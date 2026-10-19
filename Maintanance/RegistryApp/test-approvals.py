#!/usr/bin/env python3
"""Isolated approval tests: temporary SQLite/checkout only; no real approvals."""
import concurrent.futures
import http.client
import json
import sqlite3
import subprocess
import tempfile
import threading
import unittest
from pathlib import Path
from unittest.mock import patch

import approvals
import serve


class ApprovalTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.store = approvals.Store(self.root / 'Approvals' / 'test.sqlite3', self.root)
        self.card = {'taskId': 'OPS-114', 'title': 'Test', 'scope': '<script>plain text</script>', 'paths': ['file.txt'], 'condition': 'Tests pass', 'branch': 'test'}

    def add(self):
        return self.store.add(self.card)

    def change(self, item, action='approve'):
        return self.store.mutate({'action': action, 'targets': [{'id': item['id'], 'revision': item['revision']}]})

    def git(self, *args):
        return subprocess.run(['git', *args], cwd=self.root, check=True, capture_output=True, text=True).stdout.strip()

    def checkout(self):
        self.git('init', '-b', 'test')
        self.git('config', 'user.email', 'fixture@example.invalid')
        self.git('config', 'user.name', 'Test Fixture')
        (self.root / 'file.txt').write_text('initial\n')
        self.git('add', 'file.txt')
        self.git('commit', '-m', 'fixture base')

    def claim(self, item):
        return self.store.claim(item['id'], str(self.root), 'test', 'isolated test report')

    def test_atomic_snapshot_revision_and_durability(self):
        a, b = self.add(), self.add()
        self.change(b)
        with self.assertRaises(approvals.Conflict):
            self.store.mutate({'action': 'approve', 'targets': [{'id': a['id'], 'revision': 1}, {'id': b['id'], 'revision': 1}]})
        self.assertEqual(self.store.list()['requests'][0]['status'], 'pending')
        self.change(a)
        later = self.add()
        records = approvals.Store(self.store.database, self.root).list()['requests']
        self.assertEqual([r['status'] for r in records], ['approved', 'approved', 'pending'])
        self.assertEqual(records[0]['history'][-1]['content'], self.card)
        self.assertEqual(self.store.mutate({'action': 'approve', 'targets': []})['requests'], records)
        self.change(later, 'cancel')
        with self.assertRaises(approvals.Conflict):
            self.change(later)

    def test_malformed_inputs(self):
        for body in ([], None, {'action': 'approve', 'targets': None}, {'action': 'approve', 'targets': [{'id': 'x', 'revision': True}]}, {'action': 'finish', 'targets': []}, {'action': [], 'targets': []}):
            with self.subTest(body=body), self.assertRaises(ValueError):
                self.store.mutate(body)
        for path in ('../secret', '/absolute', '*', 'a//b', './file', '.', '.git/config', 'x\nfile', 'a\\b'):
            with self.subTest(path=path), self.assertRaises(ValueError):
                self.store.add(self.card | {'paths': [path]})
        (self.root / 'linked').symlink_to(self.root / 'file.txt')
        with self.assertRaises(ValueError):
            self.store.add(self.card | {'paths': ['linked']})

    def test_concurrent_approval_one_winner(self):
        item = self.add()
        def approve(_):
            try:
                self.change(item)
                return 'ok'
            except approvals.Conflict:
                return 'conflict'
        with concurrent.futures.ThreadPoolExecutor(2) as pool:
            self.assertCountEqual(list(pool.map(approve, range(2))), ['ok', 'conflict'])
        self.assertEqual(len(self.store.list()['requests'][0]['history']), 2)

    def test_claim_finish_token_and_real_commit(self):
        self.checkout()
        item = self.add()
        with self.assertRaises(approvals.Conflict):
            self.claim(item)
        self.change(item)
        for repo, branch in ((str(self.root.parent), 'test'), (str(self.root), 'other')):
            with self.assertRaises(approvals.Conflict):
                self.store.claim(item['id'], repo, branch, 'report')
        with self.assertRaises(ValueError):
            self.store.claim(item['id'], str(self.root), 'test', '')
        claimed = self.claim(item)
        snapshot = self.store.list()
        self.assertNotIn(claimed['token'], json.dumps(snapshot))
        with self.assertRaises(approvals.Conflict):
            self.store.mutate({'action': 'cancel', 'targets': [{'id': item['id'], 'revision': 3}]})
        with self.assertRaises(approvals.Conflict):
            self.store.finish(item['id'], claimed['token'], self.git('rev-parse', 'HEAD'))
        with self.assertRaises(approvals.Conflict):
            self.store.abandon(item['id'], 'wrong', 'failure')
        second = self.add()
        self.change(second)
        with self.assertRaises(approvals.Conflict):
            self.claim(second)
        (self.root / 'file.txt').write_text('changed\n')
        self.git('add', 'file.txt')
        self.git('commit', '-m', 'fixture change')
        sha = self.git('rev-parse', 'HEAD')
        self.assertEqual(self.store.finish(item['id'], claimed['token'], sha)['status'], 'consumed')
        with self.assertRaises(approvals.Conflict):
            self.store.finish(item['id'], claimed['token'], sha)
        claim2 = self.claim(second)
        self.store.abandon(second['id'], claim2['token'], 'execution failed; new approval required')
        with self.assertRaises(approvals.Conflict):
            self.claim(second)
        self.assertEqual(self.store.list()['requests'][1]['status'], 'cancelled')

    def test_finish_rejects_outside_paths_and_branch_change(self):
        self.checkout()
        item = self.add()
        self.change(item)
        claimed = self.claim(item)
        (self.root / 'outside.txt').write_text('unapproved')
        self.git('add', 'outside.txt')
        self.git('commit', '-m', 'fixture outside')
        sha = self.git('rev-parse', 'HEAD')
        with self.assertRaises(approvals.Conflict):
            self.store.finish(item['id'], claimed['token'], sha)
        self.git('checkout', '--detach', sha)
        with self.assertRaises(subprocess.CalledProcessError):
            self.store.finish(item['id'], claimed['token'], sha)
        self.assertEqual(self.store.list()['requests'][0]['status'], 'claimed')

    def test_filename_whitespace_is_not_normalized(self):
        self.checkout()
        item = self.add()
        self.change(item)
        claimed = self.claim(item)
        (self.root / ' file.txt').write_text('outside allowlist')
        self.git('add', ' file.txt')
        self.git('commit', '-m', 'fixture whitespace')
        with self.assertRaises(approvals.Conflict):
            self.store.finish(item['id'], claimed['token'], self.git('rev-parse', 'HEAD'))
        self.assertEqual(self.store.list()['requests'][0]['status'], 'claimed')

    def test_database_history_and_content_retained(self):
        item = self.add()
        with sqlite3.connect(self.store.database) as con:
            for sql in ("UPDATE requests SET card='{}'", 'DELETE FROM requests', 'DELETE FROM history', "UPDATE history SET event='{}'"):
                with self.subTest(sql=sql), self.assertRaises(sqlite3.IntegrityError):
                    con.execute(sql)
        self.assertEqual(self.store.list()['requests'][0]['id'], item['id'])

    def test_http_guards_validation_conflict_and_no_git_endpoint(self):
        store = self.store
        item = self.add()
        class QuietHandler(serve.Handler):
            def log_message(self, *args):
                pass
        server = serve.ThreadingHTTPServer(('127.0.0.1', 0), QuietHandler)
        thread = threading.Thread(target=server.serve_forever, daemon=True)
        thread.start()
        self.addCleanup(server.server_close)
        self.addCleanup(server.shutdown)
        port = server.server_port
        def request(method='POST', path='/commit-approvals', body=None, headers=None):
            connection = http.client.HTTPConnection('127.0.0.1', port, timeout=3)
            data = json.dumps(body if body is not None else {'action': 'approve', 'targets': [{'id': item['id'], 'revision': 1}]})
            base = {'Origin': f'http://127.0.0.1:{port}', 'X-Registry-Studio': 'commit-approvals', 'Content-Type': 'application/json'}
            base.update(headers or {})
            connection.request(method, path, data, base)
            response = connection.getresponse()
            result = response.status, json.loads(response.read())
            connection.close()
            return result
        with patch.object(serve.approvals, 'Store', return_value=store):
            for headers in ({'Host': 'evil.example'}, {'Origin': 'http://evil.example'}, {'X-Registry-Studio': 'other'}):
                self.assertEqual(request(headers=headers)[0], 403)
            self.assertEqual(request(headers={'Content-Type': 'text/plain'})[0], 400)
            self.assertEqual(request(headers={'Content-Length': 'invalid'})[0], 411)
            self.assertEqual(request(headers={'Content-Length': '999999999999999'})[0], 413)
            self.assertEqual(request(headers={'Content-Length': '0'})[0], 413)
            self.assertEqual(request(body=[])[0], 400)
            self.assertEqual(request(body={'action': 'claim', 'targets': []})[0], 400)
            self.assertEqual(request(method='GET')[0], 200)
            self.assertEqual(request()[0], 200)
            self.assertEqual(request()[0], 409)
            self.assertEqual(request(path='/commit')[0], 404)


if __name__ == '__main__':
    unittest.main()
