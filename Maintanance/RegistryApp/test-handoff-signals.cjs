// OPS-127: handoff (next), end of a piece of work, and per-owner lamps. Isolated tests of the actual code; no browser.
const fs=require('fs'),vm=require('vm'),assert=require('assert');
const html=fs.readFileSync(__dirname+'/index.template.html','utf8');
const slice=(a,b)=>{const i=html.indexOf(a),j=html.indexOf(b);assert(i>=0&&j>i,'markers '+a);return html.slice(i,j);};
const c={};vm.createContext(c);
vm.runInContext(slice('const activityLabels=','function startActivityTimelines(')+'\n'+slice('// OPS-119 work lane','// OPS-114: this lane owns only approval DOM'),c);
let seq=0;
const ev=(taskId,event,owner,reason='',extra={})=>{seq++;return {schemaVersion:1,id:seq.toString(16).padStart(32,'0'),taskId,event,owner,reason,timestamp:new Date(Date.UTC(2026,9,19,1,0,seq)).toISOString().replace('.000Z','Z'),...extra};};
const rows=list=>c.validateActivityRows(list,'events');
const appr=(id,taskId,status)=>({id,revision:1,taskId,title:'t',scope:'s',paths:['a'],condition:'c',branch:'b',status,createdAt:'x',updatedAt:'x'});
const lane=(list,approvals=[])=>new Map(c.workLaneItems(rows(list),approvals).map(i=>[i.taskId,i]));

// Validation: optional fields accepted, bad presence refused, older records still valid.
assert.equal(rows([ev('OPS-1','return','姫','',{next:'Astra'})])[0].raw.next,'Astra');
assert.equal(rows([ev('OPS-1','work','姫','',{presence:'waiting'})])[0].raw.presence,'waiting');
assert.throws(()=>rows([ev('OPS-1','work','姫','',{presence:'asleep'})]));
assert.throws(()=>rows([ev('OPS-1','work','姫','',{next:'x'.repeat(81)})]));
assert.equal(rows([ev('OPS-1','work','姫')])[0].raw.next,'');

// next: from the task's latest practical event only; not carried over; probes do not change it; approval first.
let m=lane([ev('OPS-10','return','姫','返却',{next:'Astra'})]);assert.equal(m.get('OPS-10').next.text,'次：Astra');assert.equal(m.get('OPS-10').next.kind,'known');
m=lane([ev('OPS-10','return','姫','返却',{next:'Astra'}),ev('OPS-10','recheck','Astra','補修依頼')]);assert.equal(m.get('OPS-10').next.text,'次：不明','older next is not carried over');
m=lane([ev('OPS-10','return','姫','返却',{next:'Astra'}),ev('OPS-10','work','姫','ACK PING-20261019-A：受信')]);assert.equal(m.get('OPS-10').next.text,'次：Astra','a probe ACK does not change next');
m=lane([ev('OPS-11','acceptance','Astra','受入',{next:'none'})]);assert.equal(m.get('OPS-11').next.kind,'ended');assert.equal(m.get('OPS-11').next.text,'この仕事は終了');
m=lane([ev('OPS-11','acceptance','Astra','受入',{next:'none'}),ev('OPS-11','request','Astra','再依頼')]);assert.equal(m.get('OPS-11').next.text,'次：不明','end -> new request: the end is not carried over');
m=lane([ev('OPS-11','commit','Astra','記録')]);assert.equal(m.get('OPS-11').next.text,'次：不明','a commit alone is not an end');
m=lane([ev('OPS-12','awaiting-commit','Astra','承認待ち',{next:'user'})],[appr('a','OPS-12','pending')]);assert.equal(m.get('OPS-12').next.text,'次：ユーザー（承認待ち）');assert.equal(m.get('OPS-12').next.kind,'approval');
m=lane([ev('OPS-12','awaiting-commit','Astra','',{next:'user'})]);assert.equal(m.get('OPS-12').next.text,'次：ユーザー');
m=lane([ev('OPS-13','return','姫','',{next:'Astra'}),ev('OPS-14','request','Astra','',{next:'姫'})]);assert.equal(m.get('OPS-13').next.text,'次：Astra');assert.equal(m.get('OPS-14').next.text,'次：姫','tasks are independent');
// presence records are not work for the lane
m=lane([ev('OPS-15','return','姫','返却'),ev('OPS-15','work','姫','WAIT 連続待機開始',{presence:'waiting'})]);assert.equal(m.get('OPS-15').stage,'返却・受入待ち');
assert(rows([ev('OPS-1','work','姫','',{presence:'working'})])[0].raw.presence==='working','working is accepted');

// OPS-141 member states: the declared state stays until the member declares another; practical events, PINGs and new
// ACKs never change it; up to the legacy boundary a WAKE ACK keeps its old "wait ended" reading, labelled as old.
const st=list=>Object.fromEntries([...c.presenceStates(rows(list))].map(([o,v])=>[o,v.state]));
const w=ev('OPS-20','work','姫','WAIT 待機開始',{presence:'waiting'});
assert.deepEqual(st([w]),{'姫':'waiting'});
assert.deepEqual(st([w,ev('OPS-20','work','姫','ACK PING-20261019-B：受信')]),{'姫':'waiting'},'PING ACK does not change presence');
assert.deepEqual(st([w,ev('OPS-21','work','姫','実装に着手')]),{'姫':'waiting'},'practical work does not change the declared state');
const ackNew=ev('OPS-20','work','姫','ACK WAKE-20261019-C：受信');ackNew.timestamp='2026-10-19T00:00:00Z';
assert.deepEqual(st([w,ackNew]),{'姫':'waiting'},'a new WAKE ACK only confirms receipt');
const ackOld=ev('OPS-20','work','姫','ACK WAKE-20261018-C：会話へ戻る');ackOld.timestamp='2026-10-18T10:00:00Z';
const old=c.presenceStates(rows([ackOld])).get('姫');assert.equal(old.state,'ended');assert.equal(old.legacy,true,'old ACK reading is labelled, not a declaration');
assert.deepEqual(st([ev('OPS-20','work','姫','',{presence:'ended'})]),{'姫':'ended'});
assert.deepEqual(st([ev('OPS-20','work','姫','着手',{presence:'working'})]),{'姫':'working'});
assert.deepEqual(st([w,ev('OPS-22','request','Astra','依頼')]),{'姫':'waiting','Astra':'unknown'},'owners are independent; no state is invented');
assert.deepEqual(st([ev('OPS-23','work','ユーザー','x')]),{},'the user is not a member');
// working -> return with waiting (one record) -> wait ended; the return stays in the lane and is the last activity
{const flow=[ev('OPS-30','work','姫','着手',{presence:'working'}),ev('OPS-30','return','姫','返却',{next:'Astra',presence:'waiting'})];
 const s=c.presenceStates(rows(flow)).get('姫');assert.equal(s.state,'waiting');assert.equal(s.last.label,activityLabelOf('return'));
 assert.equal(lane(flow).get('OPS-30').stage,'返却・受入待ち','a return with a presence stays in the lane');
 const ended=c.presenceStates(rows([...flow,ev('OPS-30','work','姫','待機を終える',{presence:'ended'})])).get('姫');assert.equal(ended.state,'ended');assert.equal(ended.last.label,activityLabelOf('return'),'a presence-only work record is not an activity');}
function activityLabelOf(e){return vm.runInContext('activityLabels',c)[e];}
// Lamp view: no flash on the first load or a repeated fetch; one flash per new record; failure and recovery; continuity text.
class Node{constructor(t){this.tag=t;this.children=[];this.dataset={};this.textContent='';this.className='';this.parent=null;}appendChild(n){if(n.parent)n.remove();n.parent=this;this.children.push(n);}remove(){if(this.parent){this.parent.children.splice(this.parent.children.indexOf(this),1);this.parent=null;}}}
const timers=[],box=new Node('box');const lamps=c.createPresenceLamps({box,makeNode:t=>new Node(t),schedule:(fn,ms)=>timers.push({fn,ms})});
const first=rows([w,ev('OPS-24','request','Astra','依頼')]);
lamps.update(first);assert.equal(timers.length,0,'no flash on the first load');assert.equal(box.children.length,2);
const himeLamp=box.children.find(n=>n.textContent.startsWith('姫'));assert(himeLamp.textContent.startsWith('姫：待機中 '));assert(himeLamp.textContent.includes('\n最後 なし\n継続 未確認'),'no continuity mark = 未確認');assert.equal(himeLamp.dataset.state,'waiting');
lamps.update(first);assert.equal(timers.length,0,'no flash for a repeated fetch');
const next=rows([...first.map(r=>({schemaVersion:1,id:r.id,taskId:r.raw.taskId,event:r.event,owner:r.raw.owner,reason:r.raw.reason,timestamp:r.raw.at,...(r.raw.presence?{presence:r.raw.presence}:{})})),ev('OPS-24','work','Astra','受入確認')]);
lamps.update(next);const astra=box.children.find(n=>n.textContent.startsWith('Astra'));
assert(astra.textContent.startsWith('Astra：未申告・新着\n最後 '),'Astra has no declared state; the flash mark is on the first line');assert.equal(astra.dataset.fresh,'true');assert.equal(himeLamp.dataset.fresh,undefined,'only the owner with a new record flashes');
assert.equal(timers.length,1);timers[0].fn();assert.equal(astra.dataset.fresh,undefined);assert(!astra.textContent.includes('・新着'),'the flash text goes away');
// continuity text and continuity-only members
lamps.continuity(o=>o==='Astra'?'継続 確認が古い（x）':'継続 未確認',['Astra','Sol']);assert(astra.textContent.endsWith('継続 確認が古い（x）'));
const sol=box.children.find(n=>n.textContent.startsWith('Sol'));assert(sol&&sol.textContent.startsWith('Sol：未申告\n最後 なし'),'a continuity-only member is shown, state not invented');
lamps.failure();assert.equal(box.dataset.stale,'true');assert(himeLamp.textContent.startsWith('姫：取得不調'));
lamps.update(next);assert.equal(box.dataset.stale,undefined);assert(himeLamp.textContent.startsWith('姫：待機中'),'recovered');
// OPS-127 fix 1: a flash timer firing during a fetch failure keeps the failure text until recovery.
{const t=[],bx=new Node('box'),lv=c.createPresenceLamps({box:bx,makeNode:x=>new Node(x),schedule:(fn,ms)=>t.push(fn)});
 const a=[ev('OPS-30','request','Astra','依頼')];lv.update(rows(a));const b2=[...a,ev('OPS-30','work','Astra','作業')];lv.update(rows(b2));assert.equal(t.length,1);
 lv.failure();t[0]();const n=bx.children[0];assert(n.textContent.startsWith('Astra：取得不調'),'failure text kept after the timer');assert.equal(bx.dataset.stale,'true');
 lv.update(rows(b2));assert(n.textContent.startsWith('Astra：未申告'),'recovery clears the failure text');}
// OPS-127 fix 2 / OPS-141: no silent cap on members; an owner leaves only when its records leave the window, and a flash timer
// does not bring it back.
{const t=[],bx=new Node('box'),lv=c.createPresenceLamps({box:bx,makeNode:x=>new Node(x),schedule:(fn,ms)=>t.push(fn)});
 const base=[ev('OPS-31','request','Old','依頼')];lv.update(rows(base));const plus=[...base,ev('OPS-31','work','Old','作業')];lv.update(rows(plus));assert.equal(t.length,1);
 const crowd=[...plus,...['A1','A2','A3','A4','A5','A6','A7'].map(o=>ev('OPS-32','work',o,'作業'))];lv.update(rows(crowd));
 assert.equal(bx.children.length,8,'all eight members shown, no cap');
 lv.update(rows(crowd.slice(2)));assert(!bx.children.some(x=>x.textContent.startsWith('Old')),'Old left the record window');const before=bx.children.length;
 t[0]();assert(!bx.children.some(x=>x.textContent.startsWith('Old')),'the timer does not revive a removed owner');assert.equal(bx.children.length,before);}
// OPS-127 fix 3: the approval colour wins over the consult-stage border on the same card (specificity, not order).
{const next=html.match(/([^}]*)\[data-next="approval"\]\{border-left-color:#c0392b\}/),stage=html.match(/([^}]*)\[data-stage="相談待ち"\]\{border-color/);
 assert(next&&stage,'both rules present');const spec=sel=>(sel.match(/\.[\w-]+|\[[^\]]+\]/g)||[]).length;
 assert(spec(next[1].split('}').pop()+'[data-next="approval"]')>spec(stage[1].split('}').pop()+'[data-stage="相談待ち"]'),'approval rule is more specific');}
// CSS: reduced motion has no animation; lamps do not use the approval circles.
assert(html.includes('@media(prefers-reduced-motion:reduce){.presence-lamp[data-fresh="true"]{animation:none}}'));
const lampRules=html.match(/\.presence-lamp[^{]*\{[^}]*\}/g)||[];assert(lampRules.length>=4);assert(!lampRules.some(r=>/[🟢🟡🔴⚪]/u.test(r)),'lamp styles do not reuse the approval circles');
assert(!/labels=\{waiting:'[^']*[🟢🟡🔴⚪]/u.test(html),'lamp labels are text');
// Probe panel moved into the work lane fold; the current band skips presence records.
const laneHtml=slice('<section class="approval-lane work-lane"','<div id="workspace"');
const memberHtml=slice('<section class="member-area"','<section class="approval-lane work-lane"');assert(memberHtml.includes('id="presence-lamps"')&&!laneHtml.includes('id="presence-lamps"'),'member status is its own section, not in Recent work');
{const r=rows([ev('OPS-1','request','Astra','依頼',{next:'姫'}),ev('OPS-2','request','Astra','依頼'),ev('OPS-3','request','Astra','依頼',{next:'none'}),ev('OPS-4','return','姫','返却',{next:'Astra'})]);
 assert.equal(r[0].heading,'OPS-1 · Astra → 姫 · 依頼');assert.equal(r[1].heading,'OPS-2 · Astra · 依頼','missing recipient: sender only');assert.equal(r[2].heading,'OPS-3 · Astra · 依頼');assert.equal(r[3].heading,'OPS-4 · 姫 · 返却','only requests show the direction');}  // OPS-136: the lane now sits in the work area
assert(laneHtml.includes('id="probe-panel"'),'probe panel inside the work lane');
assert(html.includes("rows.filter(row=>!isProbeEvent(row.raw?.reason)&&!(row.raw?.presence&&row.event==='work')).at(-1)"),'the current band skips presence-only work records');
console.log('PASS: OPS-127/141 handoff/next, member states (declared state kept, legacy ACK labelled, working->return+waiting->ended, return stays in lane, continuity text, flash/failure/recovery), probe panel folded.');
