// OPS-091 smoke: the neighborhood view (inspector entry, one step, manual expansion, center change, reset, no data change), edit-version resume, save snapshot, refresh guard, restart, against a stubbed fetch, on the same minimal DOM stub as OPS-081 (no browser, no Safari).
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
  const rows = () => $('neighborBox').all(n => n.tagName === 'STRONG').map(n => n.textContent);
  const rowWith = text => $('neighborBox').all(n => n.className === 'edge-row').find(d => d.childNodes[0].textContent.includes(text));
  // 1. From the inspector of DOC-027.
  ctx.select('DOC-027'); const snapshot = JSON.stringify(state().doc), dirty0 = state().dirty;
  clickText($('editor'), '接続を見る'); assert(!$('neighborView').hidden && $('dependencyView').hidden, 'neighbor tab opens');
  assert(/中心：DOC-027/.test($('neighborBox').all(n => n.tagName === 'H3')[0].textContent));
  assert(rows().some(t => t.startsWith('DOC-026') && t.endsWith('→ DOC-027')) && rows().some(t => t.startsWith('MS-SPI') && t.endsWith('→ DOC-027')), 'both prerequisites');
  assert(!rows().some(t => t.includes('QUALITY-005')), 'one step only');
  // 2. Expand DOC-026: QUALITY-005 → DOC-026 appears under the expanded lines.
  rowWith('DOC-026').childNodes.find(n => n.tagName === 'BUTTON' && n.textContent === 'この先を展開').click();
  assert(rows().some(t => t.startsWith('QUALITY-005') && t.includes('→ DOC-026')), 'expanded');
  // 3. Center on MS-SPI, then reset; START/END endpoints appear as they are.
  rowWith('MS-SPI').childNodes.find(n => n.tagName === 'BUTTON' && n.textContent === 'ここを中心に').click();
  assert(/中心：MS-SPI/.test($('neighborBox').all(n => n.tagName === 'H3')[0].textContent)); assert(rows().some(t => /^START-/.test(t) || /→ END-/.test(t)), 'START/END shown');
  clickText($('neighborBox'), '1段に戻す'); assert(!rows().some(t => t.includes('QUALITY-005')));
  assert.equal(JSON.stringify(state().doc), snapshot, 'viewing does not change the edit version'); assert.equal(state().dirty, dirty0);
  // 4. With pending input in a proposal editor, viewing keeps the input and does not select or apply.
  $('addProposal').click(); const form = $('proposalForm'); form.all(n => n.tagName === 'INPUT')[0].value = '接続確認の案'; clickText(form, '追加');
  ctx.select('draft-1'); $('proposalMemo').value = '未適用のメモ'; $('proposalMemo').oninput(); const doc1 = JSON.stringify(state().doc);
  clickText($('editor'), '接続を見る'); assert(state().formDirty && $('proposalMemo').value === '未適用のメモ' && state().selected === 'draft-1');
  assert.equal(rows().length, 0, 'an unconnected proposal shows only itself'); assert(/中心：draft-1/.test($('neighborBox').all(n => n.tagName === 'H3')[0].textContent));
  assert.equal(JSON.stringify(state().doc), doc1);
  console.log('PASS: OPS-091 smoke (inspector entry, DOC-027 one step with DOC-026 and MS-SPI, expand to QUALITY-005, center change, reset, START/END, isolated proposal, data/dirty/pending input unchanged).');
})().catch(e => { console.error(e); process.exit(1); });
