#!/usr/bin/env python3
"""OPS-183: isolated WebKit coverage of letters in member status, read failure and recovery.
OPS-184 rollback regression: letters do not add recent-work cards.
All stores and the test server are temporary; live files are fingerprinted.
"""
import contextlib
import copy
import io
import json
import os
import shutil
import sqlite3
import subprocess
import sys
import tempfile
import threading
import unittest
import uuid
from pathlib import Path
from unittest.mock import patch

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE / 'v3'))
import hermetic  # noqa: E402  (first: temporary roots for every live path with an override)
import registry_v3_write as w3  # noqa: E402
import v3_studio_server as vs  # noqa: E402
import activity  # noqa: E402
import approvals  # noqa: E402
import comm  # noqa: E402
import continuity  # noqa: E402
import probe  # noqa: E402
import serve  # noqa: E402
import studio_store  # noqa: E402

PLAYWRIGHT = '/opt/homebrew/lib/node_modules/playwright'
RealStore = studio_store.Store  # serve.studio_store is this module: the patched name must not call itself


class Down:
    def __getattr__(self, name):
        raise sqlite3.OperationalError('letters down (test)')


def node():
    try:
        recorded = json.loads((HERE / 'local-tools.json').read_text(encoding='utf-8')).get('node')
    except (OSError, ValueError):
        recorded = None
    return recorded if recorded and Path(recorded).exists() else shutil.which('node')


@unittest.skipUnless(node() and Path(PLAYWRIGHT).exists(), 'node and the installed Playwright are needed')
class LettersLanesBrowser(unittest.TestCase):
    def setUp(self):
        tmp = tempfile.TemporaryDirectory(prefix='ops183-184-')
        self.addCleanup(tmp.cleanup)
        self.root = Path(tmp.name)
        out = self.root / 'out'
        out.mkdir()
        if os.environ.get('LETTERS_LANES_TEMPLATE'):  # only to show the test failing on an older page (the regression check)
            p = patch.object(vs, 'TEMPLATE', Path(os.environ['LETTERS_LANES_TEMPLATE']))
            p.start()
            self.addCleanup(p.stop)
        w3.create(str(self.root / 'registry.sqlite3'), copy.deepcopy(vs_base()))
        conn = w3.open_db(str(self.root / 'registry.sqlite3'))
        try:
            (out / 'index.html').write_text(vs.build_page(conn), encoding='utf-8')
            (out / 'registry.json').write_text(json.dumps(vs.sa.export_doc(conn), ensure_ascii=False), encoding='utf-8')  # the page's canonical check
        finally:
            conn.close()
        self.db = self.root / 'letters.sqlite3'
        self.fail_letters = False
        test = self

        def store(*a, **k):
            if test.fail_letters:
                return Down()  # every read fails as an unreadable database does: the server answers 503
            return RealStore(self.db, self.root)
        for target, name, value in ((serve, 'OUTPUT', out), (serve, 'V3', None), (activity, 'EVENTS', self.root / 'Activity' / 'events.jsonl'),
                                    (activity, 'ROOT', self.root), (continuity, 'RECORD', self.root / 'Activity' / 'continuity.json'),
                                    (serve.studio_store, 'Store', store),
                                    # the probe lane's own DB (no environment override): a temporary one; approvals.sqlite3 is hermetic's
                                    (serve, 'approval_store', lambda path: probe.Store(self.root / 'probe.sqlite3') if path == '/approval-probe' else approvals.Store())):
            p = patch.object(target, name, value)
            p.start()
            self.addCleanup(p.stop)

        class Quiet(serve.Handler):
            def log_message(self, *args):
                pass
        self.server = serve.ThreadingHTTPServer(('127.0.0.1', 0), Quiet)
        threading.Thread(target=self.server.serve_forever, daemon=True).start()
        self.addCleanup(self.server.server_close)
        self.addCleanup(self.server.shutdown)
        self.origin = f'http://127.0.0.1:{self.server.server_port}'
        e = patch.dict(os.environ, {'REGISTRY_STUDIO_URL': self.origin})
        e.start()
        self.addCleanup(e.stop)
        self.s = RealStore(self.db, self.root)
        self.s.set_senders(['Astra', 'ユーザー'], 'ユーザー')

    def cli(self, *args):
        out = io.StringIO()
        with contextlib.redirect_stdout(out), patch.object(sys, 'argv', ['comm.py', *args]):
            try:
                comm.main()
                code = 0
            except SystemExit as stop:
                code = stop.code or 0
        return code, out.getvalue()

    def letter(self, task, *events, reply=False):
        sent = self.s.send(uuid.uuid4().hex, 'Astra', '姫', task, '# 依頼\n\n試験の連絡。\n')
        for event in events:
            kw = {'revision': 1} if event == 'received' else {'body': '返答\n'} if event == 'returned' else {}
            actor = 'Astra' if event == 'closed' else '姫'
            self.s.event(uuid.uuid4().hex, sent['id'], event, actor, **kw)
        return sent['id']

    def test_letters_reach_members_without_work_cards(self):
        activity.append_event('OPS-900', 'work', '姫', '連続待機', presence='waiting')
        activity.append_event('OPS-900', 'work', 'Astra', '調整')
        open_id = self.letter('OPS-901', 'received', 'started')
        returned_id = self.letter('OPS-902', 'received', 'started', 'returned')  # returned, not closed
        self.letter('OPS-902', 'received', 'started', 'returned', 'closed')  # a newer exchange of the same task, closed
        run = subprocess.Popen([node(), str(HERE / 'letters-lanes-browser.cjs'), self.origin], stdin=subprocess.PIPE, stdout=subprocess.PIPE,
                               stderr=subprocess.PIPE, text=True, env=dict(os.environ, PLAYWRIGHT_MODULE=PLAYWRIGHT))
        def stop():
            if run.poll() is None:
                run.kill()
                run.wait()
            for stream in (run.stdin, run.stdout, run.stderr):
                stream.close()
        self.addCleanup(stop)
        steps = {}

        def wait(name):
            for line in run.stdout:
                kind, _, rest = line.rstrip('\n').partition(' ')
                if kind == 'STEP':
                    got, _, value = rest.partition(' ')
                    steps[got] = json.loads(value)
                    if got == name:
                        return steps[got]
                elif kind in ('DONE', 'ERROR'):
                    steps[kind] = json.loads(rest)
                    self.fail(f'browser ended before {name}: {line} {run.stderr.read()[-2000:]}')
            self.fail(f'browser closed before {name}: {run.stderr.read()[-2000:]}')

        def go():
            run.stdin.write('GO\n')
            run.stdin.flush()

        shown = wait('shown')
        hime = next(l for l in shown['lamps'] if l.startswith('姫'))
        astra = next(l for l in shown['lamps'] if l.startswith('Astra'))
        self.assertIn('待機中', hime, 'a letter never changes the declared state')
        self.assertIn('担当中 ' + open_id[:21], hime)
        self.assertIn('最後の連絡', hime)
        self.assertIn('確認待ち ' + returned_id[:21], astra, 'returned and unclosed: the sender is to confirm')
        self.assertFalse(any(c.startswith(('OPS-901', 'OPS-902')) for c in shown['cards']))
        self.fail_letters = True
        go()
        failure = wait('failure')
        self.assertIn('担当中 ' + open_id[:21], next(l for l in failure['lamps'] if l.startswith('姫')), 'the last good letters stay')
        self.fail_letters = False
        go()
        wait('recovered')
        go()
        rest = run.stdout.read()
        run.wait(timeout=60)
        done = [l for l in rest.splitlines() if l.startswith('DONE ')]
        self.assertTrue(done, rest + run.stderr.read()[-2000:])
        result = json.loads(done[0][5:])
        self.assertEqual((result['errors'], result['blocked']), ([], []))
        self.assertEqual(run.returncode, 0)
        hermetic.assert_live_unchanged(self)


def vs_base():
    return json.loads((HERE / 'v3' / 'fixtures' / 'base.json').read_text(encoding='utf-8'))


if __name__ == '__main__':
    unittest.main()
