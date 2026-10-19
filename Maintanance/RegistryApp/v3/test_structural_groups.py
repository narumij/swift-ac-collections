#!/usr/bin/env python3
"""OPS-170 tests: structural change groups from real Studio saves (studio_harness.cjs, function harness): progress
edges and milestone links mapped to the K2 operations, with consultation and pairing resolutions. A rewire is never
inferred; pairs consume both sides for good. Expected values are written by hand.

Run: python3 -B Maintanance/RegistryApp/v3/test_structural_groups.py -v
"""
import copy
import sys
import unittest
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
import hermetic  # noqa: E402,F401  (first: temporary roots for every live path, OPS-167 K9)
import registry_v3_write as w3  # noqa: E402
import studio_adapter as sa  # noqa: E402
from test_change_groups import Groups  # noqa: E402
from test_studio_adapter import ACTOR, EVIDENCE  # noqa: E402

OLD = 'Aの結果を使う（同じ版の中）'
ADD = 'edge-add:TASK-005->TASK-003'
REM = 'edge-remove:TASK-002->TASK-003'
RW_ADD = 'edge-add:TASK-001->TASK-003'
PAIR = 'rewire:progress:TASK-002->TASK-003=>TASK-001->TASK-003'
CONSULTED = {'constraint': '相談で決めた条件', 'evidence': ['会話 2026-10-19']}


class Structural(Groups):
    def edge(self, graph, a, b):
        return self.conn.execute('SELECT flow, constraint_text FROM graph_edges WHERE graph = ? AND prerequisite = ? AND successor = ?', (graph, a, b)).fetchone()

    def rewired(self, save_id='S-1'):
        return self.stored([{'rewire': {'from': {'prerequisite': 'TASK-002', 'successor': 'TASK-003'}, 'to': {'prerequisite': 'TASK-001', 'successor': 'TASK-003'}}}], save_id)

    def rejected(self, call, words):
        before = (self.counts(), self.conn.execute('SELECT * FROM graph_edges ORDER BY 1, 2, 3').fetchall())
        with self.assertRaises(sa.SaveRejected) as caught:
            call()
        self.assertIn(words, str(caught.exception))
        self.assertEqual((self.counts(), self.conn.execute('SELECT * FROM graph_edges ORDER BY 1, 2, 3').fetchall()), before, 'nothing written')


class Additions(Structural):
    def test_added_edge_waits_for_consultation(self):
        save = self.stored([{'select': 'TASK-003'}, {'addPrerequisite': 'TASK-005'}], 'S-1')
        group = next(g for g in sa.plan_groups(self.conn, save) if g['groupId'] == ADD)
        self.assertEqual((group['status'], group['pending'], group['new']['conditionReview']), ('pending', ['consultation'], '相談待ち'))
        out = sa.apply_groups(self.conn, save, [ADD], ACTOR, EVIDENCE)
        self.assertEqual((out['pending'], out['complete']), ([{'groupId': ADD, 'needs': ['consultation']}], False))
        self.assertIsNone(self.edge('progress', 'TASK-005', 'TASK-003'), 'the save alone does not clear conditionReview')
        out = sa.apply_groups(self.conn, save, [ADD], ACTOR, EVIDENCE, {'standalone': {ADD: CONSULTED}})
        self.assertEqual((self.ids(out, 'applied'), out['complete']), ([ADD], True))
        self.assertEqual(self.edge('progress', 'TASK-005', 'TASK-003'), ('SEQUENCE', '相談で決めた条件'))
        rec = w3.operation(self.conn, 'save:S-1:' + ADD)
        self.assertEqual((rec['request']['consumes'], rec['evidence']), ([ADD], EVIDENCE + ['会話 2026-10-19']))
        again = sa.apply_groups(self.conn, save, [ADD], ACTOR, EVIDENCE, {'standalone': {ADD: CONSULTED}})
        self.assertEqual(self.ids(again, 'replayed'), [ADD])
        changed = sa.apply_groups(self.conn, save, [ADD], ACTOR, EVIDENCE, {'standalone': {ADD: dict(CONSULTED, constraint='別の条件')}})
        self.assertEqual(self.ids(changed, 'changedContent'), [ADD], 'a changed resolution under the same ID is refused')

    def test_added_link_from_the_editor(self):
        save = self.stored([{'select': 'TASK-005'}, {'set': {'milestoneTarget': 'END-0.3.0'}}, {'press': '到達点へつなぐ'}], 'S-1')
        out = sa.apply_groups(self.conn, save, ['link-add:TASK-005->END-0.3.0'], ACTOR, EVIDENCE, {'standalone': {'link-add:TASK-005->END-0.3.0': CONSULTED}})
        self.assertEqual(self.ids(out, 'applied'), ['link-add:TASK-005->END-0.3.0'])
        self.assertEqual(self.edge('milestone', 'TASK-005', 'END-0.3.0'), (None, '相談で決めた条件'))

    def test_unsupported_direction_is_refused_and_reported(self):
        save = self.stored([{'select': 'TASK-003'}, {'set': {'owner': '担当X'}}, {'apply': True}], 'S-1')
        save['milestoneRelations'].append({'prerequisite': 'END-0.2.0', 'successor': 'TASK-005', 'constraint': '', 'conditionReview': '相談待ち', 'source': {'path': '', 'quote': ''}})
        out = sa.apply_groups(self.conn, save, ['task:TASK-003', 'link-add:END-0.2.0->TASK-005'], ACTOR, EVIDENCE, {'standalone': {'link-add:END-0.2.0->TASK-005': CONSULTED}})
        self.assertEqual((self.ids(out, 'applied'), self.ids(out, 'refused'), out['complete']), (['task:TASK-003'], ['link-add:END-0.2.0->TASK-005'], False))
        self.assertIn('experiment-unsupported direction end -> task', out['refused'][0]['error'])


class Removals(Structural):
    def test_removal_alone_is_ready(self):
        save = self.stored([{'remove': {'prerequisite': 'TASK-002', 'successor': 'TASK-003'}}], 'S-1')
        group = next(g for g in sa.plan_groups(self.conn, save) if g['groupId'] == REM)
        self.assertEqual(group['status'], 'ready')
        out = sa.apply_groups(self.conn, save, [REM], ACTOR, EVIDENCE)
        self.assertEqual((self.ids(out, 'applied'), out['complete']), ([REM], True))
        self.assertIsNone(self.edge('progress', 'TASK-002', 'TASK-003'))
        self.assertEqual(self.ids(sa.apply_groups(self.conn, save, [REM], ACTOR, EVIDENCE), 'replayed'), [REM])

    def test_stale_base_is_a_conflict(self):
        save = self.stored([{'remove': {'prerequisite': 'TASK-002', 'successor': 'TASK-003'}}], 'S-1')
        w3.apply(self.conn, 'db-1', {'kind': 'set_edge', 'graph': 'progress', 'prerequisite': 'TASK-002', 'successor': 'TASK-003', 'base': {'constraint': OLD},
                                     'changes': {'constraint': 'DB側で変更'}, 'generation': w3.generation(self.conn), 'actor': 'DB側', 'evidence': []})
        out = sa.apply_groups(self.conn, save, [REM], ACTOR, EVIDENCE)
        self.assertEqual(self.ids(out, 'conflict'), [REM])
        self.assertEqual(self.edge('progress', 'TASK-002', 'TASK-003')[1], 'DB側で変更')


class Pairing(Structural):
    def test_rewire_in_the_ui_holds_both_sides(self):
        save = self.rewired()
        groups = {g['groupId']: g for g in sa.plan_groups(self.conn, save)}
        self.assertEqual((groups[REM]['pending'], groups[RW_ADD]['pending']), (['pairing'], ['consultation', 'pairing']))
        self.assertEqual(groups[RW_ADD]['new']['constraint'], OLD, 'the UI kept the old text for reference only')
        out = sa.apply_groups(self.conn, save, [RW_ADD], ACTOR, EVIDENCE)
        self.assertEqual(out['pending'], [{'groupId': RW_ADD, 'needs': ['consultation', 'pairing']}], 'selecting the addition alone does not bypass pairing')
        out = sa.apply_groups(self.conn, save, [REM], ACTOR, EVIDENCE)
        self.assertEqual(out['pending'], [{'groupId': REM, 'needs': ['pairing']}])
        self.assertEqual(self.edge('progress', 'TASK-002', 'TASK-003')[1], OLD)

    def test_pair_resolution_is_one_atomic_rewire_and_consumes_both(self):
        save = self.rewired()
        pair = {'pairs': [dict(remove=REM, add=RW_ADD, **CONSULTED)]}
        self.rejected(lambda: sa.apply_groups(self.conn, save, [RW_ADD], ACTOR, EVIDENCE, pair), 'part of ' + PAIR)
        out = sa.apply_groups(self.conn, save, [PAIR], ACTOR, EVIDENCE, pair)
        self.assertEqual((self.ids(out, 'applied'), out['complete']), ([PAIR], True))
        self.assertIsNone(self.edge('progress', 'TASK-002', 'TASK-003'))
        self.assertEqual(self.edge('progress', 'TASK-001', 'TASK-003'), ('SEQUENCE', '相談で決めた条件'), 'the consulted text, not the old one')
        self.assertEqual(self.ids(sa.apply_groups(self.conn, save, [PAIR], ACTOR, EVIDENCE, pair), 'replayed'), [PAIR])
        # after the pair, neither side can be applied in another form under the same save
        self.rejected(lambda: sa.apply_groups(self.conn, save, [RW_ADD], ACTOR, EVIDENCE, {'standalone': {RW_ADD: CONSULTED}}), 'already consumed by save:S-1:' + PAIR)
        self.rejected(lambda: sa.apply_groups(self.conn, save, [REM], ACTOR, EVIDENCE, {'standalone': {REM: {}}}), 'already consumed')

    def test_standalone_resolution_then_no_re_pairing(self):
        save = self.rewired()
        out = sa.apply_groups(self.conn, save, [REM, RW_ADD], ACTOR, EVIDENCE, {'standalone': {REM: {}, RW_ADD: CONSULTED}})
        self.assertEqual((self.ids(out, 'applied'), out['complete']), ([REM, RW_ADD], True))
        self.rejected(lambda: sa.apply_groups(self.conn, save, [PAIR], ACTOR, EVIDENCE, {'pairs': [dict(remove=REM, add=RW_ADD, **CONSULTED)]}), 'already consumed')

    def test_malformed_resolutions_are_rejected_before_any_write(self):
        save = self.stored([{'rewire': {'from': {'prerequisite': 'TASK-002', 'successor': 'TASK-003'}, 'to': {'prerequisite': 'TASK-001', 'successor': 'TASK-003'}}},
                            {'select': 'TASK-003'}, {'addPrerequisite': 'TASK-005'}, {'remove': {'prerequisite': 'MS-B1', 'successor': 'TASK-004'}}], 'S-1')
        pair = dict(remove=REM, add=RW_ADD, **CONSULTED)
        for res, words in (({'pairs': [pair, dict(pair, add=ADD)]}, 'used by more than one resolution'),
                           ({'pairs': [pair], 'standalone': {RW_ADD: CONSULTED}}, 'used by more than one resolution'),
                           ({'pairs': [dict(pair, remove='link-remove:MS-B1->TASK-004')]}, 'same graph'),
                           ({'pairs': [dict(pair, remove=ADD)]}, 'one removal with one addition'),
                           ({'pairs': [dict(pair, constraint='')]}, 'consulted constraint'),
                           ({'pairs': [dict(pair, evidence=[])]}, 'consulted constraint'),
                           ({'standalone': {'edge-add:TASK-404->TASK-003': CONSULTED}}, 'no structural group'),
                           ({'standalone': {ADD: {'constraint': 'x'}}}, 'consulted constraint'),
                           ({'standalone': {REM: CONSULTED}}, 'standalone removal takes no constraint'),
                           ({'pairs': [{'remove': REM, 'add': RW_ADD}]}, 'exactly remove, add, constraint and evidence'),
                           ({'other': 1}, 'resolutions are')):
            self.rejected(lambda: sa.apply_groups(self.conn, save, [PAIR], ACTOR, EVIDENCE, res), words)
        self.rejected(lambda: sa.apply_groups(self.conn, save, ['rewire:progress:x'], ACTOR, EVIDENCE, {'pairs': [pair]}), 'names no unit')
        self.assertEqual(self.edge('progress', 'TASK-002', 'TASK-003')[1], OLD)


class Interleaving(Structural):
    """Acceptance (2026-10-19): the consumption check must hold under the write transaction, not only in the preflight.
    Two connections; the second passes its preflight, then the first commits a pair using the same constituent."""

    def test_second_form_of_a_constituent_is_refused_in_the_transaction(self):
        save = self.rewired()
        other = self.open(self.dir / 'db.sqlite3')
        pair = {'pairs': [dict(remove=REM, add=RW_ADD, **CONSULTED)]}
        def first_commits_a_pair():
            sa.apply_groups(other, save, [PAIR], ACTOR, EVIDENCE, pair)
        out = sa.apply_groups(self.conn, save, [REM], ACTOR, EVIDENCE, {'standalone': {REM: {}}}, _after_preflight=first_commits_a_pair)
        self.assertEqual(self.ids(out, 'refused'), [REM])
        self.assertIn('already consumed by', out['refused'][0]['error'])
        claims = self.conn.execute('SELECT constituent, operation_id FROM consumption_claims ORDER BY 1').fetchall()
        self.assertEqual(claims, [(RW_ADD, sa.unit_operation_id('S-1', PAIR)), (REM, sa.unit_operation_id('S-1', PAIR))], 'only the pair holds the constituents')
        self.assertEqual(w3.operation(self.conn, sa.unit_operation_id('S-1', REM))['status'], 'refused', 'the losing form is recorded as refused, without a claim')

    def test_refused_claims_still_consume(self):
        save = self.rewired()
        w3.apply(self.conn, 'db-1', {'kind': 'set_edge', 'graph': 'progress', 'prerequisite': 'TASK-002', 'successor': 'TASK-003', 'base': {'constraint': OLD},
                                     'changes': {'constraint': 'DB側で変更'}, 'generation': w3.generation(self.conn), 'actor': 'DB側', 'evidence': []})
        out = sa.apply_groups(self.conn, save, [PAIR], ACTOR, EVIDENCE, {'pairs': [dict(remove=REM, add=RW_ADD, **CONSULTED)]})
        self.assertEqual(self.ids(out, 'conflict'), [PAIR])
        self.rejected(lambda: sa.apply_groups(self.conn, save, [REM], ACTOR, EVIDENCE, {'standalone': {REM: {}}}), 'already consumed')


class SaveIdentity(Structural):
    def test_wildcard_and_separator_characters_stay_distinct(self):
        ids = ['S%', 'S_', 'S', 'S:edge-remove', 'S%:x']
        saves = {sid: self.stored([{'remove': {'prerequisite': 'TASK-002', 'successor': 'TASK-003'}}], sid) for sid in ids}
        first = sa.apply_groups(self.conn, saves['S%'], [REM], ACTOR, EVIDENCE)
        self.assertEqual(self.ids(first, 'applied'), [REM])
        for sid in ids[1:]:
            out = sa.apply_groups(self.conn, saves[sid], [REM], ACTOR, EVIDENCE)
            self.assertEqual(self.ids(out, 'replayed'), [], f'{sid} is not the same save as S%')
            self.assertEqual(self.ids(out, 'conflict'), [REM], 'the edge is already gone: a new operation of its own save')
        op_ids = [r[0] for r in self.conn.execute("SELECT operation_id FROM operations WHERE operation_id LIKE 'save:%' ORDER BY 1")]
        self.assertEqual(len(op_ids), len(set(op_ids)), op_ids)
        self.assertEqual(len(op_ids), len(ids))
        self.assertEqual(sa.unit_operation_id('S:edge-remove', 'x'), 'save:S%3Aedge-remove:x', 'the saveId is escaped, so it cannot collide with another save and unit')


class Order(Structural):
    def test_removal_first_is_order_not_independence(self):
        # adding TASK-004 -> TASK-002 closes a cycle through MS-B1 -> TASK-004 unless that link is removed first
        actions = [{'remove': {'prerequisite': 'MS-B1', 'successor': 'TASK-004'}}, {'select': 'TASK-002'}, {'addPrerequisite': 'TASK-004'}]
        save = self.stored(actions, 'S-1')
        add = 'edge-add:TASK-004->TASK-002'
        alone = sa.apply_groups(self.conn, save, [add], ACTOR, EVIDENCE, {'standalone': {add: CONSULTED}})
        self.assertEqual(self.ids(alone, 'refused'), [add])
        self.assertIn('cycle', alone['refused'][0]['error'])
        other = self.stored(actions, 'S-2')
        both = sa.apply_groups(self.conn, other, [add, 'link-remove:MS-B1->TASK-004'], ACTOR, EVIDENCE, {'standalone': {add: CONSULTED}})
        self.assertEqual((self.ids(both, 'applied'), both['complete']), (['link-remove:MS-B1->TASK-004', add], True), 'the removal is applied first')

    def test_partial_results_are_reported(self):
        save = self.stored([{'select': 'TASK-003'}, {'set': {'owner': '担当X'}}, {'apply': True}, {'remove': {'prerequisite': 'TASK-002', 'successor': 'TASK-003'}}], 'S-1')
        self.db_owner('db-1', 'TASK-003', '担当C', '担当Y')
        out = sa.apply_groups(self.conn, save, ['task:TASK-003', REM], ACTOR, EVIDENCE)
        self.assertEqual((self.ids(out, 'applied'), self.ids(out, 'conflict'), out['complete']), ([REM], ['task:TASK-003'], False))


if __name__ == '__main__':
    sys.exit(0 if unittest.main(exit=False, verbosity=2 if '-v' in sys.argv else 1).result.wasSuccessful() else 1)
