// OPS-154 stage 2: the neighborhood (local map) as a view model. (a) Compatibility baseline: fixed scenarios on the anonymized
// fixture drawn by renderNeighborhood with a stub DOM, compared with task-view-model-neighbor.baseline.json captured from the
// code before the extraction (no canvas: the existing character estimate measures text, so the result is deterministic).
// (b) Pure view model contracts and fixed view model -> DOM with intents. --write re-captures the baseline.
const fs=require('fs'),vm=require('vm'),assert=require('assert'),path=require('path');
const html=fs.readFileSync(process.env.STUDIO_TEMPLATE||__dirname+'/index.template.html','utf8');
const fn=name=>{const a=html.indexOf('\nfunction '+name+'(');if(a<0)return '';const m=/\)\s*\{/g;m.lastIndex=a;let i=m.exec(html).index;i=html.indexOf('{',i);let d=0;for(;i<html.length;i++){if(html[i]==='{')d++;else if(html[i]==='}'&&--d===0)break;}return html.slice(a+1,i+1);};
class Node{constructor(tag){this.tag=tag;this.attrs=[];this.children=[];this._text='';this.className='';this.style={};this.parent=null;this.handlers={};this.scrollLeft=0;this.clientWidth=900;}
 setAttribute(k,v){const x=this.attrs.find(a=>a[0]===k);if(x)x[1]=String(v);else this.attrs.push([k,String(v)]);}getAttribute(k){const x=this.attrs.find(a=>a[0]===k);return x?x[1]:null;}
 append(...ns){for(const n of ns){n.parent=this;this.children.push(n);}}appendChild(n){this.append(n);}replaceChildren(...ns){this.children=[];this._text='';this.append(...ns);}
 set textContent(v){this._text=String(v);this.children=[];}get textContent(){return this._text+this.children.map(c=>c.textContent).join('');}
 set onclick(f){this.handlers.click=f;}get onclick(){return this.handlers.click;}set onkeydown(f){this.handlers.key=f;}get onkeydown(){return this.handlers.key;}
 get outer(){const cls=this.className?[['class',this.className]]:[];return '<'+this.tag+[...cls,...this.attrs].map(([k,v])=>' '+k+'="'+v+'"').join('')+(this.handlers.click?' [click]':'')+(this.handlers.key?' [key]':'')+'>'+this._text+this.children.map(c=>c.outer).join('')+'</'+this.tag+'>';}}
const fixture=JSON.parse(fs.readFileSync(path.join(__dirname,'task-view-model-fixture-b.json'),'utf8'));
function context(){
 const nodes={neighborBox:new Node('div'),neighborCount:new Node('span')},calls=[];
 const c={document:{createElementNS:(ns,t)=>new Node(t),createElement:t=>new Node(t)},$:id=>nodes[id]||null,calls};vm.createContext(c);
 const names=['el','svg','stateStyle','proposalNodes','taskDocumentPaths','cardDocumentPaths','twoLineTitle','neighborMeasure','neighborhood','neighborhoodLayout','renderNeighborhood','wrapLines','drawSvgSpec','neighborhoodViewModel','drawNeighborhood'];
 vm.runInContext(names.map(fn).filter(Boolean).join('\n')+'\nvar doc=null,selected=null,documentBundle=null;let neighborCenter=null;const neighborExpanded=new Set();'+
  'function select(id){calls.push(["select",id]);}function openDocument(p){calls.push(["open",p]);}function documentLinks(x){return document.createElement("div");}\n'+
  'function __set(d,sel,center,exp,bundle){doc=d;selected=sel;neighborCenter=center;neighborExpanded.clear();for(const x of exp)neighborExpanded.add(x);documentBundle=bundle;}function __center(){return neighborCenter;}function __expanded(){return [...neighborExpanded];}',c);
 return {c,nodes};
}
// scenarios on the anonymized fixture
const degree=new Map();for(const e of fixture.edges.concat(fixture.milestoneRelations||[]))for(const id of [e.prerequisite,e.successor])degree.set(id,(degree.get(id)||0)+1);
const busy=[...degree].filter(([id])=>fixture.tasks.some(t=>t.id===id)).sort((a,b)=>b[1]-a[1]||(a[0]<b[0]?-1:1))[0][0];
const neighborOf=id=>{const ns=fixture.edges.concat(fixture.milestoneRelations||[]).filter(e=>e.prerequisite===id||e.successor===id).map(e=>e.prerequisite===id?e.successor:e.prerequisite);return ns.sort((a,b)=>(degree.get(b)||0)-(degree.get(a)||0)||(a<b?-1:1))[0];};
const ms=(fixture.milestones||[]).find(m=>!m.virtual&&degree.get(m.id)).id;
const adj=id=>new Set(fixture.edges.concat(fixture.milestoneRelations||[]).filter(e=>e.prerequisite===id||e.successor===id).map(e=>e.prerequisite===id?e.successor:e.prerequisite));
const chain=(()=>{for(const t of fixture.tasks)for(const y of adj(t.id)){const extra=[...adj(y)].filter(z=>z!==t.id&&!adj(t.id).has(z));if(extra.length)return [t.id,y];}return [busy,neighborOf(busy)];})();
const docTask=fixture.tasks.find(t=>/Maintanance\/.+\.md/.test(t.detail)&&degree.get(t.id));
const bundle={files:Object.fromEntries(fixture.tasks.flatMap(t=>[...(t.detail.matchAll(/(?:Maintanance|Sources|Tests)\/[^`\s|]+?\.md/g))].map(m=>[m[0],{}])).slice(0,40))};
const SCENARIOS=[['busy task, one step',fixture.tasks[0].id,busy,[]],['expanded neighbor',chain[0],chain[0],[chain[1]]],['milestone center',busy,ms,[]],['document task',docTask.id,docTask.id,[]],
 ['proposal without lines','draft-1','draft-1',[]],['center falls back to the selection',busy,null,[]],['unknown center',busy,'NOPE-1',[]]];
function capture(){
 return SCENARIOS.map(([name,sel,center,exp])=>{const {c,nodes}=context();c.__set(fixture,sel,center,exp,bundle);c.renderNeighborhood();
  return {name,count:nodes.neighborCount.textContent,box:nodes.neighborBox.outer,center:c.__center()};});
}
const file=path.join(__dirname,'task-view-model-neighbor.baseline.json');
if(process.argv.includes('--write')){fs.writeFileSync(file,JSON.stringify({about:'OPS-154 stage 2 compatibility baseline of the neighborhood view (stub DOM, character-estimate text measure, anonymized fixture b). Captured before the neighborhood view-model extraction. It shows the output stayed the same; it is not a proof of correctness.',scenarios:capture()},null,1)+'\n');console.log('baseline written');process.exit(0);}
const base=JSON.parse(fs.readFileSync(file,'utf8')).scenarios,now=capture();
assert.equal(now.length,base.length);now.forEach((s,i)=>assert.deepStrictEqual(s,base[i],'baseline: '+base[i].name));
if(process.env.NEIGHBOR_BASELINE_ONLY){console.log('PASS: neighborhood baseline ('+now.length+' scenarios)');process.exit(0);}
// (b) contracts of the pure view model
{const {c}=context(),before=JSON.stringify(fixture),measure=s=>[...s].length*7;
 const vmOf=(center,exp=[])=>c.neighborhoodViewModel({data:fixture,center,expanded:new Set(exp),measure,documentPaths:t=>t.proposal?[]:c.cardDocumentPaths(t,bundle)});
 const v=vmOf(busy);assert.equal(JSON.stringify(fixture),before,'deriving never changes the data');
 assert.equal(v.svg.tag,'svg');assert.equal(v.svg.attrs['aria-label'],busy+' を中心にした局所見取り図');
 const nodes=v.svg.children.filter(x=>x.intent&&x.intent.type==='select');assert.equal(v.count,nodes.length+'ノード・'+v.svg.children.filter(x=>x.tag==='path'&&x.attrs['data-edge']).length+'本');
 const centerNode=nodes.find(x=>x.intent.id===busy);assert.equal(centerNode.children[0].attrs.fill,'#d4edbc');assert(centerNode.children[1].text.endsWith(' · 中心'));
 const title=centerNode.children.find(x=>x.tag==='title');assert.equal(title.text,busy+' '+fixture.tasks.find(t=>t.id===busy).item,'the hover title keeps the full text');
 assert(v.svg.children.filter(x=>x.tag==='path'&&x.attrs['data-edge']).every(p=>p.children[0].tag==='title'&&p.children[0].text.includes(' → ')),'every line has its hover title');
 assert.deepEqual(JSON.parse(JSON.stringify(vmOf(busy))),JSON.parse(JSON.stringify(v)),'pure: same input, same view model');
 // injected measure decides the wrapping; null falls back to the estimate
 const narrow=c.neighborhoodViewModel({data:fixture,center:busy,expanded:new Set(),measure:s=>[...s].length*100,documentPaths:()=>[]});
 const lines=n=>n.children.filter(x=>x.tag==='text'&&x.attrs['font-size']===12).map(x=>x.text);
 assert(lines(narrow.svg.children.find(x=>x.intent&&x.intent.id===busy)).every(l=>[...l].length<=2),'a wide measure wraps hard');
 // sections: the center's prerequisites and successors; expansion adds a further section and marks the expanded row
 assert.deepEqual(v.sections.map(s=>s.heading.replace(/\d+本$/,'')),['前提（→ 中心）','後続（中心 →）']);
 const ex=vmOf(chain[0],[chain[1]]);assert(ex.sections.some(s=>s.heading.startsWith('展開した先 ')));
 assert(ex.sections.flatMap(s=>s.rows).filter(r=>r.other===chain[1]).every(r=>r.canCenter&&!r.canExpand),'an expanded node offers centering only');
 const docs=vmOf(docTask.id);assert(docs.svg.children.some(x=>x.intent&&x.intent.type==='documents'&&x.intent.id===docTask.id&&x.intent.paths.length));
 assert(!vmOf('draft-1').svg.children.some(x=>x.intent&&x.intent.type==='documents'),'a proposal has no document link');
 assert.deepEqual(JSON.parse(JSON.stringify(vmOf('NOPE-1'))),{count:'',empty:'中心にするノードがありません。インスペクタの「接続を見る」で選んでください。'});
 // nothing global: the global doc does not change the view model
 vm.runInContext('doc={tasks:[],edges:[],milestones:[]};',c);assert.deepEqual(JSON.parse(JSON.stringify(vmOf(busy))),JSON.parse(JSON.stringify(v)),'the view model reads only its inputs');}
// (c) fixed view model -> DOM and intents
{const {c}=context(),box=new Node('div'),count=new Node('span'),got=[];
 const fixed={count:'2ノード・1本',empty:null,heading:'中心：A · ACTIVE',item:'本文',width:500,
  svg:{tag:'svg',attrs:{width:500,height:200},children:[{tag:'g',attrs:{class:'node'},intent:{type:'select',id:'A'},children:[{tag:'title',attrs:{},text:'A 全文'}]},{tag:'a',attrs:{href:'#document'},intent:{type:'documents',id:'A',paths:['p1','p2']}}]},
  sections:[{heading:'前提（→ 中心）0本',rows:[]},{heading:'後続（中心 →）1本',rows:[{arrow:'A → B',text:'依存 / 条件',other:'B',canCenter:true,canExpand:true}]}]};
 c.drawNeighborhood(box,count,fixed,{select:id=>got.push(['select',id]),reset:()=>got.push(['reset']),center:id=>got.push(['center',id]),expand:id=>got.push(['expand',id]),documents:(id,p)=>got.push(['documents',id,p.length])});
 assert.equal(count.textContent,'2ノード・1本');assert.deepEqual(box.children.map(n=>n.tag),['div','h3','p','div','h3','p','h3','div']);
 assert.equal(box.children[5].textContent,'ありません。','an empty section says so');
 const svgNode=box.children[3].children[0],g=svgNode.children[0],a=svgNode.children[1];
 g.onclick();g.onkeydown({key:'Enter'});g.onkeydown({key:'x'});a.onclick({preventDefault(){},stopPropagation(){}});
 box.children[0].children[0].onclick();const row=box.children[7];row.children[2].onclick();row.children[3].onclick();
 assert.deepEqual(got,[['select','A'],['select','A'],['documents','A',2],['reset'],['center','B'],['expand','B']],'only intents');
 const empty=new Node('div');c.drawNeighborhood(empty,new Node('span'),{count:'',empty:'なし'},{});assert.deepEqual([empty.children.length,empty.children[0].textContent],[1,'なし']);
 const src=fn('drawNeighborhood');for(const n of ['neighborhood(','neighborhoodLayout(','twoLineTitle(','stateStyle(','cardDocumentPaths(','doc.','neighborCenter'])assert(!src.includes(n),'the view does not use '+n);}
console.log('PASS: OPS-154 neighborhood ('+now.length+' baseline scenarios; view model: highlight, hover titles, sections, expansion, documents, injected measure, purity, no globals; fixed view model -> DOM and intents).');
