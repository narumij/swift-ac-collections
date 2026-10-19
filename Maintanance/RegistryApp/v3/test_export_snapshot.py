#!/usr/bin/env python3
"""OPS-181 acceptance correction: one export is one read snapshot. A writer (the CLI) committing while an export is
being read must be wholly before or wholly after it: the export never pairs the new revision with old rows (or the
reverse). Deterministic: the writer runs from inside the export, right after its first read (r3.read). Two connections
on a TemporaryDirectory DB, in WAL (a concurrent writer commits) and in the default rollback journal (it waits).

Run: python3 -B Maintanance/RegistryApp/v3/test_export_snapshot.py -v
"""
import hashlib
import sqlite3
import sys
import unittest
from pathlib import Path
from unittest import mock

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
sys.path.insert(0, str(HERE.parent))
import registry_v3_write as w3  # noqa: E402
import serve  # noqa: E402
import studio_adapter as sa  # noqa: E402
from test_studio_adapter import ACTOR, Studio  # noqa: E402

READ = sa.r3.read


def owner_of(doc, tid='TASK-003'):
    return next(t['owner'] for t in doc['tasks'] if t['id'] == tid)


class Snapshot(Studio):
    def setUp(self):
        super().setUp()
        self.path = self.dir / 'db.sqlite3'

    def write_during_read(self, writer, outcome):
        def read(conn, scope):
            view = READ(conn, scope)
            try:  # the CLI's commit, between the export's first read and its generation/revision reads
                outcome['result'] = w3.apply(writer, 'cli-1', {'kind': 'update_task', 'id': 'TASK-003', 'base': {'owner': '担当C'}, 'changes': {'owner': '担当NEW'},
                                                               'generation': w3.generation(writer), 'actor': ACTOR, 'evidence': []})
            except sqlite3.OperationalError as error:
                outcome['error'] = str(error)
            return view
        return mock.patch.object(sa.r3, 'read', side_effect=read)

    def consistent(self, doc):
        """(revision, owner) of an export must be one of the two real states."""
        return (doc['source']['revision'], owner_of(doc)) in {(0, '担当C'), (1, '担当NEW')}

    def test_wal_writer_commits_and_the_export_keeps_its_snapshot(self):
        self.conn.execute('PRAGMA journal_mode = WAL')
        reader, writer = self.open(self.path), self.open(self.path)
        outcome = {}
        with self.write_during_read(writer, outcome):
            doc = sa.export_doc(reader)
        self.assertIn('result', outcome, outcome)  # the write did commit meanwhile
        self.assertEqual((doc['source']['revision'], owner_of(doc)), (0, '担当C'), 'the whole export is the state before the commit')
        self.assertTrue(self.consistent(doc))
        self.assertFalse(reader.in_transaction, 'the read transaction is ended')
        after = sa.export_doc(reader)
        self.assertEqual((after['source']['revision'], owner_of(after)), (1, '担当NEW'))

    def test_rollback_journal_writer_waits(self):
        reader, writer = self.open(self.path), sqlite3.connect(self.path, isolation_level=None, timeout=0.2)
        self.addCleanup(writer.close)
        outcome = {}
        with self.write_during_read(writer, outcome):
            doc = sa.export_doc(reader)
        self.assertIn('locked', outcome.get('error', ''), 'the writer cannot commit inside the read snapshot')
        self.assertEqual((doc['source']['revision'], owner_of(doc)), (0, '担当C'))
        self.assertFalse(reader.in_transaction)

    def test_read_only_page_connection(self):
        self.conn.execute('PRAGMA journal_mode = WAL')
        writer = self.open(self.path)
        reader = serve.v3_open(self.path)
        self.addCleanup(reader.close)
        outcome = {}
        with self.write_during_read(writer, outcome):
            doc = sa.export_doc(reader)
        self.assertIn('result', outcome, outcome)
        self.assertTrue(self.consistent(doc))
        self.assertEqual(owner_of(doc), '担当C')
        with self.assertRaises(sqlite3.OperationalError):
            reader.execute('UPDATE db_meta SET generation = generation')

    def test_caller_transaction_is_kept_and_errors_clean_up(self):
        self.conn.execute('BEGIN')
        sa.export_doc(self.conn)
        self.assertTrue(self.conn.in_transaction, "a caller's transaction is left as it was")
        self.conn.execute('ROLLBACK')
        before = hashlib.sha256(self.path.read_bytes()).hexdigest()
        with mock.patch.object(sa.r3, 'read', side_effect=RuntimeError('broken read')), self.assertRaises(RuntimeError):
            sa.export_doc(self.conn)
        self.assertFalse(self.conn.in_transaction, 'ended after an error too')
        self.assertEqual(hashlib.sha256(self.path.read_bytes()).hexdigest(), before, 'an export never changes the DB')


if __name__ == '__main__':
    sys.exit(0 if unittest.main(exit=False, verbosity=2 if '-v' in sys.argv else 1).result.wasSuccessful() else 1)
