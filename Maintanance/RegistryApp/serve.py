#!/usr/bin/env python3
"""Serve Registry Studio locally; POST /sync runs only the fixed sync.py command, POST /save stores the edited JSON in Inbox/.

V3 mode (OPS-181), off by default: --v3-db PATH --v3-saves DIR, always together. Both must already exist (nothing is
created or migrated) and the DB must be a V3 DB. Then GET / is the page sync.py built with only its Registry seed
replaced by a fresh read-only DB export, GET /registry.json is that export, GET /workspace resumes only V3 saves from
DIR, and POST /save stores only V3 saves there. POST /sync still runs sync.py (documents and the pending queue); it
never writes the DB. There is no apply route: the DB is written only through v3/registry_v3_cli.py. Without the flags
nothing of V3 is imported or opened.

--output DIR (OPS-167 K9), for isolated runs: an existing directory used instead of Cache/RegistryStudio; sync.py (at
start and on POST /sync) writes its page, registry.json and tools record there, never into Cache or local-tools.json."""
import argparse
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
import approvals
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


def runtime_fingerprints():
    # Only modules retained by this process. sync.py and HTML are read afresh.
    result = {}
    for name in ('serve.py', 'inbox.py', 'activity.py', 'approvals.py', 'probe.py', 'continuity.py') + (V3_MODULES if V3 else ()):
        try:
            result[name] = hashlib.sha256((APP / name).read_bytes()).hexdigest()
        except OSError:
            result[name] = None
    return result


STARTUP_FINGERPRINTS = runtime_fingerprints()


def runtime_status():
    current = runtime_fingerprints()
    changed = [name for name, digest in STARTUP_FINGERPRINTS.items()
               if current[name] is None or current[name] != digest]
    return {'restartRecommended': bool(changed), 'changedFiles': changed}



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
    '/commit-approvals': get_approvals, '/approval-probe': get_approvals,
    '/activity-events': get_activity, '/activity-commits': get_activity,
    '/work-progress': get_work_progress, '/server-status': get_server_status, '/workspace': get_workspace,
    '/continuity': get_continuity,
    '/comm-messages': get_comm, '/studio-operations': get_comm,
    '/': get_page, '/index.html': get_page, '/registry.json': get_page,
}
# POST path -> the X-Registry-Studio value it requires
POST_ACTIONS = {'/sync': 'sync', '/save': 'save', '/commit-approvals': 'commit-approvals', '/approval-probe': 'approval-probe',
                '/activity-wake': 'activity-wake', '/approvals-cli': 'approvals-cli', '/comm-ping': 'comm-ping', '/comm-ack': 'comm-ack',
                '/comm-cutover': 'comm-cutover', '/letters-send': 'letters-send', '/letters-event': 'letters-event',
                '/letters-revise': 'letters-revise', '/letters-senders': 'letters-senders'}
LETTER_ACTIONS = ('letters-send', 'letters-event', 'letters-revise', 'letters-senders')


def get_letters(parsed):
    """H-20261019-25: GET /letters?task=&member=&state=&limit=, /letters/<id>, /letters-inbox?owner=, /letters-senders.
    Reading records nothing (it is not a receipt). Names in the query are self-reports, not authentication."""
    query = urllib.parse.parse_qs(parsed.query, keep_blank_values=False)
    if any(len(v) != 1 for v in query.values()):
        return 400, {'error': 'Each query parameter at most once'}
    q = {k: v[0] for k, v in query.items()}
    store = studio_store.Store()
    try:
        if parsed.path == '/letters-inbox':
            if set(q) != {'owner'}:
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
        return 200, json_bytes(store.letter(urllib.parse.unquote(parsed.path[len('/letters/'):])))
    except LookupError as error:
        return 404, {'error': str(error)}
    except (ValueError, TypeError) as error:
        return 400, {'error': str(error) or 'Invalid request'}
    except (OSError, sqlite3.Error):
        return 503, {'error': 'Studio records unavailable'}


LETTER_FIELDS = {
    'letters-send': ({'operationId', 'sender', 'recipient', 'taskId', 'body'}, {'recordedBy', 'refDoc', 'refSection'}),
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
        return store.send(g('operationId'), g('sender'), g('recipient'), g('taskId'), g('body'), g('recordedBy'), g('refDoc'), g('refSection'))
    if action == 'letters-event':
        return store.event(g('operationId'), g('letterId'), g('event'), g('actor'), g('recordedBy'), g('claimedAt'), g('note', ''), g('body'), g('refDoc'), g('refSection'), g('revision'))
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

    def do_GET(self):
        if not self.local_request():
            return self.reply(403, {'error': 'Local host required'})
        parsed = urllib.parse.urlsplit(self.path)
        if parsed.path in ('/letters', '/letters-inbox', '/letters-senders') or parsed.path.startswith('/letters/'):
            return self.reply(*get_letters(parsed))
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
        if action == 'sync':
            return self.sync()
        if action == 'save':
            return self.save()
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
            result = subprocess.run([sys.executable, str(APP / 'sync.py')], cwd=ROOT, **({'env': SYNC_ENV} if SYNC_ENV else {}),
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
    parser.add_argument('--v3-db', help='V3 mode (with --v3-saves): an existing V3 DB, opened read-only for the page')
    parser.add_argument('--v3-saves', help='V3 mode (with --v3-db): an existing directory for V3 saves')
    parser.add_argument('--output', help='an existing directory for the generated page and data instead of Cache/RegistryStudio '
                                         '(sync.py writes there, its tools record included); for isolated runs')
    args = parser.parse_args()
    global V3, STARTUP_FINGERPRINTS, OUTPUT, WORK_PROGRESS, SYNC_ENV
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
    subprocess.run([sys.executable, str(APP / 'sync.py')], cwd=ROOT, check=True, **({'env': SYNC_ENV} if SYNC_ENV else {}))
    server = ThreadingHTTPServer(('127.0.0.1', args.port), Handler)
    print(f'Registry Studio: http://127.0.0.1:{server.server_port}/  (Ctrl+C to stop)' + (f"  V3 mode: DB {V3['db']} (read-only), saves {V3['saves']}" if V3 else ''), flush=True)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        server.server_close()


if __name__ == '__main__':
    main()
