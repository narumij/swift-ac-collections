// OPS-136 headless check of the top-left menu on an isolated test server. Activity and approvals are mocked; POSTs to
// /save, /sync and /commit-approvals are intercepted (recorded, then aborted), so nothing is saved, synced or approved.
// Usage: node check.cjs <studio URL> <output dir>
//   REGISTRY_STUDIO_INBOX=$(mktemp -d) python3 -B Maintanance/RegistryApp/serve.py --port 18942
const pw=require('/opt/homebrew/lib/node_modules/playwright');const [url,out]=process.argv.slice(2);
let seq=0;const events=[];
const ev=(taskId,event,owner,reason,extra={})=>{seq++;events.push({schemaVersion:1,id:seq.toString(16).padStart(32,'0'),taskId,event,owner,reason,timestamp:new Date(Date.UTC(2026,9,19,1,0,seq)).toISOString().replace('.000Z','Z'),commitSha:'',...extra});};
ev('OPS-901','request','Astra','依頼',{next:'姫'});ev('OPS-903','awaiting-commit','Astra','承認待ち',{next:'user'});
const approvals={policyNotice:'模擬データ',requests:[{id:'mock-1',revision:1,taskId:'OPS-903',title:'模擬の承認',scope:'s',paths:['a'],condition:'c',branch:'b',status:'pending',createdAt:'2026-10-19T01:00:00Z',updatedAt:'2026-10-19T01:00:00Z'}]};
const posts=[];
async function mock(page){
 await page.route('**/activity-events',r=>r.fulfill({status:200,contentType:'application/json',body:JSON.stringify(events)}));
 await page.route('**/commit-approvals',r=>{if(r.request().method()!=='GET'){posts.push('approvals');return r.abort();}return r.fulfill({status:200,contentType:'application/json',body:JSON.stringify(approvals)});});
 await page.route('**/save',r=>{posts.push('save');return r.abort();});
 await page.route('**/sync',async r=>{posts.push('sync');await new Promise(f=>setTimeout(f,1500));return r.abort();});
}
const state=p=>p.evaluate(()=>{const b=document.getElementById('headerMenuButton'),m=document.getElementById('headerMenu'),r=e=>{const x=e.getBoundingClientRect();return {left:Math.round(x.left),top:Math.round(x.top),right:Math.round(x.right),bottom:Math.round(x.bottom)};};
 return {open:!m.hidden,expanded:b.getAttribute('aria-expanded'),label:b.textContent,focus:document.activeElement.id||document.activeElement.tagName.toLowerCase()+(document.activeElement.className?'.'+document.activeElement.className:''),
  button:r(b),title:r(document.querySelector('header h1')),list:m.hidden?null:r(m),items:m.hidden?[]:[...m.children].filter(x=>x.tagName!=='HR').map(x=>({text:x.textContent.trim(),...r(x)})),
  approval:{text:document.getElementById('header-approval-status').textContent,visible:document.getElementById('header-approval-status').getBoundingClientRect().height>0,all:document.getElementById('header-approval-all').textContent},
  row:(()=>{const h=document.querySelector('header .header-row').getBoundingClientRect(),ap=document.querySelector('header .header-approval'),all=document.getElementById('header-approval-all').getBoundingClientRect(),apr=ap.getBoundingClientRect();
   const mid=x=>x.top+x.height/2,items=[b.getBoundingClientRect(),document.querySelector('header h1').getBoundingClientRect(),apr];
   return {height:Math.round(h.height),sameRow:items.every(x=>x.top>=h.top-1&&x.bottom<=h.bottom+1),approval:r(ap),scrolls:ap.scrollWidth>ap.clientWidth+1,scrollLeft:Math.round(ap.scrollLeft),allInView:all.left>=apr.left-1&&all.right<=apr.right+1};})(),
  status:{hidden:document.getElementById('status').hidden,text:document.getElementById('status').textContent.slice(0,60)},vw:innerWidth};});
(async()=>{const b=await pw.webkit.launch({headless:true});const r={};try{
 for(const [name,w,h] of [['wide',1400,900],['narrow',390,844]]){
  const p=await b.newPage({viewport:{width:w,height:h}});const errors=[],dialogs=[];p.on('pageerror',e=>errors.push(e.message));p.on('dialog',d=>{dialogs.push(d.message().slice(0,40));d.dismiss();});await mock(p);
  await p.goto(url);await p.waitForTimeout(2500);const s={};r[name]=s;
  // user (2026-10-19): the work area is shown first; then open the task area, which was rendered while hidden
  s.initial=await p.evaluate(()=>({selected:document.querySelector('header [role=tab][aria-selected=true]').id,order:[...document.querySelectorAll('header .header-area-tabs>button')].map(b=>b.textContent),workVisible:!document.getElementById('workArea').hidden,taskHidden:document.getElementById('workspace').hidden,laneCards:document.querySelectorAll('#work-lane-track .work-card').length}));
  await p.screenshot({path:`${out}/${name}-initial.png`,clip:{x:0,y:0,width:w,height:Math.min(h,420)}});
  await p.click('#taskAreaTab');await p.waitForTimeout(500);
  s.taskAfterHiddenLoad=await p.evaluate(()=>{const nodes=[...document.querySelectorAll('#graph g.node')],first=nodes[0]?.getBoundingClientRect();return {nodes:nodes.length,firstCardSize:first?[Math.round(first.width),Math.round(first.height)]:null,paths:document.querySelectorAll('#graph svg path[marker-end]').length,zoomLabel:document.getElementById('graphZoomReset').textContent};});
  await p.click('#graphZoomIn');await p.waitForTimeout(200);s.taskAfterHiddenLoad.zoomAfter=await p.textContent('#graphZoomReset');await p.click('#graphZoomReset');
  s.closed=await state(p);await p.screenshot({path:`${out}/${name}-closed.png`,clip:{x:0,y:0,width:w,height:Math.min(h,260)}});
  await p.click('#headerMenuButton');s.opened=await state(p);await p.screenshot({path:`${out}/${name}-open.png`,clip:{x:0,y:0,width:w,height:Math.min(h,420)}});
  s.insideViewport=s.opened.list.right<=w&&s.opened.list.left>=0;
  await p.mouse.click(w-20,h-20);await p.waitForTimeout(100);s.afterOutside=(await state(p)).open;
  // keyboard: Enter opens, Tab through the list, Esc closes back to the button
  await p.focus('#headerMenuButton');await p.keyboard.press('Enter');const order=[];
  for(let k=0;k<5;k++){await p.keyboard.press('Alt+Tab');order.push((await state(p)).focus);}
  s.keyboardOrder=order;await p.keyboard.press('Escape');const afterEsc=await state(p);s.afterEsc={open:afterEsc.open,focus:afterEsc.focus};
  if(name==='wide'){
   // polling while open with focus inside: stays open, focus kept
   await p.click('#headerMenuButton');await p.focus('#changes');ev('OPS-904','request','Astra','新しい依頼',{next:'姫'});await p.waitForTimeout(3500);
   const poll=await state(p);s.duringPoll={open:poll.open,focus:poll.focus};await p.keyboard.press('Escape');
   // changes
   await p.click('#headerMenuButton');await p.click('#changes');await p.waitForTimeout(300);const ch=await state(p);s.changes={open:ch.open,focus:ch.focus,diffVisible:await p.isVisible('#diffPanel')};
   // file picker by click and by keyboard
   await p.click('#headerMenuButton');const [fc1]=await Promise.all([p.waitForEvent('filechooser',{timeout:3000}).catch(()=>null),p.click('#headerMenu label.file')]);
   await p.waitForTimeout(100);s.fileClick={chooser:!!fc1,open:(await state(p)).open};
   await p.click('#headerMenuButton');await p.focus('#headerMenu label.file');const [fc2]=await Promise.all([p.waitForEvent('filechooser',{timeout:3000}).catch(()=>null),p.keyboard.press('Enter')]);
   s.fileKey={chooser:!!fc2};await p.keyboard.press('Escape');
   // save: the POST is intercepted; the result shows in #status outside the menu
   await p.click('#headerMenuButton');await p.click('#save');await p.waitForTimeout(800);const sv=await state(p);s.save={open:sv.open,focus:sv.focus,status:sv.status};
   // refresh: busy label on the menu button while the (delayed, then aborted) sync runs
   await p.click('#headerMenuButton');await p.click('#refresh');await p.waitForTimeout(400);const busy=await state(p);await p.waitForTimeout(2000);const done=await state(p);
   s.refresh={busyLabel:busy.label,open:busy.open,afterLabel:done.label,status:done.status};
   // restart: the existing confirm() appears; dismissed
   await p.click('#headerMenuButton');await p.click('#restart');await p.waitForTimeout(400);s.restart={dialogs:[...dialogs],open:(await state(p)).open};
  }
  // the bulk-approve button can be reached by keyboard inside the scrolling approval part and is fully shown when focused
  await p.focus('#workAreaTab').catch(()=>{});await p.focus('#taskAreaTab');let reached=false;for(let k=0;k<4&&!reached;k++){await p.keyboard.press('Alt+Tab');reached=(await state(p)).focus==='header-approval-all';}
  await p.waitForTimeout(300);const st=await state(p);s.approvalKeyboard={reached,focus:st.focus,row:st.row,disabled:await p.$eval('#header-approval-all',e=>e.disabled)};
  if(name==='narrow')await p.screenshot({path:`${out}/narrow-approval-focus.png`,clip:{x:0,y:0,width:w,height:120}});
  await p.keyboard.press('Alt+Tab');await p.waitForTimeout(200);s.approvalAfterLeave=(await state(p)).row.scrollLeft;
  // top bar: task/work (left, same width), title (centre, not overlapping), approval (right); the menu beside the map tabs
  s.layout=await p.evaluate(()=>{const row=document.querySelector('header .header-row').getBoundingClientRect(),inRow=e=>{const r=e.getBoundingClientRect();return r.height>0&&r.top>=row.top-1&&r.bottom<=row.bottom+1;};
   const area=document.querySelector('header .header-area-tabs'),h1=document.querySelector('header h1'),map=document.querySelector('main .buttons[role=tablist]');
   const t=h1.getBoundingClientRect(),ar=area.getBoundingClientRect(),ap=document.querySelector('header .header-approval').getBoundingClientRect(),btns=[...area.children].map(b=>Math.round(b.getBoundingClientRect().width));
   const overlap=(a,b)=>a.width>0&&b.width>0&&a.left<b.right&&b.left<a.right;
   return {rowHeight:Math.round(row.height),menuInTopBar:document.querySelector('header').contains(document.getElementById('headerMenuButton')),menuBesideMapTabs:document.getElementById('headerMenuButton').closest('.task-toolbar')===map.closest('.task-toolbar'),
    areaButtonWidths:btns,titleCentreOffset:t.width?Math.round((t.left+t.width/2)-(row.left+row.width/2)):null,titleOverlaps:overlap(t,ar)||overlap(t,ap),areaTabs:inRow(area),areaTabsBox:[Math.round(area.getBoundingClientRect().left),Math.round(area.getBoundingClientRect().right)],titleShown:h1.getBoundingClientRect().width>0,
    approvalInRow:inRow(document.querySelector('header .header-approval')),headerBottom:Math.round(document.querySelector('header').getBoundingClientRect().bottom),mapTabsTop:Math.round(map.getBoundingClientRect().top+scrollY),mapInMain:!!map.closest('main'),
    selectedArea:document.querySelector('header [role=tab][aria-selected=true]').id,taskVisible:!document.getElementById('workspace').hidden,workHidden:document.getElementById('workArea').hidden};});
  await p.click('#headerMenuButton');s.menuOverContent=await p.evaluate(()=>{const m=document.getElementById('headerMenu').getBoundingClientRect();const e=document.elementFromPoint(m.left+20,m.bottom-10);return document.getElementById('headerMenu').contains(e);});await p.keyboard.press('Escape');
  // task-side state before going to work: the card list tab, a typed (not applied) input, a selected task
  await p.click('#cardsTab');await p.click('#planToolsDetails > summary').catch(()=>{});await p.fill('#planAddName','往復で残る入力（適用しない）');
  const before=await p.evaluate(()=>({map:document.querySelector('main [role=tab][aria-selected=true]').id,selected:document.getElementById('selectedTitle').textContent,input:document.getElementById('planAddName').value}));
  // updates while the work area is hidden
  ev('OPS-950','return','姫','タスク表示中の返却 '+name,{next:'Astra'});approvals.requests[0].status='approved';approvals.requests[0].revision=2;await p.waitForTimeout(4000);
  const hiddenHeader=await p.evaluate(()=>document.getElementById('header-approval-status').textContent);
  await p.focus('#taskAreaTab');await p.keyboard.press('ArrowRight');await p.waitForTimeout(300);
  s.work=await p.evaluate(()=>{const lane=[...document.querySelectorAll('#work-lane-track .work-card')].map(n=>n.children[0].textContent);
   return {focus:document.activeElement.id,selected:document.querySelector('header [role=tab][aria-selected=true]').id,workVisible:!document.getElementById('workArea').hidden,taskHidden:document.getElementById('workspace').hidden,
    laneHasNew:lane.some(t=>t.startsWith('OPS-950')),current:document.getElementById('activity-current-heading').textContent,headerApproval:document.getElementById('header-approval-status').textContent,
    laneHeading:document.querySelector('#workArea .approval-heading').textContent.replace(/\s+/g,' ').slice(0,120),statusOutside:!document.getElementById('workArea').contains(document.getElementById('status'))&&!document.getElementById('workspace').contains(document.getElementById('status'))};});
  s.work.headerWhileHidden=hiddenHeader;
  await p.screenshot({path:`${out}/${name}-work.png`,clip:{x:0,y:0,width:w,height:Math.min(h,520)}});
  await p.keyboard.press('End');await p.waitForTimeout(300);
  const after=await p.evaluate(()=>({map:document.querySelector('main [role=tab][aria-selected=true]').id,selected:document.getElementById('selectedTitle').textContent,input:document.getElementById('planAddName').value,focus:document.activeElement.id,taskVisible:!document.getElementById('workspace').hidden}));
  s.roundTrip={before,after,kept:before.map===after.map&&before.selected===after.selected&&before.input===after.input};
  await p.screenshot({path:`${out}/${name}-task.png`,clip:{x:0,y:0,width:w,height:Math.min(h,300)}});
  approvals.requests[0].status='pending';approvals.requests[0].revision=3;await p.click('#dependencyTab');
  s.errors=errors;await p.close();
 }
 r.posts=posts;
}finally{await b.close();}console.log(JSON.stringify(r,null,1));})();
