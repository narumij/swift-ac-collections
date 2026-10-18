// OPS-095 placement test (read-only). Requirement: TASK_REGISTRY_APP.md「タスク配置の要求」.
// Outside the permanent tree, a task with any line (task dependency or milestone connection) is placed on the dependency map,
// a task with none only in the independent strip; never both, never neither. Placement is checked per destination, not only by count.
// Usage: node placement.cjs [registry.json]. Exit 1 = requirement violation.
const fs=require('fs'),path=require('path'),vm=require('vm'),assert=require('assert');
const root=path.resolve(__dirname,'../../..');
const source=fs.readFileSync(path.join(root,'RegistryApp/index.template.html'),'utf8');
function load(data){const ctx={doc:data,taskDocumentPaths:()=>[]};vm.createContext(ctx);
 vm.runInContext(source.slice(source.indexOf('function proposalNodes('),source.indexOf('function nextProposalId(')),ctx);
 vm.runInContext(source.slice(source.indexOf('function graphData('),source.indexOf('function independent(){')),ctx);
 vm.runInContext(source.slice(source.indexOf('function permanentMapData('),source.indexOf('// Card list (OPS-085)')),ctx);return ctx;}
function audit(data,views){const ctx=load(data),problems=[];
 const tree=new Set(ctx.permanentMapData(data).flatMap(g=>[g.task.id,...g.descendants.map(t=>t.id)]));
 const lined=new Set([...data.edges,...(data.milestoneRelations||[])].flatMap(e=>[e.prerequisite,e.successor]));
 const strip=ctx.independentGroups(data).regular.map(t=>t.id);
 const all=ctx.versionView(ctx.graphData(),''),layout=ctx.graphLayout(all.nodes,all.edges),onMap=new Set(all.nodes.filter(n=>layout.pos.has(n.id)).map(n=>n.id));
 const subjects=[...data.tasks.map(t=>t.id),...ctx.proposalNodes(data).map(p=>p.id)].filter(id=>!tree.has(id));
 for(const id of subjects){const want=lined.has(id)?'map':'strip',map=onMap.has(id),inStrip=strip.filter(x=>x===id).length;
  if(want==='map'&&!map)problems.push(`${id}: has lines but is not on the dependency map`);
  if(want==='map'&&inStrip)problems.push(`${id}: has lines but is in the independent strip`);
  if(want==='strip'&&map)problems.push(`${id}: no lines but is on the dependency map`);
  if(want==='strip'&&inStrip!==1)problems.push(`${id}: no lines but appears ${inStrip} times in the independent strip`);}
 for(const id of strip)if(tree.has(id))problems.push(`${id}: permanent-tree task in the independent strip`);
 // A version filter only hides lines; it never turns a lined task into an independent one (the strip does not depend on the view).
 for(const v of views){const g=ctx.versionView(ctx.graphData(),v),l=ctx.graphLayout(g.nodes,g.edges);
  for(const n of g.nodes)if(l.pos.has(n.id)&&n.kind!=='milestone'&&!lined.has(n.id))problems.push(`${n.id}: placed on the ${v} map without lines`);}
 return {subjects:subjects.length,problems};}
// Oracle self-check on a fixture: milestone chain, task-only group, isolated task, permanent tree with a lined child, proposal.
const T=(id,extra={})=>({id,state:'ACTIVE',owner:'',item:id,condition:'',detail:'',raw:'',...extra});
const fx={tasks:[T('A'),T('B'),T('X'),T('Y'),T('Z'),T('P',{permanent:true}),T('C',{parentTask:'P'})],
 edges:[{prerequisite:'X',successor:'Y',flow:'SEQUENCE',constraint:''},{prerequisite:'A',successor:'B',flow:'SEQUENCE',constraint:''},{prerequisite:'C',successor:'A',flow:'SEQUENCE',constraint:''}],
 milestones:[{id:'START-1.0.0',kind:'milestone',item:'START-1.0.0',state:'ACTIVE',owner:'',condition:'',detail:'',raw:'',gate:'Maintanance/Milestones/1.0.0/',virtual:true},{id:'END-1.0.0',kind:'milestone',item:'END-1.0.0',state:'ACTIVE',owner:'',condition:'',detail:'',raw:'',gate:'Maintanance/Milestones/1.0.0/',virtual:true}],
 milestoneRelations:[{prerequisite:'START-1.0.0',successor:'END-1.0.0',constraint:'',source:{path:'',quote:''}},{prerequisite:'B',successor:'END-1.0.0',constraint:'',source:{path:'',quote:''}}],
 proposals:[{id:'draft-1',title:'孤立案',memo:''},{id:'draft-2',title:'接続案',memo:''}],milestoneHead:'1.0.0'};
fx.edges.push({prerequisite:'draft-2',successor:'X',flow:'SEQUENCE',constraint:''});
const r=audit(fx,['1.0.0']);
assert.deepStrictEqual(r.problems,[],'fixture: '+JSON.stringify(r.problems));
const broken=JSON.parse(JSON.stringify(fx));broken.edges=broken.edges.filter(e=>e.prerequisite!=='X');broken.edges.push({prerequisite:'Z',successor:'Y',flow:'SEQUENCE',constraint:''});
assert(audit(broken,[]).problems.length===0,'re-wired fixture still placed by lines');
// Real data.
const data=JSON.parse(fs.readFileSync(process.argv[2]||path.join(root,'Cache/RegistryStudio/registry.json'),'utf8'));
const views=['@head',...new Set((data.milestones||[]).map(m=>(m.gate||'').split('/')[2]).filter(Boolean))];
const real=audit(data,views);
console.log(JSON.stringify({subjects:real.subjects,views:views.length,problems:real.problems}));
process.exitCode=real.problems.length?1:0;
