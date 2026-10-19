// OPS-127 headless check. The page comes from an isolated test server; /activity-events and /commit-approvals are
// answered by mocked data inside the browser (nothing is written to the real activity log or approval store).
// Usage: node check.cjs <studio URL> <output dir>
//   REGISTRY_STUDIO_INBOX=$(mktemp -d) python3 -B Maintanance/RegistryApp/serve.py --port 18937
const pw=require('/opt/homebrew/lib/node_modules/playwright');const [url,out]=process.argv.slice(2);
let seq=0,events=[],fail=false;
const ev=(taskId,event,owner,reason,extra={})=>{seq++;events.push({schemaVersion:1,id:seq.toString(16).padStart(32,'0'),taskId,event,owner,reason,timestamp:new Date(Date.UTC(2026,9,19,1,0,seq)).toISOString().replace('.000Z','Z'),commitSha:'',...extra});};
const approvals={policyNotice:'模擬データ',requests:[{id:'mock-1',revision:1,taskId:'OPS-902',title:'模擬の承認',scope:'s',paths:['a'],condition:'c',branch:'b',status:'pending',createdAt:'2026-10-19T01:00:00Z',updatedAt:'2026-10-19T01:00:00Z'}]};
async function mock(page){
 await page.route('**/activity-events',route=>fail?route.fulfill({status:500,body:'{}'}):route.fulfill({status:200,contentType:'application/json',body:JSON.stringify(events)}));
 await page.route('**/commit-approvals',route=>route.request().method()==='GET'?route.fulfill({status:200,contentType:'application/json',body:JSON.stringify(approvals)}):route.abort());
}
const snap=p=>p.evaluate(()=>({lamps:[...document.querySelectorAll('#presence-lamps .presence-lamp')].map(n=>({text:n.textContent,state:n.dataset.state,fresh:n.dataset.fresh||'',anim:getComputedStyle(n).animationName})),stale:document.getElementById('presence-lamps').dataset.stale||'',cards:Object.fromEntries([...document.querySelectorAll('#work-lane-track .work-card')].map(n=>[n.children[0].textContent.split(' · ')[0],{line:n.children[2].textContent,next:n.dataset.next}])),current:document.getElementById('activity-current-heading').textContent}));
(async()=>{const b=await pw.webkit.launch({headless:true});const r={steps:{}};try{
 ev('OPS-901','request','Astra','依頼',{next:'姫'});ev('OPS-901','work','姫','WAIT 連続待機開始',{presence:'waiting'});ev('OPS-902','awaiting-commit','Astra','承認待ち',{next:'user'});ev('OPS-903','commit','Astra','記録のコミット');
 const p=await b.newPage({viewport:{width:1400,height:900}});const errors=[];p.on('pageerror',e=>errors.push(e.message));await mock(p);
 await p.goto(url);await p.waitForTimeout(2000);r.steps.initial=await snap(p);
 await p.screenshot({path:out+'/wide.png',clip:{x:0,y:55,width:1400,height:420}});
 // keep an input focused while the lane updates
 await p.click('#cardsTab');await p.click('#planToolsDetails > summary');await p.fill('#planAddName','模擬の入力（適用しない）');await p.focus('#planAddName');
 ev('OPS-901','return','姫','返却',{next:'Astra'});await p.waitForTimeout(3500);r.steps.afterReturn=await snap(p);
 r.focusKept=await p.evaluate(()=>document.activeElement.id==='planAddName'&&document.getElementById('planAddName').value==='模擬の入力（適用しない）');
 await p.waitForTimeout(3500);r.steps.flashCleared=await snap(p);
 ev('OPS-901','acceptance','Astra','受入',{next:'none'});await p.waitForTimeout(3500);r.steps.afterEnd=await snap(p);
 ev('OPS-901','work','姫','ACK PING-20261019-Z：受信');await p.waitForTimeout(3500);r.steps.afterPingAck=await snap(p);
 ev('OPS-901','work','姫','ACK WAKE-20261019-Z：会話へ戻る');await p.waitForTimeout(3500);r.steps.afterWakeAck=await snap(p);
 ev('OPS-901','request','Astra','再依頼');await p.waitForTimeout(3500);r.steps.afterReRequest=await snap(p);
 fail=true;await p.waitForTimeout(3500);r.steps.failure=await snap(p);
 fail=false;await p.waitForTimeout(3500);r.steps.recovered=await snap(p);
 // fix 3: consult stage + pending approval on the same card: the approval colour wins on the left line
 ev('OPS-902','work','Astra','相談待ち：承認の範囲を確認してください');await p.waitForTimeout(3500);
 r.consultWithApproval=await p.evaluate(()=>{const n=[...document.querySelectorAll('#work-lane-track .work-card')].find(c=>c.children[0].textContent.startsWith('OPS-902'));const cs=getComputedStyle(n);return {stage:n.dataset.stage,next:n.dataset.next,left:cs.borderLeftColor,top:cs.borderTopColor};});
 r.errors=errors;await p.close();
 // reduced motion: a fresh lamp does not animate
 const ctx=await b.newContext({viewport:{width:390,height:844},reducedMotion:'reduce'});const q=await ctx.newPage();await mock(q);await q.goto(url);await q.waitForTimeout(2000);
 ev('OPS-904','request','Astra','新しい依頼',{next:'姫'});await q.waitForTimeout(3500);r.reducedMotion=(await snap(q)).lamps.find(l=>l.text.startsWith('Astra'));
 await q.evaluate(()=>window.scrollTo(0,0));await q.screenshot({path:out+'/narrow.png'});await ctx.close();
}finally{await b.close();}console.log(JSON.stringify(r,null,1));})();
