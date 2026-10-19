// OPS-086 smoke: milestone plan editing in the edit version (cards tab tools, plan editor, save/resume, waiting edits), edit-version resume, save snapshot, refresh guard, restart, against a stubbed fetch, on the same minimal DOM stub as OPS-081 (no browser, no Safari).
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
const seed = JSON.parse(embedded('seed'));
(async () => {
  const chainOf = v => { const d = state().doc; return ['START-' + v, ...ctx.planCards(d, v).map(m => m.id), 'END-' + v]; };
  const v6 = seed.milestones.find(m => m.id === 'MS-SPI').gate.split('/')[2], v7 = seed.milestones.find(m => m.id === 'MS-VALIDATION').gate.split('/')[2];
  // 1. Cards tab: add an intermediate card to v6.
  $('cardsTab').click(); $('planAddVersionOf').value = v6; $('planAddName').value = '計画で足すカード'; clickText($('planTools'), '中間カードを追加');
  assert.equal(state().selected, 'draft-ms-1'); assert(state().dirty); assert.deepEqual(chainOf(v6), ['START-' + v6, 'MS-SPI', 'draft-ms-1', 'END-' + v6]);
  const shell = $('cardList').all(n => n.tagName === 'STRONG' && n.textContent === 'draft-ms-1 · 計画案')[0]; assert(shell, 'listed as a plan card');
  // 2. Plan editor: move the new card before MS-SPI; a refused step changes nothing.
  clickText($('editor'), '前へ'); assert.deepEqual(chainOf(v6), ['START-' + v6, 'draft-ms-1', 'MS-SPI', 'END-' + v6]);
  let before = JSON.stringify(state().doc); clickText($('editor'), '前へ'); assert.equal(JSON.stringify(state().doc), before); assert(/動かせません/.test($('status').textContent));
  // 3. Rename MS-SPI with a condition proposal, then move it to v7. Task lines into MS-SPI stay.
  const taskLinesBefore = state().doc.milestoneRelations.filter(r => r.successor === 'MS-SPI' && !(r.source && r.source.path === 'Maintanance/Milestones/README.md')).map(r => r.prerequisite);
  ctx.select('MS-SPI'); $('planItem').value = 'SPI登録（計画）'; $('planItem').oninput(); $('planCondition').value = 'バッジと試験結果の対応'; $('planCondition').oninput();
  $('dependencyTab').click(); assert(state().formDirty && $('planItem').value === 'SPI登録（計画）', 'tab switch keeps pending input'); $('cardsTab').click();
  clickText($('editor'), '名前・条件を適用'); assert.equal(state().doc.milestones.find(m => m.id === 'MS-SPI').item, 'SPI登録（計画）');
  ctx.select('MS-SPI'); $('planVersion').value = v7; clickText($('editor'), 'この版へ移動');
  assert.deepEqual(chainOf(v7), ['START-' + v7, 'MS-VALIDATION', 'MS-SPI', 'END-' + v7]); assert.deepEqual(chainOf(v6), ['START-' + v6, 'draft-ms-1', 'END-' + v6]);
  assert.deepEqual(state().doc.milestoneRelations.filter(r => r.successor === 'MS-SPI' && !(r.source && r.source.path === 'Maintanance/Milestones/README.md')).map(r => r.prerequisite), taskLinesBefore);
  // 4. Add an unconnected version.
  $('planNewVersion').value = '0.6.5'; clickText($('planTools'), '版を追加'); assert.deepEqual(chainOf('0.6.5'), ['START-0.6.5', 'END-0.6.5']);
  // 5. Save while another plan edit happens during the response; the later edit stays unsaved.
  let sent = null;
  routes['/save'] = async opts => { sent = JSON.parse(opts.body); ctx.select('draft-ms-1'); $('planItem').value = '保存待ち中の改名'; $('planItem').oninput(); clickText($('editor'), '名前・条件を適用');
    return reply(200, { ok: true, file: 'f.json', folder: 'x', save: { saveId: 'S1', series: 'S1', parent: null, branched: false } }); };
  await $('save').onclick(); assert(state().dirty, 'edit during save stays unsaved');
  const plan = sent.changes.find(c => c.field === 'milestones').changes.map(c => c.change + ':' + c.id);
  for (const k of ['added:draft-ms-1', 'moved:MS-SPI', 'renamed:MS-SPI', 'condition:MS-SPI', 'added:START-0.6.5']) assert(plan.includes(k), 'saved change ' + k);
  assert.deepEqual(sent.baseline.milestones, seed.milestones, 'baseline milestones = canonical at the start');
  // 6. Refresh with unsaved edits is refused; after saving, an edit during /sync prevents the reload.
  const calls = fetchCalls.length; await $('refresh').onclick(); assert.equal(fetchCalls.length, calls);
  routes['/save'] = reply(200, { ok: true, file: 'g.json', folder: 'x', save: { saveId: 'S2', series: 'S1', parent: 'S1', branched: false } }); await $('save').onclick(); assert(!state().dirty);
  routes['/sync'] = async () => { ctx.select('draft-ms-1'); $('planItem').value = '更新待ち中の改名'; $('planItem').oninput(); clickText($('editor'), '名前・条件を適用'); return reply(200, { ok: true }); };
  await $('refresh').onclick(); assert.equal(reloads, 0); assert(state().dirty);
  // 7. Resume the saved version: plan and baseline come back.
  const resumed = JSON.parse(JSON.stringify(sent)); resumed.studioSave = { saveId: 'S1', series: 'S1', parent: null }; routes['/workspace'] = reply(200, { save: resumed, heads: 1, saves: 1 });
  routes['/save'] = reply(200, { ok: true, file: 'h.json', folder: 'x', save: { saveId: 'S3', series: 'S1', parent: 'S2', branched: false } }); await $('save').onclick();
  await ctx.resumeWorkspace(); assert.deepEqual(chainOf(v7), ['START-' + v7, 'MS-VALIDATION', 'MS-SPI', 'END-' + v7]); assert.equal(state().doc.milestones.find(m => m.id === 'MS-SPI').planCondition, 'バッジと試験結果の対応');
  assert(ctx.milestonePlanChanges(state().doc).length >= 5);
  console.log('PASS: OPS-086 smoke (add card from the card list, reorder with refusal unchanged, rename/condition, move between versions keeping task lines, add version, save with a later edit unsaved, refresh guards, resume restores the plan and baseline).');
})().catch(e => { console.error(e); process.exit(1); });
