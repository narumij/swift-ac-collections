// OPS-151: 開始待ち (a request with a leading ID shown for its recipient until the recipient's own matching record) and the
// confirmed-start exception in the lanes. Isolated tests of the actual code; no browser or server.
const fs=require('fs'),vm=require('vm'),assert=require('assert');
const html=fs.readFileSync(__dirname+'/index.template.html','utf8');
const slice=(a,b)=>{const i=html.indexOf(a),j=html.indexOf(b);assert(i>=0&&j>i,'markers '+a);return html.slice(i,j);};
const c={};vm.createContext(c);
vm.runInContext(slice('const activityLabels=','function startActivityTimelines(')+'\n'+slice('// OPS-119 work lane','// OPS-114: this lane owns only approval DOM'),c);
let seq=0;
const ev=(taskId,event,owner,reason='',extra={})=>{seq++;return {schemaVersion:1,id:seq.toString(16).padStart(32,'0'),taskId,event,owner,reason,timestamp:new Date(Date.UTC(2026,9,19,2,0,seq)).toISOString().replace('.000Z','Z'),...extra};};
const rows=list=>c.validateActivityRows(list,'events');
const pend=list=>{const m=c.startPendings(rows(list)),o={};for(const [k,v] of m)o[k]=[...v.entries.values()].map(e=>e.id+(e.unmatched?'?':''));return o;};
const lane=list=>new Map(c.workLaneItems(rows(list),[]).map(i=>[i.taskId,i]));

// One parser: full-ID boundary; connectivity and update IDs are not requests; the ID must be at the very start.
assert.equal(c.leadingRequestId('D-20261019-02：評価'),'D-20261019-02');
assert.equal(c.leadingRequestId('H-20261019-05着手：…'),'H-20261019-05','a Japanese character ends the ID');
assert.equal(c.leadingRequestId('D-20261019-020：x'),'D-20261019-020','02 and 020 are different IDs');
for(const r of ['WAKE-20261019-M：待機終了依頼','UPDATE-20261019-L：現在地','PING-20261019-A：疎通','ACK WAKE-20261019-M：会話へ戻る','依頼 D-20261019-02','D-2026101-02：桁違い',''])
 assert.equal(c.leadingRequestId(r),'',r);

// Old ended -> request -> 開始待ち; the same ID's own working joins it (closes); state is never written for the member.
const oldEnded=ev('OPS-50','work','評価役','待機を終える',{presence:'ended'});
const req=ev('OPS-50','request','Astra','D-20261019-02：評価',{next:'評価役'});
assert.deepEqual(pend([oldEnded,req]),{'評価役':['D-20261019-02']});
assert.equal(c.presenceStates(rows([oldEnded,req])).get('評価役').state,'ended','the declared state is not changed');
const start=ev('OPS-50','work','評価役','D-20261019-02：照合に着手',{presence:'working'});
assert.deepEqual(pend([oldEnded,req,start]),{},'own working with the same ID and task closes it');
// A return or an ended with the same ID also closes it.
assert.deepEqual(pend([req,ev('OPS-50','return','評価役','D-20261019-02返却',{next:'Astra'})]),{});
assert.deepEqual(pend([req,ev('OPS-50','work','評価役','D-20261019-02：対象外で終える',{presence:'ended'})]),{});
// H-20261019-07: a waiting with the same ID and task does not close it (nor mark it unanswered) and is not a start.
{const wait=ev('OPS-50','work','評価役','D-20261019-02：受信、待機',{presence:'waiting'});
 assert.deepEqual(pend([req,wait]),{'評価役':['D-20261019-02']},'same-ID waiting alone leaves it open');
 assert.equal(lane([req,wait]).get('OPS-50').stage,'依頼済み','same-ID waiting is not a start');
 assert.deepEqual(pend([req,wait,start]),{},'the later same-ID working still closes it');}

// Without the ID, with another ID, or another task: never closes; marked 対応未確認. An old WAKE ACK does not join.
assert.deepEqual(pend([req,ev('OPS-50','work','評価役','着手',{presence:'working'})]),{'評価役':['D-20261019-02?']});
assert.deepEqual(pend([req,ev('OPS-50','work','評価役','D-20261019-020：別件',{presence:'working'})]),{'評価役':['D-20261019-02?']},'02 is not closed by 020');
assert.deepEqual(pend([req,ev('OPS-51','work','評価役','D-20261019-02：別task',{presence:'working'})]),{'評価役':['D-20261019-02?']},'the task must match');
assert.deepEqual(pend([req,ev('OPS-50','work','評価役','ACK WAKE-20261019-K：会話へ戻る',{presence:'ended'})]),{'評価役':['D-20261019-02?']},'an old WAKE ACK with ended does not close it');
// Practical records without a presence do not mark it unanswered; another member's matching record does not close it.
assert.deepEqual(pend([req,ev('OPS-50','verification','評価役','途中メモ')]),{'評価役':['D-20261019-02']});
assert.deepEqual(pend([req,ev('OPS-50','work','姫','D-20261019-02：代わりに',{presence:'working'})]),{'評価役':['D-20261019-02']},'only the recipient closes it');

// Not a start request: WAKE / UPDATE / PING, no leading ID, no or special recipient, self-addressed.
assert.deepEqual(pend([
 ev('OPS-52','request','Astra','WAKE-20261019-M：待機終了依頼',{next:'姫'}),ev('OPS-52','request','Astra','UPDATE-20261019-L：現在地',{next:'姫'}),
 ev('OPS-52','request','Astra','PING-20261019-A：疎通',{next:'姫'}),ev('OPS-52','request','Astra','相談だけ',{next:'姫'}),
 ev('OPS-52','request','Astra','H-20261019-09：宛先なし'),ev('OPS-52','request','Astra','H-20261019-09：x',{next:'none'}),
 ev('OPS-52','request','Astra','H-20261019-09：x',{next:'user'}),ev('OPS-52','request','Astra','H-20261019-09：x',{next:'Astra'})]),{});

// A waiting/working member with a new request: the declared state is kept and nothing is removed by an ID mismatch.
{const w=ev('OPS-53','work','姫','待機',{presence:'waiting'}),r1=ev('OPS-53','request','Astra','H-20261019-07：依頼',{next:'姫'});
 assert.equal(c.presenceStates(rows([w,r1])).get('姫').state,'waiting');assert.deepEqual(pend([w,r1]),{'姫':['H-20261019-07']});
 const r2=ev('OPS-53','request','Astra','H-20261019-08：次',{next:'姫'});
 assert.deepEqual(pend([w,r1,r2,ev('OPS-53','return','姫','H-20261019-08返却',{next:'Astra',presence:'waiting'})]),{'姫':['H-20261019-07']},'closing 08 leaves 07 open; an answer that names another ID is not an unmatched declaration');
 // The same ID requested again (an added input) is one entry, renewed; one matching return closes it.
 assert.deepEqual(pend([w,r1,ev('OPS-53','request','Astra','H-20261019-07追加入力',{next:'姫'}),ev('OPS-53','return','姫','H-20261019-07返却',{next:'Astra'})]),{});}

// Lamp text: a new recipient without any own record is shown and told apart from 未申告 alone; 対応未確認 is labelled.
class Node{constructor(t){this.tag=t;this.children=[];this.dataset={};this.textContent='';this.className='';this.parent=null;}appendChild(n){if(n.parent)n.remove();n.parent=this;this.children.push(n);}remove(){if(this.parent){this.parent.children.splice(this.parent.children.indexOf(this),1);this.parent=null;}}}
{const box=new Node('box'),lv=c.createPresenceLamps({box,makeNode:t=>new Node(t),schedule:()=>{}});
 lv.update(rows([ev('OPS-54','request','Astra','D-20261019-03：初回',{next:'新評価役'})]));
 const t=box.children.map(n=>n.textContent).find(x=>x.startsWith('新評価役：'));assert(t,'a recipient with no own record is listed');
 assert(t.includes('新評価役：未申告'),t);assert(t.includes('開始待ち D-20261019-03（Astra ')&&t.includes('・本人記録なし'),t);
 assert.equal(box.children.find(n=>n.textContent.startsWith('新評価役：')).dataset.pending,'true');
 lv.update(rows([oldEnded,req,ev('OPS-50','work','評価役','着手',{presence:'working'})]));
 const u=box.children.map(n=>n.textContent).find(x=>x.startsWith('評価役：'));assert(u.startsWith('評価役：作業中')&&u.includes('開始待ち D-20261019-02')&&u.includes('・対応未確認')&&!u.includes('本人記録なし'),u);
 lv.update(rows([oldEnded,req,start]));const v=box.children.find(n=>n.textContent.startsWith('評価役：'));
 assert(!v.textContent.includes('開始待ち'),'closed by the matching start');assert.equal(v.dataset.pending,undefined);
 // More than three open requests: three lines and the rest counted, never silently dropped.
 lv.update(rows([1,2,3,4,5].map(i=>ev('OPS-55','request','Astra','H-20261019-1'+i+'：x',{next:'姫'}))));
 const x=box.children.find(n=>n.textContent.startsWith('姫：')).textContent;assert.equal((x.match(/開始待ち H-/g)||[]).length,3);assert(x.includes('ほか2件の開始待ち'),x);}

// Lanes: a confirmed start (working + same ID + same task + addressed to this owner) shows as 着手; state notices do not.
assert.equal(lane([req,start]).get('OPS-50').stage,'着手');
assert.equal(lane([req,start]).get('OPS-50').owner,'評価役');
assert.equal(lane([req,ev('OPS-50','work','評価役','着手',{presence:'working'})]).get('OPS-50').stage,'依頼済み','working without the ID is a state notice');
assert.equal(lane([req,ev('OPS-50','work','姫','D-20261019-02：横から',{presence:'working'})]).get('OPS-50').stage,'依頼済み','another member is not the recipient');
assert.equal(lane([req,ev('OPS-50','work','評価役','D-20261019-02：待機',{presence:'waiting'})]).get('OPS-50').stage,'依頼済み','waiting/ended stay state notices');
assert.equal(lane([ev('OPS-56','work','評価役','D-20261019-04：依頼なし',{presence:'working'})]).has('OPS-56'),false,'no earlier request: not a start');
assert.equal(c.presenceStates(rows([req,start])).get('評価役').last.label,'作業','a confirmed start is also the last activity');
console.log('PASS: OPS-151 start-pending (one ID parser, same ID+task+recipient closes, no-ID/other-ID/old ACK only marks 対応未確認, non-requests ignored, declared state kept, lamp text and count) and confirmed starts in the lanes.');
