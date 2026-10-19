#!/usr/bin/env python3
"""OPS-167 migration gap: set_focus and set_recorded_done, through the existing CLI path (registry_v3_cli.py apply).
Reuses the generation, operation-ID replay, base-value conflict and transaction contracts. Focus only moves the read
boundary and never sets recordedDone; recordedDone exists only for real cards (gates, START/END, tasks are refused).
Every DB is a fixture DB in a TemporaryDirectory under the hermetic guard.

Run: python3 -B Maintanance/RegistryApp/v3/test_focus_and_done.py -v
"""
import copy
import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
import hermetic  # noqa: E402,F401  (first: temporary roots for every live path, OPS-167 K9)
import registry_v3_recovery as rc  # noqa: E402
import registry_v3_write as w3  # noqa: E402
import studio_adapter as sa  # noqa: E402
from test_registry_v3_cli import BASE  # noqa: E402

ACTOR, EVIDENCE = '姫（focus/DONE試験）', ['OPS-167 移行の欠け']


class Ops(unittest.TestCase):
    def setUp(self):
        tmp = tempfile.TemporaryDirectory()
        self.addCleanup(tmp.cleanup)
        self.dir = Path(tmp.name)
        self.db = self.dir / 'db.sqlite3'
        w3.create(str(self.db), copy.deepcopy(BASE))
        self.n = 0

    def cli(self, op, **req):
        self.n += 1
        path = self.dir / f'req-{self.n}.json'
        req.setdefault('generation', self.gen())
        path.write_text(json.dumps({'actor': ACTOR, 'evidence': EVIDENCE, **req}, ensure_ascii=False), encoding='utf-8')
        run = subprocess.run([sys.executable, '-B', str(HERE / 'registry_v3_cli.py'), 'apply', '--db', str(self.db), '--op', op, '--request', str(path)],
                             capture_output=True, text=True, timeout=60)
        return run.returncode, json.loads(run.stdout)

    def gen(self):
        conn = w3.open_db(str(self.db))
        try:
            return w3.generation(conn)
        finally:
            conn.close()

    def export(self):
        conn = w3.open_db(str(self.db))
        try:
            return sa.export_doc(conn)
        finally:
            conn.close()

    def cards(self, doc):
        return {m['id']: (m['state'], m['recordedDone']) for m in doc['milestones'] if 'recordedDone' in m}


class Focus(Ops):
    def test_roundtrip_replay_and_conflict(self):
        before = self.export()
        self.assertEqual(before['milestoneHead'], '0.2.0')
        code, out = self.cli('f1', kind='set_focus', base={'focus': '0.2.0'}, focus='0.3.0')
        self.assertEqual((code, out['status'], out['result']['alreadyReflected']), (0, 'ok', False))
        after = self.export()
        self.assertEqual((after['milestoneHead'], after['source']['revision']), ('0.3.0', 1))
        self.assertEqual({k: v[1] for k, v in self.cards(after).items()}, {k: v[1] for k, v in self.cards(before).items()},
                         'moving the focus records no arrival: every recordedDone is as before')
        code, again = self.cli('f1', kind='set_focus', base={'focus': '0.2.0'}, focus='0.3.0', generation=before['source']['generation'])
        self.assertEqual((code, again['replayed'], self.export()['source']['revision']), (0, True, 1), 'replay adds no revision')
        code, other = self.cli('f1', kind='set_focus', base={'focus': '0.2.0'}, focus='0.1.0')
        self.assertEqual((code, other['status']), (5, 'operationMismatch'))
        code, stale = self.cli('f2', kind='set_focus', base={'focus': '0.2.0'}, focus='0.1.0')
        self.assertEqual((code, stale['status']), (1, 'refused'))
        self.assertIn('focus changed since the base', stale['error'])
        code, same = self.cli('f3', kind='set_focus', base={'focus': '0.1.0'}, focus='0.3.0')
        self.assertEqual((code, same['result']['alreadyReflected']), (0, True), 'the target already in place')
        self.assertEqual(self.export()['milestoneHead'], '0.3.0')

    def test_refusals(self):
        for op, req, words in (('a', {'base': {'focus': '0.2.0'}, 'focus': '9.9.9'}, 'unknown version'),
                               ('b', {'base': {'focus': '0.2.0'}, 'focus': ''}, 'needs focus'),
                               ('c', {'focus': '0.3.0'}, 'base must be exactly focus'),
                               ('d', {'base': {'focus': '0.2.0', 'x': 1}, 'focus': '0.3.0'}, 'base must be exactly focus')):
            with self.subTest(op=op):
                code, out = self.cli(op, kind='set_focus', **req)
                self.assertEqual((code, out['status']), (1, 'refused'))
                self.assertIn(words, out['error'])
        self.assertEqual((self.export()['milestoneHead'], self.export()['source']['revision']), ('0.2.0', 0))

    def test_generation_and_closed_writes(self):
        code, out = self.cli('g', kind='set_focus', base={'focus': '0.2.0'}, focus='0.3.0', generation='gen-other')
        self.assertEqual((code, out['status']), (4, 'notWritable'))
        conn = w3.open_db(str(self.db))
        rc.backup(conn, self.dir / 'b.sqlite3')
        conn.close()
        rc.restore(self.dir / 'b.sqlite3', self.dir / 'r.sqlite3', ACTOR, EVIDENCE)
        self.db = self.dir / 'r.sqlite3'
        code, out = self.cli('h', kind='set_focus', base={'focus': '0.2.0'}, focus='0.3.0')
        self.assertEqual((code, out['status'], out['kind']), (4, 'notWritable', 'WriteDisabled'), 'a restored DB stays closed')


class Done(Ops):
    def test_roundtrip_and_the_derived_state_stays_apart(self):
        before = self.cards(self.export())
        self.assertEqual(before['MS-A2'], ('DONE', False), 'derived DONE (before the focus), box open')
        code, out = self.cli('d1', kind='set_recorded_done', id='MS-A2', base={'recordedDone': False}, recordedDone=True)
        self.assertEqual((code, out['result']['alreadyReflected']), (0, False))
        after = self.export()
        self.assertEqual(self.cards(after)['MS-A2'], ('DONE', True))
        self.assertEqual(after['milestoneHead'], '0.2.0', 'recording DONE does not move the focus')
        code, out = self.cli('d2', kind='set_recorded_done', id='MS-B1', base={'recordedDone': False}, recordedDone=True)
        self.assertEqual(code, 0)
        self.assertEqual(self.cards(self.export())['MS-B1'], ('DONE', True), 'from the focus on, the display uses the recorded box (the accepted rule)')
        code, again = self.cli('d2', kind='set_recorded_done', id='MS-B1', base={'recordedDone': False}, recordedDone=True)
        self.assertEqual((code, again['replayed']), (0, True))
        code, stale = self.cli('d3', kind='set_recorded_done', id='MS-B1', base={'recordedDone': False}, recordedDone=False)
        self.assertEqual((code, stale['status']), (1, 'refused'))
        self.assertIn('recordedDone changed since the base', stale['error'])
        code, back = self.cli('d4', kind='set_recorded_done', id='MS-B1', base={'recordedDone': True}, recordedDone=False)
        self.assertEqual((code, self.cards(self.export())['MS-B1']), (0, ('ACTIVE', False)))

    def test_focus_moves_the_display_not_the_record(self):
        """The display state is derived (before the focus: DONE; from it on: the recorded box); moving the focus back
        changes the display only, and the recorded boxes stay exactly as they were."""
        recorded = {k: v[1] for k, v in self.cards(self.export()).items()}
        self.assertEqual(self.cards(self.export())['MS-A2'], ('DONE', False))
        code, _ = self.cli('back', kind='set_focus', base={'focus': '0.2.0'}, focus='0.1.0')
        self.assertEqual(code, 0)
        after = self.cards(self.export())
        self.assertEqual(after['MS-A2'], ('ACTIVE', False), 'no longer before the focus, and the box is open')
        self.assertEqual({k: v[1] for k, v in after.items()}, recorded)

    def test_only_real_cards(self):
        for op, target in (('g', 'GATE-0.2.0'), ('s', 'START-0.1.0'), ('e', 'END-0.1.0'), ('t', 'TASK-003'), ('u', 'MS-NONE')):
            with self.subTest(target=target):
                code, out = self.cli(op, kind='set_recorded_done', id=target, base={'recordedDone': False}, recordedDone=True)
                self.assertEqual((code, out['status']), (1, 'refused'))
                self.assertIn('not a card with a recorded DONE box', out['error'])
        for op, req in (('v', {'base': {'recordedDone': False}, 'recordedDone': 1}), ('w', {'base': {'recordedDone': 0}, 'recordedDone': True}),
                        ('x', {'recordedDone': True})):
            with self.subTest(op=op):
                code, out = self.cli(op, kind='set_recorded_done', id='MS-A2', **req)
                self.assertEqual((code, out['status']), (1, 'refused'))
        self.assertEqual(self.export()['source']['revision'], 0, 'nothing applied')


if __name__ == '__main__':
    sys.exit(0 if unittest.main(exit=False, verbosity=2 if '-v' in sys.argv else 1).result.wasSuccessful() else 1)
