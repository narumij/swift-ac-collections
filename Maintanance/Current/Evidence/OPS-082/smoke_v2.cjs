// OPS-082 trial smoke (v2): edit-version resume, save snapshot, refresh guard, restart, against a stubbed fetch, on the same minimal DOM stub as OPS-081 (no browser, no Safari).
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
let routes = {};
const ctx = { fetch: async (url, opts) => { fetchCalls.push({ url, opts }); const r = routes[url]; return typeof r === 'function' ? r(opts) : r; }, document, window: { addEventListener() {}, location: { reload() {} } }, location: { protocol: 'http:' }, confirm: () => true, alert() {}, console, innerWidth: 1280, innerHeight: 800,
  setTimeout: () => 0, URL: Object.assign(function URL(u, b) { return new (require('url').URL)(u, b); }, { createObjectURL: blob => { downloaded = blob.text; return 'blob:x'; }, revokeObjectURL() {} }),
  Blob: function (parts) { this.text = parts.join(''); }, DOMParser: function () { this.parseFromString = () => ({ body: new Node('body') }); }, JSON, Math, Date, Set, Map, Array, Object, String, Number, Error, RegExp, Promise };
vm.createContext(ctx);
vm.runInContext(script.replace(/^'use strict';/, '') + '\n;globalThis.__get=()=>({doc,selected,dirty,formDirty});', ctx);
const $ = id => document.getElementById(id), state = () => ctx.__get();
const clickText = (root, text) => { const b = root.all(n => n.tagName === 'BUTTON' && n.textContent === text)[0]; assert(b, 'button not found: ' + text); b.click(); };



const reply = (status, body) => ({ ok: status >= 200 && status < 300, status, json: async () => body });
const seed = JSON.parse(embedded('seed'));
(async () => {
  // 1. Resume: /workspace returns a saved edit version built on an older base; it replaces the seed, keeps its base, and says the canonical is newer.
  const saved = JSON.parse(JSON.stringify(seed)); saved.source.sha256 = 'oldbase0000000000000000'; saved.proposals = [{ id: 'draft-1', title: '保存済みの案', memo: '' }];
  saved.studioSave = { saveId: 'S1', series: 'S1', parent: null };
  routes['/workspace'] = reply(200, { save: saved, heads: 1, saves: 1 });
  await ctx.resumed; // the page's startup resume
  // the page resumed before routes were set (fetch returned undefined); resume again explicitly with the route in place
  await ctx.resumeWorkspace();
  assert.equal(state().doc.source.sha256, 'oldbase0000000000000000', 'base kept'); assert.deepEqual(state().doc.proposals, saved.proposals); assert(!state().dirty);
  assert(/編集版 S1 を再開中/.test($('sourceInfo').textContent)); assert(/正本が更新されています/.test($('sourceInfo').textContent));
  // 2. Save sends parent S1; an edit made while the response is pending stays unsaved.
  ctx.select('draft-1'); $('proposalTitle').value = '保存する題'; $('proposalTitle').oninput(); clickText($('editor'), '変更を適用'); assert(state().dirty);
  let sentBody = null;
  routes['/save'] = async opts => { sentBody = JSON.parse(opts.body); ctx.select('draft-1'); $('proposalTitle').value = '応答待ち中の題'; $('proposalTitle').oninput(); clickText($('editor'), '変更を適用');
    return reply(200, { ok: true, file: 'registry-edited-S2.json', folder: 'Maintanance/RegistryApp/Inbox', save: { saveId: 'S2', series: 'S1', parent: 'S1', branched: false } }); };
  await $('save').onclick();
  assert.equal(sentBody.studioSave.parent, 'S1'); assert.equal(sentBody.proposals[0].title, '保存する題', 'the snapshot at the click is what was sent');
  assert(state().dirty, 'the later edit is still unsaved'); assert(/まだ未保存/.test($('status').textContent)); assert.equal(state().doc.proposals[0].title, '応答待ち中の題');
  // 3. The next save names S2 as parent and clears the mark.
  routes['/save'] = async opts => { sentBody = JSON.parse(opts.body); return reply(200, { ok: true, file: 'registry-edited-S3.json', folder: 'Maintanance/RegistryApp/Inbox', save: { saveId: 'S3', series: 'S1', parent: 'S2', branched: false } }); };
  await $('save').onclick(); assert.equal(sentBody.studioSave.parent, 'S2'); assert(!state().dirty);
  // 4. An old-tab save comes back branched: the message says so.
  ctx.select('draft-1'); $('proposalMemo').value = '別タブ'; $('proposalMemo').oninput(); clickText($('editor'), '変更を適用');
  routes['/save'] = reply(200, { ok: true, file: 'registry-edited-S4.json', folder: 'Maintanance/RegistryApp/Inbox', save: { saveId: 'S4', series: 'S4', parent: 'S3', branched: true } });
  await $('save').onclick(); assert(/別の系列として保存/.test($('status').textContent)); assert(/別の系列の保存もあります/.test($('sourceInfo').textContent));
  // 5. Failure keeps edits and the mark.
  ctx.select('draft-1'); $('proposalMemo').value = '失敗時'; $('proposalMemo').oninput(); clickText($('editor'), '変更を適用');
  routes['/save'] = reply(500, { error: '保存できませんでした：試験' }); await $('save').onclick(); assert(state().dirty); assert.equal(state().doc.proposals[0].memo, '失敗時');
  // 6. Refresh while unsaved does not call /sync and does not discard.
  const before = fetchCalls.length; await $('refresh').onclick(); assert.equal(fetchCalls.length, before, 'no /sync while unsaved'); assert(/先に「編集結果を保存」/.test($('status').textContent)); assert(state().dirty);
  // 7. Restart from canonical is refused while unsaved, allowed after saving; it starts from the seed with no workspace.
  $('restart').onclick(); assert(/未保存/.test($('status').textContent)); assert.equal(state().doc.source.sha256, 'oldbase0000000000000000');
  routes['/save'] = reply(200, { ok: true, file: 'registry-edited-S5.json', folder: 'x', save: { saveId: 'S5', series: 'S4', parent: 'S4', branched: false } }); await $('save').onclick(); assert(!state().dirty);
  $('restart').onclick(); assert.equal(state().doc.source.sha256, seed.source.sha256); assert(!('proposals' in state().doc)); assert(!/編集版/.test($('sourceInfo').textContent));
  console.log('PASS: OPS-082 trial smoke (resume keeps base and shows newer canonical, snapshot save with later edit unsaved, parent chain, branched message, failure keeps edits, refresh does not discard, restart from canonical).');
})().catch(e => { console.error(e); process.exit(1); });
