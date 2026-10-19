#!/usr/bin/env python3
"""OPS-174 tests: the thin CLI, run as a subprocess on fixture DBs in a TemporaryDirectory. Expected values by hand.

Run: python3 -B Maintanance/RegistryApp/Experiments/registry_v3_read/test_registry_v3_cli.py -v
"""
import copy
import hashlib
import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
import registry_v3_recovery as rc  # noqa: E402
import registry_v3_write as w3  # noqa: E402
from test_change_groups import Groups  # noqa: E402

CLI = HERE / 'registry_v3_cli.py'
BASE = json.loads((HERE / 'fixtures' / 'base.json').read_text(encoding='utf-8'))
ACTOR, EVIDENCE = '姫（CLI試験）', ['TASK_REGISTRY_V3_WRITER_CLI.md#範囲と受入']


class Cli(unittest.TestCase):
    def setUp(self):
        tmp = tempfile.TemporaryDirectory()
        self.addCleanup(tmp.cleanup)
        self.dir = Path(tmp.name)
        self.db = self.dir / 'db.sqlite3'
        w3.create(str(self.db), copy.deepcopy(BASE))
        conn = w3.open_db(str(self.db))
        self.gen = w3.generation(conn)
        conn.close()
        self.n = 0

    def file(self, data):
        self.n += 1
        p = self.dir / f'in-{self.n}.json'
        p.write_text(json.dumps(data, ensure_ascii=False) if not isinstance(data, str) else data, encoding='utf-8')
        return str(p)

    def run_cli(self, *args, stdin=None):
        out = subprocess.run([sys.executable, '-B', str(CLI), *map(str, args)], capture_output=True, text=True, input=stdin, timeout=60)
        body = json.loads(out.stdout) if out.stdout.strip() else None
        return out.returncode, body

    def update(self, owner='担当X', base='担当C', generation=None):
        return {'kind': 'update_task', 'id': 'TASK-003', 'base': {'owner': base}, 'changes': {'owner': owner}, 'generation': generation or self.gen,
                'actor': ACTOR, 'evidence': EVIDENCE}

    def digest(self):
        return hashlib.sha256(self.db.read_bytes()).hexdigest()


class Apply(Cli):
    def test_apply_query_and_replay(self):
        code, body = self.run_cli('apply', '--db', self.db, '--op', 'op-1', '--request', self.file(self.update()))
        self.assertEqual((code, body['status'], body['replayed'], body['result']['applied'], body['result']['revision']), (0, 'ok', False, ['owner'], 1))
        code, rec = self.run_cli('operation', '--db', self.db, '--op', 'op-1')
        self.assertEqual((code, rec['result']['status'], rec['result']['actor'], rec['result']['before'], rec['result']['after']),
                         (0, 'done', ACTOR, {'id': 'TASK-003', 'owner': '担当C'}, {'id': 'TASK-003', 'owner': '担当X'}))
        code, again = self.run_cli('apply', '--db', self.db, '--op', 'op-1', '--request', '-', stdin=json.dumps(self.update(), ensure_ascii=False))
        self.assertEqual((code, again['replayed'], again['result']), (0, True, body['result']), 'the same command again replays (stdin input)')
        code, read = self.run_cli('read', '--db', self.db, '--scope', 'all')
        self.assertEqual((code, read['result']['ids']['tasks']['TASK-003']['owner']), (0, '担当X'))

    def test_mismatch_conflict_and_generation(self):
        self.run_cli('apply', '--db', self.db, '--op', 'op-1', '--request', self.file(self.update()))
        code, body = self.run_cli('apply', '--db', self.db, '--op', 'op-1', '--request', self.file(self.update(owner='担当Y')))
        self.assertEqual((code, body['status']), (5, 'operationMismatch'))
        code, body = self.run_cli('apply', '--db', self.db, '--op', 'op-2', '--request', self.file(self.update(owner='担当Y')))
        self.assertEqual((code, body['status'], body['replayed']), (1, 'refused', False))
        self.assertIn('conflict on TASK-003: owner', body['error'])
        code, body = self.run_cli('apply', '--db', self.db, '--op', 'op-2', '--request', self.file(self.update(owner='担当Y')))
        self.assertEqual((code, body['replayed']), (1, True), 'the recorded refusal replays')
        code, body = self.run_cli('apply', '--db', self.db, '--op', 'op-3', '--request', self.file(self.update(generation='gen-other')))
        self.assertEqual((code, body['status'], body['kind']), (4, 'notWritable', 'GenerationMismatch'))

    def test_restored_db_stays_closed(self):
        conn = w3.open_db(str(self.db))
        rc.backup(conn, self.dir / 'b.sqlite3')
        conn.close()
        info = rc.restore(self.dir / 'b.sqlite3', self.dir / 'r.sqlite3', ACTOR, EVIDENCE)
        before = hashlib.sha256((self.dir / 'r.sqlite3').read_bytes()).hexdigest()
        code, body = self.run_cli('apply', '--db', self.dir / 'r.sqlite3', '--op', 'op-1', '--request', self.file(self.update(generation=info['generation'])))
        self.assertEqual((code, body['kind']), (4, 'WriteDisabled'))
        self.assertEqual(hashlib.sha256((self.dir / 'r.sqlite3').read_bytes()).hexdigest(), before)

    def test_malformed_inputs(self):
        for data, words in (('{bad json', 'is not JSON'), ('[1]', 'JSON object'), ({k: v for k, v in self.update().items() if k != 'actor'}, 'actor must be given explicitly')):
            code, body = self.run_cli('apply', '--db', self.db, '--op', 'op-x', '--request', self.file(data))
            self.assertEqual((code, body['status']), (2, 'malformed'), data)
            self.assertIn(words, body['error'])
        code, body = self.run_cli('apply', '--db', self.db, '--request', self.file(self.update()))
        self.assertEqual((code, body['status']), (2, 'malformed'), 'no --op: the CLI does not invent one')
        code, body = self.run_cli('apply', '--db', self.db, '--op', 'op-x', '--request', self.dir / 'missing.json')
        self.assertEqual(code, 2)
        conn = w3.open_db(str(self.db))
        self.addCleanup(conn.close)
        self.assertIsNone(w3.operation(conn, 'op-x'))

    def test_missing_db_is_not_created(self):
        ghost = self.dir / 'typo.sqlite3'
        code, body = self.run_cli('read', '--db', ghost)
        self.assertEqual((code, body['status']), (3, 'notFound'))
        self.assertFalse(ghost.exists())
        other = self.dir / 'other.sqlite3'
        import sqlite3
        c = sqlite3.connect(other)
        c.execute('CREATE TABLE x (y)')
        c.close()
        code, body = self.run_cli('read', '--db', other)
        self.assertEqual((code, body['status']), (2, 'malformed'))
        self.assertIn('not a V3 experiment DB', body['error'])
        code, body = self.run_cli('operation', '--db', self.db, '--op', 'nope')
        self.assertEqual((code, body['status']), (3, 'notFound'))

    def test_export(self):
        code, body = self.run_cli('export', '--db', self.db)
        self.assertEqual((code, body['result']['source']['kind'], body['result']['source']['generation']), (0, 'v3-export', self.gen))


class Corrections(Cli):
    """Acceptance (2026-10-19): explicit request fields and exact DB paths."""

    def test_generation_actor_and_evidence_must_be_explicit(self):
        before = self.digest()
        for missing in ('evidence', 'actor', 'generation'):
            req = self.update()
            del req[missing]
            code, body = self.run_cli('apply', '--db', self.db, '--op', 'missing-' + missing, '--request', self.file(req))
            self.assertEqual((code, body['status']), (2, 'malformed'), missing)
            self.assertIn(missing, body['error'])
        for field, value in (('evidence', 'not a list'), ('evidence', [1]), ('actor', ''), ('actor', 3), ('generation', 5)):
            code, body = self.run_cli('apply', '--db', self.db, '--op', 'bad-' + field, '--request', self.file(dict(self.update(), **{field: value})))
            self.assertEqual(code, 2, (field, value))
        self.assertEqual(self.digest(), before, 'nothing written')
        code, body = self.run_cli('apply', '--db', self.db, '--op', 'empty-evidence', '--request', self.file(dict(self.update(), evidence=[])))
        self.assertEqual(code, 0, 'an explicit empty evidence list stays allowed (existing API)')

    def test_special_characters_open_exactly_the_named_db(self):
        import shutil
        for name in ('db.sqlite3#other', 'db.sqlite3?mode=ro', 'db%20x.sqlite3', 'with space.sqlite3', 'pct%3F.sqlite3'):
            target = self.dir / name
            shutil.copy(self.db, target)
            plain = self.digest()
            code, body = self.run_cli('apply', '--db', target, '--op', 'op-' + str(len(name)), '--request', self.file(self.update()))
            self.assertEqual(code, 0, (name, body))
            self.assertEqual(self.digest(), plain, f'{name}: the other DB is untouched')
            c = w3.open_db(str(target))
            self.assertEqual(c.execute("SELECT owner FROM tasks WHERE id = 'TASK-003'").fetchone()[0], '担当X', name)
            c.close()
            target.unlink()
        code, body = self.run_cli('read', '--db', self.dir / 'missing#x.sqlite3')
        self.assertEqual(code, 3)
        self.assertFalse((self.dir / 'missing#x.sqlite3').exists())
        self.assertFalse((self.dir / 'missing').exists())


class SaveGroups(Groups):
    """Saves from the real editor (harness), then the CLI."""

    def cli(self, *args):
        out = subprocess.run([sys.executable, '-B', str(CLI), *map(str, args)], capture_output=True, text=True, timeout=60)
        return out.returncode, json.loads(out.stdout)

    def file(self, name, data):
        p = self.dir / name
        p.write_text(json.dumps(data, ensure_ascii=False), encoding='utf-8')
        return p

    def test_plan_is_read_only_and_partial_groups_are_reported(self):
        save = self.two_tasks()
        self.db_owner('db-1', 'TASK-004', '担当D', '担当Y')
        db = self.dir / 'db.sqlite3'
        before = hashlib.sha256(db.read_bytes()).hexdigest()
        code, plan = self.cli('plan-groups', '--db', db, '--save', self.file('save.json', save))
        self.assertEqual((code, [g['groupId'] for g in plan['groups']]), (0, ['task:TASK-003', 'task:TASK-004']))
        self.assertEqual(hashlib.sha256(db.read_bytes()).hexdigest(), before, 'planning writes nothing')
        sel = {'selected': ['task:TASK-003', 'task:TASK-004'], 'actor': ACTOR, 'evidence': EVIDENCE}
        code, out = self.cli('apply-groups', '--db', db, '--save', self.file('save.json', save), '--selection', self.file('sel.json', sel))
        self.assertEqual((code, out['status'], [e['groupId'] for e in out['result']['applied']], [e['groupId'] for e in out['result']['conflict']]),
                         (6, 'incomplete', ['task:TASK-003'], ['task:TASK-004']))
        code, again = self.cli('apply-groups', '--db', db, '--save', self.file('save.json', save), '--selection', self.file('sel.json', dict(sel, selected=['task:TASK-003'])))
        self.assertEqual((code, [e['groupId'] for e in again['result']['replayed']]), (6, ['task:TASK-003']), 'replayed, and B still unselected -> incomplete')
        code, done = self.cli('apply-groups', '--db', db, '--save', self.file('one.json', self.stored([{'select': 'TASK-005'}, {'set': {'owner': '担当Q'}}, {'apply': True}], 'S-2')),
                              '--selection', self.file('sel2.json', dict(sel, selected=['task:TASK-005'])))
        self.assertEqual((code, done['status']), (0, 'ok'))

    def test_whole_save_rejection_and_selection_shape(self):
        save = self.two_tasks()
        db = self.dir / 'db.sqlite3'
        bad = copy.deepcopy(save)
        bad['v3']['generation'] = 'gen-x'
        bad['source']['generation'] = 'gen-x'
        code, out = self.cli('apply-groups', '--db', db, '--save', self.file('bad.json', bad), '--selection', self.file('sel.json', {'selected': [], 'actor': ACTOR, 'evidence': []}))
        self.assertEqual((code, out['status']), (7, 'saveRejected'))
        code, out = self.cli('apply-groups', '--db', db, '--save', self.file('save.json', save), '--selection', self.file('sel.json', {'selected': ['task:TASK-003']}))
        self.assertEqual((code, out['status']), (2, 'malformed'), 'actor and evidence are never inferred')
        code, out = self.cli('apply-groups', '--db', db, '--save', self.file('save.json', save), '--selection',
                             self.file('sel.json', {'selected': ['task:TASK-003'], 'actor': ACTOR, 'evidence': EVIDENCE, 'guess': True}))
        self.assertEqual(code, 2)


if __name__ == '__main__':
    sys.exit(0 if unittest.main(exit=False, verbosity=2 if '-v' in sys.argv else 1).result.wasSuccessful() else 1)
