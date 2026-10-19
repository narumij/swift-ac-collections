// OPS-138 follow-up: the task-area menu button keeps its size while busy. Isolated server; /sync is held 1.5 s then aborted.
// Usage: node menu-busy-check.cjs <studio URL> <output dir>   (REGISTRY_STUDIO_INBOX=$(mktemp -d) python3 -B Maintanance/RegistryApp/serve.py --port 18947)
const pw=require('/opt/homebrew/lib/node_modules/playwright');const [url,out]=process.argv.slice(2);
(async()=>{const b=await pw.webkit.launch();const r={};try{for(const [name,w,h] of [['wide',1400,900],['narrow',390,844]]){
 const p=await b.newPage({viewport:{width:w,height:h}});const errors=[];p.on('pageerror',e=>errors.push(e.message));
 await p.route('**/activity-events',x=>x.fulfill({status:200,contentType:'application/json',body:'[]'}));
 await p.route('**/commit-approvals',x=>x.request().method()==='GET'?x.fulfill({status:200,contentType:'application/json',body:JSON.stringify({policyNotice:'x',requests:[]})}):x.abort());
 await p.route('**/continuity',x=>x.fulfill({status:200,contentType:'application/json',body:JSON.stringify({serverNow:new Date().toISOString(),schemaVersion:1,owners:{}})}));
 let syncs=0;await p.route('**/sync',async x=>{syncs++;await new Promise(f=>setTimeout(f,1500));return x.abort();});
 await p.goto(url);await p.waitForTimeout(2000);await p.click('#taskAreaTab');await p.waitForTimeout(300);
 const look=()=>p.evaluate(()=>{const btn=document.getElementById('headerMenuButton'),rc=btn.getBoundingClientRect(),vis=[...btn.children].filter(s=>getComputedStyle(s).visibility==='visible').map(s=>s.textContent),tabs=document.querySelector('main .buttons[role=tablist]').getBoundingClientRect();
  return {w:Math.round(rc.width*10)/10,h:Math.round(rc.height*10)/10,visible:vis,busy:btn.getAttribute('aria-busy'),tabsLeft:Math.round(tabs.left)};});
 const s={idle:await look()};await p.click('#headerMenuButton');await p.click('#refresh');await p.waitForTimeout(400);s.busy=await look();
 await p.screenshot({path:`${out}/menu-busy-${name}.png`,clip:{x:0,y:Math.max(0,60),width:Math.min(w,700),height:120}});
 await p.waitForTimeout(2000);s.after=await look();s.sameSize=s.idle.w===s.busy.w&&s.idle.h===s.busy.h&&s.after.w===s.idle.w;s.tabsDidNotMove=s.idle.tabsLeft===s.busy.tabsLeft;s.syncs=syncs;s.errors=errors;r[name]=s;await p.close();}}
 finally{await b.close();}console.log(JSON.stringify(r,null,1));})();
