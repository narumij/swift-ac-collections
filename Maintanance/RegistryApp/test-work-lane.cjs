// OPS-119: isolated tests of the actual work-lane code (pure derivation and DOM view); no live browser or server.
const fs=require('fs'),vm=require('vm'),assert=require('assert');
const html=fs.readFileSync(__dirname+'/index.template.html','utf8');
const slice=(from,to)=>{const a=html.indexOf(from),b=html.indexOf(to);assert(a>=0&&b>a,'source markers: '+from);return html.slice(a,b);};
const c={};vm.createContext(c);
vm.runInContext(slice('const activityLabels=','function startActivityTimelines(')+'\n'+slice('// OPS-119 work lane','// OPS-114: this lane owns only approval DOM'),c);

let seq=0;
const ev=(taskId,event,reason='',owner='姫')=>{seq++;return {schemaVersion:1,id:seq.toString(16).padStart(32,'0'),taskId,event,owner,reason,timestamp:new Date(Date.UTC(2026,9,18,7,0,seq)).toISOString().replace('.000Z','Z')};};
const rows=list=>c.validateActivityRows(list,'events');
const appr=(id,taskId,status)=>({id,revision:1,taskId,title:'t',scope:'s',paths:['a'],condition:'c',branch:'b',status,createdAt:'x',updatedAt:'x'});
const items=(events,approvals=[],states={})=>c.workLaneItems(rows(events),approvals,id=>states[id]);
const one=(events,...rest)=>items(events,...rest)[0];

// 1. State transitions follow the latest practical event of the task.
const flow=['request','work','verification','return','recheck','acceptance','complete','awaiting-commit','commit'];
const expected=['依頼済み','作業中','確認中','返却・受入待ち','再確認中','受入済み','作業区切り','コミット待ち','記録コミット済み'];
const history=[];flow.forEach((kind,i)=>{history.push(ev('OPS-200',kind));assert.equal(one(history).stage,expected[i],kind);});
assert.equal(items(history).length,1,'recheck does not open another card');
// complete followed by awaiting-commit (current practice) is a commit wait, not a finished state.
assert.equal(one([ev('OPS-201','complete'),ev('OPS-201','awaiting-commit')]).stage,'コミット待ち');
assert.equal(one([ev('OPS-202','work','相談待ち：正本の姫 Returnを確認してください')]).stage,'相談待ち');

// 2. Old or missing start: work without a visible request is still 作業中, not 検討中; the start is reported as unknown.
const old=one([ev('OPS-203','work','着手')]);
assert.equal(old.stage,'作業中');assert.equal(old.start,'開始：不明');assert.equal(old.startNote,'開始：不明（記録範囲外または未記録）','the detail keeps why the start is unknown');
assert(one([ev('OPS-204','request'),ev('OPS-204','work')]).start.startsWith('依頼 '));

// 3. Approvals are counted per task, never assigned to a request; approval-only tasks are kept.
const onlyApproval=items([],[appr('a1','OPS-205','pending')])[0];
assert.equal(onlyApproval.stage,'活動情報なし');assert.deepEqual({...onlyApproval.approvals},{pending:1,approved:0,claimed:0});
const many=items([ev('OPS-206','work')],[appr('b1','OPS-206','pending'),appr('b2','OPS-206','pending'),appr('b3','OPS-206','approved'),appr('b4','OPS-206','claimed'),appr('b5','OPS-206','consumed'),appr('b6','OPS-206','cancelled')])[0];
assert.deepEqual({...many.approvals},{pending:2,approved:1,claimed:1},'consumed/cancelled stay in the approval history only');
assert.equal(many.stage,'作業中','approvals do not change the work stage');

// 4. Probes (dedicated notation) are excluded from the stage; ordinary mentions of PING are not.
// Actual probe reasons from 2026-10-18 (sends and replies).
for(const reason of ['疎通専用 PING-20261018-A：activityを自動確認した姫は同じIDを含むACKをworkイベントで1回だけ返してください。','疎通専用 PING-20261018-B：待機中の姫はこの合図を読んだら、同じIDを含むACKを','連続疎通1/3 PING-20261018-C1：姫は同じIDを含むACKをworkイベントで一度だけ返してください。','ユーザーから姫への呼びかけ WAKE-20261018-D：待機中ならACKを同じID付きで一度だけ','ACK PING-20261018-B（PING-20261018-Aも受信）：会話内の5秒間隔待機で検出。','ACK PING-20261018-C1：連続待機中に検出（16:04:31）。','ACK WAKE-20261018-D：連続待機中に検出（16:11:06）。'])assert(c.isProbeEvent(reason),'probe: '+reason);
for(const reason of ['PING-20261018-Aの判定不具合を修正','疎通ID PING-20261018-A の扱いを整理','PINGの仕組みを説明','OPS-117 PING応答の規則をレビュー','WAKE-UP手順を確認','XPING-20261018-A：は別名','ACKNOWLEDGE の表記を検討','ACK の表記を決める',''])assert(!c.isProbeEvent(reason),'not a probe: '+reason);
assert.equal(one([ev('OPS-209','work','PING-20261018-Aの判定不具合を修正')]).stage,'作業中','a practical event mentioning a probe ID is kept');
assert.equal(one([ev('OPS-114','commit'),ev('OPS-114','verification','疎通専用 PING-20261018-A：ACKを返してください','Astra')]).stage,'記録コミット済み','a probe after commit does not reopen the task');
assert.equal(one([ev('OPS-207','work','PINGの仕組みを説明')]).stage,'作業中','a practical event mentioning PING is kept');
assert.equal(items([ev('OPS-208','verification','疎通専用 PING-20261018-Z：ACKを返してください')]).length,0,'a task with only probes has no card');

// 5. RBT-026 regression: WAITING_USER in the Registry plus a record commit stays separate, never DONE.
const rbt=one([ev('RBT-026','work','準備','Astra'),ev('RBT-026','request','依頼','Astra'),ev('RBT-026','request','追加','Astra'),ev('RBT-026','work'),ev('RBT-026','return'),ev('RBT-026','acceptance','受入','Astra'),ev('RBT-026','commit','記録','Astra')],[],{'RBT-026':'WAITING_USER'});
assert.equal(rbt.stage,'記録コミット済み');assert.equal(rbt.registryState,'WAITING_USER');
assert.equal(items([ev('RBT-026','request'),ev('RBT-026','request')]).length,1,'repeated requests share one card');

// 6. Newest activity first.
assert.deepEqual(items([ev('OPS-301','work'),ev('OPS-302','work'),ev('OPS-301','return')]).map(i=>i.taskId),['OPS-301','OPS-302']);

// 7. DOM view: local update, node identity, scroll and focus are kept; failures keep the last cards.
class Node{
 constructor(tag){this.tag=tag;this.children=[];this.dataset={};this.textContent='';this.title='';this.parent=null;this.scrollLeft=0;this.moves=0;}
 appendChild(n){this.insertBefore(n,null);}
 insertBefore(n,before){if(n.parent)n.remove();n.parent=this;const i=before?this.children.indexOf(before):this.children.length;this.children.splice(i,0,n);this.moves++;}
 remove(){if(this.parent){const a=this.parent.children;a.splice(a.indexOf(this),1);this.parent=null;}}
 contains(n){return n===this||this.children.some(child=>child.contains(n));}
}
let active=null;const track=new Node('track'),status=new Node('status');
const view=c.createWorkLaneView({track,status,makeNode:t=>new Node(t),getActive:()=>active});
const lane=c.createWorkLane({view,registryState:id=>({'OPS-401':'ACTIVE'})[id]});
lane.activity(rows([ev('OPS-401','work','着手'),ev('OPS-402','request')]));
assert.equal(track.children.length,2);assert.equal(track.children[0].children[0].textContent,'OPS-402 · 依頼済み');
assert(track.children[1].children[1].textContent==='次：不明'&&track.children[1].children[3].textContent.startsWith('Registry：ACTIVE'),'OPS-127/132: next on its own line, unknown when not recorded');assert.equal(status.textContent,'2件');
const card401=track.children[1];track.scrollLeft=77;active=card401;
lane.activity(rows([ev('OPS-402','request'),ev('OPS-401','return')].slice(0,1).concat([ev('OPS-401','return')])));
assert.strictEqual(track.children[1],card401,'a focused card is not moved');assert.equal(card401.children[0].textContent,'OPS-401 · 返却・受入待ち');assert.equal(track.scrollLeft,77);
active=null;
lane.approvals([appr('c1','OPS-401','pending')]);
assert(card401.children[3].textContent.includes('承認 待ち1'),'approval badge');assert(card401.children[1].textContent.startsWith('次：ユーザー（承認待ち）'),'OPS-127: a pending approval comes first');assert.equal(card401.dataset.next,'approval');assert.equal(card401.children[0].textContent,'OPS-401 · 返却・受入待ち','approval does not change the stage');
lane.activityFailure();assert.equal(track.children.length,2,'last cards kept');assert.equal(status.dataset.stale,'true');assert(status.textContent.includes('活動の取得不調'));
lane.approvalFailure();assert(status.textContent.includes('承認の取得不調'));
lane.activity(rows([ev('OPS-401','return')]));assert(!status.textContent.includes('活動の取得不調'));assert(status.textContent.includes('承認の取得不調'));
assert(card401.children[2].textContent.includes('姫'),'owner shown as text');
assert.equal(card401.children[4].textContent,'開始：不明');assert(card401.title.includes('開始：不明（記録範囲外または未記録）'),'unknown start explained in the card title');

// 8. Wiring: the lane is fed by the existing pollers only, and the template keeps the approval controls.
assert(html.includes("const view={update(rows){workLaneInstance().activity(rows);},failure(){workLaneInstance().activityFailure();}}"),'OPS-138/153: the one poller feeds the shared studio');
assert(/wake:createWakeView\(\{select,button:\$\('wake-send'\)/.test(html),'OPS-153: the wake control is a view of the same studio');
assert(html.includes('workLaneInstance().approvals(value.requests)'));
// One approval UI, inside the work lane: counts and the all-approve entry stay visible; cards and history are always visible.
const laneStart=html.indexOf('<section class="approval-lane work-lane"'),laneEnd=html.indexOf('</section>',laneStart),laneHtml=html.slice(laneStart,laneEnd);
const details=laneHtml.slice(laneHtml.indexOf('<div id="approval-details">'),laneHtml.indexOf('<details id="work-lane-help">'));
for(const id of ['approval-status','approval-all','approval-policy','approval-track','approval-history','approval-history-summary'])assert.equal(html.split('id="'+id+'"').length,2,'exactly one '+id);
for(const id of ['approval-status','approval-all'])assert(laneHtml.includes('id="'+id+'"')&&!details.includes('id="'+id+'"'),id+' visible in the lane heading');
for(const id of ['approval-track','approval-history','approval-policy'])assert(details.includes('id="'+id+'"'),id+' visible in the lane');
assert(!details.includes('<details'),'approval details and history are not collapsible');
assert(!html.includes('<section class="approval-lane" aria-label="コミット事前承認"'),'no separate approval lane; header mirror is allowed');
assert(!/work-lane[^]*?approve/.test(slice('// OPS-119 work lane','// OPS-114: this lane owns only approval DOM')),'the lane has no approve action');
console.log('PASS: OPS-119 work lane (transitions, unknown start, per-task approvals, probe exclusion +/-, RBT-026, ordering, local DOM update, focus/scroll, failure kept, wiring).');
