// OPS-132 first look: screenshots and a few measurements on an isolated test server. /activity-events and
// /commit-approvals are mocked in the browser; nothing is saved, approved or synced.
// Usage: node look.cjs <studio URL> <output dir>
//   REGISTRY_STUDIO_INBOX=$(mktemp -d) python3 -B Maintanance/RegistryApp/serve.py --port 18940
const pw=require('/opt/homebrew/lib/node_modules/playwright');const [url,out]=process.argv.slice(2);
let seq=0;const events=[];
const ev=(taskId,event,owner,reason,extra={})=>{seq++;events.push({schemaVersion:1,id:seq.toString(16).padStart(32,'0'),taskId,event,owner,reason,timestamp:new Date(Date.UTC(2026,9,19,1,0,seq)).toISOString().replace('.000Z','Z'),commitSha:'',...extra});};
ev('OPS-901','request','Astra','UI確認の依頼',{next:'姫'});ev('OPS-901','work','姫','WAIT 連続待機開始',{presence:'waiting'});
ev('OPS-902','return','姫','返却',{next:'Astra',ref:{path:'Maintanance/Current/X.md',section:'姫Return'}});
ev('OPS-903','awaiting-commit','Astra','承認待ち',{next:'user'});ev('OPS-904','acceptance','Astra','受入',{next:'none'});
ev('OPS-905','work','Fable','検討中：別件');
const approvals={policyNotice:'模擬データ',requests:[{id:'mock-1',revision:1,taskId:'OPS-903',title:'模擬の承認',scope:'s',paths:['a'],condition:'c',branch:'b',status:'pending',createdAt:'2026-10-19T01:00:00Z',updatedAt:'2026-10-19T01:00:00Z'}]};
async function mock(page){
 await page.route('**/activity-events',r=>r.fulfill({status:200,contentType:'application/json',body:JSON.stringify(events)}));
 await page.route('**/commit-approvals',r=>r.request().method()==='GET'?r.fulfill({status:200,contentType:'application/json',body:JSON.stringify(approvals)}):r.abort());
 await page.route('**/save',r=>r.abort());await page.route('**/sync',r=>r.abort());
}
const measure=p=>p.evaluate(()=>{const box=s=>{const e=document.querySelector(s);if(!e)return null;const r=e.getBoundingClientRect();return {top:Math.round(r.top+scrollY),left:Math.round(r.left),w:Math.round(r.width),h:Math.round(r.height)};};
 return {viewport:[innerWidth,innerHeight],header:box('header'),headerRow:box('header .header-row'),title:box('header h1'),toolbar:box('header .toolbar'),
  headerInfo:box('.header-info'),lane:box('.work-lane'),tabs:box('.buttons[role=tablist]'),graph:box('#graph'),
  firstGraphCardTop:(()=>{const g=document.querySelector('#graph g.node');return g?Math.round(g.getBoundingClientRect().top+scrollY):null;})(),
  cards:[...document.querySelectorAll('#work-lane-track .work-card')].map(n=>({text:n.innerText.replace(/\s+/g,' ').slice(0,90),next:n.dataset.next||'',left:getComputedStyle(n).borderLeftColor})),
  lamps:[...document.querySelectorAll('#presence-lamps .presence-lamp')].map(n=>n.textContent)};});
(async()=>{const b=await pw.webkit.launch({headless:true});const r={};try{
 for(const [name,w,h] of [['wide',1400,900],['narrow',390,844]]){
  const p=await b.newPage({viewport:{width:w,height:h}});const errors=[];p.on('pageerror',e=>errors.push(e.message));await mock(p);
  await p.goto(url);await p.waitForTimeout(2500);r[name]=await measure(p);r[name].errors=errors;
  await p.screenshot({path:`${out}/${name}-top.png`});
  await p.screenshot({path:`${out}/${name}-full.png`,fullPage:true});
  await p.close();
 }
}finally{await b.close();}console.log(JSON.stringify(r,null,1));})();
