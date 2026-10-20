"""Team notices: temporary database and isolated HTTP only; no real messages."""
import concurrent.futures
import json
import os
from pathlib import Path
import subprocess
import tempfile
import threading
import time
import unittest
import urllib.error
import urllib.parse
import urllib.request
import uuid
from unittest.mock import patch

import member_state
import serve
from task_rounds import TaskRoundStore


class TeamNoticesTest(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.store = TaskRoundStore(Path(self.tmp.name) / 'db')
        self.members = member_state.MemberState([], ['Astra', 'そる', 'ユーザー'])
        self.members.attend('そる'); self.members.attend('Other')
        self.store.set_senders(['Astra', 'そる'], 'fixture')
        anchor = self.store.send(uuid.uuid4().hex, 'Astra', 'そる', 'OPS-197', 'anchor', ref_doc='Maintanance/Current/THREAD_ROUND_FIXTURE.md', ref_section='依頼')['id']
        self.round = self.store.act({'action':'create', 'actor':'Astra', 'operationId':uuid.uuid4().hex, 'letter':anchor, 'members':['Astra', 'そる']})['id']
        for target in ('serve.studio_store.Store', 'serve.task_rounds.TaskRoundStore'):
            patched = patch(target, return_value=self.store); patched.start(); self.addCleanup(patched.stop)
        patched = patch.object(member_state, 'members', self.members); patched.start(); self.addCleanup(patched.stop)
        class Quiet(serve.Handler):
            def log_message(self, *args):pass
        self.server = serve.ThreadingHTTPServer(('127.0.0.1', 0), Quiet)
        self.url = 'http://127.0.0.1:' + str(self.server.server_port)
        threading.Thread(target=self.server.serve_forever, daemon=True).start()
        self.addCleanup(self.server.server_close); self.addCleanup(self.server.shutdown)

    def post(self, path, body):
        req = urllib.request.Request(self.url+path, data=json.dumps(body).encode(), headers={'Origin':self.url,'X-Registry-Studio':path[1:],'Content-Type':'application/json'})
        with urllib.request.urlopen(req, timeout=4) as response:return json.load(response)

    def notice(self, kind='pause', reason='test', operation=None):
        return self.post('/team-notice', {'operationId':operation or uuid.uuid4().hex, 'kind':kind, 'reason':reason})

    def watch(self, wait=0, inbox=None):
        q={'round':self.round,'after':self.store.show_round(self.round)['context'],'owner':'そる','wait':wait}
        if inbox is not None:q['inboxAfter']=inbox
        with urllib.request.urlopen(self.url+'/letter-turns?'+urllib.parse.urlencode(q), timeout=wait+3) as response:return json.load(response)

    def test_four_kinds_fixed_roster_replay_atomicity_and_ack(self):
        membership = self.members.snapshot()
        letters_before = self.store.inbox('そる')['letters']
        notices = [self.notice(kind, '理由 <safe>') for kind in ('thanks','pause','cancel','return')]
        self.assertEqual([n['label'] for n in notices], ['おつかれさま','一時中断','中止','差し戻し'])
        self.assertTrue(all(n['targets']==['Astra','そる','Other'] and n['sentCount']==3 for n in notices))
        self.assertEqual(self.members.snapshot(), membership)
        self.assertEqual(self.store.inbox('そる')['letters'], letters_before)
        self.assertEqual(len(self.store.inbox('そる')['notifications']), 4)
        self.members.replace_planned(['Later']); self.members.clear()
        replay = self.notice('thanks', '理由 <safe>', notices[0]['operationId'])
        self.assertTrue(replay['replayed']); self.assertEqual(replay['targets'], notices[0]['targets'])
        self.assertEqual(self.store.notifications('Later'), [])
        with self.assertRaises(urllib.error.HTTPError) as error:self.notice('thanks','changed',notices[0]['operationId'])
        self.assertEqual(error.exception.code,409); error.exception.close()
        self.members.clear_planned()
        with self.assertRaises(urllib.error.HTTPError) as error:self.notice()
        self.assertEqual(error.exception.code,400); error.exception.close()
        with self.store.transaction() as con:
            self.assertEqual(con.execute("SELECT COUNT(*) FROM messages WHERE kind='team-notice'").fetchone()[0],12)
            self.assertEqual(con.execute('SELECT COUNT(*) FROM letters').fetchone()[0],1)
        notification = self.store.notifications('そる')[0]
        self.assertEqual(self.post('/comm-ack', {'messageId':notification['id'],'owner':'そる','recordedBy':'Astra'})['ack'],'proxy')
        self.assertEqual(len(self.store.notifications('そる')),4)
        self.assertEqual(self.post('/comm-ack', {'messageId':notification['id'],'owner':'そる'})['ack'],'answer')
        self.assertEqual(len(self.store.notifications('そる')),3)

    def test_watch_wakes_for_new_or_existing_unreceived_and_cli_reads_body(self):
        baseline = self.store.inbox_notice_context('そる')
        with concurrent.futures.ThreadPoolExecutor() as pool:
            waiting = pool.submit(self.watch,2,baseline)
            time.sleep(.15)
            sent = self.notice('return','ここを再確認')
            result = waiting.result(timeout=3)
        self.assertTrue(result['ownerInboxChanged']); self.assertTrue(result['notificationPending'])
        self.assertIn('team-notice',result['wakeReasons'])
        self.assertEqual(result['notifications'][0]['reason'],'ここを再確認')
        existing = self.watch()
        self.assertTrue(existing['notificationPending'], 'initial baseline does not hide unread notices')
        command=['python3','-B',str(Path(__file__).with_name('comm.py'))]
        env=dict(os.environ,REGISTRY_STUDIO_URL=self.url)
        inbox=subprocess.run(command+['letter','inbox','--owner','そる'],env=env,capture_output=True,text=True)
        self.assertEqual(inbox.returncode,0,inbox.stderr)
        notice=json.loads(inbox.stdout)['notifications'][0]
        self.assertEqual(notice['noticeKind'],'return'); self.assertIn('受入不可',notice['body'])
        state=str(Path(self.tmp.name)/'watch.json')
        watched=subprocess.run(command+['letter','watch','--owner','そる','--state-file',state],env=env,capture_output=True,text=True)
        self.assertEqual(watched.returncode,0,watched.stderr)
        self.assertTrue(any(c.get('kind')=='team-notice' for c in json.loads(watched.stdout)['changes']))
        ack=subprocess.run(command+['ack',notice['id'],'--owner','そる'],env=env,capture_output=True,text=True)
        self.assertEqual(ack.returncode,0,ack.stderr)
        self.assertEqual(json.loads(ack.stdout)['ack'],'answer')
        self.assertFalse(self.watch()['notificationPending'])


if __name__=='__main__':unittest.main()
