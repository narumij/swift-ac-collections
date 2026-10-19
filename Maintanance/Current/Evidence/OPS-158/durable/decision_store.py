"""OPS-158 isolated continuation: an append-only SQLite event store for a few decision records. Experiment only.

Not an authority: the decision canonical stays in Markdown. This store records, for each decision ID, its revisions,
which revision was adopted (as an external fact), and references to copies and other locators. It never decides,
approves or validates anything; a reference is never proof that a copy is still correct.

Model
- events: one row per operation (op_id unique), never updated or deleted (SQLite triggers abort UPDATE/DELETE).
  Refused operations are recorded too, so a replay of the same op_id returns the same refusal.
- The state is derived by folding the done events in order (fold); there are no mutable status columns.
- One scope per decision ID: a different scope is a different ID (no coexistence model, no cross-scope inference).

Operations (request = {kind, actor, ...}; actor is the registrar, self-declared)
- register {id, scope, statement, source}: a new ID (never reused) with revision 1 as a proposal.
- propose {id, base_revision, statement, source}: revision n+1 as a proposal; base_revision must be the latest.
- record_adoption {id, revision, replaces, decided_by, source}: records that decided_by adopted that proposed revision
  elsewhere (source names where). replaces must be the currently adopted revision (null when none). It grants no
  authority and does not check what the source says; the semantic check stays human.
- add_reference {ref_id, decision, revision, ref_kind, locator}: a copy / historical-open / source /
  rejected-alternative / evidence locator for an existing decision revision.

Contracts (the shape of the accepted Registry V3 writer, not its code)
- init(path) creates a new DB file exclusively; every other entry opens an existing DB only (mode=rw, never creates).
- apply(conn, op_id, request) runs in BEGIN IMMEDIATE: a known op_id with the same request digest replays the stored
  result (or refusal); a different digest is OperationMismatch; otherwise the folded state is checked and one event
  is appended. A stale base is a refusal, never a last-writer-wins overwrite.
- review_candidates(conn, id): copies of this decision that refer to a revision older than the adopted one (copies made
  before the latest adoption). With no adopted revision it lists nothing; a copy tied to a newer, unadopted proposal is
  not a candidate. It only lists; nothing is changed, and other decisions are not affected.
"""
import datetime
import hashlib
import json
import re
import sqlite3
from pathlib import Path

SCHEMA_VERSION = 1
SCHEMA = """
CREATE TABLE meta (one INTEGER PRIMARY KEY CHECK (one = 1), schema_version INTEGER NOT NULL, created_at TEXT NOT NULL);
CREATE TABLE events (seq INTEGER PRIMARY KEY AUTOINCREMENT, op_id TEXT NOT NULL UNIQUE, digest TEXT NOT NULL,
                     kind TEXT NOT NULL, status TEXT NOT NULL CHECK (status IN ('done', 'refused')),
                     request TEXT NOT NULL, result TEXT NOT NULL, actor TEXT NOT NULL, recorded_at TEXT NOT NULL);
CREATE TRIGGER events_append_only_update BEFORE UPDATE ON events BEGIN SELECT RAISE(ABORT, 'events are append-only'); END;
CREATE TRIGGER events_append_only_delete BEFORE DELETE ON events BEGIN SELECT RAISE(ABORT, 'events are append-only'); END;
"""
KINDS = ('register', 'propose', 'record_adoption', 'add_reference')
REF_KINDS = ('copy', 'historical-open', 'source', 'rejected-alternative', 'evidence')
ID = re.compile(r'[A-Z][A-Za-z0-9-]{0,63}')


class Refused(ValueError):
    """A deterministic refusal; it is recorded under its op_id."""


class OperationMismatch(ValueError):
    """The op_id was already used with a different request."""


class NotADecisionStore(ValueError):
    """The path is not an existing decision store of this schema."""


def now():
    return datetime.datetime.now(datetime.timezone.utc).isoformat()


def digest(request):
    return hashlib.sha256(json.dumps(request, ensure_ascii=False, sort_keys=True, separators=(',', ':')).encode('utf-8')).hexdigest()


def init(path):
    """Create a new store at path; an existing path (even an empty file) is refused, nothing is overwritten."""
    p = Path(path)
    with open(p, 'x'):  # exclusive creation: refuses an existing path
        pass
    conn = sqlite3.connect(str(p), isolation_level=None)
    try:
        conn.executescript(SCHEMA)
        conn.execute('INSERT INTO meta VALUES (1, ?, ?)', (SCHEMA_VERSION, now()))
    finally:
        conn.close()
    return p


def open_store(path, timeout=5.0):
    """An existing store only: opened read-write through the escaped file URI (mode=rw never creates a file)."""
    p = Path(path)
    if not p.is_file():
        raise FileNotFoundError(f'{p}: no decision store (run init first; it is never created implicitly)')
    conn = sqlite3.connect(p.resolve().as_uri() + '?mode=rw', uri=True, isolation_level=None, timeout=timeout)
    try:
        row = conn.execute('SELECT schema_version FROM meta').fetchone()
    except sqlite3.DatabaseError as error:
        conn.close()
        raise NotADecisionStore(f'{p}: not a decision store ({error})') from None
    if not row or row[0] != SCHEMA_VERSION:
        conn.close()
        raise NotADecisionStore(f'{p}: schema version {row and row[0]} is not {SCHEMA_VERSION}')
    return conn


def _text(req, key):
    v = req.get(key)
    if not isinstance(v, str) or not v.strip():
        raise Refused(f'{key} must be non-empty text')
    return v


def _locator(req, key):
    v = req.get(key)
    if not isinstance(v, dict) or not v or not all(isinstance(k, str) for k in v):
        raise Refused(f'{key} must be a non-empty locator object (for example path, line, text, sha256, or a letter ID)')
    return v


def fold(events):
    """The state from the done events, in order: {decisions: {id: {...}}, references: {ref_id: {...}}}."""
    decisions, references = {}, {}
    for kind, request in events:
        if kind == 'register':
            decisions[request['id']] = {'scope': request['scope'], 'adopted': None,
                                        'revisions': {1: {'statement': request['statement'], 'source': request['source'],
                                                          'proposedBy': request['actor'], 'adoption': None}}}
        elif kind == 'propose':
            d = decisions[request['id']]
            d['revisions'][max(d['revisions']) + 1] = {'statement': request['statement'], 'source': request['source'],
                                                       'proposedBy': request['actor'], 'adoption': None}
        elif kind == 'record_adoption':
            d = decisions[request['id']]
            d['revisions'][request['revision']]['adoption'] = {'decidedBy': request['decided_by'], 'source': request['source'],
                                                               'replaces': request['replaces'], 'recordedBy': request['actor']}
            d['adopted'] = request['revision']
        elif kind == 'add_reference':
            references[request['ref_id']] = {'decision': request['decision'], 'revision': request['revision'],
                                             'kind': request['ref_kind'], 'locator': request['locator']}
    return {'decisions': decisions, 'references': references}


def state(conn):
    return fold([(k, json.loads(r)) for k, r in conn.execute("SELECT kind, request FROM events WHERE status = 'done' ORDER BY seq")])


def _check(st, req):
    """The result of one operation on the folded state, or Refused."""
    kind = req['kind']
    decisions = st['decisions']
    if kind == 'register':
        did = _text(req, 'id')
        if not ID.fullmatch(did):
            raise Refused(f'{did!r} is not a decision ID (a capital letter, then letters, digits, hyphens)')
        if did in decisions:
            raise Refused(f'{did} already exists; IDs are never reused (a different scope is a different ID)')
        _text(req, 'scope'), _text(req, 'statement'), _locator(req, 'source')
        return {'id': did, 'revision': 1, 'status': 'proposed'}
    did = req.get('id') if kind != 'add_reference' else req.get('decision')
    if did not in decisions:
        raise Refused(f'unknown decision {did!r}')
    d = decisions[did]
    if kind == 'propose':
        _text(req, 'statement'), _locator(req, 'source')
        latest = max(d['revisions'])
        if req.get('base_revision') != latest:
            raise Refused(f'conflict on {did}: the latest revision is {latest}, not {req.get("base_revision")!r}')
        return {'id': did, 'revision': latest + 1, 'status': 'proposed'}
    if kind == 'record_adoption':
        _text(req, 'decided_by'), _locator(req, 'source')
        rev = req.get('revision')
        if type(rev) is not int or rev not in d['revisions']:
            raise Refused(f'{did} has no revision {rev!r}')
        if d['revisions'][rev]['adoption'] is not None or (d['adopted'] is not None and rev < d['adopted']):
            raise Refused(f'{did} revision {rev} is not an open proposal (already adopted or superseded)')
        if 'replaces' not in req or req['replaces'] != d['adopted']:
            raise Refused(f'conflict on {did}: replaces must name the adopted revision {d["adopted"]!r}, not {req.get("replaces")!r}')
        return {'id': did, 'revision': rev, 'recorded': 'adoption', 'replaces': d['adopted'],
                'note': 'records an external decision; grants no authority and does not check the source'}
    if kind == 'add_reference':
        rid = _text(req, 'ref_id')
        if rid in st['references']:
            raise Refused(f'reference {rid} already exists')
        if req.get('ref_kind') not in REF_KINDS:
            raise Refused(f'ref_kind must be one of {", ".join(REF_KINDS)}')
        rev = req.get('revision')
        if type(rev) is not int or rev not in d['revisions']:
            raise Refused(f'{did} has no revision {rev!r}')
        _locator(req, 'locator')
        return {'ref_id': rid, 'decision': did, 'revision': rev}
    raise Refused(f'unknown kind {kind!r}')


def apply(conn, op_id, request):
    """One operation: replay, mismatch, refusal or one appended event (see the module contract)."""
    if not isinstance(op_id, str) or not op_id:
        raise ValueError('op_id must be non-empty text')
    if not isinstance(request, dict) or request.get('kind') not in KINDS or not isinstance(request.get('actor'), str) or not request['actor'].strip():
        raise ValueError('a request is an object with kind (' + ', '.join(KINDS) + ') and actor (non-empty)')
    want = digest(request)
    conn.execute('BEGIN IMMEDIATE')
    try:
        known = conn.execute('SELECT digest, status, result FROM events WHERE op_id = ?', (op_id,)).fetchone()
        if known:
            conn.execute('ROLLBACK')
            if known[0] != want:
                raise OperationMismatch(f'operation {op_id} was used with a different request')
            result = json.loads(known[2])
            if known[1] == 'refused':
                raise Refused(result['error'])
            return dict(result, replayed=True)
        try:
            result, status = _check(state(conn), request), 'done'
        except Refused as error:
            result, status = {'error': str(error)}, 'refused'
        conn.execute('INSERT INTO events (op_id, digest, kind, status, request, result, actor, recorded_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
                     (op_id, want, request['kind'], status, json.dumps(request, ensure_ascii=False, sort_keys=True),
                      json.dumps(result, ensure_ascii=False, sort_keys=True), request['actor'], now()))
        conn.execute('COMMIT')
    except BaseException:
        if conn.in_transaction:
            conn.execute('ROLLBACK')
        raise
    if status == 'refused':
        raise Refused(result['error'])
    return dict(result, replayed=False)


def decision(conn, did):
    """One decision with all its revisions (old ones kept) and its references; None when unknown."""
    st = state(conn)
    d = st['decisions'].get(did)
    if d is None:
        return None
    return {'id': did, 'scope': d['scope'], 'adopted': d['adopted'],
            'revisions': {str(n): r for n, r in sorted(d['revisions'].items())},
            'references': {rid: r for rid, r in sorted(st['references'].items()) if r['decision'] == did}}


def review_candidates(conn, did):
    """Copies of did whose revision is older than the adopted one; [] while nothing is adopted. Lists only."""
    st = state(conn)
    d = st['decisions'].get(did)
    if d is None:
        return None
    if d['adopted'] is None:
        return []
    return sorted(rid for rid, r in st['references'].items() if r['decision'] == did and r['kind'] == 'copy' and r['revision'] < d['adopted'])


def export(conn):
    """Every event in order, done and refused, as plain dicts (for review; it is not a backup procedure)."""
    return [{'seq': s, 'opId': o, 'kind': k, 'status': st, 'request': json.loads(rq), 'result': json.loads(rs), 'recordedAt': at}
            for s, o, k, st, rq, rs, at in conn.execute('SELECT seq, op_id, kind, status, request, result, recorded_at FROM events ORDER BY seq')]
