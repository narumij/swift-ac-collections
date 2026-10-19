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
CREATE TABLE consumption_claims (scope TEXT NOT NULL, constituent TEXT NOT NULL, operation_id TEXT NOT NULL, PRIMARY KEY (scope, constituent));
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


class IdentityHeld(ValueError):
    """The declared ancestry does not allow this registration now (not stated, or an ancestor save already registered
    the same draft). Raised inside the write transaction; nothing is recorded, so the operation stays unused."""


class ConsumedElsewhere(Refused):
    """A constituent named in request.consumes is already claimed by another operation of the same scope."""


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
        claims = _claims(request)
        conn.execute('SAVEPOINT work')
        try:
            for scope, c in claims:  # checked under this write transaction, not only in a caller's preflight
                row = conn.execute('SELECT operation_id FROM consumption_claims WHERE scope = ? AND constituent = ?', (scope, c)).fetchone()
                if row and row[0] != operation_id:
                    raise ConsumedElsewhere(f'{c} already consumed by {row[0]}; it cannot be used again in another form (fail closed)')
            result, before, after = _run(conn, operation_id, request, hook)
        except Refused as error:
            conn.execute('ROLLBACK TO work')
            conn.execute('RELEASE work')
            if hook:
                hook('refused')
            record('refused', {'error': str(error)}, None, None, None)
            if not isinstance(error, ConsumedElsewhere):  # a refused operation still holds what it consumed
                conn.executemany('INSERT INTO consumption_claims VALUES (?, ?, ?)', [(scope, c, operation_id) for scope, c in claims])
            conn.execute('COMMIT')
            raise
        conn.execute('RELEASE work')
        if hook:
            hook('validated')
        result['revision'] = revision(conn) + 1
        conn.execute('INSERT INTO revisions VALUES (?, ?, ?)', (gen, result['revision'], operation_id))
        record('done', result, result['revision'], before, after)  # the change and its history commit together
        conn.executemany('INSERT INTO consumption_claims VALUES (?, ?, ?)', [(scope, c, operation_id) for scope, c in claims])
        conn.execute('COMMIT')
        return result
    except BaseException:
        if conn.in_transaction:
            conn.execute('ROLLBACK')
        raise


def _claims(request):
    """(scope, constituent) pairs an operation claims: request.consumes within request.consumerScope (OPS-170)."""
    consumes, scope = request.get('consumes'), request.get('consumerScope')
    if consumes is None and scope is None:
        return []
    if not isinstance(scope, str) or not scope or not isinstance(consumes, list) or not consumes or not all(isinstance(c, str) and c for c in consumes) or len(set(consumes)) != len(consumes):
        raise ValueError('consumes needs a non-empty consumerScope and a non-empty list of distinct constituents')
    return [(scope, c) for c in consumes]


def _live_task(conn, tid):
    row = conn.execute("SELECT kind FROM nodes WHERE id = ?", (tid,)).fetchone()
    if not row:
        raise Refused(f'unknown ID {tid}')
    if row[0] != 'task':
        raise Refused(f'{tid} is not a task')
    if conn.execute('SELECT 1 FROM retirements WHERE id = ?', (tid,)).fetchone():
        raise Refused(f'{tid} is retired')


def _run(conn, operation_id, req, hook=None):
    kind = req['kind']
    if kind in STRUCTURAL:
        return STRUCTURAL[kind](conn, operation_id, req, hook)
    if kind in EXPERIMENT_UNSUPPORTED:
        raise Refused(f'experiment-unsupported: {kind} ({EXPERIMENT_UNSUPPORTED[kind]}); this is not a canonical prohibition')
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


# ---- OPS-169 K2: structural writes ----------------------------------------------------------------------------------
# Every op names the current values it relies on (base); a missing target or another value is a conflict. Changes are
# validated on the post-change structure inside the transaction; a remove + add pair is one operation (hook 'between'
# runs between them, test-only). conditionReview is never stored: a new edge or link needs explicit constraint text,
# which the DB stores but does not approve.

EXPERIMENT_UNSUPPORTED = {
    'reparent': 'single-parent policy and a dedicated reparent op are undecided (OPS-167); use rewire_edge on the management graph',
    'set_task_permanent': 'who may change permanence is undecided (OPS-167)',
}
# milestone link directions this experiment supports; others are undecided, not forbidden
LINK_SUPPORTED = {('task', 'end'), ('task', 'card'), ('card', 'task'), ('start', 'task')}


def _conflict(what, detail):
    raise Refused(f'conflict on {what}: {detail}')


def _edge_attrs(conn, graph, a, b):
    row = conn.execute('SELECT flow, constraint_text FROM graph_edges WHERE graph = ? AND prerequisite = ? AND successor = ?', (graph, a, b)).fetchone()
    return None if row is None else {'flow': row[0], 'constraint': row[1]}


def _expect(what, current, base):
    if current is None:
        _conflict(what, 'it no longer exists')
    for k, v in base.items():
        if current.get(k) != v:
            _conflict(what, f'{k} changed since the base')


def _cycles(conn, graph):
    if graph == 'management':
        edges = conn.execute("SELECT prerequisite, successor FROM graph_edges WHERE graph = 'management'").fetchall()
    else:
        edges = conn.execute("SELECT prerequisite, successor FROM graph_edges WHERE graph IN ('progress','milestone')").fetchall() + r3.skeleton(conn)
    if (n := r3._cycle(edges)):
        raise Refused(f'{graph} cycle through {n}')


def _constraint(req, graph):
    c = req.get('constraint')
    if graph in ('progress', 'milestone') and (not isinstance(c, str) or not c.strip()):
        raise Refused('explicit constraint text is required for a new edge or link (conditionReview is not stored, nothing is carried over)')
    return c if graph != 'management' else ''


def _exact_base(req, fields, what=''):
    """The request's base must be a mapping with exactly these fields: missing, partial, unknown or malformed bases are
    refused before any change (destructive ops must state everything they remove)."""
    base = req.get('base') if 'base' in req else None
    if not isinstance(base, dict) or set(base) != set(fields):
        raise Refused('base must be exactly ' + (', '.join(sorted(fields)) if fields else '{}') + what)
    return base


def _edge_base(graph, req):
    return _exact_base(req, {'flow', 'constraint'}) if graph == 'progress' else _exact_base(req, set(), ' for management')


def _graph(req):
    if req['graph'] not in ('progress', 'management'):
        raise Refused(f"graph must be progress or management, not {req['graph']}")
    return req['graph']


def _insert_edge(conn, operation_id, graph, a, b, flow, constraint):
    for x in (a, b):
        _live_task(conn, x)
    if a == b:
        raise Refused('an edge needs two different tasks')
    if _edge_attrs(conn, graph, a, b) is not None:
        raise Refused(f'{graph} edge {a} -> {b} already exists')
    if graph == 'progress' and flow not in ('SEQUENCE', 'PARALLEL_JOIN'):
        raise Refused(f'flow must be SEQUENCE or PARALLEL_JOIN, not {flow!r}')
    conn.execute('INSERT INTO graph_edges VALUES (?, ?, ?, ?, ?)', (graph, a, b, flow if graph == 'progress' else None, constraint))
    conn.execute('INSERT OR REPLACE INTO provenance VALUES (?, ?)', (f'edge:{graph}:{a}->{b}', 'operation:' + operation_id))


def _delete_edge(conn, graph, a, b):
    conn.execute('DELETE FROM graph_edges WHERE graph = ? AND prerequisite = ? AND successor = ?', (graph, a, b))
    conn.execute('DELETE FROM provenance WHERE subject = ?', (f'edge:{graph}:{a}->{b}',))


def _remove_edge(conn, operation_id, req, hook):
    graph, a, b = _graph(req), req['prerequisite'], req['successor']
    current = _edge_attrs(conn, graph, a, b)
    _expect(f'{graph} edge {a} -> {b}', current, _edge_base(graph, req))
    _delete_edge(conn, graph, a, b)  # endpoints may be retired: removal is cleanup
    return {'kind': 'remove_edge', 'graph': graph, 'prerequisite': a, 'successor': b}, dict(current, graph=graph, prerequisite=a, successor=b), None


def _set_edge(conn, operation_id, req, hook):
    a, b = req['prerequisite'], req['successor']
    if req.get('graph') != 'progress':
        raise Refused('only progress edges have flow and constraint')
    changes = req.get('changes')
    if not isinstance(changes, dict) or not changes or set(changes) - {'flow', 'constraint'}:
        raise Refused('set_edge changes flow and/or constraint')
    base = _exact_base(req, set(changes))
    for x in (a, b):
        _live_task(conn, x)  # a setter keeps the edge: its endpoints must be live (only removal cleans up retired ones)
    current = _edge_attrs(conn, 'progress', a, b)
    _expect(f'progress edge {a} -> {b}', current, base)
    if changes.get('flow', current['flow']) not in ('SEQUENCE', 'PARALLEL_JOIN'):
        raise Refused(f"flow must be SEQUENCE or PARALLEL_JOIN, not {changes['flow']!r}")
    if 'constraint' in changes and (not isinstance(changes['constraint'], str) or not changes['constraint'].strip()):
        raise Refused('constraint text must not be empty')
    for k, column in (('flow', 'flow'), ('constraint', 'constraint_text')):
        if k in changes:
            conn.execute(f'UPDATE graph_edges SET {column} = ? WHERE graph = ? AND prerequisite = ? AND successor = ?', (changes[k], 'progress', a, b))
    return {'kind': 'set_edge', 'prerequisite': a, 'successor': b}, dict(current, prerequisite=a, successor=b), dict(current, **changes, prerequisite=a, successor=b)


def _rewire_edge(conn, operation_id, req, hook):
    graph = _graph(req)
    (a, b), (c, d) = (req['from']['prerequisite'], req['from']['successor']), (req['to']['prerequisite'], req['to']['successor'])
    if (a, b) == (c, d):
        raise Refused('rewire needs a different edge')
    current = _edge_attrs(conn, graph, a, b)
    _expect(f'{graph} edge {a} -> {b}', current, _edge_base(graph, req))
    constraint = _constraint(req, graph)
    _delete_edge(conn, graph, a, b)
    if hook:
        hook('between')
    _insert_edge(conn, operation_id, graph, c, d, req.get('flow', current['flow']), constraint)
    _cycles(conn, graph)
    after = dict(_edge_attrs(conn, graph, c, d), graph=graph, prerequisite=c, successor=d)
    return {'kind': 'rewire_edge', 'graph': graph, 'from': [a, b], 'to': [c, d]}, dict(current, graph=graph, prerequisite=a, successor=b), after


def _milestone_kinds(conn, a, b):
    kinds = [conn.execute('SELECT kind FROM nodes WHERE id = ?', (x,)).fetchone() for x in (a, b)]
    for x, k in zip((a, b), kinds):
        if k is None:
            raise Refused(f'unknown ID {x}')
    return tuple(k[0] for k in kinds)


def _link_rules(conn, a, b):
    kinds = _milestone_kinds(conn, a, b)
    if kinds.count('task') != 1:
        raise Refused(f'a milestone link joins exactly one task and one milestone node, got {kinds}')
    if 'gate' in kinds:
        raise Refused('canonical: tasks are not connected to a release gate (Milestones/README, Registry マイルストーン接続)')
    if kinds not in LINK_SUPPORTED:
        raise Refused(f'experiment-unsupported direction {kinds[0]} -> {kinds[1]}: undecided (OPS-167), not a canonical prohibition')
    _live_task(conn, a if kinds[0] == 'task' else b)


def _add_link(conn, operation_id, req, hook):
    a, b = req['prerequisite'], req['successor']
    _link_rules(conn, a, b)
    if _edge_attrs(conn, 'milestone', a, b) is not None:
        raise Refused(f'milestone link {a} -> {b} already exists')
    constraint = _constraint(req, 'milestone')
    conn.execute('INSERT INTO graph_edges VALUES (?, ?, ?, NULL, ?)', ('milestone', a, b, constraint))
    conn.execute('INSERT OR REPLACE INTO provenance VALUES (?, ?)', (f'edge:milestone:{a}->{b}', 'operation:' + operation_id))
    _cycles(conn, 'milestone')
    return {'kind': 'add_milestone_link', 'prerequisite': a, 'successor': b}, None, {'prerequisite': a, 'successor': b, 'constraint': constraint}


def _remove_link(conn, operation_id, req, hook):
    a, b = req['prerequisite'], req['successor']
    current = _edge_attrs(conn, 'milestone', a, b)
    _expect(f'milestone link {a} -> {b}', current, _exact_base(req, {'constraint'}))
    _delete_edge(conn, 'milestone', a, b)  # a retired task's link may be removed: cleanup
    return {'kind': 'remove_milestone_link', 'prerequisite': a, 'successor': b}, {'prerequisite': a, 'successor': b, 'constraint': current['constraint']}, None


def _set_link(conn, operation_id, req, hook):
    a, b, changes = req['prerequisite'], req['successor'], req.get('changes')
    base = _exact_base(req, {'constraint'})
    if not isinstance(changes, dict) or set(changes) != {'constraint'} or not isinstance(changes['constraint'], str) or not changes['constraint'].strip():
        raise Refused('set_milestone_link changes the constraint only, with non-empty text')
    kinds = _milestone_kinds(conn, a, b)
    if kinds.count('task') == 1:
        _live_task(conn, a if kinds[0] == 'task' else b)  # a setter keeps the link: its task must be live
    current = _edge_attrs(conn, 'milestone', a, b)
    _expect(f'milestone link {a} -> {b}', current, base)
    conn.execute("UPDATE graph_edges SET constraint_text = ? WHERE graph = 'milestone' AND prerequisite = ? AND successor = ?", (changes['constraint'], a, b))
    return {'kind': 'set_milestone_link', 'prerequisite': a, 'successor': b}, {'constraint': current['constraint']}, {'constraint': changes['constraint']}


def _rewire_link(conn, operation_id, req, hook):
    (a, b), (c, d) = (req['from']['prerequisite'], req['from']['successor']), (req['to']['prerequisite'], req['to']['successor'])
    if (a, b) == (c, d):
        raise Refused('rewire needs a different link')
    current = _edge_attrs(conn, 'milestone', a, b)
    _expect(f'milestone link {a} -> {b}', current, _exact_base(req, {'constraint'}))
    _delete_edge(conn, 'milestone', a, b)
    if hook:
        hook('between')
    _, _, after = _add_link(conn, operation_id, {'prerequisite': c, 'successor': d, 'constraint': req.get('constraint')}, None)
    return {'kind': 'rewire_milestone_link', 'from': [a, b], 'to': [c, d]}, {'prerequisite': a, 'successor': b, 'constraint': current['constraint']}, after


def _set_group(conn, operation_id, req, hook):
    tid, group = req['id'], req['group']
    _live_task(conn, tid)
    if group is not None and (not isinstance(group, str) or not group.strip()):
        raise Refused('group is a non-empty heading text or null')
    base = _exact_base(req, {'group'})
    current = conn.execute('SELECT task_group FROM tasks WHERE id = ?', (tid,)).fetchone()[0]
    if current != group:  # equal to the new value: already reflected, as update_task
        _expect(f'{tid} group', {'group': current}, base)
    conn.execute('UPDATE tasks SET task_group = ? WHERE id = ?', (group, tid))
    return {'kind': 'set_task_group', 'id': tid, 'alreadyReflected': current == group}, {'id': tid, 'group': current}, {'id': tid, 'group': group}


STRUCTURAL = {'remove_edge': _remove_edge, 'set_edge': _set_edge, 'rewire_edge': _rewire_edge, 'add_milestone_link': _add_link,
              'remove_milestone_link': _remove_link, 'set_milestone_link': _set_link, 'rewire_milestone_link': _rewire_link, 'set_task_group': _set_group}


# ---- OPS-171 K4: proposal registration ------------------------------------------------------------------------------
DRAFT = re.compile(r'draft-[1-9]\d*')


def _register_proposal(conn, operation_id, req, hook):
    """Register one draft and every connection that references it, in this one transaction: number (highwater + 1),
    proposal_map (saveId, draftId), then the edges and links with the draft ID replaced by the formal ID, validated by
    the K2 rules on the post-change structure. Any refusal or failure undoes all of it (no number used)."""
    key, fields = req['proposal'], req['fields']
    draft = key.get('draftId') if isinstance(key, dict) else None
    if not isinstance(key, dict) or not isinstance(key.get('saveId'), str) or not key['saveId'] or not isinstance(draft, str) or not DRAFT.fullmatch(draft):
        raise Refused('proposal needs a saveId and a draft-N id')
    ancestry = req.get('ancestry')
    if ancestry == {'independent': True}:
        ancestors = []
    elif isinstance(ancestry, dict) and set(ancestry) == {'ancestors'} and isinstance(ancestry['ancestors'], list) and ancestry['ancestors'] \
            and all(isinstance(a, str) and a for a in ancestry['ancestors']):
        ancestors = ancestry['ancestors']
    else:
        raise IdentityHeld('identity: ancestry not stated (state independent or the known ancestor saves)')
    for anc in ancestors:  # under this write transaction: an ancestor registered meanwhile holds this one
        row = conn.execute('SELECT formal_id FROM proposal_map WHERE save_id = ? AND draft_id = ?', (anc, draft)).fetchone()
        if row:
            raise IdentityHeld(f'identity: ancestor save {anc} registered {draft} as {row[0]}')
    if not isinstance(fields, dict) or set(fields) - {'state', 'owner', 'item', 'condition', 'detail', 'group'} or {'state', 'owner', 'item', 'condition', 'detail'} - set(fields) \
            or not all(isinstance(fields[k], str) and fields[k].strip() for k in ('state', 'owner', 'item')) \
            or not all(isinstance(fields[k], str) for k in ('condition', 'detail')) \
            or not (fields.get('group') is None or (isinstance(fields['group'], str) and fields['group'].strip())):
        raise Refused('fields must be given explicitly: state, owner, item (non-empty text), condition, detail (text), and group (non-empty text or null)')
    if not isinstance(req.get('edges', []), list) or not isinstance(req.get('links', []), list):
        raise Refused('edges and links are lists')
    connections = [('edge', e) for e in req.get('edges', [])] + [('link', e) for e in req.get('links', [])]
    for kind, e in connections:
        if not isinstance(e, dict) or not isinstance(e.get('prerequisite'), str) or not isinstance(e.get('successor'), str) \
                or (kind == 'edge' and e.get('flow', 'SEQUENCE') not in ('SEQUENCE', 'PARALLEL_JOIN')):
            raise Refused(f'{kind} entries need prerequisite and successor text' + (' and a SEQUENCE/PARALLEL_JOIN flow' if kind == 'edge' else ''))
        ends = (e['prerequisite'], e['successor'])
        if ends.count(draft) != 1:
            raise Refused(f'{kind} {ends[0]} -> {ends[1]} must reference {draft} exactly once')
        other = ends[1] if ends[0] == draft else ends[0]
        if DRAFT.fullmatch(other):
            raise Refused(f'experiment-unsupported: draft-to-draft connection {ends[0]} -> {ends[1]}')
        if not isinstance(e.get('constraint'), str) or not e['constraint'].strip():
            raise Refused(f'{kind} {ends[0]} -> {ends[1]}: an explicit consulted constraint is required')
    if not isinstance(req.get('prefix'), str):
        raise Refused('prefix is text')
    result, before, after = _register(conn, operation_id, {'prefix': req['prefix'], 'fields': dict(fields, permanent=False), 'proposal': key})
    tid = result['id']
    swap = lambda x: tid if x == draft else x
    added = []
    for kind, e in connections:
        a, b = swap(e['prerequisite']), swap(e['successor'])
        if kind == 'edge':
            _insert_edge(conn, operation_id, 'progress', a, b, e.get('flow', 'SEQUENCE'), e['constraint'])
        else:
            _link_rules(conn, a, b)
            if _edge_attrs(conn, 'milestone', a, b) is not None:
                raise Refused(f'milestone link {a} -> {b} already exists')
            conn.execute("INSERT INTO graph_edges VALUES ('milestone', ?, ?, NULL, ?)", (a, b, e['constraint']))
            conn.execute('INSERT OR REPLACE INTO provenance VALUES (?, ?)', (f'edge:milestone:{a}->{b}', 'operation:' + operation_id))
        added.append({'kind': kind, 'prerequisite': a, 'successor': b, 'constraint': e['constraint']})
    _cycles(conn, 'progress')  # progress + milestone links + skeleton, after every connection is in place
    after = dict(after, connections=added)
    return {'kind': 'register_proposal', 'id': tid, 'proposal': key, 'connections': len(added)}, before, after


STRUCTURAL['register_proposal'] = _register_proposal
