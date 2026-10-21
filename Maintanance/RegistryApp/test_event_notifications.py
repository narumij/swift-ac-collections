import unittest
from unittest.mock import patch

from event_notifications import Notifications, events
import communication_notifications as communication
import work_notifications as work


class EventNotificationsTests(unittest.TestCase):
    def test_subscribe_disconnect_and_no_replay(self):
        notifications = Notifications()
        received = []
        notifications.send('before subscription')
        notifications.connect(received.append)
        notifications.connect(received.append)
        notifications.send('hello')
        notifications.disconnect(received.append)
        notifications.send('after disconnect')
        self.assertEqual(received, ['hello'])

    def test_failed_listener_does_not_block_others(self):
        notifications = Notifications()
        received = []
        def fail(text):
            raise ValueError('listener failed')
        notifications.connect(fail)
        notifications.connect(received.append)
        with self.assertLogs(level='ERROR'):
            notifications.send('hello')
        self.assertEqual(received, ['hello'])

    def test_communication_sources_reach_shared_receiver(self):
        received = []
        events.connect(received.append)
        self.addCleanup(events.disconnect, received.append)
        # Isolate existing member-state subscribers; exercise the real source signals.
        for name in ('waiting_started', 'waiting_ended', 'letter_received', 'communication_activity'):
            signal = getattr(communication, name)
            with patch.object(signal, '_listeners', []):
                signal.send(owner='fixture-member')
        self.assertEqual(len(received), 4)
        for text, name in zip(received, ('waiting_started', 'waiting_ended', 'letter_received', 'communication_activity')):
            self.assertTrue(text.startswith(name + ': '))
            self.assertIn('owner=fixture-member', text)
            self.assertIn('at=', text)

    def test_work_sources_keep_revision_notification(self):
        received = []
        events.connect(received.append)
        self.addCleanup(events.disconnect, received.append)
        for name in ('activity_changes', 'approval_changes', 'letter_changes', 'registry_changes'):
            changes = getattr(work, name)
            before = changes.wait(-1, timeout=0)
            changes.changed()
            self.assertEqual(changes.wait(before, timeout=0), before + 1)
        self.assertEqual(received, ['activity_changes', 'approval_changes', 'letter_changes', 'registry_changes'])


if __name__ == '__main__':
    unittest.main()
