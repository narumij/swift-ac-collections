// OPS-126 proposals 4 and 6: headless check on an isolated test server. No save/approve/refresh; typed text is never applied.
// Usage: node cards-check.cjs <studio URL> <output dir>
//   REGISTRY_STUDIO_INBOX=$(mktemp -d) python3 -B Maintanance/RegistryApp/serve.py --port 18935
const pw=require('/opt/homebrew/lib/node_modules/playwright');const [url,out]=process.argv.slice(2);
(async()=>{const b=await pw.webkit.launch({headless:true});const r={};try{
 const p=await b.newPage({viewport:{width:1400,height:900}});const errors=[];p.on('pageerror',e=>errors.push(e.message));
 await p.goto(url);await p.waitForTimeout(2500);
 // 4. select DOC-027 from the map, open the local map, read the card titles
 await (await p.$('#graph g.node:has(text:text-matches("^DOC-027"))')).click();await p.click('#neighborTab');await p.waitForTimeout(500);
 r.localCards=await p.$$eval('#neighborBox svg g.node',gs=>gs.map(g=>({id:g.dataset.node,title:[...g.querySelectorAll('text')].slice(1,-1).map(t=>t.textContent),full:g.querySelector('title')?.textContent||'',widest:Math.max(...[...g.querySelectorAll('text')].slice(1,-1).map(t=>t.getComputedTextLength())),rect:+g.querySelector('rect').getAttribute('width')})));
 r.heading=await p.$eval('#neighborBox h3',h=>h.textContent);
 await p.$eval('#neighborBox',e=>e.scrollIntoView({block:'start'}));await p.screenshot({path:out+'/cards-view.png'});
 // clicking a side card still re-centers the local map
 await (await p.$('#neighborBox svg g.node[data-node="DOC-026"]')).click();await p.waitForTimeout(400);r.headingAfterClick=await p.$eval('#neighborBox h3',h=>h.textContent);
 // 6. plan editor folded by default; open, type, switch tabs, re-render, close
 await p.click('#cardsTab');await p.waitForTimeout(400);
 const state=()=>p.evaluate(()=>{const d=document.getElementById('planToolsDetails');return {exists:!!d,open:d?.open,summary:d?.querySelector('summary')?.textContent,name:document.getElementById('planAddName')?.value};});
 r.initial=await state();
 await p.click('#planToolsDetails > summary');await p.fill('#planAddName','試験の入力（適用しない）');r.typedOpen=await state();
 await p.click('#dependencyTab');await p.waitForTimeout(300);await p.click('#cardsTab');await p.waitForTimeout(300);r.afterTabSwitch=await state();
 await (await p.$('#cardList .card, #cardList article, #cardList button')).click().catch(()=>{});await p.waitForTimeout(400);r.afterRerender=await state();
 await p.click('#planToolsDetails > summary');await p.waitForTimeout(200);r.closedWithPending=await state();
 r.errors=errors;
}finally{await b.close();}console.log(JSON.stringify(r,null,1));})();
