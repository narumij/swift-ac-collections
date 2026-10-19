// OPS-085 smoke: the card list tab (find cards, open canonical documents, keep edits), edit-version resume, save snapshot, refresh guard, restart, against a stubbed fetch, on the same minimal DOM stub as OPS-081 (no browser, no Safari).
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





(async () => {
  const d = state().doc, bundle = JSON.parse(embedded('documents'));
  const groupOf = title => { const hs = $('cardList').all(n => n.tagName === 'H3'); const h = hs.find(n => n.textContent.startsWith(title)); const i = $('cardList').childNodes.indexOf(h); return $('cardList').childNodes[i + 1]; };
  const cardIn = (title, id) => groupOf(title).childNodes.find(shell => shell.childNodes[0].childNodes[0].textContent.startsWith(id + ' ') || shell.childNodes[0].childNodes[0].textContent === id);
  // An unapplied input before switching tabs.
  $('addProposal').click(); const form = $('proposalForm'); form.all(n => n.tagName === 'INPUT')[0].value = '一覧試験の案'; clickText(form, '追加');
  $('proposalMemo').value = '未適用のメモ'; $('proposalMemo').oninput(); assert(state().formDirty && state().dirty);
  $('cardsTab').click(); assert(!$('cardsView').hidden && $('dependencyView').hidden);
  assert(state().formDirty && state().dirty && $('proposalMemo').value === '未適用のメモ', 'switching tabs keeps edits and pending input');
  // Isolated, permanent and finished tasks and an intermediate card are all in the list.
  const isolated = ctx.independentGroups(d).regular.find(t => !t.proposal).id, permanent = d.tasks.find(t => t.permanent).id, finished = d.tasks.find(t => !t.permanent && t.state === 'DONE').id;
  const found = [['タスク（未完了）', isolated], ['恒久タスク', permanent], ['完了・除外', finished], ['マイルストーン', 'MS-SPI'], ['追加案', 'draft-1']].map(([g, id]) => [id, cardIn(g, id)]);
  for (const [id, shell] of found) assert(shell, 'listed: ' + id);
  const proposalShell = found.find(([id]) => id === 'draft-1')[1]; assert(!proposalShell.childNodes.some(n => n.className === 'card-document'), 'no document link on a proposal');
  // Open the canonical document directly from the list (single → document; several → chooser of bundled ones).
  let opened = 0;
  for (const [id, shell] of found.filter(([id]) => id !== 'draft-1')) {
    const link = shell.childNodes.find(n => n.className === 'card-document'); const t = [...d.tasks, ...d.milestones].find(x => x.id === id);
    const paths = ctx.cardDocumentPaths(t, bundle); if (!paths.length) { assert(!link, 'no link without a bundled document: ' + id); continue; }
    $('documentDialog').close(); link.onclick({ preventDefault() {}, stopPropagation() {} }); assert($('documentDialog').open, 'dialog opens for ' + id);
    if (paths.length === 1) assert.equal($('documentTitle').textContent, paths[0]); else assert.equal($('documentTitle').textContent, id + ' の正本');
    opened++;
  }
  assert(opened >= 3, 'documents opened from the list');
  // A task with several documents shows a chooser listing only bundled paths.
  const multi = d.tasks.find(t => ctx.cardDocumentPaths(t, bundle).length > 1); const ms = cardIn(multi.permanent ? '恒久タスク' : ['DONE', 'EXCLUDED', 'ARCHIVED'].includes(multi.state) ? '完了・除外' : 'タスク（未完了）', multi.id);
  $('documentDialog').close(); ms.childNodes.find(n => n.className === 'card-document').onclick({ preventDefault() {}, stopPropagation() {} });
  assert.equal($('documentBody').all(n => n.tagName === 'A').length, ctx.cardDocumentPaths(multi, bundle).length);
  assert(state().formDirty && state().dirty, 'reading documents keeps edits');
  // Selecting a card (after applying the input) shares the selection with the inspector.
  clickText($('editor'), '変更を適用'); found.find(([id]) => id === 'MS-SPI')[1].childNodes[0].click(); assert.equal(state().selected, 'MS-SPI');
  $('dependencyTab').click(); assert(!$('dependencyView').hidden && $('cardsView').hidden);
  console.log('PASS: OPS-085 smoke (isolated, permanent, finished task and intermediate card listed and opened, chooser lists bundled documents, proposal without link, tabs and reading keep edits, selection shared).');
})().catch(e => { console.error(e); process.exit(1); });
