import json
import sys
import tempfile
import unittest
import uuid
from pathlib import Path
from unittest.mock import patch
import task_status_command as command
sys.path.insert(0, str(Path(__file__).parent / 'v3'))
import registry_v3_write as writer

class StateCommandTest(unittest.TestCase):
    def test_write_replay_conflict_and_validation(self):
        with tempfile.TemporaryDirectory() as folder:
            root = Path(folder)
            db = root / 'db.sqlite3'
            fixture = json.loads((Path(__file__).parent / 'v3/fixtures/base.json').read_text())
            writer.create(db, fixture)
            conn = writer.open_db(db)
            task, initial = conn.execute('select id,state from tasks limit 1').fetchone()
            generation = writer.generation(conn)
            body = dict(taskId=task, baseState=initial, state='WAITING_EXTERNAL', generation=generation, operationId=str(uuid.uuid4()))
            with patch('registry_v3_views.replace_in_place'), patch.object(command.events, 'send') as notify:
                self.assertEqual(command.change(db, root, root/'backups', body)[0], 200)
                self.assertEqual(notify.call_count, 1)
                self.assertIn(task, notify.call_args.args[0])
                self.assertIn(initial + ' → WAITING_EXTERNAL', notify.call_args.args[0])
                self.assertEqual(conn.execute('select state from tasks where id=?',(task,)).fetchone()[0], 'WAITING_EXTERNAL')
                self.assertEqual(command.change(db, root, root/'backups', body)[0], 200)
                self.assertEqual(command.change(db, root, root/'backups', dict(body, operationId=str(uuid.uuid4()), state='DONE'))[0], 409)
                self.assertEqual(conn.execute('select state from tasks where id=?',(task,)).fetchone()[0], 'WAITING_EXTERNAL')
                self.assertEqual(notify.call_count, 1, 'replays and conflicts must not notify')
                self.assertEqual(command.change(db, root, root/'backups', dict(body, operationId=str(uuid.uuid4()), baseState='WAITING_EXTERNAL'))[0],200)
                self.assertEqual(notify.call_count, 1, 'same state is not a change')
                with self.assertRaises(ValueError): command.change(db, root, root/'backups', dict(body, state='INVALID'))
                with patch('registry_v3_views.replace_in_place', side_effect=OSError('fixture')):
                    status, result = command.change(db, root, root/'backups', dict(body, operationId=str(uuid.uuid4()), baseState='WAITING_EXTERNAL', state='DONE'))
                    self.assertEqual(status,200)
                    self.assertIn('保存済み',result['warning'])
                    self.assertEqual(notify.call_count,2, 'committed changes notify even when document generation fails')
            conn.close()
            self.assertTrue(list((root/'backups').glob('*-after.sqlite3')))

if __name__ == '__main__': unittest.main()
