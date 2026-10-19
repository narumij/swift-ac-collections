// Read-only requirement test. Exit 1 means a display requirement violation.
const fs=require('fs'),path=require('path'),vm=require('vm'),assert=require('assert');
const root=path.resolve(__dirname,'../../..');
const source=fs.readFileSync(path.join(root,'RegistryApp/index.template.html'),'utf8');
const data=JSON.parse(fs.readFileSync(process.argv[2]||path.join(root,'Cache/RegistryStudio/registry.json'),'utf8'));
const ctx={doc:data,proposalNodes:()=>[],taskDocumentPaths:()=>[]};vm.createContext(ctx);
vm.runInContext(source.slice(source.indexOf('function graphData('),source.indexOf('function independent(){')),ctx);
vm.runInContext(source.slice(source.indexOf('function permanentMapData('),source.indexOf('// Card list (OPS-085)')),ctx);
function violations(ids,graph,regular,exempt){return ids.filter(id=>!exempt.has(id)).map(id=>({id,count:graph.filter(x=>x===id).length+regular.filter(x=>x===id).length})).filter(x=>x.count!==1);}
// Check the test oracle independently: missing, duplicated, unique and exempt.
assert.deepStrictEqual(violations(['missing','double','one','exempt'],['double','one'],['double'],new Set(['exempt'])),[{id:'missing',count:0},{id:'double',count:2}]);
const exempt=new Set(ctx.permanentMapData(data).flatMap(g=>[g.task.id,...g.descendants.map(t=>t.id)]));
const connected=new Set([...data.edges,...data.milestoneRelations].flatMap(e=>[e.prerequisite,e.successor]));
const regular=ctx.independentGroups(data).regular.map(t=>t.id);
let failed=false;
for(const view of ['', '@head']){
 const g=ctx.versionView(ctx.graphData(),view),layout=ctx.graphLayout(g.nodes,g.edges);
 const graph=g.nodes.filter(t=>layout.pos.has(t.id)).map(t=>t.id);
 const ids=view?['QUALITY-005','DOC-026']:data.tasks.filter(t=>connected.has(t.id)).map(t=>t.id);
 const result=violations(ids,graph,regular,exempt);failed ||= result.length>0;
 console.log(JSON.stringify({view:view||'all',tested:ids.filter(id=>!exempt.has(id)).length,violations:result.map(x=>({...x,graph:graph.includes(x.id),independent:regular.includes(x.id)}))}));
}
process.exitCode=failed?1:0;
