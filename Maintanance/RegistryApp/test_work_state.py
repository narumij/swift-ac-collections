import unittest
from datetime import datetime, timedelta, timezone

from work_state import WorkState


BASE = datetime(2026, 10, 19, 5, tzinfo=timezone.utc)


def event(number, task='T-1', kind='work', owner='甲', reason='', **extra):
    return {'schemaVersion': 1, 'id': f'{number:032x}', 'taskId': task, 'event': kind,
            'owner': owner, 'reason': reason,
            'timestamp': (BASE + timedelta(seconds=number)).isoformat().replace('+00:00', 'Z'), **extra}


class WorkStateTests(unittest.TestCase):
    def test_observable_revision_and_last_good_on_failure(self):
        model = WorkState({'T-1': '進行中'})
        first = model.update_activity([event(1)])
        self.assertEqual(first['revision'], 1)
        self.assertEqual(first['cards']['cards'][0]['lines'][3], 'Registry：進行中 · 承認なし')
        first['cards']['cards'].clear()
        self.assertEqual(len(model.snapshot()['cards']['cards']), 1, 'snapshots are isolated')
        failed = model.failure('activity')
        self.assertEqual(failed['revision'], 2)
        self.assertTrue(failed['cards']['stale'])
        self.assertIn('活動の取得不調 · 最終情報を保持', failed['cards']['status'])
        self.assertEqual(len(failed['timeline']['cards']), 1)
        self.assertEqual(model.wait(1, 0)['revision'], 2)
        recovered = model.update_activity([event(1)])
        self.assertEqual(recovered['revision'], 3)
        self.assertFalse(recovered['cards']['stale'])
        self.assertEqual(model.update_activity([event(1)])['revision'], 3, 'same good data is not a change')

    def test_confirmed_start_state_notices_probe_and_return(self):
        request = event(1, kind='request', owner='調整', reason='R-20261019-01：依頼', next='甲')
        started = event(2, kind='work', owner='甲', reason='R-20261019-01：着手', presence='working')
        waiting = event(3, kind='work', owner='甲', reason='待機', presence='waiting')
        probe = event(4, kind='work', owner='甲', reason='ACK PING-20261019-A：受信')
        model = WorkState()
        snap = model.update_activity([request, started, waiting, probe])
        self.assertEqual(snap['timeline']['current']['heading'], '現在：T-1 · 甲 · 作業')
        self.assertEqual(len(snap['timeline']['cards']), 4, 'timeline retains probe and state notices')
        self.assertEqual(snap['cards']['cards'][0]['stage'], '着手')
        returned = event(5, kind='return', owner='乙', reason='返却', next='調整', presence='waiting')
        snap = model.update_activity([request, started, waiting, probe, returned])
        self.assertEqual(snap['timeline']['current']['heading'], '現在：T-1 · 乙 · 返却')
        self.assertEqual(snap['cards']['cards'][0]['stage'], '返却・受入待ち')
        self.assertEqual(snap['cards']['cards'][0]['next'], 'known')

    def test_approval_counts_lane_and_status(self):
        model = WorkState({'T-2': '確認中'}, policy_notice='規則')
        def approval(id, status):
            return {'id': id, 'revision': 1, 'taskId': 'T-2', 'title': '確認',
                    'scope': '目的', 'paths': ['a.txt'], 'condition': '受入',
                    'branch': 'topic', 'createdAt': '2026-10-19', 'updatedAt': '2026-10-20',
                    'status': status, 'approvedAt': None, 'commitSha': None}
        approvals = [approval('A', 'pending'), approval('B', 'approved'),
                     approval('C', 'claimed'), approval('D', 'consumed')]
        snap = model.update_approvals(approvals)
        card = snap['cards']['cards'][0]
        self.assertEqual(card['stage'], '活動情報なし')
        self.assertEqual(card['next'], 'approval')
        self.assertIn('承認 待ち1 · 済み1 · 確保1', card['lines'][3])
        self.assertEqual(snap['approvals']['counts'], {'pending': 1, 'approved': 1, 'claimed': 1})
        self.assertEqual(len(snap['approvals']['visible']), 3)
        self.assertEqual(snap['approvals']['visible'][0]['heading'], 'T-2 · 確認')
        self.assertEqual(snap['approvals']['visible'][0]['stateText'], '承認待ち')
        self.assertEqual(snap['approvals']['visible'][0]['detailText'],
                         '依頼：A / revision 1\n\nタスク：T-2 · 確認\n\n状態：承認待ち\n\n目的・範囲：\n目的\n\n'
                         '対象ファイル：\na.txt\n\n受入条件：\n受入\n\nbranch：topic\n\n登録：2026-10-19\n\n'
                         '更新：2026-10-20\n\n承認：未承認\n\n実コミット：未記録')
        self.assertEqual(snap['approvals']['policyNotice'], '規則')
        self.assertIn('🔴 承認待ち 1件', snap['approvals']['status'])
        snap = model.failure('approvals')
        self.assertIn('承認の取得不調', snap['cards']['status'])
        self.assertEqual(len(snap['approvals']['requests']), 4)

    def test_wake_owners_pending_and_exact_ack(self):
        wake = 'WAKE-20261019-Q'
        rows = [event(1, owner='甲'), event(2, owner='乙'),
                event(3, kind='request', owner='ユーザー', reason=wake + '：待機終了依頼', next='甲')]
        model = WorkState()
        snap = model.update_activity(rows)
        self.assertEqual(snap['wake']['owners'], ['乙', '甲'])
        self.assertEqual(snap['wake']['statuses']['甲']['kind'], 'pending')
        self.assertEqual(snap['wake']['statuses']['乙'], {'kind': 'none'})
        rows.append(event(4, owner='甲', reason='ACK ' + wake + 'X：別件'))
        self.assertEqual(model.update_activity(rows)['wake']['statuses']['甲']['kind'], 'pending')
        rows.append(event(5, owner='甲', reason='ACK ' + wake + '：受信', presence='ended'))
        self.assertEqual(model.update_activity(rows)['wake']['statuses']['甲']['kind'], 'acked')


if __name__ == '__main__':
    unittest.main()
