// OPS-086 fix smoke: unapplied input in the card-list add forms (card name, target version, new version name), edit-version resume, save snapshot, refresh guard, restart, against a stubbed fetch, on the same minimal DOM stub as OPS-081 (no browser, no Safari).
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
let routes = {}, reloads = 0, beforeUnload = null;
const ctx = { fetch: async (url, opts) => { fetchCalls.push({ url, opts }); const r = routes[url]; return typeof r === 'function' ? r(opts) : r; }, document, window: { addEventListener(type, f) { if (type === 'beforeunload') beforeUnload = f; }, location: { reload() { reloads++; } } }, location: { protocol: 'http:' }, confirm: () => true, alert() {}, console, innerWidth: 1280, innerHeight: 800,
  setTimeout: () => 0, URL: Object.assign(function URL(u, b) { return new (require('url').URL)(u, b); }, { createObjectURL: blob => { downloaded = blob.text; return 'blob:x'; }, revokeObjectURL() {} }),
  Blob: function (parts) { this.text = parts.join(''); }, DOMParser: function () { this.parseFromString = () => ({ body: new Node('body') }); }, JSON, Math, Date, Set, Map, Array, Object, String, Number, Error, RegExp, Promise };
vm.createContext(ctx);
vm.runInContext(script.replace(/^'use strict';/, '') + '\n;globalThis.__get=()=>({doc,selected,dirty,formDirty});', ctx);
const $ = id => document.getElementById(id), state = () => ctx.__get();
const clickText = (root, text) => { const b = root.all(n => n.tagName === 'BUTTON' && n.textContent === text)[0]; assert(b, 'button not found: ' + text); b.click(); };





const reply = (status, body) => ({ ok: status >= 200 && status < 300, status, json: async () => body });
(async () => {
  await new Promise(r => setImmediate(r)); // let the page's startup resume (no /workspace route here) settle first
  const seed = JSON.parse(embedded('seed')), versions = [...new Set(seed.milestones.filter(m => m.virtual && m.id.startsWith('START-')).map(m => m.id.slice(6)))];
  const other = versions.find(v => v !== seed.milestoneHead);
  // 1. Reproduction: typed but not added, then a card selection / tab switch / re-render must not erase it.
  $('cardsTab').click(); $('planAddVersionOf').value = other; $('planAddVersionOf').onchange && $('planAddVersionOf').onchange();
  $('planAddName').value = 'まだ追加していない入力'; $('planAddName').oninput && $('planAddName').oninput();
  $('planNewVersion').value = '9.9'; $('planNewVersion').oninput && $('planNewVersion').oninput();
  ctx.select('MS-SPI');
  assert.equal($('planAddName').value, 'まだ追加していない入力', 'card name kept after selecting a card');
  assert.equal($('planAddVersionOf').value, other, 'target version kept'); assert.equal($('planNewVersion').value, '9.9', 'new version name kept');
  $('dependencyTab').click(); $('cardsTab').click(); ctx.render();
  assert.equal($('planAddName').value, 'まだ追加していない入力'); assert.equal($('planNewVersion').value, '9.9');
  // 2. Pending add-form input blocks refresh and leaving, and is not reported as saved.
  const calls = fetchCalls.length; await $('refresh').onclick(); assert.equal(fetchCalls.length, calls, 'no /sync with pending add-form input'); assert(/追加欄/.test($('status').textContent));
  const ev = { preventDefault() { this.prevented = true; } }; beforeUnload(ev); assert(ev.prevented, 'leaving is guarded');
  // 3. A failed add keeps the input; a successful add clears only what it used.
  $('planNewVersion').value = state().doc.milestones.find(m => m.virtual).gate.split('/')[2]; $('planNewVersion').oninput(); clickText($('planTools'), '版を追加');
  assert(/すでに/.test($('status').textContent)); assert.equal($('planAddName').value, 'まだ追加していない入力', 'other field untouched on failure');
  $('planNewVersion').value = '9.9'; $('planNewVersion').oninput();
  clickText($('planTools'), '中間カードを追加'); assert.equal(state().doc.milestones.find(m => m.id === 'draft-ms-1').gate.split('/')[2], other);
  assert.equal($('planAddName').value, '', 'card name cleared after its add'); assert.equal($('planNewVersion').value, '9.9', 'version name kept'); assert.equal($('planAddVersionOf').value, other);
  // Inspector pending input is not cleared by the add forms.
  ctx.select('MS-SPI'); $('planItem').value = 'インスペクタの未適用'; $('planItem').oninput(); $('cardsTab').click();
  $('planAddName').value = 'もう一枚'; $('planAddName').oninput(); clickText($('planTools'), '中間カードを追加');
  assert(/変更を適用/.test($('status').textContent)); assert.equal($('planItem').value, 'インスペクタの未適用'); assert.equal($('planAddName').value, 'もう一枚', 'refused add keeps its input');
  clickText($('editor'), '名前・条件を適用');
  // 4. Save while add-form input is pending: the message says it was not saved; input typed during the response is kept.
  routes['/save'] = async () => { $('planAddName').value = '保存待ち中に入力'; $('planAddName').oninput(); return reply(200, { ok: true, file: 'f.json', folder: 'x', save: { saveId: 'S1', series: 'S1', parent: null, branched: false } }); };
  await $('save').onclick(); assert(/追加欄/.test($('status').textContent), 'not reported as saved'); assert.equal($('planAddName').value, '保存待ち中に入力');
  // 5. Input typed while /sync is pending prevents the reload.
  $('planAddName').value = ''; $('planAddName').oninput(); $('planNewVersion').value = ''; $('planNewVersion').oninput(); assert(!state().dirty);
  routes['/sync'] = async () => { $('planNewVersion').value = '更新待ち中の版'; $('planNewVersion').oninput(); return reply(200, { ok: true }); };
  await $('refresh').onclick(); assert.equal(reloads, 0, 'no reload after add-form input during /sync'); assert.equal($('planNewVersion').value, '更新待ち中の版');
  console.log('PASS: OPS-086 add-form smoke (card name / target version / version name survive selection, tab switch and re-render; refresh and leaving guarded; failed add keeps input, successful add clears only its field; inspector input untouched; save/refresh waits keep input).');
})().catch(e => { console.error(e); process.exit(1); });
