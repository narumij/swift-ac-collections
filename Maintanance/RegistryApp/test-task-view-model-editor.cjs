// OPS-154 stage 3: the editor as a view model and operation intents. (a) Compatibility baseline: the editor drawn and operated
// with a stub DOM on the anonymized fixture b, compared with task-view-model-editor.baseline.json captured from the code before
// the extraction (editor DOM per selection; Model, delta, selection, flags, prompts and reports after the same operations).
// (b) Pure view model contracts, fixed view model -> DOM and intents, and pending input kept while formDirty.
// --write re-captures the baseline; EDITOR_BASELINE_ONLY=1 runs (a) only.
const fs=require('fs'),vm=require('vm'),assert=require('assert'),path=require('path');
const html=fs.readFileSync(process.env.STUDIO_TEMPLATE||__dirname+'/index.template.html','utf8');
const fn=name=>{const a=html.indexOf('\nfunction '+name+'(');if(a<0)return '';const m=/\)\s*\{/g;m.lastIndex=a;let i=m.exec(html).index;i=html.indexOf('{',i);let d=0;for(;i<html.length;i++){if(html[i]==='{')d++;else if(html[i]==='}'&&--d===0)break;}return html.slice(a+1,i+1);};
const line=prefix=>{const a=html.indexOf('\n'+prefix);assert(a>=0,prefix);return html.slice(a+1,html.indexOf('\n',a+1));};
class Node{constructor(tag,ids){this.tag=tag;this.ids=ids;this.children=[];this.attrs=[];this._text='';this.className='';this.style={};this.handlers={};this._id='';this.title='';this.htmlFor='';this.rows=0;this._value='';}
 set id(v){this._id=v;this.ids.set(v,this);}get id(){return this._id;}
 setAttribute(k,v){const x=this.attrs.find(a=>a[0]===k);if(x)x[1]=String(v);else this.attrs.push([k,String(v)]);}
 append(...ns){for(const n of ns)this.children.push(n);}appendChild(n){this.children.push(n);}replaceChildren(...ns){this.children=[];this._text='';this.append(...ns);}
 set textContent(v){this._text=String(v);this.children=[];}get textContent(){return this._text+this.children.map(c=>c.textContent).join('');}
 get options(){return this.children.filter(c=>c.tag==='option');}
 set value(v){this._value=String(v);}get value(){if(this.tag!=='select')return this._value;const o=this.options.find(c=>c.value===this._value);return o?o.value:'';}
 get outer(){const a=[['class',this.className],['id',this._id],['title',this.title],['for',this.htmlFor],['rows',this.rows||''],['value',this.tag==='select'||this.tag==='input'||this.tag==='textarea'||this.tag==='option'?this.value:'']].filter(x=>x[1]).concat(this.attrs);
  return '<'+this.tag+a.map(([k,v])=>' '+k+'="'+v+'"').join('')+Object.keys(this.handlers).filter(k=>this.handlers[k]).sort().map(k=>' ['+k+']').join('')+'>'+this._text+this.children.map(c=>c.outer).join('')+'</'+this.tag+'>';}}
for(const k of ['onclick','oninput','onchange'])Object.defineProperty(Node.prototype,k,{get(){return this.handlers[k]||null;},set(f){this.handlers[k]=f;}});
const fixture=JSON.parse(fs.readFileSync(path.join(__dirname,'task-view-model-fixture-b.json'),'utf8'));
const NAMES=['el','options','field','documentLinks','copy','check','proposalNodes','nextProposalId','addProposal','updateProposal','removeProposal','addProposalEdge','initializeRelationBaseline',
 'planClone','planParts','planCards','planVersions','planRenumber','planRebuild','planCard','planEditText','planReorder','planMove','milestonePlanChanges','graphData','delta',
 'removeRelation','isMilestoneLink','linkLabel','dataRelation','isChainLink','addMilestoneRelation','renderTaskPicker','editor','milestonePlanEditor','proposalEditor',
 'editorViewModel','milestonePlanBlocks','proposalBlocks','drawEditor','editorAct'];
function context(){
 const ids=new Map(),log=[],c={log,ids,console};c.document={createElement:t=>new Node(t,ids),createElementNS:(ns,t)=>new Node(t,ids)};vm.createContext(c);
 for(const id of ['editor','taskPicker','selectedTitle'])new Node(id==='taskPicker'?'select':'div',ids).id=id;
 const src=[line('const STATES='),line('const PLAN_DIR='),line('const CHAIN_NOTE='),html.includes('\nconst EDITOR_GUARD=')?line('const EDITOR_GUARD='):'',...NAMES.map(fn).filter(Boolean)].join('\n')+
  '\nvar doc=null,selected=null,dirty=false,formDirty=false,__confirm=true;const copy=x=>JSON.parse(JSON.stringify(x));function $(id){return ids.get(id)||null;}'+
  'function report(m,e){log.push(["report",m,!!e]);}function confirm(m){log.push(["confirm",m]);return __confirm;}function banner(){log.push(["banner"]);}'+
  'function showNeighborhood(id){log.push(["neighborhood",id]);}function openDocument(p){log.push(["open",p]);}function render(){log.push(["render"]);editor();}'+
  'function select(id){if(formDirty&&!confirm("編集中の入力を破棄して移動しますか？"))return;formDirty=false;selected=id;render();}\n'+
  'function __set(d,sel){doc=d;selected=sel;dirty=false;formDirty=false;}function __state(){return {doc,selected,dirty,formDirty};}function __confirmAnswer(v){__confirm=v;}function __formDirty(v){formDirty=v;}';
 vm.runInContext(src,c);return c;
}
const fresh=()=>{const d=JSON.parse(JSON.stringify(fixture));const c=context();c.initializeRelationBaseline(d);return {c,d};};
const all=n=>[n,...n.children.flatMap(all)];
const button=(c,text,nth=0)=>{const b=all(c.ids.get('editor')).filter(n=>n.tag==='button'&&n.textContent===text)[nth];assert(b,'button '+text);return b;};
// scenario choices on the fixture (deterministic)
const withPre=fixture.tasks.find(t=>fixture.edges.some(e=>e.successor===t.id)).id;
const withLink=fixture.tasks.find(t=>fixture.milestoneRelations.some(r=>r.prerequisite===t.id&&!/^(START|END|GATE)-/.test(r.successor))||fixture.milestoneRelations.some(r=>r.prerequisite===t.id)).id;
const withAfter=fixture.tasks.find(t=>fixture.milestoneRelations.some(r=>r.successor===t.id&&!r.prerequisite.startsWith('START-')))?.id||withLink;
const withStart=fixture.tasks.find(t=>fixture.milestoneRelations.some(r=>r.successor===t.id&&r.prerequisite.startsWith('START-')))?.id||withLink;
const permanent=fixture.tasks.find(t=>t.permanent)?.id||fixture.tasks[1].id;
const plain=fixture.tasks.find(t=>!fixture.edges.some(e=>e.successor===t.id||e.prerequisite===t.id)&&!fixture.milestoneRelations.some(r=>r.prerequisite===t.id||r.successor===t.id)).id;
const cardDir=m=>!m.virtual&&/\/\d+_[^/]+\.md$/.test(m.gate||'')?m.gate.split('/')[2]:null;  // an intermediate card in a version with two or more cards, so it can move both ways
const card=fixture.milestones.filter(m=>cardDir(m)&&fixture.milestones.filter(x=>cardDir(x)===cardDir(m)).length>1)[1].id;
const gate=fixture.milestones.find(m=>m.id.startsWith('GATE-')).id;
const VIEWS=[['task with prerequisites',withPre],['task with milestone links',withLink],['task after a milestone',withAfter],['task with a START',withStart],['permanent or other task',permanent],
 ['task without lines',plain],['intermediate card with plan',card],['release gate',gate],['proposal','draft-1'],['unknown selection','NOPE-1'],['no selection',null]];
const setField=(c,id,v,typed)=>{const n=c.ids.get(id);assert(n,'field '+id);n.value=v;if(typed&&n.oninput)n.oninput();};
// operations: [name, selection, steps(c)] -- the same user actions run against the old and the new code
const OPS=[
 ['apply state and owner',withPre,c=>{setField(c,'state','DONE',true);setField(c,'owner','担当Z',true);button(c,'変更を適用').onclick();}],
 ['add a prerequisite',withPre,c=>{setField(c,'prerequisite',plain);setField(c,'flow','PARALLEL_JOIN');button(c,'前提を追加').onclick();}],
 ['add a duplicate prerequisite',withPre,c=>{setField(c,'prerequisite',fixture.edges.find(e=>e.successor===withPre).prerequisite);button(c,'前提を追加').onclick();}],
 ['add while typing is refused',withPre,c=>{setField(c,'owner','打ちかけ',true);button(c,'前提を追加').onclick();}],
 ['remove a prerequisite (yes)',withPre,c=>{button(c,'削除').onclick();}],
 ['remove a prerequisite (no)',withPre,c=>{c.__confirmAnswer(false);button(c,'削除').onclick();}],
 ['connect to a milestone',plain,c=>{button(c,'到達点へつなぐ').onclick();}],
 ['connect twice is refused',plain,c=>{button(c,'到達点へつなぐ').onclick();button(c,'到達点へつなぐ').onclick();}],
 ['milestone as prerequisite',plain,c=>{button(c,'マイルストーンを前提にする').onclick();}],
 ['connect from START',plain,c=>{const s=c.ids.get('startSource');s.value=s.options[0].value;button(c,'STARTからつなぐ').onclick();}],
 ['remove a milestone link',withLink,c=>{const rows=all(c.ids.get('editor')).filter(n=>n.className==='edge-row');rows[rows.length-1].children[0].onclick();}],
 ['look at the neighborhood',withPre,c=>{button(c,'接続を見る').onclick();}],
 ['picker selects',withPre,c=>{const p=c.ids.get('taskPicker');p.value=plain;p.onchange();}],
 ['picker while typing, keep',withPre,c=>{setField(c,'owner','打ちかけ',true);c.__confirmAnswer(false);const p=c.ids.get('taskPicker');p.value=plain;p.onchange();}],
 ['plan name and condition',card,c=>{setField(c,'planItem','新しい名前',true);setField(c,'planCondition','新しい条件',true);button(c,'名前・条件を適用').onclick();}],
 ['plan empty name is refused',card,c=>{setField(c,'planItem','  ',true);button(c,'名前・条件を適用').onclick();}],
 ['plan move later',card,c=>{button(c,'後へ').onclick();}],
 ['plan move earlier',card,c=>{button(c,'前へ').onclick();}],
 ['plan move to a version',card,c=>{button(c,'この版へ移動').onclick();}],
 ['plan reorder while typing is refused',card,c=>{setField(c,'planItem','打ちかけ',true);button(c,'後へ').onclick();}],
 ['proposal apply',`draft-1`,c=>{setField(c,'proposalTitle','新しい題',true);setField(c,'proposalMemo','新しいメモ',true);button(c,'変更を適用').onclick();}],
 ['proposal cancel (yes)','draft-1',c=>{button(c,'この追加案を取り消す').onclick();}],
 ['proposal cancel (no)','draft-1',c=>{c.__confirmAnswer(false);button(c,'この追加案を取り消す').onclick();}],
 ['proposal prerequisite',`draft-1`,c=>{setField(c,'proposalPre',plain);setField(c,'proposalPreFlow','PARALLEL_JOIN');button(c,'前提に追加').onclick();}],
 ['proposal successor','draft-1',c=>{setField(c,'proposalNext',withPre);button(c,'後続に追加').onclick();}],
 ['proposal after a milestone','draft-1',c=>{button(c,'マイルストーンの後に続ける').onclick();}],
 ['proposal to a milestone, then remove it','draft-1',c=>{button(c,'到達点へつなぐ').onclick();const rows=all(c.ids.get('editor')).filter(n=>n.className==='edge-row');rows[rows.length-1].children[0].onclick();}],
 ['proposal add while typing is refused','draft-1',c=>{setField(c,'proposalTitle','打ちかけ',true);button(c,'後続に追加').onclick();}],
];
function snapshot(c){const s=c.__state();return {editor:c.ids.get('editor').outer,title:c.ids.get('selectedTitle').textContent,picker:c.ids.get('taskPicker').outer,
 doc:JSON.stringify(s.doc),delta:JSON.stringify(c.delta()),selected:s.selected,dirty:s.dirty,formDirty:s.formDirty,log:JSON.parse(JSON.stringify(c.log))};}
function capture(){
 const views=VIEWS.map(([name,sel])=>{const {c,d}=fresh();c.__set(d,sel);c.editor();return {name,...snapshot(c)};});
 const ops=OPS.map(([name,sel,steps])=>{const {c,d}=fresh();c.__set(d,sel);c.editor();c.log.length=0;steps(c);return {name,...snapshot(c)};});
 return {views,ops};
}
const file=path.join(__dirname,'task-view-model-editor.baseline.json');
if(process.argv.includes('--write')){fs.writeFileSync(file,JSON.stringify({about:'OPS-154 stage 3 compatibility baseline of the editor (stub DOM, anonymized fixture b): editor DOM per selection, and Model/delta/selection/flags/prompts/reports after the same operations. Captured before the editor view-model extraction. It shows the output stayed the same; it is not a proof of correctness.',...capture()},null,1)+'\n');console.log('baseline written');process.exit(0);}
const base=JSON.parse(fs.readFileSync(file,'utf8')),now=capture();
for(const k of ['views','ops']){assert.equal(now[k].length,base[k].length);now[k].forEach((s,i)=>{for(const f of Object.keys(base[k][i]))assert.deepStrictEqual(s[f],base[k][i][f],'baseline '+k+': '+base[k][i].name+' / '+f);});}
if(process.env.EDITOR_BASELINE_ONLY){console.log('PASS: editor baseline ('+now.views.length+' views, '+now.ops.length+' operations)');process.exit(0);}
// (b) contracts
// Pending input is kept while formDirty: a redraw request (the version filter calls render()) keeps the typed value; applying
// it changes the Model; discarding through the selection guard redraws.
{const {c,d}=fresh();c.__set(d,withPre);c.editor();setField(c,'owner','入力中の値',true);c.render();
 assert.equal(c.ids.get('owner').value,'入力中の値','typed value survives a redraw request while formDirty');assert(c.__state().formDirty);
 assert.equal(JSON.stringify(c.__state().doc),JSON.stringify(fresh().d),'the Model is unchanged until apply');
 button(c,'変更を適用').onclick();assert.equal(c.__state().doc.tasks.find(t=>t.id===withPre).owner,'入力中の値');assert(!c.__state().formDirty&&c.__state().dirty);
 setField(c,'owner','また入力',true);c.__confirmAnswer(true);const p=c.ids.get('taskPicker');p.value=plain;p.onchange();
 assert.equal(c.__state().selected,plain);assert.equal(c.ids.get('owner').value,c.__state().doc.tasks.find(t=>t.id===plain).owner,'discarding by the guard redraws the new selection');}
// contracts of the pure view model
{const {c,d}=fresh(),before=JSON.stringify(d);c.__set(d,withPre);const graph=c.graphData();
 const vmOf=sel=>c.editorViewModel({data:d,graph,selected:sel}),flat=bs=>bs.flatMap(b=>b.type==='row'?flat(b.columns.flat()):[b]),intents=v=>flat(v.blocks).flatMap(b=>b.type==='buttons'?b.items.map(x=>x.intent):b.intent?[b.intent]:[]);
 const task=vmOf(withPre);assert.equal(JSON.stringify(d),before,'the view model does not change its input');
 assert.equal(JSON.stringify(vmOf(withPre)),JSON.stringify(task),'same input, same view model');
 c.__set({tasks:[],edges:[],milestones:[],milestoneRelations:[],proposals:[],source:{path:'x'}},null);assert.equal(JSON.stringify(vmOf(withPre)),JSON.stringify(task),'reads only its inputs, not the global Model or selection');c.__set(d,withPre);
 const ids=task.picker.options.map(o=>o.value);assert.deepEqual(ids,[...ids].sort((a,b)=>a.localeCompare(b,'en',{numeric:true})));assert.equal(task.picker.value,withPre);
 const fields=flat(task.blocks).filter(b=>b.type==='field');assert.deepEqual(fields.filter(f=>f.typing).map(f=>f.id),['state','owner'],'only state and owner mark the form dirty');
 assert.deepEqual(fields.map(f=>f.id),['state','owner','prerequisite','flow','milestoneTarget','milestoneSource','startSource']);
 const acts=intents(task);for(const i of acts)if(i.type!=='removeRelation')assert.equal(i.id,withPre,'intents name the selected task by ID');
 assert.deepEqual([...new Set(acts.map(i=>i.type))],['look','applyTask','removeRelation','addPrerequisite','milestoneRelation']);
 const removal=acts.find(i=>i.type==='removeRelation').relation;assert(!d.edges.includes(removal),'the view model hands out copies, not Model objects');
 assert.deepEqual(acts.filter(i=>i.type==='milestoneRelation').map(i=>[i.direction,i.read.target]),[[undefined,'milestoneTarget'],['from','milestoneSource'],[undefined,'startSource']]);
 const target=fields.find(f=>f.id==='milestoneTarget');for(const [k,v] of Object.entries(target.options.labels))assert(v.startsWith(k+'（→ GATE-'),'END options name their gate');
 const plan=vmOf(card),planActs=intents(plan);assert.equal(plan.title,d.milestones.find(m=>m.id===card).item);
 assert.deepEqual(planActs.filter(i=>i.type==='planReorder').map(i=>i.step),[-1,1]);assert(planActs.some(i=>i.type==='planMove'&&i.read.version==='planVersion'));
 assert.deepEqual(flat(plan.blocks).filter(b=>b.type==='field'&&b.typing).map(b=>b.id),['planItem','planCondition']);
 const gate=vmOf(d.milestones.find(m=>m.id.startsWith('GATE-')).id);assert(!flat(gate.blocks).some(b=>b.type==='field'),'a release gate has no fields');
 const prop=vmOf('draft-1'),propActs=intents(prop);assert.equal(prop.title,'draft-1 · 追加案');
 assert.deepEqual(propActs.filter(i=>i.type==='proposalEdge').map(i=>[i.side,i.read.other,i.read.flow]),[['pre','proposalPre','proposalPreFlow'],['next','proposalNext','proposalNextFlow']]);
 assert.deepEqual(propActs.filter(i=>i.type==='milestoneRelation').map(i=>i.direction),['from',undefined]);
 for(const sel of ['NOPE-1',null]){const v=vmOf(sel);assert.equal(v.title,null);assert.deepEqual(v.blocks,[]);assert.equal(v.picker.value,sel||'');}}
// fixed view model -> DOM and intents
{const {c}=fresh(),got=[],box=new Node('div',c.ids),title=new Node('div',c.ids),picker=new Node('select',c.ids);title.textContent='前の題';
 const vm={picker:{options:[{value:'A-1',title:'一'},{value:'A-2',title:'二'}],value:'A-2'},title:'題',blocks:[
  {type:'buttons',items:[{text:'押す',cls:'primary',title:'説明',intent:{type:'x',id:'A-2',read:{v:'f1',w:'f2'}}}]},
  {type:'row',columns:[[{type:'field',label:'入力',id:'f1',control:'input',value:'初期',typing:true}],[{type:'field',label:'選ぶ',id:'f2',control:'select',value:'',options:{values:['p','q'],value:'q',labels:{q:'q（→ G）'}},typing:false}]]},
  {type:'text',tag:'h3',text:'見出し'},{type:'text',tag:'p',text:'注記',cls:'muted'},{type:'details',summary:'開く',text:'中身'},
  {type:'edge',strong:'A-1 · SEQUENCE',note:'条件',intent:{type:'removeRelation',relation:{prerequisite:'A-1',successor:'A-2'}}},{type:'button',text:'単独',intent:{type:'y',id:'A-2'}}]};
 c.drawEditor(box,title,picker,vm,(i,v)=>got.push([i.type,i.id||null,v||null]));
 assert.equal(title.textContent,'題');assert.deepEqual(picker.options.map(o=>[o.value,o.title]),[['A-1','一'],['A-2','二']]);assert.equal(picker.value,'A-2');
 assert.deepEqual(box.children.map(n=>n.tag+(n.className?'.'+n.className:'')),['div.buttons','div.row','h3','p.muted','details','div.edge-row','button']);
 const f1=c.ids.get('f1'),f2=c.ids.get('f2');assert.equal(f1.value,'初期');assert.equal(f2.value,'q');assert.equal(f2.options[1].textContent,'q（→ G）');
 assert(f1.oninput&&!f2.oninput,'only typing fields mark the form dirty');f1.oninput();assert(c.__state().formDirty,'typing marks the form dirty');
 f1.value='打った';f2.value='p';box.children[0].children[0].onclick();box.children[5].children[0].onclick();box.children[6].onclick();picker.value='A-1';picker.onchange();
 assert.equal(JSON.stringify(got),JSON.stringify([['x','A-2',{v:'打った',w:'p'}],['removeRelation',null,{}],['y','A-2',{}],['select','A-1',null]]),'only intents, with the values the intent reads');
 assert.equal(box.children[0].children[0].title,'説明');
 c.drawEditor(box,title,picker,{picker:{options:[],value:''},title:null,blocks:[]},()=>{});assert.equal(title.textContent,'題','no selection leaves the title');assert.equal(box.children.length,0);
 const view=fn('drawEditor');assert(!/\bdoc\b|graphData|formDirty|\bselected\b/.test(view),'the view reads no Model state');}
console.log('PASS: OPS-154 editor ('+now.views.length+' baseline views, '+now.ops.length+' operations; pending input kept while formDirty; view model: purity, fields, intents by ID, copies; fixed view model -> DOM and intents).');
