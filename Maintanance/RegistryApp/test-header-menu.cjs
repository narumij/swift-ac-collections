// OPS-136: the top-left menu (actual createHeaderMenu with a stub DOM) and the header markup. No browser.
const fs=require('fs'),vm=require('vm'),assert=require('assert');
const html=fs.readFileSync(__dirname+'/index.template.html','utf8');
const a=html.indexOf('function createHeaderMenu('),b=html.indexOf('\nif(typeof document',a);assert(a>=0&&b>a);
const c={};vm.createContext(c);vm.runInContext(html.slice(a,b),c);
class Node{constructor(tag,parent){this.tag=tag;this.children=[];this.parent=null;this.hidden=false;this.disabled=false;this.textContent='';this.attrs={};this.handlers={};this.clicks=0;if(parent)parent.add(this);}
 add(n){n.parent=this;this.children.push(n);return n;}contains(n){for(;n;n=n.parent)if(n===this)return true;return false;}
 setAttribute(k,v){this.attrs[k]=v;}addEventListener(t,f){(this.handlers[t]||=[]).push(f);}
 closest(sel){for(let n=this;n;n=n.parent){if(sel.split(',').some(s=>s==='label.file'?n.tag==='label':n.tag===s))return n;}return null;}
 querySelectorAll(sel){const out=[];const walk=n=>{for(const x of n.children){if(x.tag===sel)out.push(x);walk(x);}};walk(this);return out;}
 querySelector(sel){return this.querySelectorAll(sel)[0]||null;}focus(){root.activeElement=this;}click(){this.clicks++;}}
const fire=(target,type,extra={})=>{const e={type,target,key:extra.key,prevented:false,preventDefault(){this.prevented=true;}};for(let n=target;n;n=n.parent)for(const f of n.handlers[type]||[])f(e);return e;};
const root=new Node('document');root.body=new Node('body',root);root.activeElement=root.body;
const header=new Node('header',root.body),button=new Node('button',header);
const menu=new Node('div',header);menu.hidden=true;
const [save,changes,refresh]=[0,1,2].map(()=>new Node('button',menu)),file=new Node('label',menu),input=new Node('input',file),restart=new Node('button',menu);
const outside=new Node('button',root.body);let later=[];
const m=c.createHeaderMenu({button,menu,root,defer:fn=>later.push(fn)});const flush=()=>{const l=later;later=[];l.forEach(f=>f());};
// open / close by the button
fire(button,'click');assert.equal(menu.hidden,false);assert.equal(button.attrs['aria-expanded'],'true');
fire(button,'click');assert.equal(menu.hidden,true);assert.equal(button.attrs['aria-expanded'],'false');
// Esc from inside the list closes and returns focus to the button
fire(button,'click');changes.focus();const esc=fire(changes,'keydown',{key:'Escape'});
assert(esc.prevented);assert.equal(menu.hidden,true);assert.strictEqual(root.activeElement,button);
// Esc on a closed menu does nothing (does not steal Esc from others)
assert.equal(fire(button,'keydown',{key:'Escape'}).prevented,false);
// outside click closes without moving focus; clicks on the button or inside the list do not count as outside
fire(button,'click');outside.focus();fire(outside,'click');assert.equal(menu.hidden,true);assert.strictEqual(root.activeElement,outside);
fire(button,'click');fire(menu,'click');flush();assert.equal(menu.hidden,false,'a click on the list background keeps it open');
// choosing an action closes after its own handler; focus back to the button only if it was left in the list or nowhere
save.focus();fire(save,'click');assert.equal(menu.hidden,false,'not closed during the click itself');flush();assert.equal(menu.hidden,true);assert.strictEqual(root.activeElement,button);
const dialog=new Node('dialog',root.body);fire(button,'click');fire(changes,'click');dialog.focus();flush();assert.equal(menu.hidden,true);assert.strictEqual(root.activeElement,dialog,'a dialog keeps its focus');
fire(button,'click');root.activeElement=root.body;fire(restart,'click');flush();assert.strictEqual(root.activeElement,button);
// the file label opens the picker from the keyboard (Enter/Space), and its click closes the menu afterwards
fire(button,'click');file.focus();fire(file,'keydown',{key:'Enter'});fire(file,'keydown',{key:' '});assert.equal(input.clicks,2);
fire(file,'keydown',{key:'a'});assert.equal(input.clicks,2);fire(file,'click');flush();assert.equal(menu.hidden,true);
// busy actions show on the button; recovery restores the label
refresh.disabled=true;m.busy();assert.equal(button.attrs['aria-busy'],'true');assert.equal(button.textContent,'','the labels are not rewritten (width kept)');
refresh.disabled=false;m.busy();assert.equal(button.attrs['aria-busy'],'false');
assert(html.includes('aria-busy="false"><span class="menu-idle">メニュー ▾</span><span class="menu-busy">処理中… ▾</span></button>'),'both labels in the button');
assert(html.includes('#headerMenuButton>span{grid-area:1/1}')&&html.includes('#headerMenuButton[aria-busy="true"]>.menu-busy{visibility:visible}'),'stacked labels: the button width is the wider label in both states');
// Markup (user's latest layout, 2026-10-19): top bar = task/work (left), title (centre), approval (right);
// the menu works on the task area, so it sits at the start of the task area beside the map tabs.
const header0=html.slice(html.indexOf('<header>'),html.indexOf('</header>'));
const toolbar=html.slice(html.indexOf('<div class="task-toolbar">'),html.indexOf('<section id="dependencyView"'));
const list=toolbar.slice(toolbar.indexOf('<div id="headerMenu"'),toolbar.indexOf('<div class="buttons" role="tablist"'));
const pos=['id="save"','id="changes"','id="refresh"','id="open"','<hr>','id="restart"'].map(x=>{const i=list.indexOf(x);assert(i>=0,x);return i;});
assert.deepEqual(pos,[...pos].sort((x,y)=>x-y),'order: save, changes, refresh, open, separator, restart');
assert(list.includes('hidden>'),'closed at load');assert(toolbar.indexOf('id="headerMenuButton"')<toolbar.indexOf('aria-label="見取り図"'),'menu before the map tabs');
assert(!header0.includes('id="headerMenuButton"')&&!header0.includes('id="save"'),'the menu is no longer in the top bar');
for(const id of ['header-approval-status','header-approval-all','canonicalNotice'])assert(header0.includes('id="'+id+'"')&&!list.includes('id="'+id+'"'),id+' stays in the top bar');
assert(!list.includes('id="status"'),'save result line stays outside');
const inRow2=header0.slice(header0.indexOf('<div class="header-row">'),header0.indexOf('<details id="canonicalNotice"'));
const at=x=>{const i=inRow2.indexOf(x);assert(i>=0,x);return i;};
assert(at('id="workAreaTab"')<at('id="taskAreaTab"')&&at('id="taskAreaTab"')<at('<h1>')&&at('<h1>')<at('id="header-approval-status"'),'work/task, title, approval');
assert(inRow2.includes('role="tablist" aria-label="表示する領域"')&&inRow2.includes('id="workAreaTab" role="tab" aria-selected="true" aria-controls="workArea"')&&inRow2.includes('id="taskAreaTab" role="tab" aria-selected="false" aria-controls="workspace" tabindex="-1"'),'work first and selected (user 2026-10-19)');
assert(html.includes('header .header-row{display:grid;grid-template-columns:minmax(0,1fr) auto minmax(0,1fr);'),'equal side columns keep the title centred without overlapping');
assert(html.includes('header .header-area-tabs{margin:0;display:grid;grid-template-columns:1fr 1fr;'),'task and work buttons have the same width');
assert(html.includes('@media(max-width:600px){header .header-approval-label{display:none}'),'narrow: the state comes first (the label is hidden; the group keeps its aria-label)');assert(header0.includes('aria-label="コミット事前承認"'));
for(const id of ['dependencyTab','permanentTab','protectionTab','cardsTab','neighborTab'])assert(!header0.includes('id="'+id+'"'),id+' not in the top bar');
const mainHtml=html.slice(html.indexOf('<main>'),html.indexOf('</main>'));assert(mainHtml.startsWith('<main><div class="task-toolbar"><div class="header-menu">'),'menu and map tabs at the top of the task area');
assert(html.includes("const MAP_TABS=['dependency','permanent','protection','cards','neighbor'];"),'map tabs unchanged');
assert(html.includes("const AREA_TABS=[['work','workArea'],['task','workspace']];"));
const workArea=html.slice(html.indexOf('<section id="workArea"'),html.indexOf('<div id="workspace"'));
assert(workArea.startsWith('<section id="workArea" class="work-area" role="tabpanel" aria-labelledby="workAreaTab" aria-label="作業">'),'work area shown at load, before the task area');
for(const id of ['activity-current-heading','activity-events','work-lane-track','presence-lamps','approval-track','probe-panel'])assert(workArea.includes('id="'+id+'"'),id+' in the work area');
for(const id of ['status','serverRestartNotice','canonicalNotice','header-approval-status','dependencyTab'])assert(!workArea.includes('id="'+id+'"'),id+' not in the work area');
assert(html.includes('<div id="workspace" class="layout sidebar-hidden" role="tabpanel" aria-labelledby="taskAreaTab" hidden>'),'task area hidden at load');
assert(html.includes('#workspace[hidden],#workArea[hidden]{display:none}'),'hidden wins over .layout display:grid');
assert(html.includes('@media(max-width:600px){header .header-approval-label{display:none}header .header-row{grid-template-columns:auto minmax(0,1fr)}header .header-row>h1{display:none}'),'narrow: the title gives way');
assert(html.lastIndexOf('@media(max-width:600px){header .header-approval-label{display:none}')>html.lastIndexOf('header .header-area-tabs>button{padding:5px 12px}')&&html.lastIndexOf('@media(max-width:600px){header .header-approval-label')>html.lastIndexOf('.header-approval button{padding:4px 8px}'),'the narrow rule comes after the rules it overrides');
const note=html.slice(html.indexOf('<section class="header-info"'),html.indexOf('</section>',html.indexOf('<section class="header-info"')));assert(note.includes('class="header-note"')&&!note.includes('activity-'),'only the note stays above');
// the area switch itself (actual code, stub DOM)
{const els={};const mk=id=>els[id]={id,hidden:false,tabIndex:0,attrs:{},setAttribute(k,v){this.attrs[k]=v;},focus(){els.focused=this;}};['workspace','workArea','taskAreaTab','workAreaTab'].forEach(mk);
 const ctx={$:id=>els[id]};vm.createContext(ctx);const src=html.slice(html.indexOf('const AREA_TABS='),html.indexOf('\n',html.indexOf('for(const [name] of AREA_TABS)')));vm.runInContext(src,ctx);
 ctx.switchArea('work');assert(els.workspace.hidden&&!els.workArea.hidden&&els.workAreaTab.attrs['aria-selected']==='true'&&els.workAreaTab.tabIndex===0&&els.taskAreaTab.tabIndex===-1);
 let prevented=false;els.workAreaTab.onkeydown({key:'ArrowRight',preventDefault(){prevented=true;}});assert(prevented&&!els.workspace.hidden&&els.workArea.hidden&&els.focused===els.taskAreaTab,'arrow moves right to task and moves focus');
 els.taskAreaTab.onkeydown({key:'Home',preventDefault(){}});assert(!els.workArea.hidden&&els.focused===els.workAreaTab,'Home goes to work (left)');els.workAreaTab.onkeydown({key:'End',preventDefault(){}});assert(!els.workspace.hidden&&els.focused===els.taskAreaTab,'End goes to task');els.workAreaTab.onclick();assert(!els.workArea.hidden);}
assert(html.includes("part.addEventListener('focusout',e=>{if(!part.contains(e.relatedTarget))part.scrollLeft=0;})"),'the approval part scrolls back when focus leaves');
console.log('PASS: OPS-136 header menu (toggle, Esc returns focus, outside click, close after the action, dialog focus kept, file picker by keyboard, busy label; markup order and things kept outside).');
