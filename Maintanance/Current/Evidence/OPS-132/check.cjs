// OPS-132 second step: after-change check on an isolated test server (compare with look.json from the first step).
// /activity-events and /commit-approvals are mocked in the browser; save, sync and approval POSTs are blocked.
// Usage: node check.cjs <studio URL> <output dir>
//   REGISTRY_STUDIO_INBOX=$(mktemp -d) python3 -B Maintanance/RegistryApp/serve.py --port 18941
const pw=require('/opt/homebrew/lib/node_modules/playwright');const [url,out]=process.argv.slice(2);
let seq=0;const events=[];
const ev=(taskId,event,owner,reason,extra={})=>{seq++;events.push({schemaVersion:1,id:seq.toString(16).padStart(32,'0'),taskId,event,owner,reason,timestamp:new Date(Date.UTC(2026,9,19,1,0,seq)).toISOString().replace('.000Z','Z'),commitSha:'',...extra});};
ev('OPS-901','request','Astra','UI確認の依頼',{next:'姫'});ev('OPS-901','work','姫','WAIT 連続待機開始',{presence:'waiting'});
ev('OPS-902','return','姫','返却',{next:'Astra'});ev('OPS-903','awaiting-commit','Astra','承認待ち',{next:'user'});
ev('OPS-904','acceptance','Astra','受入',{next:'none'});ev('OPS-905','work','Fable','検討中：別件');
ev('OPS-906','return','姫','長い担当名の返却',{next:'Reviewer-'+'とても長い担当名'.repeat(4)+' Long English Owner Name'});
const approvals={policyNotice:'模擬データ',requests:[{id:'mock-1',revision:1,taskId:'OPS-903',title:'模擬の承認',scope:'s',paths:['a'],condition:'c',branch:'b',status:'pending',createdAt:'2026-10-19T01:00:00Z',updatedAt:'2026-10-19T01:00:00Z'}]};
const posts=[];
async function mock(page){
 await page.route('**/activity-events',r=>r.fulfill({status:200,contentType:'application/json',body:JSON.stringify(events)}));
 await page.route('**/commit-approvals',r=>{if(r.request().method()!=='GET'){posts.push(r.request().url());return r.abort();}return r.fulfill({status:200,contentType:'application/json',body:JSON.stringify(approvals)});});
 for(const u of ['**/save','**/sync'])await page.route(u,r=>{posts.push(r.request().url());return r.abort();});
}
const measure=p=>p.evaluate(()=>{const box=s=>{const e=document.querySelector(s);if(!e)return null;const r=e.getBoundingClientRect();return {top:Math.round(r.top+scrollY),left:Math.round(r.left),w:Math.round(r.width),h:Math.round(r.height)};};
 const cards=[...document.querySelectorAll('#work-lane-track .work-card')].map(n=>{const next=n.children[1],cs=getComputedStyle(next);
  return {id:n.children[0].textContent,next:next.textContent,kind:n.dataset.next,colour:cs.color,weight:cs.fontWeight,left:getComputedStyle(n).borderLeftColor,
   nextLines:Math.round(next.getBoundingClientRect().height/parseFloat(cs.lineHeight||'14')||0),nextClipped:next.scrollHeight>next.clientHeight+1,
   cardOverflow:n.scrollHeight>n.clientHeight+1,lines:[...n.children].map(x=>x.textContent),titleHasAll:[...n.children].slice(0,4).every(x=>n.title.includes(x.textContent))};});
 const ctl=['#versionPicker','.graph-help > summary','#graphZoomOut','#graphHoverEnabled'].map(s=>({s,...box(s)}));
 const visibleCards=[...document.querySelectorAll('#graph g.node')].map(g=>g.getBoundingClientRect().top+scrollY).filter(y=>y>0);
 return {viewport:[innerWidth,innerHeight],lane:box('.work-lane'),track:box('#work-lane-track'),graph:box('#graph'),controls:ctl,controlsBox:box('.graph-controls'),topmostGraphCard:Math.round(Math.min(...visibleCards)),cards};});
(async()=>{const b=await pw.webkit.launch({headless:true});const r={};try{
 for(const [name,w,h] of [['wide',1400,900],['narrow',390,844]]){
  const p=await b.newPage({viewport:{width:w,height:h}});const errors=[];p.on('pageerror',e=>errors.push(e.message));await mock(p);
  await p.goto(url);await p.waitForTimeout(2500);r[name]=await measure(p);r[name].errors=errors;
  await p.screenshot({path:`${out}/${name}-after.png`});
  // help opened: full width row below the controls
  await p.click('.graph-help > summary');await p.waitForTimeout(200);
  r[name].helpOpen=await p.evaluate(()=>{const d=document.querySelector('.graph-help'),c=document.querySelector('.graph-controls');const dr=d.getBoundingClientRect(),cr=c.getBoundingClientRect(),z=document.getElementById('graphZoomOut').getBoundingClientRect();return {open:d.open,width:Math.round(dr.width),rowWidth:Math.round(cr.width),belowZoom:dr.top>=z.bottom-1};});
  await p.click('.graph-help > summary');
  if(name==='wide'){
   // version: change by keyboard; value kept and focus stays on the picker after the redraw
   const opts=await p.$$eval('#versionPicker option',o=>o.map(x=>x.value));await p.focus('#versionPicker');
   if(opts.length>1){await p.selectOption('#versionPicker',opts[1]);await p.waitForTimeout(500);}
   r.version={options:opts.length,value:await p.$eval('#versionPicker',e=>e.value),expected:opts[1]??opts[0],focus:await p.evaluate(()=>document.activeElement.id)};
   if(opts.length>1){await p.selectOption('#versionPicker',opts[0]);await p.waitForTimeout(500);}
   // keyboard order inside the row: picker -> help summary -> zoom out -> reset -> zoom in -> hover switch
   await p.focus('#versionPicker');const order=[];for(let k=0;k<5;k++){await p.keyboard.press('Alt+Tab');order.push(await p.evaluate(()=>{const e=document.activeElement;return e.id||e.tagName.toLowerCase();}));}
   r.keyboardOrder=order;
   // zoom and hover switch still work; focus stays on the zoom button after redraw
   await p.focus('#graphZoomIn');await p.keyboard.press('Enter');await p.waitForTimeout(300);
   r.zoom={label:await p.textContent('#graphZoomReset'),focus:await p.evaluate(()=>document.activeElement.id)};
   await p.click('#graphZoomReset');await p.click('#graphHoverEnabled');r.hoverOff=!(await p.isChecked('#graphHoverEnabled'));await p.click('#graphHoverEnabled');
   // an input keeps its value and focus while the lane polls
   await p.click('#cardsTab');await p.click('#planToolsDetails > summary');await p.fill('#planAddName','模擬の入力（適用しない）');await p.focus('#planAddName');
   ev('OPS-907','request','Astra','新しい依頼',{next:'姫'});await p.waitForTimeout(3500);
   r.inputKept=await p.evaluate(()=>document.activeElement.id==='planAddName'&&document.getElementById('planAddName').value==='模擬の入力（適用しない）');
   r.laneAfterPoll=await p.evaluate(()=>document.querySelectorAll('#work-lane-track .work-card').length);
  }
  await p.close();
 }
 r.blockedPosts=posts;
}finally{await b.close();}console.log(JSON.stringify(r,null,1));})();
