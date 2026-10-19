#!/usr/bin/env python3
"""OPS-164 tests: generation guard, operation history, backup, validation and restore into a new generation.
Cases follow TASK_REGISTRY_V3_RECOVERY_EXPERIMENT.md「受入と範囲」. Each test owns a TemporaryDirectory and closes every
connection it opens. Expected values are written by hand.

Run: python3 -B Maintanance/RegistryApp/v3/test_registry_v3_recovery.py -v
"""
import copy
import json
import sys
import tempfile
import unittest
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
import hermetic  # noqa: E402,F401  (first: temporary roots for every live path, OPS-167 K9)
import registry_v3_recovery as rc  # noqa: E402
import registry_v3_write as w3  # noqa: E402

BASE = json.loads((HERE / 'fixtures' / 'base.json').read_text(encoding='utf-8'))
NEW = {'state': 'PROPOSED', 'owner': '担当F', 'item': '新しい仕事', 'condition': '着手の条件', 'detail': 'Maintanance/Current/新規.md'}
ACTOR, EVIDENCE = '姫（試験）', ['TASK_REGISTRY_V3_RECOVERY_EXPERIMENT.md#試行契約']


def request(conn, **r):
    return dict({'actor': ACTOR, 'evidence': EVIDENCE}, **r, generation=w3.generation(conn))


class Recovery(unittest.TestCase):
    def setUp(self):
        tmp = tempfile.TemporaryDirectory()
        self.addCleanup(tmp.cleanup)
        self.dir = Path(tmp.name)
        self.path = self.dir / 'origin.sqlite3'
        w3.create(str(self.path), copy.deepcopy(BASE))
        self.conn = self.open(self.path)
        self.gen = w3.generation(self.conn)
        w3.apply(self.conn, 'op-1', request(self.conn, kind='register_task', prefix='TASK', fields=NEW))  # TASK-006
        w3.apply(self.conn, 'op-2', request(self.conn, kind='update_task', id='TASK-003', base={'owner': '担当C'}, changes={'owner': '担当X'}))

    def open(self, path):
        conn = w3.open_db(str(path))
        self.addCleanup(conn.close)
        return conn

    def snapshot(self, conn):
        return {t: conn.execute(f'SELECT * FROM {t} ORDER BY 1').fetchall() for t in
                ('nodes', 'tasks', 'graph_edges', 'id_allocations', 'issued_ids', 'retirements', 'operations', 'revisions', 'db_meta', 'lineage')}

    def backed_up(self):
        backup = self.dir / 'backup-1.sqlite3'
        return backup, rc.backup(self.conn, backup)

    def restored(self, name='restored.sqlite3'):
        backup, _ = self.backed_up() if not (self.dir / 'backup-1.sqlite3').exists() else (self.dir / 'backup-1.sqlite3', None)
        info = rc.restore(backup, self.dir / name, ACTOR, EVIDENCE)
        return self.open(self.dir / name), info


class BackupAndRestore(Recovery):
    def test_normal_backup_validate_restore(self):
        backup, manifest = self.backed_up()
        self.assertEqual({k: manifest[k] for k in ('schemaVersion', 'generation', 'revision', 'file')}, {'schemaVersion': 1, 'generation': self.gen, 'revision': 2, 'file': 'backup-1.sqlite3'})
        self.assertEqual(rc.validate(backup), manifest)
        new, info = self.restored()
        self.assertNotEqual(info['generation'], self.gen)
        self.assertEqual((info['fromGeneration'], info['fromRevision']), (self.gen, 2))
        self.assertEqual(w3.generation(new), info['generation'])
        self.assertFalse(w3.write_enabled(new), 'a restored generation starts with writes closed')
        events = rc.lineage(new)
        self.assertEqual([(e['generation'], e['event']) for e in events], [(self.gen, 'created'), (info['generation'], 'restored')])
        self.assertEqual((events[1]['fromGeneration'], events[1]['fromRevision'], events[1]['backupSha256'], events[1]['actor']), (self.gen, 2, manifest['sha256'], ACTOR))
        mine, theirs = self.snapshot(new), self.snapshot(self.conn)
        for t in ('nodes', 'tasks', 'graph_edges', 'id_allocations', 'issued_ids', 'operations', 'revisions'):
            self.assertEqual(mine[t], theirs[t], t)
        self.assertFalse(w3.write_enabled(self.open(self.dir / 'restored.sqlite3')), 'reopening the file does not reopen writes')

    def test_backup_and_restore_never_overwrite(self):
        taken = self.dir / 'taken.sqlite3'
        taken.write_bytes(b'existing')
        with self.assertRaises(FileExistsError):
            rc.backup(self.conn, taken)
        self.assertEqual(taken.read_bytes(), b'existing')
        rc.manifest_path(self.dir / 'other.sqlite3').write_text('existing manifest')
        with self.assertRaises(FileExistsError):
            rc.backup(self.conn, self.dir / 'other.sqlite3')
        self.assertFalse((self.dir / 'other.sqlite3').exists())
        self.assertEqual(rc.manifest_path(self.dir / 'other.sqlite3').read_text(), 'existing manifest')
        backup, _ = self.backed_up()
        with self.assertRaises(FileExistsError):
            rc.restore(backup, taken, ACTOR, EVIDENCE)
        self.assertEqual(taken.read_bytes(), b'existing')

    def test_damaged_or_altered_backups_are_refused(self):
        backup, manifest = self.backed_up()
        data = backup.read_bytes()
        mpath = rc.manifest_path(backup)
        def attempt(words, name):
            with self.assertRaises(rc.BackupInvalid) as caught:
                rc.restore(backup, self.dir / name, ACTOR, EVIDENCE)
            self.assertIn(words, str(caught.exception))
            self.assertFalse((self.dir / name).exists(), 'nothing is restored')
        broken = bytearray(data)
        broken[len(broken) // 2] ^= 0xFF
        backup.write_bytes(bytes(broken))
        attempt('bytes do not match', 'r1.sqlite3')
        unreadable = b'not sqlite format' + data[17:]  # structural damage, with a manifest re-made to match the bytes
        backup.write_bytes(unreadable)
        mpath.write_text(json.dumps(dict(manifest, sha256=rc._sha256(backup), bytes=len(unreadable))))
        attempt('not a readable experiment DB', 'r2.sqlite3')
        # Limit (recorded, not tested as a refusal): a content change inside a valid page with a manifest re-made to match
        # passes; the manifest is not signed and integrity_check only sees structure.
        backup.write_bytes(data)
        mpath.write_text(json.dumps(dict(manifest, generation='gen-someone-else')))
        attempt('manifest says', 'r3.sqlite3')
        mpath.write_text(json.dumps(dict(manifest, revision=1)))
        attempt('manifest says', 'r4.sqlite3')
        mpath.write_text(json.dumps(dict(manifest, schemaVersion=2)))
        attempt('schema version 2', 'r5.sqlite3')
        mpath.unlink()
        attempt('manifest unreadable', 'r6.sqlite3')

    def test_changes_after_the_backup_are_not_in_the_restore(self):
        self.backed_up()
        w3.apply(self.conn, 'op-3', request(self.conn, kind='register_task', prefix='TASK', fields=dict(NEW, item='バックアップ後')))  # TASK-007
        new, _ = self.restored()
        self.assertIsNone(new.execute("SELECT 1 FROM nodes WHERE id = 'TASK-007'").fetchone())
        self.assertIsNone(w3.operation(new, 'op-3'))
        self.assertEqual(dict(new.execute('SELECT prefix, highwater FROM id_allocations')), {'TASK': 6}, 'the restored highwater lags the origin (7)')


class Races(Recovery):
    """Acceptance robustness (2026-10-19): destinations are reserved exclusively, and restore copies only the bytes it
    validated. The hooks run at the exact interleaving points; they are test-only."""

    def test_backup_destination_taken_at_the_last_moment(self):
        target = self.dir / 'late.sqlite3'
        def other(path):
            if path == target:
                target.write_bytes(b'someone else')
        with self.assertRaises(FileExistsError):
            rc.backup(self.conn, target, _before_reserve=other)
        self.assertEqual(target.read_bytes(), b'someone else', 'the other file is not touched')
        self.assertFalse(rc.manifest_path(target).exists(), 'no manifest for a backup that was not written')

    def test_backup_manifest_taken_at_the_last_moment(self):
        target = self.dir / 'late.sqlite3'
        def other(path):
            if path == rc.manifest_path(target):
                path.write_text('someone else')
        with self.assertRaises(FileExistsError):
            rc.backup(self.conn, target, _before_reserve=other)
        self.assertFalse(target.exists(), 'our own reserved backup file is removed')
        self.assertEqual(rc.manifest_path(target).read_text(), 'someone else')

    def test_restore_target_taken_at_the_last_moment(self):
        backup, _ = self.backed_up()
        target = self.dir / 'late-restore.sqlite3'
        def other(path):
            target.write_bytes(b'someone else')
        with self.assertRaises(FileExistsError):
            rc.restore(backup, target, ACTOR, EVIDENCE, _before_reserve=other)
        self.assertEqual(target.read_bytes(), b'someone else')

    def test_restore_copies_the_validated_bytes(self):
        backup, manifest = self.backed_up()
        w3.apply(self.conn, 'op-3', request(self.conn, kind='register_task', prefix='TASK', fields=dict(NEW, item='後から')))
        later = self.dir / 'backup-2.sqlite3'
        rc.backup(self.conn, later)
        def swap(path):
            backup.write_bytes(later.read_bytes())  # replaced by a valid but different DB after validation
        new_path = self.dir / 'pinned.sqlite3'
        rc.restore(backup, new_path, ACTOR, EVIDENCE, _after_validate=swap)
        new = self.open(new_path)
        self.assertIsNone(new.execute("SELECT 1 FROM nodes WHERE id = 'TASK-007'").fetchone(), 'the swapped-in content is not restored')
        self.assertEqual(rc.lineage(new)[-1]['backupSha256'], manifest['sha256'])
        self.assertEqual(rc.lineage(new)[-1]['fromRevision'], 2)

    def test_restore_after_the_backup_disappears_uses_the_pinned_bytes(self):
        backup, manifest = self.backed_up()
        new_path = self.dir / 'pinned.sqlite3'
        rc.restore(backup, new_path, ACTOR, EVIDENCE, _after_validate=lambda path: path.unlink())
        new = self.open(new_path)
        self.assertEqual(rc.lineage(new)[-1]['backupSha256'], manifest['sha256'])
        self.assertTrue(new.execute("SELECT 1 FROM nodes WHERE id = 'TASK-006'").fetchone())

    def test_backup_manifest_hashes_the_written_bytes(self):
        target = self.dir / 'b.sqlite3'
        manifest = rc.backup(self.conn, target)
        self.assertEqual(manifest['sha256'], rc._sha256(target))
        self.assertEqual(manifest['bytes'], target.stat().st_size)


class GenerationsAndHistory(Recovery):
    def test_requests_of_another_generation_change_nothing(self):
        new, info = self.restored()
        rc.enable_writes(new, ACTOR, EVIDENCE, {'TASK': 6})
        before = self.snapshot(new)
        with self.assertRaises(w3.GenerationMismatch):
            w3.apply(new, 'op-9', dict(request(self.conn, kind='update_task', id='TASK-004', base={'owner': '担当D'}, changes={'owner': 'Z'})))  # old generation
        self.assertEqual(self.snapshot(new), before, 'nothing recorded or changed')
        origin_before = self.snapshot(self.conn)
        with self.assertRaises(w3.GenerationMismatch):
            w3.apply(self.conn, 'op-9', dict(request(self.conn, kind='update_task', id='TASK-004', base={'owner': '担当D'}, changes={'owner': 'Z'}), generation=info['generation']))
        self.assertEqual(self.snapshot(self.conn), origin_before)
        with self.assertRaises(ValueError):
            w3.apply(new, 'op-10', {'kind': 'retire_task', 'id': 'TASK-005', 'reason': 'x', 'generation': info['generation']})  # no actor

    def test_old_operations_are_kept_for_query_and_never_replayed(self):
        new, info = self.restored()
        rc.enable_writes(new, ACTOR, EVIDENCE, {'TASK': 6})
        old = w3.operation(new, 'op-2')
        self.assertEqual((old['generation'], old['status'], old['revision'], old['actor'], old['evidence']), (self.gen, 'done', 2, ACTOR, EVIDENCE))
        self.assertEqual((old['before'], old['after']), ({'id': 'TASK-003', 'owner': '担当C'}, {'id': 'TASK-003', 'owner': '担当X'}))
        same = dict(old['request'], generation=info['generation'])
        with self.assertRaises(w3.OperationFromEarlierGeneration):
            w3.apply(new, 'op-2', same)  # the same op ID in the new generation is not replayed or run again
        self.assertEqual(w3.operation(new, 'op-2'), old)
        first = w3.apply(new, 'op-new', request(new, kind='update_task', id='TASK-004', base={'owner': '担当D'}, changes={'owner': '担当Z'}))
        self.assertEqual(first['revision'], 1, 'revisions count within the new generation')
        self.assertEqual(new.execute('SELECT generation, revision FROM revisions ORDER BY generation = ?, revision', (self.gen,)).fetchall(),
                         [(info['generation'], 1), (self.gen, 1), (self.gen, 2)])

    def test_history_is_written_with_the_change(self):
        rec = w3.operation(self.conn, 'op-1')
        self.assertEqual((rec['before'], rec['after']['id'], rec['after']['highwater'], rec['after']['task']), ({'highwater': 5}, 'TASK-006', 6, NEW))
        self.assertEqual(rec['request']['generation'], self.gen)
        with self.assertRaises(w3.Refused):
            w3.apply(self.conn, 'op-3', request(self.conn, kind='update_task', id='TASK-003', base={'owner': '担当C'}, changes={'owner': '担当Y'}))
        refused = w3.operation(self.conn, 'op-3')
        self.assertEqual((refused['status'], refused['before'], refused['after'], refused['actor']), ('refused', None, None, ACTOR))
        self.assertIn('conflict', refused['result']['error'])
        before = self.snapshot(self.conn)
        def fail(stage):
            raise RuntimeError('injected')
        with self.assertRaises(RuntimeError):
            w3.apply(self.conn, 'op-4', request(self.conn, kind='update_task', id='TASK-004', base={'owner': '担当D'}, changes={'owner': 'Z'}), fail)
        self.assertEqual(self.snapshot(self.conn), before, 'no change, no history, no revision')


class Reopening(Recovery):
    def test_restored_writes_stay_closed_until_explicitly_enabled(self):
        self.backed_up()
        w3.apply(self.conn, 'op-3', request(self.conn, kind='register_task', prefix='TASK', fields=dict(NEW, item='バックアップ後')))  # TASK-007 in the origin only
        new, info = self.restored()
        before = self.snapshot(new)
        with self.assertRaises(w3.WriteDisabled):
            w3.apply(new, 'op-x', request(new, kind='register_task', prefix='TASK', fields=NEW))
        self.assertEqual(self.snapshot(new), before)
        for bad in (dict(evidence=[]), dict(issued_through={'TASK': 5}), dict(issued_through={})):
            args = {'actor': ACTOR, 'evidence': EVIDENCE, 'issued_through': {'TASK': 7}, **bad}
            with self.assertRaises(ValueError):
                rc.enable_writes(new, **args)
            self.assertFalse(w3.write_enabled(new))
        rc.enable_writes(new, ACTOR, EVIDENCE, {'TASK': 7})  # the caller states the real boundary (TASK-007 was issued after the backup)
        self.assertEqual(w3.apply(new, 'op-x', request(new, kind='register_task', prefix='TASK', fields=NEW))['id'], 'TASK-008')
        event = rc.lineage(new)[-1]
        self.assertEqual((event['event'], event['issuedThrough'], event['restoredHighwater']), ('writes enabled', {'TASK': 7}, {'TASK': 6}))

    def test_the_api_cannot_know_the_real_boundary(self):
        # Documenting the open decision: enabling with only the backup's highwater is accepted and re-issues TASK-007,
        # which the origin had already issued after the backup. The number is not safe from the backup alone.
        self.backed_up()
        w3.apply(self.conn, 'op-3', request(self.conn, kind='register_task', prefix='TASK', fields=dict(NEW, item='バックアップ後')))
        new, _ = self.restored()
        rc.enable_writes(new, ACTOR, EVIDENCE, {'TASK': 6})
        self.assertEqual(w3.apply(new, 'op-x', request(new, kind='register_task', prefix='TASK', fields=NEW))['id'], 'TASK-007')
        self.assertEqual(self.conn.execute("SELECT name FROM nodes WHERE id = 'TASK-007'").fetchone()[0], 'バックアップ後', 'the same number means another task in the origin')


if __name__ == '__main__':
    sys.exit(0 if unittest.main(exit=False, verbosity=2 if '-v' in sys.argv else 1).result.wasSuccessful() else 1)
