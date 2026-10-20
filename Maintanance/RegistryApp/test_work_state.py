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
        self.assertEqual(snap['timeline']['current']['heading'], '最新の活動：T-1 · 甲 · 作業')
        self.assertEqual(len(snap['timeline']['cards']), 4, 'timeline retains probe and state notices')
        self.assertEqual(snap['cards']['cards'][0]['stage'], '着手')
        returned = event(5, kind='return', owner='乙', reason='返却', next='調整', presence='waiting')
        snap = model.update_activity([request, started, waiting, probe, returned])
        self.assertEqual(snap['timeline']['current']['heading'], '最新の活動：T-1 · 乙 · 返却')
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

    def test_unified_tasks_prioritize_pending_then_first_start(self):
        model = WorkState()
        records = [event(1, 'T-9', 'request'), event(2, 'T-2', reason='着手：開始'),
                   event(3, 'T-1', 'request'), event(4, 'T-1', reason='着手：開始'),
                   event(8, 'T-2', 'return'), event(9, 'T-1', 'request')]
        model.update_activity(records)
        def approval(identity, task, status='pending'):
            return dict(id=identity, taskId=task, status=status, revision=1, title=identity,
                        scope='purpose', paths=['a'], condition='tested', branch='topic',
                        createdAt='2026-10-19', updatedAt='2026-10-19')
        pending = [approval('a', 'T-1'), approval('b', 'T-1', 'approved'),
                   approval('c', 'T-2'), approval('d', 'T-0'), approval('e', 'T-3', 'claimed'),
                   approval('past', 'T-8', 'consumed'), approval('cancel', 'T-8', 'cancelled')]
        snap = model.update_approvals(pending)
        cards = snap['cards']['cards']
        self.assertEqual([c['taskId'] for c in cards], ['T-2', 'T-1', 'T-0', 'T-9', 'T-3'])
        self.assertEqual([a['id'] for a in cards[1]['approvalEntries']], ['a', 'b'])
        self.assertEqual(cards[0]['startAt'], records[1]['timestamp'])
        self.assertEqual(cards[3]['startSource'], 'request')
        self.assertIn('依頼時刻を代用', cards[3]['lines'][-1])
        self.assertEqual(cards[2]['startSource'], 'unknown')
        self.assertEqual(cards[2]['lines'][-1], '開始：不明')
        # Return, verification and a later start do not reorder or replace first start.
        records += [event(10, 'T-2', 'request'), event(11, 'T-2', reason='着手：再開'), event(12, 'T-2', 'return')]
        snap = model.update_activity(records)
        self.assertEqual([c['taskId'] for c in snap['cards']['cards']], ['T-2', 'T-1', 'T-0', 'T-9', 'T-3'])
        self.assertEqual(snap['cards']['cards'][0]['startAt'], records[1]['timestamp'])
        # The server retains an observed start when it slips out of the bounded read window.
        snap = model.update_activity(records[-3:])
        self.assertEqual(snap['cards']['cards'][0]['startAt'], records[1]['timestamp'])
        # Approval changes only move between priority groups, never use updatedAt for order.
        pending[0]['status'] = 'approved'; pending[2]['status'] = 'approved'
        pending[2]['updatedAt'] = '2026-10-30'
        snap = model.update_approvals(pending)
        self.assertEqual([c['taskId'] for c in snap['cards']['cards']], ['T-0', 'T-2', 'T-1', 'T-3'])
        self.assertEqual(len(snap['cards']['cards'][2]['approvalEntries']), 2)

    def test_letter_start_is_earliest_start_not_return_time(self):
        model = WorkState()
        model.update_activity([event(1, 'T-1', 'request'), event(6, 'T-1', 'request')])
        model.update_letters([dict(sequence=1, letter_id='LTR-TEST', task_id='T-1', actor='甲',
                                   sender='Astra', recipient='甲', event='started', received_at=event(3)['timestamp']),
                              dict(sequence=2, letter_id='LTR-TEST', task_id='T-1', actor='甲',
                                   sender='Astra', recipient='甲', event='returned', received_at=event(8)['timestamp'])])
        card = model.snapshot()['cards']['cards'][0]
        self.assertEqual(card['startSource'], 'started')
        self.assertEqual(datetime.fromisoformat(card['startAt']), BASE + timedelta(seconds=3))
        self.assertEqual(card['stage'], '返却・受入待ち')

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
