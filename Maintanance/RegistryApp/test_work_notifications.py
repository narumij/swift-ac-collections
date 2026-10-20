"""Change notifications: external activity writes and committed approval mutations."""
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch
import approvals
from work_notifications import Changes, FileObserver

class WorkNotificationsTests(unittest.TestCase):
    def test_external_file_changes(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / 'events.jsonl'
            changes = Changes()
            observer = FileObserver(path, changes)
            try:
                revision = changes.wait(None, 0)
                path.write_text('created\n')
                self.assertGreater(changes.wait(revision, 2), revision)
                # Settle any directory event before testing the next independent write.
                import time
                time.sleep(.05)
                revision = changes.wait(None, 0)
                with path.open('a') as stream:
                    stream.write('appended\n')
                self.assertGreater(changes.wait(revision, 2), revision)
                time.sleep(.05)
                replacement = path.with_suffix('.new')
                replacement.write_text('replacement\n')
                time.sleep(.05)
                revision = changes.wait(None, 0)
                replacement.replace(path)
                self.assertGreater(changes.wait(revision, 2), revision)
            finally:
                observer.close()

    def test_only_committed_history_notifies(self):
        with tempfile.TemporaryDirectory() as directory:
            store = approvals.Store(Path(directory) / 'approvals.sqlite3', Path(directory).resolve())
            changes = Changes()
            with patch.object(approvals.work_notifications, 'approval_changes', changes):
                card = dict(taskId='OPS-1', title='test', scope='test', paths=['test.txt'], condition='test', branch='test')
                row = store.add(card)
                self.assertEqual(changes.wait(None, 0), 1)
                with store.transaction() as con:
                    self.assertEqual(con.execute('SELECT count(*) FROM history').fetchone()[0], 1)
                self.assertEqual(changes.wait(None, 0), 1)
                with self.assertRaises(RuntimeError):
                    with store.transaction() as con:
                        con.execute('INSERT INTO history(request_id,event) VALUES (?,?)', (row['id'], '{}'))
                        raise RuntimeError('rollback')
                self.assertEqual(changes.wait(None, 0), 1)
                with store.transaction() as con:
                    con.execute('INSERT INTO history(request_id,event) VALUES (?,?)', (row['id'], '{}'))
                self.assertEqual(changes.wait(None, 0), 2)

if __name__ == '__main__':
    unittest.main()
