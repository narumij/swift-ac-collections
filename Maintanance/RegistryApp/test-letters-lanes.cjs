// OPS-183/184: the member status and the recent-work lane read the letters too (one shared, paged reader of
// /letters?brief=1). Isolated tests of the actual page code (pure view models and the reader); no browser or server.
process.env.TZ='UTC';  // memberTime follows the runtime time zone
const fs=require('fs'),vm=require('vm'),assert=require('assert');
const html=fs.readFileSync(__dirname+'/index.template.html','utf8');
const slice=(a,b)=>{const i=html.indexOf(a),j=html.indexOf(b);assert(i>=0&&j>i,'markers '+a);return html.slice(i,j);};
const c={};vm.createContext(c);
vm.runInContext(slice('const activityLabels=','function startActivityTimelines(')+'\n'+slice('// OPS-119 work lane','// OPS-114: this lane owns only approval DOM')+'\n'+slice('const CONTINUITY_LIMIT_MS','function validateContinuity('),c);
const T=m=>new Date(Date.UTC(2026,9,19,3,m,0)).toISOString();
let seq=0;
const ev=(taskId,event,owner,reason='',extra={})=>{seq++;return {schemaVersion:1,id:seq.toString(16).padStart(32,'0'),taskId,event,owner,reason,timestamp:T(seq).replace('.000Z','Z'),...extra};};
const rows=list=>c.validateActivityRows(list,'events');
const e=(event,actor,m,effective=true,recordedBy=actor)=>({event,actor,recordedBy,effective,at:T(m)});
// a brief letter: its state is the last effective event, as the server derives it
const letter=(n,taskId,sender,recipient,events)=>{const eff=events.filter(x=>x.effective);const state=eff.at(-1).event;
 return {id:'LTR-20261019-'+String(n).padStart(2,'0')+'0'.repeat(30),kind:'request',sender,recipient,taskId,sentAt:events[0].at,state,stateLabel:state,events,lastEvent:events.at(-1),lastEventAt:events.at(-1).at};};
const feed=(letters,complete=true)=>({letters,complete});
const studio=(parts)=>{const views={},drawn={};for(const p of parts)views[p]={show(vm){drawn[p]=vm;},update(vm){drawn[p]=vm;},showFailure(t){drawn[p]={failed:t};},recovered(){}};
 return {s:c.createStudio({views,registryState:()=>'',withLetters:true}),drawn};};

// --- the shared reader: every page is read; a cap or a failed page is never shown as "complete" or "none"
(async()=>{
 const pages={'':{letters:[1,2],hasMore:true,nextCursor:'r5'},'r5':{letters:[3],hasMore:false,nextCursor:null}};
 const calls=[];const fetchJson=async path=>{calls.push(path);const cur=(/cursor=([^&]+)/.exec(path)||[])[1]||'';if(!(cur in pages))throw Error('x');return pages[cur];};
 const all=await c.readLetterFeed(fetchJson,{limit:2,maxPages:5});
 assert.deepEqual([...all.letters],[1,2,3]);assert.equal(all.complete,true);
 assert.ok(calls.every(p=>p.startsWith('/letters?brief=1&limit=2')),calls.join());
 const capped=await c.readLetterFeed(fetchJson,{limit:2,maxPages:1});
 assert.deepEqual([[...capped.letters],capped.complete],[[1,2],false],'a cap is an incomplete read');
 await assert.rejects(c.readLetterFeed(async()=>{throw Error('down');},{limit:2,maxPages:5}),'a failed page fails the read');

 // --- member status
 const L1=letter(1,'OPS-1','Astra','姫',[e('sent','Astra',1),e('received','姫',2),e('started','姫',3)]);
 const L2=letter(2,'OPS-2','Astra','姫',[e('sent','Astra',4),e('received','姫',5),e('started','姫',6),e('returned','姫',7)]);
 const L3=letter(3,'OPS-3','Astra','Fable',[e('sent','Astra',8),e('received','Fable',9,false,'Astra')]);  // a proxy receipt
 {const {s,drawn}=studio(['members']);
  s.activity(rows([ev('OPS-1','work','姫','連続待機',{presence:'waiting'})]));
  const lamp=drawn.members.find(x=>x.owner==='姫');
  assert.match(lamp.body,/連絡 読み込み中/,'not yet read: said so, never "none"');
  s.letterFeed(feed([L3,L2,L1]));
  const by=o=>drawn.members.find(x=>x.owner===o);
  assert.equal(by('姫').state,'waiting','a letter event never changes the declared state');
  assert.match(by('姫').head,/待機中/);
  assert.match(by('姫').body,/担当中 LTR-20261019-01/,'the open letter to her');
  assert.doesNotMatch(by('姫').body,/(未受領|受領|担当中|停止要請) LTR-20261019-02/,'her returned letter is not open work for her');
  assert.match(by('姫').body,/最後の連絡 返答 LTR-20261019-02/,'her own latest letter action, labelled as a letter action');
  assert.match(by('Astra').body,/確認待ち LTR-20261019-02/,'returned and unclosed: the sender is to confirm');
  assert.ok(by('Fable'),'a member known only from the letters is listed');
  assert.equal(by('Fable').state,'unknown');
  assert.match(by('Fable').body,/未受領 LTR-20261019-03/,'a proxy receipt did not move the state');
  assert.doesNotMatch(by('Fable').body,/最後の連絡/,'a proxy record is not her own action');
  s.letterFeedFailure();
  assert.match(by('姫').body,/連絡 取得不調/,'a failure is said');
  assert.match(by('姫').body,/担当中 LTR-20261019-01/,'the last good letters stay');
  s.letterFeed(feed([L1],false));
  assert.match(by('姫').body,/連絡 一部のみ/,'an incomplete read is said');
 }

 {const {s,drawn}=studio(['cards']);s.activity(rows([ev('OPS-9','work','姫','旧経路')]));s.letterFeed(feed([L1,L2]));assert.deepEqual(Array.from(drawn.cards.cards,x=>x.taskId),['OPS-9']);}
 console.log('PASS test-letters-lanes');
})().catch(err=>{console.error(err);process.exit(1);});
