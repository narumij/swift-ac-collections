#!/usr/bin/env python3
"""Serve Registry Studio locally; POST /sync runs only the fixed sync.py command, POST /save stores the edited JSON in Inbox/."""
import argparse
import datetime
import re
import hashlib
import json
import subprocess
import sys
import threading
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path

import activity
import approvals
import sqlite3

import inbox  # edit versions in Inbox/ (OPS-082)

# Restart-notice manual check requested by user (2026-10-18).
APP = Path(__file__).resolve().parent
ROOT = APP.parent.parent
OUTPUT = ROOT / "Maintanance/Cache/RegistryStudio"
WORK_PROGRESS = OUTPUT / 'work-progress.json'
MAX_PROGRESS_BYTES = 32 * 1024
PROGRESS_STAGES = ('preparation', 'work', 'verification', 'acceptance', 'awaiting-commit')
SYNC_LOCK = threading.Lock()
# Edited JSON handed to the AI (OPS-082). Fixed on the server side; clients never choose the path. REGISTRY_STUDIO_INBOX
# exists only so tests can use an isolated folder. Not under Cache/, so sync and restarts keep it.
INBOX = inbox.INBOX
MAX_SAVE_BYTES = 10 * 1024 * 1024


def runtime_fingerprints():
    # Only modules retained by this process. sync.py and HTML are read afresh.
    result = {}
    for name in ('serve.py', 'inbox.py', 'activity.py', 'approvals.py'):
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

    def do_GET(self):
        if not self.local_request():
            return self.reply(403, {'error': 'Local host required'})
        if self.path == '/commit-approvals':
            try:
                return self.reply(200, approvals.Store().list())
            except (OSError, ValueError, sqlite3.Error):
                return self.reply(503, {'error': 'Approvals unavailable'})
        if self.path in ('/activity-events', '/activity-commits'):
            try:
                records = activity.read_events() if self.path == '/activity-events' else read_activity_commits()
                return self.reply(200, json.dumps(records, ensure_ascii=False).encode())
            except (OSError, ValueError, UnicodeDecodeError, subprocess.SubprocessError):
                return self.reply(503, {'error': 'Activity row unavailable'})
        if self.path == '/work-progress':
            try:
                data = read_work_progress()
                return self.reply(200, json.dumps(data, ensure_ascii=False).encode())
            except (OSError, ValueError, UnicodeDecodeError):
                return self.reply(503, {'error': 'Progress record unavailable'})
        if self.path == '/server-status':
            return self.reply(200, runtime_status())
        if self.path == '/workspace':  # the edit version Studio resumes (OPS-082); null when nothing is saved
            return self.reply(200, json.dumps(inbox.latest(INBOX), ensure_ascii=False).encode())
        if self.path not in ('/', '/index.html', '/registry.json'):
            return self.reply(404, {'error': 'Not found'})
        name = 'registry.json' if self.path == '/registry.json' else 'index.html'
        mime = 'application/json; charset=utf-8' if name.endswith('.json') else 'text/html; charset=utf-8'
        self.reply(200, (OUTPUT / name).read_bytes(), mime)

    def do_POST(self):
        origin = f'http://127.0.0.1:{self.server.server_port}'
        action = {'/sync': 'sync', '/save': 'save', '/commit-approvals': 'commit-approvals'}.get(self.path)
        if (not self.local_request() or self.headers.get('Origin') != origin
                or action is None or self.headers.get('X-Registry-Studio') != action):
            if self.path not in ('/sync', '/save', '/commit-approvals'):
                return self.reply(404, {'error': 'Not found'})
            return self.reply(403, {'error': 'Same-origin Studio request required'})
        if action == 'commit-approvals':
            return self.commit_approvals()
        if action == 'save':
            return self.save()
        if not SYNC_LOCK.acquire(blocking=False):
            return self.reply(409, {'error': '更新中です。完了を待ってください。'})
        try:
            result = subprocess.run([sys.executable, str(APP / 'sync.py')], cwd=ROOT,
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
            return self.reply(200, approvals.Store().mutate(body))
        except approvals.Conflict as error:
            return self.reply(409, {'error': str(error)})
        except (ValueError, UnicodeDecodeError, RecursionError):
            return self.reply(400, {'error': 'Invalid approval request'})
        except (OSError, sqlite3.Error):
            return self.reply(503, {'error': 'Approvals unavailable'})

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


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--port', type=int, default=8088)
    args = parser.parse_args()
    subprocess.run([sys.executable, str(APP / 'sync.py')], cwd=ROOT, check=True)
    server = ThreadingHTTPServer(('127.0.0.1', args.port), Handler)
    print(f'Registry Studio: http://127.0.0.1:{args.port}/  (Ctrl+C to stop)', flush=True)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        server.server_close()


if __name__ == '__main__':
    main()
