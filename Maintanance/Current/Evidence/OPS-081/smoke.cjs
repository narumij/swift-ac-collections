// OPS-081 smoke test: runs the generated Studio page against a minimal DOM stub (no browser, no Safari).
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
const ctx = { document, window: { addEventListener() {}, location: { reload() {} } }, location: { protocol: 'http:' }, confirm: () => true, alert() {}, console, innerWidth: 1280, innerHeight: 800,
  setTimeout: () => 0, URL: Object.assign(function URL(u, b) { return new (require('url').URL)(u, b); }, { createObjectURL: blob => { downloaded = blob.text; return 'blob:x'; }, revokeObjectURL() {} }),
  Blob: function (parts) { this.text = parts.join(''); }, DOMParser: function () { this.parseFromString = () => ({ body: new Node('body') }); }, JSON, Math, Date, Set, Map, Array, Object, String, Number, Error, RegExp, Promise };
vm.createContext(ctx);
vm.runInContext(script.replace(/^'use strict';/, '') + '\n;globalThis.__get=()=>({doc,selected,dirty,formDirty});', ctx);
const $ = id => document.getElementById(id), state = () => ctx.__get();
const clickText = (root, text) => { const b = root.all(n => n.tagName === 'BUTTON' && n.textContent === text)[0]; assert(b, 'button not found: ' + text); b.click(); };

// 1. Add an independent proposal from the dialog.
$('addProposal').click();
assert($('proposalDialog').open, 'dialog opens');
let form = $('proposalForm'), [title] = form.all(n => n.tagName === 'INPUT'), [memo] = form.all(n => n.tagName === 'TEXTAREA');
title.value = '独立の追加案'; memo.value = '試験メモ'; clickText(form, '追加');
assert.deepEqual(state().doc.proposals, [{ id: 'draft-1', title: '独立の追加案', memo: '試験メモ' }]);
assert.equal(state().selected, 'draft-1'); assert(state().dirty); assert(!$('proposalDialog').open);
assert($('independent').all(n => n.tagName === 'STRONG' && n.textContent === 'draft-1 · 追加案').length === 1, 'independent strip shows the proposal');
assert(!$('independent').all(n => n.className === 'card-document').some(a => a.attributes['aria-label']?.startsWith('draft-1')), 'no 正本 link for a proposal');
assert.equal($('selectedTitle').textContent, 'draft-1 · 追加案');

// 2. Add a second proposal placed onto a milestone END.
$('addProposal').click(); form = $('proposalForm'); [title] = form.all(n => n.tagName === 'INPUT');
const place = form.all(n => n.tagName === 'SELECT')[0], end = place.childNodes.find(o => o.value.startsWith('ms:END-') && state().doc.milestones.find(m => 'ms:' + m.id === o.value).state !== 'DONE').value;
title.value = '到達点へつなぐ案'; place.value = end; clickText(form, '追加');
assert(state().doc.milestoneRelations.some(r => r.prerequisite === 'draft-2' && r.successor === end.slice(3) && r.conditionReview === '相談待ち'));
assert($('graph').all(n => n.tagName === 'TEXT' && n.textContent === 'draft-2 · 追加案').length === 1, 'graph draws the connected proposal');

// 3. Edit the title/memo of draft-1 and connect draft-1 → draft-2 from the proposal editor.
ctx.select('draft-1');
$('proposalTitle').value = '改題した案'; $('proposalMemo').value = '新しいメモ'; clickText($('editor'), '変更を適用');
assert.deepEqual(state().doc.proposals[0], { id: 'draft-1', title: '改題した案', memo: '新しいメモ' });
ctx.select('draft-1'); $('proposalNext').value = 'draft-2'; clickText($('editor'), '後続に追加');
assert(state().doc.edges.some(e => e.prerequisite === 'draft-1' && e.successor === 'draft-2' && e.conditionReview === '相談待ち'));
// A cycle is refused with a message and leaves the data unchanged.
ctx.select('draft-2'); $('proposalNext').value = 'draft-1'; const before = JSON.stringify(state().doc); clickText($('editor'), '後続に追加');
assert.equal(JSON.stringify(state().doc), before); assert(/循環/.test($('status').textContent));

// 4. Save, then reload the saved JSON.
$('save').onclick(); assert(downloaded, 'saved JSON produced');
const saved = JSON.parse(downloaded); assert(saved.changes.some(c => c.field === 'proposals')); assert(!saved.baseline.proposals);
const fileEvent = { target: { files: [{ text: async () => downloaded }], value: 'x' } };
Promise.resolve($('open').onchange(fileEvent)).then(() => {
  assert.deepEqual(state().doc.proposals, saved.proposals); assert.deepEqual(state().doc.edges, saved.edges); assert(!state().dirty);
  // 5. Cancel both proposals: no proposal, edge or milestone line remains.
  ctx.select('draft-1'); clickText($('editor'), 'この追加案を取り消す'); ctx.select('draft-2'); clickText($('editor'), 'この追加案を取り消す');
  const d = state().doc; assert(!('proposals' in d)); assert(!JSON.stringify(d.edges).includes('draft-')); assert(!JSON.stringify(d.milestoneRelations).includes('draft-'));
  assert.deepEqual(d.edges, d.baseline.edges); assert.deepEqual(d.milestoneRelations, d.baseline.milestoneRelations);
  console.log('PASS: OPS-081 smoke (add independent / onto END, edit, proposal→proposal line, cycle refused, save JSON, reload, cancel without traces).');
}).catch(e => { console.error(e); process.exit(1); });
