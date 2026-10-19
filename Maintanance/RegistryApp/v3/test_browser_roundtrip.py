#!/usr/bin/env python3
"""OPS-166 tests: the real Studio page served by the isolated V3 server (127.0.0.1, OS-assigned port, TemporaryDirectory)
and driven by headless WebKit (browser_roundtrip.cjs, installed Playwright, nothing installed by the test).
Save -> reopen -> compare with the latest DB -> explicit apply. A save never writes the DB.
The server and the browser are stopped also when a test fails.

Run: python3 -B Maintanance/RegistryApp/v3/test_browser_roundtrip.py -v
"""
import copy
import json
import os
import subprocess
import sys
import tempfile
import unittest
import urllib.error
import urllib.request
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
import registry_v3_recovery as rc  # noqa: E402
import registry_v3_write as w3  # noqa: E402
import v3_studio_server as vs  # noqa: E402

BASE = json.loads((HERE / 'fixtures' / 'base.json').read_text(encoding='utf-8'))
ACTOR, EVIDENCE = '姫（試験）', ['TASK_REGISTRY_V3_BROWSER_EXPERIMENT.md#受入条件']
EXPECTED_PATHS = {'GET /', 'GET /workspace', 'POST /save', 'GET /registry.json', 'GET /server-status', 'GET /activity-events', 'GET /commit-approvals',
                  'GET /approval-probe', 'GET /continuity', 'GET /letters'}


class Browser(unittest.TestCase):
    def setUp(self):
        tmp = tempfile.TemporaryDirectory()
        self.addCleanup(tmp.cleanup)
        self.dir = Path(tmp.name)
        w3.create(str(self.dir / 'db.sqlite3'), copy.deepcopy(BASE))
        docs = getattr(self, 'DOCUMENT_ROOT', None)  # OPS-176: a subclass may name a temporary document root under self.dir
        self.server = vs.V3StudioServer(self.dir / 'db.sqlite3', self.dir / 'saves', None if docs is None else self.dir / docs).start()
        self.addCleanup(self.server.stop)  # runs even when the test fails
        self.conn = w3.open_db(str(self.dir / 'db.sqlite3'))
        self.addCleanup(self.conn.close)
        self.n = 0

    def browser(self, mode, **params):
        self.n += 1
        p, out = self.dir / f'params-{self.n}.json', self.dir / f'out-{self.n}.json'
        p.write_text(json.dumps(params, ensure_ascii=False), encoding='utf-8')
        run = subprocess.run(['node', str(HERE / 'browser_roundtrip.cjs'), self.server.origin, mode, str(p), str(out)], capture_output=True, text=True, timeout=180)
        self.assertEqual(run.returncode, 0, run.stderr[-2000:])
        result = json.loads(out.read_text(encoding='utf-8'))
        self.assertEqual(result['pageErrors'], [])
        if mode != 'blocked':
            self.assertEqual(result['blocked'], [], 'nothing outside the isolated origin was even attempted')
        self.assertTrue(set(result['requests']) <= EXPECTED_PATHS | {'POST /save'} | getattr(self, 'EXTRA_PATHS', set()), result['requests'])  # OPS-177: a subclass may allow POST /sync
        return result

    def apply(self, save_id):
        req = urllib.request.Request(self.server.origin + '/v3/apply', data=json.dumps({'saveId': save_id, 'actor': ACTOR, 'evidence': EVIDENCE}).encode('utf-8'),
                                     headers={'Content-Type': 'application/json'}, method='POST')
        try:
            with urllib.request.urlopen(req, timeout=30) as r:
                return r.status, json.loads(r.read())
        except urllib.error.HTTPError as e:
            with e:
                return e.code, json.loads(e.read())

    def saved(self):
        latest = self.server.latest()
        return latest['save']['studioSave']['saveId']

    def db(self):
        return (self.conn.execute('SELECT * FROM tasks ORDER BY id').fetchall(), w3.revision(self.conn), self.conn.execute('SELECT COUNT(*) FROM operations').fetchone()[0])

    def owner(self, tid='TASK-003'):
        return self.conn.execute('SELECT state, owner FROM tasks WHERE id = ?', (tid,)).fetchone()

    def db_change(self, op, field, base, new):
        w3.apply(self.conn, op, {'kind': 'update_task', 'id': 'TASK-003', 'base': {field: base}, 'changes': {field: new}, 'generation': w3.generation(self.conn),
                                 'actor': 'DB側の別の編集', 'evidence': []})


class RoundTrip(Browser):
    def test_save_reopen_apply_and_replay(self):
        before = self.db()
        saved = self.browser('save', task='TASK-003', owner='担当X', state='DONE')
        self.assertIn('サーバーに保存しました', saved['after']['status'])
        self.assertIn('POST /save', saved['requests'])
        self.assertEqual(self.db(), before, 'the save alone writes nothing to the DB')
        reopened = self.browser('reopen', task='TASK-003', screenshot=str(self.dir / 'reopen.png'))
        self.assertEqual((reopened['after']['owner'], reopened['after']['state']), ('担当X', 'DONE'), 'the page resumes the saved edit')
        banner = reopened['after']['banner']
        self.assertIn('世代 ' + w3.generation(self.conn) + ' · 改訂 0', banner)
        self.assertIn('を再開中', banner)
        for word in ('コミット済み版', '未コミット差分', 'HEAD ', 'SHA-256 '):
            self.assertNotIn(word, banner)
        status, body = self.apply(self.saved())
        self.assertEqual((status, body['result']['applied'], body['result']['revision']), (200, ['owner', 'state'], 1))
        self.assertEqual(self.owner(), ('DONE', '担当X'))
        status2, body2 = self.apply(self.saved())
        self.assertEqual((status2, body2), (200, body), 'applying the same save again replays')
        self.assertEqual(w3.revision(self.conn), 1)
        evidence = os.environ.get('OPS166_EVIDENCE')  # optional: keep the browser outputs and the screenshot of this run
        if evidence:
            out = Path(evidence)
            out.mkdir(parents=True, exist_ok=True)
            (out / 'reopen.png').write_bytes((self.dir / 'reopen.png').read_bytes())
            (out / 'roundtrip.json').write_text(json.dumps({'save': saved, 'reopen': reopened, 'apply': body, 'serverRequests': self.server.requests,
                                                            'patches': [p[2] for p in vs.PATCHES]}, ensure_ascii=False, indent=1) + '\n', encoding='utf-8')


class Compare(Browser):
    def test_other_field_changed_meanwhile(self):
        self.browser('save', task='TASK-003', owner='担当X')
        self.db_change('db-1', 'state', 'ACTIVE', 'DONE')
        after = self.browser('reopen', task='TASK-003')['after']
        self.assertIn('DBが更新されています：この編集版の土台 世代 ' + w3.generation(self.conn) + ' 改訂 0 → 最新 世代 ' + w3.generation(self.conn) + ' 改訂 1', after['banner'])
        self.assertIn('タスク TASK-003 変更', after['notice'])
        self.assertNotIn('競合', after['notice'])
        status, body = self.apply(self.saved())
        self.assertEqual((status, body['result']['applied']), (200, ['owner']))
        self.assertEqual(self.owner(), ('DONE', '担当X'))

    def test_same_field_conflict(self):
        self.browser('save', task='TASK-003', owner='担当X')
        self.db_change('db-1', 'owner', '担当C', '担当Y')
        after = self.browser('reopen', task='TASK-003')['after']
        self.assertIn('【競合の可能性あり】', after['notice'])
        before = self.db()
        status, body = self.apply(self.saved())
        self.assertEqual((status, body['kind']), (409, 'Refused'))
        self.assertIn('conflict on TASK-003: owner', body['error'])
        self.assertEqual(self.owner()[1], '担当Y')
        self.assertEqual(self.db()[:2], before[:2], 'only the refusal is recorded')


class Rejections(Browser):
    def test_generation_change(self):
        self.browser('save', task='TASK-003', owner='担当X')
        rc.backup(self.conn, self.dir / 'b.sqlite3')
        rc.restore(self.dir / 'b.sqlite3', self.dir / 'restored.sqlite3', ACTOR, EVIDENCE)
        restored = w3.open_db(str(self.dir / 'restored.sqlite3'))
        self.addCleanup(restored.close)
        rc.enable_writes(restored, ACTOR, EVIDENCE, {'TASK': 5})
        self.server.db_path = str(self.dir / 'restored.sqlite3')
        status, body = self.apply(self.saved())
        self.assertEqual((status, body['kind']), (409, 'SaveRejected'))
        self.assertIn('generation changed', body['error'])
        self.assertEqual(restored.execute("SELECT owner FROM tasks WHERE id = 'TASK-003'").fetchone()[0], '担当C')

    def test_unsupported_mixed_edit_through_the_ui(self):
        before = self.db()
        self.browser('save', task='TASK-003', owner='担当X', addPrerequisite='TASK-005')
        status, body = self.apply(self.saved())
        self.assertEqual((status, body['kind']), (409, 'SaveRejected'))
        self.assertIn('unsupported changes, nothing applied: edges', body['error'])
        self.assertEqual(self.db(), before)


class Isolation(Browser):
    def test_other_origins_are_blocked_before_sending(self):
        result = self.browser('blocked', url='http://blocked.invalid/probe')
        self.assertEqual(result['blocked'], ['http://blocked.invalid/probe'])
        self.assertTrue(result['fetch'].startswith('failed'))
        self.assertNotIn(('GET', '/probe'), self.server.requests)

    def test_served_paths_and_no_production_port(self):
        self.browser('save', task='TASK-003', owner='担当X')
        paths = {f"{m} {p.split('?')[0]}" for m, p in self.server.requests}
        self.assertTrue(paths <= EXPECTED_PATHS, paths - EXPECTED_PATHS)
        self.assertNotIn(':8088', self.server.origin)
        self.assertEqual(len(self.server.pages), 1)
        page = self.server.pages[0]
        for _, new, _ in vs.PATCHES:
            self.assertIn(new, page)


if __name__ == '__main__':
    sys.exit(0 if unittest.main(exit=False, verbosity=2 if '-v' in sys.argv else 1).result.wasSuccessful() else 1)
