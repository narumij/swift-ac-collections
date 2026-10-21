import json
import tempfile
import threading
import unittest
import urllib.request
import uuid
from datetime import datetime, timezone
from http.server import ThreadingHTTPServer
from pathlib import Path
from unittest.mock import patch

import communication_notifications as notifications
import member_state
import serve
import studio_store
from member_state import MemberState


class MemberLetterReceiptTest(unittest.TestCase):
    def test_http_receipt_updates_member_snapshot(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            store = studio_store.Store(root / 'letters.sqlite3', root)
            store.set_senders(['Sender', 'A'], 'Sender')
            letter = store.send(uuid.uuid4().hex, 'Sender', 'A', 'OPS-202', 'A request')

            state = MemberState([], ['A'])
            state.connect_notifications()
            self.addCleanup(notifications.waiting_started.disconnect, state.on_waiting_started)
            self.addCleanup(notifications.waiting_ended.disconnect, state.on_waiting_ended)
            self.addCleanup(notifications.letter_received.disconnect, state.on_letter_received)
            original_members = member_state.members
            member_state.members = state
            self.addCleanup(setattr, member_state, 'members', original_members)

            server = ThreadingHTTPServer(('127.0.0.1', 0), serve.Handler)
            threading.Thread(target=server.serve_forever, daemon=True).start()
            self.addCleanup(server.server_close)
            self.addCleanup(server.shutdown)
            base = f'http://127.0.0.1:{server.server_port}'

            fixed_datetime = patch.object(notifications, 'datetime')
            clock = fixed_datetime.start()
            self.addCleanup(fixed_datetime.stop)
            clock.now.return_value = datetime(2026, 10, 20, 16, 23, tzinfo=timezone.utc)

            store_patch = patch.object(studio_store, 'Store', return_value=store)
            store_patch.start()
            self.addCleanup(store_patch.stop)

            before = state.snapshot()
            body = {'operationId': uuid.uuid4().hex, 'letterId': letter['id'],
                    'event': 'received', 'actor': 'A', 'revision': 1}
            request = urllib.request.Request(base + '/letters-event', data=json.dumps(body).encode(),
                headers={'Origin': base, 'Content-Type': 'application/json',
                         'X-Registry-Studio': 'letters-event'})
            with urllib.request.urlopen(request, timeout=3) as response:
                result = json.load(response)
                self.assertEqual(response.status, 200)
            self.assertTrue(result['effective'])
            with urllib.request.urlopen(base + '/members', timeout=3) as response:
                snapshot = json.load(response)

            self.assertGreater(snapshot['revision'], before['revision'])
            self.assertEqual(snapshot['members'], [{'owner': 'A', 'planned': True, 'attendance': 'present'}])
            self.assertEqual(snapshot['memberInfo'], {'A': '受領 01:23'})


if __name__ == '__main__':
    unittest.main()
