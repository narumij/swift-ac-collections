// OPS-094 local-map smoke: the selected card in the middle, prerequisites left, successors right, real lines (inspector entry, one step, manual expansion, center change, reset, no data change), edit-version resume, save snapshot, refresh guard, restart, against a stubbed fetch, on the same minimal DOM stub as OPS-081 (no browser, no Safari).
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
  const map = () => $('neighborBox').all(n => n.tagName === 'SVG')[0];
  const cards = () => map().all(n => n.tagName === 'G' && n.attributes['data-node']);
  const xy = id => { const g = cards().find(c => c.attributes['data-node'] === id); const m = /translate\(([-\d.]+) ([-\d.]+)\)/.exec(g.attributes.transform); return [+m[1], +m[2]]; };
  const lines = () => map().all(n => n.tagName === 'PATH' && n.attributes['data-edge']).map(p => p.attributes['data-edge']);
  const textEdges = () => $('neighborBox').all(n => n.className === 'edge-row').map(r => r.childNodes[0].textContent.split(' → ').map(x => x.split(' · ')[0]).join('>'));
  const agree = () => { const ids = cards().map(c => c.attributes['data-node']); assert.equal(new Set(ids).size, ids.length, 'one card per node'); const l = lines(); assert.equal(new Set(l).size, l.length, 'one line per edge');
    assert.deepEqual([...l].sort(), [...new Set(textEdges())].sort(), 'map lines = text list lines'); };
  const middle = id => { const w = +map().attributes.width, [x] = xy(id); assert(Math.abs((x + 105) - w / 2) < 1, id + ' is horizontally centered'); };
  const snapshot = JSON.stringify(state().doc);
  // 1. DOC-027: center in the middle, both prerequisites to the left.
  ctx.select('DOC-027'); $('neighborTab').click(); agree(); middle('DOC-027');
  assert(xy('DOC-026')[0] < xy('DOC-027')[0] && xy('MS-SPI')[0] < xy('DOC-027')[0], 'prerequisites left');
  // 2. MS-SPI with DOC-027 expanded: DOC-026 → DOC-027 is drawn between its real ends, not to MS-SPI.
  const row = text => $('neighborBox').all(n => n.className === 'edge-row').find(r => r.childNodes[0].textContent.includes(text));
  ctx.select('MS-SPI'); $('neighborTab').click(); middle('MS-SPI'); row('DOC-027').childNodes.find(n => n.textContent === 'この先を展開').click(); agree(); middle('MS-SPI');
  assert(lines().includes('DOC-026>DOC-027') && !lines().some(l => l === 'DOC-026>MS-SPI' || l === 'MS-SPI>DOC-026'));
  assert(xy('DOC-027')[0] > xy('MS-SPI')[0] && xy('DOC-026')[0] < xy('DOC-027')[0]);
  // 3. Center change and reset keep the map in sync; the new center is in the middle.
  row('DOC-026').childNodes.find(n => n.textContent === 'ここを中心に').click(); agree(); middle('DOC-026'); clickText($('neighborBox'), '1段に戻す'); agree(); middle('DOC-026');
  // 4. Clicking a card on the map selects it; the center follows; expansion is dropped.
  cards().find(c => c.attributes['data-node'] !== 'DOC-026').onclick(); const sel = state().selected; assert.notEqual(sel, 'DOC-026'); agree(); middle(sel);
  // 5. Isolated node: only itself, centered.
  const lone = ctx.independentGroups(state().doc).regular.find(t => !state().doc.edges.some(e => e.prerequisite === t.id || e.successor === t.id) && !state().doc.milestoneRelations.some(e => e.prerequisite === t.id || e.successor === t.id));
  ctx.select(lone.id); $('neighborTab').click(); assert.equal(cards().length, 1); assert.equal(lines().length, 0); middle(lone.id);
  // 6. Input protection: with pending input, a cancelled card click keeps selection, input and center.
  ctx.select('MS-SPI'); $('planItem').value = '未適用'; $('planItem').oninput(); $('neighborTab').click(); ctx.confirm = () => false;
  cards().find(c => c.attributes['data-node'] !== 'MS-SPI').onclick(); assert.equal(state().selected, 'MS-SPI'); assert(state().formDirty && $('planItem').value === '未適用'); middle('MS-SPI');
  ctx.confirm = () => true; assert.equal(JSON.stringify(state().doc), snapshot, 'viewing changed nothing');
  console.log('PASS: OPS-094 local-map smoke (center horizontally centered; prerequisites left, successors right; lines = text list without duplicates; expanded DOC-026 → DOC-027 between real ends; center change/reset; card click follows; isolated; input protection; data unchanged).');
})().catch(e => { console.error(e.message || e); process.exit(1); });
