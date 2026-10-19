#!/usr/bin/env python3
"""OPS-167 B4: sync.py --v3-db, the V3 document/pending build without the legacy structural validation, and serve.py's
V3 startup and POST /sync using it. The DB is imported once from a snapshot copy of the live repository (read only);
every output, tools record and DB copy lives in a TemporaryDirectory under the hermetic guard. Documents are read from
the repository as they are (none is created there): "outside the old folder layout" uses an existing Current/ document.

Run: python3 -B Maintanance/RegistryApp/v3/test_v3_sync.py -v
"""
import hashlib
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
import unittest
import urllib.request
from pathlib import Path
from unittest import mock

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
import hermetic  # noqa: E402,F401  (first: temporary roots for every live path, OPS-167 K9)
APP, ROOT = HERE.parent, HERE.parent.parent.parent
sys.path.insert(0, str(APP))
import registry_v3_write as w3  # noqa: E402
import serve  # noqa: E402
import shadow_import as si  # noqa: E402
import studio_adapter as sa  # noqa: E402

OUTSIDE = 'Maintanance/Current/TASK_REGISTRY_V3_MODULE_PROMOTION.md'  # an existing document outside Milestones/
ACTOR = '姫（B4試験）'
_base = {}


def setUpModule():
    tmp = tempfile.TemporaryDirectory()
    _base['tmp'] = tmp
    _base['db'] = Path(tmp.name) / 'base.sqlite3'
    report = si.import_db(_base['db'])
    assert report['created'], report.get('differences')


def tearDownModule():
    _base.pop('tmp').cleanup()


def block(html, name):
    return json.loads(re.search(rf'<script id="{name}" type="application/json">(.*?)</script>', html, re.S).group(1))


class V3Sync(unittest.TestCase):
    def setUp(self):
        tmp = tempfile.TemporaryDirectory()
        self.addCleanup(tmp.cleanup)
        self.dir = Path(tmp.name)
        self.db = self.dir / 'db.sqlite3'
        shutil.copy2(_base['db'], self.db)
        self.out = self.dir / 'out'
        self.out.mkdir()
        if (APP / 'local-tools.json').exists():  # a read-only copy, so node/marked are found; the copy is what gets rewritten
            shutil.copy2(APP / 'local-tools.json', self.out / 'local-tools.json')
        self.env = dict(os.environ, REGISTRY_STUDIO_APP=str(self.out), REGISTRY_STUDIO_TOOLS=str(self.out / 'local-tools.json'))
        self.conn = w3.open_db(str(self.db))
        self.addCleanup(self.conn.close)

    def sync(self):
        return subprocess.run([sys.executable, '-B', str(APP / 'sync.py'), '--v3-db', str(self.db)], cwd=ROOT, env=self.env,
                              capture_output=True, text=True, timeout=300)

    def page(self):
        return (self.out / 'index.html').read_text(encoding='utf-8')

    def apply(self, op, **req):
        w3.apply(self.conn, op, {'generation': w3.generation(self.conn), 'actor': ACTOR, 'evidence': ['B4試験'], **req})

    def change_everything(self):
        """DB-only: a reorder, a new version (no folder), a new card whose document is outside Milestones/, a focus."""
        version, cards = next((v, [r[0] for r in self.conn.execute('SELECT node FROM version_members WHERE version = ? ORDER BY position', (v,))])
                              for (v,) in self.conn.execute('SELECT name FROM versions ORDER BY position')
                              if self.conn.execute('SELECT COUNT(*) FROM version_members WHERE version = ?', (v,)).fetchone()[0] >= 2)
        self.apply('reorder', kind='apply_plan', cardsBase={version: cards}, cards={version: list(reversed(cards))})
        versions = [r[0] for r in self.conn.execute('SELECT name FROM versions ORDER BY position')]
        digest = hashlib.sha256((ROOT / OUTSIDE).read_bytes()).hexdigest()
        self.apply('new', kind='apply_plan', cardsBase={'9.9.9': []}, cards={'9.9.9': ['MS-B4OUTSIDE']}, versionsBase=versions,
                   newVersions=[{'name': '9.9.9', 'position': len(versions)}], draftMap={'draft-ms-1': 'MS-B4OUTSIDE'},
                   newCards={'MS-B4OUTSIDE': {'name': 'B4の外の文書', 'detail': OUTSIDE, 'documentEvidence': {'path': OUTSIDE, 'sha256': digest}}})
        self.conn.execute("UPDATE focus SET version = '9.9.9'")  # no write op for focus yet; directly, in this temporary DB
        return version, list(reversed(cards))

    def test_db_is_the_structure_and_documents_are_bundled(self):
        version, order = self.change_everything()
        run = self.sync()
        self.assertEqual(run.returncode, 0, run.stdout[-3000:])
        html, data = self.page(), json.loads((self.out / 'registry.json').read_text(encoding='utf-8'))
        seed = block(html, 'seed')
        self.assertEqual(seed, sa.export_doc(self.conn), 'the seed is the DB export')
        self.assertEqual(data['extraDocuments'], [si.REGISTRY])
        self.assertEqual(seed['milestoneHead'], '9.9.9', 'focus from the DB')
        cards = [m['id'] for m in seed['milestones'] if m['gate'].startswith(f'Maintanance/Milestones/{version}/') and 'recordedDone' in m]
        self.assertEqual(cards, order, 'card order from the DB')
        self.assertIn('MS-B4OUTSIDE', [m['id'] for m in seed['milestones']])
        docs = block(html, 'documents')
        self.assertIn(OUTSIDE, docs['files'], 'a document outside the old folder layout is bundled')
        self.assertIn(si.REGISTRY, docs['files'], 'the Registry view stays a bundled document')
        self.assertEqual(docs['missing'], [])
        self.assertIn('verify_v3.cjs passed', run.stdout)

    def test_missing_db_document_fails_and_keeps_the_previous_output(self):
        self.assertEqual(self.sync().returncode, 0)
        before = {p.name: p.read_bytes() for p in self.out.iterdir()}
        versions = [r[0] for r in self.conn.execute('SELECT name FROM versions ORDER BY position')]
        gone = 'Maintanance/Current/B4-does-not-exist.md'
        self.apply('ghost', kind='apply_plan', cardsBase={'9.9.9': []}, cards={'9.9.9': ['MS-B4GHOST']}, versionsBase=versions,
                   newVersions=[{'name': '9.9.9', 'position': len(versions)}], draftMap={'draft-ms-1': 'MS-B4GHOST'},
                   newCards={'MS-B4GHOST': {'name': 'ない文書', 'detail': gone, 'documentEvidence': {'path': gone, 'sha256': '0' * 64}}})
        run = self.sync()
        self.assertNotEqual(run.returncode, 0)
        self.assertIn('Documents the V3 DB refers to are missing (nothing was written):\n  ' + gone, run.stdout, 'named before anything is written, not silently left out')
        self.assertEqual({p.name: p.read_bytes() for p in self.out.iterdir()}, before, 'nothing was written')

    def test_the_legacy_structural_reader_is_not_used(self):
        code = ('import sys; sys.path.insert(0, sys.argv[1]); import sync\n'
                'def refuse(*a, **k):\n    raise AssertionError("legacy build() called")\n'
                'sync.build = refuse; sys.argv = ["sync.py", "--v3-db", sys.argv[2]]; sync.main()')
        run = subprocess.run([sys.executable, '-B', '-c', code, str(APP), str(self.db)], cwd=ROOT, env=self.env, capture_output=True, text=True, timeout=300)
        self.assertEqual(run.returncode, 0, (run.stdout + run.stderr)[-3000:])

    def test_extra_documents_are_bundled_on_their_own(self):
        """build-documents.mjs bundles extraDocuments even when no detail names them (the Registry view in V3 mode)."""
        tools = json.loads((self.out / 'local-tools.json').read_text(encoding='utf-8')) if (self.out / 'local-tools.json').exists() else {}
        node, marked = tools.get('node') or shutil.which('node'), tools.get('marked')
        (self.out / 'registry.json').write_text(json.dumps({'source': {'path': 'v3-db'}, 'tasks': [], 'milestones': [], 'extraDocuments': [si.REGISTRY]}), encoding='utf-8')
        (self.out / 'index.html').write_text('<html><script>\n</script></html>', encoding='utf-8')
        run = subprocess.run([node, str(APP / 'build-documents.mjs')] + ([marked] if marked else []), cwd=APP, env=self.env, capture_output=True, text=True, timeout=120)
        self.assertEqual(run.returncode, 0, run.stderr[-2000:])
        docs = block(self.page(), 'documents')
        self.assertEqual((sorted(docs['files']), docs['missing']), ([si.REGISTRY], []), 'v3-db is not a document; the Registry view is bundled')

    def test_refused_invocations_change_nothing(self):
        """--v3-db without a value, combined with --check or --show-tools, or naming a missing DB: refused before any
        side effect; the output folder, the tools record and the DB stay as they were."""
        state = lambda: ({p.name: p.read_bytes() for p in self.out.iterdir()}, self.db.read_bytes())
        before = state()
        cases = ((['--v3-db'], 2, 'needs the path'), (['--v3-db', '--check'], 2, 'needs the path'),
                 (['--v3-db', str(self.db), '--check'], 2, 'cannot be combined with --check'),
                 (['--v3-db', str(self.db), '--show-tools'], 2, 'cannot be combined with --show-tools'),
                 (['--check', '--v3-db', str(self.db)], 2, 'cannot be combined with --check'),
                 (['--v3-db', str(self.dir / 'none.sqlite3')], 1, 'no such file'))
        for args, code, words in cases:
            with self.subTest(args=args):
                run = subprocess.run([sys.executable, '-B', str(APP / 'sync.py'), *args], cwd=ROOT, env=self.env, capture_output=True, text=True, timeout=120)
                self.assertEqual(run.returncode, code, run.stdout[-1500:])
                self.assertIn(words, run.stdout)
                self.assertEqual(state(), before, 'no output, tools record or DB change')
        self.assertFalse((self.dir / 'none.sqlite3').exists())

    def test_serve_passes_v3_db_only_in_v3_mode(self):
        with mock.patch.object(serve, 'V3', None):
            self.assertEqual(serve.sync_args(), [])
        with mock.patch.object(serve, 'V3', {'db': self.db, 'saves': self.dir}):
            self.assertEqual(serve.sync_args(), ['--v3-db', str(self.db)])

    def test_real_isolated_startup_and_refresh(self):
        (self.dir / 'saves').mkdir()
        proc = subprocess.Popen([sys.executable, '-B', str(APP / 'serve.py'), '--port', '0', '--output', str(self.out), '--v3-db', str(self.db),
                                 '--v3-saves', str(self.dir / 'saves')], cwd=ROOT, env=dict(self.env, REGISTRY_STUDIO_APPROVALS_DB=str(self.dir / 'a.sqlite3')),
                                stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
        self.addCleanup(proc.stdout.close)
        self.addCleanup(lambda: (proc.poll() is None and (proc.terminate(), proc.wait(10))))
        lines = []
        for line in proc.stdout:
            lines.append(line)
            if line.startswith('Registry Studio: http://127.0.0.1:'):
                break
        self.assertIsNone(proc.poll(), ''.join(lines)[-3000:])
        self.assertIn('sync complete (V3)', ''.join(lines))
        origin = 'http://127.0.0.1:' + re.search(r'127\.0\.0\.1:(\d+)/', lines[-1]).group(1)
        version, order = self.change_everything()  # DB-only changes while the server runs
        req = urllib.request.Request(origin + '/sync', data=b'{}', method='POST', headers={'Content-Type': 'application/json', 'Origin': origin, 'X-Registry-Studio': 'sync'})
        with urllib.request.urlopen(req, timeout=300) as r:
            body = json.loads(r.read())
        self.assertTrue(body['ok'], body.get('output', '')[-3000:])
        with urllib.request.urlopen(origin + '/', timeout=30) as r:
            page = r.read().decode('utf-8')
        self.assertEqual(block(page, 'seed')['milestoneHead'], '9.9.9')
        self.assertIn(OUTSIDE, block(page, 'documents')['files'], 'the refresh bundled the new card document')
        proc.terminate()
        proc.wait(10)
        hermetic.assert_live_unchanged(self)


if __name__ == '__main__':
    sys.exit(0 if unittest.main(exit=False, verbosity=2 if '-v' in sys.argv else 1).result.wasSuccessful() else 1)
