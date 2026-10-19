// OPS-154: the task-map compatibility baseline as digests. `make` turns captures (task-view-model-capture.cjs) into
// task-view-model-maps.baseline.json; `check` compares new captures with it and names the first differing step and part.
// The baseline shows "the same output as before the extraction" under the fixed capture conditions; it is not a proof of
// correctness. Usage: node task-view-model-baseline.cjs make|check <capture-a.json> <capture-b.json>
const fs=require('fs'),crypto=require('crypto'),path=require('path');
const [mode,...caps]=process.argv.slice(2),file=path.join(__dirname,'task-view-model-maps.baseline.json');
const sha=s=>s===null||s===undefined?null:crypto.createHash('sha256').update(String(s)).digest('hex');
const PARTS=['graph','independent','permanentMap','cardList'];
const digest=c=>({errors:c.errors,inputRetention:c.inputRetention,steps:c.steps.map(s=>({name:s.name,
 parts:Object.fromEntries(PARTS.map(k=>[k,{sha256:sha(s[k]),length:s[k]==null?null:s[k].length}])),
 counts:[s.independentCount,s.permanentMapCount,s.cardsCount],picker:s.picker,selectedTitle:s.selectedTitle,tip:s.tip}))});
const now={a:digest(JSON.parse(fs.readFileSync(caps[0],'utf8'))),b:digest(JSON.parse(fs.readFileSync(caps[1],'utf8')))};
if(mode==='make'){
 fs.writeFileSync(file,JSON.stringify({about:'OPS-154 task-map compatibility baseline (dependency graph, independent strip, permanent map, card list, selection sharing, hover tip, input retention). Captured from 5149327f before the map view-model extraction by task-view-model-capture.cjs: file:// copy of the generated page with the seed replaced, WebKit, viewport 1400x900, TZ=UTC, locale ja-JP, canvas measureText = 7 px per character. Fixture a: completed-document-layout-fixture.json with the retired relation key removed (task-view-model-fixtures.py); fixture b: task-view-model-fixture-b.json (anonymized Registry structure plus one proposal). It shows the output stayed the same; it is not a proof of correctness.',
  knownLimits:['real fonts are not measured (fixed 7 px per character); the look is checked separately','the protection and neighborhood tabs are outside this baseline','input retention records the existing behavior: a version-filter change re-renders the editor and drops an unapplied value'],fixtures:now},null,1)+'\n');
 console.log('baseline written');process.exit(0);
}
const base=JSON.parse(fs.readFileSync(file,'utf8')).fixtures;let bad=0;
for(const f of ['a','b']){const x=now[f],y=base[f];
 if(JSON.stringify(x.errors)!==JSON.stringify(y.errors)){console.log(f,'errors differ',x.errors,y.errors);bad++;}
 if(JSON.stringify(x.inputRetention)!==JSON.stringify(y.inputRetention)){console.log(f,'input retention differs',x.inputRetention,y.inputRetention);bad++;}
 if(x.steps.length!==y.steps.length){console.log(f,'step count',x.steps.length,y.steps.length);bad++;continue;}
 x.steps.forEach((s,i)=>{const t=y.steps[i];for(const k of Object.keys(t)){if(JSON.stringify(s[k])!==JSON.stringify(t[k])){
  const parts=k==='parts'?PARTS.filter(p=>JSON.stringify(s.parts[p])!==JSON.stringify(t.parts[p])).join(','):'';console.log(f,'step',i,t.name,'differs in',k,parts);bad++;}}});}
console.log(bad?'BASELINE DIFFERS ('+bad+')':'PASS: task maps match the 5149327f baseline (fixtures a and b)');process.exit(bad?1:0);
