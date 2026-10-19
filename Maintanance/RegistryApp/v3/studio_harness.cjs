// OPS-165 function harness: the real Studio functions, extracted by name from a read-only index.template.html, run in a
// vm with a stub DOM on a V3 export. This is a function harness, not browser validation; the template file is never
// written. Compatibility patches are applied to the extracted source text only, each must match exactly once, and the
// list is printed with every result (PATCHES below).
//
// node studio_harness.cjs edit <export.json> <actions.json> <save-out.json>
//   loads the export as the page does (check, initializeRelationBaseline), runs the actions through the real editor
//   (editorViewModel/drawEditor/editorAct): [{"select":ID}, {"set":{"owner":"X","state":"DONE"}}, {"apply":true},
//   {"addPrerequisite":ID}, {"press":"button text"}], then builds the save payload as the page's save button does and writes it.
// node studio_harness.cjs resume <save.json> <latest-export.json>
//   reads a saved JSON back (check), and prints the banner text and the three-way rows (canonicalDifferences and
//   editsReflected of the save's baseline, the save and the latest export).
'use strict';
const fs = require('fs'), vm = require('vm'), path = require('path');
const TEMPLATE = process.env.STUDIO_TEMPLATE || path.join(__dirname, '..', 'index.template.html');
const html = fs.readFileSync(TEMPLATE, 'utf8');
const fn = name => { const a = html.indexOf('\nfunction ' + name + '('); if (a < 0) throw Error('function not found: ' + name); const m = /\)\s*\{/g; m.lastIndex = a; let i = html.indexOf('{', m.exec(html).index), d = 0; for (; i < html.length; i++) { if (html[i] === '{') d++; else if (html[i] === '}' && --d === 0) break; } return html.slice(a + 1, i + 1); };
const line = prefix => { const a = html.indexOf('\n' + prefix); if (a < 0) throw Error('line not found: ' + prefix); return html.slice(a + 1, html.indexOf('\n', a + 1)); };

// Compatibility patches of this harness (the production template is unchanged and is NOT claimed to accept a V3 export).
const PATCHES = [
  ['check', "typeof d.source.sha256!=='string'",
   "(d.source.kind==='v3-export'?!(d.v3&&typeof d.source.generation==='string'&&Number.isInteger(d.source.revision)&&d.source.sha256===undefined):typeof d.source.sha256!=='string')",
   'P1 check(): a V3 export has no source.sha256; it is accepted only with source.kind v3-export, a generation and an integer revision'],
  ['banner', "'生成元 '+doc.source.path+' · HEAD '+doc.source.head.slice(0,8)+' · '+doc.source.generatedAt+'\\nSHA-256 '+doc.source.sha256+' · '+(doc.source.dirty?'未コミット差分を含む':'コミット済み版')",
   "(doc.source.kind==='v3-export'?'V3 DB '+doc.source.path+' · 世代 '+doc.source.generation+' · 改訂 '+doc.source.revision+'\\npayloadHash '+doc.source.payloadHash.slice(0,12)+'（'+doc.source.payloadHashOf+'）':'生成元 '+doc.source.path+' · HEAD '+doc.source.head.slice(0,8)+' · '+doc.source.generatedAt+'\\nSHA-256 '+doc.source.sha256+' · '+(doc.source.dirty?'未コミット差分を含む':'コミット済み版'))",
   'P2 banner(): a V3 export shows its DB generation and revision and the named payloadHash, never a Git HEAD or a committed/uncommitted label'],
  ['banner', "(doc.source.sha256!==canonical.sha256?",
   "(doc.source.kind==='v3-export'?(doc.source.generation!==canonical.generation||doc.source.revision!==canonical.revision?'\\nDBが更新されています：この編集版の土台 世代 '+doc.source.generation+' 改訂 '+doc.source.revision+' → 最新 世代 '+canonical.generation+' 改訂 '+canonical.revision:''):'')+(doc.source.kind!=='v3-export'&&doc.source.sha256!==canonical.sha256?",
   'P3 banner(): the base comparison of a V3 export uses generation and revision instead of sha256'],
  ['planRebuild', 'function planRebuild(d,versions){',
   "function planRebuild(d,versions){const PLAN_SOURCE=(d.source&&d.source.kind==='v3-export')?'v3-db:skeleton':PLAN_SOURCE_FILE;",
   'P4 planRebuild(): for a V3 export the derived chain lines are the export\'s v3-db:skeleton lines (not Milestones/README.md), so a replan replaces them instead of leaving stale ones'],
  ['renderPlanTools', "const addVer=el('button','版を追加');box.append(addVer);addVer.onclick=()=>{if(formDirty){report('先に入力の「変更を適用」を押してください。',true);return;}try{const name=vn.value.trim();doc=planAddVersion(doc,vn.value);",
   "const after=el('select');after.id='planAddVersionAfter';options(after,['（先頭）'].concat(versions),versions[versions.length-1]);const la=el('label','追加する位置（この版の後）');la.append(after);box.append(la);const addVer=el('button','版を追加');box.append(addVer);addVer.onclick=()=>{if(formDirty){report('先に入力の「変更を適用」を押してください。',true);return;}try{const name=vn.value.trim();doc=planAddVersion(doc,vn.value);{const s=doc.milestones.find(m=>m.id==='START-'+name);if(s)s.planPosition={after:after.value==='（先頭）'?null:after.value};}",
   'P5 renderPlanTools(): 版を追加 gets an explicit position select (insert after a version, or first); the choice is kept as planPosition on the new START (OPS-176; the DB version order is authoritative)'],
];
const MIRRORED = ['M4 the proposal dialog: its add line (addProposal, then addMilestoneRelation or addProposalEdge for the chosen place) is called directly; the dialog DOM is not built','M3 the relation dialog: its apply line (doc=rewireRelation(doc,orig,pre,to)) and remove button (removeRelation(orig)) are called directly; the dialog DOM is not built','M1 the save payload: the first statements of the page\'s save button handler (check, copy, exportedAt, changes=delta(), studioSave {parent: null}); the handler is an inline arrow function, so it is mirrored here rather than extracted',
  'M2 the page load: check(d); initializeRelationBaseline(d); doc=d (as the open-file handler does)',
  'NOT EXERCISED: serve.py /save and Inbox (they require source.sha256 and would refuse a V3 export); resume over HTTP; the browser'];
function patched(name) {
  let src = fn(name);
  for (const [target, from, to] of PATCHES) if (target === name) { const n = src.split(from).length - 1; if (n !== 1) throw Error(`patch for ${name} matched ${n} times; the template changed`); src = src.replace(from, to); }
  return src;
}

class Node {
  constructor(tag, ids) { this.tag = tag; this.ids = ids; this.children = []; this.attrs = {}; this.style = {}; this._text = ''; this.className = ''; this.handlers = {}; this._id = ''; this.title = ''; this.htmlFor = ''; this.rows = 0; this._value = ''; this.hidden = false; }
  set id(v) { this._id = v; this.ids.set(v, this); } get id() { return this._id; }
  setAttribute(k, v) { this.attrs[k] = String(v); }
  append(...ns) { this.children.push(...ns); } appendChild(n) { this.children.push(n); } replaceChildren(...ns) { this.children = []; this._text = ''; this.append(...ns); }
  set textContent(v) { this._text = String(v); this.children = []; } get textContent() { return this._text + this.children.map(c => c.textContent).join(''); }
  get options() { return this.children.filter(c => c.tag === 'option'); }
  set value(v) { this._value = String(v); } get value() { if (this.tag !== 'select') return this._value; const o = this.options.find(c => c.value === this._value); return o ? o.value : ''; }
}
for (const k of ['onclick', 'oninput', 'onchange']) Object.defineProperty(Node.prototype, k, { get() { return this.handlers[k] || null; }, set(f) { this.handlers[k] = f; } });

function context() {
  const ids = new Map(), log = [], c = { log, console };
  c.document = { createElement: t => new Node(t, ids), createElementNS: (ns, t) => new Node(t, ids) };
  vm.createContext(c);
  for (const id of ['editor', 'taskPicker', 'selectedTitle', 'sourceInfo', 'planTools']) new Node(id === 'taskPicker' ? 'select' : 'div', ids).id = id;
  const names = ['el', 'options', 'field', 'documentLinks', 'proposalNodes', 'initializeRelationBaseline', 'planParts', 'planVersions', 'milestonePlanChanges', 'graphData', 'delta',
    'rewireRelation', 'planAddCard', 'planAddVersion', 'renderPlanTools', 'planClone', 'planCards', 'planRenumber', 'planRebuild', 'planCard', 'planEditText', 'planReorder', 'planMove', 'nextProposalId', 'addProposal', 'updateProposal', 'removeProposal', 'addProposalEdge',
    'removeRelation', 'isMilestoneLink', 'linkLabel', 'dataRelation', 'isChainLink', 'addMilestoneRelation', 'editorViewModel', 'milestonePlanBlocks', 'proposalBlocks',
    'drawEditor', 'editorAct', 'editor', 'canonicalDifferences', 'editsReflected'];
  const src = [line('const STATES='), line('const PLAN_DIR='), 'const PLAN_SOURCE_FILE=PLAN_SOURCE;', line('const CHAIN_NOTE='), line('const EDITOR_GUARD='), line('let planDraft='), patched('check'), patched('banner'), ...names.map(n => n === 'planRebuild' || n === 'renderPlanTools' ? patched(n) : fn(n))].join('\n') +
    '\nconst copy=x=>JSON.parse(JSON.stringify(x));var doc=null,selected=null,dirty=false,formDirty=false,workspace=null,canonical=null;' +
    'function $(id){return __ids.get(id)||null;}function report(m,e){log.push(["report",m,!!e]);}function confirm(m){log.push(["confirm",m]);return true;}' +
    'function renderCanonicalRestartSuggestion(){}function renderCanonicalNotice(){}function showNeighborhood(id){log.push(["neighborhood",id]);}function openDocument(p){}' +
    'function render(){editor();renderPlanTools();}function select(id){if(formDirty&&!confirm("x"))return;formDirty=false;selected=id;render();}' +
    'function __load(d){check(d);initializeRelationBaseline(d);doc=d;canonical=copy(d.source);selected=d.tasks[0]&&d.tasks[0].id;dirty=false;formDirty=false;}' +
    'function __save(){if(formDirty)throw Error("入力中の変更を先に「変更を適用」で確定してください。");check(doc);const out=copy(doc);out.exportedAt=new Date().toISOString();out.changes=delta();out.studioSave={parent:null};return out;}' +
    'function __state(){return {doc,selected,dirty,formDirty};}function __setCanonical(s){canonical=copy(s);}' +
    // M3: the relation dialog's apply and remove lines (the dialog DOM is not built): rewireRelation / removeRelation on the shown relation
    'function __rel(a,b){const r=graphData().edges.find(e=>(e.shownFrom||e.prerequisite)===a&&(e.shownFor||e.successor)===b)||doc.edges.find(e=>e.prerequisite===a&&e.successor===b)||(doc.milestoneRelations||[]).find(e=>e.prerequisite===a&&e.successor===b);if(!r)throw Error("relation not found: "+a+" -> "+b);return dataRelation(r);}' +
    // M4: the proposal dialog's add line (the dialog DOM is not built): addProposal, then the chosen place, then select it
    'function __proposal(title,memo,v){let {data,id}=addProposal(doc,title,memo);if(v.startsWith("ms:"))data=addMilestoneRelation(data,id,v.slice(3));else if(v.startsWith("task:"))data=addProposalEdge(data,id,v.slice(5),"SEQUENCE");doc=data;selected=id;dirty=true;render();}' +
    'function __remove(a,b){removeRelation(__rel(a,b));}function __rewire(f,t){const orig=__rel(f.prerequisite,f.successor);doc=rewireRelation(doc,orig,t.prerequisite,t.successor);dirty=true;render();}';
  c.__ids = ids;
  vm.runInContext(src, c);
  return c;
}
const all = n => [n, ...n.children.flatMap(all)];
function press(c, text, where = 'editor') { const b = all(c.__ids.get(where)).find(n => n.tag === 'button' && n.textContent === text); if (!b) throw Error('button not found: ' + text); b.onclick(); }

function edit(exportFile, actionsFile, out) {
  const c = context(), d = JSON.parse(fs.readFileSync(exportFile, 'utf8'));
  c.__load(d);
  c.editor();
  c.renderPlanTools();
  for (const a of JSON.parse(fs.readFileSync(actionsFile, 'utf8'))) {
    if (a.select) { const p = c.__ids.get('taskPicker'); p.value = a.select; p.onchange(); }
    if (a.set) for (const [k, v] of Object.entries(a.set)) { const n = c.__ids.get(k); if (!n) throw Error('field not found: ' + k); n.value = v; if (n.oninput) n.oninput(); }
    if (a.apply) press(c, '変更を適用');
    if (a.addPrerequisite) { c.__ids.get('prerequisite').value = a.addPrerequisite; press(c, '前提を追加'); }
    if (a.press) press(c, a.press);
    if (a.pressTool) press(c, a.pressTool, 'planTools');  // the card list's plan tools (renderPlanTools)
    if (a.remove) c.__remove(a.remove.prerequisite, a.remove.successor);
    if (a.rewire) c.__rewire(a.rewire.from, a.rewire.to);
    if (a.proposal) c.__proposal(a.proposal.title, a.proposal.memo || '', a.proposal.place || '');
  }
  let save;
  try { save = c.__save(); } catch (e) { throw Error(e.message + ' | editor reports: ' + JSON.stringify(c.log.filter(l => l[0] === 'report'))); }
  fs.writeFileSync(out, JSON.stringify(save, null, 2) + '\n');
  return { saved: out, delta: JSON.parse(JSON.stringify(save.changes)), reports: JSON.parse(JSON.stringify(c.log.filter(l => l[0] === 'report'))) };
}

function resume(saveFile, latestFile) {
  const c = context(), save = JSON.parse(fs.readFileSync(saveFile, 'utf8')), latest = JSON.parse(fs.readFileSync(latestFile, 'utf8'));
  c.__load(save);
  c.__setCanonical(latest.source);
  c.banner();
  c.initializeRelationBaseline(latest);
  return { banner: c.__ids.get('sourceInfo').textContent, rows: JSON.parse(JSON.stringify(c.canonicalDifferences(save.baseline, save, latest))),
           reflected: c.editsReflected(save.baseline, save, latest) };
}

const [cmd, ...args] = process.argv.slice(2);
const result = cmd === 'edit' ? edit(...args) : cmd === 'resume' ? resume(...args) : (() => { throw Error('usage: edit|resume'); })();
console.log(JSON.stringify({ ...result, patches: PATCHES.map(p => p[3]), mirrored: MIRRORED, template: TEMPLATE }));
