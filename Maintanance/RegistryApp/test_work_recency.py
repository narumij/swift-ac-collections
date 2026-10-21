"""Recency comes from persisted, effective recipient work in the existing letters DB."""
import json
import tempfile
import threading
import unittest
import urllib.error
import urllib.request
import uuid
from pathlib import Path
from http.server import ThreadingHTTPServer

import serve
import studio_store
from work_state import WorkState
from test_work_state import event


class WorkRecencyTests(unittest.TestCase):
    def test_letter_lifecycle_is_the_only_work_time_source(self):
        with tempfile.TemporaryDirectory() as folder:
            store = studio_store.Store(Path(folder) / 'comm.sqlite3', folder)
            store.set_senders(['Astra'], 'fixture')
            model = WorkState()
            model.update_activity([event(1, 'T-99', kind='work')])
            self.assertEqual(model.snapshot()['recentTasks'], [], 'independent activity timestamps are not another entry route')
            sent = store.send(uuid.uuid4().hex, 'Astra', 'Luna', 'T-1', 'actual assignment')
            model.update_letters(store.work_snapshot())
            self.assertEqual(model.snapshot()['recentTasks'], [], 'sending is not work')
            store.event(uuid.uuid4().hex, sent['id'], 'received', 'Luna', revision=1)
            model.update_letters(store.work_snapshot())
            self.assertEqual(model.snapshot()['recentTasks'], [], 'receipt is not work')
            store.event(uuid.uuid4().hex, sent['id'], 'started', 'Luna')
            started = model.update_letters(store.work_snapshot())['recentTasks']
            self.assertEqual(started[0]['taskId'], 'T-1')
            self.assertEqual(started[0]['letterId'], sent['id'])
            self.assertEqual(started[0]['workedAt'], store.work_snapshot()['latestWork'][0]['received_at'])
            store.event(uuid.uuid4().hex, sent['id'], 'returned', 'Luna', body='work result')
            latest = model.update_letters(store.work_snapshot())['recentTasks']
            self.assertEqual(len(latest), 1)
            self.assertGreaterEqual(latest[0]['workedAt'], started[0]['workedAt'])
            fresh = WorkState().update_letters(studio_store.Store(Path(folder) / 'comm.sqlite3', folder).work_snapshot())
            self.assertEqual(fresh['recentTasks'], latest, 'restart rebuilds the same latest time from the DB')

    def test_latest_work_survives_more_than_200_timeline_events(self):
        with tempfile.TemporaryDirectory() as folder:
            store = studio_store.Store(Path(folder) / 'comm.sqlite3', folder)
            store.set_senders(['Astra'], 'fixture')
            for i in range(105):
                sent = store.send(uuid.uuid4().hex, 'Astra', 'Luna', f'T-{i}', 'fixture assignment')
                store.event(uuid.uuid4().hex, sent['id'], 'received', 'Luna', revision=1)
                store.event(uuid.uuid4().hex, sent['id'], 'started', 'Luna')
            data = store.work_snapshot()
            self.assertEqual(len(data['events']), 200)
            self.assertFalse(any(row['task_id'] == 'T-0' for row in data['events']))
            self.assertEqual(len(data['latestWork']), 105)
            model = WorkState().update_letters(data)
            self.assertIn('T-0', [row['taskId'] for row in model['recentTasks']])
            rebuilt = WorkState().update_letters(store.work_snapshot())
            self.assertEqual(rebuilt['recentTasks'], model['recentTasks'])

    def test_removed_work_time_api_does_not_accept_get_or_post(self):
        server = ThreadingHTTPServer(('127.0.0.1', 0), serve.Handler)
        worker = threading.Thread(target=server.serve_forever, daemon=True)
        worker.start()
        try:
            for method in ['GET', 'POST']:
                request = urllib.request.Request(f'http://127.0.0.1:{server.server_port}/task-work-times', method=method)
                with self.assertRaises(urllib.error.HTTPError) as error:
                    urllib.request.urlopen(request, timeout=3)
                self.assertEqual(error.exception.code, 404)
                error.exception.close()
        finally:
            server.shutdown()
            server.server_close()
            worker.join()
