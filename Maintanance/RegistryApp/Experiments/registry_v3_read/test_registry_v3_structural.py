#!/usr/bin/env python3
"""OPS-169 K2 tests: structural writes (progress/management edge remove, rewire and progress flow/constraint; milestone
link add/remove/set/rewire for the supported directions; task group). Expected values are written by hand. Every
refusal leaves the structure unchanged and is recorded; rewires roll back fully when they fail between remove and add.

Run: python3 -B Maintanance/RegistryApp/Experiments/registry_v3_read/test_registry_v3_structural.py -v
"""
import copy
import json
import sys
import tempfile
import unittest
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
import registry_v3_write as w3  # noqa: E402

BASE = json.loads((HERE / 'fixtures' / 'base.json').read_text(encoding='utf-8'))
ACTOR, EVIDENCE = '姫（試験）', ['TASK_REGISTRY_V3_STRUCTURAL_WRITES.md#初回内訳の限定採用（2026-10-19）']


class Structural(unittest.TestCase):
    def setUp(self):
        tmp = tempfile.TemporaryDirectory()
        self.addCleanup(tmp.cleanup)
        path = str(Path(tmp.name) / 'db.sqlite3')
        w3.create(path, copy.deepcopy(BASE))
        self.conn = w3.open_db(path)
        self.addCleanup(self.conn.close)
        self.n = 0

    def op(self, hook=None, op=None, **req):
        self.n += 1
        return w3.apply(self.conn, op or f'op-{self.n}', dict(req, generation=w3.generation(self.conn), actor=ACTOR, evidence=EVIDENCE), hook)

    def structure(self):
        return (self.conn.execute('SELECT * FROM graph_edges ORDER BY 1, 2, 3').fetchall(), self.conn.execute('SELECT * FROM tasks ORDER BY id').fetchall(), w3.revision(self.conn))

    def edge(self, graph, a, b):
        return self.conn.execute('SELECT flow, constraint_text FROM graph_edges WHERE graph = ? AND prerequisite = ? AND successor = ?', (graph, a, b)).fetchone()

    def refused(self, words, **req):
        before = self.structure()
        with self.assertRaises(w3.Refused) as caught:
            self.op(**req)
        self.assertIn(words, str(caught.exception))
        self.assertEqual(self.structure(), before, 'a refusal changes nothing')
        self.assertEqual(w3.operation(self.conn, f'op-{self.n}')['status'], 'refused')
        return str(caught.exception)


class Edges(Structural):
    def test_remove_progress_edge_with_base(self):
        self.refused('conflict on progress edge TASK-002 -> TASK-003: constraint changed', kind='remove_edge', graph='progress', prerequisite='TASK-002', successor='TASK-003',
                     base={'flow': 'SEQUENCE', 'constraint': '古い条件'})
        r = self.op(kind='remove_edge', graph='progress', prerequisite='TASK-002', successor='TASK-003', base={'flow': 'SEQUENCE', 'constraint': 'Aの結果を使う（同じ版の中）'})
        self.assertIsNone(self.edge('progress', 'TASK-002', 'TASK-003'))
        rec = w3.operation(self.conn, f'op-{self.n}')
        self.assertEqual((rec['before']['constraint'], rec['after']), ('Aの結果を使う（同じ版の中）', None))
        self.refused('it no longer exists', kind='remove_edge', graph='progress', prerequisite='TASK-002', successor='TASK-003', base={'flow': 'SEQUENCE', 'constraint': 'Aの結果を使う（同じ版の中）'})
        self.assertEqual(self.op(op=f'op-2', kind='remove_edge', graph='progress', prerequisite='TASK-002', successor='TASK-003',
                                 base={'flow': 'SEQUENCE', 'constraint': 'Aの結果を使う（同じ版の中）'}), r, 'replay')

    def test_remove_management_edge(self):
        self.refused('base must be exactly {} for management', kind='remove_edge', graph='management', prerequisite='TASK-001', successor='TASK-002', base={'constraint': ''})
        self.op(kind='remove_edge', graph='management', prerequisite='TASK-001', successor='TASK-002', base={})
        self.assertIsNone(self.edge('management', 'TASK-001', 'TASK-002'))

    def test_set_progress_flow_and_constraint(self):
        self.op(kind='set_edge', graph='progress', prerequisite='TASK-002', successor='TASK-003', base={'flow': 'SEQUENCE', 'constraint': 'Aの結果を使う（同じ版の中）'},
                changes={'flow': 'PARALLEL_JOIN', 'constraint': '並行してよい | 合流は後続の完了まで'})
        self.assertEqual(self.edge('progress', 'TASK-002', 'TASK-003'), ('PARALLEL_JOIN', '並行してよい | 合流は後続の完了まで'))
        self.refused('conflict on progress edge TASK-002 -> TASK-003: flow changed', kind='set_edge', graph='progress', prerequisite='TASK-002', successor='TASK-003',
                     base={'flow': 'SEQUENCE'}, changes={'flow': 'SEQUENCE'})
        self.refused('flow must be', kind='set_edge', graph='progress', prerequisite='TASK-002', successor='TASK-003', base={'flow': 'PARALLEL_JOIN'}, changes={'flow': 'MAYBE'})
        self.refused('must not be empty', kind='set_edge', graph='progress', prerequisite='TASK-002', successor='TASK-003',
                     base={'constraint': '並行してよい | 合流は後続の完了まで'}, changes={'constraint': '  '})
        self.refused('only progress edges', kind='set_edge', graph='management', prerequisite='TASK-001', successor='TASK-002', base={}, changes={'flow': 'SEQUENCE'})

    def test_rewire_progress_edge(self):
        base = {'flow': 'SEQUENCE', 'constraint': 'Aの結果を使う（同じ版の中）'}
        self.refused('explicit constraint text is required', kind='rewire_edge', graph='progress', **{'from': {'prerequisite': 'TASK-002', 'successor': 'TASK-003'}},
                     to={'prerequisite': 'TASK-002', 'successor': 'TASK-004'}, base=base)
        self.op(kind='rewire_edge', graph='progress', **{'from': {'prerequisite': 'TASK-002', 'successor': 'TASK-003'}}, to={'prerequisite': 'TASK-002', 'successor': 'TASK-004'},
                base=base, constraint='相談して決めた条件')
        self.assertIsNone(self.edge('progress', 'TASK-002', 'TASK-003'))
        self.assertEqual(self.edge('progress', 'TASK-002', 'TASK-004'), ('SEQUENCE', '相談して決めた条件'))

    def test_rewire_refusals_leave_the_old_edge(self):
        base = {'flow': 'SEQUENCE', 'constraint': 'Aの結果を使う（同じ版の中）'}
        frm = {'prerequisite': 'TASK-002', 'successor': 'TASK-003'}
        # TASK-004 -> TASK-002 would close a cycle: TASK-002 -> MS-A2 -> ... -> START-0.2.0 -> MS-B1 -> TASK-004 (links and skeleton)
        self.refused('progress cycle', kind='rewire_edge', graph='progress', **{'from': frm}, to={'prerequisite': 'TASK-004', 'successor': 'TASK-002'}, base=base, constraint='x')
        self.op(kind='add_edge', graph='progress', prerequisite='TASK-001', successor='TASK-004', flow='SEQUENCE', constraint='y')
        self.refused('already exists', kind='rewire_edge', graph='progress', **{'from': frm}, to={'prerequisite': 'TASK-001', 'successor': 'TASK-004'}, base=base, constraint='x')
        self.op(kind='retire_task', id='TASK-005', reason='試験')
        self.refused('TASK-005 is retired', kind='rewire_edge', graph='progress', **{'from': frm}, to={'prerequisite': 'TASK-005', 'successor': 'TASK-003'}, base=base, constraint='x')
        self.refused('is not a task', kind='rewire_edge', graph='progress', **{'from': frm}, to={'prerequisite': 'MS-B1', 'successor': 'TASK-003'}, base=base, constraint='x')
        self.refused('conflict on progress edge TASK-002 -> TASK-003: flow changed', kind='rewire_edge', graph='progress', **{'from': frm},
                     to={'prerequisite': 'TASK-001', 'successor': 'TASK-003'}, base=dict(base, flow='PARALLEL_JOIN'), constraint='x')
        self.assertEqual(self.edge('progress', 'TASK-002', 'TASK-003'), ('SEQUENCE', 'Aの結果を使う（同じ版の中）'))

    def test_rewire_failure_between_remove_and_add_rolls_back(self):
        before = self.structure()
        def fail(stage):
            if stage == 'between':
                raise RuntimeError('injected between remove and add')
        with self.assertRaises(RuntimeError):
            self.op(hook=fail, kind='rewire_edge', graph='progress', **{'from': {'prerequisite': 'TASK-002', 'successor': 'TASK-003'}},
                    to={'prerequisite': 'TASK-002', 'successor': 'TASK-004'}, base={'flow': 'SEQUENCE', 'constraint': 'Aの結果を使う（同じ版の中）'}, constraint='x')
        self.assertEqual(self.structure(), before)
        self.assertIsNone(w3.operation(self.conn, f'op-{self.n}'), 'an unexpected failure is not recorded')

    def test_management_rewire_keeps_the_existing_model(self):
        # no single-parent constraint is added: a child may get a second parent edge, as the existing model allows
        self.op(kind='add_edge', graph='management', prerequisite='TASK-003', successor='TASK-002')
        self.op(kind='rewire_edge', graph='management', **{'from': {'prerequisite': 'TASK-001', 'successor': 'TASK-002'}}, to={'prerequisite': 'TASK-004', 'successor': 'TASK-002'}, base={})
        self.assertEqual(self.conn.execute("SELECT prerequisite FROM graph_edges WHERE graph = 'management' ORDER BY 1").fetchall(), [('TASK-003',), ('TASK-004',)])
        self.op(kind='add_edge', graph='management', prerequisite='TASK-002', successor='TASK-005')
        self.refused('management cycle', kind='rewire_edge', graph='management', **{'from': {'prerequisite': 'TASK-002', 'successor': 'TASK-005'}},
                     to={'prerequisite': 'TASK-002', 'successor': 'TASK-004'}, base={})
        # a progress edge opposite a management edge is not a cycle
        self.op(kind='add_edge', graph='progress', prerequisite='TASK-002', successor='TASK-004', flow='SEQUENCE', constraint='z')

    def test_changed_request_under_the_same_id(self):
        self.op(op='fixed', kind='remove_edge', graph='management', prerequisite='TASK-001', successor='TASK-002', base={})
        with self.assertRaises(w3.OperationMismatch):
            self.op(op='fixed', kind='remove_edge', graph='progress', prerequisite='TASK-002', successor='TASK-003', base={'flow': 'SEQUENCE', 'constraint': 'Aの結果を使う（同じ版の中）'})
        self.assertIsNotNone(self.edge('progress', 'TASK-002', 'TASK-003'))


class StrictBase(Structural):
    """Acceptance corrections (2026-10-19): destructive ops need the exact full base, setters exactly their fields, and
    setters need live endpoints. Every refusal leaves the structure and revision unchanged (a refusal record is fine)."""
    P = {'prerequisite': 'TASK-002', 'successor': 'TASK-003'}
    FULL = {'flow': 'SEQUENCE', 'constraint': 'Aの結果を使う（同じ版の中）'}

    def test_progress_remove_and_rewire_need_the_full_base(self):
        for base, words in (({}, 'base must be exactly constraint, flow'), ({'flow': 'SEQUENCE'}, 'base must be exactly constraint, flow'),
                            (dict(self.FULL, extra=1), 'base must be exactly constraint, flow'), ('SEQUENCE', 'base must be exactly')):
            self.refused(words, kind='remove_edge', graph='progress', base=base, **self.P)
            self.refused(words, kind='rewire_edge', graph='progress', **{'from': self.P}, to={'prerequisite': 'TASK-002', 'successor': 'TASK-004'}, base=base, constraint='x')
        self.refused('base must be exactly', kind='remove_edge', graph='progress', **self.P)  # no base at all
        self.op(kind='remove_edge', graph='progress', base=self.FULL, **self.P)
        self.assertIsNone(self.edge('progress', 'TASK-002', 'TASK-003'))

    def test_management_needs_an_explicit_empty_base(self):
        self.refused('base must be exactly {} for management', kind='remove_edge', graph='management', prerequisite='TASK-001', successor='TASK-002')
        self.refused('base must be exactly {} for management', kind='rewire_edge', graph='management', **{'from': {'prerequisite': 'TASK-001', 'successor': 'TASK-002'}},
                     to={'prerequisite': 'TASK-004', 'successor': 'TASK-002'})
        self.op(kind='remove_edge', graph='management', prerequisite='TASK-001', successor='TASK-002', base={})

    def test_milestone_remove_and_rewire_need_the_constraint_base(self):
        link = {'prerequisite': 'MS-B1', 'successor': 'TASK-004'}
        for base in ({}, {'constraint': 'B1の後', 'flow': None}, None):
            req = dict(link, kind='remove_milestone_link', **({} if base is None else {'base': base}))
            self.refused('base must be exactly constraint', **req)
            req = dict(kind='rewire_milestone_link', **{'from': link}, to={'prerequisite': 'MS-A2', 'successor': 'TASK-004'}, constraint='x', **({} if base is None else {'base': base}))
            self.refused('base must be exactly constraint', **req)
        self.op(kind='remove_milestone_link', base={'constraint': 'B1の後'}, **link)

    def test_setters_take_exactly_their_fields(self):
        self.refused('base must be exactly constraint', kind='set_edge', graph='progress', base=self.FULL, changes={'constraint': '新'}, **self.P)
        self.refused('base must be exactly constraint', kind='set_edge', graph='progress', base={}, changes={'constraint': '新'}, **self.P)
        self.refused('base must be exactly constraint', kind='set_milestone_link', prerequisite='MS-B1', successor='TASK-004', base={'constraint': 'B1の後', 'x': 1}, changes={'constraint': '新'})
        self.refused('base must be exactly group', kind='set_task_group', id='TASK-005', base={'group': None, 'state': 'PROPOSED'}, group='g')
        self.refused('base must be exactly group', kind='set_task_group', id='TASK-005', group='g')

    def test_setters_refuse_retired_endpoints_while_removal_still_cleans_up(self):
        self.op(kind='retire_task', id='TASK-003', reason='試験')
        self.refused('TASK-003 is retired', kind='set_edge', graph='progress', base={'constraint': self.FULL['constraint']}, changes={'constraint': '新'}, **self.P)
        self.refused('TASK-003 is retired', kind='set_milestone_link', prerequisite='TASK-003', successor='END-0.2.0', base={'constraint': 'Bの完了条件'}, changes={'constraint': '新'})
        self.op(kind='remove_edge', graph='progress', base=self.FULL, **self.P)
        self.op(kind='remove_milestone_link', prerequisite='TASK-003', successor='END-0.2.0', base={'constraint': 'Bの完了条件'})
        self.assertIsNone(self.edge('progress', 'TASK-002', 'TASK-003'))
        self.assertIsNone(self.edge('milestone', 'TASK-003', 'END-0.2.0'))


class Links(Structural):
    def test_supported_directions(self):
        # chosen so that no pair closes a cycle with the skeleton (TASK-004 -> MS-A1 would: MS-A1 is before MS-B1 -> TASK-004)
        for a, b in (('TASK-004', 'END-0.2.0'), ('TASK-005', 'MS-B1'), ('MS-A2', 'TASK-005'), ('START-0.3.0', 'TASK-001')):
            self.op(kind='add_milestone_link', prerequisite=a, successor=b, constraint='判断材料。' + a)
            self.assertEqual(self.edge('milestone', a, b), (None, '判断材料。' + a))

    def test_canonical_and_unsupported_refusals(self):
        msg = self.refused('canonical: tasks are not connected to a release gate', kind='add_milestone_link', prerequisite='TASK-004', successor='GATE-0.3.0', constraint='x')
        self.refused('canonical: tasks are not connected to a release gate', kind='add_milestone_link', prerequisite='GATE-0.2.0', successor='TASK-004', constraint='x')
        for a, b, kinds in (('END-0.2.0', 'TASK-005', 'end -> task'), ('TASK-005', 'START-0.3.0', 'task -> start')):
            msg = self.refused('experiment-unsupported direction ' + kinds, kind='add_milestone_link', prerequisite=a, successor=b, constraint='x')
            self.assertIn('not a canonical prohibition', msg)
        self.refused('exactly one task and one milestone node', kind='add_milestone_link', prerequisite='MS-A1', successor='MS-B1', constraint='x')
        self.refused('exactly one task and one milestone node', kind='add_milestone_link', prerequisite='TASK-004', successor='TASK-005', constraint='x')
        self.refused('already exists', kind='add_milestone_link', prerequisite='MS-B1', successor='TASK-004', constraint='x')
        self.refused('explicit constraint text is required', kind='add_milestone_link', prerequisite='TASK-005', successor='END-0.3.0', constraint='')
        self.refused('milestone cycle', kind='add_milestone_link', prerequisite='TASK-003', successor='MS-A1', constraint='x')

    def test_remove_set_and_rewire(self):
        self.refused('conflict on milestone link MS-B1 -> TASK-004: constraint changed', kind='remove_milestone_link', prerequisite='MS-B1', successor='TASK-004', base={'constraint': '別'})
        self.op(kind='set_milestone_link', prerequisite='MS-B1', successor='TASK-004', base={'constraint': 'B1の後'}, changes={'constraint': '到達後。B1の確認'})
        self.assertEqual(self.edge('milestone', 'MS-B1', 'TASK-004')[1], '到達後。B1の確認')
        self.op(kind='rewire_milestone_link', **{'from': {'prerequisite': 'MS-B1', 'successor': 'TASK-004'}}, to={'prerequisite': 'MS-A2', 'successor': 'TASK-004'},
                base={'constraint': '到達後。B1の確認'}, constraint='到達後。A2の確認')
        self.assertIsNone(self.edge('milestone', 'MS-B1', 'TASK-004'))
        self.assertEqual(self.edge('milestone', 'MS-A2', 'TASK-004')[1], '到達後。A2の確認')
        self.op(kind='remove_milestone_link', prerequisite='MS-A2', successor='TASK-004', base={'constraint': '到達後。A2の確認'})
        self.assertIsNone(self.edge('milestone', 'MS-A2', 'TASK-004'))

    def test_link_rewire_rolls_back(self):
        before = self.structure()
        self.refused('experiment-unsupported direction', kind='rewire_milestone_link', **{'from': {'prerequisite': 'MS-B1', 'successor': 'TASK-004'}},
                     to={'prerequisite': 'END-0.2.0', 'successor': 'TASK-004'}, base={'constraint': 'B1の後'}, constraint='x')
        def fail(stage):
            if stage == 'between':
                raise RuntimeError('injected')
        with self.assertRaises(RuntimeError):
            self.op(hook=fail, kind='rewire_milestone_link', **{'from': {'prerequisite': 'MS-B1', 'successor': 'TASK-004'}},
                    to={'prerequisite': 'MS-A2', 'successor': 'TASK-004'}, base={'constraint': 'B1の後'}, constraint='x')
        self.assertEqual(self.structure()[:2], before[:2])
        self.assertEqual(self.edge('milestone', 'MS-B1', 'TASK-004')[1], 'B1の後')


class Tasks(Structural):
    def test_group(self):
        self.op(kind='set_task_group', id='TASK-005', base={'group': None}, group='新しい区分')
        self.assertEqual(self.conn.execute("SELECT task_group FROM tasks WHERE id = 'TASK-005'").fetchone()[0], '新しい区分')
        same = self.op(kind='set_task_group', id='TASK-005', base={'group': None}, group='新しい区分')
        self.assertTrue(same['alreadyReflected'])
        self.refused('conflict on TASK-005 group', kind='set_task_group', id='TASK-005', base={'group': None}, group='別の区分')
        self.refused('non-empty heading', kind='set_task_group', id='TASK-005', base={'group': '新しい区分'}, group='  ')
        self.op(kind='retire_task', id='TASK-004', reason='試験')
        self.refused('TASK-004 is retired', kind='set_task_group', id='TASK-004', base={'group': '現行'}, group='x')

    def test_experiment_unsupported_operations(self):
        for kind in ('reparent', 'set_task_permanent'):
            msg = self.refused('experiment-unsupported: ' + kind, kind=kind, id='TASK-002')
            self.assertIn('not a canonical prohibition', msg)


if __name__ == '__main__':
    sys.exit(0 if unittest.main(exit=False, verbosity=2 if '-v' in sys.argv else 1).result.wasSuccessful() else 1)
