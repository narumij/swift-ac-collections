#!/usr/bin/env python3
"""OPS-171 tests: proposal registration (K4) from real Studio saves: one register_proposal operation numbers the draft
and writes every incident connection with the formal ID, or nothing. Explicit resolution and explicit ancestry only.

Run: python3 -B Maintanance/RegistryApp/v3/test_proposal_registration.py -v
"""
import copy
import sys
import unittest
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
import registry_v3_recovery as rc  # noqa: E402
import registry_v3_write as w3  # noqa: E402
import studio_adapter as sa  # noqa: E402
from test_change_groups import Groups  # noqa: E402
from test_studio_adapter import ACTOR, EVIDENCE  # noqa: E402

P1 = 'proposal:draft-1'
FIELDS = {'state': 'PROPOSED', 'owner': '担当F', 'condition': '着手の条件', 'detail': 'Maintanance/Current/新規.md', 'group': '現行'}
INDEPENDENT = {'independent': True}


def resolution(constraints, prefix='TASK', fields=FIELDS):
    return {'proposals': {P1: {'prefix': prefix, 'fields': fields, 'constraints': constraints, 'evidence': ['会話 2026-10-19']}}}


class Proposal(Groups):
    def with_links(self, save_id='S-1'):
        # draft-1 -> TASK-003 (dialog place), TASK-004 -> draft-1 (proposal editor), draft-1 -> END-0.3.0 (proposal editor)
        return self.stored([{'proposal': {'title': '新しい提案', 'memo': 'メモ', 'place': 'task:TASK-003'}},
                            {'set': {'proposalPre': 'TASK-004'}}, {'press': '前提に追加'},
                            {'set': {'proposalTarget': 'END-0.3.0'}}, {'press': '到達点へつなぐ'}], save_id)

    CONSTRAINTS = {'edge:draft-1->TASK-003': '判断材料。', 'edge:TASK-004->draft-1': 'B1の後に始める', 'link:draft-1->END-0.3.0': 'この到達点の前に完了が必要。'}

    def state(self):
        c = self.conn
        return (c.execute('SELECT * FROM id_allocations').fetchall(), c.execute('SELECT * FROM proposal_map').fetchall(), c.execute('SELECT * FROM graph_edges ORDER BY 1,2,3').fetchall(),
                c.execute("SELECT COUNT(*) FROM nodes WHERE kind = 'task'").fetchone()[0], w3.revision(c))

    def rejected(self, call, words):
        before = self.state()
        with self.assertRaises(sa.SaveRejected) as caught:
            call()
        self.assertIn(words, str(caught.exception))
        self.assertEqual(self.state(), before)


class Register(Proposal):
    def test_registers_the_draft_and_all_its_connections_in_one_operation(self):
        save = self.with_links()
        group = next(g for g in sa.plan_groups(self.conn, save) if g['groupId'] == P1)
        self.assertEqual((group['status'], sorted(group['consumes'])), ('pending', ['edge-add:TASK-004->draft-1', 'edge-add:draft-1->TASK-003', 'link-add:draft-1->END-0.3.0']))
        self.assertNotIn('edge-add:draft-1->TASK-003', [g['groupId'] for g in sa.plan_groups(self.conn, save)], 'incident connections are not structural groups')
        out = sa.apply_groups(self.conn, save, [P1], ACTOR, EVIDENCE, resolution(self.CONSTRAINTS), INDEPENDENT)
        self.assertEqual((self.ids(out, 'applied'), out['complete']), ([P1], True))
        result = out['applied'][0]['result']
        self.assertEqual((result['id'], result['connections']), ('TASK-006', 3))
        self.assertEqual(self.conn.execute("SELECT * FROM proposal_map").fetchall(), [('S-1', 'draft-1', 'TASK-006')])
        self.assertEqual(self.conn.execute("SELECT state, owner, item, task_group FROM tasks WHERE id = 'TASK-006'").fetchone(), ('PROPOSED', '担当F', '新しい提案', '現行'))
        self.assertEqual(self.edge('progress', 'TASK-006', 'TASK-003'), ('SEQUENCE', '判断材料。'))
        self.assertEqual(self.edge('progress', 'TASK-004', 'TASK-006'), ('SEQUENCE', 'B1の後に始める'))
        self.assertEqual(self.edge('milestone', 'TASK-006', 'END-0.3.0'), (None, 'この到達点の前に完了が必要。'))
        self.assertEqual(w3.revision(self.conn), 1, 'one operation')
        self.assertIsNone(self.conn.execute("SELECT 1 FROM graph_edges WHERE prerequisite LIKE 'draft-%' OR successor LIKE 'draft-%'").fetchone(), 'no draft ID left')

    def edge(self, graph, a, b):
        return self.conn.execute('SELECT flow, constraint_text FROM graph_edges WHERE graph = ? AND prerequisite = ? AND successor = ?', (graph, a, b)).fetchone()

    def test_replay_and_changed_resolution(self):
        save = self.with_links()
        first = sa.apply_groups(self.conn, save, [P1], ACTOR, EVIDENCE, resolution(self.CONSTRAINTS), INDEPENDENT)
        before = self.state()
        again = sa.apply_groups(self.conn, save, [P1], ACTOR, EVIDENCE, resolution(self.CONSTRAINTS), INDEPENDENT)
        self.assertEqual((self.ids(again, 'replayed'), again['replayed'][0]['result']), ([P1], first['applied'][0]['result']))
        self.assertEqual(self.state(), before, 'no second number')
        changed = sa.apply_groups(self.conn, save, [P1], ACTOR, EVIDENCE, resolution(dict(self.CONSTRAINTS, **{'edge:draft-1->TASK-003': '別の条件'})), INDEPENDENT)
        self.assertEqual(self.ids(changed, 'changedContent'), [P1])
        with self.assertRaises(w3.Refused) as caught:  # the same key through another operation
            w3.apply(self.conn, 'other', {'kind': 'register_task', 'prefix': 'TASK', 'fields': dict(FIELDS, item='x'), 'proposal': {'saveId': 'S-1', 'draftId': 'draft-1'},
                                          'generation': w3.generation(self.conn), 'actor': ACTOR, 'evidence': []})
        self.assertIn('already registered as TASK-006', str(caught.exception))

    def test_failure_rolls_back_the_number_and_every_connection(self):
        # TASK-003 -> draft-1 -> MS-A1 closes a cycle (MS-A1 is before START-0.2.0 -> TASK-003). Studio's own check() refuses
        # to add that edge in the editor, so it is appended to the saved JSON to reach the DB-side validation and rollback.
        save = self.stored([{'proposal': {'title': '循環する提案', 'place': 'ms:MS-A1'}}], 'S-1')
        save['edges'].append({'prerequisite': 'TASK-003', 'successor': 'draft-1', 'flow': 'SEQUENCE', 'constraint': '', 'conditionReview': '相談待ち', 'raw': None, 'sourceLine': None})
        before = self.state()
        out = sa.apply_groups(self.conn, save, [P1], ACTOR, EVIDENCE, resolution({'link:draft-1->MS-A1': 'x', 'edge:TASK-003->draft-1': 'y'}), INDEPENDENT)
        self.assertEqual(self.ids(out, 'refused'), [P1])
        self.assertIn('cycle', out['refused'][0]['error'])
        self.assertEqual(self.state(), before, 'no number, no mapping, no connection')
        self.assertEqual(w3.operation(self.conn, sa.unit_operation_id('S-1', P1))['status'], 'refused')


class Pending(Proposal):
    def test_unresolved_and_partly_resolved(self):
        save = self.with_links()
        out = sa.apply_groups(self.conn, save, [P1], ACTOR, EVIDENCE, None, INDEPENDENT)
        self.assertEqual(out['pending'], [{'groupId': P1, 'needs': ['registration']}])
        self.assertEqual(self.state()[1], [])
        missing = dict(self.CONSTRAINTS)
        missing.pop('link:draft-1->END-0.3.0')
        self.rejected(lambda: sa.apply_groups(self.conn, save, [P1], ACTOR, EVIDENCE, resolution(missing), INDEPENDENT), 'a consulted constraint is required for exactly these connections')
        self.rejected(lambda: sa.apply_groups(self.conn, save, [P1], ACTOR, EVIDENCE, resolution(dict(self.CONSTRAINTS, **{'link:draft-1->END-0.3.0': ' '})), INDEPENDENT), 'consulted constraint')
        self.rejected(lambda: sa.apply_groups(self.conn, save, [P1], ACTOR, EVIDENCE, resolution(self.CONSTRAINTS, prefix='task'), INDEPENDENT), 'prefix (A-Z)')
        r = resolution(self.CONSTRAINTS)
        r['proposals'][P1]['evidence'] = []
        self.rejected(lambda: sa.apply_groups(self.conn, save, [P1], ACTOR, EVIDENCE, r, INDEPENDENT), 'evidence')
        bad = sa.apply_groups(self.conn, save, [P1], ACTOR, EVIDENCE, resolution(self.CONSTRAINTS, fields={'state': 'PROPOSED'}), INDEPENDENT)
        self.assertEqual(self.ids(bad, 'refused'), [P1])
        self.assertIn('fields must be given explicitly', bad['refused'][0]['error'])

    def test_ancestry_must_be_stated(self):
        save = self.with_links()
        for ancestry in (None, {}, {'ancestors': []}, {'independent': False}):
            out = sa.apply_groups(self.conn, save, [P1], ACTOR, EVIDENCE, resolution(self.CONSTRAINTS), ancestry)
            self.assertEqual(out['pending'], [{'groupId': P1, 'needs': ['identity: ancestry not stated (state independent or the known ancestor saves)']}], ancestry)
        self.assertEqual(self.state()[1], [], 'missing ancestry is not taken as independent')

    def test_existing_ancestor_mapping_stays_pending(self):
        sa.apply_groups(self.conn, self.with_links('S-1'), [P1], ACTOR, EVIDENCE, resolution(self.CONSTRAINTS), INDEPENDENT)
        child = self.stored([{'proposal': {'title': '新しい提案', 'place': 'task:TASK-003'}}], 'S-2')
        out = sa.apply_groups(self.conn, child, [P1], ACTOR, EVIDENCE, resolution({'edge:draft-1->TASK-003': '判断材料。'}), {'ancestors': ['S-1']})
        self.assertEqual(out['pending'], [{'groupId': P1, 'needs': ['identity: ancestor save S-1 registered draft-1 as TASK-006']}])
        other = sa.apply_groups(self.conn, child, [P1], ACTOR, EVIDENCE, resolution({'edge:draft-1->TASK-003': '判断材料。'}), INDEPENDENT)
        self.assertEqual(other['applied'][0]['result']['id'], 'TASK-007', 'stated independent: its own key, no inference either way')


class IdentityRace(Proposal):
    """Acceptance (2026-10-19): the declared ancestry is enforced in the write transaction, not only in the preflight."""

    def test_ancestor_registered_between_preflight_and_write(self):
        ancestor, child = self.with_links('ancestor'), self.with_links('child')
        other = self.open(self.dir / 'db.sqlite3')
        def ancestor_registers_first():
            sa.apply_groups(other, ancestor, [P1], ACTOR, EVIDENCE, resolution(self.CONSTRAINTS), INDEPENDENT)
        out = sa.apply_groups(self.conn, child, [P1], ACTOR, EVIDENCE, resolution(self.CONSTRAINTS), {'ancestors': ['ancestor']}, _after_preflight=ancestor_registers_first)
        self.assertEqual((self.ids(out, 'applied'), out['pending']), ([], [{'groupId': P1, 'needs': ['identity: ancestor save ancestor registered draft-1 as TASK-006']}]))
        self.assertEqual(self.conn.execute('SELECT * FROM proposal_map').fetchall(), [('ancestor', 'draft-1', 'TASK-006')], 'no duplicate allocation')
        self.assertEqual(self.conn.execute("SELECT highwater FROM id_allocations WHERE prefix = 'TASK'").fetchone()[0], 6)
        self.assertIsNone(w3.operation(self.conn, sa.unit_operation_id('child', P1)), 'a held identity leaves no operation and no claim')
        self.assertEqual(self.conn.execute("SELECT COUNT(*) FROM consumption_claims WHERE scope = 'child'").fetchone()[0], 0)

    def test_identity_change_under_the_same_operation(self):
        save = self.with_links('S-1')
        sa.apply_groups(self.conn, save, [P1], ACTOR, EVIDENCE, resolution(self.CONSTRAINTS), INDEPENDENT)
        again = sa.apply_groups(self.conn, save, [P1], ACTOR, EVIDENCE, resolution(self.CONSTRAINTS), INDEPENDENT)
        self.assertEqual(self.ids(again, 'replayed'), [P1])
        changed = sa.apply_groups(self.conn, save, [P1], ACTOR, EVIDENCE, resolution(self.CONSTRAINTS), {'ancestors': ['other-save']})
        self.assertEqual(self.ids(changed, 'changedContent'), [P1], 'the declared ancestry is part of the request')

    def test_direct_registration_needs_declared_ancestry(self):
        req = {'kind': 'register_proposal', 'prefix': 'TASK', 'fields': dict(FIELDS, item='x'), 'proposal': {'saveId': 'S-9', 'draftId': 'draft-1'},
               'edges': [], 'links': [], 'generation': w3.generation(self.conn), 'actor': ACTOR, 'evidence': []}
        for ancestry in (None, {}, {'independent': False}, {'ancestors': []}, {'ancestors': ['']}, {'independent': True, 'ancestors': ['a']}):
            r = dict(req) if ancestry is None else dict(req, ancestry=ancestry)
            with self.assertRaises(w3.IdentityHeld):
                w3.apply(self.conn, 'direct', r)
        self.assertEqual(self.state()[1], [])
        sa.apply_groups(self.conn, self.with_links('A-1'), [P1], ACTOR, EVIDENCE, resolution(self.CONSTRAINTS), INDEPENDENT)
        with self.assertRaises(w3.IdentityHeld) as caught:
            w3.apply(self.conn, 'direct', dict(req, ancestry={'ancestors': ['A-1']}))
        self.assertIn('ancestor save A-1 registered draft-1 as TASK-006', str(caught.exception))
        self.assertEqual(w3.apply(self.conn, 'direct', dict(req, ancestry={'independent': True}))['id'], 'TASK-007')

    def test_field_types_are_validated(self):
        req = {'kind': 'register_proposal', 'prefix': 'TASK', 'proposal': {'saveId': 'S-9', 'draftId': 'draft-1'}, 'edges': [], 'links': [], 'ancestry': {'independent': True},
               'generation': w3.generation(self.conn), 'actor': ACTOR, 'evidence': []}
        good = dict(FIELDS, item='x')
        for bad in ({'condition': 3}, {'detail': None}, {'group': ''}, {'group': 5}, {'state': ' '}, {'owner': ['a']}):
            with self.assertRaises(w3.Refused):
                w3.apply(self.conn, 'bad-' + next(iter(bad)) + str(len(str(bad))), dict(req, fields=dict(good, **bad)))
        self.assertEqual(self.state()[1], [])
        self.assertEqual(w3.apply(self.conn, 'ok', dict(req, fields=dict(good, group=None)))['id'], 'TASK-006')


class Boundaries(Proposal):
    def test_draft_to_draft_is_unsupported(self):
        save = self.stored([{'proposal': {'title': '一つ目', 'place': ''}}, {'proposal': {'title': '二つ目', 'place': 'task:draft-1'}}], 'S-1')
        groups = {g['groupId']: g for g in sa.plan_groups(self.conn, save)}
        self.assertEqual((groups[P1]['status'], groups['proposal:draft-2']['status']), ('unsupported', 'unsupported'))
        res = {'proposals': {P1: {'prefix': 'TASK', 'fields': FIELDS, 'constraints': {'edge:draft-2->draft-1': 'x'}, 'evidence': ['e']}}}
        before = self.state()
        out = sa.apply_groups(self.conn, save, [P1, 'proposal:draft-2'], ACTOR, EVIDENCE, res, INDEPENDENT)
        self.assertEqual(self.ids(out, 'refused'), [P1, 'proposal:draft-2'])
        self.assertIn('draft-to-draft', out['refused'][0]['error'])
        self.assertEqual(self.state(), before)
        with self.assertRaises(w3.Refused) as caught:  # the write side refuses it too, not only the adapter
            w3.apply(self.conn, 'direct', {'kind': 'register_proposal', 'prefix': 'TASK', 'fields': dict(FIELDS, item='x'), 'proposal': {'saveId': 'S-9', 'draftId': 'draft-1'},
                                           'edges': [{'prerequisite': 'draft-2', 'successor': 'draft-1', 'flow': 'SEQUENCE', 'constraint': 'x'}], 'links': [], 'ancestry': {'independent': True},
                                           'generation': w3.generation(self.conn), 'actor': ACTOR, 'evidence': []})
        self.assertIn('draft-to-draft', str(caught.exception))
        self.assertEqual(self.state()[:4], before[:4])

    def test_incident_connections_cannot_be_applied_as_structural_groups(self):
        save = self.with_links()
        gid = 'edge-add:draft-1->TASK-003'
        self.rejected(lambda: sa.apply_groups(self.conn, save, [gid], ACTOR, EVIDENCE, None, INDEPENDENT), 'names no unit')
        self.rejected(lambda: sa.apply_groups(self.conn, save, [gid], ACTOR, EVIDENCE, {'standalone': {gid: {'constraint': 'x', 'evidence': ['e']}}}, INDEPENDENT), 'no structural group')
        sa.apply_groups(self.conn, save, [P1], ACTOR, EVIDENCE, resolution(self.CONSTRAINTS), INDEPENDENT)
        claims = [r[0] for r in self.conn.execute('SELECT constituent FROM consumption_claims ORDER BY 1')]
        self.assertEqual(claims, sorted([P1, 'edge-add:TASK-004->draft-1', gid, 'link-add:draft-1->END-0.3.0']))

    def test_restored_generation_stays_closed(self):
        rc.backup(self.conn, self.dir / 'b.sqlite3')
        rc.restore(self.dir / 'b.sqlite3', self.dir / 'r.sqlite3', ACTOR, EVIDENCE)
        restored = self.open(self.dir / 'r.sqlite3')
        with self.assertRaises(w3.WriteDisabled):
            w3.apply(restored, 'p', {'kind': 'register_proposal', 'prefix': 'TASK', 'fields': dict(FIELDS, item='x'), 'proposal': {'saveId': 'S-1', 'draftId': 'draft-1'},
                                     'edges': [], 'links': [], 'generation': w3.generation(restored), 'actor': ACTOR, 'evidence': []})
        self.assertEqual(restored.execute('SELECT COUNT(*) FROM proposal_map').fetchone()[0], 0)

    def test_single_task_path_still_rejects_proposals(self):
        save = self.with_links()
        with self.assertRaises(sa.SaveRejected) as caught:
            sa.plan_save(self.conn, save)
        self.assertIn('proposals', str(caught.exception))


if __name__ == '__main__':
    sys.exit(0 if unittest.main(exit=False, verbosity=2 if '-v' in sys.argv else 1).result.wasSuccessful() else 1)
