// OPS-154 区切り0/1: isolated capture of the task maps (dependency graph, independent strip, permanent map, card list) and of
// selection sharing and input retention, for the compatibility baseline. No server and no network: the generated page is
// opened as a file:// copy whose seed is replaced by a fixture, so every fetch path is off. Fixed for repeatability:
// TZ=UTC, locale ja-JP, viewport, and text measuring (canvas measureText = 7 px per character).
// Usage: node task-view-model-capture.cjs <generated index.html> <fixture.json> <out.json>
const pw=require('/opt/homebrew/lib/node_modules/playwright'),fs=require('fs'),os=require('os'),path=require('path');
const [page,fixture,out]=process.argv.slice(2);
const html=fs.readFileSync(page,'utf8'),seed=fs.readFileSync(fixture,'utf8').replace(/<\//g,'<\\/');
const a=html.indexOf('<script id="seed" type="application/json">'),b=html.indexOf('</script>',a);if(a<0||b<0)throw Error('seed block');
const dir=fs.mkdtempSync(path.join(os.tmpdir(),'ops154-capture-')),file=path.join(dir,'index.html');
fs.writeFileSync(file,html.slice(0,a)+'<script id="seed" type="application/json">'+seed+html.slice(b));
(async()=>{const browser=await pw.webkit.launch();const r={steps:[],errors:[]};
 try{const ctx=await browser.newContext({viewport:{width:1400,height:900},timezoneId:'UTC',locale:'ja-JP'});
  await ctx.addInitScript(()=>{CanvasRenderingContext2D.prototype.measureText=function(t){return {width:[...String(t)].length*7};};window.confirm=()=>true;});
  const p=await ctx.newPage();p.on('pageerror',e=>r.errors.push(e.message));
  await p.goto('file://'+file);await p.waitForTimeout(400);await p.click('#taskAreaTab');await p.waitForTimeout(100);
  const snap=async name=>r.steps.push({name,...await p.evaluate(()=>{const h=id=>{const n=document.getElementById(id);return n?n.innerHTML:null;},t=id=>{const n=document.getElementById(id);return n?n.textContent:null;};
   const picker=document.getElementById('versionPicker');
   return {graph:h('graph'),independent:h('independent'),independentCount:t('independentCount'),permanentMap:h('permanentMap'),permanentMapCount:t('permanentMapCount'),cardList:h('cardList'),cardsCount:t('cardsCount'),
    picker:picker?{value:picker.value,options:[...picker.options].map(o=>[o.value,o.textContent])}:null,selectedTitle:t('selectedTitle'),tip:(()=>{const n=document.getElementById('graphTip');return {hidden:n.hidden,text:n.textContent};})()};})});
  await snap('load');
  await p.selectOption('#versionPicker','');await snap('version: all');
  const folders=await p.$$eval('#versionPicker option',o=>o.map(x=>x.value).filter(v=>v&&v!=='@head'));
  if(folders.length){await p.selectOption('#versionPicker',folders[0]);await snap('version: '+folders[0]);await p.selectOption('#versionPicker','');}
  await p.click('#dependencyTab');const nodes=await p.$$('#graph g.node');if(nodes.length>2){await nodes[2].click();await snap('select a graph node');}
  await p.check('#graphHoverEnabled').catch(()=>{});const n2=await p.$$('#graph g.node');if(n2.length>1){await n2[1].hover();await p.waitForTimeout(50);await snap('hover a node');}
  await p.click('#cardsTab');await p.selectOption('#cardOrder','id');await snap('cards by id');
  const cards=await p.$$('#cardList button.task');if(cards.length>1){await cards[1].click();await snap('select a card');}
  await p.selectOption('#cardOrder','grouped').catch(()=>{});
  await p.click('#dependencyTab');const ind=await p.$$('#independent button.task');if(ind.length){await ind[0].click();await snap('select an independent task');}
  // input retention: type in the editor, then switch map tabs, change the card order, and change the version filter
  const field=await p.$('#editor #owner')||await p.$('#editor input');
  if(field){const id=await field.getAttribute('id');await field.fill('入力中の値');const val=()=>p.evaluate(i=>{const n=document.getElementById(i);return n?n.value:null;},id);
   const keep={field:id,afterType:await val()};await p.click('#permanentTab');await p.click('#dependencyTab');keep.afterTabs=await val();
   await p.click('#cardsTab');await p.selectOption('#cardOrder','id');keep.afterCardOrder=await val();await p.click('#dependencyTab');
   await p.selectOption('#versionPicker',folders[0]||'').catch(()=>{});keep.afterVersionChange=await val();r.inputRetention=keep;}
 }finally{await browser.close();fs.rmSync(dir,{recursive:true,force:true});}
 fs.writeFileSync(out,JSON.stringify(r,null,1)+'\n');console.log('captured',r.steps.length,'steps, errors',r.errors.length,out);})().catch(e=>{console.error(e);process.exit(1);});
