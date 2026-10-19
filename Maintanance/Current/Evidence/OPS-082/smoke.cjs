// OPS-082 smoke test: the Studio save button against a stubbed fetch, on the same minimal DOM stub as OPS-081 (no browser, no Safari).
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
const ctx = { fetch: async (url, opts) => { fetchCalls.push({ url, opts }); return fetchReply; }, document, window: { addEventListener() {}, location: { reload() {} } }, location: { protocol: 'http:' }, confirm: () => true, alert() {}, console, innerWidth: 1280, innerHeight: 800,
  setTimeout: () => 0, URL: Object.assign(function URL(u, b) { return new (require('url').URL)(u, b); }, { createObjectURL: blob => { downloaded = blob.text; return 'blob:x'; }, revokeObjectURL() {} }),
  Blob: function (parts) { this.text = parts.join(''); }, DOMParser: function () { this.parseFromString = () => ({ body: new Node('body') }); }, JSON, Math, Date, Set, Map, Array, Object, String, Number, Error, RegExp, Promise };
vm.createContext(ctx);
vm.runInContext(script.replace(/^'use strict';/, '') + '\n;globalThis.__get=()=>({doc,selected,dirty,formDirty});', ctx);
const $ = id => document.getElementById(id), state = () => ctx.__get();
const clickText = (root, text) => { const b = root.all(n => n.tagName === 'BUTTON' && n.textContent === text)[0]; assert(b, 'button not found: ' + text); b.click(); };


const reply = (status, body) => ({ ok: status >= 200 && status < 300, status, json: async () => body });
(async () => {
  // An edit to save: one proposal.
  $('addProposal').click(); const form = $('proposalForm'); form.all(n => n.tagName === 'INPUT')[0].value = '保存試験の案'; clickText(form, '追加');
  assert(state().dirty);
  // 1. Server failure: edits and the unsaved mark stay, no download happens.
  fetchReply = reply(500, { error: '保存できませんでした：試験' }); downloaded = null;
  await $('save').onclick();
  assert.equal(fetchCalls.length, 1); assert.equal(fetchCalls[0].url, '/save'); assert.equal(fetchCalls[0].opts.headers['X-Registry-Studio'], 'save');
  const sent = JSON.parse(fetchCalls[0].opts.body); assert.deepEqual(sent.proposals, state().doc.proposals); assert(sent.baseline && !sent.baseline.proposals); assert(sent.changes.some(c => c.field === 'proposals'));
  assert(state().dirty, 'still unsaved after a failed save'); assert(/保存できませんでした/.test($('status').textContent)); assert.equal(downloaded, null, 'no fallback download');
  // 2. Network error: same.
  ctx.fetch = async () => { throw new Error('接続できません'); }; await $('save').onclick(); assert(state().dirty); assert(/接続できません/.test($('status').textContent));
  // 3. Success: the unsaved mark clears and the saved name is shown.
  ctx.fetch = async (url, opts) => { fetchCalls.push({ url, opts }); return reply(200, { ok: true, file: 'registry-edited-x.json', folder: 'Maintanance/RegistryApp/Inbox' }); };
  await $('save').onclick(); assert(!state().dirty); assert(/registry-edited-x\.json/.test($('status').textContent)); assert.deepEqual(state().doc.proposals.map(p => p.id), ['draft-1'], 'edits kept after save');
  // 4. Pending input is still protected.
  state(); ctx.select('draft-1'); $('proposalTitle').value = '未適用'; $('proposalTitle').oninput(); const calls = fetchCalls.length; await $('save').onclick();
  assert.equal(fetchCalls.length, calls, 'no request while input is pending'); assert(/変更を適用/.test($('status').textContent));
  // 5. file:// keeps the download path.
  clickText($('editor'), '変更を適用'); ctx.location.protocol = 'file:'; downloaded = null; await $('save').onclick(); assert(downloaded, 'download under file://'); assert.equal(fetchCalls.length, calls);
  console.log('PASS: OPS-082 save smoke (server failure / network error keep edits and unsaved mark without download, success clears it, pending input blocked, file:// downloads).');
})().catch(e => { console.error(e); process.exit(1); });
