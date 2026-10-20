#!/usr/bin/env python3
"""OPS-187: the letters round trip through the real Studio server and the real page in headless WebKit.

A real serve.py process on port 0 with disposable stores only: approvals/letters DB, Inbox, output/cache and tools
record in a temporary directory. It runs in the default (Markdown) mode: the letter routes, the page and its letter
poller are the same in both modes, and the V3 mode's startup needs every document the Registry names, one of which is
an untracked cache file (Maintanance/Cache/Astra/AI_GATE.md), so it cannot start from a clean checkout. A letter is sent through the real CLI (comm.py → HTTP),
the page's own poller must show it in the work-page letter list, and selecting it must show its exact text. Viewing must
record no receipt; an explicit receive by the recipient through the CLI must then appear on the page through the
page's own poll, with the send and receipt times of the server's own records. Nothing here writes a hand-made server
answer: the oracle is what the server stored (read back over HTTP), never a fixture.

Live paths without an override (Activity/, probe.sqlite3) are kept out by not letting the page request them
(blockPaths); the server is never asked for them. Port 8088 and the live stores are never used.

Run from the repository root: python3 -B Maintanance/RegistryApp/test-letters-e2e.py -v
Needs: node, the global Playwright with WebKit (/opt/homebrew/lib/node_modules/playwright), and node/marked for the
startup sync (found as sync.py finds them; a live local-tools.json is copied read-only into the temporary output).
"""
import json
import os
import re
import subprocess
import sys
import tempfile
import time
import unittest
import urllib.request
import uuid
from pathlib import Path

APP = Path(__file__).resolve().parent
ROOT = APP.parent.parent
BLOCK = ['/activity-events', '/activity-commits', '/continuity', '/approval-probe', '/work-progress']


class LettersRoundTrip(unittest.TestCase):
    def setUp(self):
        tmp = tempfile.TemporaryDirectory(prefix='ops187-')
        self.addCleanup(tmp.cleanup)
        self.d = d = Path(tmp.name)
        for name in ('out', 'inbox', 'driver'):
            (d / name).mkdir()
        self.env = dict(os.environ, REGISTRY_STUDIO_APPROVALS_DB=str(d / 'approvals.sqlite3'), REGISTRY_STUDIO_INBOX=str(d / 'inbox'),
                        REGISTRY_STUDIO_APP=str(d / 'out'), REGISTRY_STUDIO_TOOLS=str(d / 'out' / 'local-tools.json'))
        live_tools = APP / 'local-tools.json'
        if live_tools.exists():
            (d / 'out' / 'local-tools.json').write_bytes(live_tools.read_bytes())  # read-only copy so sync.py finds node/marked
        self.proc = subprocess.Popen([sys.executable, '-B', str(APP / 'serve.py'), '--port', '0', '--output', str(d / 'out')],
                                     cwd=ROOT, env=self.env, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
        self.addCleanup(self.proc.stdout.close)
        self.addCleanup(lambda: self.proc.poll() is None and (self.proc.terminate(), self.proc.wait(10)))
        lines = []
        for line in self.proc.stdout:
            lines.append(line)
            if line.startswith('Registry Studio: http://127.0.0.1:'):
                break
        self.assertIsNone(self.proc.poll(), ''.join(lines)[-3000:])
        port = int(re.search(r'127\.0\.0\.1:(\d+)/', lines[-1]).group(1))
        self.assertNotEqual(port, 8088)
        self.origin = f'http://127.0.0.1:{port}'
        self.env['REGISTRY_STUDIO_URL'] = self.origin

    def comm(self, *args, stdin=None):
        run = subprocess.run([sys.executable, '-B', str(APP / 'comm.py'), 'letter', *args], cwd=ROOT, env=self.env, input=stdin,
                             capture_output=True, text=True, timeout=60)
        self.assertEqual(run.returncode, 0, run.stdout + run.stderr)
        return json.loads(run.stdout)

    def get(self, path):
        with urllib.request.urlopen(self.origin + path, timeout=30) as r:
            return json.loads(r.read())

    def test_send_view_receive_round_trip(self):
        self.comm('senders', '--set', 'Astra', 'ユーザー', '--recorded-by', 'ユーザー')
        token = uuid.uuid4().hex
        body = f'# OPS-187 実接続 {token}\n\n- 改行と <b>記号</b> & "引用" をそのまま\r\n- 二行目\n'
        sent = self.comm('send', '--sender', 'Astra', '--recipient', '姫', '--task', 'OPS-187', '--body-file', '-', stdin=body)
        lid = sent['id']
        params = self.d / 'driver' / 'params.json'
        params.write_text(json.dumps({'letterId': lid, 'blockPaths': BLOCK, 'phaseTimeoutMs': 30000}), encoding='utf-8')
        driver = subprocess.Popen(['node', str(APP / 'letters_e2e.cjs'), self.origin, str(params), str(self.d / 'driver')],
                                  cwd=APP, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
        self.addCleanup(lambda: driver.poll() is None and (driver.kill(), driver.wait(10)))
        self.addCleanup(driver.stdout.close)
        phase1 = self.d / 'driver' / 'phase1.json'
        deadline = time.time() + 60
        while not phase1.exists() and driver.poll() is None and time.time() < deadline:
            time.sleep(0.1)
        if not phase1.exists():  # the message is read only on failure: reading the driver's output waits for it to end
            driver.wait(60)
            report = self.d / 'driver' / 'result.json'
            self.fail(report.read_text(encoding='utf-8') if report.exists() else driver.stdout.read())
        one = json.loads(phase1.read_text(encoding='utf-8'))['phase1']

        # the page shows the letter the server stored: sender, recipient, state, and its exact text
        self.assertIn('OPS-187 · Astra → 姫 · 未受領', one['row'])
        self.assertIn('受領日時 未受領', one['row'])
        self.assertEqual(one['selected'], 'true')
        self.assertEqual(one['pre'], [body], 'the exact original text, markup and line endings included')
        self.assertIn('OPS-187 · Astra → 姫 · 未受領', one['detail'])
        # the page asked the server for the brief list and the chosen letter, with GET only
        self.assertIn('GET /letters?brief=1&limit=50', one['requests'])
        self.assertIn('GET /letters/' + lid, one['requests'])
        # viewing is not a receipt: the server has only the send
        stored = self.get('/letters/' + lid)
        self.assertEqual((stored['state'], [e['event'] for e in stored['events']], stored['receivedAt']), ('sent', ['sent'], None))

        # an explicit receive by the recipient through the existing CLI
        received = self.comm('receive', lid, '--actor', '姫', '--revision', '1')
        stored = self.get('/letters/' + lid)
        self.assertEqual((stored['state'], received['receivedAt']), ('received', stored['receivedAt']))
        self.assertIsNotNone(stored['receivedAt'])
        (self.d / 'driver' / 'go.json').write_text(json.dumps({'sentAt': stored['sentAt'], 'receivedAt': stored['receivedAt']}), encoding='utf-8')
        driver.wait(90)
        result = json.loads((self.d / 'driver' / 'result.json').read_text(encoding='utf-8'))
        if os.environ.get('OPS187_EVIDENCE'):  # optional: keep the driver's record and the server's record as evidence
            Path(os.environ['OPS187_EVIDENCE'], 'roundtrip.json').write_text(json.dumps({'driver': result, 'server': stored}, ensure_ascii=False, indent=1), encoding='utf-8')
        self.assertTrue(result['ok'], result.get('error', '') + '\n' + str(result.get('last')))
        two, expect = result['phase2'], result['expect']
        # the page's own poll shows the receipt, with the times the server recorded
        self.assertIn('OPS-187 · Astra → 姫 · 受領', two['row'])
        self.assertIn('送信日時 ' + expect['sent'], one['row'], 'the send time is the server record of the send')
        self.assertIn('受領日時 ' + expect['received'], two['row'], 'the receipt time is the server record of her receive')
        self.assertIn('受領日時 ' + expect['received'], two['detail'])
        # nothing left the isolated origin; the page never wrote a letter; the live-store paths were never sent
        self.assertEqual(result['blocked'], [])
        self.assertFalse([r for r in result['requests'] if r.startswith('POST /letters')], 'the page never writes letters')
        self.assertFalse([r for r in result['requests'] if any(r.split(' ')[1].startswith(p) for p in BLOCK)])
        self.assertEqual(result['pageErrors'], [])


if __name__ == '__main__':
    unittest.main()
