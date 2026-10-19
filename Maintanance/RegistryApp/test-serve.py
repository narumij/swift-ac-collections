#!/usr/bin/env python3
"""OPS-131: pin the HTTP behaviour of serve.py (routes, guards, sync, save, approvals) on an isolated port.
Everything behind the handler is mocked or in a temporary folder; no real server, Inbox or approval store is used."""
import json
from pathlib import Path
import socket
import subprocess
import sys
import tempfile
import threading
import unittest
from unittest.mock import patch

import approvals
import serve


class QuietHandler(serve.Handler):
    def log_message(self, *args):
        pass


class ServeTests(unittest.TestCase):
    def setUp(self):
        folder = tempfile.TemporaryDirectory()
        self.addCleanup(folder.cleanup)
        self.folder = Path(folder.name)
        (self.folder/'out').mkdir()
        (self.folder/'out'/'index.html').write_bytes(b'<html>studio</html>')
        (self.folder/'out'/'registry.json').write_bytes(b'{"tasks":[]}')
        for name, value in (('OUTPUT', self.folder/'out'), ('INBOX', self.folder/'inbox')):
            patcher = patch.object(serve, name, value)
            patcher.start(); self.addCleanup(patcher.stop)
        self.server = serve.ThreadingHTTPServer(('127.0.0.1', 0), QuietHandler)
        threading.Thread(target=self.server.serve_forever, daemon=True).start()
        self.addCleanup(self.server.server_close)
        self.addCleanup(self.server.shutdown)
        self.port = self.server.server_port
        self.origin = f'http://127.0.0.1:{self.port}'

    def raw(self, data, half_close=False):
        """Send raw request bytes and return (status, headers, body)."""
        with socket.create_connection(('127.0.0.1', self.port), timeout=10) as connection:
            connection.sendall(data)
            if half_close:
                connection.shutdown(socket.SHUT_WR)
            chunks = []
            while chunk := connection.recv(65536):
                chunks.append(chunk)
        head, _, body = b''.join(chunks).partition(b'\r\n\r\n')
        lines = head.decode('latin-1').split('\r\n')
        headers = {}
        for line in lines[1:]:
            key, _, value = line.partition(':')
            headers[key.strip().lower()] = value.strip()
        return int(lines[0].split()[1]), headers, body

    def request(self, method, path, body=b'', headers=None, length=True, host=None, half_close=False):
        base = {'Host': host or f'127.0.0.1:{self.port}', 'Connection': 'close'}
        if method == 'POST':
            base['Origin'] = self.origin
            base['X-Registry-Studio'] = {'/sync': 'sync', '/save': 'save'}.get(path, path.strip('/'))
            if length:
                base['Content-Length'] = str(len(body))
        base.update(headers or {})
        lines = [f'{method} {path} HTTP/1.1'] + [f'{k}: {v}' for k, v in base.items() if v is not None]
        return self.raw(('\r\n'.join(lines) + '\r\n\r\n').encode() + body, half_close)

    def json_of(self, response):
        status, headers, body = response
        self.assertEqual(headers['content-type'], 'application/json; charset=utf-8')
        self.assertEqual(headers['cache-control'], 'no-store')
        self.assertEqual(headers['content-length'], str(len(body)))
        return status, json.loads(body)

    def test_get_routes(self):
        status, headers, body = self.request('GET', '/')
        self.assertEqual((status, headers['content-type'], body), (200, 'text/html; charset=utf-8', b'<html>studio</html>'))
        self.assertEqual(self.request('GET', '/index.html')[2], b'<html>studio</html>')
        status, headers, body = self.request('GET', '/registry.json')
        self.assertEqual((status, headers['content-type'], headers['cache-control'], body), (200, 'application/json; charset=utf-8', 'no-store', b'{"tasks":[]}'))
        for path in ('/missing', '/index.html?x=1', '/registry.json/', '/../serve.py', '/sync', '/save'):
            self.assertEqual(self.json_of(self.request('GET', path)), (404, {'error': 'Not found'}), path)
        for host in ('localhost:%d' % self.port, '127.0.0.1', 'evil.example'):
            for path in ('/', '/missing', '/activity-events', '/server-status'):
                self.assertEqual(self.json_of(self.request('GET', path, host=host)), (403, {'error': 'Local host required'}))
        with patch.object(serve.activity, 'read_events', return_value=[{'taskId': 'OPS-1', 'reason': '日本語'}]):
            status, headers, body = self.request('GET', '/activity-events')
            self.assertEqual((status, body), (200, json.dumps([{'taskId': 'OPS-1', 'reason': '日本語'}], ensure_ascii=False).encode()))
        for error in (OSError('x'), ValueError('x'), UnicodeDecodeError('utf-8', b'', 0, 1, 'x')):
            with patch.object(serve.activity, 'read_events', side_effect=error):
                self.assertEqual(self.json_of(self.request('GET', '/activity-events')), (503, {'error': 'Activity row unavailable'}))
        with patch.object(serve, 'read_activity_commits', return_value=[{'sha': 'a'}]):
            self.assertEqual(self.json_of(self.request('GET', '/activity-commits')), (200, [{'sha': 'a'}]))
        for error in (subprocess.TimeoutExpired('git', 3), subprocess.CalledProcessError(1, 'git'), ValueError('x')):
            with patch.object(serve, 'read_activity_commits', side_effect=error):
                self.assertEqual(self.json_of(self.request('GET', '/activity-commits')), (503, {'error': 'Activity row unavailable'}))
        with patch.object(serve, 'read_work_progress', return_value=None):
            self.assertEqual(self.json_of(self.request('GET', '/work-progress')), (200, None))
        for error in (OSError('x'), ValueError('x')):
            with patch.object(serve, 'read_work_progress', side_effect=error):
                self.assertEqual(self.json_of(self.request('GET', '/work-progress')), (503, {'error': 'Progress record unavailable'}))
        with patch.object(serve, 'runtime_status', return_value={'restartRecommended': True, 'changedFiles': ['serve.py']}):
            self.assertEqual(self.json_of(self.request('GET', '/server-status')), (200, {'restartRecommended': True, 'changedFiles': ['serve.py']}))
        with patch.object(serve.continuity, 'read', return_value={'schemaVersion': 1, 'owners': {}}):
            status, sent = self.json_of(self.request('GET', '/continuity'))
            self.assertEqual((status, sent['owners']), (200, {})); self.assertIn('serverNow', sent)
        with patch.object(serve.continuity, 'read', side_effect=ValueError('x')):
            self.assertEqual(self.json_of(self.request('GET', '/continuity')), (503, {'error': 'Continuity unavailable'}))
        self.assertEqual(self.json_of(self.request('GET', '/workspace')), (200, None))
        with patch.object(serve.inbox, 'latest', return_value={'saveId': 's'}) as latest:
            self.assertEqual(self.json_of(self.request('GET', '/workspace')), (200, {'saveId': 's'}))
            latest.assert_called_once_with(self.folder/'inbox')
        for path, name in (('/commit-approvals', 'approvals'), ('/approval-probe', 'probe')):
            with patch.object(getattr(serve, name), 'Store') as store:
                store.return_value.list.return_value = {'requests': [name]}
                self.assertEqual(self.json_of(self.request('GET', path)), (200, {'requests': [name]}))
            for error in (OSError('x'), ValueError('x'), serve.sqlite3.Error('x')):
                with patch.object(getattr(serve, name), 'Store', side_effect=error):
                    self.assertEqual(self.json_of(self.request('GET', path)), (503, {'error': 'Approvals unavailable'}))

    def test_post_guards(self):
        actions = {'/sync': 'sync', '/save': 'save', '/commit-approvals': 'commit-approvals', '/approval-probe': 'approval-probe', '/activity-wake': 'activity-wake'}
        forbidden = (403, {'error': 'Same-origin Studio request required'})
        with patch.object(serve.subprocess, 'run') as run, patch.object(serve.inbox, 'append_save') as save, \
                patch.object(serve.approvals, 'Store') as store, patch.object(serve.probe, 'Store') as probe, \
                patch.object(serve.activity, 'request_wake') as wake:
            for path, action in actions.items():
                for headers in ({'Origin': None}, {'Origin': 'http://evil.example'}, {'Origin': f'http://localhost:{self.port}'},
                                {'X-Registry-Studio': None}, {'X-Registry-Studio': 'other'},
                                {'X-Registry-Studio': next(a for a in actions.values() if a != action)}):
                    self.assertEqual(self.json_of(self.request('POST', path, b'{}', headers)), forbidden, (path, headers))
                self.assertEqual(self.json_of(self.request('POST', path, b'{}', host='evil.example')), forbidden)
            for path in ('/commit', '/sync/', '/save?x=1', '/'):
                self.assertEqual(self.json_of(self.request('POST', path, b'{}')), (404, {'error': 'Not found'}), path)
                self.assertEqual(self.json_of(self.request('POST', path, b'{}', {'Origin': None}, host='evil.example')), (404, {'error': 'Not found'}))
            for mock in (run, save, store, probe, wake):
                mock.assert_not_called()

    def test_sync(self):
        def sync(**headers):
            return self.json_of(self.request('POST', '/sync', **headers))
        with patch.object(serve.subprocess, 'run', return_value=subprocess.CompletedProcess([], 0, 'out\n', 'err\n')) as run:
            self.assertEqual(sync(), (200, {'ok': True, 'output': 'out\nerr\n'}))
            run.assert_called_once_with([sys.executable, str(serve.APP/'sync.py')], cwd=serve.ROOT, capture_output=True, text=True, timeout=300)
            self.assertEqual(sync(length=False), (200, {'ok': True, 'output': 'out\nerr\n'}), 'sync needs no body')
        with patch.object(serve.subprocess, 'run', return_value=subprocess.CompletedProcess([], 1, 'o', 'e')):
            self.assertEqual(sync(), (500, {'ok': False, 'output': 'oe'}))
        with patch.object(serve.subprocess, 'run', side_effect=subprocess.TimeoutExpired('sync', 300)):
            self.assertEqual(sync(), (504, {'error': '更新がタイムアウトしました。ターミナルで状態を確認してください。'}))
        with patch.object(serve.subprocess, 'run', side_effect=OSError('no python')):
            self.assertEqual(sync(), (500, {'error': 'no python'}))
        self.assertFalse(serve.SYNC_LOCK.locked(), 'released after success, failure, timeout and OSError')
        # a second sync while one is running is refused; the lock is released afterwards
        started, finish = threading.Event(), threading.Event()
        def slow(*args, **kwargs):
            started.set(); finish.wait(10)
            return subprocess.CompletedProcess([], 0, 'done', '')
        with patch.object(serve.subprocess, 'run', side_effect=slow) as run:
            first = []
            thread = threading.Thread(target=lambda: first.append(sync()))
            thread.start(); self.assertTrue(started.wait(10))
            self.assertEqual(sync(), (409, {'error': '更新中です。完了を待ってください。'}))
            finish.set(); thread.join(10)
            self.assertEqual(first, [(200, {'ok': True, 'output': 'done'})]); self.assertEqual(run.call_count, 1)
        self.assertFalse(serve.SYNC_LOCK.locked())

    def test_save(self):
        good = {'schemaVersion': 1, 'source': {'sha256': 'x'}, 'tasks': [], 'edges': [], 'baseline': {}}
        def save(body, **options):
            raw = body if isinstance(body, bytes) else json.dumps(body).encode()
            return self.json_of(self.request('POST', '/save', raw, **options))
        meta = {'saveId': '20261019-000000-abc', 'parent': 'p'}
        with patch.object(serve.inbox, 'append_save', return_value=meta) as append:
            self.assertEqual(save({**good, 'studioSave': {'parent': 'p', 'saveId': 'client'}}),
                             (200, {'ok': True, 'file': 'registry-edited-20261019-000000-abc.json', 'folder': str(self.folder/'inbox'), 'save': meta}))
            append.assert_called_once_with(good, 'p', self.folder/'inbox')
            append.reset_mock()
            save({**good, 'studioSave': 'p'}); self.assertIsNone(append.call_args[0][1], 'parent only from a dict')
            save(good); self.assertIsNone(append.call_args[0][1])
            with patch.object(serve, 'INBOX', serve.ROOT/'Maintanance/RegistryApp/Inbox'):
                self.assertEqual(save(good)[1]['folder'], 'Maintanance/RegistryApp/Inbox', 'repo-relative when inside the repository')
            append.reset_mock()
            self.assertEqual(save(good, length=False), (411, {'error': 'Content-Length が必要です。'}))
            self.assertEqual(save(good, headers={'Content-Length': 'x'}), (411, {'error': 'Content-Length が必要です。'}))
            self.assertEqual(save(b''), (413, {'error': f'保存できる大きさは {serve.MAX_SAVE_BYTES} バイトまでです。'}))
            self.assertEqual(save(good, headers={'Content-Length': '-1'})[0], 413)
            self.assertEqual(save(good, headers={'Content-Length': str(serve.MAX_SAVE_BYTES + 1)})[0], 413)
            self.assertEqual(save(b'{'), (400, {'error': 'JSONとして読めません。'}))
            self.assertEqual(save(b'\xff'), (400, {'error': 'JSONとして読めません。'}))
            for change in ({'schemaVersion': 2}, {'source': []}, {'source': {'sha256': 1}}, {'tasks': {}}, {'edges': None}, {'baseline': []}):
                self.assertEqual(save({**good, **change}), (400, {'error': 'Registry Studio形式のJSONではありません。'}), change)
            self.assertEqual(save([]), (400, {'error': 'Registry Studio形式のJSONではありません。'}))
            append.assert_not_called()
        with patch.object(serve.inbox, 'append_save', side_effect=ValueError('親が違います')):
            self.assertEqual(save(good), (409, {'error': '親が違います'}))
        with patch.object(serve.inbox, 'append_save', side_effect=OSError('disk full')):
            self.assertEqual(save(good), (500, {'error': '保存できませんでした：disk full'}))

    def test_approvals(self):
        for path, name in (('/commit-approvals', 'approvals'), ('/approval-probe', 'probe')):
            other = 'probe' if name == 'approvals' else 'approvals'
            def post(body=b'{"action":"x"}', **options):
                options.setdefault('headers', {}).setdefault('Content-Type', 'application/json')
                return self.json_of(self.request('POST', path, body, **options))
            with patch.object(getattr(serve, name), 'Store') as store, patch.object(getattr(serve, other), 'Store') as unused:
                store.return_value.mutate.return_value = {'requests': ['done']}
                self.assertEqual(post(), (200, {'requests': ['done']}))
                store.return_value.mutate.assert_called_once_with({'action': 'x'})
                self.assertEqual(post(headers={'Content-Type': 'Application/JSON; charset=utf-8'})[0], 200)
                store.reset_mock()
                bad = (400, {'error': 'JSON body required'})
                self.assertEqual(post(headers={'Content-Type': 'text/plain'}), bad)
                self.assertEqual(post(headers={'Content-Type': None}), bad)
                self.assertEqual(post(headers={'Transfer-Encoding': 'chunked'}), bad)
                required = (411, {'error': 'Content-Length required'})
                self.assertEqual(post(length=False), required)
                self.assertEqual(post(headers={'Content-Length': 'x'}), required)
                self.assertEqual(post(headers={'Content-Length': '-1'}), required)
                large = (413, {'error': 'Approval body too large'})
                self.assertEqual(post(b''), large)
                self.assertEqual(post(headers={'Content-Length': '1000000'}), large)
                self.assertEqual(post(headers={'Content-Length': str(128 * 1024 + 1)}), large)
                invalid = (400, {'error': 'Invalid approval request'})
                self.assertEqual(post(b'{', ), invalid)
                self.assertEqual(post(b'\xff'), invalid)
                self.assertEqual(post(b'{"a"', headers={'Content-Length': '10'}, half_close=True), invalid, 'incomplete body')
                store.assert_not_called()
                # duplicate Content-Length headers
                lines = [f'POST {path} HTTP/1.1', f'Host: 127.0.0.1:{self.port}', f'Origin: {self.origin}', f'X-Registry-Studio: {path.strip("/")}',
                         'Content-Type: application/json', 'Content-Length: 2', 'Content-Length: 2', 'Connection: close']
                self.assertEqual(self.json_of(self.raw(('\r\n'.join(lines) + '\r\n\r\n{}').encode())), required)
                for error, expected in ((approvals.Conflict('changed'), (409, {'error': 'changed'})), (ValueError('x'), invalid),
                                        (RecursionError(), invalid), (OSError('x'), (503, {'error': 'Approvals unavailable'})),
                                        (serve.sqlite3.Error('x'), (503, {'error': 'Approvals unavailable'}))):
                    store.return_value.mutate.side_effect = error
                    self.assertEqual(post(), expected, error)
                unused.assert_not_called()


    def test_activity_wake(self):
        def post(body=b'{"owner":"Astra"}', **options):
            options.setdefault('headers', {}).setdefault('Content-Type', 'application/json')
            return self.json_of(self.request('POST', '/activity-wake', body, **options))
        event = {'id': 'e', 'reason': 'WAKE-20261019-ABC：Astraへ。'}
        with patch.object(serve.activity, 'request_wake', return_value=(event, True)) as wake:
            self.assertEqual(post(), (200, {'created': True, 'event': event})); wake.assert_called_once_with('Astra')
            wake.reset_mock()
            bad = (400, {'error': 'JSON body required'})
            self.assertEqual(post(headers={'Content-Type': 'text/plain'}), bad); self.assertEqual(post(headers={'Transfer-Encoding': 'chunked'}), bad)
            self.assertEqual(post(length=False), (411, {'error': 'Content-Length required'}))
            self.assertEqual(post(headers={'Content-Length': '2000'}), (411, {'error': 'Content-Length required'}))
            self.assertEqual(post(b''), (411, {'error': 'Content-Length required'}))
            invalid = (400, {'error': 'Invalid wake request'})
            for body in (b'{', b'[]', b'{"owner":1}', b'{"owner":"Astra","reason":"free text"}', b'{"owner":"Astra","command":"rm"}', b'\xff'):
                self.assertEqual(post(body), invalid, body)
            wake.assert_not_called()
        with patch.object(serve.activity, 'request_wake', return_value=(event, False)):
            self.assertEqual(post(), (200, {'created': False, 'event': event}), 'unanswered request comes back')
        for error, expected in ((LookupError('x'), (409, {'error': 'Unknown owner'})), (ValueError('x'), (400, {'error': 'Invalid wake request'})), (OSError('x'), (503, {'error': 'Activity unavailable'}))):
            with patch.object(serve.activity, 'request_wake', side_effect=error):
                self.assertEqual(post(), expected)


if __name__ == '__main__':
    unittest.main()
