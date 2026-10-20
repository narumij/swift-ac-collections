import subprocess
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

from approvals import Store, Conflict, make_draft, run_cli_command
from work_notifications import Changes


class ApprovalDraftTests(unittest.TestCase):
    def test_staged_paths_and_retry_identity(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp).resolve()
            def git(*args):
                return subprocess.run(['git', '-C', str(root), *args], check=True, capture_output=True)
            git('init', '-b', 'test')
            (root / 'chosen.txt').write_text('yes')
            (root / 'unrelated.txt').write_text('no')
            git('add', 'chosen.txt')
            draft = make_draft(root, 'OPS-1', 'Title', 'Scope', 'Condition')
            self.assertEqual(draft['card']['paths'], ['chosen.txt'])
            self.assertEqual(draft['card']['branch'], 'test')
            self.assertEqual(draft['repo'], str(root))
            store = Store(root / 'test.sqlite3', root)
            changes = Changes()
            with patch('approvals.work_notifications.approval_changes', changes):
                body = {'command': 'submit', 'args': draft}
                first = run_cli_command(store, body)
                second = run_cli_command(store, body)
                self.assertEqual(first, second)
                self.assertEqual(changes.wait(None, 0), 1)
                with store.transaction() as con:
                    self.assertEqual(con.execute('SELECT count(*) FROM requests').fetchone()[0], 1)
                    self.assertEqual(con.execute('SELECT count(*) FROM history').fetchone()[0], 1)
                draft['card']['scope'] = 'changed'
                with self.assertRaises(Conflict):
                    run_cli_command(store, body)
                self.assertEqual(changes.wait(None, 0), 1)

    def test_empty_stage_and_wrong_checkout_are_rejected(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp).resolve()
            subprocess.run(['git', '-C', str(root), 'init', '-b', 'test'], check=True, capture_output=True)
            with self.assertRaisesRegex(ValueError, 'No staged changes'):
                make_draft(root, 'OPS-1', 'Title', 'Scope', 'Condition')
            card = dict(taskId='OPS-1', title='Title', scope='Scope', condition='Condition', branch='test', paths=['file'])
            store = Store(root / 'test.sqlite3', root)
            with self.assertRaises(Conflict):
                store.add(card, 'a' * 32, str(root / 'wrong'))
            with store.transaction() as con:
                self.assertEqual(con.execute('SELECT count(*) FROM requests').fetchone()[0], 0)

if __name__ == '__main__':
    unittest.main()
