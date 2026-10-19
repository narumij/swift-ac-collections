// OPS-126 proposals 4 and 6: local-map titles use two lines; the plan editor in the card list is a closed-by-default
// details whose open state survives re-renders. Isolated tests of the actual code; no browser.
const fs=require('fs'),vm=require('vm'),assert=require('assert');
const html=fs.readFileSync(__dirname+'/index.template.html','utf8');
const from=html.indexOf('// OPS-126 proposal 4'),to=html.indexOf('function renderNeighborhood(){');assert(from>=0&&to>from);
const c={};vm.createContext(c);vm.runInContext(html.slice(from,to),c);

// 4. Two-line titles: short stays one line, long wraps to two and ends with an ellipsis; the width is respected.
const width=190,measure=s=>[...s].reduce((n,ch)=>n+(ch.charCodeAt(0)>255?12:7),0);
assert.deepEqual([...c.twoLineTitle('短い題名',width,measure)],['短い題名']);
const long='Swift Package Index公開導線のREADME・Pages反映と、その後の確認と記録の整理まで含めた長い題名';
const two=c.twoLineTitle(long,width,measure);assert.equal(two.length,2,'wraps to two lines');
assert(two[1].endsWith('…'),'the second line ends with an ellipsis when cut');
for(const line of two)assert(measure(line)<=width,'each line fits: '+line);
assert(long.startsWith(two[0]),'the first line is the start of the text');
const exact=c.twoLineTitle('あ'.repeat(15)+'い'.repeat(15),width,measure);assert.equal(exact.length,2);assert(!exact[1].endsWith('…'),'no ellipsis when it fits in two lines');
assert.equal(c.twoLineTitle('',width,measure).length,0,'empty title has no lines');
// Without a canvas measure, the character estimate still keeps two lines.
assert(c.twoLineTitle(long,width,null).length<=2);
// The old 16-character cut is gone; the full text is kept in the card's <title>.
assert(!html.includes(".slice(0,16)));"),'no fixed 16-character cut');
// OPS-154 stage 2 moved the card into neighborhoodViewModel/drawNeighborhood: check the behavior on fixture b instead of source text.
{const fn=name=>{const a=html.indexOf('\nfunction '+name+'(');assert(a>=0,name);const m=/\)\s*\{/g;m.lastIndex=a;let i=html.indexOf('{',m.exec(html).index),d=0;for(;i<html.length;i++){if(html[i]==='{')d++;else if(html[i]==='}'&&--d===0)break;}return html.slice(a+1,i+1);};
 class Node{constructor(tag){this.tag=tag;this.children=[];this.attrs={};this.style={};this.textContent='';}setAttribute(k,v){this.attrs[k]=String(v);}append(...ns){this.children.push(...ns);}appendChild(n){this.children.push(n);}replaceChildren(...ns){this.children=ns;}}
 const d={document:{createElementNS:(ns,t)=>new Node(t),createElement:t=>new Node(t)}};vm.createContext(d);
 vm.runInContext(['el','svg','stateStyle','proposalNodes','twoLineTitle','neighborhood','neighborhoodLayout','wrapLines','drawSvgSpec','neighborhoodViewModel','drawNeighborhood'].map(fn).join('\n'),d);
 const data=JSON.parse(fs.readFileSync(__dirname+'/task-view-model-fixture-b.json','utf8'));
 const center=data.edges.map(e=>data.tasks.find(t=>t.id===e.prerequisite)).find(t=>t&&measure(t.id+' '+t.item)>2*width);assert(center,'fixture has a linked task with a long title');
 const model=d.neighborhoodViewModel({data,center:center.id,expanded:new Set(),measure:null,documentPaths:()=>[]});
 const box=new Node('div'),count=new Node('span'),picked=[];d.drawNeighborhood(box,count,model,{select:id=>picked.push(id),reset(){},center(){},expand(){},documents(){}});
 const all=n=>[n,...n.children.flatMap(all)],cards=all(box).filter(n=>n.tag==='g'&&n.onclick);assert(cards.length>=2,'cards are drawn');
 const card=cards.find(g=>g.children.some(x=>x.tag==='title'&&x.textContent===center.id+' '+center.item));assert(card,'full title in the card');
 card.onclick();assert.deepEqual(picked,[center.id],'clicking a local-map card still selects it');}

// 6. Plan editor: closed by default, open state kept on the function across re-renders, summary shows pending input/changes.
assert(html.includes("box.id='planToolsDetails';box.open=!!renderPlanTools.open;"),'closed by default, restored on render');
assert(html.includes("box.ontoggle=()=>{renderPlanTools.open=box.open;summary.textContent=note();};"),'open state remembered');
assert(html.includes("(planDraftPending()?' · 入力途中あり':'')"),'pending input visible while closed');
assert(html.includes("' · 計画の変更'+planChangeCount+'件'"),'unsaved plan changes visible while closed');
for(const id of ['planAddVersionOf','planAddName','planNewVersion'])assert(html.includes("id='"+id+"'")||html.includes(".id='"+id+"'"),id+' still exists');
assert(html.includes('nm.value=planDraft.name;')&&html.includes('vn.value=planDraft.versionName;'),'typed values are restored from planDraft');
console.log('PASS: OPS-126 proposals 4 (two-line local-map titles, full text kept) and 6 (plan editor folded, state and pending input kept).');
