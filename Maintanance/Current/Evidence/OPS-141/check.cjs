// OPS-141 headless check of the member states. Isolated server; activity, continuity and approvals mocked in the browser; no POST.
// Usage: node check.cjs <studio URL> <output dir>   (REGISTRY_STUDIO_INBOX=$(mktemp -d) python3 -B Maintanance/RegistryApp/serve.py --port 18948)
const pw=require('/opt/homebrew/lib/node_modules/playwright');const [url,out]=process.argv.slice(2);
let seq=0;const events=[];const now=Date.now();const iso=ms=>new Date(ms).toISOString().replace(/\.\d+Z$/,'Z');
const ev=(taskId,event,owner,reason,extra={},at)=>{seq++;events.push({schemaVersion:1,id:seq.toString(16).padStart(32,'0'),taskId,event,owner,reason,timestamp:at||iso(now-120000+seq*1000),...extra});};
ev('OPS-1','work','姫','着手',{presence:'working'});ev('OPS-2','request','Astra','依頼',{next:'姫'});ev('OPS-1','return','姫','返却',{next:'Astra',presence:'waiting'});
ev('OPS-1','work','姫','ACK WAKE-20261019-'+'A'.repeat(32)+'：受信');ev('OPS-3','work','Fable','検討中：別件');
ev('OPS-4','work','Luna','ACK WAKE-20261018-OLD：会話へ戻る',{},'2026-10-18T10:00:00Z');
let cont={kind:'ok'};const posts=[];
(async()=>{const b=await pw.webkit.launch();const r={};try{for(const [name,w,h] of [['wide',1400,900],['narrow',390,844]]){
 const p=await b.newPage({viewport:{width:w,height:h}});const errors=[];p.on('pageerror',e=>errors.push(e.message));
 await p.route('**/activity-events',x=>x.fulfill({status:200,contentType:'application/json',body:JSON.stringify(events)}));
 await p.route('**/continuity',x=>cont.kind==='fail'?x.fulfill({status:503,contentType:'application/json',body:'{}'}):x.fulfill({status:200,contentType:'application/json',body:JSON.stringify({serverNow:new Date().toISOString(),schemaVersion:1,owners:{Astra:{state:'alive',at:new Date(Date.now()-90000).toISOString()},'姫':{state:'alive',at:new Date(Date.now()-5000).toISOString()},Sol:{state:'ended',at:new Date(Date.now()-1000).toISOString()}}})}));
 await p.route('**/commit-approvals',x=>x.request().method()==='GET'?x.fulfill({status:200,contentType:'application/json',body:JSON.stringify({policyNotice:'x',requests:[]})}):(posts.push('a'),x.abort()));
 for(const u of ['**/save','**/sync','**/activity-wake'])await p.route(u,x=>{posts.push(u);return x.abort();});
 await p.goto(url);await p.waitForTimeout(3500);
 const look=()=>p.evaluate(()=>({lamps:[...document.querySelectorAll('#presence-lamps .presence-lamp')].map(n=>({text:n.textContent,state:n.dataset.state})),lane:[...document.querySelectorAll('#work-lane-track .work-card')].map(n=>n.children[0].textContent),
  topBar:document.querySelector('header').textContent.includes('Astra'),memberSection:!!document.getElementById('presence-lamps').closest('.member-area')&&!document.getElementById('presence-lamps').closest('.work-lane'),fontSize:getComputedStyle(document.querySelector('#presence-lamps .presence-lamp')||document.body).fontSize,chips:[...document.querySelectorAll('#activity-events .activity-card')].map(n=>n.textContent),boxTop:Math.round(document.getElementById('presence-lamps').getBoundingClientRect().top),inView:document.getElementById('presence-lamps').getBoundingClientRect().right<=innerWidth+1}));
 const s={initial:await look()};await p.screenshot({path:`${out}/${name}.png`,clip:{x:0,y:0,width:w,height:Math.min(h,520)}});
 cont={kind:'fail'};await p.waitForTimeout(5800);s.continuityFail=await look();cont={kind:'ok'};
 ev('OPS-1','work','姫','待機を終える',{presence:'ended'});await p.waitForTimeout(5800);s.ended=await look();
 await p.click('#taskAreaTab');await p.waitForTimeout(300);await p.click('#workAreaTab');await p.waitForTimeout(300);s.afterSwitch=(await look()).lamps.length;
 s.errors=errors;r[name]=s;events.pop();await p.close();}}finally{await b.close();}r.posts=posts;console.log(JSON.stringify(r,null,1));})();
