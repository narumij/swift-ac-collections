const fs=require('fs'),vm=require('vm'),assert=require('assert');
const html=fs.readFileSync(require('path').join(__dirname,'index.html'),'utf8');const script=html.split('<script>')[1].split('</script>')[0];new vm.Script(script);const d=JSON.parse(fs.readFileSync(require('path').join(__dirname,'registry.json'),'utf8'));
const checkSource=script.slice(script.indexOf('function check('),script.indexOf('function el('));const deltaSource=script.slice(script.indexOf('function delta('),script.indexOf('function banner('));const ctx={doc:d};vm.createContext(ctx);vm.runInContext(checkSource+'\n'+deltaSource,ctx);ctx.check(d);assert.equal(d.tasks.length,38);assert.equal(d.edges.length,9);assert.equal(ctx.delta().length,0);
const copy=x=>JSON.parse(JSON.stringify(x));const original=copy(d);d.tasks.find(t=>t.id==='OPS-051').condition='編集確認';assert.equal(ctx.delta()[0].old,original.tasks.find(t=>t.id==='OPS-051').condition);assert.equal(ctx.delta()[0].new,'編集確認');assert.deepEqual(d.baseline,original.baseline);
d.edges.push({successor:'OPS-051',prerequisite:'OPS-049',flow:'SEQUENCE',constraint:'確認'});ctx.check(d);assert.equal(ctx.delta().length,2);const reloaded=JSON.parse(JSON.stringify(d));ctx.check(reloaded);assert.deepEqual(reloaded,d);
function rejects(mutator){let x=copy(original);mutator(x);assert.throws(()=>ctx.check(x));}
rejects(x=>x.edges.push(copy(x.edges[0])));rejects(x=>x.edges.push({successor:'OPS-048',prerequisite:'OPS-048',flow:'SEQUENCE',constraint:''}));rejects(x=>x.edges.push({successor:'OPS-048',prerequisite:'MISSING',flow:'SEQUENCE',constraint:''}));rejects(x=>x.edges.push({successor:'OPS-048',prerequisite:'OPS-049',flow:'bad',constraint:''}));rejects(x=>x.edges.push({successor:'OPS-048',prerequisite:'OPS-049',flow:'SEQUENCE',constraint:''},{successor:'OPS-049',prerequisite:'OPS-048',flow:'SEQUENCE',constraint:''}));rejects(x=>x.tasks.push(copy(x.tasks[0])));rejects(x=>x.tasks.pop());rejects(x=>x.schemaVersion=2);
let unknown=copy(original);unknown.tasks[0].state='FUTURE_STATE';unknown.extra='retain me';ctx.check(unknown);assert.equal(JSON.parse(JSON.stringify(unknown)).extra,'retain me');console.log('PASS: JS syntax; 38 tasks / 9 edges; edit deltas; unchanged baseline; JSON roundtrip; duplicate/self/dangling/invalid-flow/cycle checks; duplicate/deleted task rejection; version rejection; unknown state and extra-field retention.');console.log('Not tested: DOM rendering, actual file download, Safari UI.');

const layoutSource=script.slice(script.indexOf('function graphLayout('),script.indexOf('function independentGroups('));vm.runInContext(layoutSource,ctx);
const fixture=['A','B','C','D','E','F'].map(id=>({id})),links=['A','B','C'].map(prerequisite=>({prerequisite,successor:'F'}));
const layout=ctx.graphLayout(fixture,links);assert(!layout.pos.has('D'));assert(!layout.pos.has('E'));for(const id of ['A','B','C'])assert(layout.pos.get(id)[0]<layout.pos.get('F')[0]);
const actual=ctx.graphLayout(original.tasks,original.edges);const connected=new Set(original.edges.flatMap(e=>[e.prerequisite,e.successor]));assert.equal(actual.pos.size,connected.size);for(const edge of original.edges)assert(actual.pos.get(edge.prerequisite)[0]<actual.pos.get(edge.successor)[0]);assert.equal(new Set([...actual.pos.values()].map(p=>p.join(','))).size,connected.size);assert.equal(ctx.graphLayout(fixture,[]).pos.size,0);console.log('PASS: independent nodes excluded from graph; all connected nodes retained; all edges left-to-right; no overlap; empty-edge graph.');
vm.runInContext(script.slice(script.indexOf('function graphData('),script.indexOf('function graphLayout(')),ctx);ctx.doc=original;const visual=ctx.graphData(),placed=ctx.graphLayout(visual.nodes,visual.edges);assert.equal(original.milestones.length,6);assert.equal(original.milestoneRelations.length,13);for(const e of visual.edges)assert((placed.pos.get(e.prerequisite)[0]<placed.pos.get(e.successor)[0]||(placed.pos.get(e.prerequisite)[0]===placed.pos.get(e.successor)[0]&&placed.pos.get(e.prerequisite)[1]<placed.pos.get(e.successor)[1])));for(const id of ['MS-060','MS-070','MS-SPI','MS-HUMAN','QUALITY-001'])assert(placed.pos.has(id));assert.equal(new Set([...placed.pos.values()].map(p=>p.join(','))).size,placed.pos.size);assert(original.milestoneRelations.some(e=>e.prerequisite==='MS-060'&&e.successor==='PERM-079'&&e.relation==='resume'));assert(original.milestoneRelations.some(e=>e.prerequisite==='MS-VALIDATION'&&e.successor==='MS-070'&&e.relation==='required'));rejects(x=>x.milestoneRelations[0].successor='MISSING');rejects(x=>x.milestoneRelations[0].relation='unknown');console.log('PASS: milestone backbone, 13 sourced relations, release-after decision, Validation gate, combined DAG, no overlap, invalid relation rejection.');

vm.runInContext(script.slice(script.indexOf('function independentGroups('),script.indexOf('function independent(){')),ctx);const groups=ctx.independentGroups(original);assert(groups.permanent.every(t=>t.permanent));assert(groups.regular.every(t=>!t.permanent));const expected=original.tasks.filter(t=>!visual.edges.some(e=>e.prerequisite===t.id||e.successor===t.id));assert.equal(groups.regular.length+groups.permanent.length,expected.length);assert.equal(new Set([...groups.regular,...groups.permanent].map(t=>t.id)).size,expected.length);console.log('PASS: independent regular/permanent partition, no omissions or duplicates.');

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
const rewired=ctx.rewireRelation(base,edge,'OPS-048','OPS-051');ctx.check(rewired);assert.deepEqual(base,untouched);assert.deepEqual(rewired.baseline,base.baseline);assert(rewired.edges.some(e=>e.prerequisite==='OPS-048'&&e.successor==='OPS-051'&&e.constraint===edge.constraint));
assert.throws(()=>ctx.rewireRelation(base,edge,'OPS-048','OPS-048'));
assert.throws(()=>ctx.rewireRelation(base,edge,'MISSING','OPS-051'));
assert.throws(()=>ctx.rewireRelation(base,edge,base.edges[0].prerequisite,base.edges[0].successor));
assert.throws(()=>ctx.rewireRelation(base,edge,'QUALITY-001','RBT-001'));
const relation=base.milestoneRelations[0],moved=ctx.rewireRelation(base,relation,'MS-060','OPS-048');ctx.check(moved);assert.deepEqual(moved.milestoneRelations[0].source,relation.source);assert.deepEqual(base,untouched);
ctx.doc=rewired;assert(ctx.delta().some(x=>x.field==='edges'));ctx.doc=moved;ctx.initializeRelationBaseline(ctx.doc);console.log('PASS: transactional rewiring, retained evidence/baseline, task and milestone endpoints, self/duplicate/dangling/cycle rejection.');

assert.equal(placed.pos.get('PERM-079')[0]-placed.pos.get('MS-060')[0],295);
assert(Math.abs(placed.pos.get('MS-070')[0]-placed.pos.get('PERM-079')[0]-250*(3-Math.sqrt(5))/2)<1e-9);
console.log('PASS: requested node-edge spacing (45px gap, golden-ratio stagger).');

for(const id of ['RELEASE-075','RELEASE-076','RELEASE-072'])assert(Math.abs(placed.pos.get(id)[0]-placed.pos.get('MS-060')[0]-250*(3-Math.sqrt(5))/2)<1e-9);

assert(Math.abs(placed.pos.get('RELEASE-078')[0]-placed.pos.get('MS-DOC')[0]-250*(3-Math.sqrt(5))/2)<1e-9);

assert.equal(placed.pos.get('RELEASE-078')[1]-placed.pos.get('MS-DOC')[1],placed.pos.get('RELEASE-075')[1]-placed.pos.get('MS-VALIDATION')[1]);

assert.equal(placed.pos.get('QUALITY-005')[1]-placed.pos.get('MS-070')[1],placed.pos.get('RELEASE-075')[1]-placed.pos.get('MS-VALIDATION')[1]);

for(const [a,b] of [['MS-SPI','MS-HUMAN'],['MS-HUMAN','QUALITY-001']])assert(Math.abs(placed.pos.get(b)[0]-placed.pos.get(a)[0]-442.5)<1e-9);
