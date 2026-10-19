#!/usr/bin/env python3
"""OPS-156: isolated tests of the communication / operation records (案A, same SQLite file as the approvals), the server
routes and the command lines through HTTP. Temporary database, checkout, activity log and server only; nothing live."""
import concurrent.futures
import contextlib
import io
import json
import os
import socket
import sqlite3
import subprocess
import sys
import tempfile
import threading
import unittest
import uuid
from pathlib import Path
from unittest.mock import patch

import activity
import approvals
import comm
import serve
import studio_client
import studio_store

RealApprovals, RealComm = approvals.Store, studio_store.Store
CARD = {'taskId': 'OPS-156', 'title': 'T', 'scope': 's', 'paths': ['file.txt'], 'condition': 'c', 'branch': 'test'}


class Base(unittest.TestCase):
    def setUp(self):
        temp = tempfile.TemporaryDirectory()
        self.addCleanup(temp.cleanup)
        self.root = Path(temp.name)
        self.db = self.root / 'Approvals' / 'studio-test.sqlite3'
        self.store = approvals.Store(self.db, self.root)
        self.comm = studio_store.Store(self.db, self.root)

    def raw(self, sql, *args):
        con = sqlite3.connect(self.db)
        try:
            return con.execute(sql, args).fetchall()
        finally:
            con.close()

    def git(self, *args):
        return subprocess.run(['git', *args], cwd=self.root, check=True, capture_output=True, text=True).stdout.strip()

    def checkout(self):
        self.git('init', '-b', 'test')
        self.git('config', 'user.email', 'fixture@example.invalid')
        self.git('config', 'user.name', 'Test Fixture')
        (self.root / 'file.txt').write_text('initial\n')
        self.git('add', 'file.txt')
        self.git('commit', '-m', 'fixture base')


class StoreTests(Base):
    def test_old_database_gains_tables_and_keeps_history(self):
        self.db.parent.mkdir(parents=True)
        con = sqlite3.connect(self.db)
        con.execute('CREATE TABLE requests (id TEXT PRIMARY KEY, card TEXT NOT NULL, state TEXT NOT NULL, token_hash TEXT)')
        con.execute('CREATE TABLE history (sequence INTEGER PRIMARY KEY AUTOINCREMENT, request_id TEXT NOT NULL REFERENCES requests(id), event TEXT NOT NULL)')
        state = {'revision': 1, 'status': 'pending', 'createdAt': 'x', 'updatedAt': 'x', 'approvedAt': None, 'commitSha': None}
        con.execute("INSERT INTO requests VALUES ('old', ?, ?, NULL)", (json.dumps(CARD), json.dumps(state)))
        con.execute("INSERT INTO history(request_id,event) VALUES ('old', ?)", (json.dumps({'action': 'add', 'at': 'x', 'revision': 1}),))
        con.commit()
        con.close()
        listed = self.store.list()['requests']
        self.assertEqual([r['id'] for r in listed], ['old'])
        self.assertEqual(listed[0]['history'], [{'action': 'add', 'at': 'x', 'revision': 1}])
        tables = {r[0] for r in self.raw("SELECT name FROM sqlite_master WHERE type='table'")}
        self.assertTrue({'operations', 'messages', 'acks', 'meta'} <= tables)
        self.store.list()  # opening again is idempotent
        self.assertEqual(len(self.raw('SELECT * FROM history')), 1)

    def test_new_tables_are_append_only(self):
        item = self.store.add(CARD)
        self.store.mutate({'action': 'approve', 'targets': [{'id': item['id'], 'revision': 1}], 'operationId': 'a' * 32})
        sent = self.comm.ping('b' * 32, '姫', 'OPS-155')
        self.comm.ack(sent['id'], '姫')
        self.comm.cutover('ab' * 16)
        con = sqlite3.connect(self.db)
        for sql in ("UPDATE operations SET status='x'", 'DELETE FROM operations', "UPDATE messages SET target='x'", 'DELETE FROM messages',
                    "UPDATE acks SET status='x'", 'DELETE FROM acks', "UPDATE meta SET value='x'", 'DELETE FROM meta'):
            with self.assertRaises(sqlite3.DatabaseError, msg=sql):
                con.execute(sql)
        con.close()

    def test_operation_applied_replayed_and_reused_id(self):
        a, b = self.store.add(CARD), self.store.add(CARD)
        body = {'action': 'approve', 'targets': [{'id': a['id'], 'revision': 1}, {'id': b['id'], 'revision': 1}], 'operationId': '1' * 32}
        first = self.store.mutate(body)
        self.assertEqual(first['operation'], {'id': '1' * 32, 'status': 'applied', 'replayed': False, 'targets': [a['id'], b['id']], 'changed': [a['id'], b['id']]})
        events = [json.loads(e[0]) for e in self.raw('SELECT event FROM history WHERE request_id=? ORDER BY sequence', a['id'])]
        self.assertEqual(events[-1]['operationId'], '1' * 32, 'the approval history names the operation')
        again = self.store.mutate(body)
        self.assertTrue(again['operation']['replayed'])
        self.assertEqual(len(self.raw('SELECT * FROM history')), 4, 'a resend applies nothing again')
        self.assertEqual(len(self.raw('SELECT * FROM operations')), 1)
        other = dict(body, targets=[{'id': a['id'], 'revision': 1}])
        with self.assertRaisesRegex(approvals.Conflict, 'different content'):
            self.store.mutate(other)
        with self.assertRaises(ValueError):
            self.store.mutate(dict(body, operationId='not-hex'))
        with self.assertRaises(ValueError):
            self.store.mutate(dict(body, extra=1))

    def test_refused_change_is_recorded_and_nothing_changes(self):
        a, b = self.store.add(CARD), self.store.add(CARD)
        self.store.mutate({'action': 'approve', 'targets': [{'id': b['id'], 'revision': 1}]})
        before = self.store.list()
        body = {'action': 'approve', 'targets': [{'id': a['id'], 'revision': 1}, {'id': b['id'], 'revision': 1}], 'operationId': '2' * 32}
        with self.assertRaises(approvals.Conflict):
            self.store.mutate(body)
        self.assertEqual([(r['status'], r['revision']) for r in self.store.list()['requests']], [(r['status'], r['revision']) for r in before['requests']], 'all or nothing')
        op = self.store.operations()['operations'][0]
        self.assertEqual((op['id'], op['status']), ('2' * 32, 'refused'))
        self.assertEqual(op['result']['changed'], [])
        self.assertEqual(op['result']['reason']['id'], b['id'])
        with self.assertRaises(approvals.Conflict):
            self.store.mutate(body)
        self.assertEqual(len(self.raw("SELECT * FROM operations WHERE id=?", '2' * 32)), 1, 'a resent refusal is not recorded twice')
        with self.assertRaises(approvals.Conflict):
            self.store.mutate({'action': 'cancel', 'targets': [{'id': 'missing', 'revision': 1}], 'operationId': '3' * 32})
        self.assertEqual(self.store.operations()['operations'][0]['result']['reason']['reason'], 'Unknown request')

    def test_failure_inside_the_transaction_rolls_everything_back(self):
        a, b = self.store.add(CARD), self.store.add(CARD)
        original = approvals.Store._save
        calls = []
        def failing(store, con, *args, **kwargs):
            calls.append(1)
            if len(calls) == 2:
                raise RuntimeError('injected')
            return original(store, con, *args, **kwargs)
        with patch.object(approvals.Store, '_save', failing):
            with self.assertRaises(RuntimeError):
                self.store.mutate({'action': 'approve', 'targets': [{'id': a['id'], 'revision': 1}, {'id': b['id'], 'revision': 1}], 'operationId': '4' * 32})
        self.assertEqual([r['status'] for r in self.store.list()['requests']], ['pending', 'pending'])
        self.assertEqual(self.raw('SELECT * FROM operations'), [], 'no operation record without its change')
        self.store.mutate({'action': 'approve', 'targets': [{'id': a['id'], 'revision': 1}], 'operationId': '4' * 32})  # the same ID applies once retried

    def test_concurrent_sends_of_one_operation_apply_once(self):
        a = self.store.add(CARD)
        body = {'action': 'approve', 'targets': [{'id': a['id'], 'revision': 1}], 'operationId': '5' * 32}
        with concurrent.futures.ThreadPoolExecutor(6) as pool:
            results = list(pool.map(lambda _: approvals.Store(self.db, self.root).mutate(body), range(6)))
        self.assertEqual(sorted(r['operation']['replayed'] for r in results), [False] + [True] * 5)
        self.assertEqual(len(self.raw("SELECT * FROM history WHERE event LIKE '%approve%'")), 1)

    def test_ping_ack_answer_duplicate_foreign(self):
        sent = self.comm.ping('6' * 32, '姫', 'OPS-155')
        self.assertRegex(sent['id'], r'^PING-\d{8}-[0-9A-F]{32}$')
        self.assertEqual((sent['status'], sent['target'], sent['sender'], sent['replayed']), ('unanswered', '姫', 'ユーザー', False))
        self.assertEqual(self.comm.ping('6' * 32, '姫', 'OPS-155')['id'], sent['id'], 'a resend of the same operation is the same PING')
        with self.assertRaises(approvals.Conflict):
            self.comm.ping('6' * 32, 'Astra', 'OPS-155')
        foreign = self.comm.ack(sent['id'], 'Astra')
        self.assertEqual((foreign['ack'], foreign['status']), ('foreign', 'unanswered'), 'only the target answers')
        answer = self.comm.ack(sent['id'], '姫', claimed_at='2026-10-19T13:00:00+09:00')
        self.assertEqual((answer['ack'], answer['status']), ('answer', 'answered'))
        self.assertEqual(answer['answer']['claimed_at'], '2026-10-19T13:00:00+09:00')
        self.assertNotEqual(answer['answer']['received_at'], answer['answer']['claimed_at'], 'claimed and received times are separate')
        dup = self.comm.ack(sent['id'], '姫')
        self.assertEqual(dup['ack'], 'duplicate')
        proxy = self.comm.ack(sent['id'], '姫', recorded_by='Astra調整')
        self.assertEqual(proxy['ack'], 'proxy')
        self.assertEqual(proxy['acks'][-1]['recorded_by'], 'Astra調整', 'who recorded it is kept apart from whose answer it claims to be')

    def test_proxy_ack_before_the_member_is_not_the_answer(self):
        sent = self.comm.ping('c' * 32, '姫', 'OPS-155')
        proxy = self.comm.ack(sent['id'], '姫', recorded_by='Astra調整')
        self.assertEqual((proxy['ack'], proxy['status'], proxy['answer']), ('proxy', 'unanswered', None), 'a proxy record naming the target is not its answer')
        own = self.comm.ack(sent['id'], '姫')
        self.assertEqual((own['ack'], own['status']), ('answer', 'answered'), 'the member\'s own ACK after a proxy one is the answer')
        self.assertEqual(own['answer']['recorded_by'], '姫')
        self.assertEqual([a['status'] for a in own['acks']], ['proxy', 'answer'])
        with self.assertRaises(LookupError):
            self.comm.ack('PING-20261019-' + 'F' * 32, '姫')
        for bad in ({'claimed_at': '2026-10-19T13:00:00'}, {'claimed_at': 'yesterday'}):
            with self.assertRaises(ValueError):
                self.comm.ack(sent['id'], '姫', **bad)
        with self.assertRaises(ValueError):
            self.comm.ping('7' * 32, '姫', 'not a task')

    def test_cutover_recorded_once(self):
        self.assertIsNone(self.comm.cutover_point())
        first = self.comm.cutover('ab' * 16)
        self.assertFalse(first['replayed'])
        self.assertTrue(self.comm.cutover('ab' * 16)['replayed'])
        with self.assertRaises(approvals.Conflict):
            self.comm.cutover('cd' * 16)
        with self.assertRaises(ValueError):
            self.comm.cutover('x')


class HttpTests(Base):
    def setUp(self):
        super().setUp()
        self.events = self.root / 'Activity' / 'events.jsonl'
        patches = [patch.object(activity, 'EVENTS', self.events),
                   patch.object(serve.approvals, 'Store', lambda *a, **k: RealApprovals(self.db, self.root)),
                   patch.object(serve.studio_store, 'Store', lambda *a, **k: RealComm(self.db, self.root))]
        for p in patches:
            p.start()
            self.addCleanup(p.stop)
        activity.append_event('OPS-155', 'work', '姫', '待機', presence='waiting')
        class Quiet(serve.Handler):
            def log_message(self, *args):
                pass
        self.server = serve.ThreadingHTTPServer(('127.0.0.1', 0), Quiet)
        threading.Thread(target=self.server.serve_forever, daemon=True).start()
        self.addCleanup(self.server.server_close)
        self.addCleanup(self.server.shutdown)
        self.url = f'http://127.0.0.1:{self.server.server_port}'
        env = patch.dict(os.environ, {'REGISTRY_STUDIO_URL': self.url})
        env.start()
        self.addCleanup(env.stop)

    def cli(self, module, *argv):
        """Run a command line in-process with SQLite unavailable: it must reach the database only through the server."""
        out = io.StringIO()
        real = sqlite3.connect
        server_thread = threading.current_thread
        def guarded(*a, **k):
            if threading.current_thread() is self.main_thread:
                raise AssertionError('the command line opened SQLite directly')
            return real(*a, **k)
        self.main_thread = threading.current_thread()
        with patch.object(sys, 'argv', [module.__name__, *argv]), patch.object(sqlite3, 'connect', guarded), contextlib.redirect_stdout(out):
            try:
                module.main()
                code = 0
            except SystemExit as exit_:
                code = exit_.code
        return code, out.getvalue()

    def test_guards_and_validation(self):
        call = lambda path, action, body, **h: studio_client._call('POST', path, action, body)
        with self.assertRaisesRegex(studio_client.StudioError, '403'):
            studio_client._call('POST', '/comm-ack', 'comm-ping', {'messageId': 'x', 'owner': '姫'})
        with self.assertRaisesRegex(studio_client.StudioError, '400'):
            call('/comm-ack', 'comm-ack', {'messageId': 'x'})
        with self.assertRaisesRegex(studio_client.StudioError, '409.*Unknown member'):
            call('/comm-ping', 'comm-ping', {'operationId': '8' * 32, 'target': '不明', 'taskId': 'OPS-155'})
        with self.assertRaisesRegex(studio_client.StudioError, '409.*Unknown member'):
            call('/comm-ping', 'comm-ping', {'operationId': '8' * 32, 'target': 'ユーザー', 'taskId': 'OPS-155'})
        with self.assertRaisesRegex(studio_client.StudioError, '400'):
            call('/approvals-cli', 'approvals-cli', {'command': 'drop', 'args': {}})
        with self.assertRaisesRegex(studio_client.StudioError, '400'):
            call('/approvals-cli', 'approvals-cli', {'command': 'list', 'args': {'x': 1}})
        with patch.dict(os.environ, {'REGISTRY_STUDIO_URL': 'http://example.com:1'}):
            with self.assertRaisesRegex(studio_client.StudioError, '127.0.0.1'):
                studio_client.get('/comm-messages')

    def test_ping_and_ack_through_the_server_and_comm_cli(self):
        code, out = self.cli(comm, 'ping', '--target', '姫', '--task', 'OPS-155', '--operation-id', '9' * 32)
        self.assertEqual(code, 0)
        ping_id = json.loads(out)['id']
        code, out = self.cli(comm, 'ack', ping_id, '--owner', '姫', '--claimed-at', '2026-10-19T13:00:00+09:00')
        self.assertEqual((code, json.loads(out)['status']), (0, 'answered'))
        listed = studio_client.get('/comm-messages')
        self.assertEqual(listed['messages'][0]['id'], ping_id)
        self.assertIsNone(listed['cutover'])
        ops = studio_client.get('/studio-operations')['operations']
        self.assertEqual((ops[0]['kind'], ops[0]['result']['messageId']), ('ping', ping_id))
        code, _ = self.cli(comm, 'ack', 'PING-20261019-' + 'E' * 32, '--owner', '姫')
        self.assertEqual(code, 1)

    def test_approvals_cli_through_the_server_keeps_arguments_tokens_and_git_checks(self):
        self.checkout()
        code, out = self.cli(approvals, 'add', '--task-id', 'OPS-156', '--title', 'T', '--scope', 's', '--condition', 'c', '--branch', 'test', '--path', 'file.txt')
        self.assertEqual(code, 0)
        item = json.loads(out)
        self.assertEqual((item['status'], item['paths']), ('pending', ['file.txt']))
        code, out = self.cli(approvals, 'list')
        self.assertEqual([r['id'] for r in json.loads(out)['requests']], [item['id']])
        code, _ = self.cli(approvals, 'claim', item['id'], '--repo', str(self.root), '--branch', 'test', '--acceptance-ref', 'r')
        self.assertEqual(code, 1, 'claiming before approval is refused by the server')
        self.store.mutate({'action': 'approve', 'targets': [{'id': item['id'], 'revision': 1}]})
        code, _ = self.cli(approvals, 'claim', item['id'], '--repo', str(self.root.parent), '--branch', 'test', '--acceptance-ref', 'r')
        self.assertEqual(code, 1, 'the repository check is kept')
        code, out = self.cli(approvals, 'claim', item['id'], '--repo', str(self.root), '--branch', 'test', '--acceptance-ref', 'r')
        claimed = json.loads(out)
        self.assertEqual((code, claimed['status']), (0, 'claimed'))
        (self.root / 'file.txt').write_text('changed\n')
        self.git('add', 'file.txt')
        self.git('commit', '-m', 'change')
        sha = self.git('rev-parse', 'HEAD')
        code, _ = self.cli(approvals, 'finish', item['id'], '--token', 'wrong', '--sha', sha)
        self.assertEqual(code, 1, 'the claim token is kept')
        code, out = self.cli(approvals, 'finish', item['id'], '--token', claimed['token'], '--sha', sha)
        self.assertEqual((code, json.loads(out)['status']), (0, 'consumed'))

    def test_url_is_parsed_and_only_127_0_0_1_is_contacted(self):
        contacted = []
        real = socket.create_connection
        def watch(address, *a, **k):
            contacted.append(address)
            return real(address, *a, **k)
        bad = ['http://127.0.0.1:1@evil.example', 'http://user@127.0.0.1:%d' % self.server.server_port, 'http://u:p@127.0.0.1:%d' % self.server.server_port,
               'http://127.0.0.1:8088.evil.example', 'https://127.0.0.1:%d' % self.server.server_port, 'http://127.0.0.1:%d/x' % self.server.server_port,
               'http://127.0.0.1:%d?q=1' % self.server.server_port, 'http://127.0.0.1:%d#f' % self.server.server_port, 'http://127.0.0.1', 'http://localhost:%d' % self.server.server_port,
               'http://[::1]:%d' % self.server.server_port, 'http://127.0.0.1:99999']
        with patch.object(socket, 'create_connection', watch):
            for url in bad:
                with patch.dict(os.environ, {'REGISTRY_STUDIO_URL': url}):
                    with self.assertRaises(studio_client.StudioError, msg=url) as caught:
                        studio_client.get('/comm-messages')
                    self.assertEqual(caught.exception.outcome, 'not-sent', url)
        self.assertEqual(contacted, [], 'no connection is opened for a rejected URL')
        with patch.dict(os.environ, {'REGISTRY_STUDIO_URL': self.url + '/'}):
            self.assertIn('messages', studio_client.get('/comm-messages'))

    def test_redirect_is_not_followed(self):
        hits = []
        class Redirect(serve.BaseHTTPRequestHandler):
            def log_message(self, *args):
                pass
            def do_POST(self):
                hits.append(self.path)
                self.send_response(307)
                self.send_header('Location', 'http://evil.example/comm-ack')
                self.send_header('Content-Length', '0')
                self.end_headers()
        server = serve.ThreadingHTTPServer(('127.0.0.1', 0), Redirect)
        threading.Thread(target=server.serve_forever, daemon=True).start()
        self.addCleanup(server.server_close)
        self.addCleanup(server.shutdown)
        contacted = []
        real = socket.create_connection
        with patch.dict(os.environ, {'REGISTRY_STUDIO_URL': f'http://127.0.0.1:{server.server_port}'}), \
             patch.object(socket, 'create_connection', lambda address, *a, **k: (contacted.append(address), real(address, *a, **k))[1]):
            with self.assertRaisesRegex(studio_client.StudioError, 'redirect') as caught:
                studio_client.post('/comm-ack', 'comm-ack', {'messageId': 'x', 'owner': '姫'})
        self.assertEqual(caught.exception.outcome, 'refused')
        self.assertEqual(hits, ['/comm-ack'])
        self.assertEqual([a[0] for a in contacted], ['127.0.0.1'], 'only the local server was contacted')

    def test_lost_answer_is_result_unknown_not_unrecorded(self):
        sent = RealComm(self.db, self.root).ping('d' * 32, '姫', 'OPS-155')
        original = serve.Handler.reply
        def lose(handler, status, body, *a, **k):
            if handler.path == '/comm-ack':
                handler.close_connection = True
                handler.connection.shutdown(socket.SHUT_RDWR)  # stored, but the answer never leaves the server
                return None
            return original(handler, status, body, *a, **k)
        with patch.object(serve.Handler, 'reply', lose):
            code, out = self.cli(comm, 'ack', sent['id'], '--owner', '姫')
            with self.assertRaises(studio_client.StudioError) as caught:
                studio_client.post('/comm-ack', 'comm-ack', {'messageId': sent['id'], 'owner': '姫'})
        self.assertEqual(caught.exception.outcome, 'unknown')
        self.assertIn('result is unknown', str(caught.exception))
        self.assertNotIn('nothing was', str(caught.exception))
        self.assertEqual(code, 1)
        stored = [a['status'] for a in RealComm(self.db, self.root).messages()['messages'][0]['acks']]
        self.assertEqual(stored, ['answer', 'duplicate'], 'both were stored although no answer came back: "unrecorded" would have been wrong')
        # a server that reads the request and closes without answering: also unknown
        listener = socket.socket()
        listener.bind(('127.0.0.1', 0))
        listener.listen(1)
        self.addCleanup(listener.close)
        def drop():
            conn, _ = listener.accept()
            conn.recv(65536)
            conn.close()
        threading.Thread(target=drop, daemon=True).start()
        with patch.dict(os.environ, {'REGISTRY_STUDIO_URL': f'http://127.0.0.1:{listener.getsockname()[1]}'}):
            with self.assertRaises(studio_client.StudioError) as dropped:
                studio_client.post('/comm-ack', 'comm-ack', {'messageId': sent['id'], 'owner': '姫'})
        self.assertEqual(dropped.exception.outcome, 'unknown')

    def test_cutover_marker_failure_after_the_database_commit(self):
        last = activity.read_events()[-1]['id']
        real_replace = Path.replace
        def fail_once(path, target):
            if path.name.startswith('ping-cutover'):
                raise OSError('disk full')
            return real_replace(path, target)
        with patch.object(Path, 'replace', fail_once):
            with self.assertRaisesRegex(studio_client.StudioError, '503.*recorded in the database but the activity marker was not written'):
                studio_client.post('/comm-cutover', 'comm-cutover', {'afterEventId': last})
        self.assertEqual(RealComm(self.db, self.root).cutover_point()['afterEventId'], last, 'the point is committed')
        self.assertFalse(activity.ping_cutover_file().exists(), 'the marker is missing')
        gap = activity.append_event('OPS-155', 'work', '姫', 'ACK PING-20261019-C：受信')
        self.assertTrue(gap['reason'].startswith('ACK PING-'), 'the known gap: until the marker exists, the old way still writes')
        again = studio_client.post('/comm-cutover', 'comm-cutover', {'afterEventId': last})
        self.assertEqual((again['replayed'], again['marker']), (True, True), 'sending the same request again writes the marker')
        with self.assertRaisesRegex(ValueError, 'comm.py'):
            activity.append_event('OPS-155', 'work', '姫', 'ACK PING-20261019-C：受信')
        self.assertEqual(studio_client.get('/comm-messages')['cutover']['afterEventId'], last)

    def test_unreachable_server_records_nothing(self):
        with socket.socket() as s:
            s.bind(('127.0.0.1', 0))
            port = s.getsockname()[1]
        with patch.dict(os.environ, {'REGISTRY_STUDIO_URL': f'http://127.0.0.1:{port}'}):
            code, _ = self.cli(comm, 'ack', 'PING-20261019-' + 'A' * 32, '--owner', '姫')
            code2, _ = self.cli(approvals, 'list')
            with self.assertRaises(studio_client.StudioError) as caught:
                studio_client.get('/comm-messages')
        self.assertEqual((code, code2), (1, 1))
        self.assertEqual(caught.exception.outcome, 'not-sent')
        self.assertFalse(self.db.exists(), 'nothing was created or written')
        self.assertEqual(self.events.read_text().count('\n'), 1, 'and nothing went to the activity log instead')

    def test_cutover_marker_stops_direct_ping_lines(self):
        before = activity.append_event('OPS-155', 'work', '姫', 'ACK PING-20261019-A：受信')
        self.assertTrue(before['reason'].startswith('ACK PING-'), 'before the cutover the old way still works')
        last = activity.read_events()[-1]['id']
        result = studio_client.post('/comm-cutover', 'comm-cutover', {'afterEventId': last})
        self.assertEqual(result['afterEventId'], last)
        self.assertEqual(json.loads(activity.ping_cutover_file().read_text())['afterEventId'], last)
        for reason in ('PING-20261019-B：疎通', 'ACK PING-20261019-B：受信'):
            with self.assertRaisesRegex(ValueError, 'comm.py'):
                activity.append_event('OPS-155', 'work', '姫', reason)
        self.assertEqual(activity.append_event('OPS-155', 'work', '姫', '通常の作業')['reason'], '通常の作業')
        lines = self.events.read_text().splitlines()
        self.assertEqual(len(lines), 3, 'rejected lines were not written; the history before the cutover is unchanged')
        with self.assertRaisesRegex(studio_client.StudioError, '409'):
            studio_client.post('/comm-cutover', 'comm-cutover', {'afterEventId': 'ef' * 16})


if __name__ == '__main__':
    unittest.main()
