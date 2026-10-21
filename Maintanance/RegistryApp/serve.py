#!/usr/bin/env python3
"""Serve Registry Studio locally; POST /sync runs only the fixed sync.py command, POST /save stores the edited JSON in Inbox/.

V3 mode (OPS-181), off by default: --v3-db PATH --v3-saves DIR, always together. Both must already exist (nothing is
created or migrated) and the DB must be a V3 DB. Then GET / is the page sync.py built with only its Registry seed
replaced by a fresh read-only DB export, GET /registry.json is that export, GET /workspace resumes only V3 saves from
DIR, and POST /save stores only V3 saves there. POST /sync still runs sync.py (documents and the pending queue); it
never writes the DB. The narrow /task-status command also writes through v3/registry_v3_cli.py. Without the flags
nothing of V3 is imported or opened.

--output DIR (OPS-167 K9), for isolated runs: an existing directory used instead of Cache/RegistryStudio; sync.py (at
start and on POST /sync) writes its page, registry.json and tools record there, never into Cache or local-tools.json."""
import argparse
import queue
from event_notifications import events
import datetime
import re
import hashlib
import json
import os
import subprocess
import sys
import threading
import urllib.parse
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path

import activity
import work_notifications
from work_state_binding import WorkStateBinding
from task_state import TaskStateBinding
from document_state import DocumentStateBinding
import member_state
import communication_notifications as notifications
import approvals
import task_rounds
import time
import secrets
import continuity
import probe
import sqlite3
import studio_store

import inbox  # edit versions in Inbox/ (OPS-082)

# Restart-notice manual check requested by user (2026-10-18).
APP = Path(__file__).resolve().parent
ROOT = APP.parent.parent
OUTPUT = ROOT / "Maintanance/Cache/RegistryStudio"
WORK_PROGRESS = OUTPUT / 'work-progress.json'
MAX_PROGRESS_BYTES = 32 * 1024
PROGRESS_STAGES = ('preparation', 'work', 'verification', 'acceptance', 'awaiting-commit')
SYNC_LOCK = threading.Lock()
SYNC_ENV = None  # OPS-167 K9: with --output, sync.py writes its page, data and tools record there (REGISTRY_STUDIO_APP/TOOLS)
# Edited JSON handed to the AI (OPS-082). Fixed on the server side; clients never choose the path. REGISTRY_STUDIO_INBOX
# exists only so tests can use an isolated folder. Not under Cache/, so sync and restarts keep it.
INBOX = inbox.INBOX
MAX_SAVE_BYTES = 10 * 1024 * 1024


V3 = None  # OPS-181: the explicit V3 mode, {'db': Path, 'saves': Path} (v3_mode); None keeps every legacy path
V3_MODULES = ('v3/registry_v3_read.py', 'v3/registry_v3_write.py', 'v3/studio_adapter.py')  # retained in V3 mode


_WORK_VIEW = None
_WORK_VIEW_LOCK = threading.Lock()


def work_view():
    global _WORK_VIEW
    with _WORK_VIEW_LOCK:
        if _WORK_VIEW is None:
            registry_path = V3['db'] if V3 is not None else OUTPUT / 'registry.json'
            _WORK_VIEW = WorkStateBinding(
                work_notifications.observe_activity(activity.EVENTS), work_notifications.approval_changes,
                activity.read_events, lambda: approvals.Store().list(), {},
                work_notifications.letter_changes, lambda: studio_store.Store().work_snapshot(),
                work_notifications.observe_registry(registry_path),
                lambda: {row['id']: row.get('state', '') for row in registry_tasks()})
        return _WORK_VIEW.model


_TASK_VIEW = None
_TASK_VIEW_LOCK = threading.Lock()


def registry_document():
    if V3 is not None:
        _, adapter = v3_modules()
        conn = v3_open(V3['db'])
        try:
            return adapter.export_doc(conn)
        finally:
            conn.close()
    return json.loads((OUTPUT / 'registry.json').read_text(encoding='utf-8'))


def task_view():
    global _TASK_VIEW
    with _TASK_VIEW_LOCK:
        if _TASK_VIEW is None:
            path = V3['db'] if V3 is not None else OUTPUT / 'registry.json'
            _TASK_VIEW = TaskStateBinding(work_notifications.observe_registry(path), registry_document)
        return _TASK_VIEW.model


def render_document_markdown(text):
    import sync
    node, marked, _ = sync.resolve_tools()
    command = [node, str(APP / 'render-document.mjs')]
    if marked:
        command.append(marked)
    return subprocess.run(command, input=text, text=True, capture_output=True,
                          check=True, timeout=15).stdout


def runtime_fingerprints():
    # Only modules retained by this process. sync.py and HTML are read afresh.
    result = {}
    for name in ('serve.py', 'inbox.py', 'activity.py', 'work_notifications.py', 'work_state.py', 'work_state_binding.py', 'task_state.py', 'document_state.py', 'task_status_command.py', 'approvals.py', 'probe.py', 'continuity.py', 'communication_notifications.py', 'event_notifications.py', 'record_notifications.py', 'notification_log.py', 'member_state.py', 'studio_store.py', 'task_rounds.py') + (V3_MODULES if V3 else ()):
        try:
            result[name] = hashlib.sha256((APP / name).read_bytes()).hexdigest()
        except OSError:
            result[name] = None
    return result


STARTUP_FINGERPRINTS = runtime_fingerprints()


SERVER_IDENTITY = {}  # Self-reported launcher, not authentication.

def runtime_status():
    current = runtime_fingerprints()
    changed = [name for name, digest in STARTUP_FINGERPRINTS.items()
               if current[name] is None or current[name] != digest]
    return {'restartRecommended': bool(changed), 'changedFiles': changed, 'server': dict(SERVER_IDENTITY)}



def read_work_progress():
    """Read one bounded, fixed-path advisory record; never consult or change edit data."""
    try:
        with WORK_PROGRESS.open('rb') as stream:
            raw = stream.read(MAX_PROGRESS_BYTES + 1)
    except FileNotFoundError:
        return None
    if len(raw) > MAX_PROGRESS_BYTES:
        raise ValueError('Progress record too large')
    data = json.loads(raw.decode('utf-8'))
    if not isinstance(data, dict) or type(data.get('schemaVersion')) is not int or data['schemaVersion'] != 1:
        raise ValueError('Invalid progress version')
    for key, limit in (('taskId', 40), ('title', 160), ('owner', 80), ('updatedAt', 40)):
        value = data.get(key)
        if not isinstance(value, str) or not value.strip() or len(value) > limit or re.search(r'[\x00-\x1f\x7f]', value):
            raise ValueError('Invalid progress field')
    if not re.fullmatch(r'[A-Z][A-Z0-9]*-[0-9]+', data['taskId']) or data.get('stage') not in PROGRESS_STAGES:
        raise ValueError('Invalid progress task or stage')
    if not re.fullmatch(r'\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.\d{1,3})?(?:Z|[+-]\d{2}:\d{2})', data['updatedAt']):
        raise ValueError('Progress timestamp needs a timezone')
    datetime.datetime.fromisoformat(data['updatedAt'].replace('Z', '+00:00'))
    reason = data.get('waitingReason', '')
    if not isinstance(reason, str) or len(reason) > 240 or re.search(r'[\x00-\x1f\x7f]', reason):
        raise ValueError('Invalid waiting reason')
    return {key: data[key] for key in ('schemaVersion', 'taskId', 'title', 'owner', 'stage', 'updatedAt')} | {'waitingReason': reason}


def read_activity_commits():
    result = subprocess.run(['git', 'log', '-30', '--format=%H%x1f%cI%x1f%s', '-z', 'HEAD', '--'],
                            cwd=ROOT, capture_output=True, timeout=3, check=True)
    if len(result.stdout) > 512 * 1024:
        raise ValueError('Commit response too large')
    commits = []
    for raw in result.stdout.decode('utf-8').split('\0'):
        if not raw:
            continue
        sha, at, subject = raw.split('\x1f')
        if not re.fullmatch(r'[a-f0-9]{40}', sha):
            raise ValueError('Invalid commit identity')
        commits.append({'sha': sha, 'timestamp': activity.timestamp(at), 'subject': activity.text(subject, 4096, False)})
    return list(reversed(commits))


def json_bytes(value):
    return json.dumps(value, ensure_ascii=False).encode()


def approval_store(path):
    return probe.Store() if path == '/approval-probe' else approvals.Store()


# GET handlers for the fixed paths below. Each returns the arguments of Handler.reply: (status, body[, content type]).
def get_approvals(path):
    try:
        return 200, approval_store(path).list()
    except (OSError, ValueError, sqlite3.Error):
        return 503, {'error': 'Approvals unavailable'}


def get_members(path):
    return 200, member_state.members.snapshot()


def get_activity(path):
    try:
        return 200, json_bytes(activity.read_events() if path == '/activity-events' else read_activity_commits())
    except (OSError, ValueError, UnicodeDecodeError, subprocess.SubprocessError):
        return 503, {'error': 'Activity row unavailable'}


def get_work_progress(path):
    try:
        return 200, json_bytes(read_work_progress())
    except (OSError, ValueError, UnicodeDecodeError):
        return 503, {'error': 'Progress record unavailable'}


def get_continuity(path):
    # OPS-139: the owners' own one-shot marks plus the server clock, so Studio can age them without trusting its own clock
    try:
        now = datetime.datetime.now(datetime.timezone.utc).isoformat(timespec='milliseconds').replace('+00:00', 'Z')
        return 200, json_bytes({'serverNow': now, **continuity.read()})
    except (OSError, ValueError, UnicodeDecodeError):
        return 503, {'error': 'Continuity unavailable'}


def get_comm(path):
    # OPS-156: communication records and the operation log; read through the server only.
    try:
        if path == '/comm-messages':
            store = studio_store.Store()
            return 200, json_bytes(store.messages() | {'cutover': store.cutover_point()})
        return 200, json_bytes(approvals.Store().operations())
    except (OSError, sqlite3.Error):
        return 503, {'error': 'Studio records unavailable'}


def get_server_status(path):
    return 200, runtime_status()


def v3_modules():
    """(registry_v3_write, studio_adapter), imported only when the V3 mode is used."""
    if str(APP / 'v3') not in sys.path:
        sys.path.insert(0, str(APP / 'v3'))
    import registry_v3_write
    import studio_adapter
    return registry_v3_write, studio_adapter


def v3_open(db):
    """A read-only connection (mode=ro through the escaped absolute file URI): it never creates or writes the DB."""
    return sqlite3.connect(Path(db).resolve().as_uri() + '?mode=ro', uri=True, isolation_level=None, timeout=5.0)


def v3_mode(db, saves):
    """The V3 mode settings for an existing V3 DB and an existing saves directory, or ValueError. Checks: the file and
    the directory exist; the DB opens read-only; its tables are exactly the V3 schema's; schema_version matches;
    quick_check is ok; and an export can be read."""
    db, saves = Path(db), Path(saves)
    if not db.is_file():
        raise ValueError(f'--v3-db {db}: no such file (it is never created)')
    if not saves.is_dir():
        raise ValueError(f'--v3-saves {saves}: no such directory (it is never created)')
    w3, sa = v3_modules()
    tables = lambda c: {r[0] for r in c.execute("SELECT name FROM sqlite_master WHERE type = 'table' AND name NOT LIKE 'sqlite_%'")}
    expected = sqlite3.connect(':memory:')
    try:
        expected.executescript(w3.r3.SCHEMA + w3.WRITE_SCHEMA)
        want = tables(expected)
    finally:
        expected.close()
    try:
        conn = v3_open(db)
    except sqlite3.Error as error:
        raise ValueError(f'--v3-db {db}: cannot be opened read-only: {error}') from None
    try:
        have = tables(conn)
        if have != want:
            raise ValueError(f'--v3-db {db}: not a V3 DB (tables differ: {", ".join(sorted(have ^ want))})')
        if conn.execute('SELECT schema_version FROM db_meta').fetchone()[0] != w3.SCHEMA_VERSION:
            raise ValueError(f'--v3-db {db}: schema version is not {w3.SCHEMA_VERSION}')
        if conn.execute('PRAGMA quick_check').fetchone()[0] != 'ok':
            raise ValueError(f'--v3-db {db}: quick_check failed')
        sa.export_doc(conn)
    except sqlite3.DatabaseError as error:
        raise ValueError(f'--v3-db {db}: not a V3 DB: {error}') from None
    finally:
        conn.close()
    return {'db': db.resolve(), 'saves': saves.resolve()}


def v3_page(html, conn):
    """The page with only its Registry seed replaced by a fresh export of the DB (the other blocks stay as built)."""
    _, sa = v3_modules()
    block = '<script id="seed" type="application/json">' + json.dumps(sa.export_doc(conn), ensure_ascii=False).replace('<', '\\u003c') + '</script>'
    html, n = re.subn(r'<script id="seed" type="application/json">.*?</script>', lambda m: block, html, count=1, flags=re.S)
    if n != 1:
        raise ValueError('seed block not found in the page')
    return html


class NotV3Save(ValueError):
    """The posted JSON is not a well-formed V3 export save (answered 400; parent problems stay ValueError, 409)."""


def v3_store(data, parent, saves):
    """Store a V3 save in saves (inbox.append_save). NotV3Save for anything that is not a well-formed V3 export save;
    ValueError from inbox for an unknown or other-kind parent."""
    if not (isinstance(data, dict) and data.get('schemaVersion') == 1 and isinstance(data.get('tasks'), list)
            and isinstance(data.get('edges'), list) and isinstance(data.get('baseline'), dict)):
        raise NotV3Save('Registry Studio形式のJSONではありません。')
    try:
        kind, _ = inbox.base_of(data)
    except inbox.InvalidBase as error:
        raise NotV3Save(f'V3の編集版として保存できません：{error}') from None
    if kind != inbox.V3:
        raise NotV3Save('V3モードでは、V3の編集版だけを保存できます（旧形式は保存しません）。')
    return inbox.append_save(data, parent, saves)


def sync_args():
    """sync.py's arguments: none in the legacy mode (as before); --v3-db in V3 mode, so documents and the pending queue
    are built without the legacy structural validation and the structure comes from the DB (OPS-167 B4)."""
    return ['--v3-db', str(V3['db'])] if V3 is not None else []


def get_workspace(path):
    # the edit version Studio resumes (OPS-082); null when nothing is saved. V3 mode: only V3 saves (OPS-181)
    if V3 is not None:
        return 200, json_bytes(inbox.latest(V3['saves'], inbox.V3))
    return 200, json_bytes(inbox.latest(INBOX))


def get_page(path):
    if V3 is not None:  # OPS-181: the seed and /registry.json come from the DB, read-only
        _, sa = v3_modules()
        conn = v3_open(V3['db'])
        try:
            if path == '/registry.json':
                return 200, json_bytes(sa.export_doc(conn)), 'application/json; charset=utf-8'
            return 200, v3_page((OUTPUT / 'index.html').read_text(encoding='utf-8'), conn).encode(), 'text/html; charset=utf-8'
        finally:
            conn.close()
    if path == '/registry.json':
        return 200, (OUTPUT / 'registry.json').read_bytes(), 'application/json; charset=utf-8'
    return 200, (OUTPUT / 'index.html').read_bytes(), 'text/html; charset=utf-8'


# Exact paths only: no query strings, prefixes or files chosen by the client.
GET_ROUTES = {
    '/members': get_members,
    '/commit-approvals': get_approvals, '/approval-probe': get_approvals,
    '/activity-events': get_activity, '/activity-commits': get_activity,
    '/work-progress': get_work_progress, '/server-status': get_server_status, '/workspace': get_workspace,
    '/continuity': get_continuity,
    '/comm-messages': get_comm, '/studio-operations': get_comm,
    '/': get_page, '/index.html': get_page, '/registry.json': get_page,
}
MEMBER_OPERATIONS = {
    'members-attendance': ('attend', 'owner'),
    'members-departure': ('leave', 'owner'),
    'members-clear': ('clear', None),
    'members-planned-add': ('add_planned', 'owner'),
    'members-planned-remove': ('remove_planned', 'owner'),
    'members-planned-clear': ('clear_planned', None),
    'members-planned-replace': ('replace_planned', 'plannedMembers'),
}

# POST path -> the X-Registry-Studio value it requires
POST_ACTIONS = {'/task-status': 'task-status', '/members/departure': 'members-departure', '/members/attendance': 'members-attendance', '/letter-turns': 'letter-turns', '/sync': 'sync', '/save': 'save', '/commit-approvals': 'commit-approvals', '/approval-probe': 'approval-probe',
                '/team-notice': 'team-notice', '/activity-wake': 'activity-wake', '/approvals-cli': 'approvals-cli', '/comm-ping': 'comm-ping', '/comm-ack': 'comm-ack',
                '/comm-cutover': 'comm-cutover', '/letters-send': 'letters-send', '/letters-event': 'letters-event',
                '/letters-revise': 'letters-revise', '/letters-senders': 'letters-senders'}
POST_ACTIONS.update({
    '/members/clear': 'members-clear',
    '/members/planned/add': 'members-planned-add',
    '/members/planned/remove': 'members-planned-remove',
    '/members/planned/clear': 'members-planned-clear',
    '/members/planned/replace': 'members-planned-replace',
})
LETTER_ACTIONS = ('letters-send', 'letters-event', 'letters-revise', 'letters-senders')


def get_letters(parsed):
    """H-20261019-25: GET /letters?task=&member=&state=&limit=, /letters/<id>, /letters/<id>/thread, /letters-inbox?owner=, /letters-senders.
    Reading records nothing (it is not a receipt). Names in the query are self-reports, not authentication."""
    query = urllib.parse.parse_qs(parsed.query, keep_blank_values=False)
    if any(len(v) != 1 for v in query.values()):
        return 400, {'error': 'Each query parameter at most once'}
    q = {k: v[0] for k, v in query.items()}
    store = studio_store.Store()
    try:
        if parsed.path == '/letters-inbox':
            if 'owner' not in q or set(q) - {'owner', 'watch'} or q.get('watch', '1') != '1':
                raise ValueError('Expected owner')
            return 200, json_bytes(store.inbox(q['owner']))
        if parsed.path == '/letters-senders':
            if q:
                raise ValueError('No parameters')
            return 200, json_bytes(store.senders())
        if parsed.path == '/letters':
            if not set(q) <= {'task', 'member', 'state', 'limit', 'brief', 'cursor', 'sender', 'recipient'}:
                raise ValueError('Unexpected parameter')
            if 'brief' in q:
                if q['brief'] != '1':
                    raise ValueError('brief must be 1')
                return 200, json_bytes(store.letters_brief(q.get('task'), q.get('member'), q.get('state'), q.get('limit', 50), q.get('cursor'), q.get('sender'), q.get('recipient')))
            if {'cursor', 'sender', 'recipient'} & set(q):
                raise ValueError('cursor, sender and recipient are for brief=1')
            return 200, json_bytes(store.letters(q.get('task'), q.get('member'), q.get('state'), q.get('limit', 200)))
        name = urllib.parse.unquote(parsed.path[len('/letters/'):])
        if name.endswith('/thread'):  # OPS-192 D1: the thread of the letter, read only
            if q:
                raise ValueError('No parameters')
            return 200, json_bytes(store.thread(name[:-len('/thread')]))
        return 200, json_bytes(store.letter(name))
    except LookupError as error:
        return 404, {'error': str(error)}
    except (ValueError, TypeError) as error:
        return 400, {'error': str(error) or 'Invalid request'}
    except (OSError, sqlite3.Error):
        return 503, {'error': 'Studio records unavailable'}


def registry_tasks():
    """The tasks of the Registry the page is built from: the V3 export in V3 mode, else the generated registry.json."""
    if V3 is not None:
        _, sa = v3_modules()
        conn = v3_open(V3['db'])
        try:
            return sa.export_doc(conn)['tasks']
        finally:
            conn.close()
    return json.loads((OUTPUT / 'registry.json').read_text(encoding='utf-8'))['tasks']


def task_documents(detail):
    """OPS-192: the canonical documents a Registry detail names explicitly: every backticked `….md` path (an anchor is
    dropped), or the whole detail when it is one bare .md path. Prose is never searched for document names."""
    detail = (detail or '').strip()
    named = re.findall(r'`([^`\s]+\.md)(?:#[^`]*)?`', detail)
    if not named and re.fullmatch(r'[^\s`]+\.md', detail):
        named = [detail]
    out = []
    root = activity.ROOT.resolve()
    for raw in dict.fromkeys(named):
        path = (root / raw).resolve()
        if Path(raw).is_absolute() or not path.is_relative_to(root):
            out.append({'path': raw, 'status': 'outside'})
        elif not path.is_file():
            out.append({'path': path.relative_to(root).as_posix(), 'status': 'missing'})
        else:
            out.append({'path': path.relative_to(root).as_posix(), 'status': 'ok', 'text': path.read_text(encoding='utf-8')})
    return out


def get_task_context(parsed):
    """OPS-192: GET /task-context?task=ID — the task as the Registry has it, its canonical documents, and the letters
    explicitly associated with it (studio_store.task_letters). Read only."""
    query = urllib.parse.parse_qs(parsed.query, keep_blank_values=True)
    if set(query) != {'task'} or len(query['task']) != 1 or not re.fullmatch(r'[A-Z][A-Z0-9]*-[0-9]+', query['task'][0]):
        return 400, {'error': 'Expected task=<TASK-ID>'}
    task = query['task'][0]
    try:
        row = next((t for t in registry_tasks() if t.get('id') == task), None)
    except (OSError, ValueError, KeyError, sqlite3.Error):
        return 503, {'error': 'Registry unavailable'}
    if row is None:
        return 404, {'error': f'unknown task {task}'}
    documents = task_documents(row.get('detail'))
    try:
        # a missing file is still an explicit document of the task: letters that reference it stay associated
        letters = studio_store.Store().task_letters(task, [d['path'] for d in documents if d['status'] in ('ok', 'missing')])['letters']
    except (OSError, sqlite3.Error):
        return 503, {'error': 'Studio records unavailable'}
    keep = ('id', 'state', 'owner', 'item', 'condition', 'detail')
    return 200, json_bytes({'task': {k: row.get(k) for k in keep}, 'documents': documents, 'letters': letters})


LETTER_FIELDS = {
    'letters-send': ({'operationId', 'sender', 'recipient', 'taskId', 'body'}, {'recordedBy', 'refDoc', 'refSection', 'follows'}),
    'letters-event': ({'operationId', 'letterId', 'event', 'actor'}, {'recordedBy', 'claimedAt', 'note', 'body', 'refDoc', 'refSection', 'revision'}),
    'letters-revise': ({'operationId', 'letterId', 'part', 'actor', 'body', 'reason'}, {'recordedBy', 'refDoc', 'refSection'}),
    'letters-senders': ({'names', 'recordedBy'}, set()),
}


def letter_action(store, action, body):
    required, optional = LETTER_FIELDS[action]
    if not required <= set(body) <= required | optional:
        raise ValueError('Expected ' + ', '.join(sorted(required)))
    g = body.get
    if action == 'letters-send':
        result = store.send(g('operationId'), g('sender'), g('recipient'), g('taskId'), g('body'), g('recordedBy'), g('refDoc'), g('refSection'), g('follows'))
        if not result.get('replayed') and g('recordedBy', g('sender')) == g('sender'):
            notifications.communication_activity.send(owner=g('sender'), label='送信')
        return result
    if action == 'letters-event':
        result = store.event(g('operationId'), g('letterId'), g('event'), g('actor'), g('recordedBy'), g('claimedAt'), g('note', ''), g('body'), g('refDoc'), g('refSection'), g('revision'))
        if g('event') in ('received', 'revision-received') and result.get('effective') and not result.get('replayed'):
            notifications.letter_received.send(owner=g('actor'), letter_id=g('letterId'), revision=g('revision'))
        elif result.get('effective') and not result.get('replayed') and g('recordedBy', g('actor')) == g('actor'):
            notifications.communication_activity.send(owner=g('actor'), label='連絡更新')
        return result
    if action == 'letters-revise':
        return store.revise(g('operationId'), g('letterId'), g('part'), g('actor'), g('body'), g('reason'), g('recordedBy'), g('refDoc'), g('refSection'))
    return store.set_senders(g('names'), g('recordedBy'))


class Handler(BaseHTTPRequestHandler):
    def reply(self, status, body, content_type='application/json; charset=utf-8'):
        if isinstance(body, dict):
            body = json.dumps(body, ensure_ascii=False).encode()
        self.send_response(status)
        self.send_header('Content-Type', content_type)
        self.send_header('Content-Length', str(len(body)))
        self.send_header('Cache-Control', 'no-store')
        self.end_headers()
        self.wfile.write(body)

    def local_request(self):
        host = f'127.0.0.1:{self.server.server_port}'
        return self.headers.get('Host') == host

    def studio_request(self, action):
        """Same host and origin, and the X-Registry-Studio value of this path."""
        return (self.local_request() and self.headers.get('Origin') == f'http://127.0.0.1:{self.server.server_port}'
                and self.headers.get('X-Registry-Studio') == action)

    def stream_members(self):
        self.send_response(200)
        self.send_header('Content-Type', 'text/event-stream; charset=utf-8')
        self.send_header('Cache-Control', 'no-cache')
        self.end_headers()
        self.close_connection = True
        revision = None
        try:
            while True:
                model = member_state.members.wait(revision)
                if model['revision'] != revision:
                    payload = json.dumps(model, ensure_ascii=False)
                    self.wfile.write(f'data: {payload}\n\n'.encode('utf-8'))
                    revision = model['revision']
                else:
                    self.wfile.write(b': keepalive\n\n')
                self.wfile.flush()
        except (BrokenPipeError, ConnectionResetError, OSError):
            pass

    def stream_work(self):
        return self.stream_state(work_view())

    def stream_state(self, model, timeout=15):
        self.send_response(200)
        self.send_header('Content-Type', 'text/event-stream; charset=utf-8')
        self.send_header('Cache-Control', 'no-cache')
        self.end_headers()
        self.close_connection = True
        revision = None
        try:
            while True:
                snapshot = model.wait(revision, timeout=timeout)
                if snapshot['revision'] != revision:
                    self.wfile.write(('data: ' + json.dumps(snapshot, ensure_ascii=False) + '\n\n').encode())
                    revision = snapshot['revision']
                else:
                    self.wfile.write(b': keepalive\n\n')
                self.wfile.flush()
        except (BrokenPipeError, ConnectionResetError, OSError):
            pass

    def stream_changes(self, changes):
        self.send_response(200)
        self.send_header('Content-Type', 'text/event-stream; charset=utf-8')
        self.send_header('Cache-Control', 'no-cache')
        self.end_headers()
        self.close_connection = True
        revision = None
        try:
            while True:
                current = changes.wait(revision)
                data = f'data: {current}\n\n' if current != revision else ': keepalive\n\n'
                revision = current
                self.wfile.write(data.encode())
                self.wfile.flush()
        except (BrokenPipeError, ConnectionResetError, OSError):
            pass

    def stream_timeline(self):
        import notification_log
        pending = queue.Queue(maxsize=1024)
        overflow = threading.Event()
        def receive(cursor, text):
            try:
                pending.put_nowait({'reset': False, 'entries': [text], 'cursor': cursor})
            except queue.Full:
                overflow.set()
        log = notification_log.start(OUTPUT / 'notifications.log')
        snapshot = log.follow(receive, self.headers.get('Last-Event-ID', ''))
        self.close_connection = True
        try:
            self.send_response(200)
            self.send_header('Content-Type', 'text/event-stream; charset=utf-8')
            self.send_header('Cache-Control', 'no-cache')
            self.end_headers()
            def send(value):
                frame = 'id: ' + value['cursor'] + '\ndata: ' + json.dumps(value, ensure_ascii=False) + '\n\n'
                self.wfile.write(frame.encode('utf-8'))
                self.wfile.flush()
            send(snapshot)
            while not overflow.is_set():
                try:
                    send(pending.get(timeout=1))
                except queue.Empty:
                    self.wfile.write(b': keepalive\n\n')
                    self.wfile.flush()
            # Closing prompts EventSource to resume from the last delivered cursor.
        except OSError:
            pass
        finally:
            log.unfollow(receive)

    def stream_notifications(self):
        pending = queue.Queue(maxsize=1024)
        overflow = threading.Event()

        def receive(text):
            try:
                pending.put_nowait(text)
            except queue.Full:
                overflow.set()

        events.connect(receive)
        try:
            import record_notifications
            record_notifications.start(approvals.DATABASE, activity.EVENTS, V3['db'] if V3 else None)

        except Exception:
            events.disconnect(receive)
            return self.reply(503, {'error': 'Notification sources unavailable'})
        self.close_connection = True
        try:
            self.send_response(200)
            self.send_header('Content-Type', 'text/event-stream; charset=utf-8')
            self.send_header('Cache-Control', 'no-cache')
            self.end_headers()
            self.wfile.write(b': connected\n\n')
            self.wfile.flush()
            while True:
                if overflow.is_set():
                    self.wfile.write(b'event: overflow\ndata: notification consumer is too slow; reconnect\n\n')
                    self.wfile.flush()
                    return
                try:
                    text = pending.get(timeout=1)
                    frame = ''.join('data: ' + line + '\n' for line in text.split('\n')) + '\n'
                except queue.Empty:
                    frame = ': keepalive\n\n'
                self.wfile.write(frame.encode('utf-8'))
                self.wfile.flush()
        except OSError:
            pass
        finally:
            events.disconnect(receive)

    def do_GET(self):
        if not self.local_request():
            return self.reply(403, {'error': 'Local host required'})
        parsed = urllib.parse.urlsplit(self.path)
        if parsed.path in ('/document-state', '/document-state/events'):
            query = urllib.parse.parse_qs(parsed.query)
            if set(query) != {'path'} or len(query['path']) != 1:
                return self.reply(400, {'error': 'One document path required'})
            try:
                binding = DocumentStateBinding(ROOT, query['path'][0], render_document_markdown)
            except ValueError as error:
                return self.reply(400, {'error': str(error)})
            try:
                if parsed.path.endswith('/events'):
                    return self.stream_state(binding.model, timeout=1)
                return self.reply(200, binding.model.snapshot())
            finally:
                binding.close()
        if self.path == '/notifications/timeline':
            return self.stream_timeline()
        if self.path == '/notifications/events':
            return self.stream_notifications()
        if self.path == '/task-state/events':
            return self.stream_state(task_view())
        if self.path == '/task-state':
            return self.reply(200, task_view().snapshot())
        if self.path == '/work-state/events':
            return self.stream_work()
        if self.path == '/work-state':
            return self.reply(200, work_view().snapshot())
        if self.path == '/activity-events/changes':
            return self.stream_changes(work_notifications.observe_activity(activity.EVENTS))
        if self.path == '/commit-approvals/changes':
            return self.stream_changes(work_notifications.approval_changes)
        if self.path == '/members/events':
            return self.stream_members()
        if parsed.path == '/letter-turns':
            try:
                q=urllib.parse.parse_qs(parsed.query)
                store=task_rounds.TaskRoundStore()
                if 'letter' in q:return self.reply(200,json_bytes(store.rounds_for_letter(q['letter'][0])))
                wait=float(q.get('wait',['0'])[0])
                if not 0<=wait<=30:raise ValueError('wait must be 0..30')
                if len(q.get('owner',[]))>1 or len(q.get('inboxAfter',[]))>1:raise ValueError('owner and inboxAfter may appear only once')
                owner=q.get('owner',[None])[0]
                inbox_after=q.get('inboxAfter',[None])[0]
                if inbox_after is not None and owner is None:raise ValueError('inboxAfter requires owner')
                if inbox_after is not None and not re.fullmatch(r'[0-9a-f]{64}',inbox_after):raise ValueError('Invalid inboxAfter context')
                inbox_baseline=(inbox_after if inbox_after is not None else store.inbox_notice_context(owner)) if owner is not None else None
                if len(q.get('approvalChanges',[]))>1 or len(q.get('approvalAfter',[]))>1:
                    raise ValueError('approvalChanges and approvalAfter may appear only once')
                approval_option=q.get('approvalChanges',[None])[0]
                if approval_option not in (None,'1'):raise ValueError('approvalChanges must be 1')
                approval_watch=approval_option=='1'
                approval_after=q.get('approvalAfter',[None])[0]
                if approval_after is not None:
                    if not approval_watch:raise ValueError('approvalAfter requires approvalChanges=1')
                    if not re.fullmatch(r'[0-9]{1,19}',approval_after) or int(approval_after)>9223372036854775807:
                        raise ValueError('Invalid approvalAfter cursor')
                approval_baseline=(int(approval_after) if approval_after is not None else store.approval_change_cursor()) if approval_watch else None
                event = dict(owner=owner, round_id=q['round'][0], connection_id=secrets.token_hex(16))
                watching = 'wait' in q
                if watching:
                    notifications.waiting_started.send(**event)
                try:
                    until=time.monotonic()+wait
                    while True:
                        out=store.show_round(q['round'][0])
                        inbox_context=store.inbox_notice_context(owner) if owner is not None else None
                        inbox_changed=owner is not None and inbox_context!=inbox_baseline
                        team_notifications=store.notifications(owner) if owner is not None else []
                        approval_cursor=store.approval_change_cursor() if approval_watch else None
                        approval_changed=approval_watch and approval_cursor!=approval_baseline
                        if out['context']!=q.get('after',[''])[0] or inbox_changed or team_notifications or approval_changed or time.monotonic()>=until:break
                        time.sleep(.1)
                    if owner is not None:
                        out=out|{'ownerInboxOwner':owner,'ownerInboxContext':inbox_context,'ownerInboxChanged':inbox_changed,'notifications':team_notifications,'notificationPending':bool(team_notifications)}
                    if approval_watch or team_notifications:
                        reasons=[]
                        if out['context']!=q.get('after',[''])[0]:reasons.append('round-context')
                        if inbox_changed:reasons.append('inbox')
                        if approval_changed:reasons.append('approval-change')
                        if team_notifications:reasons.append('team-notice')
                        out=out|{'wakeReasons':reasons or ['timeout']}
                        if approval_watch:out=out|{'approvalCursor':approval_cursor,'approvalChanged':approval_changed}
                    return self.reply(200,out)
                finally:
                    if watching:
                        notifications.waiting_ended.send(**event)
            except (ValueError,KeyError,LookupError) as e:return self.reply(400,{'error':str(e)})
            except (OSError,sqlite3.Error):return self.reply(503,{'error':'Watch records unavailable'})
        if parsed.path in ('/letters', '/letters-inbox', '/letters-senders') or parsed.path.startswith('/letters/'):
            result = get_letters(parsed)
            q = urllib.parse.parse_qs(parsed.query)
            if parsed.path == '/letters-inbox' and q.get('watch') == ['1'] and result[0] == 200:
                notifications.communication_activity.send(owner=q.get('owner', [None])[0], label='待機確認')
            return self.reply(*result)
        if parsed.path == '/task-context':
            return self.reply(*get_task_context(parsed))
        route = GET_ROUTES.get(self.path)
        if route is None:
            return self.reply(404, {'error': 'Not found'})
        return self.reply(*route(self.path))

    def do_POST(self):
        action = POST_ACTIONS.get(self.path)
        if action is None:
            return self.reply(404, {'error': 'Not found'})
        if not self.studio_request(action):
            return self.reply(403, {'error': 'Same-origin Studio request required'})
        if action == 'task-status':
            if not V3:
                return self.reply(409, {'error': 'Registry V3 is required'})
            body = self.json_body(4096)
            if body is None:
                return
            try:
                import task_status_command
                status, result = task_status_command.change(V3['db'], ROOT,
                    Path.home() / 'Documents/RegistryStudioBackups' / ROOT.name, body)
                if status == 200:
                    work_notifications.registry_changes.changed()
                return self.reply(status, result)
            except (ValueError, TypeError, KeyError) as error:
                return self.reply(400, {'error': str(error)})
            except (OSError, sqlite3.Error) as error:
                return self.reply(503, {'error': str(error)})
        if action in MEMBER_OPERATIONS:
            body = self.json_body(4096)
            if body is None:
                return
            try:
                if not isinstance(body, dict):
                    raise ValueError('JSON object required')
                method, field = MEMBER_OPERATIONS[action]
                operation = getattr(member_state.members, method)
                return self.reply(200, operation(body.get(field)) if field else operation())
            except (ValueError, AttributeError) as error:
                return self.reply(400, {'error': str(error)})
        if action == 'letter-turns':
            body=self.json_body(128*1024)
            if body is None:return
            if body.get('action') in ('approve-skip','continuous-skip'):
                token=os.environ.get('ROUND_USER_APPROVAL_TOKEN')
                if not token or not secrets.compare_digest(self.headers.get('Authorization',''),'Bearer '+token):
                    return self.reply(403,{'error':'User approval channel required'})
            try:
                result = task_rounds.TaskRoundStore().act(body)
                if body.get('action') in ('speak', 'nop') and not result.get('replayed'):
                    notifications.communication_activity.send(owner=body.get('actor'), label='発言' if body['action'] == 'speak' else 'パス')
                return self.reply(200, result)
            except approvals.Conflict as e:return self.reply(409,{'error':str(e)})
            except (ValueError,KeyError,TypeError,LookupError) as e:return self.reply(400,{'error':str(e)})
        if action == 'sync':
            return self.sync()
        if action == 'save':
            return self.save()
        if action == 'team-notice':
            body = self.json_body(16*1024)
            if body is None:return
            try:
                if not isinstance(body, dict) or set(body) != {'operationId', 'kind', 'reason'}:
                    raise ValueError('Expected operationId, kind and reason')
                targets = [row['owner'] for row in member_state.members.snapshot()['members']]
                return self.reply(200, studio_store.Store().team_notice(body['operationId'], body['kind'], body['reason'], targets))
            except approvals.Conflict as error:return self.reply(409, {'error': str(error)})
            except ValueError as error:return self.reply(400, {'error': str(error)})
            except (OSError, sqlite3.Error):return self.reply(503, {'error': 'Team notice unavailable'})
        if action == 'activity-wake':
            return self.activity_wake()
        if action in ('approvals-cli', 'comm-ping', 'comm-ack', 'comm-cutover') + LETTER_ACTIONS:
            return self.studio_records(action)
        return self.commit_approvals()

    def json_body(self, limit):
        """The JSON object of a POST, or None after replying with the error."""
        if (self.headers.get('Content-Type', '').split(';')[0].strip().lower() != 'application/json'
                or self.headers.get('Transfer-Encoding') is not None):
            self.reply(400, {'error': 'JSON body required'})
            return None
        lengths = self.headers.get_all('Content-Length', [])
        if len(lengths) != 1 or not re.fullmatch(r'[0-9]{1,7}', lengths[0]) or not 0 < int(lengths[0]) <= limit:
            self.reply(411, {'error': 'Content-Length required within the size limit'})
            return None
        self.connection.settimeout(5)
        try:
            raw = self.rfile.read(int(lengths[0]))
            body = json.loads(raw.decode('utf-8'))
            if len(raw) != int(lengths[0]) or not isinstance(body, dict):
                raise ValueError('Invalid body')
            return body
        except (ValueError, UnicodeDecodeError, RecursionError, OSError):
            self.reply(400, {'error': 'Invalid JSON body'})
            return None

    def studio_records(self, action):
        """OPS-156: the approvals command line, PING / ACK and the PING cutover. Only this server opens the database.
        The same-origin headers are a guard, not authentication: a record is a local self-report of the member named."""
        body = self.json_body(128 * 1024)
        if body is None:
            return None
        try:
            if action == 'approvals-cli':
                return self.reply(200, approvals.run_cli_command(approvals.Store(), body))
            store = studio_store.Store()
            if action in LETTER_ACTIONS:
                return self.reply(200, letter_action(store, action, body))
            if action == 'comm-ping':
                if set(body) != {'operationId', 'target', 'taskId'}:
                    raise ValueError('Expected operationId, target, taskId')
                owners = {r['owner'] for r in activity.read_events()} - {activity.WAKE_SENDER}
                if body['target'] not in owners:
                    raise LookupError('Unknown member')
                return self.reply(200, store.ping(body['operationId'], body['target'], body['taskId']))
            if action == 'comm-ack':
                if not {'messageId', 'owner'} <= set(body) <= {'messageId', 'owner', 'recordedBy', 'claimedAt'}:
                    raise ValueError('Expected messageId and owner')
                return self.reply(200, store.ack(body['messageId'], body['owner'], body.get('recordedBy'), body.get('claimedAt')))
            if set(body) != {'afterEventId'}:
                raise ValueError('Expected afterEventId')
            result = store.cutover(body['afterEventId'])
            # The point is committed in the database first; the marker that makes activity.py refuse PING lines follows.
            # If writing the marker fails, the point stays recorded and the same request is safe to send again: a resend
            # of the same point is a replay that writes the marker. The reply says so instead of a plain failure.
            try:
                marker = activity.ping_cutover_file()
                marker.parent.mkdir(parents=True, exist_ok=True)
                temp = marker.with_suffix('.tmp')
                temp.write_text(json.dumps({'afterEventId': result['afterEventId'], 'recordedAt': result['recordedAt']}) + '\n', encoding='utf-8')
                temp.replace(marker)
            except OSError:
                return self.reply(503, {'error': 'The cutover is recorded in the database but the activity marker was not written; '
                                                 'send the same request again', 'cutover': result, 'marker': False})
            return self.reply(200, result | {'marker': True})
        except approvals.Conflict as error:
            return self.reply(409, {'error': str(error)})
        except LookupError as error:
            return self.reply(409, {'error': str(error)})
        except (ValueError, TypeError) as error:
            return self.reply(400, {'error': str(error) or 'Invalid request'})
        except subprocess.SubprocessError:
            return self.reply(500, {'error': 'Repository check failed'})
        except (OSError, sqlite3.Error):
            return self.reply(503, {'error': 'Studio records unavailable'})

    def sync(self):
        """Run only the fixed sync.py command, one at a time."""
        if not SYNC_LOCK.acquire(blocking=False):
            return self.reply(409, {'error': '更新中です。完了を待ってください。'})
        try:
            result = subprocess.run([sys.executable, str(APP / 'sync.py'), *sync_args()], cwd=ROOT, **({'env': SYNC_ENV} if SYNC_ENV else {}),
                                    capture_output=True, text=True, timeout=300)
            output = result.stdout + result.stderr
            self.reply(200 if result.returncode == 0 else 500,
                       {'ok': result.returncode == 0, 'output': output})
        except subprocess.TimeoutExpired:
            self.reply(504, {'error': '更新がタイムアウトしました。ターミナルで状態を確認してください。'})
        except OSError as error:
            self.reply(500, {'error': str(error)})
        finally:
            SYNC_LOCK.release()

    def commit_approvals(self):
        if (self.headers.get('Content-Type', '').split(';')[0].strip().lower() != 'application/json'
                or self.headers.get('Transfer-Encoding') is not None):
            return self.reply(400, {'error': 'JSON body required'})
        lengths = self.headers.get_all('Content-Length', [])
        if len(lengths) != 1 or not re.fullmatch(r'[0-9]+', lengths[0]):
            return self.reply(411, {'error': 'Content-Length required'})
        if len(lengths[0]) > 6:
            return self.reply(413, {'error': 'Approval body too large'})
        length = int(lengths[0])
        if length <= 0 or length > 128 * 1024:
            return self.reply(413, {'error': 'Approval body too large'})
        self.connection.settimeout(5)
        try:
            raw = self.rfile.read(length)
            if len(raw) != length:
                raise ValueError('Incomplete body')
            body = json.loads(raw.decode('utf-8'))
            return self.reply(200, approval_store(self.path).mutate(body))
        except approvals.Conflict as error:
            return self.reply(409, {'error': str(error)})
        except (ValueError, UnicodeDecodeError, RecursionError):
            return self.reply(400, {'error': 'Invalid approval request'})
        except (OSError, sqlite3.Error):
            return self.reply(503, {'error': 'Approvals unavailable'})

    def activity_wake(self):
        """OPS-138: the user's 待機完了 request. The body names only the owner; activity.request_wake fixes everything else."""
        if (self.headers.get('Content-Type', '').split(';')[0].strip().lower() != 'application/json'
                or self.headers.get('Transfer-Encoding') is not None):
            return self.reply(400, {'error': 'JSON body required'})
        lengths = self.headers.get_all('Content-Length', [])
        if len(lengths) != 1 or not re.fullmatch(r'[0-9]{1,4}', lengths[0]) or not 0 < int(lengths[0]) <= 1024:
            return self.reply(411, {'error': 'Content-Length required'})
        self.connection.settimeout(5)
        try:
            raw = self.rfile.read(int(lengths[0]))
            body = json.loads(raw.decode('utf-8'))
            if len(raw) != int(lengths[0]) or not isinstance(body, dict) or set(body) != {'owner'} or not isinstance(body['owner'], str):
                raise ValueError('Invalid body')
            event, created = activity.request_wake(body['owner'])
            return self.reply(200, {'created': created, 'event': event})
        except LookupError:
            return self.reply(409, {'error': 'Unknown owner'})
        except (ValueError, UnicodeDecodeError, RecursionError):
            return self.reply(400, {'error': 'Invalid wake request'})
        except OSError:
            return self.reply(503, {'error': 'Activity unavailable'})

    def save(self):
        """Store one edited Studio JSON as a new save in INBOX (inbox.append_save); never overwrite, never reflect into the Registry."""
        try:
            length = int(self.headers.get('Content-Length', ''))
        except ValueError:
            return self.reply(411, {'error': 'Content-Length が必要です。'})
        if length <= 0 or length > MAX_SAVE_BYTES:
            return self.reply(413, {'error': f'保存できる大きさは {MAX_SAVE_BYTES} バイトまでです。'})
        raw = self.rfile.read(length)
        try:
            data = json.loads(raw.decode('utf-8'))
        except (UnicodeDecodeError, json.JSONDecodeError):
            return self.reply(400, {'error': 'JSONとして読めません。'})
        if V3 is not None:  # OPS-181: only V3 saves, into the explicit saves directory
            return self.save_v3(data)
        if not (isinstance(data, dict) and data.get('schemaVersion') == 1 and isinstance(data.get('source'), dict)
                and isinstance(data['source'].get('sha256'), str) and isinstance(data.get('tasks'), list)
                and isinstance(data.get('edges'), list) and isinstance(data.get('baseline'), dict)):
            return self.reply(400, {'error': 'Registry Studio形式のJSONではありません。'})
        claimed = data.pop('studioSave', None)  # the client names only its parent; the server assigns the rest
        parent = claimed.get('parent') if isinstance(claimed, dict) else None
        try:
            meta = inbox.append_save(data, parent, INBOX)
        except ValueError as error:
            return self.reply(409, {'error': str(error)})
        except OSError as error:
            return self.reply(500, {'error': '保存できませんでした：' + str(error)})
        folder = INBOX.relative_to(ROOT).as_posix() if INBOX.is_relative_to(ROOT) else str(INBOX)
        self.reply(200, {'ok': True, 'file': f"registry-edited-{meta['saveId']}.json", 'folder': folder, 'save': meta})

    def save_v3(self, data):
        claimed = data.pop('studioSave', None) if isinstance(data, dict) else None
        parent = claimed.get('parent') if isinstance(claimed, dict) else None
        saves = V3['saves']
        try:
            meta = v3_store(data, parent, saves)
        except NotV3Save as error:
            return self.reply(400, {'error': str(error)})
        except ValueError as error:
            return self.reply(409, {'error': str(error)})
        except OSError as error:
            return self.reply(500, {'error': '保存できませんでした：' + str(error)})
        folder = saves.relative_to(ROOT).as_posix() if saves.is_relative_to(ROOT) else str(saves)
        self.reply(200, {'ok': True, 'file': f"registry-edited-{meta['saveId']}.json", 'folder': folder, 'save': meta})


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--port', type=int, default=8088)
    parser.add_argument('--started-by', default='unknown', help='Self-reported launcher name (not authentication)')
    parser.add_argument('--thread-id', default='', help='Launcher chat ID for follow-up')
    parser.add_argument('--v3-db', help='V3 mode (with --v3-saves): an existing V3 DB, opened read-only for the page')
    parser.add_argument('--v3-saves', help='V3 mode (with --v3-db): an existing directory for V3 saves')
    parser.add_argument('--output', help='an existing directory for the generated page and data instead of Cache/RegistryStudio '
                                         '(sync.py writes there, its tools record included); for isolated runs')
    args = parser.parse_args()
    global V3, STARTUP_FINGERPRINTS, OUTPUT, WORK_PROGRESS, SYNC_ENV, SERVER_IDENTITY
    if args.output is not None:
        output = Path(args.output)
        if not output.is_dir():
            parser.error(f'--output {output}: no such directory (it is never created)')
        OUTPUT, WORK_PROGRESS = output.resolve(), output.resolve() / 'work-progress.json'
        SYNC_ENV = dict(os.environ, REGISTRY_STUDIO_APP=str(OUTPUT), REGISTRY_STUDIO_TOOLS=str(OUTPUT / 'local-tools.json'))
    if (args.v3_db is None) != (args.v3_saves is None):
        parser.error('--v3-db and --v3-saves go together')
    if args.v3_db is not None:
        try:
            V3 = v3_mode(args.v3_db, args.v3_saves)
        except ValueError as error:
            parser.error(str(error))
        STARTUP_FINGERPRINTS = runtime_fingerprints()
    # OPS-189: take the port first. A port in use (for example a running server) fails here, before sync.py could
    # rewrite the output that server is serving. The socket only listens until serve_forever, so a failed generation
    # closes it again and nothing incomplete is ever answered.
    try:
        server = ThreadingHTTPServer(('127.0.0.1', args.port), Handler)
    except OSError as error:
        parser.exit(1, f'Port {args.port} cannot be used ({error}); nothing was generated\n')
    try:
        subprocess.run([sys.executable, str(APP / 'sync.py'), *sync_args()], cwd=ROOT, check=True, **({'env': SYNC_ENV} if SYNC_ENV else {}))
    except BaseException:
        server.server_close()
        raise
    import notification_log
    import record_notifications
    notification_log.start(OUTPUT / 'notifications.log')
    record_notifications.start(approvals.DATABASE, activity.EVENTS, V3['db'] if V3 else None)
    SERVER_IDENTITY = {'startedBy': args.started_by, 'threadId': args.thread_id,
                       'pid': os.getpid(), 'port': server.server_port,
                       'startedAt': datetime.datetime.now(datetime.timezone.utc).isoformat(),
                       'root': str(ROOT), 'db': str(V3['db']) if V3 else None,
                       'identityKind': 'self-reported'}
    events.send('server_started: ' + json.dumps(SERVER_IDENTITY, ensure_ascii=False))
    print(f'Registry Studio: http://127.0.0.1:{server.server_port}/  (Ctrl+C to stop)' + (f"  V3 mode: DB {V3['db']} (read-only), saves {V3['saves']}" if V3 else ''), flush=True)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        server.server_close()


if __name__ == '__main__':
    main()
