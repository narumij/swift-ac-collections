// OPS-082 trial smoke (v3, refresh while waiting): edit-version resume, save snapshot, refresh guard, restart, against a stubbed fetch, on the same minimal DOM stub as OPS-081 (no browser, no Safari).
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
  // A saved proposal so there is something to edit while /sync is pending.
  $('addProposal').click(); const form = $('proposalForm'); form.all(n => n.tagName === 'INPUT')[0].value = '更新試験の案'; clickText(form, '追加');
  routes['/save'] = reply(200, { ok: true, file: 'f.json', folder: 'x', save: { saveId: 'S1', series: 'S1', parent: null, branched: false } });
  await $('save').onclick(); assert(!state().dirty);
  // 1. Applied edit while /sync is pending: regeneration succeeds, but the page is not reloaded and the edit stays unsaved.
  routes['/sync'] = async () => { ctx.select('draft-1'); $('proposalTitle').value = '更新待ち中に適用'; $('proposalTitle').oninput(); clickText($('editor'), '変更を適用'); return reply(200, { ok: true, output: '' }); };
  await $('refresh').onclick();
  assert.equal(reloads, 0, 'no reload after an applied edit during refresh'); assert(state().dirty); assert.equal(state().doc.proposals[0].title, '更新待ち中に適用'); assert(/読み直していません/.test($('status').textContent));
  routes['/save'] = reply(200, { ok: true, file: 'g.json', folder: 'x', save: { saveId: 'S2', series: 'S1', parent: 'S1', branched: false } }); await $('save').onclick(); assert(!state().dirty);
  // 2. Unapplied input while /sync is pending: not reloaded, input kept.
  routes['/sync'] = async () => { ctx.select('draft-1'); $('proposalMemo').value = '未適用の入力'; $('proposalMemo').oninput(); return reply(200, { ok: true, output: '' }); };
  await $('refresh').onclick();
  assert.equal(reloads, 0, 'no reload with pending input'); assert(state().formDirty); assert.equal($('proposalMemo').value, '未適用の入力');
  clickText($('editor'), '変更を適用'); await $('save').onclick(); assert(!state().dirty && !state().formDirty);
  // 3. Nothing changed while waiting: reload happens as before.
  routes['/sync'] = reply(200, { ok: true, output: '' }); await $('refresh').onclick(); assert.equal(reloads, 1, 'reload when nothing changed');
  // 4. Failed regeneration: no reload, message shown.
  routes['/sync'] = reply(500, { error: '同期失敗' }); await $('refresh').onclick(); assert.equal(reloads, 1); assert(/更新できませんでした/.test($('status').textContent));
  console.log('PASS: OPS-082 refresh smoke (applied edit and pending input during /sync keep the page, unchanged page reloads, failure does not reload).');
})().catch(e => { console.error(e); process.exit(1); });
