// OPS-154 区切り1: the task maps as view models. (a) Contract cases of the pure view models (dependency graph, independent
// strip, card list, permanent map; listed, not exhaustive). (b) Fixed view models -> SVG/DOM and intents with a stub DOM.
// The compatibility baseline of the real page is task-view-model-maps.baseline.json, checked by task-view-model-capture.cjs
// and task-view-model-baseline.cjs in an isolated browser (not run here).
const fs=require('fs'),vm=require('vm'),assert=require('assert');
const html=fs.readFileSync(process.env.STUDIO_TEMPLATE||__dirname+'/index.template.html','utf8');
// Take top-level functions by name (brace matching; the template keeps braces balanced in strings and templates).
const fn=name=>{const a=html.indexOf('\nfunction '+name+'(');assert(a>=0,'function '+name);const m=/\)\s*\{/g;m.lastIndex=a;let i=m.exec(html).index+m.exec.length,d=0;i=html.indexOf('{',i);for(;i<html.length;i++){if(html[i]==='{')d++;else if(html[i]==='}'&&--d===0)break;}return html.slice(a+1,i+1);};
class Node{constructor(tag,ns){this.tag=tag;this.ns=ns;this.attrs=[];this.children=[];this._text='';this.style={};this.className='';this.parent=null;}
 setAttribute(k,v){const x=this.attrs.find(a=>a[0]===k);if(x)x[1]=String(v);else this.attrs.push([k,String(v)]);}getAttribute(k){const x=this.attrs.find(a=>a[0]===k);return x?x[1]:null;}
 append(...ns){for(const n of ns){n.parent=this;this.children.push(n);}}appendChild(n){this.append(n);}set textContent(v){this._text=String(v);this.children=[];}get textContent(){return this._text+this.children.map(c=>c.textContent).join('');}
 setAttributeNS(){}replaceChildren(...ns){this.children=[];this._text='';this.append(...ns);}get outer(){const st=Object.keys(this.style).length?[['style',Object.entries(this.style).map(([k,v])=>k+': '+v+';').join(' ')]]:[];const cls=this.className?[['class',this.className]]:[];
  return '<'+this.tag+[...cls,...this.attrs,...st].map(([k,v])=>' '+k+'="'+v+'"').join('')+'>'+this._text+this.children.map(c=>c.outer).join('')+'</'+this.tag+'>';}}
const c={document:{createElementNS:(ns,t)=>new Node(t,ns),createElement:t=>new Node(t)}};vm.createContext(c);
vm.runInContext(html.slice(html.indexOf('const STATES='),html.indexOf('\n',html.indexOf('const STATES=')))+'\n'+['svg','el','stateStyle','stateBand','wrapLines','drawSvgSpec','graphViewModel','versionView','versionFolders','graphLayout','isMilestoneLink','linkLabel','graphData','proposalNodes',
 'independentViewModel','cardListViewModel','bandView','stateBandModel','drawIndependent','drawCardList','permanentMapViewModel','permanentMapData','taskDocumentPaths','independentGroups','cardListGroups'].map(fn).join('\n')+'\nvar doc=null;',c);
const fixture=JSON.parse(fs.readFileSync(__dirname+'/task-view-model-fixture-b.json','utf8'));c.doc=fixture;
const measure=t=>[...t].length*7,clone=x=>JSON.parse(JSON.stringify(x));
const walk=(spec,f)=>{f(spec);for(const ch of spec.children||[])walk(ch,f);};
// (a1) wrapLines: limit, maxLines and the ellipsis
assert.deepEqual(c.wrapLines('あいうえお',21,2,measure),['あいう','えお']);
assert.deepEqual(c.wrapLines('あいうえおかきく',21,2,measure),['あいう','えお…'],'the last line is cut with an ellipsis that fits');
assert.deepEqual(c.wrapLines('あいうえお',35,1,measure),['あいうえお']);
// (a2) dependency graph view model
{const data=c.graphData(),before=clone(fixture),placed=c.graphViewModel({data,source:fixture,version:'',selected:'',measure,hasDocuments:()=>false}).children.filter(s=>s.intent&&s.intent.type==='node').map(s=>s.intent.id),sel=placed.find(id=>data.nodes.find(n=>n.id===id).kind!=='milestone');
 const v=c.graphViewModel({data,source:fixture,version:'',selected:sel,measure,hasDocuments:t=>c.taskDocumentPaths(t).length>0});
 assert.deepEqual(clone(fixture),before,'deriving never changes the data');
 assert.equal(v.tag,'svg');assert.equal(v.attrs['aria-label'],'全taskの明示依存グラフ');assert.equal(v.children[0].tag,'defs');
 const nodes=v.children.filter(s=>s.intent&&s.intent.type==='node'),rels=v.children.filter(s=>s.intent&&s.intent.type==='relation'),docs=v.children.filter(s=>s.intent&&s.intent.type==='documents');
 assert(nodes.length>10&&rels.length>5);
 const selNode=nodes.find(s=>s.intent.id===sel);assert.equal(selNode.children[0].attrs.fill,'#d4edbc');assert.equal(selNode.children[0].attrs.stroke,'#126c58');
 assert(nodes.filter(s=>s.intent.id!==sel).every(s=>s.children[0].attrs.fill!=='#d4edbc'),'only the selected node is highlighted');
 const ms=nodes.find(s=>data.nodes.find(n=>n.id===s.intent.id)?.kind==='milestone'&&s.intent.id!==sel);assert.equal(ms.children[0].attrs.fill,'#fff1c9');
 for(const r of rels){assert(data.edges.includes(r.intent.edge)||data.edges.some(e=>e===r.intent.edge),'a relation intent carries the drawn edge itself');assert(v.children.includes(r.intent.line),'and its visible line');assert.equal(r.attrs.d,r.intent.line.attrs.d);}
 for(const d of docs)assert(!d.intent.node.proposal&&c.taskDocumentPaths(d.intent.node).length>0,'document links only for tasks with documents');
 assert(nodes.every(s=>typeof s.intent.tip==='string'&&s.intent.tip.startsWith(s.intent.id)),'each node carries its tip text');
 assert.deepStrictEqual(JSON.stringify(c.graphViewModel({data,source:fixture,version:'',selected:sel,measure,hasDocuments:t=>c.taskDocumentPaths(t).length>0})),JSON.stringify(v),'pure: same input, same view model');
 // a version view with no lines still lists its cards in a row
 const folder=(fixture.milestones.find(m=>m.virtual&&m.id.startsWith('START-'))||{}).id?.slice(6);
 if(folder){const lv=c.graphViewModel({data,source:fixture,version:folder,selected:'',measure,hasDocuments:()=>false});assert(lv.children.some(s=>s.tag==='text'&&/途中のゲート|依存|前提/.test(s.text||'')),'a version view carries its note');}}
// H-20261019-20: the graph view model is closed over its inputs; changing only the global doc changes nothing.
{const data=c.graphData(),args=v=>({data,source:fixture,version:v,selected:'',measure,hasDocuments:()=>true});
 for(const v of ['','@head',(fixture.milestones.find(m=>m.virtual&&m.id.startsWith('START-'))||{}).id?.slice(6)].filter(x=>x!==undefined)){
  const a=JSON.stringify(c.graphViewModel(args(v)));const saved=c.doc;
  c.doc={...clone(fixture),milestoneHead:'9.9.9',milestones:[]};const b=JSON.stringify(c.graphViewModel(args(v)));c.doc=saved;
  assert.equal(b,a,'version '+JSON.stringify(v)+': the view model ignores the global doc');}}
// (a3) independent strip, card list, permanent map
{const groups=c.independentGroups(fixture),reg=groups.regular,prop=reg.find(t=>t.proposal),pick=reg.find(t=>!t.proposal);
 const v=c.independentViewModel(reg,pick&&pick.id,t=>c.taskDocumentPaths(t).length>0);
 assert.equal(v.count,reg.length+'件');assert.equal(v.items.length,reg.length);
 if(pick){const it=v.items.find(i=>i.id===pick.id);assert.equal(it.className,'task selected');assert.equal(it.selected,true);assert(it.title.includes('\n担当：'));}
 if(prop){const it=v.items.find(i=>i.id===prop.id);assert(it.className.endsWith(' proposal'));assert.equal(it.heading,prop.id+' · 追加案');assert(it.title.includes('追加案（正式採番前）'));assert.equal(it.documents,false);}
 assert.deepEqual(clone(c.independentViewModel([],'',()=>false)),{count:'0件',empty:'該当するタスクはありません。',items:[]});}
{const g=c.cardListGroups(fixture,'grouped'),sel=fixture.tasks[0].id,v=c.cardListViewModel(g,sel,()=>[]);
 assert.equal(v.count,g.reduce((n,x)=>n+x.cards.length,0)+'件');assert.equal(v.groups.length,g.filter(x=>x.cards.length).length,'empty groups are not shown');
 assert(v.groups.every(x=>/（\d+件）$/.test(x.heading)));const card=v.groups.flatMap(x=>x.cards).find(x=>x.id===sel);assert(card.className.startsWith('task selected'));
 const msCard=v.groups.flatMap(x=>x.cards).find(x=>x.heading.endsWith(' · 到達点'));assert(msCard,'milestones are marked');}
{const groups=c.permanentMapData(fixture),sel=groups[0].task.id,v=c.permanentMapViewModel(groups,sel,measure);
 assert.equal(v.count,groups.length+'件');assert.equal(v.svg.attrs['aria-label'],'恒久タスクと正本の参照関係');
 const acts=[];walk(v.svg,s=>{if(s.action)acts.push(s.action);});
 assert(acts.some(a=>a.intent.type==='select'&&a.intent.id===sel));assert(acts.every(a=>['select','documents','document'].includes(a.intent.type)));
 const selCard=v.svg.children.find(s=>s.action&&s.action.intent.id===sel);assert.equal(selCard.children[0].attrs['stroke-width'],3);}
// (a4) selection sharing: one selected id is marked in every map built from the same input
{const sel=fixture.tasks.find(t=>t.permanent).id,data=c.graphData();
 const gv=c.graphViewModel({data,source:fixture,version:'',selected:sel,measure,hasDocuments:()=>false}),pv=c.permanentMapViewModel(c.permanentMapData(fixture),sel,measure),cv=c.cardListViewModel(c.cardListGroups(fixture,'id'),sel,()=>[]);
 const inGraph=gv.children.find(s=>s.intent&&s.intent.id===sel);if(inGraph)assert.equal(inGraph.children[0].attrs.fill,'#d4edbc');
 assert.equal(pv.svg.children.find(s=>s.action&&s.action.intent.id===sel).children[0].attrs.fill,'#edf6ef');
 assert(cv.groups.flatMap(x=>x.cards).find(x=>x.id===sel).selected);}
// (b0) fixed view models -> DOM: the independent strip and the card list draw the document flag and band colors as given.
{const item=(id,documents,band)=>({id,node:{id},selected:false,className:'task',heading:id,text:'t',state:'X',band,title:'T',documents});
 const strip=new Node('div'),count=new Node('span'),opened=[],chosen=[];
 c.drawIndependent(strip,count,{count:'2件',empty:'none',items:[item('A',true,{text:'X',bg:'#123456',fg:'#abcdef'}),item('B',false,{text:'Y',bg:'#000',fg:'#fff'})]},{select:id=>chosen.push(id),openDocuments:n=>opened.push(n.id)});
 assert.equal(count.textContent,'2件');assert.equal(strip.children.length,2);
 const [sa,sb]=strip.children;assert.equal(sa.children.length,2,'the document flag adds the link even if the task has no paths');assert.equal(sb.children.length,1,'no flag, no link');
 const band=sa.children[0].children[2];assert.equal(band.textContent,'X');assert.equal(band.style.background,'#123456');assert.equal(band.style.color,'#abcdef','band colors are drawn as given');
 sa.children[0].onclick();sa.children[1].onclick({preventDefault(){},stopPropagation(){}});assert.deepEqual([chosen,opened],[['A'],['A']],'intents only');
 const box=new Node('div'),cnt=new Node('span'),docs=[],multi=[];
 c.drawCardList(box,cnt,{count:'1件',groups:[{heading:'G（1件）',cards:[{id:'C',selected:true,className:'task selected',heading:'C',text:'t',state:'Z',band:{text:'Z',bg:'#010203',fg:'#040506'},paths:['p1','p2']}]}]},{select(){},openDocument:p=>docs.push(p),openDocuments:(id,paths)=>multi.push([id,paths])});
 assert.equal(cnt.textContent,'1件');assert.equal(box.children[0].textContent,'G（1件）');const shell=box.children[1].children[0];assert.equal(shell.children[0].children[2].style.background,'#010203');
 shell.children[1].onclick({preventDefault(){},stopPropagation(){}});assert.deepEqual(multi,[['C',['p1','p2']]],'several paths: the choice is an intent');}
// (b) fixed view model -> SVG and intents
{const spec={tag:'svg',attrs:{width:10,height:5},children:[{tag:'path',attrs:{d:'M0 0'},children:[{tag:'title',attrs:{},text:'t'}]},{tag:'g',attrs:{},children:[{tag:'rect',attrs:{x:1}}],action:{title:'A を選ぶ',intent:{type:'select',id:'A'}}},{tag:'g',attrs:{class:'node'},intent:{type:'node',id:'B'}}]};
 const got=[];const n=c.drawSvgSpec(spec,(intent,node,made)=>got.push([intent.type,intent.id,node.tag,made.get(spec.children[0]).tag]));
 assert.equal(n.outer,'<svg width="10" height="5"><path d="M0 0"><title>t</title></path><g tabindex="0" role="button" aria-label="A を選ぶ" style="cursor: pointer;"><rect x="1"></rect><title>A を選ぶ</title></g><g class="node"></g></svg>','drawn in order; an action adds tabindex, role, label, cursor and a title after its children');
 assert.deepEqual(got,[['node','B','g','path']],'a plain intent is handed to the binder while drawing');
 n.children[1].onclick();assert.deepEqual(got.at(-1).slice(0,3),['select','A','g'],'an action reports its intent on click');
 let prevented=false;n.children[1].onkeydown({key:'Enter',preventDefault:()=>{prevented=true;}});assert(prevented&&got.length===3,'Enter acts like a click');
 n.children[1].onkeydown({key:'x',preventDefault:()=>{throw Error('no');}});assert.equal(got.length,3,'other keys do nothing');}
// The views draw what they are given: no history or grouping logic inside them.
{for(const name of ['drawIndependent','drawCardList'])assert(!/stateStyle\(|stateBand\(|taskDocumentPaths\(|cardDocumentPaths\(|cardWithDocuments\(/.test(fn(name)),'the '+name+' view decides no color or documents');
 for(const name of ['graph','permanentMap','independent','renderCards']){const src=fn(name);assert(!/graphLayout\(|versionView\(|wrapLines\(|stateStyle\(|cardListGroups\([^)]*\)\.filter/.test(src)||name==='renderCards'&&!/graphLayout\(|wrapLines\(/.test(src),'the '+name+' view does not lay out or wrap');}}
console.log('PASS: OPS-154 task maps (wrapLines; graph / independent / card list / permanent view models: highlight, intents carrying the drawn data, documents, purity and no data change; selection shared across maps; the graph view model ignores the global doc; fixed view models -> DOM (document flag, band colors) and SVG with intents; the views do not lay out).');
