import tempfile
import unittest
from pathlib import Path
from notification_log import TextLog

class NotificationHistoryTests(unittest.TestCase):
    def test_tail_live_resume_and_bounds(self):
        with tempfile.TemporaryDirectory() as folder:
            log = TextLog(Path(folder) / 'events.log')
            received = []
            listener = lambda cursor, text: received.append((cursor, text))
            for i in range(120): log.receive(f'通知{i}')
            first = log.follow(listener)
            self.assertTrue(first['reset'])
            self.assertEqual(first['entries'], [f'通知{i}' for i in range(20, 120)])
            log.receive('new')
            self.assertEqual(received[0][1], 'new')
            log.unfollow(listener)
            log.receive('offline')
            resumed = log.follow(listener, received[0][0])
            self.assertFalse(resumed['reset'])
            self.assertEqual(resumed['entries'], ['offline'])
            log.unfollow(listener)
            self.assertEqual(log.follow(listener, resumed['cursor'])['entries'], [])
            log.unfollow(listener)
            for i in range(600): log.receive(str(i))
            self.assertEqual(log.follow(listener, resumed['cursor'])['entries'], [str(i) for i in range(100,600)])

    def test_replacement_and_invalid_cursor(self):
        with tempfile.TemporaryDirectory() as folder:
            path = Path(folder) / 'events.log'
            log = TextLog(path)
            listener = lambda *args: None
            log.receive('old')
            first = log.follow(listener)
            log.unfollow(listener)
            replacement = path.with_suffix('.new')
            replacement.write_text('replacement\n')
            replacement.replace(path)
            value = log.follow(listener, first['cursor'])
            self.assertTrue(value['reset'])
            self.assertEqual(value['entries'], ['replacement'])
            log.unfollow(listener)
            self.assertTrue(log.follow(listener, 'invalid')['reset'])
