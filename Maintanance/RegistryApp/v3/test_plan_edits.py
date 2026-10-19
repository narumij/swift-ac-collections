#!/usr/bin/env python3
"""OPS-172 tests: existing-card plan edits (K5 slice) from real Studio editor saves: reorder, move between versions and
rename as ONE atomic apply_plan, after an explicit confirmation. Versions, gates, focus and recordedDone stay fixed.

Run: python3 -B Maintanance/RegistryApp/v3/test_plan_edits.py -v
"""
import copy
import sys
import unittest
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
import hermetic  # noqa: E402,F401  (first: temporary roots for every live path, OPS-167 K9)
import registry_v3_read as r3  # noqa: E402
import registry_v3_recovery as rc  # noqa: E402
import registry_v3_write as w3  # noqa: E402
import studio_adapter as sa  # noqa: E402
from test_change_groups import Groups  # noqa: E402
from test_studio_adapter import ACTOR, EVIDENCE  # noqa: E402

PLAN = 'plan:milestones'
EV = ['計画の確認 2026-10-19']


class Plan(Groups):
    def order(self):
        return r3.read(self.conn, 'all')['order']['cards']

    def names(self):
        return dict(self.conn.execute("SELECT id, name FROM nodes WHERE kind = 'card'").fetchall())

    def plan_group(self, save):
        return next(g for g in sa.plan_groups(self.conn, save) if g['groupId'] == PLAN)

    def confirm(self, save):
        g = self.plan_group(save)
        return {'plan': {'cards': g['cards'], 'renames': {k: v['name'] for k, v in g['renames'].items()}, 'evidence': EV}}

    def snapshot(self):
        c = self.conn
        return (c.execute('SELECT * FROM version_members ORDER BY 1, 3').fetchall(), self.names(), c.execute('SELECT * FROM graph_edges ORDER BY 1,2,3').fetchall(), w3.revision(c))


class Edits(Plan):
    def test_reorder_within_a_version(self):
        save = self.stored([{'select': 'MS-A1'}, {'press': '後へ'}], 'S-1')
        g = self.plan_group(save)
        self.assertEqual((g['status'], g['cardsBase'], g['cards']), ('pending', {'0.1.0': ['MS-A1', 'MS-A2']}, {'0.1.0': ['MS-A2', 'MS-A1']}))
        pending = sa.apply_groups(self.conn, save, [PLAN], ACTOR, EVIDENCE)
        self.assertEqual(pending['pending'], [{'groupId': PLAN, 'needs': ['plan-confirmation']}])
        self.assertEqual(self.order()['0.1.0'], ['MS-A1', 'MS-A2'], 'the display paths alone change nothing')
        out = sa.apply_groups(self.conn, save, [PLAN], ACTOR, EVIDENCE, self.confirm(save))
        self.assertEqual((self.ids(out, 'applied'), out['complete']), ([PLAN], True))
        self.assertEqual(self.order()['0.1.0'], ['MS-A2', 'MS-A1'])
        self.assertIn(['START-0.1.0', 'MS-A2'], r3.read(self.conn, 'all')['relations']['skeleton'], 'the skeleton is derived from the new order')
        self.assertIn(['TASK-002', 'MS-A2'], r3.read(self.conn, 'all')['relations']['milestone'], 'task links stay on their card IDs')

    def test_move_between_versions_is_one_operation(self):
        save = self.stored([{'select': 'MS-B1'}, {'set': {'planVersion': '0.3.0'}}, {'press': 'この版へ移動'}], 'S-1')
        g = self.plan_group(save)
        self.assertEqual(g['cards'], {'0.2.0': [], '0.3.0': ['MS-B1']})
        out = sa.apply_groups(self.conn, save, [PLAN], ACTOR, EVIDENCE, self.confirm(save))
        self.assertEqual(self.ids(out, 'applied'), [PLAN])
        self.assertEqual((self.order()['0.2.0'], self.order()['0.3.0']), ([], ['MS-B1']))
        self.assertEqual(w3.revision(self.conn), 1)

    def test_rename(self):
        save = self.stored([{'select': 'MS-A2'}, {'set': {'planItem': 'A の次（改名）'}}, {'press': '名前・条件を適用'}], 'S-1')
        out = sa.apply_groups(self.conn, save, [PLAN], ACTOR, EVIDENCE, self.confirm(save))
        self.assertEqual(self.ids(out, 'applied'), [PLAN])
        self.assertEqual(self.names()['MS-A2'], 'A の次（改名）')
        rec = w3.operation(self.conn, sa.unit_operation_id('S-1', PLAN))
        self.assertEqual((rec['before']['names'], rec['after']['names']), ({'MS-A2': 'A の次'}, {'MS-A2': 'A の次（改名）'}))

    def test_replay_and_changed_confirmation(self):
        save = self.stored([{'select': 'MS-A1'}, {'press': '後へ'}], 'S-1')
        sa.apply_groups(self.conn, save, [PLAN], ACTOR, EVIDENCE, self.confirm(save))
        before = self.snapshot()
        again = sa.apply_groups(self.conn, save, [PLAN], ACTOR, EVIDENCE, self.confirm(save))
        self.assertEqual(self.ids(again, 'replayed'), [PLAN])
        self.assertEqual(self.snapshot(), before)
        other = self.confirm(save)
        other['plan']['evidence'] = ['別の根拠']
        self.assertEqual(self.ids(sa.apply_groups(self.conn, save, [PLAN], ACTOR, EVIDENCE, other), 'changedContent'), [PLAN])


class Conflicts(Plan):
    def test_stale_order_base(self):
        first = self.stored([{'select': 'MS-A1'}, {'press': '後へ'}], 'S-1')
        second = self.stored([{'select': 'MS-A1'}, {'set': {'planItem': '別の名前'}}, {'press': '名前・条件を適用'}, {'press': '後へ'}], 'S-2')
        sa.apply_groups(self.conn, first, [PLAN], ACTOR, EVIDENCE, self.confirm(first))
        before = self.snapshot()
        out = sa.apply_groups(self.conn, second, [PLAN], ACTOR, EVIDENCE, self.confirm(second))
        self.assertEqual(self.ids(out, 'conflict'), [PLAN])
        self.assertIn('conflict on version 0.1.0', out['conflict'][0]['error'])
        self.assertEqual(self.snapshot()[:3], before[:3], 'nothing of the plan, not even the rename, is applied')

    def test_stale_name_base(self):
        first = self.stored([{'select': 'MS-A2'}, {'set': {'planItem': '一つ目の名前'}}, {'press': '名前・条件を適用'}], 'S-1')
        second = self.stored([{'select': 'MS-A2'}, {'set': {'planItem': '二つ目の名前'}}, {'press': '名前・条件を適用'}], 'S-2')
        sa.apply_groups(self.conn, first, [PLAN], ACTOR, EVIDENCE, self.confirm(first))
        out = sa.apply_groups(self.conn, second, [PLAN], ACTOR, EVIDENCE, self.confirm(second))
        self.assertIn('conflict on card MS-A2: name changed', out['conflict'][0]['error'])
        self.assertEqual(self.names()['MS-A2'], '一つ目の名前')

    def test_cycle_rolls_back(self):
        # with TASK-003 -> MS-B1, moving MS-B1 into 0.1.0 closes MS-B1 -> END-0.1.0 -> GATE -> START-0.2.0 -> TASK-003 -> MS-B1
        w3.apply(self.conn, 'db-1', {'kind': 'add_milestone_link', 'prerequisite': 'TASK-003', 'successor': 'MS-B1', 'constraint': '判断材料。',
                                     'generation': w3.generation(self.conn), 'actor': 'DB側', 'evidence': []})
        # Studio's own check() refuses this move in the editor (the export carries the link), so the DB-side rollback is
        # exercised with the same request apply_groups would send
        save = self.stored([{'select': 'MS-B1'}, {'set': {'planVersion': '0.1.0'}}, {'press': 'この版へ移動'}], 'S-1')
        ms_b1 = next(m for m in save['milestones'] if m['id'] == 'MS-B1')
        self.assertTrue(ms_b1['gate'].startswith('Maintanance/Milestones/0.2.0/'), 'the editor refused the move')
        before = self.snapshot()
        with self.assertRaises(w3.Refused) as caught:
            w3.apply(self.conn, 'move', {'kind': 'apply_plan', 'cardsBase': {'0.1.0': ['MS-A1', 'MS-A2'], '0.2.0': ['MS-B1']}, 'cards': {'0.1.0': ['MS-A1', 'MS-A2', 'MS-B1'], '0.2.0': []},
                                         'generation': w3.generation(self.conn), 'actor': ACTOR, 'evidence': []})
        self.assertIn('cycle', str(caught.exception))
        self.assertEqual(self.snapshot()[:3], before[:3])


class Boundaries(Plan):
    def test_skeleton_lines_are_replaced_not_duplicated(self):
        save = self.stored([{'select': 'MS-A1'}, {'press': '後へ'}], 'S-1')
        sk = [(r['prerequisite'], r['successor']) for r in save['milestoneRelations'] if r['source']['path'] == 'v3-db:skeleton']
        self.assertIn(('START-0.1.0', 'MS-A2'), sk)
        self.assertNotIn(('START-0.1.0', 'MS-A1'), sk, 'the stale line was replaced (P4)')
        self.assertFalse([r for r in save['milestoneRelations'] if 'README' in r['source']['path']], 'no line claims Milestones/README.md')
        self.assertFalse([g for g in sa.plan_groups(self.conn, save) if g['groupId'].startswith('link-')], 'derived lines do not become link groups')

    def test_unknown_lines_do_not_disappear(self):
        save = self.stored([{'select': 'MS-A1'}, {'press': '後へ'}], 'S-1')
        stale = copy.deepcopy(save)
        stale['milestoneRelations'].append({'prerequisite': 'START-0.1.0', 'successor': 'MS-A1', 'constraint': 'x', 'source': {'path': 'v3-db:skeleton', 'quote': ''}})
        with self.assertRaises(sa.SaveRejected) as caught:
            sa.plan_groups(self.conn, stale)
        self.assertIn('skeleton relations differ', str(caught.exception))
        other = copy.deepcopy(save)
        other['milestoneRelations'].append({'prerequisite': 'MS-A1', 'successor': 'MS-B1', 'constraint': 'x', 'source': {'path': 'Maintanance/Milestones/README.md', 'quote': ''}})
        self.assertIn('link-add:MS-A1->MS-B1', [g['groupId'] for g in sa.plan_groups(self.conn, other)], 'a line with another source is an ordinary link change')

    def test_out_of_scope_plan_edits_are_unsupported(self):
        # OPS-176 changed two cases: planCondition is now a separate document proposal, and a planned draft-ms card a new
        # card waiting for its document (test_new_plan_items.py). recordedDone and gate changes stay unsupported.
        save = self.stored([{'select': 'MS-A2'}, {'set': {'planItem': 'A の次', 'planCondition': '到達条件の案'}}, {'press': '名前・条件を適用'}], 'S-1')
        groups = {g['groupId']: g for g in sa.plan_groups(self.conn, save)}
        self.assertNotIn(PLAN, groups, 'no structural plan change')
        self.assertEqual((groups['card-condition:MS-A2']['status'], groups['card-condition:MS-A2']['text']), ('pending', '到達条件の案'))
        for change, words in ((lambda d: next(m for m in d['milestones'] if m['id'] == 'MS-A1').update(recordedDone=False), 'recordedDone'),
                              (lambda d: next(m for m in d['milestones'] if m['id'] == 'GATE-0.2.0').update(item='改名'), 'gates and existing versions are fixed')):
            crafted = self.stored([], 'S-x')
            change(crafted)
            g = self.plan_group(crafted)
            self.assertEqual(g['status'], 'unsupported')
            self.assertTrue(any(words in u for u in g['unsupported']), (words, g['unsupported']))

    def test_restored_generation_stays_closed(self):
        rc.backup(self.conn, self.dir / 'b.sqlite3')
        rc.restore(self.dir / 'b.sqlite3', self.dir / 'r.sqlite3', ACTOR, EVIDENCE)
        restored = self.open(self.dir / 'r.sqlite3')
        with self.assertRaises(w3.WriteDisabled):
            w3.apply(restored, 'p', {'kind': 'apply_plan', 'cardsBase': {'0.1.0': ['MS-A1', 'MS-A2']}, 'cards': {'0.1.0': ['MS-A2', 'MS-A1']},
                                     'generation': w3.generation(restored), 'actor': ACTOR, 'evidence': []})

    def test_confirmation_must_match_and_no_card_is_added(self):
        save = self.stored([{'select': 'MS-A1'}, {'press': '後へ'}], 'S-1')
        wrong = {'plan': {'cards': {'0.1.0': ['MS-A1', 'MS-A2']}, 'renames': {}, 'evidence': EV}}
        with self.assertRaises(sa.SaveRejected):
            sa.apply_groups(self.conn, save, [PLAN], ACTOR, EVIDENCE, wrong)
        with self.assertRaises(w3.Refused) as caught:
            w3.apply(self.conn, 'direct', {'kind': 'apply_plan', 'cardsBase': {'0.1.0': ['MS-A1', 'MS-A2']}, 'cards': {'0.1.0': ['MS-A2', 'MS-A1', 'MS-B1']},
                                           'generation': w3.generation(self.conn), 'actor': ACTOR, 'evidence': []})
        self.assertIn('nothing else is added or removed', str(caught.exception))

    def test_single_task_path_still_rejects_plans(self):
        save = self.stored([{'select': 'MS-A1'}, {'press': '後へ'}], 'S-1')
        with self.assertRaises(sa.SaveRejected) as caught:
            sa.plan_save(self.conn, save)
        self.assertIn('milestones (plan)', str(caught.exception))


if __name__ == '__main__':
    sys.exit(0 if unittest.main(exit=False, verbosity=2 if '-v' in sys.argv else 1).result.wasSuccessful() else 1)
