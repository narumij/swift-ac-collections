// OPS-126 re-runnable headless check (proposals 3 and 5). Read-only: no save/approve/refresh clicks.
// Usage: node check.cjs <studio URL> <output dir> <label>
//   Start an isolated test server first, e.g. REGISTRY_STUDIO_INBOX=$(mktemp -d) python3 -B Maintanance/RegistryApp/serve.py --port 18933
const pw=require('/opt/homebrew/lib/node_modules/playwright');const [url,out,label]=process.argv.slice(2);
(async()=>{const b=await pw.webkit.launch({headless:true});const r={label};try{
 const p=await b.newPage({viewport:{width:1400,height:900}});const errors=[];p.on('pageerror',e=>errors.push(e.message));
 await p.goto(url);await p.waitForTimeout(2500);
 const tipVisible=()=>p.$eval('#graphTip',t=>!t.hidden);
 const card=await p.$('#graph g.node:has(text:text-matches("^DOC-026"))');await card.scrollIntoViewIfNeeded();const box=await card.boundingBox();
 await p.mouse.move(box.x+box.width/2,box.y+box.height/2);await p.waitForTimeout(300);r.hoverShows=await tipVisible();
 await p.mouse.wheel(0,700);await p.waitForTimeout(500);r.afterPageWheel=await tipVisible();await p.screenshot({path:`${out}/${label}-after-wheel.png`});
 // hover again after scrolling back: it must reappear
 await card.scrollIntoViewIfNeeded();const box2=await card.boundingBox();await p.mouse.move(box2.x+box2.width/2+3,box2.y+box2.height/2);await p.mouse.move(box2.x+box2.width/2,box2.y+box2.height/2);await p.waitForTimeout(300);r.reHoverShows=await tipVisible();
 // leaving the graph area closes it
 await p.mouse.move(5,5);await p.waitForTimeout(300);r.afterLeave=await tipVisible();
 // hover setting OFF: no tooltip
 await p.uncheck('#graphHoverEnabled');await p.mouse.move(box2.x+box2.width/2,box2.y+box2.height/2);await p.waitForTimeout(300);r.offShows=await tipVisible();await p.check('#graphHoverEnabled');
 // click still selects
 await card.click();await p.waitForTimeout(300);r.clickSelected=(await p.textContent('#selectedTitle')).startsWith('DOC-026');
 // proposal 3: unknown start in the work lane
 r.lane=await p.$$eval('#work-lane-track .work-card',cs=>cs.map(c=>({line:c.children[3]?.textContent||'',title:c.title})).filter(x=>/不明|範囲外/.test(x.line+x.title)).slice(0,2));
 await p.screenshot({path:`${out}/${label}-top.png`,clip:{x:0,y:180,width:1400,height:200}});
 r.errors=errors;
}finally{await b.close();}console.log(JSON.stringify(r));})();
