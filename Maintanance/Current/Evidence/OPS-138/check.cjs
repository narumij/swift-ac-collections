// OPS-138 headless check: older activity-event cards one step darker. Isolated test server; activity mocked; no POST.
// Usage: node check.cjs <studio URL> <output dir>   (REGISTRY_STUDIO_INBOX=$(mktemp -d) python3 -B Maintanance/RegistryApp/serve.py --port 18944)
const pw=require('/opt/homebrew/lib/node_modules/playwright');const [url,out]=process.argv.slice(2);
let seq=0;const events=[];const ev=(taskId,event,owner,reason,extra={})=>{seq++;events.push({schemaVersion:1,id:seq.toString(16).padStart(32,'0'),taskId,event,owner,reason,timestamp:new Date(Date.UTC(2026,9,19,1,0,seq)).toISOString().replace('.000Z','Z'),...extra});};
ev('OPS-901','request','Astra','依頼');ev('OPS-901','work','姫','着手');ev('OPS-902','return','姫','返却',{next:'Astra'});ev('OPS-903','awaiting-commit','Astra','承認待ち');
const posts=[];
(async()=>{const b=await pw.webkit.launch();const r={};try{for(const [name,w,h] of [['wide',1400,900],['narrow',390,844]]){
 const p=await b.newPage({viewport:{width:w,height:h}});const errors=[];p.on('pageerror',e=>errors.push(e.message));
 await p.route('**/activity-events',x=>x.fulfill({status:200,contentType:'application/json',body:JSON.stringify(events)}));
 await p.route('**/commit-approvals',x=>x.request().method()==='GET'?x.fulfill({status:200,contentType:'application/json',body:JSON.stringify({policyNotice:'x',requests:[]})}):(posts.push('a'),x.abort()));
 for(const u of ['**/save','**/sync'])await p.route(u,x=>{posts.push(u);return x.abort();});
 await p.goto(url);await p.waitForTimeout(2500);
 const look=()=>p.evaluate(()=>[...document.querySelectorAll('#activity-events .activity-card')].map(n=>{const cs=getComputedStyle(n);return {text:n.textContent,age:n.dataset.age,bg:cs.backgroundColor,border:cs.borderTopColor,color:cs.color};}));
 const s={before:await look()};
 await p.focus('#activity-events .activity-card');s.focusOutline=await p.evaluate(()=>{const cs=getComputedStyle(document.activeElement);return cs.outlineStyle+' '+cs.outlineColor;});
 ev('OPS-904','request','Astra','新しい依頼');await p.waitForTimeout(3800);s.after=await look();
 await p.screenshot({path:`${out}/${name}.png`,clip:{x:0,y:0,width:w,height:Math.min(h,300)}});
 s.errors=errors;r[name]=s;await p.close();}}finally{await b.close();}r.posts=posts;console.log(JSON.stringify(r,null,1));})();
