import unittest
from datetime import datetime, timezone
from unittest.mock import patch

import communication_notifications as notifications
from member_state import MemberState


class MemberStateNotificationsTest(unittest.TestCase):
    def setUp(self):
        self.state = MemberState([], ['A'])
        self.state.connect_notifications()
        for signal, listener in (
            (notifications.waiting_started, self.state.on_waiting_started),
            (notifications.waiting_ended, self.state.on_waiting_ended),
            (notifications.letter_received, self.state.on_letter_received),
            (notifications.communication_activity, self.state.on_communication_activity),
        ):
            self.addCleanup(signal.disconnect, listener)
        self.addCleanup(self.state.clear)
        clock = patch.object(notifications, 'datetime').start()
        self.addCleanup(patch.stopall)
        clock.now.return_value = datetime(2026, 10, 20, 16, 23, tzinfo=timezone.utc)
        self.timer = patch('member_state.Timer').start()

    def test_each_notification_updates_label_and_japan_time(self):
        for signal, label in (
            (notifications.waiting_started, '待機開始'),
            (notifications.waiting_ended, '待機終了'),
            (notifications.letter_received, '受領'),
        ):
            with self.subTest(label=label):
                revision = self.state.snapshot()['revision']
                signal.send(owner='A')
                snapshot = self.state.wait(revision, timeout=0)
                self.assertGreater(snapshot['revision'], revision)
                self.assertEqual(snapshot['memberInfo'], {'A': f'{label} 01:23'})
                self.assertEqual(snapshot['plannedMembers'], ['A'])

    def test_wait_end_delays_departure_and_retains_planned_information(self):
        notifications.waiting_started.send(owner='A')
        notifications.waiting_ended.send(owner='A')
        self.assertEqual(len(self.state.snapshot()['actualMembers']), 1)
        self.assertEqual(self.timer.call_args.args[0], 30)
        self.timer.call_args.args[1]()
        snapshot = self.state.snapshot()
        self.assertEqual(snapshot['actualMembers'], [])
        self.assertEqual(snapshot['memberInfo'], {'A': '待機終了 01:23'})

    def test_receipt_cancels_pending_departure(self):
        notifications.waiting_started.send(owner='A')
        notifications.waiting_ended.send(owner='A')
        expire = self.timer.call_args.args[1]
        notifications.letter_received.send(owner='A')
        expire()
        self.assertEqual(len(self.state.snapshot()['actualMembers']), 1)
        self.assertEqual(self.state.snapshot()['memberInfo']['A'], '受領 01:23')

    def test_activity_cancels_departure_and_updates_information(self):
        notifications.waiting_started.send(owner='A')
        notifications.waiting_ended.send(owner='A')
        expire = self.timer.call_args.args[1]
        notifications.communication_activity.send(owner='A', label='発言')
        expire()
        self.assertEqual(len(self.state.snapshot()['actualMembers']), 1)
        self.assertEqual(self.state.snapshot()['memberInfo']['A'], '発言 01:23')

    def test_unplanned_attendance_gets_information_then_departure_removes_it(self):
        notifications.waiting_started.send(owner=' B ')
        self.assertEqual(self.state.snapshot()['memberInfo']['B'], '待機開始 01:23')
        self.state.leave('B')
        self.assertNotIn('B', self.state.snapshot()['memberInfo'])
        self.assertEqual(self.state.snapshot()['plannedMembers'], ['A'])

    def test_unknown_wait_end_does_not_create_card_or_information(self):
        before = self.state.snapshot()
        notifications.waiting_ended.send(owner='Unknown')
        self.timer.call_args.args[1]()
        self.assertEqual(self.state.snapshot(), before)

    def test_nameless_notifications_do_not_change_state(self):
        before = self.state.snapshot()
        for signal in (notifications.waiting_started, notifications.waiting_ended, notifications.letter_received):
            signal.send(owner=None)
        self.assertEqual(self.state.snapshot(), before)


if __name__ == '__main__':
    unittest.main()
