const assert = require('node:assert/strict');
const { canonicalTaskChoices, TaskCanonicalViewModel } = require('./index.document.model.js');
const { CanonicalDocumentViewModel } = require('./index.task.document.js');
const first = {id:'OPS-208',item:'[EXECUTION] 正本タブ',detail:'`a.md` `b.md` `missing.md`'};
const second = {id:'OPS-207',item:'通知TL'};
assert.deepEqual(canonicalTaskChoices({tasks:[first,second]}).map(t=>t.id),['OPS-207','OPS-208']);
assert.equal(canonicalTaskChoices({tasks:[first]})[0].title,'正本タブ');
(async()=>{
  const streams = [], pending = {};
  const model = new TaskCanonicalViewModel({
    context: id => new Promise(resolve=>pending[id]=resolve),
    makeDocument: () => new CanonicalDocumentViewModel({files:{},generatedAt:'2026-10-21'},(path,receive)=>{
      const stream={path,receive,closed:false};streams.push(stream);return ()=>{stream.closed=true};
    })
  });
  const selectFirst = model.select(first.id);
  pending[first.id]({task:first,documents:[{path:'a.md',status:'ok'},{path:'b.md',status:'ok'},{path:'missing.md',status:'missing'}],letters:[{id:'LTR-fixture'}]});await selectFirst;
  assert.deepEqual(model.state.documents.map(d=>d.path),['a.md','b.md','missing.md']);
  const send=(index,html)=>streams[index].receive({document:{path:streams[index].path,html,status:'ready',stamp:'test'}});
  send(0,'part A');send(1,'part B');
  assert.deepEqual(model.state.documents.map(d=>d.html),['part A','part B','']);
  assert.equal(model.state.documents[2].status,'missing');assert.equal(model.state.letters[0].id,'LTR-fixture');
  send(0,'updated A');send(1,'updated B');assert.deepEqual(model.state.documents.slice(0,2).map(d=>d.html),['updated A','updated B']);
  const selectSecond=model.select(second.id);
  assert.ok(streams.every(s=>s.closed));assert.equal(model.state.documents.length,0);
  pending[second.id]({task:second,documents:[{path:'b.md',status:'ok'}],letters:[]});await selectSecond;
  send(0,'late old task');assert.equal(model.state.taskId,second.id);assert.equal(model.state.documents.length,1);
  const stale=model.select(first.id),newer=model.select(second.id);
  pending[second.id]({task:second,documents:[],letters:[]});await newer;
  pending[first.id]({task:first,documents:[{path:'a.md',status:'ok'}],letters:[]});await stale;
  assert.equal(model.state.taskId,second.id);assert.equal(model.state.documents.length,0);assert.match(model.state.message,/指定がありません/);
  model.close();console.log('PASS: task-ID entry, ordered multipart, missing part, independent updates, separate letters, stale-task and stale-response rejection');
})().catch(error=>{console.error(error);process.exit(1)});
{
  const { recentCanonicalTasks } = require('./index.document.model.js');
  const registry={tasks:[{id:'OPS-1',item:'one'},{id:'OPS-2',item:'two'},{id:'OPS-3',item:'no work date'}]};
  const tasks=recentCanonicalTasks(registry,[{taskId:'OPS-1',workedAt:'2026-10-21T10:00:00Z'},{taskId:'OPS-2',workedAt:'2026-10-21T11:00:00Z'},{taskId:'OPS-1',workedAt:'2026-10-21T12:00:00Z'},{taskId:'OPS-999',workedAt:'2026-10-21T13:00:00Z'}]);
  assert.deepEqual(tasks.map(t=>t.id),['OPS-1','OPS-2']);
  assert.equal(tasks[0].workedAt,'2026-10-21T12:00:00Z');
  console.log('PASS: recent task cards use latest recorded work, deduplicate and exclude unknown/unrecorded tasks');
}
