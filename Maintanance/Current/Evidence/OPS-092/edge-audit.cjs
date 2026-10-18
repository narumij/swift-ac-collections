const fs=require('fs'),path=require('path'),vm=require('vm'),assert=require('assert');
const root=path.resolve(__dirname,'../../..'),s=fs.readFileSync(path.join(root,'RegistryApp/index.template.html'),'utf8'),d=JSON.parse(fs.readFileSync(path.join(root,'Cache/RegistryStudio/registry.json'),'utf8'));
const md=fs.readFileSync(path.join(root,'ProgressV2/TASK_REGISTRY_V2.md'),'utf8');
function rows(heading){const block=md.split('## '+heading+'\n')[1].split(/^## |^### /m)[0];return block.split('\n').filter(l=>/^\| `/.test(l)).map(l=>l.split('|').slice(1,-1).map(x=>x.trim().replace(/^`|`$/g,'')));}
const task=rows('Task precedence').map(r=>({prerequisite:r[1],successor:r[0],constraint:r[3]})),links=rows('マイルストーン接続').map(r=>({prerequisite:r[0],successor:r[1],constraint:r[2]}));
const dir=path.join(root,'Milestones'),versions=fs.readdirSync(dir,{withFileTypes:true}).filter(e=>e.isDirectory()&&!e.name.startsWith('_')).map(e=>e.name).sort((a,b)=>a.localeCompare(b,'en',{numeric:true}));
const backbone=[],add=(a,b)=>backbone.push({prerequisite:a,successor:b});
for(let i=0;i<versions.length;i++){const v=versions[i],files=fs.readdirSync(path.join(dir,v)).filter(f=>f.endsWith('.md')&&f!=='GOAL.md').sort();const id=f=>{const text=fs.readFileSync(path.join(dir,v,f),'utf8');const m=text.match(/## ID\s+`([^`]+)`/);assert(m,f);return m[1];};const cards=files.filter(f=>!f.startsWith('GATE-')).map(id),gates=files.filter(f=>f.startsWith('GATE-'));assert(gates.length<=1);const chain=['START-'+v,...cards,'END-'+v];for(let j=1;j<chain.length;j++)add(chain[j-1],chain[j]);if(gates.length){const gate=id(gates[0]);add('END-'+v,gate);if(i+1<versions.length)add(gate,'START-'+versions[i+1]);}}
const key=e=>e.prerequisite+' → '+e.successor;
function compare(expected,actual){const counts=x=>{const m={};for(const e of x)m[key(e)]=(m[key(e)]||0)+1;return m;};const a=counts(expected),b=counts(actual);return [...new Set([...Object.keys(a),...Object.keys(b)])].filter(k=>a[k]!==b[k]).map(k=>({edge:k,expected:a[k]||0,actual:b[k]||0}));}
assert.deepStrictEqual(compare(task,d.edges),[]);assert.deepStrictEqual(compare([...backbone,...links],d.milestoneRelations),[]);
for(const e of [...task,...links]){const actual=[...d.edges,...d.milestoneRelations].find(x=>key(x)===key(e));assert.equal(actual.constraint,e.constraint);}
console.log(JSON.stringify({canonical:{task:task.length,connections:links.length,backbone:backbone.length},jsonMismatch:0}));
const ctx={doc:d,proposalNodes:()=>[]};vm.createContext(ctx);vm.runInContext(s.slice(s.indexOf('function graphData('),s.indexOf('function independentGroups(')),ctx);
// Independent projection of collapsed START/END endpoints, derived from canonical edges.
const ends=new Map(backbone.filter(e=>e.prerequisite.startsWith('END-')).map(e=>[e.prerequisite,e.successor]));const starts=new Map(backbone.filter(e=>e.successor.startsWith('START-')&&e.prerequisite.startsWith('GATE-')).map(e=>[e.successor,e.prerequisite]));
const hidden=e=>e.startsWith('END-')||starts.has(e);const projected=[],omitted=[];
for(const e of [...task,...backbone,...links]){let a=e.prerequisite,b=e.successor;if(hidden(a)){if(!starts.has(a)){omitted.push(key(e));continue;}a=starts.get(a);}if(hidden(b)){if(!ends.has(b)){omitted.push(key(e));continue;}b=ends.get(b);}projected.push({...e,prerequisite:a,successor:b});}
assert.deepStrictEqual(compare(projected,ctx.graphData().edges),[]);
console.log(JSON.stringify({projectionMismatch:0,collapsedOrOmitted:omitted}));
// Execute the actual graph() line-rendering portion in a tiny SVG stub; no user screen access.
const render=s.slice(s.indexOf('function graph(){'),s.indexOf(' const measure=document.createElement',s.indexOf('function graph(){')))+'return s; }';
ctx.svg=(tag,attrs,text)=>({tag,attrs:attrs||{},children:[],append(...xs){this.children.push(...xs);},getAttribute(k){return this.attrs[k];}});ctx.isMilestoneLink=e=>d.milestones.some(m=>m.id===e.prerequisite||m.id===e.successor);ctx.linkLabel=key;ctx.el=()=>({});
vm.runInContext(render,ctx);
for(const view of ['', '@head',...versions]){ctx.$=id=>id==='versionPicker'?{value:view,options:{length:versions.length+2}}:{};const g=ctx.versionView(ctx.graphData(),view),svg=ctx.graph(),paths=svg.children.filter(n=>n.tag==='path'),visible=paths.filter(n=>n.attrs.stroke!=='transparent'),hits=paths.filter(n=>n.attrs.stroke==='transparent');assert.equal(visible.length,g.edges.length);assert.equal(hits.length,g.edges.length);assert(visible.every(n=>!String(n.attrs.d).match(/NaN|undefined/)));assert(hits.every((n,i)=>n.attrs.d===visible[i].attrs.d));const duplicates=g.edges.filter((e,i)=>g.edges.findIndex(x=>key(e)===key(x))!==i).map(key);console.log(JSON.stringify({view:view||'all',visible:visible.length,duplicateEndpoints:duplicates,duplicateGeometry:visible.length-new Set(visible.map(n=>n.attrs.d)).size}));assert.equal(duplicates.length,0);}
// Reproduce the reported addition separately, without writing it to canonical data.
ctx.doc=JSON.parse(JSON.stringify(d));ctx.doc.milestoneRelations.push({prerequisite:'QUALITY-005',successor:'MS-SPI',constraint:''});const g=ctx.versionView(ctx.graphData(),'@head'),l=ctx.graphLayout(g.nodes,g.edges);console.log(JSON.stringify({simulation:'QUALITY-005 → MS-SPI',count:g.edges.filter(e=>key(e)==='QUALITY-005 → MS-SPI').length,outgoing:g.edges.filter(e=>e.prerequisite==='QUALITY-005').map(key),fallback:l.fallback}));
