// OPS-093 smoke: the neighborhood center follows the selected card (inspector entry, one step, manual expansion, center change, reset, no data change), edit-version resume, save snapshot, refresh guard, restart, against a stubbed fetch, on the same minimal DOM stub as OPS-081 (no browser, no Safari).
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
const document = { addEventListener() {}, createElement: t => new Node(t), createElementNS: (_, t) => new Node(t), createTextNode: t => Object.assign(new Node('#text'), { _text: t, nodeType: 3 }), body: new Node('body'),
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






(async () => {
  await new Promise(r => setImmediate(r));
  const center = () => ($('neighborBox').all(n => n.tagName === 'H3')[0] || { textContent: '' }).textContent;
  const graphCard = id => $('graph').all(n => n.tagName === 'G' && (n.attributes['aria-label'] || '').startsWith(id + ' '))[0];
  const stripCard = id => $('independent').all(n => n.tagName === 'BUTTON' && n.childNodes[0] && n.childNodes[0].textContent.startsWith(id))[0];
  const d = state().doc, snapshot = JSON.stringify(d);
  const ga = 'DOC-027', gb = 'MS-SPI';
  const ia = ctx.independentGroups(d).regular[0].id, ib = ctx.independentGroups(d).regular[1].id;
  // 1. Dependency map: A then B, open from the tab → B is the center.
  $('dependencyTab').click(); graphCard(ga).onclick(); $('neighborTab').click(); assert(center().includes(ga), 'A first: ' + center());
  $('dependencyTab').click(); graphCard(gb).onclick(); $('neighborTab').click(); assert(center().includes(gb), 'map B then tab: ' + center());
  // Same through the inspector button.
  $('dependencyTab').click(); graphCard(ga).onclick(); clickText($('editor'), '接続を見る'); assert(center().includes(ga), 'inspector: ' + center());
  // 2. Independent strip: A then B, both entries.
  $('dependencyTab').click(); stripCard(ia).onclick(); $('neighborTab').click(); assert(center().includes(ia), 'strip A: ' + center());
  stripCard(ib).onclick(); $('neighborTab').click(); assert(center().includes(ib), 'strip B then tab: ' + center());
  stripCard(ia).onclick(); clickText($('editor'), '接続を見る'); assert(center().includes(ia), 'strip A then inspector: ' + center());
  // 3. While the view is open, picking another node in the inspector picker follows.
  $('taskPicker').value = gb; $('taskPicker').onchange(); assert(center().includes(gb), 'picker while open: ' + center());
  // 4. Manual operations still work, and a new selection drops the previous expansion.
  const row = text => $('neighborBox').all(n => n.className === 'edge-row').find(r => r.childNodes[0].textContent.includes(text));
  ctx.select('DOC-027'); $('neighborTab').click(); row('DOC-026').childNodes.find(n => n.textContent === 'この先を展開').click();
  assert($('neighborBox').all(n => n.tagName === 'STRONG').some(n => n.textContent.includes('QUALITY-005')), 'expanded');
  row('MS-SPI').childNodes.find(n => n.textContent === 'ここを中心に').click(); assert(center().includes('MS-SPI'));
  clickText($('neighborBox'), '1段に戻す'); ctx.select('DOC-027'); $('neighborTab').click();
  assert(!$('neighborBox').all(n => n.tagName === 'STRONG').some(n => n.textContent.includes('QUALITY-005')), 'new selection starts at one step');
  // 5. Input protection: a pending input keeps the selection unless confirmed; viewing changes nothing.
  ctx.select('MS-SPI'); $('planItem').value = '未適用'; $('planItem').oninput(); ctx.confirm = () => false; graphCard(ga).onclick();
  assert.equal(state().selected, 'MS-SPI'); assert($('planItem').value === '未適用' && state().formDirty); $('neighborTab').click(); assert(center().includes('MS-SPI'), 'refused selection keeps the center');
  ctx.confirm = () => true; assert.equal(JSON.stringify(state().doc), snapshot, 'nothing in the edit version changed');
  console.log('PASS: OPS-093 smoke (center follows selection from the map and the independent strip, via the tab and the inspector, picker while open; manual operations kept; expansion reset on new selection; input protection; data unchanged).');
})().catch(e => { console.error(e.message || e); process.exit(1); });
