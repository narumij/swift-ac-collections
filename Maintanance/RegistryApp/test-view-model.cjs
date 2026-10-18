// OPS-153 区切り4: the shared studio snapshot. Three layers, kept apart:
//  1. input boundary -> snapshot (ordering: late / failed / recovered answers),
//  2. snapshot -> view model (meaning, pure deriveStudio; parts, revision, non-simultaneous sources, clock, UI inputs),
//  3. distribution -> views (one derive per input, the same revision to every view the studio has), plus a minimal wiring check.
// Fixed view models -> DOM are tested per view in test-view-model-members / -cards / -current-wake.
process.env.TZ='UTC';
const fs=require('fs'),vm=require('vm'),assert=require('assert');
const html=fs.readFileSync(process.env.STUDIO_TEMPLATE||__dirname+'/index.template.html','utf8');
const slice=(a,b)=>{const i=html.indexOf(a),j=html.indexOf(b);assert(i>=0&&j>i,'markers '+a);return html.slice(i,j);};
const c={document:{createElement:()=>({value:'',textContent:''})}};vm.createContext(c);
vm.runInContext('const __DTF=Intl.DateTimeFormat;Intl.DateTimeFormat=function(l,o){return new __DTF(l??"ja-JP",o);};',c);
vm.runInContext(slice('const activityLabels=','function startActivityTimelines(')+'\n'+slice('const WAKE_SENDER=','async function sendWake(')+'\n'+slice('// OPS-119 work lane','// OPS-114: this lane owns only approval DOM')+'\n'+slice('const CONTINUITY_LIMIT_MS','// OPS-136: when focus leaves the scrolled approval part'),c);
const BASE=Date.UTC(2026,9,19,6,0,0);let seq=0;
const ev=(taskId,event,owner,reason='',extra={})=>{seq++;return {schemaVersion:1,id:seq.toString(16).padStart(32,'0'),taskId,event,owner,reason,timestamp:new Date(BASE+seq*1000).toISOString().replace('.000Z','Z'),...extra};};
const rows=list=>c.validateActivityRows(list,'events');
const appr=(id,taskId,status)=>({id,revision:1,taskId,title:'t',scope:'s',paths:['a'],condition:'c',branch:'b',status,createdAt:'x',updatedAt:'x'});
const clone=x=>JSON.parse(JSON.stringify(x,(k,v)=>v instanceof Set?[...v]:typeof v==='function'?'fn':v));
const ALL=['members','cards','timeline','wake'];
(async()=>{
// 1. Input boundary -> snapshot.
{let s=c.emptyStudioSnapshot(ALL);const r=rows([ev('T-1','work','甲','x')]);
 s=c.applyStudioInput(s,{source:'activity',ok:true,value:r,at:'a1'});
 assert.deepEqual(clone(s.sources.activity).generation,1);assert.equal(s.sources.activity.ok,true);assert.equal(s.sources.activity.receivedAt,'a1');assert.equal(s.revision,1);
 s=c.applyStudioInput(s,{source:'activity',ok:false,at:'a2'});
 assert.equal(s.sources.activity.generation,2);assert.equal(s.sources.activity.ok,false);assert.strictEqual(s.sources.activity.value,r,'a failure keeps the last good value');
 s=c.applyStudioInput(s,{source:'approvals',ok:false,at:'p1'});
 assert.equal(s.sources.approvals.generation,1);assert.equal(s.sources.activity.generation,2,'sources are independent: no combined server state');
 assert.throws(()=>c.applyStudioInput(s,{source:'other'}),/Unknown studio input/);
 const before=clone(s);c.applyStudioInput(s,{source:'clock',now:5});assert.deepEqual(clone(s),before,'applying an input never changes the previous snapshot');}
// The continuity boundary passes only accepted answers: a late, older answer never replaces a newer one; a failure is flagged.
{let perf=0,got=[];const q=[];const st=c.createContinuityStatus({onData:d=>got.push(clone(d)),fetchRecord:()=>new Promise((res,rej)=>q.push({res,rej})),now:()=>perf});
 const alive=at=>({state:'alive',at});const tick=()=>new Promise(r=>setImmediate(r));
 st.poll();st.poll();q[1].res({serverNow:'2026-10-19T06:01:00Z',owners:{甲:alive('2026-10-19T06:00:58Z')}});await tick();
 q[0].res({serverNow:'2026-10-19T06:00:30Z',owners:{甲:alive('2026-10-19T06:00:00Z')}});await tick();
 assert.equal(got.length,1,'the late answer is dropped at the boundary');assert.equal(got[0].base.owners['甲'].at,'2026-10-19T06:00:58Z');
 st.poll();q[2].rej(Error('down'));await tick();assert.equal(got.at(-1).failed,true);assert.equal(got.at(-1).base.owners['甲'].at,'2026-10-19T06:00:58Z','the last good marks are kept');}

// 2. Snapshot -> view model (pure).
{const req=ev('T-2','request','調整','R-20261019-21：依頼',{next:'甲'}),start=ev('T-2','work','甲','R-20261019-21：着手',{presence:'working'});
 let s=c.emptyStudioSnapshot(ALL,{registryState:id=>({'T-2':'ACTIVE'})[id]});
 s=c.applyStudioInput(s,{source:'activity',ok:true,value:rows([req,start])});
 let v=c.deriveStudio(s);assert.equal(v.revision,1);assert.deepEqual(Object.keys(v).sort(),['cards','members','revision','timeline','wake']);
 assert.equal(v.cards.cards[0].stage,'着手');assert.equal(v.timeline.current.heading,'現在：T-2 · 甲 · 作業');assert.equal(v.members.entries.find(e=>e.owner==='甲').state,'working');assert.deepEqual([...v.wake.owners],['甲','調整']);
 assert.deepEqual(Object.keys(c.deriveStudio(s,['cards'])).sort(),['cards','revision'],'only the requested parts are built');
 assert.deepStrictEqual(clone(c.deriveStudio(s)),clone(c.deriveStudio(s)),'pure: same snapshot, same view model');
 // Non-simultaneous sources: each part shows the state of the sources it reads, nothing is invented.
 s=c.applyStudioInput(s,{source:'approvals',ok:false});v=c.deriveStudio(s);
 assert.equal(v.cards.status,'1件 · 承認の取得不調 · 最終情報を保持');assert.equal(v.timeline.failed,undefined,'an approval failure does not touch the timeline');assert.equal(v.members.failed,false);
 s=c.applyStudioInput(s,{source:'activity',ok:false});v=c.deriveStudio(s);
 assert.equal(v.timeline.failed,true);assert.equal(v.members.failed,true);assert.equal(v.cards.status,'1件 · 活動の取得不調 · 承認の取得不調 · 最終情報を保持');assert.equal(v.cards.cards.length,1,'last good cards kept');
 assert.equal(v.members.failureText('甲'),'甲：取得不調（状態を読めません）\n継続 未確認');
 s=c.applyStudioInput(s,{source:'activity',ok:true,value:rows([req,start])});s=c.applyStudioInput(s,{source:'approvals',ok:true,value:[appr('a','T-2','pending')]});v=c.deriveStudio(s);
 assert.equal(v.cards.status,'1件');assert.equal(v.cards.cards[0].next,'approval');assert.equal(v.timeline.failed,undefined);}
// The clock is an input: freshness changes with no new data.
{let s=c.emptyStudioSnapshot(['members']);
 s=c.applyStudioInput(s,{source:'activity',ok:true,value:rows([ev('T-3','work','乙','待機',{presence:'waiting'})])});
 s=c.applyStudioInput(s,{source:'continuity',ok:true,value:{base:{serverMs:Date.parse('2026-10-19T06:00:10Z'),owners:{乙:{state:'alive',at:'2026-10-19T06:00:00Z'}},perf:1000},failed:false},now:1000});
 const line=s=>c.deriveStudio(s).members.entries.find(e=>e.owner==='乙').body.split('\n').at(-1);
 assert.equal(line(s),'継続 6:00:00（10秒前）');
 s=c.applyStudioInput(s,{source:'clock',now:46000});assert.equal(line(s),'継続 6:00:00（55秒前）');
 s=c.applyStudioInput(s,{source:'clock',now:46001});assert(line(s).startsWith('継続 確認が古い'),'ages from the clock alone');
 const good=s.sources.continuity.value;s=c.applyStudioInput(s,{source:'continuity',ok:false,now:47000});assert(line(s).startsWith('継続 不調'));
 assert.equal(s.sources.continuity.ok,false);assert.strictEqual(s.sources.continuity.value,good,'a continuity failure keeps the last good marks');
 assert(line(s).includes('最後に読めた確認 6:00:00'),'the failure text names the last good mark');}
// UI inputs: the kept member order, the WAKE choice falling back, a result note belonging to one owner and request.
{const s0=c.emptyStudioSnapshot(['members','wake']);let s=c.applyStudioInput(s0,{source:'activity',ok:true,value:rows([ev('T-4','work','甲','x'),ev('T-4','work','乙','y')])});
 assert.equal(s.ui.wakeSelected,'乙','first listed owner (latest first)');
 s=c.applyStudioInput(s,{source:'wake',patch:{wakeSelected:'甲',wakeNote:''}});assert.equal(s.ui.wakeSelected,'甲');
 s=c.applyStudioInput(s,{source:'wake',patch:{wakeNote:'N',wakeNoteFor:c.wakeKey(s.sources.activity.value,'甲')}});assert.equal(c.deriveStudio(s).wake.text,'N');
 s=c.applyStudioInput(s,{source:'activity',ok:true,value:rows([ev('T-4','work','甲','x'),ev('T-4','work','乙','y'),ev('T-5','request','ユーザー','WAKE-20261019-'+'S'.repeat(8)+'：待機終了依頼',{next:'甲'})])});
 assert.equal(s.ui.wakeNote,'','the note is cleared when the request state of the chosen owner changes');
 s=c.applyStudioInput(s,{source:'activity',ok:true,value:rows([ev('T-6','work','丙','z')])});assert.equal(s.ui.wakeSelected,'丙','an unlisted choice falls back to the first owner');
 const v=c.deriveStudio({...s,ui:{...s.ui,memberOrder:['乙','丙']}},['members']);assert.deepEqual(v.members.order,['丙'],'kept order, members that left dropped');}

// 3. Distribution: one derive per input and the same revision to every view the studio has (H-20261019-15).
{const calls=[],spy=name=>({show:(x,y,rev)=>calls.push([name,'show',typeof y==='number'?y:rev]),showFailure:(x,rev)=>calls.push([name,'failure',rev]),recovered:()=>{},update:(x,rev)=>calls.push([name,'update',rev])});
 const st=c.createStudio({views:{members:spy('members'),cards:spy('cards'),timeline:spy('timeline'),wake:spy('wake')}});
 const take=()=>calls.splice(0).map(x=>x[0]+':'+x[1]+':'+x[2]).sort();
 const all=r=>['cards:update:'+r,'members:show:'+r,'timeline:show:'+r,'wake:show:'+r];
 st.activity(rows([ev('T-7','work','甲','x')]));assert.deepEqual(take(),all(1),'activity: every view, same revision');
 st.approvals([]);assert.deepEqual(take(),all(2),'approvals: every view, same revision');
 st.tick(1);assert.deepEqual(take(),all(3),'clock: every view, same revision');
 st.continuity({labelOf:()=>'L',owners:[]});assert.deepEqual(take(),all(4));
 st.wakeSelect('甲');assert.deepEqual(take(),all(5),'a WAKE choice: every view, same revision');
 st.activityFailure();assert.deepEqual(take(),['cards:update:6','members:failure:6','timeline:failure:6','wake:show:6']);
 // a studio with fewer views draws only the views it has
 {const one=[];const solo=c.createStudio({views:{cards:{update:(x,r)=>one.push(r)}}});solo.activity(rows([]));solo.tick(2);assert.deepEqual(one,[1,2]);}
 // WAKE send is an operation of the presenter: busy, one send, then the result note; never a resend.
 let reply;const sent=[];const p=st.wakeSend(o=>{sent.push(o);return new Promise(r=>reply=r);});
 assert.equal(st.snapshot().ui.wakeBusy,true);st.wakeSend(()=>sent.push('again'));assert.deepEqual(sent,['甲'],'busy: no second send');
 reply({created:true});await p;assert.equal(st.snapshot().ui.wakeBusy,false);assert.equal(c.deriveStudio(st.snapshot()).wake.text,'送信しました。記録の反映を待っています');}
// Source metadata from the public entries and the page-like wiring (injected clocks; receivedAt in ms since the epoch).
{let wall=1000;const st=c.createStudio({views:{members:{show(){},showFailure(){},recovered(){}},cards:{update(){}}},now:()=>wall});
 st.activity(rows([ev('T-10','work','甲','x')]));let a=st.snapshot().sources.activity;assert.deepEqual([a.generation,a.ok,a.receivedAt],[1,true,1000]);
 wall=4000;st.activityFailure();a=st.snapshot().sources.activity;assert.deepEqual([a.generation,a.ok,a.receivedAt],[2,false,4000]);assert.equal(a.value.length,1,'last good kept');
 wall=7000;st.approvalFailure();const p=st.snapshot().sources.approvals;assert.deepEqual([p.generation,p.ok,p.receivedAt],[1,false,7000]);
 // continuity through the real boundary into the studio, as the page wires it (onData -> studio.continuity(data, perf))
 let perf=0;const q=[];const tick=()=>new Promise(r=>setImmediate(r));
 const bound=c.createContinuityStatus({onData:data=>st.continuity(data,perf),fetchRecord:()=>new Promise((res,rej)=>q.push({res,rej})),now:()=>perf});
 wall=9000;perf=500;bound.poll();q[0].res({serverNow:'2026-10-19T06:00:10Z',owners:{甲:{state:'alive',at:'2026-10-19T06:00:00Z'}}});await tick();
 let k=st.snapshot().sources.continuity;assert.deepEqual([k.generation,k.ok,k.receivedAt],[1,true,9000]);assert.equal(k.value.base.owners['甲'].at,'2026-10-19T06:00:00Z');assert.equal(st.snapshot().clock,500);
 wall=12000;perf=900;bound.poll();q[1].rej(Error('down'));await tick();
 k=st.snapshot().sources.continuity;assert.deepEqual([k.generation,k.ok,k.receivedAt],[2,false,12000],'a failed fetch is ok=false');assert.equal(k.value.base.owners['甲'].at,'2026-10-19T06:00:00Z','never overwritten by the failure');
 assert(c.deriveStudio(st.snapshot()).members.entries.find(e=>e.owner==='甲').body.includes('継続 不調'));
 // the page studio uses the wall clock by default and passes performance.now() for continuity
 assert(/function createStudio\(\{views,registryState,withCurrent=true,now=\(\)=>Date\.now\(\)\}\)/.test(html));}
// WAKE: the result belongs to the owner and request state fixed at the start of the send (A sending -> B chosen -> A answers).
for(const outcome of ['success','failure']){
 const st=c.createStudio({views:{wake:{show(){}}}});st.activity(rows([ev('T-11','work','甲','x'),ev('T-11','work','乙','y')]));
 st.wakeSelect('甲');let reply;const sent=[];const p=st.wakeSend(o=>{sent.push(o);return new Promise((res,rej)=>reply={res,rej});});
 assert.deepEqual(st.snapshot().ui.wakeSending,{owner:'甲',key:'甲|none|'});
 st.wakeSelect('乙');assert.equal(st.snapshot().ui.wakeSelected,'乙');
 if(outcome==='success')reply.res({created:true});else reply.rej(Error('Unknown owner'));await p;
 assert.deepEqual(sent,['甲'],'sent to the owner chosen at the start');
 const v=c.deriveStudio(st.snapshot()).wake;assert.equal(v.selected,'乙');assert.equal(v.text,'',outcome+': the result of 甲 is not shown for 乙');
 assert.equal(st.snapshot().ui.wakeNoteFor,'甲|none|','the note is filed under 甲 and the request state at the start');assert.equal(st.snapshot().ui.wakeSending,null);
 // when the choice did not change, the note is shown for that owner
 const st2=c.createStudio({views:{wake:{show(){}}}});st2.activity(rows([ev('T-12','work','甲','x')]));let r2;const p2=st2.wakeSend(()=>new Promise((res,rej)=>r2={res,rej}));
 if(outcome==='success')r2.res({created:true});else r2.rej(Error('Unknown owner'));await p2;
 assert.equal(c.deriveStudio(st2.snapshot()).wake.text,outcome==='success'?'送信しました。記録の反映を待っています':'送信できませんでした：Unknown owner');}
// Flash: the timer repaints the latest view model (here, after a continuity update), never an older one.
{class Node{constructor(t){this.tag=t;this.children=[];this.dataset={};this.textContent='';this.className='';this.parent=null;}appendChild(n){if(n.parent)n.remove();n.parent=this;this.children.push(n);}remove(){if(this.parent){this.parent.children.splice(this.parent.children.indexOf(this),1);this.parent=null;}}}
 const timers=[],box=new Node('box'),st=c.createStudio({views:{members:c.createMemberLampView({box,makeNode:t=>new Node(t),schedule:fn=>timers.push(fn)})}});
 const a=ev('T-8','work','甲','待機',{presence:'waiting'});st.activity(rows([a]));st.activity(rows([a,ev('T-8','return','甲','返却',{next:'調整'})]));
 assert(box.children[0].textContent.includes('・新着'));st.continuity({labelOf:o=>'継続 新しい値',owners:['甲']});
 assert(box.children[0].textContent.includes('・新着')&&box.children[0].textContent.endsWith('継続 新しい値'));
 while(timers.length)timers.shift()();assert(!box.children[0].textContent.includes('・新着'));assert(box.children[0].textContent.endsWith('継続 新しい値'),'the flash timer repaints the latest view model');}
// Minimal wiring: the page has one studio with the four views; the activity poller, approvals, continuity and the clock feed it.
{const src=slice('function workLaneInstance(){','// OPS-114: this lane owns only approval DOM');
 for(const v of ['timeline:createActivityTimelineView(','cards:createWorkLaneView(','members:createMemberLampView(','wake:createWakeView('])assert(src.includes(v),'the page studio has '+v);
 assert(src.includes('onData:data=>studio.continuity(data,performance.now())')&&src.includes('setInterval(()=>studio.tick(performance.now()),1000)'));
 assert(html.includes('const view={update(rows){workLaneInstance().activity(rows);},failure(){workLaneInstance().activityFailure();}}'));
 assert(html.includes('workLaneInstance().approvals(value.requests)')&&html.includes('workLaneInstance().approvalFailure()'));
 assert.equal((html.match(/createStudio\(\{registryState:id=>states\.get\(id\)/g)||[]).length,1,'exactly one page studio');}
console.log('PASS: OPS-153 shared studio (input boundary ordering, pure snapshot -> view model with parts/revision/non-simultaneous sources/clock/UI inputs, one revision to every view, source receivedAt/ok from the public entries and the continuity boundary, WAKE result fixed to the owner at the send start, flash repaints the latest view model, page wiring).');
})().catch(e=>{console.error(e);process.exit(1);});
