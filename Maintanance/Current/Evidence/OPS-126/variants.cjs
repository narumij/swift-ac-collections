const pw=require('/opt/homebrew/lib/node_modules/playwright');const [url,out]=process.argv.slice(2);
(async()=>{const res={};for(const name of ['webkit','chromium']){const b=await pw[name].launch({headless:true});try{
 const p=await b.newPage({viewport:{width:1400,height:900}});await p.goto(url);await p.waitForTimeout(2500);
 const vis=()=>p.$eval('#graphTip',t=>!t.hidden);
 const hover=async()=>{const c=await p.$('#graph g.node:has(text:text-matches("^DOC-026"))');await c.scrollIntoViewIfNeeded();const bx=await c.boundingBox();await p.mouse.move(bx.x+bx.width/2+2,bx.y+bx.height/2);await p.mouse.move(bx.x+bx.width/2,bx.y+bx.height/2);await p.waitForTimeout(300);return vis();};
 const r={};
 r.h1=await hover();await p.keyboard.press('PageDown');await p.waitForTimeout(500);r.pageDown=await vis();
 r.h2=await hover();await p.evaluate(()=>window.scrollBy(0,600));await p.waitForTimeout(500);r.scriptScroll=await vis();
 r.h3=await hover();await p.keyboard.press('Space');await p.waitForTimeout(500);r.space=await vis();
 if(name==='webkit')await p.screenshot({path:out+'/before-pagedown.png'});
 res[name]=r;
}finally{await b.close();}}console.log(JSON.stringify(res));})();
