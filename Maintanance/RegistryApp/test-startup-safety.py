#!/usr/bin/env python3
"""OPS-189: startup safety and the restart notice, with real serve.py processes.

Every server runs from a private copy of the Maintanance tree (its tracked and untracked-but-not-ignored files, taken
from this checkout once per run) inside a temporary directory, with its own output, tools record, approvals DB and Inbox. The copy is what lets the restart test edit studio_store.py without
touching this checkout. Ports are test-only; 8088 is never used.

- An occupied port: launching against a pre-existing output fails, and index.html, registry.json and the tools record
  keep their exact bytes (the server binds before it generates; nothing is generated when it cannot serve).
- Normal startup serves a valid page. When generation fails after the socket is bound, the process exits non-zero, never
  answers with incomplete output, and the port is free again.
- Editing studio_store.py after startup makes the real /server-status report restartRecommended and the real page show
  its restart notice; before the edit both say nothing changed. runtime_status is not mocked.

Run from the repository root: python3 -B Maintanance/RegistryApp/test-startup-safety.py -v
Needs: git (to list the files to copy), node, the global Playwright with WebKit, and node/marked for sync (a live
local-tools.json is copied read-only into each output; or set REGISTRY_STUDIO_MARKED).
"""
import json
import os
import shutil
import socket
import subprocess
import sys
import tempfile
import time
import unittest
import urllib.request
from pathlib import Path

APP = Path(__file__).resolve().parent
ROOT = APP.parent.parent
COPIED = ('Maintanance',)
BLOCK = ['/activity-events', '/activity-commits', '/continuity', '/approval-probe', '/work-progress']
OLD = {'index.html': b'<html>previous page</html>\n', 'registry.json': b'previous registry.json, not JSON (sync reads it as unreadable and regenerates)\n', 'local-tools.json': b'{"previous": "tools"}\n'}


def free_port():
    with socket.socket() as s:
        s.bind(('127.0.0.1', 0))
        return s.getsockname()[1]


class Startup(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.tree = tempfile.TemporaryDirectory(prefix='ops189-tree-')
        cls.root = Path(cls.tree.name)
        files = subprocess.run(['git', 'ls-files', '-z', '--cached', '--others', '--exclude-standard', '--', *COPIED], cwd=ROOT,
                               capture_output=True, check=True).stdout.decode().split('\0')
        for rel in filter(None, files):
            src = ROOT / rel
            if src.is_file():
                (cls.root / rel).parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(src, cls.root / rel)
        cls.app = cls.root / 'Maintanance' / 'RegistryApp'

    @classmethod
    def tearDownClass(cls):
        cls.tree.cleanup()

    def setUp(self):
        tmp = tempfile.TemporaryDirectory(prefix='ops189-')
        self.addCleanup(tmp.cleanup)
        self.d = d = Path(tmp.name)
        for name in ('out', 'inbox', 'driver'):
            (d / name).mkdir()
        self.env = dict(os.environ, REGISTRY_STUDIO_APPROVALS_DB=str(d / 'approvals.sqlite3'), REGISTRY_STUDIO_INBOX=str(d / 'inbox'),
                        REGISTRY_STUDIO_APP=str(d / 'out'), REGISTRY_STUDIO_TOOLS=str(d / 'out' / 'local-tools.json'))
        self.live_tools = APP / 'local-tools.json'

    def tools(self):
        if self.live_tools.exists():  # read-only copy so sync.py finds node/marked
            (self.d / 'out' / 'local-tools.json').write_bytes(self.live_tools.read_bytes())

    def launch(self, port, env=None):
        proc = subprocess.Popen([sys.executable, '-B', str(self.app / 'serve.py'), '--port', str(port), '--output', str(self.d / 'out')],
                                cwd=self.root, env=env or self.env, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
        self.addCleanup(lambda: proc.poll() is None and (proc.terminate(), proc.wait(10)))
        self.addCleanup(proc.stdout.close)
        return proc

    def until_serving(self, proc):
        lines = []
        for line in proc.stdout:
            lines.append(line)
            if line.startswith('Registry Studio: http://127.0.0.1:'):
                return lines
        self.fail('the server did not start:\n' + ''.join(lines)[-3000:])

    def output_bytes(self):
        return {name: (self.d / 'out' / name).read_bytes() for name in OLD}

    def test_occupied_port_changes_nothing(self):
        for name, data in OLD.items():
            (self.d / 'out' / name).write_bytes(data)
        if self.live_tools.exists():  # sync could succeed (and rewrite the tools record) if it ran
            self.env['REGISTRY_STUDIO_NODE'] = json.loads(self.live_tools.read_text())['node']
        with socket.socket() as busy:
            busy.bind(('127.0.0.1', 0))
            busy.listen()
            proc = self.launch(busy.getsockname()[1])
            out = proc.communicate(timeout=300)[0]
        self.assertNotEqual(proc.returncode, 0, out)
        self.assertNotIn('Registry Studio: http://', out)
        self.assertNotIn('sync complete', out, 'nothing was generated for a server that cannot serve')
        self.assertEqual(self.output_bytes(), OLD, 'index.html, registry.json and the tools record keep their bytes')

    def test_normal_startup_serves_a_valid_page(self):
        self.tools()
        port = free_port()
        proc = self.launch(port)
        self.until_serving(proc)
        with urllib.request.urlopen(f'http://127.0.0.1:{port}/', timeout=30) as r:
            page = r.read().decode('utf-8')
        self.assertIn('<script id="seed" type="application/json">', page)
        self.assertIn('id="serverRestartNotice"', page)
        self.assertEqual(page, (self.d / 'out' / 'index.html').read_text(encoding='utf-8'), 'the page sync.py generated')

    def test_failed_generation_exits_and_releases_the_port(self):
        for name, data in OLD.items():
            (self.d / 'out' / name).write_bytes(data)
        port = free_port()
        env = dict(self.env, REGISTRY_STUDIO_NODE='/usr/bin/false')  # build-documents.mjs then fails inside sync.py
        proc = self.launch(port, env)
        out = proc.communicate(timeout=300)[0]
        self.assertNotEqual(proc.returncode, 0, out)
        self.assertNotIn('Registry Studio: http://', out, 'nothing is served')
        self.assertIn('FAILED', out)
        self.assertEqual(self.output_bytes(), OLD, 'sync restored the previous output')
        with socket.socket() as again:
            again.bind(('127.0.0.1', port))  # raises if the exited process still held it

    def test_editing_studio_store_recommends_a_restart(self):
        self.tools()
        port = free_port()
        origin = f'http://127.0.0.1:{port}'
        proc = self.launch(port)
        self.until_serving(proc)
        status = lambda: json.loads(urllib.request.urlopen(origin + '/server-status', timeout=30).read())
        self.assertEqual(status(), {'restartRecommended': False, 'changedFiles': []}, 'unchanged baseline')
        params = self.d / 'driver' / 'params.json'
        params.write_text(json.dumps({'blockPaths': BLOCK, 'timeoutMs': 30000}), encoding='utf-8')
        driver = subprocess.Popen(['node', str(APP / 'startup_notice_e2e.cjs'), origin, str(params), str(self.d / 'driver')],
                                  cwd=APP, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
        self.addCleanup(lambda: driver.poll() is None and (driver.kill(), driver.wait(10)))
        self.addCleanup(driver.stdout.close)
        phase1, end = self.d / 'driver' / 'phase1.json', time.time() + 60
        while not phase1.exists() and driver.poll() is None and time.time() < end:
            time.sleep(0.05)
        if not phase1.exists():
            driver.wait(60)
            self.fail((self.d / 'driver' / 'result.json').read_text(encoding='utf-8'))
        before = json.loads(phase1.read_text(encoding='utf-8'))['before']
        self.assertTrue(before['hidden'], 'no notice before the edit')
        original = (self.app / 'studio_store.py').read_bytes()
        self.addCleanup((self.app / 'studio_store.py').write_bytes, original)  # the private copy is restored for later tests
        with open(self.app / 'studio_store.py', 'a', encoding='utf-8') as f:
            f.write('\n# OPS-189 test edit after startup\n')
        self.assertEqual(status(), {'restartRecommended': True, 'changedFiles': ['studio_store.py']})
        (self.d / 'driver' / 'go.json').write_text('{}', encoding='utf-8')
        driver.wait(90)
        result = json.loads((self.d / 'driver' / 'result.json').read_text(encoding='utf-8'))
        self.assertTrue(result['ok'], result.get('error'))
        self.assertFalse(result['after']['hidden'])
        self.assertIn('サーバーの再起動をおすすめします', result['after']['text'])
        self.assertIn({'restartRecommended': True, 'changedFiles': ['studio_store.py']}, result['statusAnswers'], 'the page read the real status')
        self.assertEqual((result['blocked'], result['pageErrors']), ([], []))

    def test_every_retained_studio_module_is_watched(self):
        """Every module of this directory that serve.py retains at import is in the restart fingerprints."""
        code = ('import sys, json; sys.path.insert(0, sys.argv[1]); import serve; '
                'print(json.dumps(sorted(n for n, m in sys.modules.items() if getattr(m, "__file__", None) and '
                '__import__("pathlib").Path(m.__file__).resolve().parent == __import__("pathlib").Path(sys.argv[1]).resolve()) ))')
        run = subprocess.run([sys.executable, '-B', '-c', code, str(self.app)], cwd=self.root, env=self.env, capture_output=True, text=True, timeout=60)
        self.assertEqual(run.returncode, 0, run.stderr)
        retained = {n + '.py' for n in json.loads(run.stdout) if n != 'serve'} | {'serve.py'}
        watched = set(json.loads(subprocess.run([sys.executable, '-B', '-c', 'import sys, json; sys.path.insert(0, sys.argv[1]); import serve; print(json.dumps(list(serve.runtime_fingerprints())))', str(self.app)],
                                                cwd=self.root, env=self.env, capture_output=True, text=True, timeout=60, check=True).stdout))
        self.assertEqual(retained - watched, set(), 'retained but not watched for a restart')


if __name__ == '__main__':
    unittest.main()
