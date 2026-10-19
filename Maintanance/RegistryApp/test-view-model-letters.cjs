// OPS-156 H-20261019-32: letters, read only, in the shared studio. (a) Fixed snapshots -> view model: rows, filters,
// flags (receipt revision vs latest, stop request, proxy records), detail only for the chosen letter, stale answers ignored,
// last good detail kept only for the same letter. (b) Fixed view models -> DOM: textContent only (HTML and CRLF kept as
// text), keyed rows, intents. (c) Distribution: the letters view gets the same revision as the others; GET-only pollers.
process.env.TZ='UTC';
const fs=require('fs'),vm=require('vm'),assert=require('assert');
const html=fs.readFileSync(process.env.STUDIO_TEMPLATE||__dirname+'/index.template.html','utf8');
const slice=(a,b)=>{const i=html.indexOf(a),j=html.indexOf(b);assert(i>=0&&j>i,'markers '+a);return html.slice(i,j);};
const c={document:{createElement:()=>({value:'',textContent:''})}};vm.createContext(c);
vm.runInContext(slice('const activityLabels=','function startActivityTimelines(')+'\n'+slice('const WAKE_SENDER=','async function sendWake(')+'\n'+slice('// OPS-119 work lane','// OPS-114: this lane owns only approval DOM'),c);
const L=(n,extra={})=>({id:'LTR-20261019-'+String(n).repeat(32).slice(0,32),kind:'request',sender:'Astra',recipient:'姫',taskId:'OPS-156',sentAt:'2026-10-19T05:00:00Z',state:'sent',stateLabel:'未受領',
 requestRevision:1,replyRevision:null,requestRevisionAtReceipt:null,revisedAfterReceipt:false,stopRequested:false,stopReason:null,proxyRecords:0,lastEventAt:'2026-10-19T05:00:00Z',...extra});
const D=(brief,extra={})=>({...brief,request:{revision:brief.requestRevision},reply:null,texts:[{part:'request',revision:1,body:'<img src=x onerror=alert(1)>\r\n本文\r\n',reason:'',ref_doc:null,ref_section:null,recorded_by:'Astra',received_at:'2026-10-19T05:00:00.000000Z'}],
 events:[{event:'sent',actor:'Astra',recorded_by:'Astra',effective:true,note:'',claimed_at:null,received_at:'2026-10-19T05:00:00.000000Z'}],...extra});
const apply=(s,x)=>c.applyStudioInput(s,x);
const parts=['letters'];
// (a) view model
{let s=c.emptyStudioSnapshot(parts);
 let v=c.lettersViewModel(s);assert.equal(v.status,'読み込み待ち');assert.equal(v.rows.length,0);assert(v.hint.includes('一覧から'));assert.equal(v.detail,null);
 const a=L(1),b=L(2,{recipient:'Fable',state:'withdrawn',stateLabel:'停止要請',stopRequested:true,stopReason:'優先の変更',proxyRecords:1}),r=L(3,{state:'received',stateLabel:'受領',requestRevision:2,requestRevisionAtReceipt:1,revisedAfterReceipt:true});
 s=apply(s,{source:'letters',ok:true,value:{letters:[a,b,r],hasMore:false,nextCursor:null},forKey:c.letterListKey(s.ui)});v=c.lettersViewModel(s);
 assert.equal(v.status,'最新のページ：3件（新しい順） · これより古い連絡はなし','a page, never presented as the whole history');
 assert.deepEqual(JSON.parse(JSON.stringify(v.paging)),{canOlder:false,olderCursor:null,canLatest:false});assert.deepEqual(v.rows.map(x=>x.id),[a.id,b.id,r.id]);
 assert(v.rows[0].text.startsWith('OPS-156 · Astra → 姫 · 未受領\nLTR-20261019-1111111'),v.rows[0].text);assert.equal(v.rows[0].title,a.id,'the full ID is the title');
 assert(v.rows[1].text.includes('停止要請：優先の変更')&&v.rows[1].text.includes('代理の記録 1件（状態は変えていない）'));
 assert(v.rows[2].text.includes('受領した版 v1／最新 v2（受領のあとに改訂あり）'));
 assert.deepEqual([...v.members.map(m=>m[0])],['','Astra','Fable','姫']);
 // H-20261019-34: filters are applied by the server; the view model shows the page it was given
 s=apply(s,{source:'letters-ui',patch:{letterMember:'Fable',letterCursor:null}});
 assert.strictEqual(apply(s,{source:'letters',ok:true,value:{letters:[a,b,r],hasMore:false},forKey:JSON.stringify([null,'','',])}),s,'an answer for the previous filter is ignored');
 s=apply(s,{source:'letters',ok:true,value:{letters:[b],hasMore:true,nextCursor:'r7'},forKey:c.letterListKey(s.ui)});v=c.lettersViewModel(s);
 assert.deepEqual(v.rows.map(x=>x.id),[b.id]);assert.equal(v.status,'最新のページ：1件（新しい順） · さらに古い連絡あり · 絞り込み（サーバー側）');
 assert.deepEqual(JSON.parse(JSON.stringify(v.paging)),{canOlder:true,olderCursor:'r7',canLatest:false});assert(v.members.some(m=>m[0]==='Fable'));
 assert.equal(c.letterListQuery(s.ui),'/letters?brief=1&limit=50&member=Fable');
 s=apply(s,{source:'letters-ui',patch:{letterCursor:'r7'}});assert.equal(c.letterListQuery(s.ui),'/letters?brief=1&limit=50&cursor=r7&member=Fable');
 s=apply(s,{source:'letters',ok:true,value:{letters:[r],hasMore:false,nextCursor:null,cursor:'r7'},forKey:c.letterListKey(s.ui)});v=c.lettersViewModel(s);
 assert(v.status.startsWith('より古いページ：1件'));assert.equal(v.paging.canLatest,true);
 s=apply(s,{source:'letters',ok:true,value:{letters:[r],hasMore:false},forKey:c.letterListKey(s.ui)});assert.equal(s.ui.letterCursor,'r7','polling the page shown does not jump to the newest');
 s=apply(s,{source:'letters-ui',patch:{letterMember:'',letterState:'',letterCursor:null}});
 s=apply(s,{source:'letters',ok:true,value:{letters:[a,b,r],hasMore:false,nextCursor:null},forKey:c.letterListKey(s.ui)});
 // detail only for the chosen letter; an answer for another letter is ignored (same snapshot, no redraw)
 s=apply(s,{source:'letters-ui',patch:{letterSelected:a.id}});v=c.lettersViewModel(s);assert.equal(v.detail.status,'本文を読み込み中');assert.equal(v.detail.body,null);assert(v.rows[0].selected);
 const before=s;assert.strictEqual(apply(s,{source:'letterDetail',ok:true,value:D(b),forId:b.id}),before,'a stale answer for another letter is ignored');
 assert.strictEqual(apply(s,{source:'letterDetail',ok:false,forId:b.id}),before,'and so is a stale failure');
 s=apply(s,{source:'letterDetail',ok:true,value:D(a),forId:a.id});v=c.lettersViewModel(s);
 assert.equal(v.detail.status,'');assert.equal(v.detail.body.heading,'OPS-156 · Astra → 姫 · 未受領');assert.equal(v.detail.body.texts[0].body,'<img src=x onerror=alert(1)>\r\n本文\r\n','the original text as it is');
 assert.equal(v.detail.body.receipt,'まだ受領していない（最新 v1）');
 // failure keeps the last good detail for the same letter only
 s=apply(s,{source:'letterDetail',ok:false,forId:a.id});v=c.lettersViewModel(s);assert.equal(v.detail.status,'本文の取得不調 · 最後に読めた内容');assert(v.detail.body);
 s=apply(s,{source:'letters-ui',patch:{letterSelected:r.id}});v=c.lettersViewModel(s);assert.equal(v.detail.body,null,'the old letter\'s text is not shown for the new choice');assert.equal(v.detail.status,'本文の取得不調');
 // proxy events and stop states in the detail
 const det=D(b,{events:[{event:'sent',actor:'Astra',recorded_by:'Astra',effective:true,note:'',claimed_at:null,received_at:'2026-10-19T05:00:00Z'},
  {event:'withdrawn',actor:'Astra',recorded_by:'Astra',effective:true,note:'優先の変更',claimed_at:null,received_at:'2026-10-19T05:01:00Z'},
  {event:'stopped',actor:'Fable',recorded_by:'Astra調整',effective:false,note:'止まっているはず',claimed_at:'2026-10-19T14:00:00+09:00',received_at:'2026-10-19T05:02:00Z'}]});
 s=apply(s,{source:'letters-ui',patch:{letterSelected:b.id}});s=apply(s,{source:'letterDetail',ok:true,value:det,forId:b.id});v=c.lettersViewModel(s);
 assert(v.detail.body.stop.startsWith('停止要請中')&&v.detail.body.stop.includes('占有の解除でもありません'));
 const ev=v.detail.body.events;assert.equal(ev[2].proxy,true);assert(ev[2].text.startsWith('停止の応答 — Fable（代理の記録：記録者 Astra調整。状態は変わらない）'));assert(ev[2].meta.includes('本人の申告 2026-10-19T14:00:00+09:00'));
 s=apply(s,{source:'letterDetail',ok:true,value:{...det,state:'stopped',stateLabel:'停止済み（本人の応答）'},forId:b.id});assert.equal(c.lettersViewModel(s).detail.body.stop,'停止済み（宛先の本人の応答）');
 // the list failing keeps the last rows and says so
 s=apply(s,{source:'letters',ok:false,forKey:c.letterListKey(s.ui)});v=c.lettersViewModel(s);assert.equal(v.status,'一覧の取得不調 · 最後に読めた内容');assert.equal(v.rows.length,3);
 // choice and filters survive polling
 s=apply(s,{source:'letters-ui',patch:{letterMember:'Fable'}});s=apply(s,{source:'letters',ok:true,value:{letters:[b],hasMore:false},forKey:c.letterListKey(s.ui)});assert.equal(s.ui.letterSelected,b.id);assert.equal(s.ui.letterMember,'Fable');}
// H-20261019-35: filter A read → change to B → B pending / failing: the A page and its cursor are not offered as B's →
// B read → paging from B. A failure under the same key still keeps the last good page.
{let s=c.emptyStudioSnapshot(parts);const key=()=>c.letterListKey(s.ui);
 s=apply(s,{source:'letters-ui',patch:{letterMember:'A',letterCursor:null}});
 s=apply(s,{source:'letters',ok:true,value:{letters:[L(1),L(2)],hasMore:true,nextCursor:'rA'},forKey:key()});
 let v=c.lettersViewModel(s);assert.equal(v.paging.olderCursor,'rA');assert.equal(v.rows.length,2);
 s=apply(s,{source:'letters-ui',patch:{letterMember:'B',letterCursor:null}});v=c.lettersViewModel(s);
 assert.equal(v.status,'この条件で読み込み中');assert.equal(v.rows.length,0,'the A rows are not called the result of B');
 assert.deepEqual(JSON.parse(JSON.stringify(v.paging)),{canOlder:false,olderCursor:null,canLatest:false},'the A cursor is not offered under B');
 s=apply(s,{source:'letters',ok:false,forKey:key()});v=c.lettersViewModel(s);
 assert.equal(v.status,'一覧の取得不調 · この条件ではまだ読めていません');assert.equal(v.paging.canOlder,false);assert.equal(v.rows.length,0);
 assert.strictEqual(apply(s,{source:'letters',ok:true,value:{letters:[L(1)],hasMore:true,nextCursor:'rA'},forKey:JSON.stringify([null,'A',''])}),s,'a late A answer is still dropped');
 s=apply(s,{source:'letters',ok:true,value:{letters:[L(3)],hasMore:true,nextCursor:'rB'},forKey:key()});v=c.lettersViewModel(s);
 assert.deepEqual([v.rows.map(x=>x.id),v.paging.olderCursor,v.paging.canOlder],[[L(3).id],'rB',true],'B read: paging from B');
 s=apply(s,{source:'letters',ok:false,forKey:key()});v=c.lettersViewModel(s);
 assert.equal(v.status,'一覧の取得不調 · 最後に読めた内容');assert.deepEqual([v.rows.length,v.paging.olderCursor],[1,'rB'],'same key: the last good page is kept');
 s=apply(s,{source:'letters-ui',patch:{letterCursor:'rB'}});v=c.lettersViewModel(s);assert.equal(v.status,'この条件で読み込み中');assert.equal(v.paging.canLatest,true,'back to the newest stays possible');}
// (b) fixed view models -> DOM
class Node{constructor(t){this.tag=t;this.children=[];this.dataset={};this._text='';this.className='';this.title='';this.parent=null;this.attrs={};this.handlers={};this.options=[];this.value='';}
 set textContent(v){this._text=String(v);this.children=[];}get textContent(){return this._text+this.children.map(x=>x.textContent).join('');}
 setAttribute(k,v){this.attrs[k]=String(v);}getAttribute(k){return this.attrs[k];}addEventListener(t,f){this.handlers[t]=f;}
 insertBefore(n,before){if(n.parent)n.remove();n.parent=this;const i=before?this.children.indexOf(before):this.children.length;this.children.splice(i<0?this.children.length:i,0,n);}appendChild(n){this.insertBefore(n,null);}
 remove(){if(this.parent){const a=this.parent.children;a.splice(a.indexOf(this),1);this.parent=null;}}replaceChildren(...ns){this.children=[];this._text='';for(const n of ns)this.appendChild(n);}
 add(o){this.options.push(o);}get innerHTML(){throw Error('innerHTML is not used');}set innerHTML(v){throw Error('innerHTML is not used');}}
Object.defineProperty(Node.prototype,'options',{get(){return this._o||(this._o=Object.assign([],{}))},set(v){this._o=v;}});
{const list=new Node('div'),detail=new Node('div'),status=new Node('span'),member=new Node('select'),state=new Node('select'),older=new Node('button'),latest=new Node('button');
 member.remove=function(i){if(typeof i==='number')this.options.splice(i,1);else Node.prototype.remove.call(this);};state.remove=member.remove;
 const intents=[];const view=c.createLettersView({list,detail,status,member,state,older,latest,makeNode:t=>new Node(t),onSelect:id=>intents.push(['select',id]),onFilter:p=>intents.push(['filter',p]),onPage:cur=>intents.push(['page',cur])});
 const row=(id,text,selected=false,st='sent')=>({id,text,title:id,selected,state:st});
 const body={heading:'H',state:'sent',receipt:'R',stop:'',texts:[{heading:'依頼 v1',body:'<script>x()</script>\r\nline',meta:'M'}],events:[{proxy:true,text:'代理',meta:'m'}]};
 const base={members:[['','すべて'],['Astra','Astra']],states:[['','すべて'],['sent','未受領']],member:'',state:'',status:'2件',rows:[row('A','a'),row('B','b')],hint:'選ぶ',detail:null,paging:{canOlder:true,olderCursor:'r9',canLatest:false}};
 view.show(base);
 assert.equal(older.disabled,false);assert.equal(latest.disabled,true);
 assert.deepEqual(list.children.map(n=>n.textContent),['a','b']);assert.equal(status.textContent,'2件');assert.equal(detail.children[0].textContent,'選ぶ');
 assert.deepEqual(member.options.map(o=>o.value),['','Astra']);
 const nodeB=list.children[1];
 view.show({...base,rows:[row('B','b2',true),row('A','a')],detail:{id:'B',status:'',body}});
 assert.strictEqual(list.children[0],nodeB,'rows are keyed: node identity kept');assert.equal(nodeB.attrs['aria-pressed'],'true');assert.equal(nodeB.textContent,'b2');
 const pre=detail.children.find(n=>n.tag==='pre');assert.equal(pre.textContent,'<script>x()</script>\r\nline','HTML and CRLF stay as text');assert.equal(pre.children.length,0);
 assert(detail.children.some(n=>n.className==='letter-proxy'&&n.textContent==='代理'));
 const kept=detail.children[0];view.show({...base,rows:[row('B','b2',true),row('A','a')],detail:{id:'B',status:'',body}});assert.strictEqual(detail.children[0],kept,'an unchanged detail is not rebuilt');
 nodeB.handlers.click();member.value='Astra';member.handlers.change();state.value='sent';state.handlers.change();
 older.handlers.click();latest.handlers.click();
 assert.deepEqual(intents,[['select','B'],['filter',{letterMember:'Astra'}],['filter',{letterState:'sent'}],['page','r9'],['page',null]],'only the intents');
 const vsrc=slice('function createLettersView(','// The work cards as one studio part');
 for(const n of ['innerHTML','insertAdjacentHTML','fetch(','POST','letterReceipt','LETTER_STATE_CHOICES'])assert(!vsrc.includes(n),'the letters view does not use '+n);}
// (c) distribution and GET-only pollers
{const calls=[],spy=name=>({show:(x,y,rev)=>calls.push(name+':'+(typeof y==='number'?y:rev)),showFailure:(x,rev)=>calls.push(name+':'+rev),recovered(){},update:(x,rev)=>calls.push(name+':'+rev)});
 const st=c.createStudio({views:{cards:spy('cards'),letters:spy('letters')}});
 st.letters({letters:[L(1)]});assert.deepEqual(calls.splice(0).sort(),['cards:1','letters:1']);
 st.letterSelect(L(1).id);assert.deepEqual(calls.splice(0).sort(),['cards:2','letters:2']);
 assert.equal(st.letterDetail(L(2).id,D(L(2))),null,'a stale detail is not distributed');assert.deepEqual(calls,[]);
 st.letterDetail(L(1).id,D(L(1)));assert.deepEqual(calls.splice(0).sort(),['cards:3','letters:3']);
 st.letterPage('r7');assert.equal(st.snapshot().ui.letterCursor,'r7');st.letterFilter({letterMember:'Fable'});assert.equal(st.snapshot().ui.letterCursor,null,'a filter change goes back to the newest page');
 assert.equal(st.letters({letters:[L(1)]},JSON.stringify(['r7','',''])),null,'a page answer for another key is not distributed');}
(async()=>{const paths=[];let gate;
 const st=c.createStudio({views:{letters:{show(){}}}});
 const polls=c.createLetterPolls({studio:st,fetchJson:path=>{paths.push(path);if(path.startsWith('/letters/'))return new Promise(r=>gate=()=>r(D(L(path.endsWith('1'.repeat(32))?1:2))));return Promise.resolve({letters:[L(1),L(2)]});}});
 await polls.list();assert.deepEqual(paths,['/letters?brief=1&limit=50'],'the list asks the brief list only');
 st.letterSelect(L(1).id);const first=polls.detail();st.letterSelect(L(2).id);polls.detail();
 gate();await first;await new Promise(r=>setImmediate(r));
 assert.equal(st.snapshot().sources.letterDetail.value,null,'the slow answer for the old choice was dropped');
 gate();await new Promise(r=>setImmediate(r));
 assert.equal(st.snapshot().sources.letterDetail.value.id,L(2).id,'the new choice was asked again and shown');
 assert(paths.every(p=>p==='/letters?brief=1&limit=50'||p.startsWith('/letters/')),'GET paths only');
 const page=slice('function createLetterPolls(','// The page\'s one studio');assert(!/method:\s*'POST'/.test(page)&&page.includes('fetchJson(letterListQuery(ui))'),'the list asks the brief page of the current key');
 assert(html.includes("letters:createLettersView({list:$('letters-list')"),'the page studio has the letters view');
 console.log('PASS: OPS-156 letters (view model: rows/filters/flags/receipt diff/stop/proxy, detail only for the chosen letter, stale answers ignored, last good kept for the same letter; DOM: textContent only, keyed rows, intents; same revision; GET-only single-flight pollers drop old answers).');
})().catch(e=>{console.error(e);process.exit(1);});
