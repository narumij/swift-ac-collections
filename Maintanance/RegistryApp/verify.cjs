const fs=require('fs'),vm=require('vm'),assert=require('assert');
const html=fs.readFileSync(require('path').join(__dirname,'index.html'),'utf8');const script=html.split('<script>')[1].split('</script>')[0];new vm.Script(script);const d=JSON.parse(fs.readFileSync(require('path').join(__dirname,'registry.json'),'utf8'));
const checkSource=script.slice(script.indexOf('function check('),script.indexOf('function el('));const deltaSource=script.slice(script.indexOf('function delta('),script.indexOf('function banner('));const ctx={doc:d};vm.createContext(ctx);vm.runInContext(checkSource+'\n'+deltaSource,ctx);ctx.check(d);const regRows=(()=>{const md=require('fs').readFileSync(require('path').resolve(__dirname,'../..',d.source.path),'utf8').split('\n');let sec='',grp=null,t=0,e=0;for(const l of md){if(l.startsWith('## ')){sec=l.slice(3).trim();grp=null;}else if(l.startsWith('### '))grp=l.slice(4).trim();if(!l.startsWith('| `'))continue;if(sec==='Task Registry')t++;else if(sec==='Task precedence'&&grp===null)e++;}return {t,e};})();assert.equal(d.tasks.length,regRows.t);assert.equal(d.edges.length,regRows.e);assert.equal(ctx.delta().length,0);
const copy=x=>JSON.parse(JSON.stringify(x));const original=copy(d);d.tasks.find(t=>t.id==='OPS-059').condition='編集確認';assert.equal(ctx.delta()[0].old,original.tasks.find(t=>t.id==='OPS-059').condition);assert.equal(ctx.delta()[0].new,'編集確認');assert.deepEqual(d.baseline,original.baseline);
d.edges.push({successor:'OPS-059',prerequisite:'PERM-060',flow:'SEQUENCE',constraint:'確認'});ctx.check(d);assert.equal(ctx.delta().length,2);const reloaded=JSON.parse(JSON.stringify(d));ctx.check(reloaded);assert.deepEqual(reloaded,d);
function rejects(mutator){let x=copy(original);mutator(x);assert.throws(()=>ctx.check(x));}
rejects(x=>x.edges.push(copy(x.edges[0])));rejects(x=>x.edges.push({successor:'OPS-048',prerequisite:'OPS-048',flow:'SEQUENCE',constraint:''}));rejects(x=>x.edges.push({successor:'OPS-048',prerequisite:'MISSING',flow:'SEQUENCE',constraint:''}));rejects(x=>x.edges.push({successor:'OPS-048',prerequisite:'PERM-060',flow:'bad',constraint:''}));rejects(x=>x.edges.push({successor:'OPS-048',prerequisite:'PERM-060',flow:'SEQUENCE',constraint:''},{successor:'PERM-060',prerequisite:'OPS-048',flow:'SEQUENCE',constraint:''}));rejects(x=>x.tasks.push(copy(x.tasks[0])));rejects(x=>x.tasks.pop());rejects(x=>x.schemaVersion=2);
let unknown=copy(original);unknown.tasks[0].state='FUTURE_STATE';unknown.extra='retain me';ctx.check(unknown);assert.equal(JSON.parse(JSON.stringify(unknown)).extra,'retain me');console.log('PASS: JS syntax; '+d.tasks.length+' tasks / '+d.edges.length+' edges (= Registry rows); edit deltas; unchanged baseline; JSON roundtrip; duplicate/self/dangling/invalid-flow/cycle checks; duplicate/deleted task rejection; version rejection; unknown state and extra-field retention.');console.log('Not tested: DOM rendering, actual file download, Safari UI.');

const layoutSource=script.slice(script.indexOf('function graphLayout('),script.indexOf('function independentGroups('));vm.runInContext(layoutSource,ctx);
const fixture=['A','B','C','D','E','F'].map(id=>({id})),links=['A','B','C'].map(prerequisite=>({prerequisite,successor:'F'}));
const layout=ctx.graphLayout(fixture,links);assert(!layout.pos.has('D'));assert(!layout.pos.has('E'));for(const id of ['A','B','C'])assert(layout.pos.get(id)[0]<layout.pos.get('F')[0]);
const actual=ctx.graphLayout(original.tasks,original.edges);const connected=new Set(original.edges.flatMap(e=>[e.prerequisite,e.successor]));assert.equal(actual.pos.size,connected.size);for(const edge of original.edges)assert(actual.pos.get(edge.prerequisite)[0]<actual.pos.get(edge.successor)[0]);assert.equal(new Set([...actual.pos.values()].map(p=>p.join(','))).size,connected.size);assert.equal(ctx.graphLayout(fixture,[]).pos.size,0);console.log('PASS: independent nodes excluded from graph; all connected nodes retained; all edges left-to-right; no overlap; empty-edge graph.');
vm.runInContext(script.slice(script.indexOf('function graphData('),script.indexOf('function graphLayout(')),ctx);ctx.doc=original;let visual=ctx.graphData(),placed=ctx.graphLayout(visual.nodes,visual.edges);assert(original.milestones.length>0);for(const e of visual.edges)assert((placed.pos.get(e.prerequisite)[0]<placed.pos.get(e.successor)[0]||(placed.pos.get(e.prerequisite)[0]===placed.pos.get(e.successor)[0]&&placed.pos.get(e.prerequisite)[1]<placed.pos.get(e.successor)[1])));for(const id of ['GATE-0.6.0','GATE-0.7.0','MS-SPI','MS-HUMAN','MS-QUALITY'])assert(placed.pos.has(id));assert.equal(new Set([...placed.pos.values()].map(p=>p.join(','))).size,placed.pos.size);assert(original.milestoneRelations.some(e=>e.prerequisite==='PERM-079'&&e.successor==='END-0.6.0'&&e.relation==='resume'));assert(original.milestoneRelations.some(e=>e.prerequisite==='MS-VALIDATION'&&e.successor==='END-0.6.0'&&e.relation==='required'));rejects(x=>x.milestoneRelations[0].successor='MISSING');rejects(x=>x.milestoneRelations[0].relation='unknown');console.log('PASS: milestone backbone, 17 sourced relations, release-after decision, Validation gate, combined DAG, no overlap, invalid relation rejection.');

vm.runInContext(script.slice(script.indexOf('function independentGroups('),script.indexOf('function independent(){')),ctx);const groups=ctx.independentGroups(original);assert(groups.permanent.every(t=>t.permanent));assert(groups.regular.every(t=>!t.permanent));const expected=original.tasks.filter(t=>!visual.edges.some(e=>e.prerequisite===t.id||e.successor===t.id)&&!original.tasks.some(parent=>parent.id===t.parentTask));assert.equal(groups.regular.length+groups.permanent.length,expected.length);assert.equal(new Set([...groups.regular,...groups.permanent].map(t=>t.id)).size,expected.length);console.log('PASS: independent regular/permanent partition, no omissions or duplicates.');

// Preserve historical coordinate regression checks on the pre-gate fixture.
// Current expanded graph is checked above for coverage, direction and collisions.
const historical=JSON.parse(fs.readFileSync(require('path').join(__dirname,'completed-document-layout-fixture.json'),'utf8'));ctx.doc=historical;visual=ctx.graphData();placed=ctx.graphLayout(visual.nodes,visual.edges);ctx.doc=original;
const expandedVisual=visual,expandedPlaced=placed;
const newGateIds=new Set(['DOC-033','DOC-034','DOC-035','DOC-036','DOC-037','DOC-038','DOC-039','MS-080']);
visual={nodes:visual.nodes.filter(n=>!newGateIds.has(n.id)),edges:visual.edges.filter(e=>!newGateIds.has(e.prerequisite)&&!newGateIds.has(e.successor))};
placed=ctx.graphLayout(visual.nodes,visual.edges);
assert(placed.pos.get("MS-060")[0]<placed.pos.get("PERM-079")[0]);assert(placed.pos.get("PERM-079")[0]<placed.pos.get("MS-070")[0]);console.log("PASS: display-only PERM-079 placement between 0.6 and 0.7.");

assert.equal(placed.pos.get("RELEASE-075")[1]-placed.pos.get("MS-060")[1],2*Math.abs(placed.pos.get("MS-VALIDATION")[1]-placed.pos.get("MS-060")[1])+20);console.log("PASS: release stack at twice milestone vertical spacing.");

assert(placed.pos.get("PERM-079")[1]<placed.pos.get("MS-060")[1]);assert(placed.pos.get("PERM-079")[1]<placed.pos.get("MS-070")[1]);console.log("PASS: PERM-079 above milestone backbone.");

for(const [a,b] of [["MS-VALIDATION","RELEASE-075"],["RELEASE-075","RELEASE-076"],["RELEASE-076","RELEASE-072"]]){if(a!=='MS-VALIDATION')assert.equal(placed.pos.get(a)[0],placed.pos.get(b)[0]);assert(placed.pos.get(a)[1]<placed.pos.get(b)[1]);}console.log("PASS: Validation / 075 / 076 / 072 vertical stack.");

ctx.copy=copy;ctx.doc=copy(original);ctx.formDirty=false;ctx.dirty=false;ctx.render=()=>{};ctx.report=()=>{};ctx.confirm=()=>false;
vm.runInContext(script.slice(script.indexOf('function initializeRelationBaseline('),script.indexOf('initializeRelationBaseline(doc);')),ctx);
vm.runInContext(script.slice(script.indexOf('function removeRelation('),script.indexOf('function graph(){')),ctx);
ctx.initializeRelationBaseline(ctx.doc);const before=copy(ctx.doc);ctx.removeRelation(ctx.doc.edges[0]);assert.deepEqual(ctx.doc,before);ctx.confirm=()=>true;
ctx.removeRelation(ctx.doc.edges[0]);assert.equal(ctx.doc.edges.length,before.edges.length-1);
ctx.removeRelation({...ctx.doc.milestoneRelations[0],flow:'PARALLEL_JOIN'});assert.equal(ctx.doc.milestoneRelations.length,before.milestoneRelations.length-1);assert.deepEqual(ctx.doc.baseline,before.baseline);
assert(ctx.delta().some(x=>x.field==='edges'));assert(ctx.delta().some(x=>x.field==='milestoneRelations'));const saved=JSON.parse(JSON.stringify(ctx.doc));ctx.check(saved);ctx.initializeRelationBaseline(saved);assert.deepEqual(saved.baseline,before.baseline);
ctx.formDirty=true;const unchanged=copy(ctx.doc);ctx.removeRelation(ctx.doc.edges[0]);assert.deepEqual(ctx.doc,unchanged);
console.log('PASS: relation removal cancellation, task/milestone removal, preserved baseline, exported differences, reload and pending-input guard.');

const base=copy(original),edge=base.edges.find(e=>e.prerequisite==='RELEASE-075'),untouched=copy(base);
const rewired=ctx.rewireRelation(base,edge,'OPS-048','OPS-059');ctx.check(rewired);assert.deepEqual(base,untouched);assert.deepEqual(rewired.baseline,base.baseline);assert(rewired.edges.some(e=>e.prerequisite==='OPS-048'&&e.successor==='OPS-059'&&e.constraint===edge.constraint));
assert.throws(()=>ctx.rewireRelation(base,edge,'OPS-048','OPS-048'));
assert.throws(()=>ctx.rewireRelation(base,edge,'MISSING','OPS-059'));
assert.throws(()=>ctx.rewireRelation(base,edge,base.edges[0].prerequisite,base.edges[0].successor));
assert.throws(()=>ctx.rewireRelation(base,edge,'QUALITY-001','RBT-001'));
const relation=base.milestoneRelations[0],moved=ctx.rewireRelation(base,relation,'GATE-0.6.0','OPS-048');ctx.check(moved);assert.deepEqual(moved.milestoneRelations[0].source,relation.source);assert.deepEqual(base,untouched);
ctx.doc=rewired;assert(ctx.delta().some(x=>x.field==='edges'));ctx.doc=moved;ctx.initializeRelationBaseline(ctx.doc);console.log('PASS: transactional rewiring, retained evidence/baseline, task and milestone endpoints, self/duplicate/dangling/cycle rejection.');

assert.equal(placed.pos.get('PERM-079')[0]-placed.pos.get('MS-060')[0],295);
assert(Math.abs(placed.pos.get('MS-070')[0]-placed.pos.get('PERM-079')[0]-250*(3-Math.sqrt(5))/2)<1e-9);
console.log('PASS: requested node-edge spacing (45px gap, golden-ratio stagger).');

for(const id of ['RELEASE-075','RELEASE-076','RELEASE-072'])assert(Math.abs(placed.pos.get(id)[0]-placed.pos.get('MS-060')[0]-250*(3-Math.sqrt(5))/2)<1e-9);

assert(Math.abs(placed.pos.get('RELEASE-078')[0]-placed.pos.get('MS-DOC')[0]-250*(3-Math.sqrt(5))/2)<1e-9);

assert.equal(placed.pos.get('RELEASE-078')[1]-placed.pos.get('MS-DOC')[1],placed.pos.get('RELEASE-075')[1]-placed.pos.get('MS-VALIDATION')[1]);

assert.equal(placed.pos.get('QUALITY-005')[1]-placed.pos.get('MS-070')[1],placed.pos.get('RELEASE-075')[1]-placed.pos.get('MS-VALIDATION')[1]);

for(const [a,b] of [['MS-SPI','MS-HUMAN'],['MS-HUMAN','QUALITY-001']])assert(Math.abs(placed.pos.get(b)[0]-placed.pos.get(a)[0]-442.5)<1e-9);

function assertGeometry(result,nodes,edges){
 const ids=new Set(edges.flatMap(e=>[e.prerequisite,e.successor]));assert.equal(result.pos.size,ids.size);
 const boxes=[...result.pos.values()];for(let i=0;i<boxes.length;i++)for(let j=0;j<i;j++)assert(Math.abs(boxes[i][0]-boxes[j][0])>=250||Math.abs(boxes[i][1]-boxes[j][1])>=96,'card overlap');
 for(const e of edges){const a=result.pos.get(e.prerequisite),b=result.pos.get(e.successor);assert(a[0]<b[0]||(a[0]===b[0]&&a[1]<b[1]));}
}
assert(!placed.fallback);assertGeometry(placed,visual.nodes,visual.edges);
for(const removed of visual.edges){const remaining=visual.edges.filter(e=>e!==removed);assertGeometry(ctx.graphLayout(visual.nodes,remaining),visual.nodes,remaining);}
const extraNodes=[...visual.nodes,{id:'NEW'}],extraEdges=[...visual.edges,{prerequisite:'NEW',successor:'MS-070'}];const extra=ctx.graphLayout(extraNodes,extraEdges);assert(!extra.fallback);assertGeometry(extra,extraNodes,extraEdges);
const reversed=visual.edges.filter(e=>!(e.prerequisite==='MS-060'&&e.successor==='PERM-079')).concat({prerequisite:'PERM-079',successor:'MS-060'});const rerouted=ctx.graphLayout(visual.nodes,reversed);assert(!rerouted.fallback);assertGeometry(rerouted,visual.nodes,reversed);
assert.deepEqual(ctx.graphLayout(visual.nodes,visual.edges).pos,placed.pos);
console.log('PASS: rectangle collision checks, each-edge removal, new-node and rewired-edge regrouping, deterministic placement.');

vm.runInContext(script.slice(script.indexOf('function taskDocumentPaths('),script.indexOf('function cardWithDocuments(')),ctx);
vm.runInContext(script.slice(script.indexOf('function permanentMapData('),script.indexOf('function permanentMap(){')),ctx);
const permanent=ctx.permanentMapData(original);assert.equal(permanent.length,10);assert(permanent.every(g=>g.documents.length));assert.deepEqual(permanent.map(g=>g.task.id),original.tasks.filter(t=>t.permanent).sort((a,b)=>(b.displayInterest?.score??0)-(a.displayInterest?.score??0)).map(t=>t.id));
const controls=Object.fromEntries(['dependencyView','permanentView','dependencyTab','permanentTab','protectionView','protectionTab'].map(id=>[id,{setAttribute(k,v){this[k]=v;}}]));ctx.$=id=>controls[id];vm.runInContext(script.slice(script.indexOf('function switchMap('),script.indexOf("for(const id of ['dependencyTab'")),ctx);ctx.switchMap(true);assert(controls.dependencyView.hidden);assert(!controls.permanentView.hidden);assert.equal(controls.permanentTab['aria-selected'],'true');ctx.switchMap(false);assert(!controls.dependencyView.hidden);assert(controls.permanentView.hidden);assert(!html.includes('id="taskPane"'));assert(!html.includes('id="toggleTasks"'));
console.log('PASS: permanent map coverage, tab switching, removed sidebar.');

const reference=JSON.parse(fs.readFileSync(require('path').join(__dirname,'layout-reference.json'),'utf8'));for(const [id,position] of Object.entries(reference))if(placed.pos.has(id))assert.deepEqual(placed.pos.get(id),position);
assert(!placed.fallback);
assert.deepEqual(Array.from(placed.backbone),['MS-DOC','MS-060','MS-070','MS-SPI','MS-HUMAN','QUALITY-001']);
assert(placed.branches.some(b=>b.kind==='route'&&b.ids.includes('QUALITY-005')&&b.ids.includes('DOC-027')));
assert(placed.branches.some(b=>b.kind==='feeder'&&b.ids.includes('RELEASE-075')));
const rename=new Map(visual.nodes.map((n,i)=>[n.id,'node-'+i]));const renamed=ctx.graphLayout(visual.nodes.map(n=>({...n,id:rename.get(n.id)})),visual.edges.map(e=>({...e,prerequisite:rename.get(e.prerequisite),successor:rename.get(e.successor)})));for(const [id,p] of placed.pos)assert.deepEqual(renamed.pos.get(rename.get(id)),p);assert(!renamed.fallback);
console.log('PASS: exact pre-advice geometry, automatic backbone/branch classification, ID-independent layout.');

assert(groups.regular.every((t,i,a)=>t.state==='DONE'||!a.slice(0,i).some(x=>x.state==='DONE')));
assert.equal(permanent.find(g=>g.task.id==='OPS-048').children.length,original.tasks.filter(t=>t.parentTask==='OPS-048').length);
assert(permanent.some(g=>g.task.id==='HIST-003'&&g.task.state==='ACTIVE'));

assert(!groups.regular.some(t=>['OPS-049','OPS-050','OPS-059','OPS-052'].includes(t.id)));
assert(permanent.find(g=>g.task.id==='OPS-048').children.some(t=>t.id==='OPS-059'));

vm.runInContext(script.slice(script.indexOf('function protectionRecords('),script.indexOf('function renderProtection(')),ctx);
assert.equal(ctx.protectionRecords(original).length,18);
assert.equal(ctx.protectionDays('2026-10-16','2026-10-16'),'1日目');
assert.equal(ctx.protectionDays('2026-10-15','2026-10-16'),'2日目');
assert.equal(ctx.protectionDays('不明','2026-10-16'),'不明');
ctx.switchMap('protection');assert(!controls.protectionView.hidden);assert(controls.dependencyView.hidden&&controls.permanentView.hidden);

const protectionFixture={tasks:[{id:'TEST',detail:'`Maintanance/RegistryApp/index.html`（配置維持; 区分=暫定保護; 付与日=2026-10-16; 記録日=2026-10-16; 記録者=Astra; 理由=誤読（旧名）を防ぐ; A; B） / `README.md`（配置維持; 区分=恒久希望; 付与日=不明; 理由=次の文書）'}]};
const protections=ctx.protectionRecords(protectionFixture);
assert.equal(protections.length,2);assert.equal(protections[0].path,'Maintanance/RegistryApp/index.html');assert.equal(protections[0]['理由'],'誤読（旧名）を防ぐ; A; B');assert.equal(protections[0]['記録日'],'2026-10-16');assert.equal(protections[1].path,'README.md');
for(const date of ['2026-1-5','2026-02-30','2026-13-01','2026-10-17'])assert.equal(ctx.protectionDays(date,'2026-10-16'),'日付要確認');
assert.equal(ctx.protectionDays('2024-02-29','2024-03-01'),'2日目');
assert(html.includes("'経過','記録日','記録者'"));
console.log('PASS: protection paths, parentheses and semicolons, multiple marks, invalid dates, leap day and recording date column.');

assertGeometry(expandedPlaced,expandedVisual.nodes,expandedVisual.edges);
for(const id of newGateIds)assert(expandedPlaced.pos.has(id));
console.log('PASS: expanded documentation gate graph coverage and geometry; fallback:',!!expandedPlaced.fallback);

assert(!expandedPlaced.fallback,'first-milestone feeders must not trigger whole-graph fallback');
assert(expandedPlaced.pos.get('DOC-034')[0]<expandedPlaced.pos.get('MS-DOC')[0]);
const expandedRename=new Map(expandedVisual.nodes.map((n,i)=>[n.id,'expanded-'+i]));
const expandedRenamed=ctx.graphLayout(expandedVisual.nodes.map(n=>({...n,id:expandedRename.get(n.id)})),expandedVisual.edges.map(e=>({...e,prerequisite:expandedRename.get(e.prerequisite),successor:expandedRename.get(e.successor)})));
assert(!expandedRenamed.fallback);
for(const [id,p] of expandedPlaced.pos)assert.deepEqual(expandedRenamed.pos.get(expandedRename.get(id)),p);
const firstFeed=[{id:'m1',kind:'milestone'},{id:'m2',kind:'milestone'},{id:'f1'},{id:'f2'}];
const firstEdges=[{prerequisite:'m1',successor:'m2'},{prerequisite:'f1',successor:'f2',flow:'SEQUENCE'},{prerequisite:'f2',successor:'m1'}];
const firstLayout=ctx.graphLayout(firstFeed,firstEdges);assert(!firstLayout.fallback);assertGeometry(firstLayout,firstFeed,firstEdges);
console.log('PASS: leading feeder column, no global fallback, renamed IDs and first-milestone chain.');

assert(historical.edges.some(e=>e.prerequisite==='DOC-034'&&e.successor==='DOC-037'));assert(historical.edges.some(e=>e.prerequisite==='DOC-037'&&e.successor==='DOC-035'));assert(!historical.edges.some(e=>e.prerequisite==='DOC-034'&&e.successor==='DOC-035'));

assert(!original.tasks.some(t=>t.state==='DONE'), 'completed tasks have moved to evidence archives');

// Sequential restriction (2026-10-17 user decision): milestones form a single chain, no branch or join.
{const ms=new Set(original.milestones.map(m=>m.id)),mm=original.milestoneRelations.filter(e=>ms.has(e.prerequisite)&&ms.has(e.successor));
 const next=new Map(),prev=new Map();for(const e of mm){assert(!next.has(e.prerequisite),'milestone branch at '+e.prerequisite);assert(!prev.has(e.successor),'milestone join at '+e.successor);next.set(e.prerequisite,e.successor);prev.set(e.successor,e.prerequisite);}
 const heads=[...ms].filter(id=>!prev.has(id));assert.equal(heads.length,1,'milestones must form one chain: '+heads.join(','));
 let n=0;for(let id=heads[0];id;id=next.get(id)){n++;assert(n<=ms.size,'milestone cycle');}assert.equal(n,ms.size,'milestones must form one chain');
 console.log('PASS: milestones form one sequential chain ('+n+').');}

// Only END-xyz may enter a version gate; a version gate leads only to the next milestone (2026-10-17).
{const ms=new Set(original.milestones.map(m=>m.id));
 for(const e of original.milestoneRelations){
  if(e.successor.startsWith('GATE-'))assert(e.prerequisite.startsWith('END-'),'only END may enter '+e.successor+' (got '+e.prerequisite+')');
  if(e.prerequisite.startsWith('GATE-'))assert(ms.has(e.successor),e.prerequisite+' may not lead to task '+e.successor);}
 console.log('PASS: version gates are entered only from END.');}

// Each version folder is a DAG rooted at its END: every gate of the folder, and every task feeding them,
// reaches the folder's END-xyz (2026-10-17). Cycles are rejected by the checks above.
{const ms=original.milestones,edges=original.edges.concat(original.milestoneRelations),next=new Map();
 for(const e of edges){if(!next.has(e.prerequisite))next.set(e.prerequisite,[]);next.get(e.prerequisite).push(e.successor);}
 const reaches=(from,to,seen=new Set())=>from===to||(!seen.has(from)&&(seen.add(from),(next.get(from)||[]).some(n=>reaches(n,to,seen))));
 const msIds=new Set(ms.map(m=>m.id));let checked=0;
 for(const end of ms.filter(m=>m.id.startsWith('END-'))){
  const folder=end.gate,members=new Set(ms.filter(m=>m.gate&&m.gate.startsWith(folder)&&!m.id.startsWith('GATE-')&&m.id!==end.id).map(m=>m.id));
  for(let grew=true;grew;){grew=false;for(const e of edges)if(members.has(e.successor)&&!members.has(e.prerequisite)&&!msIds.has(e.prerequisite)){members.add(e.prerequisite);grew=true;}}
  for(const e of original.milestoneRelations)if(e.successor===end.id&&!msIds.has(e.prerequisite))members.add(e.prerequisite);
  for(const id of members){assert(reaches(id,end.id),id+' does not reach '+end.id);checked++;}}
 console.log('PASS: every version folder is a DAG rooted at its END ('+checked+' nodes).');}
