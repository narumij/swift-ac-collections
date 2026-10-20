"""Communication records feed recent work, without inventing completion."""
import unittest
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
        self.assertEqual(started['timeline']['cards'], [])
        returned = model.update_letters([letter(1, 'started'), letter(2, 'returned', '2026-10-19T05:00:04Z')])
        card = returned['cards']['cards'][0]
        self.assertEqual(card['lines'][0], 'T-1 · 返却・受入待ち')
        self.assertEqual(card['lines'][1], '次：Astra')
        self.assertNotEqual(card['next'], 'ended')
        self.assertIn('連絡DB：LTR-TEST', card['title'])
        self.assertEqual(model.update_letters([letter(1, 'started'), letter(2, 'returned', '2026-10-19T05:00:04Z')])['revision'], returned['revision'])

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

if __name__ == '__main__':
    unittest.main()
