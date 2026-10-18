// OPS-139 headless check of the Astra continuity mark in the top bar. Isolated test server; /continuity, activity and
// approvals are mocked in the browser (the real continuity record is never read or written); no POST is sent.
// Usage: node check.cjs <studio URL> <output dir>   (REGISTRY_STUDIO_INBOX=$(mktemp -d) python3 -B Maintanance/RegistryApp/serve.py --port 18945)
const pw=require('/opt/homebrew/lib/node_modules/playwright');const [url,out]=process.argv.slice(2);
let mode={kind:'none'};const posts=[];
const iso=ms=>new Date(ms).toISOString();
async function mock(p){
 await p.route('**/continuity',r=>{if(mode.kind==='fail')return r.fulfill({status:503,contentType:'application/json',body:'{"error":"Continuity unavailable"}'});
  const owners=mode.kind==='none'?{}:{Astra:{state:mode.state,at:iso(mode.at)}};return r.fulfill({status:200,contentType:'application/json',body:JSON.stringify({serverNow:iso(Date.now()),schemaVersion:1,owners})});});
 await p.route('**/activity-events',r=>r.fulfill({status:200,contentType:'application/json',body:'[]'}));
 await p.route('**/commit-approvals',r=>r.request().method()==='GET'?r.fulfill({status:200,contentType:'application/json',body:JSON.stringify({policyNotice:'x',requests:[{id:'m',revision:1,taskId:'OPS-1',title:'t',scope:'s',paths:['a'],condition:'c',branch:'b',status:'pending',createdAt:'2026-10-19T01:00:00Z',updatedAt:'2026-10-19T01:00:00Z'}]})}):(posts.push('a'),r.abort()));
 for(const u of ['**/save','**/sync'])await p.route(u,r=>{posts.push(u);return r.abort();});
}
const look=p=>p.evaluate(()=>{const n=document.getElementById('continuity-status'),row=document.querySelector('header .header-row').getBoundingClientRect(),r=n.getBoundingClientRect(),h1=document.querySelector('header h1').getBoundingClientRect(),ap=document.querySelector('header .header-approval').getBoundingClientRect(),cs=getComputedStyle(n);
 const overlap=(a,b)=>a.width>0&&b.width>0&&a.left<b.right&&b.left<a.right;
 return {label:n.textContent,kind:n.dataset.kind,title:n.title,border:cs.borderStyle+' '+cs.borderColor,inRow:r.top>=row.top-1&&r.bottom<=row.bottom+1,box:[Math.round(r.left),Math.round(r.right)],overlapsTitle:overlap(r,h1),overlapsApproval:overlap(r,ap),approvalVisible:document.getElementById('header-approval-status').getBoundingClientRect().width>0};});
(async()=>{const b=await pw.webkit.launch();const r={};try{for(const [name,w,h] of [['wide',1400,900],['narrow',390,844]]){
 const p=await b.newPage({viewport:{width:w,height:h}});const errors=[];p.on('pageerror',e=>errors.push(e.message));await mock(p);const s={};
 mode={kind:'none'};await p.goto(url);await p.waitForTimeout(2000);s.unrecorded=await look(p);
 mode={kind:'mark',state:'alive',at:Date.now()-10000};await p.waitForTimeout(5600);s.alive=await look(p);await p.screenshot({path:`${out}/${name}-alive.png`,clip:{x:0,y:0,width:w,height:80}});
 mode={kind:'mark',state:'alive',at:Date.now()-50000};await p.waitForTimeout(5600);s.near=await look(p);
 await p.waitForTimeout(6000);s.lapsed=await look(p);await p.screenshot({path:`${out}/${name}-lapsed.png`,clip:{x:0,y:0,width:w,height:80}});
 mode={kind:'fail'};await p.waitForTimeout(5600);s.failure=await look(p);
 mode={kind:'mark',state:'alive',at:Date.now()-2000};await p.waitForTimeout(5600);s.recovered=await look(p);
 mode={kind:'mark',state:'ended',at:Date.now()-1000};await p.waitForTimeout(5600);s.ended=await look(p);
 mode={kind:'mark',state:'alive',at:Date.now()+60000};await p.waitForTimeout(5600);s.future=await look(p);
 s.errors=errors;r[name]=s;await p.close();}}finally{await b.close();}r.posts=posts;console.log(JSON.stringify(r,null,1));})();
