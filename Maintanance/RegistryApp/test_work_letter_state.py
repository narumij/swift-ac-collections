"""Communication records feed recent work, without inventing completion."""
import unittest
import tempfile
from pathlib import Path
import uuid
import studio_store
from work_state_binding import WorkStateBinding
from work_state import WorkState
from test_work_state import event


def letter(sequence, kind, at='2026-10-19T05:00:03.123456Z'):
    return dict(sequence=sequence, letter_id='LTR-TEST', event=kind, actor='姫',
                received_at=at, task_id='T-1', sender='Astra', recipient='姫')


class WorkLetterStateTests(unittest.TestCase):
    def test_start_and_return_notify_without_activity_duplication(self):
        model = WorkState()
        initial = model.snapshot()['revision']
        started = model.update_letters([letter(1, 'started')])
        self.assertGreater(started['revision'], initial)
        self.assertEqual(started['cards']['cards'][0]['lines'][0], 'T-1 · 作業中')
        self.assertEqual(started['activity'], [])
        self.assertEqual(len(started['timeline']['cards']), 1)
        returned = model.update_letters([letter(1, 'started'), letter(2, 'returned', '2026-10-19T05:00:04Z')])
        card = returned['cards']['cards'][0]
        self.assertEqual(card['lines'][0], 'T-1 · 返却・受入待ち')
        self.assertEqual(card['lines'][1], '次：Astra')
        self.assertNotEqual(card['next'], 'ended')
        self.assertIn('連絡DB：LTR-TEST', card['title'])
        self.assertEqual(model.update_letters([letter(1, 'started'), letter(2, 'returned', '2026-10-19T05:00:04Z')])['revision'], returned['revision'])

    def test_latest_band_uses_both_sources_and_preserves_last_good_on_letter_failure(self):
        model = WorkState()
        self.assertEqual(model.snapshot()['timeline']['current']['heading'], '最新の活動：未登録')
        model.update_activity([event(2, task='T-194', kind='verification')])
        model.update_letters([letter(1, 'started')])
        band = model.snapshot()['timeline']['current']
        self.assertEqual(band['heading'], '最新の活動：T-1 · 姫 · 作業')
        self.assertIn('連絡DB：LTR-TEST', band['detail'])
        failed = model.failure('letters')
        self.assertTrue(failed['failed']['letters'])
        self.assertEqual(failed['timeline']['current'], band)
        recovered = model.update_letters([letter(1, 'started')])
        self.assertFalse(recovered['failed']['letters'])
        activity = model.update_activity([event(5, task='T-194', kind='acceptance')])
        self.assertEqual(activity['timeline']['current']['heading'], '最新の活動：T-194 · 甲 · 受入')
        returned = model.update_letters([letter(1, 'started'), letter(2, 'returned', '2026-10-19T05:00:06Z')])
        self.assertEqual(returned['timeline']['current']['heading'], '最新の活動：T-1 · 姫 · 返却')

    def test_latest_fact_wins_and_failed_read_keeps_last_good(self):
        model = WorkState()
        model.update_activity([event(2, kind='verification')])
        model.update_letters([letter(1, 'started')])
        self.assertEqual(model.snapshot()['cards']['cards'][0]['lines'][0], 'T-1 · 作業中')
        model.update_activity([event(5, kind='acceptance')])
        self.assertEqual(model.snapshot()['cards']['cards'][0]['lines'][0], 'T-1 · 受入済み')
        failed = model.failure('letters')
        self.assertTrue(failed['cards']['stale'])
        self.assertIn('連絡の取得不調', failed['cards']['status'])
        self.assertEqual(failed['cards']['cards'][0]['lines'][0], 'T-1 · 受入済み')
        self.assertFalse(model.update_letters([letter(1, 'started')])['cards']['stale'])

class WorkSourceUpdatesTests(unittest.TestCase):
    def test_registry_update_failure_recovery_without_reordering(self):
        model = WorkState({'T-1': 'ACTIVE'})
        model.update_activity([event(1, reason='着手：開始'), event(2, 'T-2', reason='着手：開始')])
        first = model.snapshot()
        binding = object.__new__(WorkStateBinding)
        binding.model = model
        binding._refresh(lambda: {'T-1': 'DONE', 'T-2': 'ACTIVE'}, model.update_registry, 'registry')
        changed = model.snapshot()
        self.assertGreater(changed['revision'], first['revision'])
        self.assertEqual([c['taskId'] for c in changed['cards']['cards']], ['T-1', 'T-2'])
        self.assertIn('Registry：DONE', changed['cards']['cards'][0]['lines'][3])
        def broken():
            raise OSError('fixture unavailable')
        with self.assertLogs(level='ERROR'):
            binding._refresh(broken, model.update_registry, 'registry')
        failed = model.snapshot()
        self.assertTrue(failed['cards']['stale'])
        self.assertIn('Registryの取得不調', failed['cards']['status'])
        self.assertIn('Registry：DONE', failed['cards']['cards'][0]['lines'][3])
        restored = model.update_registry({'T-1': 'DONE', 'T-2': 'ACTIVE'})
        self.assertFalse(restored['cards']['stale'])
        self.assertEqual(model.update_registry({'T-1': 'DONE', 'T-2': 'ACTIVE'})['revision'], restored['revision'])

    def test_db_request_send_start_return_only_self_effective_request_records(self):
        with tempfile.TemporaryDirectory() as directory:
            store = studio_store.Store(Path(directory) / 'communication.sqlite3', directory)
            store.set_senders(['Astra', 'そる'], 'fixture')
            operation = uuid.uuid4().hex
            sent = store.send(operation, 'Astra', 'そる', 'T-1', '限定依頼')
            model = WorkState()
            value = model.update_letters(store.work_snapshot())
            self.assertEqual(value['cards']['cards'][0]['stage'], '依頼済み')
            self.assertIn('次：そる', value['cards']['cards'][0]['lines'][1])
            self.assertEqual(value['cards']['cards'][0]['startSource'], 'request')
            self.assertEqual(len(value['timeline']['cards']), 1, 'sent requests also reach the latest-activity band')
            store.event(uuid.uuid4().hex, sent['id'], 'received', 'そる', revision=1)
            store.event(uuid.uuid4().hex, sent['id'], 'started', 'そる')
            value = model.update_letters(store.work_snapshot())
            self.assertEqual(value['cards']['cards'][0]['startSource'], 'started')
            start = value['cards']['cards'][0]['startAt']
            store.event(uuid.uuid4().hex, sent['id'], 'returned', 'そる', body='返却')
            # Isolated invalid/proxy and discussion fixtures must not flow into work cards.
            with store.transaction() as con:
                con.execute("INSERT INTO letters VALUES (?,?,?,?,?,?,?)", ('DISCUSSION-FIXTURE', 'discussion', 'Astra', 'そる', 'T-2', operation, '2026-10-22T00:00:00Z'))
                for identity, actor, recorder, effective in [(sent['id'], 'そる', 'Astra', 1), (sent['id'], 'そる', 'そる', 0), ('DISCUSSION-FIXTURE', 'そる', 'そる', 1)]:
                    store._insert_event(con, identity, 'returned', actor, recorder, None, None, '', effective, operation, at='2026-10-22T00:00:00Z')
            self.assertEqual(len(store.work_snapshot()['events']), 3)
            value = model.update_letters(store.work_snapshot())
            card = value['cards']['cards'][0]
            self.assertEqual(card['stage'], '返却・受入待ち')
            self.assertEqual(card['startAt'], start)
            self.assertEqual(len(value['cards']['cards']), 1)
            self.assertEqual(len(value['recentTasks']), 1)
            self.assertEqual(value['recentTasks'][0]['taskId'], 'T-1')
            self.assertEqual(value['recentTasks'][0]['owner'], 'そる')

if __name__ == '__main__':
    unittest.main()
