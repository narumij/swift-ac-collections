"""Isolated tests for durable record notifications; all data lives in temp dirs."""
import json
import os
import queue
import sqlite3
import subprocess
import sys
import tempfile
import threading
import time
import unittest
from pathlib import Path
from http.server import ThreadingHTTPServer
from unittest import mock

import record_notifications


class DatabaseRecordTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.path = Path(self.temp.name) / 'records.sqlite3'
        with sqlite3.connect(self.path) as con:
            con.execute('CREATE TABLE operations (id TEXT, payload TEXT)')
        self.output = []
        self.records = record_notifications.DatabaseRecords(self.path, ('operations',), self.output.append)

    def insert(self, identity, payload='{}'):
        with sqlite3.connect(self.path) as con:
            con.execute('INSERT INTO operations VALUES (?, ?)', (identity, payload))

    def test_initial_rows_are_skipped(self):
        self.insert('before-watch')
        self.records = record_notifications.DatabaseRecords(self.path, ('operations',), self.output.append)
        self.records.changed()
        self.assertEqual(self.output, [])
        self.insert('after-watch')
        self.records.changed()
        self.assertEqual(len(self.output), 1)
        self.assertIn('after-watch', self.output[0])

    def test_only_committed_rows_publish(self):
        con = sqlite3.connect(self.path)
        try:
            con.execute('BEGIN')
            con.execute('INSERT INTO operations VALUES (?, ?)', ('pending', '{}'))
            self.records.changed()
            self.assertEqual(self.output, [])
            con.commit()
            self.records.changed()
            self.assertEqual(len(self.output), 1)
            self.assertIn('pending', self.output[0])
        finally:
            con.close()

    def test_multiple_rows_and_repeated_watch_hint_publish_once_each(self):
        with sqlite3.connect(self.path) as con:
            con.executemany('INSERT INTO operations VALUES (?, ?)', [('one', '{}'), ('two', '{}'), ('three', '{}')])
        self.records.changed()
        self.records.changed()
        self.assertEqual(len(self.output), 3)
        self.assertEqual([name for name in ('one', 'two', 'three') if any(name in event for event in self.output)],
                         ['one', 'two', 'three'])

    def test_rollback_does_not_publish(self):
        con = sqlite3.connect(self.path)
        try:
            con.execute('BEGIN')
            con.execute('INSERT INTO operations VALUES (?, ?)', ('rolled-back', '{}'))
            con.rollback()
        finally:
            con.close()
        self.records.changed()
        self.assertEqual(self.output, [])

    def test_database_replacement_announces_reset_then_replays_new_file(self):
        self.insert('old-file-row')
        self.records = record_notifications.DatabaseRecords(self.path, ('operations',), self.output.append)
        replacement = self.path.with_suffix('.replacement')
        with sqlite3.connect(replacement) as con:
            con.execute('CREATE TABLE operations (id TEXT, payload TEXT)')
            con.executemany('INSERT INTO operations VALUES (?, ?)', [('new-file-one', '{}'), ('new-file-two', '{}')])
        replacement.replace(self.path)

        self.records.changed()

        self.assertEqual(len(self.output), 3)
        self.assertIn('reset', self.output[0].lower(), 'the source replacement is explicit')
        self.assertLess(self.output.index(next(row for row in self.output if 'reset' in row.lower())),
                        self.output.index(next(row for row in self.output if 'new-file-one' in row)))
        self.assertIn('new-file-one', self.output[1])
        self.assertIn('new-file-two', self.output[2])
        self.assertNotIn('old-file-row', '\n'.join(self.output))

    def test_secret_fields_are_redacted_in_nested_json_payload(self):
        payload = json.dumps({'card': {'title': 'safe'}, 'token_hash': 'secret-value', 'nested': {'apiSecret': 'also-secret'}})
        self.insert('safe-op', payload)
        self.records.changed()
        self.assertEqual(len(self.output), 1)
        self.assertNotIn('secret-value', self.output[0])
        self.assertNotIn('also-secret', self.output[0])
        self.assertIn('[redacted]', self.output[0])


class ActivityRecordTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.path = Path(self.temp.name) / 'activity.jsonl'
        self.output = []
        self.records = record_notifications.ActivityRecords(self.path, self.output.append)

    def test_partial_line_waits_and_multiple_lines_drain(self):
        self.path.write_bytes(b'{"id":"partial"')
        self.records.changed()
        self.assertEqual(self.output, [])
        with self.path.open('ab') as stream:
            stream.write(b'}\n{"id":"second"}\n{"id":"third"}\n')
        self.records.changed()
        self.records.changed()
        self.assertEqual(len(self.output), 3)
        self.assertIn('partial', self.output[0])
        self.assertIn('second', self.output[1])
        self.assertIn('third', self.output[2])

    def test_file_replacement_drains_new_file_from_start(self):
        self.path.write_text('{"id":"old"}\n', encoding='utf-8')
        self.records.changed()
        replacement = self.path.with_suffix('.new')
        replacement.write_text('{"id":"replacement"}\n{"id":"replacement-2"}\n', encoding='utf-8')
        replacement.replace(self.path)
        self.records.changed()
        self.assertEqual(len(self.output), 3)
        self.assertIn('replacement', self.output[1])
        self.assertIn('replacement-2', self.output[2])


class CliNotificationHttpTests(unittest.TestCase):
    """CLI mutations reach the notification CLI through an isolated local HTTP server."""

    def setUp(self):
        import activity
        import approvals
        import record_notifications
        import serve
        import studio_store

        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        (self.root / 'Activity').mkdir()
        self.db = self.root / 'approvals.sqlite3'
        self.activity_file = self.root / 'Activity' / 'events.jsonl'
        self.store = studio_store.Store(self.db, self.root)
        self.store.set_senders(['Astra', 'Luna'], 'Astra')

        self.patches = [
            mock.patch.object(approvals, 'DATABASE', self.db),
            mock.patch.object(activity, 'EVENTS', self.activity_file),
            mock.patch.object(serve.studio_store, 'Store', lambda *args, **kwargs: self.store),
        ]
        for patcher in self.patches:
            patcher.start()
            self.addCleanup(patcher.stop)

        class QuietHandler(serve.Handler):
            def log_message(self, *args):
                pass

        self.server = ThreadingHTTPServer(('127.0.0.1', 0), QuietHandler)
        threading.Thread(target=self.server.serve_forever, daemon=True).start()
        self.addCleanup(self.server.server_close)
        self.addCleanup(self.server.shutdown)
        self.origin = f'http://127.0.0.1:{self.server.server_port}'
        self.env = dict(os.environ, REGISTRY_STUDIO_URL=self.origin)
        app = Path(__file__).resolve().parent
        self.app = app
        self.watcher = subprocess.Popen([sys.executable, str(app / 'watch_events.py'), '--url', self.origin],
                                        cwd=app.parent.parent, env=self.env, stdout=subprocess.PIPE,
                                        stderr=subprocess.PIPE, text=True, bufsize=1)
        self.addCleanup(self._stop_watcher)
        self.lines = queue.Queue()
        self.reader = threading.Thread(target=lambda: [self.lines.put(line.rstrip()) for line in self.watcher.stdout], daemon=True)
        self.reader.start()
        self.assertIn('購読中', self.watcher.stderr.readline())
        self.addCleanup(self._stop_observers, record_notifications)

    def _stop_watcher(self):
        if self.watcher.poll() is None:
            self.watcher.terminate()
            self.watcher.wait(timeout=5)
        self.watcher.stdout.close()
        self.watcher.stderr.close()

    @staticmethod
    def _stop_observers(module):
        for observer in list(module._observers):
            observer.close()
        module._observers.clear()

    def cli(self, *args, body=None):
        result = subprocess.run([sys.executable, str(self.app / 'comm.py'), 'letter', *args], cwd=self.app.parent.parent,
                                env=self.env, input=body, capture_output=True, text=True, timeout=10)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        return json.loads(result.stdout)

    def wait_for_event(self, letter_id, name):
        deadline = time.monotonic() + 6
        while time.monotonic() < deadline:
            try:
                line = self.lines.get(timeout=max(.01, deadline - time.monotonic()))
            except queue.Empty:
                break
            if (line.startswith('approvals.sqlite3/letter_events: ') and letter_id in line
                    and f"'event': '{name}'" in line):
                return line
        self.fail(f'No committed {name} notification for {letter_id}')

    def wait_for_line(self, predicate, timeout=6):
        deadline = time.monotonic() + timeout
        while time.monotonic() < deadline:
            try:
                line = self.lines.get(timeout=max(.01, deadline - time.monotonic()))
            except queue.Empty:
                break
            if predicate(line):
                return line
        self.fail('Expected notification was not received')

    def test_external_approval_history_commit_notifies_but_rollback_does_not(self):
        def add_history(con, request_id, marker):
            con.execute('INSERT INTO requests VALUES (?, ?, ?, NULL)',
                        (request_id, json.dumps({'title': marker}), json.dumps({'status': 'pending'})))
            con.execute('INSERT INTO history(request_id, event) VALUES (?, ?)',
                        (request_id, json.dumps({'action': marker})))

        con = sqlite3.connect(self.db)
        try:
            con.execute('BEGIN')
            add_history(con, 'rolled-back-request', 'rolled-back-history-marker')
            con.rollback()
        finally:
            con.close()

        caught = []
        deadline = time.monotonic() + .4
        while time.monotonic() < deadline:
            try:
                caught.append(self.lines.get(timeout=max(.01, deadline - time.monotonic())))
            except queue.Empty:
                break
        self.assertFalse(any('rolled-back-history-marker' in line for line in caught), caught)

        # This separate connection bypasses in-process commit hooks; only the file observer can wake the CLI.
        with sqlite3.connect(self.db) as external:
            external.execute('BEGIN')
            add_history(external, 'committed-request', 'committed-history-marker')
            external.commit()
        notice = self.wait_for_line(lambda line: 'approvals.sqlite3/history:' in line and 'committed-history-marker' in line)
        self.assertIn('committed-request', notice)

    def test_external_activity_file_handle_append_notifies_cli(self):
        row = json.dumps({'id': 'external-activity-row', 'taskId': 'OPS-998', 'event': 'start', 'owner': 'Astra'}) + '\n'
        with self.activity_file.open('ab') as stream:
            stream.write(row.encode('utf-8'))
            stream.flush()
            os.fsync(stream.fileno())
        notice = self.wait_for_line(lambda line: line.startswith('activity: ') and 'external-activity-row' in line)
        self.assertIn('OPS-998', notice)

    def test_cli_send_received_started_returned_are_streamed(self):
        sent = self.cli('send', '--sender', 'Astra', '--recipient', 'Luna', '--task', 'OPS-999', '--body-file', '-', body='request\n')
        letter_id = sent['id']
        self.assertIn("'event': 'sent'", self.wait_for_event(letter_id, 'sent'))
        self.cli('receive', letter_id, '--actor', 'Luna', '--revision', '1')
        self.assertIn("'event': 'received'", self.wait_for_event(letter_id, 'received'))
        self.cli('start', letter_id, '--actor', 'Luna')
        self.assertIn("'event': 'started'", self.wait_for_event(letter_id, 'started'))
        self.cli('return', letter_id, '--actor', 'Luna', '--body-file', '-', body='reply\n')
        self.assertIn("'event': 'returned'", self.wait_for_event(letter_id, 'returned'))


if __name__ == '__main__':
    unittest.main()
