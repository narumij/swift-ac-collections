// OPS-153 区切り3: the activity timeline with its current band, and the 待機完了 (WAKE) control. (a) Compatibility baseline:
// fixed, anonymized scenarios driven through createActivityView and createWakeControl, recorded step by step and compared with
// view-model-current-wake.baseline.json, captured from 73b623ea before the extraction (TZ=UTC, ja-JP, fixed times). It shows
// the output stayed the same, not that it is correct. (b) Contract cases of the pure view models and fixed view models -> DOM /
// operation intents. --write re-captures the baseline.
process.env.TZ='UTC';
const fs=require('fs'),vm=require('vm'),assert=require('assert');
const html=fs.readFileSync(process.env.STUDIO_TEMPLATE||__dirname+'/index.template.html','utf8');
const slice=(a,b)=>{const i=html.indexOf(a),j=html.indexOf(b);assert(i>=0&&j>i,'markers '+a);return html.slice(i,j);};
const c={document:{createElement:()=>({value:'',textContent:''})}};vm.createContext(c);
vm.runInContext('const __DTF=Intl.DateTimeFormat;Intl.DateTimeFormat=function(l,o){return new __DTF(l??"ja-JP",o);};',c);
vm.runInContext(slice('const activityLabels=','function startActivityTimelines(')+'\n'+slice('const WAKE_SENDER=','async function sendWake(')+'\n'+slice('// OPS-119 work lane','// OPS-114: this lane owns only approval DOM'),c);
const BASE=Date.UTC(2026,9,19,5,0,0);let seq=0;
const ev=(taskId,event,owner,reason='',extra={})=>{seq++;return {schemaVersion:1,id:seq.toString(16).padStart(32,'0'),taskId,event,owner,reason,timestamp:new Date(BASE+seq*1000).toISOString().replace('.000Z','Z'),...extra};};
const rows=list=>c.validateActivityRows(list,'events');
class Node{
 constructor(tag){this.tag=tag;this.children=[];this.dataset={};this.textContent='';this.title='';this.className='';this.parent=null;this._left=0;this.clientWidth=500;}
 get scrollWidth(){return this.children.length*266;}
 get scrollLeft(){return this._left;}set scrollLeft(v){this._left=Math.max(0,Math.min(v,this.scrollWidth-this.clientWidth));}
 appendChild(n){this.insertBefore(n,null);}
 insertBefore(n,before){if(n.parent)n.remove();n.parent=this;const i=before?this.children.indexOf(before):this.children.length;this.children.splice(i,0,n);}
 remove(){if(this.parent){const a=this.parent.children;a.splice(a.indexOf(this),1);this.parent=null;}}
 contains(n){return this.children.some(ch=>ch===n||ch.contains(n));}
 getBoundingClientRect(){const left=this.parent?this.parent.children.indexOf(this)*266-this.parent.scrollLeft:0;return {left,right:left+(this.parent?260:this.clientWidth)};}
}
function timelineScenario(){
 let active=null;const track=new Node('track'),status=new Node('status'),current={heading:new Node('h'),detail:new Node('d')};
 const view=c.createActivityView(track,status,t=>new Node(t),()=>active,current);
 const steps=[],snap=name=>steps.push({name,status:status.textContent,stale:status.dataset.stale||'',scroll:track.scrollLeft,
  current:[current.heading.textContent,current.heading.title,current.detail.textContent,current.detail.title],
  cards:track.children.map(n=>({text:n.children.map(x=>x.textContent),title:n.title,event:n.dataset.event,age:n.dataset.age,cls:n.className,tab:n.tabIndex}))});
 view.update(rows([]));snap('empty');
 const req=ev('T-1','request','調整','R-20261019-01：依頼',{next:'メンバーA'});
 let log=[ev('T-0','commit','調整','記録'),req,ev('T-1','work','メンバーA','R-20261019-01：着手',{presence:'working'})];
 view.update(rows(log));snap('a confirmed start is the current work');
 log=[...log,ev('T-1','work','メンバーA','待機',{presence:'waiting'}),ev('T-2','request','ユーザー','WAKE-20261019-Q：待機終了依頼',{next:'メンバーA'}),ev('T-2','work','メンバーA','ACK WAKE-20261019-Q：会話へ戻る',{presence:'ended'})];
 view.update(rows(log));snap('state notices and probes do not replace the current work');
 log=[...log,ev('T-3','return','メンバーB','返却',{next:'調整',presence:'waiting'})];
 track.scrollLeft=100;active=track.children[1];view.update(rows(log));snap('a return with a presence is current; focus inhibits follow');
 view.failure();snap('failure keeps the last band');
 active=null;view.update(rows(log.slice(2)));snap('recovery with a shorter window');
 return steps;
}
async function wakeScenario(){
 const select={options:[],value:'',handlers:{},add(o){this.options.push(o);},remove(i){this.options.splice(i,1);},addEventListener(t,f){this.handlers[t]=f;}};
 const button={disabled:false,title:'',handlers:{},addEventListener(t,f){this.handlers[t]=f;}},status={textContent:'',dataset:{},title:''};
 let reply=null;const sent=[];const w=c.createWakeControl({select,button,status,send:o=>{sent.push(o);return new Promise((res,rej)=>reply={res,rej});}});
 const tick=()=>new Promise(r=>setImmediate(r));
 const steps=[],snap=name=>steps.push({name,options:select.options.map(o=>o.value),value:select.value,disabled:button.disabled,buttonTitle:button.title,status:status.textContent,kind:status.dataset.kind,statusTitle:status.title,sent:[...sent]});
 const W='WAKE-20261019-'+'Q'.repeat(8);
 const base=[ev('T-1','work','メンバーA','実装'),ev('T-1','request','調整','依頼'),ev('T-1','work','ユーザー','メモ')];
 w.rows(rows(base));snap('owners latest first, user excluded, first selected');
 select.value='メンバーA';select.handlers.change();snap('the user chooses an owner');
 button.handlers.click();button.handlers.click();snap('busy: one send only');
 reply.res({created:true});await tick();snap('sent note');
 const withReq=[...base,ev('T-2','request','ユーザー',W+'：待機終了依頼',{next:'メンバーA'})];
 w.rows(rows(withReq));snap('pending: button disabled');
 w.rows(rows([...withReq,ev('T-2','work','メンバーA','ACK '+W+'：会話へ戻る',{presence:'ended'})]));snap('acked');
 button.handlers.click();reply.res({created:false});await tick();snap('server returns the unanswered request');
 select.value='調整';select.handlers.change();snap('changing the owner clears the note');
 select.value='メンバーA';select.handlers.change();snap('back to the first owner: the note stays cleared');
 button.handlers.click();reply.rej(Error('Unknown owner'));await tick();snap('send failure');
 button.handlers.click();const u=Error('timeout');u.unknown=true;reply.rej(u);await tick();snap('unknown result, no resend');
 w.rows(rows([ev('T-9','work','メンバーC','x')]));snap('owners change: the choice falls back to the first owner');
 return steps;
}
(async()=>{
 const steps={timeline:timelineScenario(),wake:await wakeScenario()},file=__dirname+'/view-model-current-wake.baseline.json';
 if(process.argv.includes('--write')){
  fs.writeFileSync(file,JSON.stringify({about:'OPS-153 区切り3 compatibility baseline of the activity timeline, its current band and the 待機完了 control. Captured from 73b623ea (before the extraction) with TZ=UTC, ja-JP and fixed times. It shows the output stayed the same; it is not a proof of correctness.',
   knownLimits:['derived from the latest 200 activity records only','an ACK only confirms receipt; the end of a wait is the member status','the server re-checks every WAKE request; the button state is not a permission'],steps},null,1)+'\n');
  console.log('baseline written: '+steps.timeline.length+'+'+steps.wake.length+' steps');return;
 }
 const base=JSON.parse(fs.readFileSync(file,'utf8'));
 for(const k of ['timeline','wake']){assert.equal(steps[k].length,base.steps[k].length,k+' step count');steps[k].forEach((s,i)=>assert.deepStrictEqual(s,base.steps[k][i],k+' baseline step '+i+': '+base.steps[k][i].name));}
 await contracts();
 console.log('PASS: OPS-153 timeline/current and WAKE match the 73b623ea baseline ('+steps.timeline.length+'+'+steps.wake.length+' steps)'+contracts.done);
})().catch(e=>{console.error(e);process.exit(1);});
async function contracts(){
 // (b) current band and timeline view model (listed cases, not exhaustive)
 const req=ev('T-8','request','調整','R-20261019-08：依頼',{next:'甲'}),start=ev('T-8','work','甲','R-20261019-08：着手',{presence:'working'});
 const wait=ev('T-8','work','甲','待機',{presence:'waiting'}),probe=ev('T-8','work','甲','ACK PING-20261019-A：受信');
 assert.equal(c.currentBandViewModel(rows([req,start,wait,probe])).heading,'現在：T-8 · 甲 · 作業','a confirmed start is current; a state notice and a probe are not');
 assert.equal(c.currentBandViewModel(rows([req,wait])).heading,'現在：T-8 · 調整 → 甲 · 依頼');
 assert.deepEqual(JSON.parse(JSON.stringify(c.currentBandViewModel(rows([wait,probe])))),{heading:'現在の作業：未登録',detail:'担当が更新する進行記録です。',title:''});
 const tv=c.activityTimelineViewModel(rows([req,start]));assert.deepEqual(tv.cards.map(x=>x.age),['older','latest']);assert.equal(tv.status,'');
 assert.equal(c.activityTimelineViewModel(rows([])).status,'記録なし');assert.equal(c.activityTimelineViewModel(rows([req]),false).current,null,'no band to show: not derived');
 // fixed view model -> timeline DOM
 {const track=new Node('track'),status=new Node('status'),cur={heading:new Node('h'),detail:new Node('d')},v=c.createActivityTimelineView(track,status,t=>new Node(t),()=>null,cur);
  v.show({cards:[{id:'a',heading:'H1',title:'T1',event:'request',age:'older'},{id:'b',heading:'H2',title:'T2',event:'return',age:'latest'}],current:{heading:'現在：X',detail:'D',title:'TT'},status:''});
  assert.deepEqual(track.children.map(n=>[n.children[0].textContent,n.title,n.dataset.event,n.dataset.age,n.className,n.tabIndex]),[['H1','T1','request','older','activity-card',0],['H2','T2','return','latest','activity-card',0]]);
  assert.deepEqual([cur.heading.textContent,cur.detail.textContent,cur.heading.title,cur.detail.title],['現在：X','D','TT','TT']);assert.equal(status.dataset.stale,'false');
  const b=track.children[1];v.show({cards:[{id:'b',heading:'H2',title:'T2',event:'return',age:'latest'}],current:{heading:'現在：Y',detail:'E',title:''},status:'記録なし?'});
  assert.strictEqual(track.children[0],b,'node identity kept');assert.equal(status.textContent,'記録なし?','status drawn as given');
  v.showFailure('F');assert.equal(status.textContent,'F');assert.equal(status.dataset.stale,'true');assert.equal(cur.heading.textContent,'現在：Y','failure keeps the band');}
 // WAKE view model
 const W='WAKE-20261019-'+'R'.repeat(8),wr=[ev('T-1','work','甲','x'),ev('T-1','work','乙','y'),ev('T-2','request','ユーザー',W+'：待機終了依頼',{next:'甲'})];
 assert.equal(c.wakeSelection(['乙','甲'],'甲'),'甲');assert.equal(c.wakeSelection(['乙','甲'],'丙'),'乙');assert.equal(c.wakeSelection([],'甲'),'');
 assert.equal(c.wakeKey(rows(wr),'甲'),'甲|pending|'+W);assert.equal(c.wakeKey(rows(wr),'乙'),'乙|none|');
 let m=c.wakeViewModel({rows:rows(wr),selected:'甲',busy:false,note:''});
 assert.deepEqual([...m.owners],['乙','甲']);assert.equal(m.disabled,true,'pending: disabled');assert.equal(m.kind,'pending');assert(m.text.startsWith('依頼済み・ACK待ち（'));assert(m.buttonTitle.includes(W));
 m=c.wakeViewModel({rows:rows(wr),selected:'乙',busy:false,note:'N'});assert.equal(m.disabled,false);assert.equal(m.text,'N','a note is shown as given');assert.equal(m.kind,'none');
 m=c.wakeViewModel({rows:rows(wr),selected:'乙',busy:true,note:'N'});assert.equal(m.disabled,true);assert.equal(m.text,'送信中…');assert.equal(m.kind,'busy');
 assert.equal(c.wakeViewModel({rows:rows([]),selected:'',busy:false,note:''}).disabled,true,'no owner: disabled');
 m=c.wakeViewModel({rows:rows([...wr,ev('T-2','work','甲','ACK '+W+'：会話へ戻る',{presence:'ended'})]),selected:'甲',busy:false,note:''});assert.equal(m.kind,'acked');assert(m.statusTitle.includes('受け取った確認'),'an ACK is receipt, the end of a wait is the member status');
 // fixed view model -> WAKE DOM and operation intents
 {const select={options:[],value:'',handlers:{},add(o){this.options.push(o);},remove(i){this.options.splice(i,1);},addEventListener(t,f){this.handlers[t]=f;}};
  const button={disabled:false,title:'',handlers:{},addEventListener(t,f){this.handlers[t]=f;}},status={textContent:'',dataset:{},title:''};const intents=[];
  const v=c.createWakeView({select,button,status,onChange:()=>intents.push('change'),onClick:()=>intents.push('click')});
  v.show({owners:['乙','甲'],selected:'甲',disabled:true,buttonTitle:'BT',text:'S',kind:'pending',statusTitle:'ST'});
  assert.deepEqual([select.options.map(o=>o.value),select.value,button.disabled,button.title,status.textContent,status.dataset.kind,status.title],[['乙','甲'],'甲',true,'BT','S','pending','ST']);
  const opts=select.options;v.show({owners:['乙','甲'],selected:'乙',disabled:false,buttonTitle:'',text:'',kind:'none',statusTitle:''});
  assert.strictEqual(select.options,opts);assert.equal(opts.length,2,'options are not rebuilt for the same list');assert.equal(select.value,'乙');assert.equal(button.disabled,false);
  select.handlers.change();button.handlers.click();assert.deepEqual(intents,['change','click'],'the view only reports the operation intents');assert.equal(v.selected(),'乙');}
 // The views read no history and compose no text.
 {const tsrc=slice('function createActivityTimelineView(','function createActivityView(');for(const n of ['confirmedStarts','isStateNotice','isProbeEvent','現在','記録なし','取得不調'])assert(!tsrc.includes(n),'the timeline view does not use '+n);
  const wsrc=slice('function createWakeView(','function createWakeControl(');for(const n of ['wakeStatus','wakeOwners','wakeKey','送信中','ACK','依頼済み'])assert(!wsrc.includes(n),'the WAKE view does not use '+n);}
 contracts.done='; timeline/current and WAKE view-model contract cases; fixed view models -> DOM and operation intents; the views only draw.';
}
