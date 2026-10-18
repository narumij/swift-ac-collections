#!/usr/bin/env python3
"""Limited activity validation, durable append, bounded history and read-only routes."""
import json
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch
sys.dont_write_bytecode = True
import activity
import serve

class ActivityTests(unittest.TestCase):
    def test_append_repeated_events_tail_and_validation(self):
        with tempfile.TemporaryDirectory() as folder, patch.object(activity, 'EVENTS', Path(folder)/'events.jsonl'):
            self.assertEqual(activity.read_events(), [])
            for index in range(205):
                activity.append_event('OPS-111', 'return' if index%2 else 'recheck', '<img src=x>', str(index))
            before = activity.EVENTS.read_bytes()
            rows = activity.read_events()
            self.assertEqual(len(rows), 200)
            self.assertEqual([r['reason'] for r in rows], list(map(str, range(5,205))))
            self.assertEqual(len({r['id'] for r in rows}), 200)
            for changes in ({'task_id':'../OPS-111'}, {'kind':'success'}, {'owner':'bad\n'}, {'reason':'x'*241}, {'commit_sha':'123'}, {'at':'2026-02-30T12:00:00Z'}, {'at':'2026-10-18T12:00:00'}):
                args=dict(task_id='OPS-111',kind='work',owner='Sol');args.update(changes)
                with self.assertRaises(ValueError): activity.append_event(**args)
            self.assertEqual(activity.EVENTS.read_bytes(), before)
            activity.EVENTS.write_bytes(before+b'{')
            with self.assertRaises(ValueError): activity.append_event('OPS-111','work','Sol')
            self.assertEqual(activity.EVENTS.read_bytes(), before+b'{')
            with self.assertRaises(ValueError): activity.read_events()

    def test_concurrent_appends(self):
        with tempfile.TemporaryDirectory() as folder:
            path=Path(folder)/'events.jsonl'
            script="import activity; from pathlib import Path; activity.EVENTS=Path(__import__('sys').argv[1]); activity.append_event('OPS-111','work','test')"
            processes=[subprocess.Popen([sys.executable,'-B','-c',script,str(path)],cwd=serve.APP) for _ in range(8)]
            self.assertTrue(all(p.wait(timeout=10)==0 for p in processes))
            rows=[json.loads(line) for line in path.read_text().splitlines()]
            self.assertEqual(len(rows),8);self.assertEqual(len({r['id'] for r in rows}),8)

    def test_fixed_routes_and_git(self):
        class Request:
            path='/activity-events'
            local_request=lambda self:True
            reply=lambda self,*args:args
        request=Request()
        with patch.object(activity,'read_events',return_value=[]) as read:
            self.assertEqual(serve.Handler.do_GET(request),(200,b'[]'))
            for path in ('/activity-events?path=/etc/passwd','/activity-events/../registry.json','/activity-commits?ref=other'):
                request.path=path;self.assertEqual(serve.Handler.do_GET(request)[0],404)
            self.assertEqual(read.call_count,1)
        request.path='/activity-events'
        with patch.object(activity,'read_events',side_effect=ValueError('private')):
            self.assertEqual(serve.Handler.do_GET(request),(503,{'error':'Activity row unavailable'}))
        request.path='/activity-commits'
        with patch.object(serve,'read_activity_commits',side_effect=subprocess.TimeoutExpired('git',3)):
            self.assertEqual(serve.Handler.do_GET(request)[0],503)
        request.server=type('Server',(),{'server_port':8088})();request.headers={}
        self.assertEqual(serve.Handler.do_POST(request)[0],404)
        request.local_request=lambda:False
        self.assertEqual(serve.Handler.do_GET(request)[0],403)
        output=b'a'*40+b'\x1f2026-10-18T12:00:00Z\x1fnew\0'+b'b'*40+b'\x1f2026-10-17T12:00:00Z\x1fold\0'
        with patch.object(serve.subprocess,'run',return_value=subprocess.CompletedProcess([],0,output,b'')) as run:
            self.assertEqual([r['subject'] for r in serve.read_activity_commits()],['old','new'])
            args,kwargs=run.call_args
            self.assertEqual(args[0],['git','log','-30','--format=%H%x1f%cI%x1f%s','-z','HEAD','--'])
            self.assertEqual(kwargs['timeout'],3);self.assertEqual(kwargs['cwd'],serve.ROOT)
        self.assertIn('activity.py',serve.runtime_fingerprints())

if __name__=='__main__':unittest.main()
