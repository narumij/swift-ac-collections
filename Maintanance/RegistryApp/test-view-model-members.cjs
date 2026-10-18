// OPS-153 区切り1: member status. (a) Compatibility baseline: a fixed, anonymized scenario driven through the public lamp API,
// its DOM recorded step by step and compared with view-model-members.baseline.json, captured from 73b623ea before the
// extraction. The baseline proves "same output as before", not correctness; known limits are listed in the file.
// (b) Contract cases of the pure member view model. Run with --write only to re-capture the baseline from the current code.
process.env.TZ='UTC';  // memberTime uses the runtime time zone; fixed so that another machine gives the same text
const fs=require('fs'),vm=require('vm'),assert=require('assert');
const html=fs.readFileSync(process.env.STUDIO_TEMPLATE||__dirname+'/index.template.html','utf8');
const slice=(a,b)=>{const i=html.indexOf(a),j=html.indexOf(b);assert(i>=0&&j>i,'markers '+a);return html.slice(i,j);};
const c={};vm.createContext(c);
// Intl with an undefined locale (shortTime) follows the runtime; pin it to ja-JP so the captured text does not depend on it.
vm.runInContext('const __DTF=Intl.DateTimeFormat;Intl.DateTimeFormat=function(l,o){return new __DTF(l??"ja-JP",o);};',c);
vm.runInContext(slice('const activityLabels=','function startActivityTimelines(')+'\n'+slice('// OPS-119 work lane','// OPS-114: this lane owns only approval DOM')+'\n'+slice('const CONTINUITY_LIMIT_MS','function validateContinuity('),c);
const BASE=Date.UTC(2026,9,19,3,0,0);let seq=0;
const ev=(taskId,event,owner,reason='',extra={})=>{seq++;return {schemaVersion:1,id:seq.toString(16).padStart(32,'0'),taskId,event,owner,reason,timestamp:new Date(BASE+seq*1000).toISOString().replace('.000Z','Z'),...extra};};
const rows=list=>c.validateActivityRows(list,'events');
class Node{constructor(t){this.tag=t;this.children=[];this.dataset={};this.textContent='';this.className='';this.parent=null;}appendChild(n){if(n.parent)n.remove();n.parent=this;this.children.push(n);}remove(){if(this.parent){this.parent.children.splice(this.parent.children.indexOf(this),1);this.parent=null;}}}
// Continuity labels come from the real continuityState with fixed marks and ages (no clock).
const mark=(state,sec)=>({state,at:new Date(BASE+sec*1000).toISOString()});
const contFn=(table,failed=false)=>owner=>{const t=table[owner];return c.continuityState(t?t[0]:null,t?t[1]:null,failed).label;};

function scenario(){
 const timers=[],box=new Node('box');const lamps=c.createPresenceLamps({box,makeNode:t=>new Node(t),schedule:(fn,ms)=>timers.push(fn)});
 const steps=[],snap=name=>steps.push({name,stale:box.dataset.stale||'',lamps:box.children.map(n=>({text:n.textContent,state:n.dataset.state,pending:n.dataset.pending||'',fresh:n.dataset.fresh||'',cls:n.className}))});
 const fire=()=>{while(timers.length)timers.shift()();};
 const A=ev('T-1','work','メンバーA','待機',{presence:'waiting'}),B=ev('T-1','work','メンバーB','着手',{presence:'working'});
 const ackOld=ev('T-2','work','メンバーC','ACK WAKE-20261018-C：会話へ戻る');ackOld.timestamp='2026-10-18T10:00:00Z';
 const U=ev('T-3','work','ユーザー','メモ');
 let log=[A,B,ackOld,U];
 lamps.update(rows(log));snap('first load: no flash, legacy ACK labelled, user excluded');
 lamps.update(rows(log));snap('same rows again: no flash');
 const r1=ev('T-4','request','調整','R-20261019-01：依頼',{next:'メンバーD'});log=[...log,r1];
 lamps.update(rows(log));snap('request to a new recipient: 開始待ち, no own record');
 const prac=ev('T-1','return','メンバーA','R-20261019-09返却',{next:'調整'});log=[...log,prac];
 lamps.update(rows(log));snap('a practical record flashes its owner');
 fire();snap('flash timer cleared');
 lamps.continuity(contFn({'メンバーA':[mark('alive',0),10000],'メンバーB':[mark('alive',0),70000],'メンバーE':[mark('ended',0),5000]}),['メンバーA','メンバーB','メンバーE','ユーザー']);snap('continuity: fresh / old / ended-only owner; user ignored');
 const dNo=ev('T-4','work','メンバーD','着手',{presence:'working'});log=[...log,dNo];
 lamps.update(rows(log));snap('recipient working without the ID: 対応未確認');
 const dYes=ev('T-4','work','メンバーD','R-20261019-01：着手',{presence:'working'});log=[...log,dYes];
 lamps.update(rows(log));snap('recipient working with the ID: closed');
 log=[...log,...[1,2,3,4,5].map(i=>ev('T-5','request','調整','R-20261019-1'+i+'：x',{next:'メンバーA'}))];
 lamps.update(rows(log));snap('five open requests: three lines and a count');
 lamps.failure();snap('fetch failure keeps the last members, state unknown');
 lamps.continuity(contFn({'メンバーA':[mark('alive',0),20000]}),['メンバーA']);snap('continuity during failure does not repaint');
 fire();snap('flash timer during failure does not repaint');
 lamps.update(rows(log.slice(0,2)));snap('recovery with a shorter window: members that left are removed');
 lamps.continuity(contFn({},true),['メンバーA']);snap('continuity trouble label');
 return steps;
}
const steps=scenario();
const file=__dirname+'/view-model-members.baseline.json';
if(process.argv.includes('--write')){
 fs.writeFileSync(file,JSON.stringify({about:'OPS-153 区切り1 compatibility baseline of the member status DOM. Captured from 73b623ea (before the member view-model extraction) with TZ=UTC, ja-JP and fixed times. It shows the output stayed the same; it is not a proof of correctness.',
  knownLimits:['derived from the latest 200 activity records only','a request to a renamed or never-answering recipient stays 開始待ち (no cancel format yet)','two conversations with the same display name are not told apart','the flash is a display effect of new records, not a state'],steps},null,1)+'\n');
 console.log('baseline written: '+steps.length+' steps');process.exit(0);
}
const base=JSON.parse(fs.readFileSync(file,'utf8'));
assert.equal(steps.length,base.steps.length,'step count');
// Declared compatibility differences (OPS-153 区切り4; the baseline file is not rewritten). With one shared snapshot,
// continuity is its own source: while the activity fetch fails, a continuity update still repaints the failure text with
// the new continuity labels (before, the lamps kept the labels of the failure moment until activity recovered).
const KNOWN_DIFFERENCES={10:{reason:'continuity keeps updating while the activity fetch fails',
 texts:['メンバーB：取得不調（状態を読めません）\n継続 未確認','メンバーA：取得不調（状態を読めません）\n継続 3:00:00（20秒前）','メンバーC：取得不調（状態を読めません）\n継続 未確認','調整：取得不調（状態を読めません）\n継続 未確認','メンバーD：取得不調（状態を読めません）\n継続 未確認','メンバーE：取得不調（状態を読めません）\n継続 未確認']}};
KNOWN_DIFFERENCES[11]={reason:'the same failure text stays until recovery (the next step is the flash timer during the failure)',texts:KNOWN_DIFFERENCES[10].texts};
steps.forEach((s,i)=>{const d=KNOWN_DIFFERENCES[i];
 if(!d)return assert.deepStrictEqual(s,base.steps[i],'baseline step '+i+': '+base.steps[i].name);
 assert.notDeepStrictEqual(s,base.steps[i],'declared difference is real: '+d.reason);
 assert.deepStrictEqual(s.lamps.map(l=>l.text),d.texts,'declared difference '+i+': '+d.reason);
 assert.deepStrictEqual(s.lamps.map(({text,...rest})=>rest),base.steps[i].lamps.map(({text,...rest})=>rest),'only the text differs');assert.equal(s.stale,base.steps[i].stale);});
// (b) Contract cases of the pure member view model (in addition to the baseline; listed, not exhaustive).
{const r1=ev('T-9','work','甲','待機',{presence:'waiting'}),r2=ev('T-9','request','乙','Q-20261019-01：依頼',{next:'丙'});
 const model=c.memberModel(rows([r1,r2])),vms=c.memberViewModels(model,['丁','ユーザー','甲'],o=>'継続 '+o);
 // order: activity owners (newest first), then 開始待ち-only recipients, then continuity-only owners; the user is never a member
 assert.deepEqual(vms.map(v=>v.owner),['乙','甲','丙','丁']);
 const by=Object.fromEntries(vms.map(v=>[v.owner,v]));
 assert.equal(by['甲'].state,'waiting');assert.equal(by['甲'].head,'甲：待機中 '+c.memberTime(r1.timestamp));assert.equal(by['甲'].pending,false);
 assert.equal(by['丙'].state,'unknown');assert.equal(by['丙'].pending,true);assert(by['丙'].body.includes('開始待ち Q-20261019-01（乙 ')&&by['丙'].body.includes('・本人記録なし'));
 assert.equal(by['丁'].head,'丁：未申告');assert.equal(by['丁'].body,'\n最後 なし\n継続 丁','continuity-only owner: declared nothing, text from the continuity input');
 assert(!vms.some(v=>/新着/.test(v.head+v.body)),'the view model never carries the flash');
 // pure: the same input gives the same entries; the model is not changed by deriving
 assert.deepStrictEqual(JSON.parse(JSON.stringify(c.memberViewModels(model,['丁','ユーザー','甲'],o=>'継続 '+o))),JSON.parse(JSON.stringify(vms)));
 assert.equal(c.memberFailureText('甲',o=>'継続 X'),'甲：取得不調（状態を読めません）\n継続 X');
 // legacy ACK reading is labelled in the head
 const old=ev('T-9','work','戊','ACK WAKE-20261018-C：会話へ戻る');old.timestamp='2026-10-18T10:00:00Z';
 assert(c.memberViewModels(c.memberModel(rows([old])),[],()=>'')[0].head.endsWith('（旧ACKからの読み）'));
 // new-record owners: nothing on the first load, then only owners of unseen records
 const f=c.newRecordOwners(null,rows([r1]));assert.equal(f.owners.size,0);
 const g=c.newRecordOwners(f.seen,rows([r1,r2]));assert.deepEqual([...g.owners],['乙']);assert.equal(g.seen.size,2);}
// H-20261019-12: the kept order is a display input (stableMemberOrder) and the view draws the given order exactly.
{const v=o=>({owner:o,state:'unknown',pending:false,head:o+'：',body:''}),ord=(p,list)=>c.stableMemberOrder(p,list.map(v)).map(x=>x.owner);
 assert.deepEqual(ord([],['A','B']),['A','B'],'no previous order: view-model order');
 assert.deepEqual(ord(['A','B'],['B','A']),['A','B'],'members already shown keep their order');
 assert.deepEqual(ord(['A','B'],['C','B','A']),['A','B','C'],'a new member goes to the end');
 assert.deepEqual(ord(['A','B','C'],['C','A']),['A','C'],'a member that left is dropped');
 assert.deepEqual(ord(['A','C'],['B','C','A']),['A','C','B'],'one that returns goes to the end');
 // fixed view models -> DOM: the view follows the order it is given (ROUND1: [A,B] then [B,A])
 const box=new Node('box'),view=c.createMemberLampView({box,makeNode:t=>new Node(t),schedule:()=>{}});
 view.show([v('A'),v('B')]);assert.deepEqual(box.children.map(n=>n.textContent),['A：','B：']);
 view.show([v('B'),v('A')]);assert.deepEqual(box.children.map(n=>n.textContent),['B：','A：'],'the DOM follows the given order');
 view.show([v('C'),v('B')]);assert.deepEqual(box.children.map(n=>n.textContent),['C：','B：'],'removed and added lamps follow too');
 view.show([v('C'),{...v('B'),state:'working',pending:true}]);const b=box.children[1];assert.equal(b.dataset.state,'working');assert.equal(b.dataset.pending,'true','state and pending are drawn as given');}
// The lamp view does not read the history or choose labels: it only draws the entries it is given.
{const viewSrc=slice('function createMemberLampView(','// The member status as one studio part');
 for(const name of ['presenceStates','startPendings','memberModel','PRESENCE_LABELS','memberTime','pendingLines','confirmedStarts','leadingRequestId'])assert(!viewSrc.includes(name),'the lamp view does not use '+name);}
console.log('PASS: OPS-153 member status matches the 73b623ea baseline ('+steps.length+' steps, 1 declared difference over 2 steps); member view-model contract cases; the lamp view only draws.');
