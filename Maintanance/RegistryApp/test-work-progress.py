#!/usr/bin/env python3
"""OPS-110: bounded advisory file and fixed, read-only routing; no running server needed."""
import json
from pathlib import Path
import sys
import tempfile
import unittest
from unittest.mock import patch
sys.dont_write_bytecode = True
import serve

RECORD = dict(schemaVersion=1, taskId='OPS-110', title='<script>title</script>', owner='Sol',
              stage='work', updatedAt='2026-10-18T12:34:56+09:00')

class ProgressTests(unittest.TestCase):
    def test_record_and_refusals(self):
        with tempfile.TemporaryDirectory() as folder, patch.object(serve, 'WORK_PROGRESS', Path(folder) / 'work-progress.json'):
            path = serve.WORK_PROGRESS
            self.assertIsNone(serve.read_work_progress())
            path.write_text(json.dumps(dict(RECORD, extra='not exposed')))
            data = serve.read_work_progress()
            self.assertEqual(data['title'], RECORD['title'])
            self.assertNotIn('extra', data)
            for change in ({'stage':'ACTIVE'}, {'taskId':'../OPS-110'}, {'title':'x'*161},
                           {'owner':'bad\nline'}, {'updatedAt':'2026-02-30T12:00:00Z'},
                           {'updatedAt':'2026-10-18T12:00:00'}, {'waitingReason':False}, {'schemaVersion':True}):
                path.write_text(json.dumps(dict(RECORD, **change)))
                with self.assertRaises(ValueError, msg=str(change)): serve.read_work_progress()
            for raw in (b'{', b'\xff', b' '* (serve.MAX_PROGRESS_BYTES+1)):
                path.write_bytes(raw)
                with self.assertRaises((ValueError, UnicodeDecodeError)): serve.read_work_progress()

    def test_fixed_route(self):
        class Request:
            path = '/work-progress'
            local_request = lambda self: True
            reply = lambda self, *args: args
        request = Request()
        with patch.object(serve, 'read_work_progress', return_value=None) as read:
            self.assertEqual(serve.Handler.do_GET(request)[:2], (200, b'null'))
            read.assert_called_once_with()
            for path in ('/work-progress?path=/etc/passwd', '/work-progress/../registry.json'):
                request.path = path
                self.assertEqual(serve.Handler.do_GET(request)[0], 404)
            self.assertEqual(read.call_count, 1)
        request.path = '/work-progress'
        with patch.object(serve, 'read_work_progress', side_effect=ValueError('private detail')):
            self.assertEqual(serve.Handler.do_GET(request), (503, {'error':'Progress record unavailable'}))
        request.local_request = lambda: False
        self.assertEqual(serve.Handler.do_GET(request)[0], 403)

if __name__ == '__main__': unittest.main()
