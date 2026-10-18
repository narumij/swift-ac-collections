// OPS-153 区切り2: work cards. (a) Compatibility baseline: a fixed, anonymized scenario driven through createWorkLane with the
// card view, its DOM recorded step by step and compared with view-model-cards.baseline.json, captured from 73b623ea before
// the card view-model extraction (TZ=UTC, ja-JP, fixed times). It shows the output stayed the same, not that it is correct.
// (b) Contract cases of the pure card view model and of fixed view models -> DOM. --write re-captures the baseline.
process.env.TZ='UTC';
const fs=require('fs'),vm=require('vm'),assert=require('assert');
const html=fs.readFileSync(process.env.STUDIO_TEMPLATE||__dirname+'/index.template.html','utf8');
const slice=(a,b)=>{const i=html.indexOf(a),j=html.indexOf(b);assert(i>=0&&j>i,'markers '+a);return html.slice(i,j);};
const c={};vm.createContext(c);
vm.runInContext('const __DTF=Intl.DateTimeFormat;Intl.DateTimeFormat=function(l,o){return new __DTF(l??"ja-JP",o);};',c);
vm.runInContext(slice('const activityLabels=','function startActivityTimelines(')+'\n'+slice('// OPS-119 work lane','// OPS-114: this lane owns only approval DOM'),c);
const BASE=Date.UTC(2026,9,19,4,0,0);let seq=0;
const ev=(taskId,event,owner,reason='',extra={})=>{seq++;return {schemaVersion:1,id:seq.toString(16).padStart(32,'0'),taskId,event,owner,reason,timestamp:new Date(BASE+seq*1000).toISOString().replace('.000Z','Z'),...extra};};
const rows=list=>c.validateActivityRows(list,'events');
const appr=(id,taskId,status)=>({id,revision:1,taskId,title:'t',scope:'s',paths:['a'],condition:'c',branch:'b',status,createdAt:'x',updatedAt:'x'});
class Node{
 constructor(tag){this.tag=tag;this.children=[];this.dataset={};this.textContent='';this.title='';this.className='';this.parent=null;this.scrollLeft=0;}
 appendChild(n){this.insertBefore(n,null);}
 insertBefore(n,before){if(n.parent)n.remove();n.parent=this;const i=before?this.children.indexOf(before):this.children.length;this.children.splice(i,0,n);}
 remove(){if(this.parent){const a=this.parent.children;a.splice(a.indexOf(this),1);this.parent=null;}}
 contains(n){return n===this||this.children.some(ch=>ch.contains(n));}
}
function scenario(){
 let active=null;const track=new Node('track'),status=new Node('status');
 const lane=c.createWorkLane({view:c.createWorkLaneView({track,status,makeNode:t=>new Node(t),getActive:()=>active}),registryState:id=>({'T-1':'ACTIVE','T-3':'DONE'})[id]});
 const steps=[],snap=name=>steps.push({name,status:status.textContent,stale:status.dataset.stale||'',scroll:track.scrollLeft,
  cards:track.children.map(n=>({lines:n.children.map(l=>[l.tag,l.className,l.textContent]),title:n.title,stage:n.dataset.stage,next:n.dataset.next,cls:n.className,tab:n.tabIndex}))});
 let log=[ev('T-1','request','調整','R-20261019-01：依頼',{next:'メンバーA'}),ev('T-2','work','メンバーB','相談待ち：方針'),ev('T-3','acceptance','調整','受入',{next:'none'})];
 lane.activity(rows(log));snap('first load: request, 相談待ち, ended');
 log=[...log,ev('T-1','work','メンバーA','R-20261019-01：着手',{presence:'working'}),ev('T-2','work','メンバーB','ACK PING-20261019-A：受信'),ev('T-4','work','メンバーC','検討中：案'),ev('T-5','work','メンバーC','待機',{presence:'waiting'})];
 lane.activity(rows(log));snap('confirmed start, probe ignored, 検討中, state notice only');
 const focusCard=track.children.find(n=>n.children[0].textContent.startsWith('T-2'));active=focusCard;track.scrollLeft=55;
 log=[...log,ev('T-2','return','メンバーB','返却',{next:'調整',presence:'waiting'}),ev('T-6','awaiting-commit','調整','承認待ち',{next:'user'})];
 lane.activity(rows(log));snap('focused card stays, scroll kept, return with presence stays, next user');
 lane.approvals([appr('a','T-6','pending'),appr('b','T-1','approved'),appr('c','T-1','claimed'),appr('d','T-7','pending')]);snap('approvals: pending first, badge counts, approval-only task');
 active=null;lane.activityFailure();snap('activity failure keeps the cards');
 lane.approvalFailure();snap('both failures');
 lane.activity(rows(log.slice(-3)));snap('recovery with a shorter window: start unknown');
 lane.approvals([]);snap('approvals recovered and empty');
 lane.activity(rows([]));snap('empty');
 return steps;
}
const steps=scenario(),file=__dirname+'/view-model-cards.baseline.json';
if(process.argv.includes('--write')){
 fs.writeFileSync(file,JSON.stringify({about:'OPS-153 区切り2 compatibility baseline of the work-card DOM. Captured from 73b623ea (before the card view-model extraction) with TZ=UTC, ja-JP and fixed times. It shows the output stayed the same; it is not a proof of correctness.',
  knownLimits:['derived from the latest 200 activity records only','a start is shown only when the request and the start carry the same leading ID, task and recipient','approvals and activity arrive separately; the cards combine their latest values'],steps},null,1)+'\n');
 console.log('baseline written: '+steps.length+' steps');process.exit(0);
}
const base=JSON.parse(fs.readFileSync(file,'utf8'));assert.equal(steps.length,base.steps.length,'step count');
steps.forEach((s,i)=>assert.deepStrictEqual(s,base.steps[i],'baseline step '+i+': '+base.steps[i].name));
// (b) Contract cases of the pure card view model (listed, not exhaustive).
{const it={taskId:'T-9',stage:'返却・受入待ち',next:{kind:'known',text:'次：調整'},owner:'甲',time:'t1',reason:'返却',registryState:'ACTIVE',approvals:{pending:1,approved:2,claimed:0},start:'依頼 t0',startNote:''};
 const v=c.workCardViewModel(it);
 assert.deepEqual(JSON.parse(JSON.stringify(v)),{taskId:'T-9',lines:['T-9 · 返却・受入待ち','次：調整','甲 · t1 · 返却','Registry：ACTIVE · 承認 待ち1 · 済み2','依頼 t0'],title:'T-9 · 返却・受入待ち\n次：調整\n甲 · t1 · 返却\nRegistry：ACTIVE · 承認 待ち1 · 済み2\n依頼 t0',stage:'返却・受入待ち',next:'known'});
 assert.equal(c.workCardViewModel({...it,approvals:{pending:0,approved:0,claimed:1}}).lines[3],'Registry：ACTIVE · 承認 待ち0 · 済み0 · 確保1','claimed is shown only when present');
 assert.equal(c.workCardViewModel({...it,approvals:{pending:0,approved:0,claimed:0},registryState:''}).lines[3],'Registry：不明 · 承認なし');
 const u=c.workCardViewModel({...it,next:null,owner:'',time:'',reason:'',start:'開始：不明',startNote:'開始：不明（記録範囲外または未記録）'});
 assert.equal(u.next,'unknown');assert.equal(u.lines[2],'');assert(u.title.endsWith('開始：不明（記録範囲外または未記録）'),'the title explains an unknown start');
 assert.equal(c.workLaneTrouble(false,false),'');assert.equal(c.workLaneTrouble(true,false),'活動の取得不調 · 最終情報を保持');assert.equal(c.workLaneTrouble(true,true),'活動の取得不調 · 承認の取得不調 · 最終情報を保持');
 assert.deepEqual(JSON.parse(JSON.stringify(c.workLaneViewModel([],''))),{cards:[],status:'記録なし',stale:false});
 const lv=c.workLaneViewModel([it],c.workLaneTrouble(false,true));assert.equal(lv.status,'1件 · 承認の取得不調 · 最終情報を保持');assert.equal(lv.stale,true);}
// Fixed view models -> DOM: drawn as given; order follows the model unless a card has focus; node identity and scroll kept.
{const card=(id,extra={})=>({taskId:id,lines:[id+' · s','n','o','r','st'],title:id+' title',stage:'s',next:'known',...extra});
 let active=null;const track=new Node('track'),status=new Node('status'),view=c.createWorkLaneView({track,status,makeNode:t=>new Node(t),getActive:()=>active});
 view.update({cards:[card('A'),card('B')],status:'2件',stale:false});
 assert.deepEqual(track.children.map(n=>n.children[0].textContent),['A · s','B · s']);assert.equal(status.textContent,'2件');assert.equal(status.dataset.stale,'false');
 const a=track.children[0];assert.equal(a.title,'A title');assert.equal(a.dataset.next,'known');assert.equal(a.children[1].className,'work-next');assert.equal(a.tabIndex,0);
 view.update({cards:[card('B'),card('A',{stage:'x',next:'ended'})],status:'2件 · 活動の取得不調',stale:true});
 assert.deepEqual(track.children.map(n=>n.children[0].textContent),['B · s','A · s'],'order follows the model');assert.strictEqual(track.children[1],a,'node identity kept');
 assert.equal(a.dataset.stage,'x');assert.equal(a.dataset.next,'ended');assert.equal(status.dataset.stale,'true');assert.equal(status.textContent,'2件 · 活動の取得不調');
 active=a;track.scrollLeft=40;view.update({cards:[card('A'),card('B')],status:'2件',stale:false});
 assert.strictEqual(track.children[1],a,'a focused lane does not move cards');assert.equal(track.scrollLeft,40,'scroll kept');
 view.update({cards:[card('B')],status:'1件',stale:false});assert(track.children.includes(a),'a focused card is not removed');
 active=null;view.update({cards:[card('B')],status:'1件',stale:false});assert.deepEqual(track.children.map(n=>n.children[0].textContent),['B · s']);}
// The card view composes no text and reads no history: it only draws the model it is given.
{const src=slice('function createWorkLaneView(','function presenceStates(');
 for(const name of ['承認なし','Registry：','workLaneItems','workCardViewModel','取得不調','件','isStateNotice','confirmedStarts'])assert(!src.slice(0,src.indexOf('// OPS-141 member states')).includes(name),'the card view does not use '+name);}
console.log('PASS: OPS-153 work cards match the 73b623ea baseline ('+steps.length+' steps); card view-model contract cases; fixed view models -> DOM; the card view only draws.');
