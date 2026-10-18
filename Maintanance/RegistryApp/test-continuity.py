#!/usr/bin/env python3
"""OPS-139: one-shot continuity marks (CLI and record) and the fixed read route. Temporary folders only."""
import json
from pathlib import Path
import subprocess
import sys
import tempfile
import threading
import unittest
from unittest.mock import patch

import continuity
import serve


class ContinuityTests(unittest.TestCase):
    def setUp(self):
        folder = tempfile.TemporaryDirectory()
        self.addCleanup(folder.cleanup)
        self.record = Path(folder.name) / 'continuity.json'
        patcher = patch.object(continuity, 'RECORD', self.record)
        patcher.start(); self.addCleanup(patcher.stop)

    def test_marks_round_trip_and_keep_other_owners(self):
        self.assertEqual(continuity.read(), {'schemaVersion': 1, 'owners': {}}, 'absent file = nobody yet')
        continuity.mark('Astra', 'alive', '2026-10-19T01:00:00Z')
        continuity.mark('姫', 'ended', '2026-10-19T01:00:05+09:00')
        continuity.mark('Astra', 'alive', '2026-10-19T01:00:30Z')
        self.assertEqual(continuity.read()['owners'], {'Astra': {'state': 'alive', 'at': '2026-10-19T01:00:30Z'}, '姫': {'state': 'ended', 'at': '2026-10-19T01:00:05+09:00'}})
        self.assertEqual([p.name for p in self.record.parent.iterdir() if p.name.startswith('.continuity-')], [], 'no temp files left')

    def test_rejections_write_nothing(self):
        continuity.mark('Astra', 'alive', '2026-10-19T01:00:00Z')
        before = self.record.read_bytes()
        for owner, state, at in (('Astra', 'waiting', None), ('', 'alive', None), ('a\n', 'alive', None), ('x' * 81, 'alive', None),
                                 ('Astra', 'alive', '2026-10-19T01:00Z'), ('Astra', 'alive', '2026-10-19T01:00:00'), ('Astra', 'alive', 'yesterday')):
            with self.assertRaises(ValueError, msg=(owner, state, at)):
                continuity.mark(owner, state, at)
        self.assertEqual(self.record.read_bytes(), before)
        for i in range(continuity.MAX_OWNERS - 1):
            continuity.mark(f'O{i}', 'alive')
        with self.assertRaises(ValueError):
            continuity.mark('one too many', 'alive')

    def test_bad_record_is_refused(self):
        for raw in (b'{', b'\xff', b'[]', b'{"schemaVersion":2,"owners":{}}', b'{"schemaVersion":1,"owners":{"A":{"state":"alive"}}}',
                    b' ' * (continuity.MAX_BYTES + 1)):
            self.record.write_bytes(raw)
            with self.assertRaises((ValueError, UnicodeDecodeError)):
                continuity.read()

    def test_concurrent_marks(self):
        threads = [threading.Thread(target=continuity.mark, args=(f'O{i}', 'alive')) for i in range(8)]
        for t in threads: t.start()
        for t in threads: t.join()
        self.assertEqual(sorted(continuity.read()['owners']), sorted(f'O{i}' for i in range(8)))

    def test_cli(self):
        script = 'import sys,continuity;from pathlib import Path;continuity.RECORD=Path(sys.argv[1]);sys.argv=["continuity.py"]+sys.argv[2:];continuity.main()'
        run = lambda *a: subprocess.run([sys.executable, '-B', '-c', script, str(self.record), *a], cwd=str(Path(__file__).resolve().parent), capture_output=True, text=True)
        ok = run('--owner', 'Astra', '--state', 'alive', '--at', '2026-10-19T01:00:00Z')
        self.assertEqual(ok.returncode, 0, ok.stderr); self.assertEqual(json.loads(ok.stdout), {'Astra': {'state': 'alive', 'at': '2026-10-19T01:00:00Z'}})
        bad = run('--owner', 'Astra', '--state', 'alive', '--at', 'now')
        self.assertNotEqual(bad.returncode, 0); self.assertEqual(bad.stdout, ''); self.assertIn('Continuity not written', bad.stderr)

    def test_read_route(self):
        class Request:
            path = '/continuity'
            local_request = lambda self: True
            reply = lambda self, *args: args
        continuity.mark('Astra', 'alive', '2026-10-19T01:00:00Z')
        code, body = serve.Handler.do_GET(Request())
        sent = json.loads(body)
        self.assertEqual(code, 200); self.assertEqual(sent['owners'], {'Astra': {'state': 'alive', 'at': '2026-10-19T01:00:00Z'}})
        self.assertRegex(sent['serverNow'], r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z$')
        self.record.write_bytes(b'{')
        self.assertEqual(serve.Handler.do_GET(Request()), (503, {'error': 'Continuity unavailable'}))
        request = Request(); request.path = '/continuity?owner=x'
        self.assertEqual(serve.Handler.do_GET(request)[0], 404)
        self.assertIn('continuity.py', serve.runtime_fingerprints())


if __name__ == '__main__':
    unittest.main()
