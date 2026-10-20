import json
import os
import subprocess
import tempfile
import threading
import time
import urllib.parse
import urllib.request
import unittest
import uuid
from http.server import ThreadingHTTPServer
from pathlib import Path
from unittest.mock import patch

import serve
from task_rounds import TaskRoundStore


class RoundWatchNoticeTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.store = TaskRoundStore(Path(self.tmp.name) / 'db')
        self.store.set_senders(['Astra', 'Luna', 'Other', 'User'], 'User')
        self.anchor = self.store.send(uuid.uuid4().hex, 'Astra', 'Luna', 'OPS-197', 'anchor',
                                      ref_doc='Maintanance/Current/THREAD_ROUND_FIXTURE.md', ref_section='依頼')['id']
        self.round = self.store.act({'action': 'create', 'actor': 'Astra', 'operationId': uuid.uuid4().hex,
                                     'letter': self.anchor, 'members': ['Astra', 'Luna']})['id']
        self.server = ThreadingHTTPServer(('127.0.0.1', 0), serve.Handler)
        self.url = f'http://127.0.0.1:{self.server.server_port}'
        self.env = dict(os.environ, REGISTRY_STUDIO_URL=self.url)
        self.store_patch = patch('task_rounds.TaskRoundStore', return_value=self.store)
        self.store_patch.start()
        self.thread = threading.Thread(target=self.server.serve_forever, daemon=True)
        self.thread.start()

    def tearDown(self):
        self.server.shutdown()
        self.server.server_close()
        self.thread.join()
        self.store_patch.stop()
        self.tmp.cleanup()

    def watch(self, *, owner=None, inbox_context=None, after=None, wait=0):
        query = {'round': self.round, 'after': after or self.store.show_round(self.round)['context'], 'wait': str(wait)}
        if owner is not None:
            query['owner'] = owner
        if inbox_context is not None:
            query['inboxAfter'] = inbox_context
        with urllib.request.urlopen(self.url + '/letter-turns?' + urllib.parse.urlencode(query), timeout=wait + 3) as response:
            return json.loads(response.read())

    def counts(self):
        with self.store.transaction() as con:
            return {table: con.execute(f'SELECT COUNT(*) FROM {table}').fetchone()[0]
                    for table in ('operations', 'messages', 'acks', 'letters', 'letter_texts', 'letter_events',
                                  'letter_links', 'letter_doc_records', 'letter_doc_snapshots', 'trial_anchors',
                                  'trial_rounds', 'trial_turns', 'trial_members', 'trial_next', 'trial_skip_policy')}

    def test_other_recipient_does_not_change_named_owner_context(self):
        before = self.store.inbox_notice_context('Luna')
        self.store.send(uuid.uuid4().hex, 'Astra', 'Other', 'OPS-197', 'not for Luna')
        result = self.watch(owner='Luna', inbox_context=before)
        self.assertFalse(result['ownerInboxChanged'])
        self.assertEqual(result['ownerInboxContext'], before)

    def test_new_incoming_letter_wakes_without_mutating_round_or_letters(self):
        before = self.store.inbox_notice_context('Luna')
        old_round_context = self.store.show_round(self.round)['context']
        self.store.send(uuid.uuid4().hex, 'Astra', 'Luna', 'OPS-197', 'new incoming')
        counts_after_send = self.counts()
        result = self.watch(owner='Luna', inbox_context=before, after=old_round_context, wait=2)
        self.assertTrue(result['ownerInboxChanged'])
        self.assertNotEqual(result['ownerInboxContext'], before)
        self.assertEqual(result['context'], old_round_context)
        self.assertEqual(result['turn'], 0)
        self.assertEqual(self.counts(), counts_after_send)

    def test_withdrawal_and_request_revision_change_owner_context(self):
        pause = self.store.send(uuid.uuid4().hex, 'Astra', 'Luna', 'OPS-197', 'separate pause request')['id']
        before = self.store.inbox_notice_context('Luna')
        round_context = self.store.show_round(self.round)['context']
        self.store.event(uuid.uuid4().hex, pause, 'withdrawn', 'Astra', note='pause request')
        withdrawn = self.store.inbox_notice_context('Luna')
        self.assertNotEqual(withdrawn, before)
        result = self.watch(owner='Luna', inbox_context=before, after=round_context)
        self.assertTrue(result['ownerInboxChanged'])
        self.assertEqual(result['ownerInboxContext'], withdrawn)
        self.assertEqual(result['context'], round_context)

        revised_request = self.store.send(uuid.uuid4().hex, 'Astra', 'Luna', 'OPS-197', 'separate revision request')['id']
        after_stop = self.store.inbox_notice_context('Luna')
        self.store.revise(uuid.uuid4().hex, revised_request, 'request', 'Astra', 'revised request', 'correction')
        revised = self.store.inbox_notice_context('Luna')
        self.assertNotEqual(revised, after_stop)
        result = self.watch(owner='Luna', inbox_context=after_stop, after=round_context)
        self.assertTrue(result['ownerInboxChanged'])
        self.assertEqual(result['ownerInboxContext'], revised)
        self.assertEqual(result['context'], round_context)

    def test_first_call_baselines_existing_letters_and_retained_cursor_does_not_repeat(self):
        self.store.send(uuid.uuid4().hex, 'Astra', 'Luna', 'OPS-197', 'already present')
        first = self.watch(owner='Luna', wait=0.15)
        self.assertFalse(first['ownerInboxChanged'])
        result = {}
        waiter = threading.Thread(target=lambda: result.setdefault('watch', self.watch(owner='Luna', wait=2)))
        waiter.start()
        time.sleep(0.15)
        self.store.send(uuid.uuid4().hex, 'Astra', 'Luna', 'OPS-197', 'arrived after baseline')
        waiter.join(3)
        self.assertFalse(waiter.is_alive())
        changed = result['watch']
        self.assertTrue(changed['ownerInboxChanged'])
        self.assertNotEqual(changed['ownerInboxContext'], first['ownerInboxContext'])
        second = self.watch(owner='Luna', inbox_context=changed['ownerInboxContext'], wait=0.15)
        self.assertFalse(second['ownerInboxChanged'])
        self.assertEqual(second['ownerInboxContext'], changed['ownerInboxContext'])

    def test_cli_accepts_and_returns_the_separate_inbox_cursor(self):
        snapshot = self.store.show_round(self.round)
        command = ['python3', '-B', str(Path(__file__).with_name('comm.py')), 'letter', 'turns', 'watch', self.round,
                   '--context', snapshot['context'], '--wait', '0', '--owner', 'Luna']
        first = subprocess.run(command, env=self.env, capture_output=True, text=True)
        self.assertEqual(first.returncode, 0, first.stderr)
        first_result = json.loads(first.stdout)
        self.assertFalse(first_result['ownerInboxChanged'])
        command += ['--inbox-context', first_result['ownerInboxContext']]
        second = subprocess.run(command, env=self.env, capture_output=True, text=True)
        self.assertEqual(second.returncode, 0, second.stderr)
        self.assertEqual(json.loads(second.stdout)['ownerInboxContext'], first_result['ownerInboxContext'])

    def test_anchor_withdrawal_still_wakes_legacy_round_watch(self):
        before = self.store.show_round(self.round)['context']
        self.store.event(uuid.uuid4().hex, self.anchor, 'withdrawn', 'Astra', note='stop round')
        result = self.watch(after=before, wait=2)
        self.assertTrue(result['blocked'])
        self.assertNotEqual(result['context'], before)
        self.assertNotIn('ownerInboxContext', result)


if __name__ == '__main__':
    unittest.main()
