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

    def test_handoff_fields(self):
        # OPS-127: optional next/presence round-trip; invalid values are refused; older records stay readable.
        with tempfile.TemporaryDirectory() as folder, patch.object(activity, 'EVENTS', Path(folder)/'events.jsonl'):
            old = {'schemaVersion':1,'id':'a'*32,'taskId':'OPS-111','event':'work','owner':'Astra','timestamp':'2026-10-18T12:00:00Z','reason':'old','commitSha':''}
            activity.EVENTS.write_text(json.dumps(old)+'\n')
            done = activity.append_event('OPS-111','return','姫','返却',next_owner='Astra')
            wait = activity.append_event('OPS-111','work','姫','WAIT 待機開始',presence='waiting')
            end = activity.append_event('OPS-111','acceptance','Astra','受入',next_owner='none')
            rows = activity.read_events()
            self.assertNotIn('next', rows[0]); self.assertNotIn('presence', rows[0])
            self.assertEqual(rows[1]['next'],'Astra'); self.assertEqual(rows[2]['presence'],'waiting'); self.assertEqual(rows[3]['next'],'none')
            self.assertEqual([done['next'],wait['presence'],end['next']],['Astra','waiting','none'])
            before = activity.EVENTS.read_bytes()
            for changes in ({'presence':'asleep'},{'next_owner':'x'*81},{'next_owner':'bad\n'}):
                args=dict(task_id='OPS-111',kind='work',owner='姫');args.update(changes)
                with self.assertRaises(ValueError): activity.append_event(**args)
            self.assertEqual(activity.EVENTS.read_bytes(), before)
            # The read route passes the fields through unchanged.
            class Request:
                path='/activity-events'
                local_request=lambda self:True
                reply=lambda self,*args:args
            code, body = serve.Handler.do_GET(Request())
            sent = json.loads(body)
            self.assertEqual(code, 200); self.assertEqual(sent[1]['next'],'Astra'); self.assertEqual(sent[2]['presence'],'waiting'); self.assertNotIn('next', sent[0])

    def test_return_reference(self):
        # OPS-129: --doc/--section/--next on a return; checked once at send time, stored as ref, never re-checked on read.
        doc = '# T\n\n## A 姫Return\n\n本文\n\n### 下位\n\n## Dup\n\nx\n\n## Dup\n\ny\n\n## Empty\n\n### Child\n\nz\n\n## Blank\n\n## Code\n\n```\n## Fenced\n```\n\n## C#\n\nc\n'
        with tempfile.TemporaryDirectory() as folder:
            root = Path(folder)/'repo'; (root/'docs').mkdir(parents=True); (root/'docs'/'r.md').write_text(doc)
            outside = Path(folder)/'outside.md'; outside.write_text('## A 姫Return\n\nx\n'); (root/'docs'/'link.md').symlink_to(outside)
            events = Path(folder)/'events.jsonl'
            def cli(*args, cwd=folder):
                script = 'import sys,activity;from pathlib import Path;activity.ROOT=Path(sys.argv[1]);activity.EVENTS=Path(sys.argv[2]);sys.argv=["activity.py"]+sys.argv[3:];activity.main()'
                return subprocess.run([sys.executable,'-B','-c',script,str(root),str(events),*args],cwd=cwd,capture_output=True,text=True,env={'PYTHONPATH':str(Path(__file__).resolve().parent)})
            base = ['--task','OPS-129','--event','return','--owner','姫']
            # normal, from a different cwd: the path is repo-root relative
            ok = cli(*base,'--doc','docs/r.md','--section','A 姫Return','--next','Astra',cwd=str(root/'docs'))
            self.assertEqual(ok.returncode,0,ok.stderr)
            self.assertEqual(json.loads(ok.stdout)['ref'],{'path':'docs/r.md','section':'A 姫Return'})
            before = events.read_bytes()
            for args, message in (
                (['--doc','docs/r.md','--next','Astra'],'required together'),
                (['--section','A 姫Return','--next','Astra'],'required together'),
                (['--doc','docs/r.md','--section','A 姫Return'],'required together'),
                (['--doc','docs/r.md','--section','A','--next','Astra'],'not found'),
                (['--doc','docs/r.md','--section','Dup','--next','Astra'],'not unique'),
                (['--doc','docs/r.md','--section','Blank','--next','Astra'],'empty'),
                (['--doc','docs/r.md','--section','Fenced','--next','Astra'],'not found'),
                (['--doc','../outside.md','--section','A 姫Return','--next','Astra'],'outside'),
                (['--doc','docs/link.md','--section','A 姫Return','--next','Astra'],'outside'),
                (['--doc',str(root/'docs'/'r.md'),'--section','A 姫Return','--next','Astra'],'relative'),
                (['--doc','docs/none.md','--section','A 姫Return','--next','Astra'],'not found')):
                run = cli(*base,*args)
                self.assertNotEqual(run.returncode,0,args); self.assertIn(message,run.stderr,args); self.assertEqual(run.stdout,'')
            work = cli('--task','OPS-129','--event','work','--owner','姫','--doc','docs/r.md','--section','A 姫Return','--next','Astra')
            self.assertIn('return only',work.stderr)
            self.assertIn('Headings: ',cli(*base,'--doc','docs/r.md','--section','A','--next','Astra').stderr,'candidates are listed')
            self.assertEqual(events.read_bytes(),before,'nothing is written on any rejection')
            # a section with only a subsection is not empty; a closing # in the text is kept
            with patch.object(activity,'ROOT',root):
                self.assertEqual(activity.check_ref('docs/r.md','Empty')['section'],'Empty')
                self.assertEqual(activity.check_ref('docs/r.md','C#')['section'],'C#')
            # a fence closes only on the same character, at least as long, with nothing but spaces after it
            (root/'docs'/'f.md').write_text('# F\n\n````\n```\n## Fake1\n```\n````\n\n~~~\n```\n## Fake2\n~~~ text\n## Fake3\n~~~~  \n\n## Real\n\nr\n')
            with patch.object(activity,'ROOT',root):
                for fake in ('Fake1','Fake2','Fake3'):
                    with self.assertRaisesRegex(ValueError,'not found'): activity.check_ref('docs/f.md',fake)
                self.assertEqual(activity.check_ref('docs/f.md','Real')['section'],'Real')
            # write failure: no success output, no event
            events.write_bytes(before+b'{')
            fail = cli(*base,'--doc','docs/r.md','--section','A 姫Return','--next','Astra')
            self.assertNotEqual(fail.returncode,0); self.assertEqual(fail.stdout,''); self.assertEqual(events.read_bytes(),before+b'{')
            events.write_bytes(before)
            # history is not re-checked: the document changes, the stored ref is still readable, old records stay valid
            (root/'docs'/'r.md').write_text('# gone\n')
            old = {'schemaVersion':1,'id':'b'*32,'taskId':'OPS-111','event':'return','owner':'Astra','timestamp':'2026-10-18T12:00:00Z'}
            with events.open('a') as stream: stream.write(json.dumps(old)+'\n')
            with patch.object(activity,'EVENTS',events):
                rows = activity.read_events()
                self.assertEqual(rows[0]['ref']['section'],'A 姫Return'); self.assertNotIn('ref',rows[1])
                for bad in ('x',{'path':'a'},{'path':'a','section':'b\n'}):
                    with self.assertRaises(ValueError): activity.validate_event({**old,'ref':bad})
                class Request:
                    path='/activity-events'
                    local_request=lambda self:True
                    reply=lambda self,*args:args
                code, body = serve.Handler.do_GET(Request())
                self.assertEqual(code,200); self.assertEqual(json.loads(body)[0]['ref'],{'path':'docs/r.md','section':'A 姫Return'})

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
