// OPS-126 proposals 1-2: headless measurement of the sticky header. Read-only except "変更内容を見る" (shows the diff only).
// Usage: node header-check.cjs <studio URL> <output dir>
//   Start an isolated test server first: REGISTRY_STUDIO_INBOX=$(mktemp -d) python3 -B Maintanance/RegistryApp/serve.py --port 18934
const pw=require('/opt/homebrew/lib/node_modules/playwright');const [url,out]=process.argv.slice(2);
(async()=>{const b=await pw.webkit.launch({headless:true});const results=[];try{
 for(const [w,h,shot] of [[1400,900,'header-wide.png'],[900,900,null],[390,844,'header-narrow.png']]){
  const p=await b.newPage({viewport:{width:w,height:h}});const errors=[];p.on('pageerror',e=>errors.push(e.message));
  await p.goto(url);await p.waitForTimeout(2500);const r={viewport:w+'x'+h};
  const hb=()=>p.$eval('header',e=>{const x=e.getBoundingClientRect();return {top:Math.round(x.top),bottom:Math.round(x.bottom),height:Math.round(x.height)};});
  r.stickyHeight=(await hb()).height;r.cssVar=await p.evaluate(()=>getComputedStyle(document.documentElement).getPropertyValue('--sticky-h').trim());
  // sticky still sticks
  await p.evaluate(()=>window.scrollTo(0,1500));await p.waitForTimeout(200);r.headerTopAfterScroll=(await hb()).top;
  // a graph card brought into view lands below the sticky header
  r.card=await p.evaluate(()=>{const g=[...document.querySelectorAll('#graph g.node')].find(n=>n.textContent.startsWith('GATE-0.6.1'))||document.querySelector('#graph g.node');g.scrollIntoView({block:'start'});const c=g.getBoundingClientRect(),hd=document.querySelector('header').getBoundingClientRect();const hit=document.elementFromPoint(c.left+10,c.top+5);return {cardTop:Math.round(c.top),headerBottom:Math.round(hd.bottom),visible:c.top>=hd.bottom-1&&!!hit&&g.contains(hit)};});
  if(shot)await p.screenshot({path:out+'/'+shot});
  // the diff panel lands below the sticky header
  await p.click('#changes');await p.waitForTimeout(1200);
  r.diff=await p.evaluate(()=>{const d=document.getElementById('diffPanel').getBoundingClientRect(),hd=document.querySelector('header').getBoundingClientRect();return {panelTop:Math.round(d.top),headerBottom:Math.round(hd.bottom),below:d.top>=hd.bottom-1};});
  // opening the canonical-change notice: the sticky height and the padding follow; record how far the content moves
  r.notice=await p.evaluate(async()=>{const n=document.getElementById('canonicalNotice'),hd=document.querySelector('header'),m=document.querySelector('main');const before={h:hd.getBoundingClientRect().height,main:m.getBoundingClientRect().top+scrollY};n.hidden=false;n.open=true;await new Promise(r=>setTimeout(r,300));const open={h:hd.getBoundingClientRect().height,main:m.getBoundingClientRect().top+scrollY,v:getComputedStyle(document.documentElement).getPropertyValue('--sticky-h').trim()};n.open=false;n.hidden=true;await new Promise(r=>setTimeout(r,300));return {heightClosed:Math.round(before.h),heightOpen:Math.round(open.h),cssVarOpen:open.v,mainShiftPx:Math.round(open.main-before.main),restoredVar:getComputedStyle(document.documentElement).getPropertyValue('--sticky-h').trim()};});
  // activity polling (every 3 s) does not move the scroll position
  await p.evaluate(()=>window.scrollTo(0,1200));await p.waitForTimeout(300);const y0=await p.evaluate(()=>scrollY);await p.waitForTimeout(7000);r.scrollYBefore=y0;r.scrollYAfterPolls=await p.evaluate(()=>scrollY);
  // back at the top, the activity band is visible and usable
  await p.evaluate(()=>window.scrollTo(0,0));await p.waitForTimeout(300);
  r.band=await p.evaluate(()=>{const t=document.getElementById('activity-events'),c=t.getBoundingClientRect(),cur=document.getElementById('activity-current-heading').getBoundingClientRect();t.scrollLeft=0;const left0=t.scrollLeft;t.scrollLeft=t.scrollWidth;const moved=t.scrollLeft>left0||t.scrollWidth<=t.clientWidth;t.focus();return {bandVisible:c.top>=0&&c.bottom<=innerHeight,currentVisible:cur.top>=0&&cur.bottom<=innerHeight,horizontalScroll:moved,focusable:document.activeElement===t,cards:t.children.length};});
  r.errors=errors;results.push(r);await p.close();
 }
}finally{await b.close();}console.log(JSON.stringify(results,null,1));})();
