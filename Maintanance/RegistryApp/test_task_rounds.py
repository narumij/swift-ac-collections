import unittest,tempfile,uuid
from pathlib import Path
from task_rounds import TaskRoundStore
import approvals

class Tests(unittest.TestCase):
 def setUp(self):
  self.tmp=tempfile.TemporaryDirectory();self.s=TaskRoundStore(Path(self.tmp.name)/'db')
  self.s.set_senders(['Astra','User'],'User')
  self.anchor=self.s.send(uuid.uuid4().hex,'Astra','Luna','OPS-197','Please check task turns',ref_doc='Maintanance/Current/THREAD_ROUND_FIXTURE.md',ref_section='依頼')['id']
  self.r=self.s.act(dict(action='create',actor='Astra',operationId=uuid.uuid4().hex,letter=self.anchor,members=['Astra','Luna']))['id']
 def tearDown(self):self.tmp.cleanup()
 def test_round_module_is_in_runtime_restart_fingerprints(self):
  import hashlib,serve
  self.assertEqual(serve.runtime_fingerprints()['task_rounds.py'],hashlib.sha256((Path(__file__).parent/'task_rounds.py').read_bytes()).hexdigest())
 def speak(self,actor='Astra',action='speak'):
  s=self.s.show_round(self.r)
  return dict(action=action,actor=actor,operationId=uuid.uuid4().hex,round=self.r,turn=s['turn'],context=s['context'],**({'body':'checked'} if action=='speak' else {}))
 def test_inherits_task_document_thread_without_return(self):
  out=self.s.act(self.speak());lid=out['letterId'];letter=self.s.letter(lid)
  self.assertEqual(letter['taskId'],'OPS-197');self.assertEqual(letter['follows'],self.anchor)
  self.assertEqual(letter['request']['ref_doc'],'Maintanance/Current/THREAD_ROUND_FIXTURE.md')
  self.assertTrue(letter['docRecords']);self.assertEqual(self.s.letter(self.anchor)['state'],'sent')
  self.assertEqual(self.s.rounds_for_letter(lid)[0]['id'],self.r)
  self.assertEqual(len(self.s.thread(lid)['letters']),2)
  self.assertIn(lid,[x['id'] for x in self.s.task_letters('OPS-197',[])['letters']])
 def test_discussion_is_visible_but_not_a_work_request(self):
  lid=self.s.act(self.speak())['letterId']
  self.assertEqual(self.s.letter(lid)['kind'],'discussion')
  self.assertNotIn(lid,[x['id'] for x in self.s.inbox('Luna')['letters']])
  self.assertIn(lid,[x['id'] for x in self.s.task_letters('OPS-197',[])['letters']])
  with self.assertRaises(approvals.Conflict):self.s.event(uuid.uuid4().hex,lid,'received','Luna',revision=1)
 def test_formal_return_and_stop_block_round(self):
  self.s.event(uuid.uuid4().hex,self.anchor,'received','Luna',revision=1)
  self.s.event(uuid.uuid4().hex,self.anchor,'started','Luna')
  self.s.act(self.speak());self.s.act(self.speak('Luna'))
  self.s.event(uuid.uuid4().hex,self.anchor,'returned','Luna',body='Done')
  self.assertTrue(self.s.show_round(self.r)['blocked'])
  with self.assertRaises(approvals.Conflict):self.s.act(self.speak())
 def test_withdraw_blocks_without_inventing_receipt(self):
  self.s.event(uuid.uuid4().hex,self.anchor,'withdrawn','Astra',note='stop')
  with self.assertRaises(approvals.Conflict):self.s.act(self.speak())
  self.assertIsNone(self.s.letter(self.anchor)['receivedAt'])
 def test_revision_requires_reread(self):
  old=self.speak()
  self.s.revise(uuid.uuid4().hex,self.anchor,'request','Astra','Updated request','correction',ref_doc='Maintanance/Current/THREAD_ROUND_FIXTURE.md',ref_section='依頼')
  with self.assertRaises(approvals.Conflict):self.s.act(old)
  self.s.act(self.speak())
 def test_worker_cannot_start_unrelated_round(self):
  other=self.s.send(uuid.uuid4().hex,'Astra','Luna','OPS-197','other',ref_doc='Maintanance/Current/THREAD_ROUND_FIXTURE.md',ref_section='依頼')['id']
  with self.assertRaises(approvals.Conflict):self.s.act(dict(action='create',actor='Luna',operationId=uuid.uuid4().hex,letter=other,members=['Luna','Astra']))
 def test_replay_and_rollback(self):
  q=self.speak();a=self.s.act(q);self.assertEqual(self.s.act(q),a|{'replayed':True})
  with self.s.transaction() as c:c.execute("CREATE TRIGGER fail BEFORE INSERT ON trial_turns BEGIN SELECT RAISE(ABORT,'test'); END")
  with self.assertRaises(Exception):self.s.act(self.speak('Luna'))
  self.assertEqual(len(self.s.thread(self.anchor)['letters']),2)
 def test_http_cli_round_discovery_and_inbox(self):
  import threading,os,subprocess,json,urllib.request,urllib.error
  from unittest.mock import patch
  from http.server import ThreadingHTTPServer
  import serve,task_rounds,studio_store
  server=ThreadingHTTPServer(('127.0.0.1',0),serve.Handler)
  t=threading.Thread(target=server.serve_forever,daemon=True);t.start()
  env=dict(os.environ,REGISTRY_STUDIO_URL='http://127.0.0.1:'+str(server.server_port))
  def cli(*args):
   p=subprocess.run(['python3','-B',str(Path(__file__).with_name('comm.py')),*args],env=env,capture_output=True,text=True)
   self.assertEqual(p.returncode,0,p.stderr);return json.loads(p.stdout)
  try:
   with patch.object(task_rounds,'TaskRoundStore',return_value=self.s),patch.object(studio_store,'Store',return_value=self.s):
    out=self.s.act(self.speak());lid=out['letterId']
    self.assertEqual(cli('letter','turns','for-letter',lid)[0]['id'],self.r)
    self.assertNotIn(lid,[x['id'] for x in cli('letter','inbox','--owner','Luna')['letters']])
    self.assertEqual(cli('letter','turns','show',self.r)['turn'],1)
    self.s.set_senders(['Astra','LunaC','User'],'User')
    anchor=self.s.send(uuid.uuid4().hex,'LunaC','姫','OPS-197','LunaC coordination check',ref_doc='Maintanance/Current/THREAD_ROUND_FIXTURE.md',ref_section='依頼')['id']
    round_id=self.s.act(dict(action='create',actor='LunaC',operationId=uuid.uuid4().hex,letter=anchor,members=['Luna','LunaC','姫']))['id']
    added=cli('letter','turns','add-member',round_id,'--actor','LunaC','--turn','0','--member','LunaR','--operation-id',uuid.uuid4().hex)
    self.assertEqual(added['speaker'],'Luna')
    self.assertEqual(added['members'],['Luna','LunaC','姫','LunaR'])
    with self.assertRaises(approvals.Conflict):
     self.s.act(dict(action='add-member',actor='Luna',operationId=uuid.uuid4().hex,round=round_id,turn=0,member='Other'))
    self.assertEqual(self.s.show_round(round_id)['speaker'],'Luna')
    req=urllib.request.Request(env['REGISTRY_STUDIO_URL']+'/letter-turns',data=b'[]',headers={
     'Content-Type':'application/json','Origin':env['REGISTRY_STUDIO_URL'],'X-Registry-Studio':'letter-turns'})
    with self.assertRaises(urllib.error.HTTPError) as error:urllib.request.urlopen(req)
    self.assertEqual(error.exception.code,400)
    self.assertEqual(json.loads(error.exception.read()),{'error':'Invalid JSON body'})
    error.exception.close()
    with patch.dict(os.environ,{'ROUND_USER_APPROVAL_TOKEN':''}):
     for action in ('approve-skip','continuous-skip'):
      body={'action':action,'actor':'User','operationId':uuid.uuid4().hex}
      req=urllib.request.Request(env['REGISTRY_STUDIO_URL']+'/letter-turns',data=json.dumps(body).encode(),headers={
       'Content-Type':'application/json','Origin':env['REGISTRY_STUDIO_URL'],'X-Registry-Studio':'letter-turns'})
      with self.assertRaises(urllib.error.HTTPError) as error:urllib.request.urlopen(req)
      self.assertEqual(error.exception.code,403)
      self.assertEqual(json.loads(error.exception.read()),{'error':'User approval channel required'})
      error.exception.close()
  finally:server.shutdown();server.server_close();t.join()
 def test_user_skip_stale_target_and_continuous(self):
  x=self.s.show_round(self.r)
  q=dict(action='continuous-skip',actor='User',operationId=uuid.uuid4().hex,round=self.r,context=x['context'],target='Luna',enabled=True,reason='fixture only')
  self.s.act(q);self.s.act(self.speak());x=self.s.show_round(self.r)
  self.assertEqual(x['turn'],2);self.assertEqual(x['speaker'],'Astra')
  self.assertEqual(x['history'][-1]['approval'],q['operationId'])
  self.s.act(q|{'operationId':uuid.uuid4().hex,'enabled':False,'context':x['context']})
  x=self.s.show_round(self.r)
  a=self.s.act(dict(action='approve-skip',actor='User',operationId=uuid.uuid4().hex,round=self.r,turn=x['turn'],target=x['speaker'],reason='fixture'))
  self.s.act(self.speak())
  with self.assertRaises(approvals.Conflict):self.s.act(dict(action='skip',actor='Astra',operationId=uuid.uuid4().hex,round=self.r,turn=3,reason='fixture',approval=a['approval']))
 def test_concurrent_speech_only_one_and_restart(self):
  import concurrent.futures
  q=self.speak()
  def run(_):
   try:self.s.act(q|{'operationId':uuid.uuid4().hex});return 1
   except approvals.Conflict:return 0
  with concurrent.futures.ThreadPoolExecutor(2) as ex:self.assertEqual(sum(ex.map(run,range(2))),1)
  self.s=TaskRoundStore(Path(self.tmp.name)/'db');self.assertEqual(self.s.show_round(self.r)['turn'],1)
 def test_context_changes_when_normal_thread_is_revised(self):
  self.s.act(self.speak());q=self.speak('Luna')
  first=self.s.show_round(self.r)['history'][0]['letter_id']
  self.s.revise(uuid.uuid4().hex,first,'request','Astra','Correction','typo',ref_doc='Maintanance/Current/THREAD_ROUND_FIXTURE.md',ref_section='依頼')
  with self.assertRaises(approvals.Conflict):self.s.act(q)
if __name__=='__main__':unittest.main()
