// OPS-138: 待機完了 control (actual wakeOwners / wakeStatus / createWakeControl with a stub DOM). No browser, no server.
const fs=require('fs'),vm=require('vm'),assert=require('assert');
const html=fs.readFileSync(__dirname+'/index.template.html','utf8');
const a=html.indexOf('const WAKE_SENDER='),b=html.indexOf('async function sendWake(');assert(a>=0&&b>a);
const slice=(x,y)=>html.slice(html.indexOf(x),html.indexOf(y));
const opt=()=>({value:'',textContent:''});
const c={document:{createElement:opt}};vm.createContext(c);vm.runInContext(slice('const activityLabels=','function startActivityTimelines(')+'\n'+html.slice(a,b),c);
let seq=0;const ev=(owner,event,reason,extra={})=>{seq++;return {schemaVersion:1,id:seq.toString(16).padStart(32,'0'),taskId:'OPS-1',event,owner,reason,timestamp:new Date(Date.UTC(2026,9,19,1,0,seq)).toISOString().replace('.000Z','Z'),...extra};};
const rows=list=>c.validateActivityRows(list,'events');
const ID='WAKE-20261019-'+'A1B2C3D4'.repeat(4);
const base=[ev('姫','work','実装'),ev('Astra','request','依頼'),ev('ユーザー','request',ID+'：姫へ。ユーザーがStudioから待機完了（待機の終了）を依頼',{next:'姫'})];
assert.deepEqual([...c.wakeOwners(rows(base))],['Astra','姫'],'known owners, latest first, the user excluded');
assert.equal(c.wakeStatus(rows(base),'姫').kind,'pending');assert.equal(c.wakeStatus(rows(base),'Astra').kind,'none');
// near misses never answer it: other owner, prefix of the ID, ID with more characters, not at the start
for(const miss of [ev('Astra','work','ACK '+ID+'：代理'),ev('姫','work','ACK '+ID.slice(0,-1)+'：途中'),ev('姫','work','ACK '+ID+'X：長い'),ev('姫','work','了解 ACK '+ID)])
 assert.equal(c.wakeStatus(rows([...base,miss]),'姫').kind,'pending',miss.reason);
const answered=[...base,ev('姫','work','ACK '+ID+'：会話へ戻る',{presence:'ended'})];
assert.equal(c.wakeStatus(rows(answered),'姫').kind,'acked');
// an older answered request does not answer a newer one
const ID2='WAKE-20261019-'+'FFFF0000'.repeat(4);
assert.equal(c.wakeStatus(rows([...answered,ev('ユーザー','request',ID2+'：姫へ。…',{next:'姫'})]),'姫').kind,'pending');
// a WAKE from someone else (Astra's own relay) is not the user's request
assert.equal(c.wakeStatus(rows([ev('姫','work','x'),ev('Astra','request',ID2+'：姫へ。',{next:'姫'})]),'姫').kind,'none');
// the control
const select={options:[],value:'',handlers:{},add(o){this.options.push(o);},remove(i){this.options.splice(i,1);},addEventListener(t,f){this.handlers[t]=f;}};
const button={disabled:false,title:'',handlers:{},addEventListener(t,f){this.handlers[t]=f;}},status={textContent:'',dataset:{}};
let calls=[],reply=null;const send=owner=>{calls.push(owner);return new Promise((res,rej)=>reply={res,rej});};
const w=c.createWakeControl({select,button,status,send});const tick=()=>new Promise(r=>setImmediate(r));
(async()=>{
 w.rows(rows(base.slice(0,2)));assert.deepEqual(select.options.map(o=>o.value),['Astra','姫']);assert.equal(select.value,'Astra');assert.equal(button.disabled,false);assert.equal(status.textContent,'');
 select.value='姫';select.handlers.change();w.rows(rows(base.slice(0,2)));assert.equal(select.value,'姫','the user\'s choice is kept across polls');
 // double click: one request only; busy while sending
 button.handlers.click();button.handlers.click();assert.deepEqual(calls,['姫']);assert.equal(button.disabled,true);assert.equal(status.textContent,'送信中…');
 reply.res({created:true});await tick();assert.equal(status.textContent,'送信しました。記録の反映を待っています');
 w.rows(rows(base));assert.equal(button.disabled,true,'pending: cannot add more');assert(status.textContent.startsWith('依頼済み・ACK待ち'));assert(!/終了しました|起動/.test(status.textContent));
 w.rows(rows(answered));assert.equal(button.disabled,false);assert(status.textContent.startsWith('ACK済み'));
 // server returns the existing unanswered request
 button.handlers.click();reply.res({created:false});await tick();assert.equal(status.textContent,'未応答の依頼があります（同じ依頼を表示しています）');
 // failure and unknown result: shown, never resent automatically
 button.handlers.click();reply.rej(Error('Unknown owner'));await tick();assert.equal(status.textContent,'送信できませんでした：Unknown owner');assert.equal(button.disabled,false);
 const n=calls.length;button.handlers.click();const unknown=Error('timeout');unknown.unknown=true;reply.rej(unknown);await tick();
 assert(status.textContent.startsWith('結果が分かりません'));assert.equal(calls.length,n+1,'no automatic resend');
 // markup and request shape
 assert(html.includes('<button type="button" id="wake-send" disabled>待機完了</button><small>選んだ担当に待機終了を依頼</small>'));
 assert(html.includes("fetch('/activity-wake',{method:'POST',headers:{'X-Registry-Studio':'activity-wake','Content-Type':'application/json'},body:JSON.stringify({owner}),"),'the body names only the owner');
 const wa=html.slice(html.indexOf('<section id="workArea"'),html.indexOf('<div id="workspace"'));assert(wa.includes('id="wake-send"'),'in the work area');
 console.log('PASS: OPS-138 wake control (known owners, exact ACK by the owner, near misses ignored, one request per click, pending blocks, existing request, failure/unknown without resend).');
})().catch(e=>{console.error(e);process.exit(1);});
