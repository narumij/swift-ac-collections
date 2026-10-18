// OPS-126 proposals 7 and 8: headless check on an isolated test server. Read-only (no save/approve/refresh).
// Usage: node final-check.cjs <studio URL> <output dir> [webkit|chromium]
//   WebKit on macOS moves focus to buttons with Option+Tab (Safari default); Chromium uses Tab.
//   REGISTRY_STUDIO_INBOX=$(mktemp -d) python3 -B Maintanance/RegistryApp/serve.py --port 18936
const pw=require('/opt/homebrew/lib/node_modules/playwright');const [url,out,engine='webkit']=process.argv.slice(2),TAB=engine==='webkit'?'Alt+Tab':'Tab',tag=engine==='webkit'?'':'-'+engine;
(async()=>{const b=await pw[engine].launch({headless:true});const shot=n=>out+'/'+n.replace('.png',tag+'.png');const r={};try{
 const p=await b.newPage({viewport:{width:1400,height:900}});const errors=[];p.on('pageerror',e=>errors.push(e.message));
 await p.goto(url);await p.waitForTimeout(2500);
 // 8. Lines: one path per visible edge, same ends, cards where the layout puts them; spread ends only where 2+ lines enter.
 r.lines=await p.evaluate(()=>{
  const data=versionView(graphData(),document.getElementById('versionPicker').value),L=graphLayout(data.nodes,data.edges),W=250,H=96;
  const paths=[...document.querySelectorAll('#graph svg path[marker-end]')];
  const ends=paths.map(pa=>{const n=pa.getAttribute('d').match(/-?\d+(\.\d+)?/g).map(Number);return [n.at(-2),n.at(-1)];});
  const cardsMoved=[...document.querySelectorAll('#graph g.node')].filter(g=>{const id=(g.getAttribute('aria-label')||'').split(' ')[0],q=L.pos.get(id);if(!q)return false;const t=g.getAttribute('transform').match(/-?\d+(\.\d+)?/g).map(Number);return Math.abs(t[0]-q[0])>0.01||Math.abs(t[1]-q[1])>0.01;}).length;
  const groups=new Map();data.edges.forEach((e,i)=>{const a=L.pos.get(e.prerequisite),c=L.pos.get(e.successor);if(!a||!c)return;const kind=a[0]===c[0]?'vertical':'left';const key=e.successor+'|'+kind;(groups.get(key)||groups.set(key,[]).get(key)).push({i,e,c});});
  let multi=0,multiOk=0,single=0,singleOk=0,vertical=0,verticalOk=0;const examples=[];
  for(const [key,list] of groups){
   if(key.endsWith('|vertical')){for(const {i,c} of list){vertical++;if(Math.abs(ends[i][1]-c[1])<0.01&&Math.abs(ends[i][0]-(c[0]+W/2))<0.01)verticalOk++;}continue;}
   if(list.length===1){single++;const {i,c}=list[0];if(Math.abs(ends[i][1]-(c[1]+H/2))<0.01&&Math.abs(ends[i][0]-c[0])<0.01)singleOk++;continue;}
   multi++;const ys=list.map(({i})=>ends[i][1]),distinct=new Set(ys.map(y=>y.toFixed(2))).size,inside=ys.every(y=>y>list[0].c[1]&&y<list[0].c[1]+H),atCard=list.every(({i,c})=>Math.abs(ends[i][0]-c[0])<0.01);
   const srcOrder=list.slice().sort((x,y)=>L.pos.get(x.e.prerequisite)[1]-L.pos.get(y.e.prerequisite)[1]||(x.e.prerequisite<y.e.prerequisite?-1:1)).map(({i})=>ends[i][1]),ordered=srcOrder.every((y,k)=>!k||y>srcOrder[k-1]);
   if(distinct===list.length&&inside&&atCard&&ordered)multiOk++;if(examples.length<3)examples.push({into:key.split('|')[0],lines:list.length,distinctEnds:distinct,ordered});
  }
  return {edges:data.edges.length,paths:paths.length,cardsMoved,multi,multiOk,single,singleOk,vertical,verticalOk,examples};
 });
 await p.click('#graphZoomOut');await p.click('#graphZoomOut');await p.waitForTimeout(300);await p.$eval('#graph',e=>e.scrollIntoView({block:'start'}));await p.screenshot({path:shot('final-wide.png')});
 // clicking a card still selects it
 await p.click('#graphZoomReset');await (await p.$('#graph g.node:has(text:text-matches("^DOC-026"))')).click();r.clickSelected=(await p.textContent('#selectedTitle')).startsWith('DOC-026');
 // 7. Narrow: single scrolling rows, keyboard reach, visible focus; back to normal on a wide viewport.
 const rows=()=>p.evaluate(()=>{const row=document.querySelector('header .header-row'),tabs=document.querySelector('.buttons[role=tablist]'),h=document.querySelector('header');const s=e=>({wrap:getComputedStyle(e).flexWrap,overflowX:getComputedStyle(e).overflowX,scrollable:e.scrollWidth>e.clientWidth+1,height:Math.round(e.getBoundingClientRect().height)});return {header:Math.round(h.getBoundingClientRect().height),row:s(row),tabs:s(tabs)};});
 r.wide=await rows();
 await p.setViewportSize({width:390,height:844});await p.waitForTimeout(500);r.narrow=await rows();
 await p.evaluate(()=>window.scrollTo(0,0));await p.screenshot({path:shot('final-narrow.png')});
 // keyboard: from the first toolbar button, Tab to the last one (tabs: the tablist moves with the arrow keys); it scrolls into view and shows a focus ring
 r.keyboard=await (async()=>{await p.focus('#save');let last=null;for(let k=0;k<6;k++){const id=await p.evaluate(()=>document.activeElement.id);if(id==='restart'){last=id;break;}await p.keyboard.press(TAB);}
  const info=await p.evaluate(()=>{const e=document.activeElement,row=document.querySelector('header .header-row'),er=e.getBoundingClientRect(),rr=row.getBoundingClientRect();return {focused:e.id,inView:er.left>=rr.left-1&&er.right<=rr.right+1,right:Math.round(er.right),rowRight:Math.round(rr.right),outline:getComputedStyle(e).outlineStyle+' '+getComputedStyle(e).outlineWidth,rowScrollLeft:Math.round(row.scrollLeft)};});return {reachedLast:last==='restart',...info};})();
 r.tabsKeyboard=await (async()=>{await p.focus('#dependencyTab');for(let k=0;k<6;k++){if(await p.evaluate(()=>document.activeElement.id)==='neighborTab')break;await p.keyboard.press('ArrowRight');}
  return p.evaluate(()=>{const e=document.activeElement,box=e.parentElement.getBoundingClientRect(),er=e.getBoundingClientRect();return {focused:e.id,inView:er.left>=box.left-1&&er.right<=box.right+1,outline:getComputedStyle(e).outlineStyle};});})();
 await p.setViewportSize({width:1400,height:900});await p.waitForTimeout(500);r.backToWide=await rows();
 r.engine=engine;r.errors=errors;
}finally{await b.close();}console.log(JSON.stringify(r,null,1));})();
