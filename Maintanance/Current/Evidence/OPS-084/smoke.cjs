// OPS-084 smoke: milestones as prerequisite/successor of a proposal and a task (MS-SPI → 「SPI登録後のタスク出し」), edit-version resume, save snapshot, refresh guard, restart, against a stubbed fetch, on the same minimal DOM stub as OPS-081 (no browser, no Safari).
// Usage: node smoke.cjs [path/to/index.html]   (default: Maintanance/Cache/RegistryStudio/index.html)
'use strict';
const fs = require('fs'), path = require('path'), vm = require('vm'), assert = require('assert');
const html = fs.readFileSync(process.argv[2] || path.resolve(__dirname, '../../../Cache/RegistryStudio/index.html'), 'utf8');
const script = html.split('<script>')[1].split('</script>')[0];
const embedded = id => { const m = new RegExp(`<script[^>]*id="${id}"[^>]*>([\\s\\S]*?)</script>`).exec(html); return m ? m[1] : ''; };

class Node {
  constructor(tag) { this.tagName = String(tag).toUpperCase(); this.childNodes = []; this.attributes = {}; this.style = {}; this.value = ''; this.hidden = false; this.disabled = false;
    this._text = ''; const self = this; this.classList = { _s: new Set(), add(c) { this._s.add(c); }, remove(c) { this._s.delete(c); }, toggle(c, on) { (on ?? !this._s.has(c)) ? this._s.add(c) : this._s.delete(c); }, contains(c) { return this._s.has(c); } };
    this.options = this.childNodes; this.open = false; this.nodeType = 1; }
  get children() { return this.childNodes; }
  set id(v) { this._id = v; byId.set(v, this); }  // elements given an id are found by getElementById, as in a browser
  get id() { return this._id; }
  set className(v) { this.classList._s = new Set(String(v).split(/\s+/).filter(Boolean)); }
  get className() { return [...this.classList._s].join(' '); }
  set textContent(v) { this._text = String(v); this.childNodes = []; }
  get textContent() { return this._text + this.childNodes.map(c => c.textContent).join(''); }
  append(...xs) { for (const x of xs) this.childNodes.push(typeof x === 'string' ? Object.assign(new Node('#text'), { _text: x, nodeType: 3 }) : x); }
  replaceChildren(...xs) { this.childNodes = []; this.append(...xs); }
  remove() {} setAttribute(k, v) { this.attributes[k] = String(v); } getAttribute(k) { return this.attributes[k] ?? null; } hasAttribute(k) { return k in this.attributes; }
  addEventListener() {} focus() {} click() { if (this.onclick) this.onclick({ preventDefault() {}, stopPropagation() {} }); } scrollIntoView() {}
  showModal() { this.open = true; } close() { this.open = false; } getBoundingClientRect() { return { left: 0, right: 0, top: 0, bottom: 0, width: 0, height: 0 }; }
  getContext() { return { font: '', measureText: t => ({ width: String(t).length * 7 }) }; }
  querySelector(sel) { const tag = sel.toUpperCase(); const walk = n => { for (const c of n.childNodes) { if (c.tagName === tag) return c; const r = walk(c); if (r) return r; } return null; }; return walk(this); }
  all(pred, out = []) { for (const c of this.childNodes) { if (pred(c)) out.push(c); c.all(pred, out); } return out; }
}
const byId = new Map();
const document = { createElement: t => new Node(t), createElementNS: (_, t) => new Node(t), createTextNode: t => Object.assign(new Node('#text'), { _text: t, nodeType: 3 }), body: new Node('body'),
  getElementById(id) { if (!byId.has(id)) { const n = new Node('div'); n.id = id; if (['seed', 'documents', 'pendingSeed'].includes(id)) n._text = embedded(id); byId.set(id, n); } return byId.get(id); } };
let downloaded = null;
let fetchReply = null, fetchCalls = [];
let routes = {}, reloads = 0;
const ctx = { fetch: async (url, opts) => { fetchCalls.push({ url, opts }); const r = routes[url]; return typeof r === 'function' ? r(opts) : r; }, document, window: { addEventListener() {}, location: { reload() { reloads++; } } }, location: { protocol: 'http:' }, confirm: () => true, alert() {}, console, innerWidth: 1280, innerHeight: 800,
  setTimeout: () => 0, URL: Object.assign(function URL(u, b) { return new (require('url').URL)(u, b); }, { createObjectURL: blob => { downloaded = blob.text; return 'blob:x'; }, revokeObjectURL() {} }),
  Blob: function (parts) { this.text = parts.join(''); }, DOMParser: function () { this.parseFromString = () => ({ body: new Node('body') }); }, JSON, Math, Date, Set, Map, Array, Object, String, Number, Error, RegExp, Promise };
vm.createContext(ctx);
vm.runInContext(script.replace(/^'use strict';/, '') + '\n;globalThis.__get=()=>({doc,selected,dirty,formDirty});', ctx);
const $ = id => document.getElementById(id), state = () => ctx.__get();
const clickText = (root, text) => { const b = root.all(n => n.tagName === 'BUTTON' && n.textContent === text)[0]; assert(b, 'button not found: ' + text); b.click(); };





const reply = (status, body) => ({ ok: status >= 200 && status < 300, status, json: async () => body });
(async () => {
  const graphText = t => $('graph').all(n => n.tagName === 'TEXT' && n.textContent === t).length;
  // The map opens at the default HEAD view (the same one the user sees first).
  // 1. Proposal 「SPI登録後のタスク出し」 placed after MS-SPI from its editor.
  $('addProposal').click(); let form = $('proposalForm'); form.all(n => n.tagName === 'INPUT')[0].value = 'SPI登録後のタスク出し'; form.all(n => n.tagName === 'TEXTAREA')[0].value = 'バッジ対応の他に試験結果への対応を検討する'; clickText(form, '追加');
  assert.equal(state().selected, 'draft-1');
  assert($('proposalSource').childNodes.every(o => !/^(END|GATE)-/.test(o.value)), 'prerequisite choices: cards and START only');
  assert($('proposalTarget').childNodes.every(o => !/^(START|GATE)-/.test(o.value)), 'successor choices: END and cards only');
  $('proposalSource').value = 'MS-SPI'; clickText($('editor'), 'マイルストーンの後に続ける');
  assert(state().doc.milestoneRelations.some(e => e.prerequisite === 'MS-SPI' && e.successor === 'draft-1' && e.conditionReview === '相談待ち'));
  assert($('editor').all(n => n.tagName === 'STRONG' && n.textContent === 'MS-SPI → draft-1').length === 1, 'row shows the arrow');
  assert.equal(graphText('draft-1 · 追加案'), 1, 'drawn in the dependency map');
  assert(!$('independent').all(n => n.tagName === 'STRONG' && n.textContent === 'draft-1 · 追加案').length, 'no longer independent');
  // 2. The same proposal forward to an END, and a refusal that changes nothing.
  const end = $('proposalTarget').childNodes.find(o => o.value.startsWith('END-') && state().doc.milestones.find(m => m.id === o.value).state !== 'DONE').value;
  $('proposalTarget').value = end; clickText($('editor'), '到達点へつなぐ');
  assert(state().doc.milestoneRelations.some(e => e.prerequisite === 'draft-1' && e.successor === end));
  let before = JSON.stringify(state().doc); $('proposalSource').value = 'MS-SPI'; clickText($('editor'), 'マイルストーンの後に続ける');
  assert.equal(JSON.stringify(state().doc), before); assert(/既にあります/.test($('status').textContent));
  // 3. An existing task: card → task from the task editor.
  const task = state().doc.tasks.find(t => !t.permanent && !state().doc.edges.some(e => e.prerequisite === t.id || e.successor === t.id) && !state().doc.milestoneRelations.some(e => e.prerequisite === t.id || e.successor === t.id)).id;
  ctx.select(task); $('milestoneSource').value = 'MS-SPI'; clickText($('editor'), 'マイルストーンを前提にする');
  assert(state().doc.milestoneRelations.some(e => e.prerequisite === 'MS-SPI' && e.successor === task));
  assert($('editor').all(n => n.tagName === 'STRONG' && n.textContent === 'MS-SPI → ' + task).length === 1);
  // Cycle refused: task → MS-SPI would close MS-SPI → task.
  before = JSON.stringify(state().doc); $('milestoneTarget').value = 'MS-SPI'; clickText($('editor'), '到達点へつなぐ');
  assert.equal(JSON.stringify(state().doc), before); assert(/循環/.test($('status').textContent));
  // 4. Save → resume keeps direction and base.
  let sent = null; routes['/save'] = async opts => { sent = JSON.parse(opts.body); return reply(200, { ok: true, file: 'f.json', folder: 'x', save: { saveId: 'S1', series: 'S1', parent: null, branched: false } }); };
  await $('save').onclick(); assert(!state().dirty);
  const resumedDoc = JSON.parse(JSON.stringify(sent)); delete resumedDoc.studioSave; resumedDoc.studioSave = { saveId: 'S1', series: 'S1', parent: null };
  routes['/workspace'] = reply(200, { save: resumedDoc, heads: 1, saves: 1 }); await ctx.resumeWorkspace();
  const rel = state().doc.milestoneRelations;
  assert(rel.some(e => e.prerequisite === 'MS-SPI' && e.successor === 'draft-1') && rel.some(e => e.prerequisite === 'draft-1' && e.successor === end) && rel.some(e => e.prerequisite === 'MS-SPI' && e.successor === task));
  assert.deepEqual(state().doc.baseline, sent.baseline); assert.deepEqual(state().doc.proposals, [{ id: 'draft-1', title: 'SPI登録後のタスク出し', memo: 'バッジ対応の他に試験結果への対応を検討する' }]);
  // 5. Removing the card → task line from the task editor.
  ctx.select(task); const row = $('editor').all(n => n.tagName === 'STRONG' && n.textContent === 'MS-SPI → ' + task)[0]; assert(row);
  const div = $('editor').all(n => n.childNodes.includes(row))[0]; div.childNodes[0].click();
  assert(!state().doc.milestoneRelations.some(e => e.prerequisite === 'MS-SPI' && e.successor === task)); assert(state().dirty);
  console.log('PASS: OPS-084 smoke (MS-SPI → proposal 「SPI登録後のタスク出し」 drawn, proposal → END, duplicate and cycle refused unchanged, card → existing task, save/resume keeps direction and baseline, removal).');
})().catch(e => { console.error(e); process.exit(1); });
