#!/usr/bin/env python3
"""OPS-181 tests: serve.py's default-off V3 mode (--v3-db PATH --v3-saves DIR). Everything runs in process on
TemporaryDirectory roots and port 0: serve.OUTPUT, serve.INBOX and serve.V3 are patched, sync.py is never run (its call
is replaced), and the page's live pollers (letters, activity, approvals, continuity) are answered 404 by the test
handler so no live store is read. The DB is a fixture V3 DB; its bytes are compared before and after.

Run: python3 -B Maintanance/RegistryApp/v3/test_serve_v3_mode.py -v
"""
import copy
import hashlib
import json
import re
import sqlite3
import subprocess
import sys
import tempfile
import threading
import unittest
import urllib.error
import urllib.request
from pathlib import Path
from unittest import mock

HERE = Path(__file__).resolve().parent
APP = HERE.parent
sys.path.insert(0, str(HERE))
import hermetic  # noqa: E402,F401  (first: temporary roots for every live path, OPS-167 K9)
sys.path.insert(0, str(APP))
import inbox  # noqa: E402
import registry_v3_write as w3  # noqa: E402
import serve  # noqa: E402
import studio_adapter as sa  # noqa: E402
from test_browser_roundtrip import ACTOR, BASE, EVIDENCE  # noqa: E402
from test_v3_inbox import legacy_doc  # noqa: E402

SERVED_GET = {'/', '/index.html', '/registry.json', '/workspace', '/server-status'}
SERVED_POST = {'/save', '/sync'}
MARK_DOCS, MARK_PENDING = 'OPS181-documents-marker', 'OPS181-pending-marker'


class Isolated(serve.Handler):
    """serve.Handler as it is, for the Studio routes this mode changes; the live pollers are not served here."""

    def log_message(self, *args):
        pass

    def do_GET(self):
        self.server.requests.append('GET ' + self.path)
        return super().do_GET() if self.path in SERVED_GET else self.reply(404, {'error': 'not served in this test'})

    def do_POST(self):
        self.server.requests.append('POST ' + self.path)
        return super().do_POST() if self.path in SERVED_POST else self.reply(404, {'error': 'not served in this test'})


def sync_built_page():
    """The template as sync.py would leave it: real documents and pending blocks (markers stand in for their content)."""
    html = (APP / 'index.template.html').read_text(encoding='utf-8')
    for name, value in (('documents', {'generatedAt': 'g', 'files': {'Maintanance/X.md': MARK_DOCS}}),
                        ('pendingSeed', {'source': MARK_PENDING, 'sources': [], 'generatedAt': '', 'entries': [], 'requests': []})):
        block = f'<script id="{name}" type="application/json">' + json.dumps(value, ensure_ascii=False) + '</script>'
        html, n = re.subn(rf'<script id="{name}" type="application/json">.*?</script>', lambda m: block, html, count=1, flags=re.S)
        assert n == 1, name
    return html


class Mode(unittest.TestCase):
    def setUp(self):
        tmp = tempfile.TemporaryDirectory()
        self.addCleanup(tmp.cleanup)
        self.dir = Path(tmp.name)
        self.db = self.dir / 'v3 #db?.sqlite3'  # characters that would be URI syntax if not escaped
        w3.create(str(self.db), copy.deepcopy(BASE))
        self.saves, self.legacy_inbox, self.out = self.dir / 'saves', self.dir / 'legacy-inbox', self.dir / 'out'
        for d in (self.saves, self.legacy_inbox, self.out):
            d.mkdir()
        (self.out / 'index.html').write_text(sync_built_page(), encoding='utf-8')
        (self.out / 'registry.json').write_text('{"legacy": true}', encoding='utf-8')
        self.sync_calls = []
        fake_sync = lambda *a, **k: self.sync_calls.append(a[0]) or subprocess.CompletedProcess(a[0], 0, 'synced (stub)\n', '')
        for name, value in (('OUTPUT', self.out), ('INBOX', self.legacy_inbox)):
            patcher = mock.patch.object(serve, name, value)
            patcher.start()
            self.addCleanup(patcher.stop)
        fake = mock.Mock(run=mock.Mock(side_effect=fake_sync), TimeoutExpired=subprocess.TimeoutExpired)
        patcher = mock.patch.object(serve, 'subprocess', fake)  # only serve's view of subprocess; sync.py never runs
        patcher.start()
        self.addCleanup(patcher.stop)

    def start(self, v3=True):
        patcher = mock.patch.object(serve, 'V3', serve.v3_mode(self.db, self.saves) if v3 else None)
        patcher.start()
        self.addCleanup(patcher.stop)
        self.server = serve.ThreadingHTTPServer(('127.0.0.1', 0), Isolated)
        self.server.requests = []
        threading.Thread(target=self.server.serve_forever, daemon=True).start()
        self.addCleanup(self.server.server_close)
        self.addCleanup(self.server.shutdown)
        self.origin = f'http://127.0.0.1:{self.server.server_port}'
        self.assertNotIn(':8088', self.origin)

    def get(self, path):
        with urllib.request.urlopen(self.origin + path, timeout=30) as r:
            return r.status, r.read()

    def post(self, path, body, action):
        data = body if isinstance(body, bytes) else json.dumps(body, ensure_ascii=False).encode('utf-8')
        req = urllib.request.Request(self.origin + path, data=data, method='POST', headers={
            'Content-Type': 'application/json', 'Origin': self.origin, 'X-Registry-Studio': action})
        try:
            with urllib.request.urlopen(req, timeout=30) as r:
                return r.status, json.loads(r.read())
        except urllib.error.HTTPError as e:
            with e:
                return e.code, json.loads(e.read())

    def db_bytes(self):
        return hashlib.sha256(self.db.read_bytes()).hexdigest()

    def export(self):
        conn = w3.open_db(str(self.db))
        try:
            return sa.export_doc(conn)
        finally:
            conn.close()

    def v3_save_doc(self):
        doc = self.export()
        next(t for t in doc['tasks'] if t['id'] == 'TASK-003')['owner'] = '担当X'
        return doc


class Settings(Mode):
    def test_refusals_create_nothing(self):
        missing_db, missing_dir = self.dir / 'none.sqlite3', self.dir / 'none-dir'
        for db, saves, words in ((missing_db, self.saves, 'no such file'), (self.db, missing_dir, 'no such directory')):
            with self.assertRaises(ValueError) as caught:
                serve.v3_mode(db, saves)
            self.assertIn(words, str(caught.exception))
        self.assertFalse(missing_db.exists() or missing_dir.exists(), 'nothing is created')
        other = self.dir / 'other.sqlite3'
        c = sqlite3.connect(other)
        c.execute('CREATE TABLE t (x)')
        c.close()
        text = self.dir / 'text.sqlite3'
        text.write_text('not a database', encoding='utf-8')
        extra, version = self.dir / 'extra.sqlite3', self.dir / 'version.sqlite3'
        for path, sql in ((extra, 'CREATE TABLE extra (x)'), (version, 'UPDATE db_meta SET schema_version = 99')):
            path.write_bytes(self.db.read_bytes())
            c = sqlite3.connect(path)
            c.execute(sql)
            c.commit()
            c.close()
        for path, words in ((other, 'tables differ'), (text, 'not a V3 DB'), (extra, 'tables differ: extra'), (version, 'schema version')):
            with self.subTest(path=path.name), self.assertRaises(ValueError) as caught:
                serve.v3_mode(path, self.saves)
            self.assertIn(words, str(caught.exception))
        before = self.db_bytes()
        self.assertEqual(serve.v3_mode(self.db, self.saves), {'db': self.db.resolve(), 'saves': self.saves.resolve()})
        self.assertEqual(self.db_bytes(), before, 'validation only reads')

    def test_page_connection_is_read_only(self):
        conn = serve.v3_open(self.db)
        try:
            with self.assertRaises(sqlite3.OperationalError) as caught:
                conn.execute('UPDATE db_meta SET generation = generation')
            self.assertIn('readonly', str(caught.exception))
        finally:
            conn.close()
        missing = self.dir / 'never.sqlite3'
        with self.assertRaises(sqlite3.OperationalError):
            serve.v3_open(missing).execute('SELECT 1')
        self.assertFalse(missing.exists(), 'opening never creates a DB')

    def test_arguments(self):
        cases = ((['--v3-db', str(self.db)], 'go together'), (['--v3-saves', str(self.saves)], 'go together'),
                 (['--v3-db', str(self.dir / 'none.sqlite3'), '--v3-saves', str(self.saves)], 'no such file'))
        for argv, words in cases:
            with self.subTest(argv=argv), mock.patch.object(sys, 'argv', ['serve.py', *argv]), \
                    mock.patch.object(serve, 'ThreadingHTTPServer', side_effect=AssertionError('no server may start')), \
                    mock.patch('sys.stderr') as err, self.assertRaises(SystemExit) as caught:
                serve.main()
            self.assertEqual(caught.exception.code, 2)
            self.assertIn(words, ''.join(c.args[0] for c in err.write.call_args_list))
        self.assertEqual(self.sync_calls, [], 'sync.py never ran for a refused start')
        self.assertFalse((self.dir / 'none.sqlite3').exists())

    def test_default_mode_imports_nothing_of_v3(self):
        code = ('import sys; sys.path.insert(0, sys.argv[1]); import serve; '
                'print(serve.V3, sorted(m for m in ("registry_v3_write", "studio_adapter", "registry_v3_read") if m in sys.modules))')
        out = subprocess.run([sys.executable, '-B', '-c', code, str(APP)], capture_output=True, text=True, timeout=60)
        self.assertEqual(out.stdout.strip(), 'None []', out.stderr)
        self.assertFalse(set(serve.V3_MODULES) & set(serve.runtime_fingerprints()), 'no V3 fingerprint without the mode')
        self.start()
        self.assertTrue(set(serve.V3_MODULES) <= set(serve.runtime_fingerprints()))


class Output(Mode):
    """--output DIR (OPS-167 K9 B1): sync.py writes there, its tools record included; nothing is created."""

    def run_main(self, argv):
        patches = [mock.patch.object(serve, n, getattr(serve, n)) for n in ('OUTPUT', 'WORK_PROGRESS', 'SYNC_ENV', 'V3', 'STARTUP_FINGERPRINTS')]
        server = mock.Mock(server_port=1234, serve_forever=mock.Mock(side_effect=KeyboardInterrupt))
        with mock.patch.object(sys, 'argv', ['serve.py', *argv]), mock.patch.object(serve, 'ThreadingHTTPServer', return_value=server), \
                mock.patch('builtins.print'):
            for patcher in patches:
                patcher.start()
            try:
                serve.main()
                return serve.OUTPUT, serve.WORK_PROGRESS, serve.SYNC_ENV
            finally:
                for patcher in reversed(patches):
                    patcher.stop()

    def test_output_redirects_sync(self):
        target = self.dir / 'isolated-out'
        target.mkdir()
        output, progress, env = self.run_main(['--port', '0', '--output', str(target)])
        self.assertEqual((output, progress), (target.resolve(), target.resolve() / 'work-progress.json'))
        self.assertEqual((env['REGISTRY_STUDIO_APP'], env['REGISTRY_STUDIO_TOOLS']), (str(target.resolve()), str(target.resolve() / 'local-tools.json')))
        self.assertEqual(len(self.sync_calls), 1)
        call = serve.subprocess.run.call_args
        self.assertEqual(call.kwargs['env']['REGISTRY_STUDIO_APP'], str(target.resolve()), 'the startup sync writes into --output')

    def test_missing_output_is_refused(self):
        with mock.patch('sys.stderr'), self.assertRaises(SystemExit) as caught:
            self.run_main(['--output', str(self.dir / 'none')])
        self.assertEqual(caught.exception.code, 2)
        self.assertFalse((self.dir / 'none').exists())
        self.assertEqual(self.sync_calls, [])

    def test_default_keeps_cache_and_no_env(self):
        output, _, env = self.run_main(['--port', '0'])
        self.assertEqual((output, env), (self.out, None))  # setUp's patched OUTPUT: untouched without --output
        self.assertNotIn('env', serve.subprocess.run.call_args.kwargs, 'the default sync call is exactly as before')


class RealProcess(unittest.TestCase):
    """The real serve.py process (B1): --port 0 --output TMP --v3-db --v3-saves, the real startup sync.py into TMP, the
    tools record copied into TMP, the approvals DB in TMP. Only /, /registry.json and /workspace are fetched (no live
    poller). The live Cache and local-tools.json must not change; the process is stopped at the end."""

    def test_isolated_launch(self):
        tmp = tempfile.TemporaryDirectory()
        self.addCleanup(tmp.cleanup)
        d = Path(tmp.name)
        for name in ('out', 'saves', 'legacy'):
            (d / name).mkdir()
        w3.create(str(d / 'db.sqlite3'), copy.deepcopy(BASE))
        live_tools = APP / 'local-tools.json'
        if live_tools.exists():
            (d / 'out' / 'local-tools.json').write_bytes(live_tools.read_bytes())  # read-only copy so sync.py finds node/marked
        watched = [live_tools, *(APP.parent / 'Cache' / 'RegistryStudio').glob('*')]
        before = {p: (p.stat().st_mtime_ns, hashlib.sha256(p.read_bytes()).hexdigest()) for p in watched if p.is_file()}
        # REGISTRY_STUDIO_APP/TOOLS also point into TMP from the parent environment: even a regression of --output (which the
        # in-process Output tests catch) cannot reach the live Cache or local-tools.json from this test (a lesson of K9)
        env = dict(__import__('os').environ, REGISTRY_STUDIO_APPROVALS_DB=str(d / 'approvals.sqlite3'), REGISTRY_STUDIO_INBOX=str(d / 'legacy'),
                   REGISTRY_STUDIO_APP=str(d / 'out'), REGISTRY_STUDIO_TOOLS=str(d / 'out' / 'local-tools.json'))
        proc = subprocess.Popen([sys.executable, '-B', str(APP / 'serve.py'), '--port', '0', '--output', str(d / 'out'),
                                 '--v3-db', str(d / 'db.sqlite3'), '--v3-saves', str(d / 'saves')],
                                cwd=APP.parent.parent, env=env, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
        self.addCleanup(proc.stdout.close)
        self.addCleanup(lambda: (proc.poll() is None and (proc.terminate(), proc.wait(10))))
        lines = []
        for line in proc.stdout:
            lines.append(line)
            if line.startswith('Registry Studio: http://127.0.0.1:'):
                break
        self.assertIsNone(proc.poll(), ''.join(lines)[-3000:])
        port = int(re.search(r'127\.0\.0\.1:(\d+)/', lines[-1]).group(1))
        self.assertNotEqual(port, 8088)
        self.assertIn('V3 mode', lines[-1])
        origin = f'http://127.0.0.1:{port}'
        with urllib.request.urlopen(origin + '/', timeout=30) as r:
            page = r.read().decode('utf-8')
        seed = json.loads(re.search(r'<script id="seed" type="application/json">(.*?)</script>', page, re.S).group(1))
        self.assertEqual(seed['source']['kind'], 'v3-export')
        docs = json.loads(re.search(r'<script id="documents" type="application/json">(.*?)</script>', page, re.S).group(1))
        self.assertTrue(docs['files'], 'the documents built by the real sync.py are kept')
        with urllib.request.urlopen(origin + '/workspace', timeout=30) as r:
            self.assertIsNone(json.loads(r.read())['save'])
        self.assertTrue((d / 'out' / 'index.html').is_file() and (d / 'out' / 'registry.json').is_file(), 'sync.py wrote into --output')
        proc.terminate()
        proc.wait(10)
        after = {p: (p.stat().st_mtime_ns, hashlib.sha256(p.read_bytes()).hexdigest()) for p in watched if p.is_file()}
        self.assertEqual(after, before, 'the live Cache and local-tools.json are untouched')
        hermetic.assert_live_unchanged(self)


class Routes(Mode):
    def test_v3_routes(self):
        self.start()
        before = self.db_bytes()
        status, page = self.get('/')
        page = page.decode('utf-8')
        seed = json.loads(re.search(r'<script id="seed" type="application/json">(.*?)</script>', page, re.S).group(1))
        self.assertEqual((status, seed['source']['kind'], seed['source']['generation']), (200, 'v3-export', self.export()['source']['generation']))
        self.assertIn(MARK_DOCS, page, 'documents stay as sync.py built them')
        self.assertIn(MARK_PENDING, page, 'the pending queue stays as built')
        self.assertEqual(self.get('/index.html')[1].decode('utf-8'), page)
        status, body = self.get('/registry.json')
        self.assertEqual(json.loads(body), self.export())
        status, body = self.post('/save', self.v3_save_doc(), 'save')
        self.assertEqual((status, body['ok']), (200, True), body)
        self.assertEqual(Path(body['folder']), self.saves.resolve())
        self.assertEqual([p.name for p in self.saves.glob('*.json')], [body['file']])
        self.assertEqual(list(self.legacy_inbox.iterdir()), [], 'the legacy Inbox is not used')
        status, legacy = self.post('/save', legacy_doc(), 'save')
        self.assertEqual(status, 400)
        self.assertIn('V3の編集版だけ', legacy['error'])
        status, bad_parent = self.post('/save', dict(self.v3_save_doc(), studioSave={'parent': 'no-such'}), 'save')
        self.assertEqual(status, 409)
        self.assertEqual(len(list(self.saves.glob('*.json'))), 1, 'nothing more stored')
        inbox.append_save(legacy_doc(), None, self.saves)  # a legacy save beside: kept, never resumed
        status, body = self.get('/workspace')
        out = json.loads(body)
        self.assertEqual((out['save']['source']['kind'], len(out['unresolvedLegacy']), out['reconciliation']), ('v3-export', 1, 'known'))
        status, body = self.post('/sync', {}, 'sync')
        self.assertEqual((status, body['ok']), (200, True))
        self.assertEqual([Path(c[1]).name for c in self.sync_calls], ['sync.py'], '/sync runs sync.py as before (stubbed here)')
        self.assertEqual(self.db_bytes(), before, 'no route writes the DB')

    def test_default_mode_is_unchanged(self):
        self.start(v3=False)
        self.assertEqual(self.get('/')[1], (self.out / 'index.html').read_bytes())
        self.assertEqual(self.get('/registry.json')[1], b'{"legacy": true}')
        self.assertEqual(json.loads(self.get('/workspace')[1]), None)
        status, body = self.post('/save', legacy_doc(), 'save')
        self.assertEqual(status, 200, body)
        self.assertEqual(len(list(self.legacy_inbox.glob('*.json'))), 1)
        self.assertEqual(list(self.saves.iterdir()), [])
        status, body = self.post('/save', self.v3_save_doc(), 'save')
        self.assertEqual(status, 400, 'the legacy mode keeps refusing a document without source.sha256')


class Browser(Mode):
    """The real page from serve.py's V3 mode in headless WebKit, through the accepted driver."""

    def browser(self, mode, **params):
        self.n = getattr(self, 'n', 0) + 1
        p, out = self.dir / f'params-{self.n}.json', self.dir / f'out-{self.n}.json'
        p.write_text(json.dumps(params, ensure_ascii=False), encoding='utf-8')
        run = subprocess.run(['node', str(HERE / 'browser_roundtrip.cjs'), self.origin, mode, str(p), str(out)], capture_output=True, text=True, timeout=180)
        self.assertEqual(run.returncode, 0, run.stderr[-2000:])
        result = json.loads(out.read_text(encoding='utf-8'))
        self.assertEqual((result['pageErrors'], result['blocked']), ([], []))
        return result

    def cli(self, *args):
        run = subprocess.run([sys.executable, '-B', str(HERE / 'registry_v3_cli.py'), *map(str, args)], capture_output=True, text=True, timeout=60)
        return run.returncode, json.loads(run.stdout)

    def test_save_resume_cli_apply_and_restart_suggestion(self):
        self.start()
        saved = self.browser('save', task='TASK-003', owner='担当X')
        self.assertIn('サーバーに保存しました', saved['after']['status'])
        stored = sorted(self.saves.glob('*.json'))
        self.assertEqual(len(stored), 1)
        sid = json.loads(stored[0].read_text(encoding='utf-8'))['studioSave']['saveId']
        before = self.browser('look')
        self.assertIn(f'編集版 {sid} を再開中', before['after']['banner'])
        self.assertFalse(before['after']['restartSuggested'], 'nothing reflected yet')
        sel = self.dir / 'sel.json'
        sel.write_text(json.dumps({'selected': ['task:TASK-003'], 'actor': ACTOR, 'evidence': EVIDENCE}, ensure_ascii=False), encoding='utf-8')
        code, out = self.cli('apply-groups', '--db', self.db, '--save', stored[0], '--selection', sel)
        self.assertEqual((code, out['status']), (0, 'ok'), out)
        after = self.browser('look')
        self.assertIn(f'編集版 {sid} を再開中', after['after']['banner'])
        self.assertTrue(after['after']['restartSuggested'], 'the page sees through /registry.json that its edits are in the DB')
        self.assertIn('GET /registry.json', self.server.requests)
        self.assertEqual(self.sync_calls, [], 'no sync.py run')

    def test_mixed_saves_and_unknown_history(self):
        self.start()
        self.browser('save', task='TASK-003', owner='担当X')
        sid = json.loads(sorted(self.saves.glob('*.json'))[0].read_text(encoding='utf-8'))['studioSave']['saveId']
        inbox.append_save(legacy_doc(), None, self.saves)
        (self.saves / inbox.IMPORTS).write_text('{"saveId": []}\n', encoding='utf-8')
        out = self.browser('look')
        self.assertIn(f'編集版 {sid} を再開中', out['after']['banner'])
        self.assertIn('取り込み記録が読めないため', out['after']['status'])


if __name__ == '__main__':
    sys.exit(0 if unittest.main(exit=False, verbosity=2 if '-v' in sys.argv else 1).result.wasSuccessful() else 1)
