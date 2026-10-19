#!/usr/bin/env python3
"""OPS-161 stage 2 isolated experiment: the update contract of TASK_REGISTRY_V3_DESIGN.md as Python calls on a SQLite
file in a temporary directory. No HTTP, UI, Inbox, live DB or production use.

apply(conn, operation_id, request) runs one operation in one BEGIN IMMEDIATE transaction:
- replay: the operation ID and the SHA-256 of the canonical request are kept forever. The same ID with the same request
  returns the stored result (an earlier refusal included) without writing; the same ID with another request is refused
  and changes nothing. A reduced request after a refusal therefore needs a new operation ID.
- register_task: the next number of the prefix (highwater + 1), never an issued one; an optional proposal key
  (saveId, draftId) is mapped to the formal ID once, and a second registration of the same key is refused rather than
  numbered again. The number is visible only in the committed result.
- update_task: every changed field carries its base value. The field is applied when the latest value still equals the
  base, treated as already reflected when it equals the new value, and refused as a conflict otherwise; changes to other
  fields from the same base stay independent. Retired tasks cannot be edited.
- retire_task: the ID stays reserved (node, issue record); it is never issued again and cannot get new edges.
- add_edge: management (parent -> child) or progress (task -> task); validated against the latest committed state inside
  the transaction, so two edges that are fine alone but make a cycle together are refused for the later one. The two
  graphs are checked separately; progress cycles include the milestone connections and the derived skeleton.
OPS-164: every DB has a generation ID and a write switch (db_meta). A request names its generation and carries a
self-declared actor and evidence references (not authenticated). Another generation is refused without any change; an
operation ID of an earlier generation is never replayed (operation() still returns its record). The operation record
keeps the request, digest, result, actor, evidence and the before/after of the change.
Data, issue records, the operation record and the new revision are committed together; any failure rolls all back.
Deterministic refusals (Refused) undo the business changes (savepoint) and are recorded for replay in the same\ntransaction; other errors roll the whole transaction back and are not recorded.
"""
import hashlib
import json
import re
import sqlite3
import uuid
from pathlib import Path

import registry_v3_read as r3

WRITE_SCHEMA = """
CREATE TABLE id_allocations (prefix TEXT PRIMARY KEY, highwater INTEGER NOT NULL CHECK (highwater >= 0));
CREATE TABLE issued_ids (id TEXT PRIMARY KEY, prefix TEXT NOT NULL, number INTEGER NOT NULL, operation_id TEXT, UNIQUE (prefix, number));
CREATE TABLE retirements (id TEXT PRIMARY KEY REFERENCES nodes(id), revision INTEGER NOT NULL, reason TEXT NOT NULL);
CREATE TABLE proposal_map (save_id TEXT NOT NULL, draft_id TEXT NOT NULL, formal_id TEXT NOT NULL UNIQUE REFERENCES nodes(id), PRIMARY KEY (save_id, draft_id));
CREATE TABLE db_meta (one INTEGER PRIMARY KEY CHECK (one = 1), schema_version INTEGER NOT NULL, generation TEXT NOT NULL,
  write_enabled INTEGER NOT NULL CHECK (write_enabled IN (0, 1)));
CREATE TABLE lineage (sequence INTEGER PRIMARY KEY AUTOINCREMENT, generation TEXT NOT NULL, event TEXT NOT NULL, detail TEXT NOT NULL);
CREATE TABLE revisions (generation TEXT NOT NULL, revision INTEGER NOT NULL, operation_id TEXT NOT NULL UNIQUE, PRIMARY KEY (generation, revision));
CREATE TABLE operations (operation_id TEXT PRIMARY KEY, generation TEXT NOT NULL, digest TEXT NOT NULL, status TEXT NOT NULL CHECK (status IN ('done','refused')),
  result TEXT NOT NULL, revision INTEGER, request TEXT NOT NULL, actor TEXT NOT NULL, evidence TEXT NOT NULL, before_state TEXT, after_state TEXT);
"""
SCHEMA_VERSION = 1
TASK_ID = re.compile(r'([A-Z]+)-(\d+)')
EDITABLE = ('state', 'owner', 'item', 'condition', 'detail')


class OperationMismatch(ValueError):
    """The operation ID was already used with a different request."""


class GenerationMismatch(ValueError):
    """The request names another generation of the DB (for example one made before a restore); nothing is changed."""


class OperationFromEarlierGeneration(ValueError):
    """The operation ID belongs to an earlier generation; its result can be queried but it is never replayed or reused."""


class WriteDisabled(ValueError):
    """Writes are closed (a restored generation starts closed until writes are explicitly enabled)."""


Refused = r3.Refused


def create(path, fixture):
    """Make the experiment DB file from a fixture: the read schema and data, the write tables, and the highwater per prefix.
    The highwater is the larger of the present task IDs and the fixture's optional ledger `issuedThrough` {PREFIX: n}.
    The ledger reserves every number 1..n as a non-reusable dummy allocation (user, 2026-10-19: historical IDs were reused
    and are not reconstructed): no task node, issue row or document binding is made for an absent number; only the
    fixture's own task rows are nodes. A ledger below a present ID, a bad prefix or a
    non-integer is refused, and no file is left behind."""
    ledger = fixture.get('issuedThrough', {})
    if not isinstance(ledger, dict):
        raise Refused('issuedThrough must be a mapping of prefix to the last issued number')
    for prefix, n in ledger.items():
        if not re.fullmatch(r'[A-Z]+', prefix):
            raise Refused(f'issuedThrough: bad prefix {prefix}')
        if type(n) is not int or n < 0:
            raise Refused(f'issuedThrough {prefix}: needs a non-negative integer, got {n!r}')
    if Path(path).exists():
        raise FileExistsError(f'{path} exists; create() makes a new experiment DB only')  # never touch or remove an existing file
    conn = sqlite3.connect(path, isolation_level=None)
    try:
        conn.executescript(r3.SCHEMA + WRITE_SCHEMA)
        r3.load(conn, fixture)
        highwater = {}
        for nid, in conn.execute("SELECT id FROM nodes WHERE kind = 'task' ORDER BY id"):
            m = TASK_ID.fullmatch(nid)
            if m:
                highwater[m.group(1)] = max(highwater.get(m.group(1), 0), int(m.group(2)))
                conn.execute('INSERT INTO issued_ids VALUES (?, ?, ?, NULL)', (nid, m.group(1), int(m.group(2))))
        for prefix, n in ledger.items():
            if n < highwater.get(prefix, 0):
                raise Refused(f'issuedThrough {prefix}: {n} is below the present {prefix}-{highwater[prefix]:03d}')
            highwater[prefix] = n
        conn.executemany('INSERT INTO id_allocations VALUES (?, ?)', sorted(highwater.items()))
        gen = new_generation()
        conn.execute('INSERT INTO db_meta VALUES (1, ?, ?, 1)', (SCHEMA_VERSION, gen))
        conn.execute('INSERT INTO lineage (generation, event, detail) VALUES (?, ?, ?)', (gen, 'created', json.dumps({'from': 'fixture'})))
    except BaseException:
        conn.close()
        Path(path).unlink(missing_ok=True)
        raise
    conn.close()


def is_reserved(conn, prefix, number):
    """Whether a number of the prefix can never be issued again: up to the highwater (the imported ledger reserves the
    whole interval 1..n as dummy allocations, without task nodes or any historical identity) or recorded as issued."""
    row = conn.execute('SELECT highwater FROM id_allocations WHERE prefix = ?', (prefix,)).fetchone()
    return bool((row and number <= row[0]) or conn.execute('SELECT 1 FROM issued_ids WHERE prefix = ? AND number = ?', (prefix, number)).fetchone())


def open_db(path, timeout=5.0):
    conn = sqlite3.connect(path, isolation_level=None, timeout=timeout)
    conn.execute('PRAGMA foreign_keys = ON')
    return conn


def digest(request):
    return hashlib.sha256(json.dumps(request, ensure_ascii=False, sort_keys=True, separators=(',', ':')).encode('utf-8')).hexdigest()


def new_generation():
    return 'gen-' + uuid.uuid4().hex


def generation(conn):
    return conn.execute('SELECT generation FROM db_meta').fetchone()[0]


def write_enabled(conn):
    return bool(conn.execute('SELECT write_enabled FROM db_meta').fetchone()[0])


def revision(conn):
    """The last revision of the current generation (revisions count within a generation)."""
    return conn.execute('SELECT COALESCE(MAX(revision), 0) FROM revisions WHERE generation = (SELECT generation FROM db_meta)').fetchone()[0]


def operation(conn, operation_id):
    """The stored record of an operation of any generation (request, actor, evidence, result, before/after), or None."""
    row = conn.execute('SELECT operation_id, generation, status, revision, request, actor, evidence, result, before_state, after_state FROM operations WHERE operation_id = ?',
                       (operation_id,)).fetchone()
    if not row:
        return None
    keys = ('operationId', 'generation', 'status', 'revision', 'request', 'actor', 'evidence', 'result', 'before', 'after')
    out = dict(zip(keys, row))
    for k in ('request', 'evidence', 'result', 'before', 'after'):
        out[k] = json.loads(out[k]) if out[k] is not None else None
    return out


def apply(conn, operation_id, request, hook=None):
    """Run one operation; returns its result dict. hook(stage) is for tests only: 'validated' just before commit,
    'refused' after the business changes were undone and before the refusal is recorded (the lock is still held).

    The operation ID is owned from BEGIN IMMEDIATE to COMMIT: the business changes run inside SAVEPOINT work, a refusal
    rolls back only to that savepoint and records itself in the same transaction, so no other request can claim the ID
    between the refusal and its record."""
    if not isinstance(request.get('actor'), str) or not request['actor'] or not isinstance(request.get('evidence', []), list):
        raise ValueError('a request needs actor (self-declared, not authenticated) and evidence (a list of references)')
    want = digest(request)
    conn.execute('BEGIN IMMEDIATE')
    try:
        gen, enabled = conn.execute('SELECT generation, write_enabled FROM db_meta').fetchone()
        if request.get('generation') != gen:
            raise GenerationMismatch(f"request names generation {request.get('generation')!r}; this DB is {gen}")
        known = conn.execute('SELECT digest, status, result, generation FROM operations WHERE operation_id = ?', (operation_id,)).fetchone()
        if known and known[3] != gen:
            raise OperationFromEarlierGeneration(f'operation {operation_id} belongs to generation {known[3]}; query it, it is not replayed')
        if not enabled:
            raise WriteDisabled(f'writes are closed in generation {gen}')
        if known:
            conn.execute('ROLLBACK')
            if known[0] != want:
                raise OperationMismatch(f'operation {operation_id} was used with a different request')
            result = json.loads(known[2])
            if known[1] == 'refused':
                raise Refused(result['error'])
            return result
        dump = lambda x: None if x is None else json.dumps(x, ensure_ascii=False, sort_keys=True)
        record = lambda status, result, rev, before, after: conn.execute(
            'INSERT INTO operations VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
            (operation_id, gen, want, status, dump(result), rev, dump(request), request['actor'], dump(request.get('evidence', [])), dump(before), dump(after)))
        conn.execute('SAVEPOINT work')
        try:
            result, before, after = _run(conn, operation_id, request)
        except Refused as error:
            conn.execute('ROLLBACK TO work')
            conn.execute('RELEASE work')
            if hook:
                hook('refused')
            record('refused', {'error': str(error)}, None, None, None)
            conn.execute('COMMIT')
            raise
        conn.execute('RELEASE work')
        if hook:
            hook('validated')
        result['revision'] = revision(conn) + 1
        conn.execute('INSERT INTO revisions VALUES (?, ?, ?)', (gen, result['revision'], operation_id))
        record('done', result, result['revision'], before, after)  # the change and its history commit together
        conn.execute('COMMIT')
        return result
    except BaseException:
        if conn.in_transaction:
            conn.execute('ROLLBACK')
        raise


def _live_task(conn, tid):
    row = conn.execute("SELECT kind FROM nodes WHERE id = ?", (tid,)).fetchone()
    if not row:
        raise Refused(f'unknown ID {tid}')
    if row[0] != 'task':
        raise Refused(f'{tid} is not a task')
    if conn.execute('SELECT 1 FROM retirements WHERE id = ?', (tid,)).fetchone():
        raise Refused(f'{tid} is retired')


def _run(conn, operation_id, req):
    kind = req['kind']
    if kind == 'register_task':
        return _register(conn, operation_id, req)
    if kind == 'update_task':
        return _update(conn, req)
    if kind == 'retire_task':
        _live_task(conn, req['id'])
        conn.execute('INSERT INTO retirements VALUES (?, ?, ?)', (req['id'], revision(conn) + 1, req['reason']))
        return {'kind': kind, 'id': req['id']}, {'id': req['id'], 'retired': False}, {'id': req['id'], 'retired': True, 'reason': req['reason']}
    if kind == 'add_edge':
        return _add_edge(conn, operation_id, req)
    raise Refused(f'unknown operation kind {kind}')


def _register(conn, operation_id, req):
    prefix, fields = req['prefix'], req['fields']
    if not re.fullmatch(r'[A-Z]+', prefix):
        raise Refused(f'bad prefix {prefix}')
    key = req.get('proposal')
    if key:
        mapped = conn.execute('SELECT formal_id FROM proposal_map WHERE save_id = ? AND draft_id = ?', (key['saveId'], key['draftId'])).fetchone()
        if mapped:
            raise Refused(f"proposal {key['saveId']}/{key['draftId']} is already registered as {mapped[0]}")
    row = conn.execute('SELECT highwater FROM id_allocations WHERE prefix = ?', (prefix,)).fetchone()
    before = {'highwater': row[0] if row else 0}
    number = (row[0] if row else 0) + 1
    while conn.execute('SELECT 1 FROM issued_ids WHERE prefix = ? AND number = ?', (prefix, number)).fetchone():
        number += 1  # never reuse an issued number, even one issued outside the highwater (defensive)
    tid = f'{prefix}-{number:03d}'
    if conn.execute('SELECT 1 FROM nodes WHERE id = ?', (tid,)).fetchone():
        raise Refused(f'{tid} already exists')
    conn.execute("INSERT INTO nodes VALUES (?, 'task', ?)", (tid, fields['item']))
    conn.execute('INSERT INTO tasks VALUES (?, ?, ?, ?, ?, ?, ?, ?)', (tid, fields['state'], fields['owner'], fields['item'], fields['condition'],
                                                                        fields['detail'], int(bool(fields.get('permanent', False))), fields.get('group')))
    conn.execute('INSERT INTO provenance VALUES (?, ?)', ('node:' + tid, 'operation:' + operation_id))
    conn.execute('INSERT INTO issued_ids VALUES (?, ?, ?, ?)', (tid, prefix, number, operation_id))
    conn.execute('INSERT INTO id_allocations VALUES (?, ?) ON CONFLICT (prefix) DO UPDATE SET highwater = excluded.highwater', (prefix, number))
    if key:
        conn.execute('INSERT INTO proposal_map VALUES (?, ?, ?)', (key['saveId'], key['draftId'], tid))
    after = {'highwater': number, 'id': tid, 'task': dict(fields), **({'proposal': key} if key else {})}
    return {'kind': 'register_task', 'id': tid, **({'proposal': key} if key else {})}, before, after


def _update(conn, req):
    tid, base, changes = req['id'], req['base'], req['changes']
    _live_task(conn, tid)
    if not changes or set(changes) - set(EDITABLE):
        raise Refused(f'editable fields are {", ".join(EDITABLE)}')
    missing = set(changes) - set(base)
    if missing:
        raise Refused('every changed field needs its base value: ' + ', '.join(sorted(missing)))
    now = dict(zip(EDITABLE, conn.execute('SELECT ' + ', '.join(EDITABLE) + ' FROM tasks WHERE id = ?', (tid,)).fetchone()))
    applied, reflected, conflicts = [], [], []
    for field in sorted(changes):
        if now[field] == changes[field]:
            reflected.append(field)
        elif now[field] == base[field]:
            applied.append(field)
        else:
            conflicts.append(field)
    if conflicts:
        raise Refused(f'conflict on {tid}: ' + ', '.join(conflicts) + ' changed since the base')
    for field in applied:
        conn.execute(f'UPDATE tasks SET {field} = ? WHERE id = ?', (changes[field], tid))
        if field == 'item':
            conn.execute('UPDATE nodes SET name = ? WHERE id = ?', (changes[field], tid))  # the node name is the task item
    before = {'id': tid, **{f: now[f] for f in applied}}
    after = {'id': tid, **{f: changes[f] for f in applied}}
    return {'kind': 'update_task', 'id': tid, 'applied': applied, 'alreadyReflected': reflected}, before, after


def _add_edge(conn, operation_id, req):
    graph, a, b = req['graph'], req['prerequisite'], req['successor']
    if graph not in ('management', 'progress'):
        raise Refused(f'add_edge supports management and progress, not {graph}')
    for x in (a, b):
        _live_task(conn, x)
    if a == b:
        raise Refused('an edge needs two different tasks')
    if conn.execute('SELECT 1 FROM graph_edges WHERE graph = ? AND prerequisite = ? AND successor = ?', (graph, a, b)).fetchone():
        raise Refused(f'{graph} edge {a} -> {b} already exists')
    conn.execute('INSERT INTO graph_edges VALUES (?, ?, ?, ?, ?)', (graph, a, b, req.get('flow'), req.get('constraint', '')))
    if graph == 'management':
        edges = conn.execute("SELECT prerequisite, successor FROM graph_edges WHERE graph = 'management'").fetchall()
    else:
        edges = conn.execute("SELECT prerequisite, successor FROM graph_edges WHERE graph IN ('progress','milestone')").fetchall() + r3.skeleton(conn)
    if (n := r3._cycle(edges)):
        raise Refused(f'{graph} cycle through {n}')
    conn.execute('INSERT INTO provenance VALUES (?, ?)', (f'edge:{graph}:{a}->{b}', 'operation:' + operation_id))
    edge = {'graph': graph, 'prerequisite': a, 'successor': b, 'flow': req.get('flow'), 'constraint': req.get('constraint', '')}
    return {'kind': 'add_edge', 'graph': graph, 'prerequisite': a, 'successor': b}, None, edge
