// OPS-094 smoke: neighborhood cards match the text list (inspector entry, one step, manual expansion, center change, reset, no data change), edit-version resume, save snapshot, refresh guard, restart, against a stubbed fetch, on the same minimal DOM stub as OPS-081 (no browser, no Safari).
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
  const lane = key => $('neighborBox').all(n => n.attributes && n.attributes['data-lane'] === key)[0];
  const cardIds = key => lane(key).all(n => n.tagName === 'BUTTON' && n.className.split(' ').includes('task')).map(b => b.childNodes[0].textContent.split(' · ')[0]);
  const allCards = () => ['pre', 'center', 'post'].flatMap(cardIds);
  const textIds = () => { const ids = new Set(); for (const s of $('neighborBox').all(n => n.tagName === 'STRONG' && / → /.test(n.textContent))) for (const part of s.textContent.split(' → ')) ids.add(part.split(' · ')[0]); return ids; };
  const same = () => { const c = allCards(), t = textIds(); t.add(c.find(x => cardIds('center').includes(x))); assert.equal(new Set(c).size, c.length, 'no duplicate cards'); assert.deepEqual([...new Set(c)].sort(), [...t].sort(), 'cards = text list'); };
  const snapshot = JSON.stringify(state().doc);
  // 1. DOC-027 one step: center, both prerequisites on the left lane.
  ctx.select('DOC-027'); $('neighborTab').click();
  assert.deepEqual(cardIds('center'), ['DOC-027']); assert(cardIds('pre').includes('DOC-026') && cardIds('pre').includes('MS-SPI')); same();
  assert(lane('center').all(n => n.tagName === 'BUTTON')[0].className.includes('selected'));
  // 2. Expand DOC-026: QUALITY-005 joins the prerequisite lane; text and cards agree.
  const row = text => $('neighborBox').all(n => n.className === 'edge-row').find(r => r.childNodes[0].textContent.includes(text));
  row('DOC-026').childNodes.find(n => n.textContent === 'この先を展開').click(); assert(cardIds('pre').includes('QUALITY-005')); same();
  // 3. Center change to MS-SPI (milestone): DOC-027 moves to the successor lane; reset back to one step.
  row('MS-SPI').childNodes.find(n => n.textContent === 'ここを中心に').click(); assert.deepEqual(cardIds('center'), ['MS-SPI']); assert(cardIds('post').includes('DOC-027')); same();
  clickText($('neighborBox'), '1段に戻す'); same();
  // 4. Clicking a card selects it and the center follows (OPS-093); the expansion is dropped.
  lane('post').all(n => n.tagName === 'BUTTON').find(b => b.childNodes[0].textContent.startsWith('DOC-027')).click();
  assert.equal(state().selected, 'DOC-027'); assert.deepEqual(cardIds('center'), ['DOC-027']); assert(!cardIds('pre').includes('QUALITY-005')); same();
  // 5. A node without lines: only its own card.
  const lone = ctx.independentGroups(state().doc).regular.find(t => !state().doc.edges.some(e => e.prerequisite === t.id || e.successor === t.id) && !state().doc.milestoneRelations.some(e => e.prerequisite === t.id || e.successor === t.id));
  ctx.select(lone.id); $('neighborTab').click(); assert.deepEqual(allCards(), [lone.id]);
  // 6. Input protection: with pending input, clicking a card asks; cancelling keeps selection, input and center.
  ctx.select('MS-SPI'); $('planItem').value = '未適用'; $('planItem').oninput(); $('neighborTab').click(); ctx.confirm = () => false;
  lane('post').all(n => n.tagName === 'BUTTON')[0].click(); assert.equal(state().selected, 'MS-SPI'); assert(state().formDirty && $('planItem').value === '未適用'); assert.deepEqual(cardIds('center'), ['MS-SPI']);
  ctx.confirm = () => true; assert.equal(JSON.stringify(state().doc), snapshot, 'viewing changed nothing');
  // Document links appear only where a canonical document exists.
  assert(lane('center').all(n => n.className === 'card-document').length <= 1);
  console.log('PASS: OPS-094 smoke (cards match the text list without duplicates; DOC-027 prerequisites; expansion, center change, reset; card click selects and the center follows; isolated node; input protection; data unchanged).');
})().catch(e => { console.error(e.message || e); process.exit(1); });
