#!/usr/bin/env python3
"""OPS-168 tests: task-only change groups. Saves are made with the real Studio editor (studio_harness.cjs, function
harness), written and read back, and given a saveId as the isolated server stores it. Each test owns a TemporaryDirectory.

Run: python3 -B Maintanance/RegistryApp/v3/test_change_groups.py -v
"""
import copy
import json
import sys
import unittest
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
import hermetic  # noqa: E402,F401  (first: temporary roots for every live path, OPS-167 K9)
import registry_v3_recovery as rc  # noqa: E402
import registry_v3_write as w3  # noqa: E402
import studio_adapter as sa  # noqa: E402
from test_studio_adapter import ACTOR, EVIDENCE, Studio  # noqa: E402

A, B = 'task:TASK-003', 'task:TASK-004'


class Groups(Studio):
    def stored(self, actions, save_id):
        save, _ = self.edit(actions)
        save['studioSave'] = {'saveId': save_id, 'parent': None}  # as the isolated server stores it
        return save

    def two_tasks(self, save_id='S-1'):
        return self.stored([{'select': 'TASK-003'}, {'set': {'owner': '担当X'}}, {'apply': True},
                            {'select': 'TASK-004'}, {'set': {'owner': '担当Z'}}, {'apply': True}], save_id)

    def owners(self):
        return dict(self.conn.execute("SELECT id, owner FROM tasks WHERE id IN ('TASK-003', 'TASK-004')").fetchall())

    def db_owner(self, op, tid, base, new):
        w3.apply(self.conn, op, {'kind': 'update_task', 'id': tid, 'base': {'owner': base}, 'changes': {'owner': new}, 'generation': w3.generation(self.conn),
                                 'actor': 'DB側の別の編集', 'evidence': []})

    def ids(self, out, key):
        return [e if isinstance(e, str) else e['groupId'] for e in out[key]]


class Apply(Groups):
    def test_a_applies_and_b_conflicts(self):
        save = self.two_tasks()
        self.assertEqual([g['groupId'] for g in sa.plan_groups(self.conn, save)], [A, B])
        self.db_owner('db-1', 'TASK-004', '担当D', '担当Y')
        out = sa.apply_groups(self.conn, save, [A, B], ACTOR, EVIDENCE)
        self.assertEqual((self.ids(out, 'applied'), self.ids(out, 'conflict'), out['complete']), ([A], [B], False))
        self.assertIn('conflict on TASK-004: owner', out['conflict'][0]['error'])
        self.assertEqual(self.owners(), {'TASK-003': '担当X', 'TASK-004': '担当Y'})
        self.assertEqual(out['applied'][0]['operationId'], 'save:S-1:task:TASK-003')

    def test_replay_of_a_adds_no_revision(self):
        save = self.two_tasks()
        first = sa.apply_groups(self.conn, save, [A], ACTOR, EVIDENCE)
        revision = w3.revision(self.conn)
        again = sa.apply_groups(self.conn, copy.deepcopy(save), [A], ACTOR, EVIDENCE)
        self.assertEqual((self.ids(again, 'replayed'), self.ids(again, 'applied')), ([A], []))
        self.assertEqual(again['replayed'][0]['result'], first['applied'][0]['result'])
        self.assertEqual(w3.revision(self.conn), revision)

    def test_reworked_b_is_a_new_request(self):
        save = self.two_tasks()
        self.db_owner('db-1', 'TASK-004', '担当D', '担当Y')
        sa.apply_groups(self.conn, save, [A, B], ACTOR, EVIDENCE)
        revision, ops = self.counts()
        changed = copy.deepcopy(save)  # the same saveId with B's content changed: refused, not re-run
        for part in (changed, changed['baseline']):
            next(t for t in part['tasks'] if t['id'] == 'TASK-004')['owner'] = '担当Y'
        next(t for t in changed['tasks'] if t['id'] == 'TASK-004')['owner'] = '担当W'
        out = sa.apply_groups(self.conn, changed, [B], ACTOR, EVIDENCE)
        self.assertEqual(self.ids(out, 'changedContent'), [B])
        self.assertEqual(self.counts(), (revision, ops), 'nothing written')
        self.assertEqual(self.owners()['TASK-004'], '担当Y')
        rework = self.stored([{'select': 'TASK-004'}, {'set': {'owner': '担当W'}}, {'apply': True}], 'S-2')  # re-exported and re-edited
        out = sa.apply_groups(self.conn, rework, [B], ACTOR, EVIDENCE)
        self.assertEqual((self.ids(out, 'applied'), out['complete']), ([B], True))
        self.assertEqual(self.owners()['TASK-004'], '担当W')

    def test_unselected_groups_stay_intact(self):
        save = self.two_tasks()
        out = sa.apply_groups(self.conn, save, [A], ACTOR, EVIDENCE)
        self.assertEqual((self.ids(out, 'applied'), out['unselected'], out['complete']), ([A], [B], False))
        self.assertEqual(self.owners()['TASK-004'], '担当D')
        self.assertIsNone(w3.operation(self.conn, 'save:S-1:' + B), 'an unselected group leaves no record')
        later = sa.apply_groups(self.conn, save, [A, B], ACTOR, EVIDENCE)
        self.assertEqual((self.ids(later, 'replayed'), self.ids(later, 'applied'), later['complete']), ([A], [B], True))

    def test_same_task_fields_are_atomic(self):
        save = self.stored([{'select': 'TASK-003'}, {'set': {'owner': '担当X', 'state': 'DONE'}}, {'apply': True}], 'S-1')
        self.db_owner('db-1', 'TASK-003', '担当C', '担当Y')
        out = sa.apply_groups(self.conn, save, [A], ACTOR, EVIDENCE)
        self.assertEqual(self.ids(out, 'conflict'), [A])
        self.assertEqual(self.task('TASK-003'), {'state': 'ACTIVE', 'owner': '担当Y'}, 'state is not applied without owner')

    def test_already_reflected_group(self):
        save = self.two_tasks()
        self.db_owner('db-1', 'TASK-003', '担当C', '担当X')
        out = sa.apply_groups(self.conn, save, [A, B], ACTOR, EVIDENCE)
        self.assertEqual((self.ids(out, 'alreadyReflected'), self.ids(out, 'applied'), out['complete']), ([A], [B], True))


class WholeSave(Groups):
    def unchanged(self, call, words):
        before = (self.counts(), self.owners())
        with self.assertRaises(sa.SaveRejected) as caught:
            call()
        self.assertIn(words, str(caught.exception))
        self.assertEqual((self.counts(), self.owners()), before)

    def test_old_generation(self):
        save = self.two_tasks()
        rc.backup(self.conn, self.dir / 'b.sqlite3')
        rc.restore(self.dir / 'b.sqlite3', self.dir / 'r.sqlite3', ACTOR, EVIDENCE)
        new = self.open(self.dir / 'r.sqlite3')
        rc.enable_writes(new, ACTOR, EVIDENCE, {'TASK': 5})
        with self.assertRaises(sa.SaveRejected) as caught:
            sa.apply_groups(new, save, [A, B], ACTOR, EVIDENCE)
        self.assertIn('generation changed', str(caught.exception))
        self.assertEqual(new.execute('SELECT COUNT(*) FROM operations').fetchone()[0], 0)

    def test_mixed_structural_change(self):
        # OPS-170 changed this case: the added edge is its own group, pending consultation, instead of a whole-save rejection
        save = self.stored([{'select': 'TASK-003'}, {'set': {'owner': '担当X'}}, {'apply': True}, {'addPrerequisite': 'TASK-005'},
                            {'select': 'TASK-004'}, {'set': {'owner': '担当Z'}}, {'apply': True}], 'S-1')
        out = sa.apply_groups(self.conn, save, [A, B, 'edge-add:TASK-005->TASK-003'], ACTOR, EVIDENCE)
        self.assertEqual((self.ids(out, 'applied'), out['pending'], out['complete']), ([A, B], [{'groupId': 'edge-add:TASK-005->TASK-003', 'needs': ['consultation']}], False))
        self.assertIsNone(self.conn.execute("SELECT 1 FROM graph_edges WHERE prerequisite = 'TASK-005'").fetchone())
        with self.assertRaises(sa.SaveRejected) as caught:  # the single-task path still rejects structural changes
            sa.plan_save(self.conn, save)
        self.assertIn('unsupported changes, nothing applied: edges', str(caught.exception))

    def test_selection_and_identity(self):
        save = self.two_tasks()
        self.unchanged(lambda: sa.apply_groups(self.conn, save, ['task:TASK-999'], ACTOR, EVIDENCE), 'the selection names no unit')
        self.unchanged(lambda: sa.apply_groups(self.conn, save, [A, A], ACTOR, EVIDENCE), 'without duplicates')
        anonymous = copy.deepcopy(save)
        del anonymous['studioSave']
        self.unchanged(lambda: sa.apply_groups(self.conn, anonymous, [A], ACTOR, EVIDENCE), 'no saveId')
        empty = self.stored([], 'S-0')
        self.unchanged(lambda: sa.apply_groups(self.conn, empty, [], ACTOR, EVIDENCE), 'changes nothing')

    def test_single_task_path_is_unchanged(self):
        save = self.two_tasks()
        with self.assertRaises(sa.SaveRejected) as caught:
            sa.apply_save(self.conn, save, ACTOR, EVIDENCE)
        self.assertIn('exactly one task, it changes 2', str(caught.exception))


if __name__ == '__main__':
    sys.exit(0 if unittest.main(exit=False, verbosity=2 if '-v' in sys.argv else 1).result.wasSuccessful() else 1)
