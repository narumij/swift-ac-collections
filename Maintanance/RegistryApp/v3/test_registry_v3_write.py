#!/usr/bin/env python3
"""OPS-161 stage 2 tests: the update contract as Python calls on a SQLite file in a per-test TemporaryDirectory.
Cases follow TASK_REGISTRY_V3_CONTRACT_EXPERIMENT.md「区切り2の試験案」. Expected values are written by hand.
Each test owns its connections and its directory and closes/removes them at its end.

Run: python3 -B Maintanance/RegistryApp/v3/test_registry_v3_write.py -v
"""
import copy
import json
import sys
import tempfile
import threading
import unittest
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
import registry_v3_read as r3  # noqa: E402
import registry_v3_write as w3  # noqa: E402

BASE = json.loads((HERE / 'fixtures' / 'base.json').read_text(encoding='utf-8'))
def full(conn, request):
    """The request as the API requires it: explicit generation, self-declared actor, evidence references (OPS-164)."""
    return dict({'actor': '姫（試験）', 'evidence': []}, **request, generation=w3.generation(conn))


def apply(conn, operation_id, request, hook=None):
    return w3.apply(conn, operation_id, full(conn, request), hook)


NEW = {'state': 'PROPOSED', 'owner': '担当F', 'item': '新しい仕事', 'condition': '着手の条件', 'detail': 'Maintanance/Current/新規.md'}


class Db(unittest.TestCase):
    def setUp(self):
        tmp = tempfile.TemporaryDirectory()
        self.addCleanup(tmp.cleanup)
        self.path = str(Path(tmp.name) / 'v3.sqlite3')
        w3.create(self.path, copy.deepcopy(BASE))
        self.conn = self.connect()

    def connect(self):
        conn = w3.open_db(self.path)
        self.addCleanup(conn.close)
        return conn

    def state(self):
        c = self.conn
        return {'revision': w3.revision(c), 'highwater': dict(c.execute('SELECT prefix, highwater FROM id_allocations')),
                'issued': [r[0] for r in c.execute('SELECT id FROM issued_ids ORDER BY prefix, number')],
                'operations': c.execute('SELECT operation_id, status, result, revision FROM operations ORDER BY operation_id').fetchall(),
                'tasks': c.execute('SELECT * FROM tasks ORDER BY id').fetchall(), 'edges': c.execute('SELECT * FROM graph_edges ORDER BY 1, 2, 3').fetchall(),
                'retired': c.execute('SELECT id FROM retirements').fetchall(), 'proposals': c.execute('SELECT * FROM proposal_map').fetchall()}

    def task(self, tid):
        return dict(zip(('state', 'owner', 'item', 'condition', 'detail'), self.conn.execute('SELECT state, owner, item, condition, detail FROM tasks WHERE id = ?', (tid,)).fetchone()))

    def race(self, first, second):
        """Run first on one connection until it is validated and holds the write lock, start second on another connection,
        then let first commit. Returns (first result or error, second result or error, second_started_before_commit)."""
        held, release, out = threading.Event(), threading.Event(), {}
        def hook(stage):
            held.set()
            assert release.wait(5)
        def run(name, op, req, hook=None):
            conn = w3.open_db(self.path)
            try:
                out[name] = apply(conn, op, req, hook)
            except Exception as error:  # returned to the test
                out[name] = error
            finally:
                conn.close()
        a = threading.Thread(target=run, args=('a', *first, hook))
        a.start()
        self.assertTrue(held.wait(5))
        b = threading.Thread(target=run, args=('b', *second))
        b.start()
        b.join(0.3)
        waiting = b.is_alive() and 'b' not in out  # b waits for a's write lock
        release.set()
        a.join(5)
        b.join(5)
        return out['a'], out['b'], waiting


class Register(Db):
    def test_two_connections_get_distinct_numbers(self):
        a, b, waiting = self.race(('op-a', {'kind': 'register_task', 'prefix': 'TASK', 'fields': NEW}),
                                  ('op-b', {'kind': 'register_task', 'prefix': 'TASK', 'fields': dict(NEW, item='もう一つ')}))
        self.assertTrue(waiting, 'the second registration waited for the first transaction')
        self.assertEqual((a['id'], a['revision']), ('TASK-006', 1))
        self.assertEqual((b['id'], b['revision']), ('TASK-007', 2))
        s = self.state()
        self.assertEqual(s['highwater'], {'TASK': 7})
        self.assertEqual(s['issued'][-2:], ['TASK-006', 'TASK-007'])
        self.assertEqual([(o[0], o[1], o[3]) for o in s['operations']], [('op-a', 'done', 1), ('op-b', 'done', 2)])
        self.assertEqual(self.task('TASK-007')['item'], 'もう一つ')

    def test_replay_returns_the_same_result_without_writing(self):
        req = {'kind': 'register_task', 'prefix': 'TASK', 'fields': NEW}
        first = apply(self.conn, 'op-1', req)
        before = self.state()
        again = apply(self.connect(), 'op-1', copy.deepcopy(req))
        self.assertEqual(again, first)
        self.assertEqual(self.state(), before, 'no new number, revision or record')

    def test_same_id_with_another_request_is_refused(self):
        first = apply(self.conn, 'op-1', {'kind': 'register_task', 'prefix': 'TASK', 'fields': NEW})
        before = self.state()
        with self.assertRaises(w3.OperationMismatch):
            apply(self.conn, 'op-1', {'kind': 'register_task', 'prefix': 'TASK', 'fields': dict(NEW, item='別の内容')})
        self.assertEqual(self.state(), before)
        self.assertEqual(json.loads(before['operations'][0][2]), first)

    def test_proposal_key_maps_once(self):
        req = {'kind': 'register_task', 'prefix': 'TASK', 'fields': NEW, 'proposal': {'saveId': 'S-1', 'draftId': 'draft-1'}}
        first = apply(self.conn, 'op-1', req)
        self.assertEqual(first['id'], 'TASK-006')
        with self.assertRaises(w3.Refused) as caught:
            apply(self.conn, 'op-2', req)
        self.assertIn('already registered as TASK-006', str(caught.exception))
        self.assertEqual(self.state()['highwater'], {'TASK': 6}, 'no second number for the same proposal')
        self.assertEqual(self.state()['proposals'], [('S-1', 'draft-1', 'TASK-006')])
        other = apply(self.conn, 'op-3', dict(req, proposal={'saveId': 'S-2', 'draftId': 'draft-1'}))
        self.assertEqual(other['id'], 'TASK-007', 'the same draft ID in another save is a different key')

    def test_failure_leaves_nothing_and_publishes_no_candidate(self):
        before = self.state()
        def fail(stage):
            raise RuntimeError('injected at ' + stage)
        with self.assertRaises(RuntimeError) as caught:
            apply(self.conn, 'op-1', {'kind': 'register_task', 'prefix': 'TASK', 'fields': NEW}, fail)
        self.assertNotIn('TASK-006', str(caught.exception))
        self.assertFalse(self.conn.in_transaction)
        self.assertEqual(self.state(), before, 'no task, number, revision or operation record')
        self.assertEqual(apply(self.conn, 'op-2', {'kind': 'register_task', 'prefix': 'TASK', 'fields': NEW})['id'], 'TASK-006',
                         'the unpublished candidate was never issued')
        with self.assertRaises(RuntimeError):
            apply(self.conn, 'op-3', {'kind': 'update_task', 'id': 'TASK-002', 'base': {'owner': '担当B'}, 'changes': {'owner': 'X'}}, fail)
        self.assertEqual(self.task('TASK-002')['owner'], '担当B')
        self.assertEqual(w3.revision(self.conn), 1)


class Ledger(unittest.TestCase):
    """The fixture may carry an issued-through ledger for IDs that no longer appear (history); the real Registry is not read."""

    def make(self, ledger):
        tmp = tempfile.TemporaryDirectory()
        self.addCleanup(tmp.cleanup)
        path = str(Path(tmp.name) / 'v3.sqlite3')
        fx = copy.deepcopy(BASE)
        if ledger is not None:
            fx['issuedThrough'] = ledger
        w3.create(path, fx)
        conn = w3.open_db(path)
        self.addCleanup(conn.close)
        return conn, path

    def test_issued_through_covers_absent_ids(self):
        conn, _ = self.make({'TASK': 100, 'OPS': 160})
        self.assertEqual(dict(conn.execute('SELECT prefix, highwater FROM id_allocations')), {'TASK': 100, 'OPS': 160})
        self.assertEqual(apply(conn, 'op-1', {'kind': 'register_task', 'prefix': 'TASK', 'fields': NEW})['id'], 'TASK-101')
        self.assertEqual(apply(conn, 'op-2', {'kind': 'register_task', 'prefix': 'OPS', 'fields': NEW})['id'], 'OPS-161', 'a prefix with no present ID')
        self.assertEqual(apply(conn, 'op-3', {'kind': 'register_task', 'prefix': 'DOC', 'fields': NEW})['id'], 'DOC-001', 'no ledger and no ID: starts at 1')

    def test_ledger_reserves_an_interval_without_dummy_tasks(self):
        conn, _ = self.make({'TASK': 100})
        self.assertTrue(all(w3.is_reserved(conn, 'TASK', n) for n in range(1, 101)), 'missing 1..100 are reserved')
        self.assertFalse(w3.is_reserved(conn, 'TASK', 101))
        self.assertEqual(conn.execute("SELECT COUNT(*) FROM nodes WHERE kind = 'task'").fetchone()[0], 5, 'no dummy task nodes')
        self.assertEqual([r[0] for r in conn.execute('SELECT id FROM issued_ids ORDER BY number')], ['TASK-001', 'TASK-002', 'TASK-003', 'TASK-004', 'TASK-005'],
                         'issue rows only for the fixture tasks; absent numbers get no historical identity')
        made = apply(conn, 'op-1', {'kind': 'register_task', 'prefix': 'TASK', 'fields': NEW})['id']
        self.assertEqual(made, 'TASK-101')
        self.assertTrue(w3.is_reserved(conn, 'TASK', 101))
        self.assertEqual(sorted(r3.read(conn, 'all')['ids']['tasks']), ['TASK-001', 'TASK-002', 'TASK-003', 'TASK-004', 'TASK-005', 'TASK-101'],
                         'the read output has no dummy tasks')

    def test_without_ledger_the_present_ids_decide(self):
        conn, _ = self.make(None)
        self.assertEqual(apply(conn, 'op-1', {'kind': 'register_task', 'prefix': 'TASK', 'fields': NEW})['id'], 'TASK-006')

    def test_invalid_ledgers_are_refused_and_leave_no_file_state(self):
        for ledger, words in (({'TASK': 3}, 'below the present TASK-005'), ({'task': 10}, 'bad prefix'), ({'TASK': -1}, 'non-negative integer'),
                              ({'TASK': '100'}, 'non-negative integer'), ({'TASK': True}, 'non-negative integer'), ([100], 'mapping')):
            tmp = tempfile.TemporaryDirectory()
            self.addCleanup(tmp.cleanup)
            path = Path(tmp.name) / 'v3.sqlite3'
            fx = dict(copy.deepcopy(BASE), issuedThrough=ledger)
            with self.assertRaises(w3.Refused) as caught:
                w3.create(str(path), fx)
            self.assertIn(words, str(caught.exception), ledger)
            self.assertFalse(path.exists(), 'a refused ledger leaves no half-made DB file')

    def test_create_never_touches_an_existing_file(self):
        _, path = self.make(None)
        before = Path(path).read_bytes()
        with self.assertRaises(FileExistsError):
            w3.create(path, copy.deepcopy(BASE))
        self.assertEqual(Path(path).read_bytes(), before)


class SameOperation(Db):
    """Two requests compete for one operation ID while the first is being refused: what the callers see agrees with what
    is stored."""

    def conflicting(self):
        apply(self.conn, 'op-0', {'kind': 'update_task', 'id': 'TASK-003', 'base': {'owner': '担当C'}, 'changes': {'owner': '担当X'}})
        return {'kind': 'update_task', 'id': 'TASK-003', 'base': {'owner': '担当C'}, 'changes': {'owner': '担当Y'}}  # stale base: refused

    def race_on_refusal(self, first, second):
        held, release, out = threading.Event(), threading.Event(), {}
        def hook(stage):
            if stage == 'refused':
                held.set()
                assert release.wait(5)
        def run(name, req, hook=None):
            conn = w3.open_db(self.path)
            try:
                out[name] = apply(conn, 'op-x', req, hook)
            except Exception as error:
                out[name] = error
            finally:
                conn.close()
        a = threading.Thread(target=run, args=('a', first, hook))
        a.start()
        self.assertTrue(held.wait(5))
        b = threading.Thread(target=run, args=('b', second))
        b.start()
        b.join(0.3)
        release.set()
        a.join(5)
        b.join(5)
        stored = self.conn.execute("SELECT digest, status, result FROM operations WHERE operation_id = 'op-x'").fetchone()
        return out['a'], out['b'], stored

    def test_other_request_cannot_take_the_id_of_a_refusal(self):
        refused = self.conflicting()
        valid = {'kind': 'update_task', 'id': 'TASK-004', 'base': {'owner': '担当D'}, 'changes': {'owner': '担当Z'}}
        a, b, stored = self.race_on_refusal(refused, valid)
        self.assertIsInstance(a, w3.Refused)
        self.assertIsInstance(b, w3.OperationMismatch, 'the ID belongs to the refused request')
        self.assertEqual(stored[:2], (w3.digest(full(self.conn, refused)), 'refused'))
        self.assertEqual(json.loads(stored[2])['error'], str(a))
        self.assertEqual(self.task('TASK-004')['owner'], '担当D', 'the competing request changed nothing')

    def test_same_request_during_a_refusal_gets_the_same_refusal(self):
        refused = self.conflicting()
        a, b, stored = self.race_on_refusal(refused, copy.deepcopy(refused))
        self.assertIsInstance(a, w3.Refused)
        self.assertIsInstance(b, w3.Refused)
        self.assertEqual(str(a), str(b))
        self.assertEqual(stored[:2], (w3.digest(full(self.conn, refused)), 'refused'))


class Update(Db):
    def test_independent_fields_from_the_same_base_both_stay(self):
        base = self.task('TASK-003')
        one = apply(self.conn, 'op-1', {'kind': 'update_task', 'id': 'TASK-003', 'base': {'owner': base['owner']}, 'changes': {'owner': '担当X'}})
        two = apply(self.connect(), 'op-2', {'kind': 'update_task', 'id': 'TASK-003', 'base': {'state': base['state']}, 'changes': {'state': 'DONE'}})
        self.assertEqual((one['applied'], two['applied']), (['owner'], ['state']))
        self.assertEqual((self.task('TASK-003')['owner'], self.task('TASK-003')['state']), ('担当X', 'DONE'))

    def test_item_change_keeps_the_node_name(self):
        apply(self.conn, 'op-1', {'kind': 'update_task', 'id': 'TASK-003', 'base': {'item': 'Bで始まる仕事'}, 'changes': {'item': '新しい項目名'}})
        self.assertEqual(self.task('TASK-003')['item'], '新しい項目名')
        self.assertEqual(self.conn.execute("SELECT name FROM nodes WHERE id = 'TASK-003'").fetchone()[0], '新しい項目名')
        self.assertEqual(self.conn.execute('SELECT COUNT(*) FROM tasks t JOIN nodes n ON n.id = t.id WHERE n.name <> t.item').fetchone()[0], 0)

    def test_conflicting_change_is_refused_and_replayed(self):
        base = self.task('TASK-003')
        apply(self.conn, 'op-1', {'kind': 'update_task', 'id': 'TASK-003', 'base': {'owner': base['owner']}, 'changes': {'owner': '担当X'}})
        late = {'kind': 'update_task', 'id': 'TASK-003', 'base': {'owner': base['owner'], 'state': base['state']}, 'changes': {'owner': '担当Y', 'state': 'DONE'}}
        before = self.state()
        with self.assertRaises(w3.Refused) as caught:
            apply(self.connect(), 'op-2', late)
        self.assertIn('conflict on TASK-003: owner', str(caught.exception))
        self.assertEqual(self.task('TASK-003'), dict(base, owner='担当X'), 'the whole operation is refused, state included')
        self.assertEqual(w3.revision(self.conn), before['revision'])
        with self.assertRaises(w3.Refused):
            apply(self.conn, 'op-2', late)  # the refusal is replayed
        with self.assertRaises(w3.OperationMismatch):
            apply(self.conn, 'op-2', {'kind': 'update_task', 'id': 'TASK-003', 'base': {'state': base['state']}, 'changes': {'state': 'DONE'}})
        reduced = apply(self.conn, 'op-3', {'kind': 'update_task', 'id': 'TASK-003', 'base': {'state': base['state']}, 'changes': {'state': 'DONE'}})
        self.assertEqual(reduced['applied'], ['state'], 'the reduced request goes under a new operation ID')

    def test_already_reflected_and_base_required(self):
        base = self.task('TASK-003')
        apply(self.conn, 'op-1', {'kind': 'update_task', 'id': 'TASK-003', 'base': {'owner': base['owner']}, 'changes': {'owner': '担当X'}})
        same = apply(self.conn, 'op-2', {'kind': 'update_task', 'id': 'TASK-003', 'base': {'owner': base['owner']}, 'changes': {'owner': '担当X'}})
        self.assertEqual((same['applied'], same['alreadyReflected']), ([], ['owner']))
        with self.assertRaises(w3.Refused):
            apply(self.conn, 'op-3', {'kind': 'update_task', 'id': 'TASK-003', 'base': {}, 'changes': {'owner': 'Z'}})
        with self.assertRaises(w3.Refused):
            apply(self.conn, 'op-4', {'kind': 'update_task', 'id': 'TASK-003', 'base': {'id': 'x'}, 'changes': {'id': 'TASK-999'}})


class Retire(Db):
    def test_retired_id_is_never_reused_or_edited(self):
        made = apply(self.conn, 'op-1', {'kind': 'register_task', 'prefix': 'TASK', 'fields': NEW})['id']
        apply(self.conn, 'op-2', {'kind': 'retire_task', 'id': made, 'reason': '登録直後に取り消し'})
        self.assertEqual(apply(self.conn, 'op-3', {'kind': 'register_task', 'prefix': 'TASK', 'fields': NEW})['id'], 'TASK-007')
        with self.assertRaises(w3.Refused) as caught:
            apply(self.conn, 'op-4', {'kind': 'update_task', 'id': made, 'base': {'owner': NEW['owner']}, 'changes': {'owner': 'X'}})
        self.assertIn('retired', str(caught.exception))
        with self.assertRaises(w3.Refused):
            apply(self.conn, 'op-5', {'kind': 'add_edge', 'graph': 'progress', 'prerequisite': 'TASK-003', 'successor': made, 'flow': 'SEQUENCE'})
        with self.assertRaises(w3.Refused):
            apply(self.conn, 'op-6', {'kind': 'retire_task', 'id': made, 'reason': '二回目'})
        self.assertIn(made, self.state()['issued'])
        self.assertTrue(self.conn.execute('SELECT 1 FROM nodes WHERE id = ?', (made,)).fetchone(), 'the node stays as a reservation')


class Edges(Db):
    def test_concurrent_edges_forming_a_cycle_refuse_the_later(self):
        a, b, waiting = self.race(('op-a', {'kind': 'add_edge', 'graph': 'progress', 'prerequisite': 'TASK-003', 'successor': 'TASK-004', 'flow': 'SEQUENCE'}),
                                  ('op-b', {'kind': 'add_edge', 'graph': 'progress', 'prerequisite': 'TASK-004', 'successor': 'TASK-003', 'flow': 'SEQUENCE'}))
        self.assertTrue(waiting)
        self.assertEqual(a['revision'], 1)
        self.assertIsInstance(b, w3.Refused)
        self.assertIn('progress cycle', str(b))
        self.assertEqual([e[:3] for e in self.state()['edges'] if e[0] == 'progress'], [('progress', 'TASK-002', 'TASK-003'), ('progress', 'TASK-003', 'TASK-004')])
        self.assertEqual([o[:2] for o in self.state()['operations']], [('op-a', 'done'), ('op-b', 'refused')])
        # each alone is fine: the later edge passes on a fresh copy without the earlier one
        fresh = tempfile.TemporaryDirectory()
        self.addCleanup(fresh.cleanup)
        path = str(Path(fresh.name) / 'alone.sqlite3')
        w3.create(path, copy.deepcopy(BASE))
        alone = w3.open_db(path)
        self.addCleanup(alone.close)
        self.assertEqual(apply(alone, 'op-b', {'kind': 'add_edge', 'graph': 'progress', 'prerequisite': 'TASK-004', 'successor': 'TASK-003', 'flow': 'SEQUENCE'})['revision'], 1)

    def test_management_and_progress_are_not_merged(self):
        apply(self.conn, 'op-1', {'kind': 'add_edge', 'graph': 'management', 'prerequisite': 'TASK-003', 'successor': 'TASK-004'})
        apply(self.conn, 'op-2', {'kind': 'add_edge', 'graph': 'progress', 'prerequisite': 'TASK-004', 'successor': 'TASK-003', 'flow': 'SEQUENCE'})
        with self.assertRaises(w3.Refused) as caught:
            apply(self.conn, 'op-3', {'kind': 'add_edge', 'graph': 'management', 'prerequisite': 'TASK-002', 'successor': 'TASK-001'})
        self.assertIn('management cycle', str(caught.exception))
        # TASK-002 -> MS-A2 -> END-0.1.0 -> GATE-0.2.0 -> START-0.2.0 -> MS-B1 -> TASK-004: closing it needs the milestone links and the skeleton
        with self.assertRaises(w3.Refused) as caught:
            apply(self.conn, 'op-4', {'kind': 'add_edge', 'graph': 'progress', 'prerequisite': 'TASK-004', 'successor': 'TASK-002', 'flow': 'SEQUENCE'})
        self.assertIn('progress cycle', str(caught.exception))
        view = r3.read(self.conn, 'all')
        self.assertIn(['TASK-003', 'TASK-004'], view['relations']['management'])
        self.assertIn(['TASK-004', 'TASK-003'], view['relations']['progress'])
        self.assertEqual(view['sources']['edge:progress:TASK-004->TASK-003'], 'operation:op-2')


if __name__ == '__main__':
    sys.exit(0 if unittest.main(exit=False, verbosity=2 if '-v' in sys.argv else 1).result.wasSuccessful() else 1)
