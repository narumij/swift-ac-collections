// @section main
// include-js:index.task.logic.js
// include-js:index.task.document.js
'use strict';
const $ = id => document.getElementById(id), copy = x => JSON.parse(JSON.stringify(x));
const STATES = ['ACTIVE', 'WAITING_USER', 'WAITING_EXTERNAL', 'FROZEN', 'USER_ONLY', 'PROPOSED', 'DONE', 'EXCLUDED', 'ARCHIVED'];
let doc = JSON.parse($('seed').textContent), selected = doc.tasks[0]?.id, dirty = false, formDirty = false;
// Edit version (OPS-082 trial): `workspace` is the saved version being continued; `canonical` is the newest canonical source from sync.
// The edit version keeps its own source/baseline (its base); a newer canonical is only reported, never merged in here.
let workspace = null, canonical = copy(doc.source), canonicalSnapshot = copy(doc);
let taskFollowCanonical = true;
// Card-list add forms (OPS-086 fix): their unapplied input lives here so selection, tab switches and re-renders keep it.
// It is not edit data: never saved, but refresh/leaving are guarded while it is pending.
let planDraft = { version: null, name: '', versionName: '' }; const planDraftPending = () => !!(planDraft.name.trim() || planDraft.versionName.trim());
initializeRelationBaseline(doc);
function el(tag, text, cls) { let e = document.createElement(tag); if (text !== undefined) e.textContent = text; if (cls) e.className = cls; return e; }
// Per-tab choice survives reload without deleting any Inbox history.
function canonicalStartMode(value) {
  try { if (value !== undefined) { if (value) sessionStorage.setItem('registry-studio-canonical-start', '1'); else sessionStorage.removeItem('registry-studio-canonical-start'); } return sessionStorage.getItem('registry-studio-canonical-start') === '1'; }
  catch (e) { if (value !== undefined) throw Error('開始方法を保持できません。ブラウザーの保存設定を確認してください。'); return false; }
}
function report(msg, error = false) { $('status').hidden = !msg; $('status').textContent = msg; $('status').classList.toggle('error', error); }
function banner() { renderCanonicalRestartSuggestion(); renderCanonicalNotice(); $('sourceInfo').textContent = (doc.source.kind === 'v3-export' ? 'V3 DB ' + doc.source.path + ' · 世代 ' + doc.source.generation + ' · 改訂 ' + doc.source.revision + '\npayloadHash ' + doc.source.payloadHash.slice(0, 12) + '（' + doc.source.payloadHashOf + '）' : '生成元 ' + doc.source.path + ' · HEAD ' + doc.source.head.slice(0, 8) + ' · ' + doc.source.generatedAt + '\nSHA-256 ' + doc.source.sha256 + ' · ' + (doc.source.dirty ? '未コミット差分を含む' : 'コミット済み版')) + ' · ' + delta().length + '件の変更' + (dirty ? ' ／ ファイル未保存' : '') + (formDirty ? ' ／ 入力を編集中：下の「変更を適用」で確定' : '') + (workspace ? '\n編集版 ' + workspace.saveId + ' を再開中' + (workspace.heads > 1 ? '（別の系列の保存もあります）' : '') : '') + (doc.source.kind === 'v3-export' ? (doc.source.generation !== canonical.generation || doc.source.revision !== canonical.revision ? '\nDBが更新されています：この編集版の土台 世代 ' + doc.source.generation + ' 改訂 ' + doc.source.revision + ' → 最新 世代 ' + canonical.generation + ' 改訂 ' + canonical.revision : '') : '') + (doc.source.kind !== 'v3-export' && doc.source.sha256 !== canonical.sha256 ? '\n正本が更新されています：この編集版の土台 ' + doc.source.sha256.slice(0, 12) + ' → 最新の正本 ' + canonical.sha256.slice(0, 12) + '（取り込み時にAIが比べます）' : ''); }
// Compare semantic fields only: line numbers, generation times and raw quotes are not edits.
function renderCanonicalNotice() {
  const rows = canonicalDifferences(doc.baseline, doc, canonicalSnapshot), changed = rows.filter(r => !r.unknown), unknown = rows.some(r => r.unknown), sourceChanged = doc.source.sha256 !== canonical.sha256;
  $('canonicalNotice').hidden = !rows.length && !sourceChanged;
  const conflicts = changed.filter(r => r.conflict).length;
  $('canonicalSummary').textContent = (changed.length || sourceChanged ? '正本に更新があります' : '正本との差を一部比較できません') + ' · ' + changed.length + '件' + (conflicts ? ' ／ 競合の可能性 ' + conflicts + '件' : '') + (unknown ? ' ／ 比較できない範囲あり' : '');
  $('canonicalDiff').textContent = rows.map(r => r.label + (r.title ? ' · ' + r.title : '') + (r.conflict ? ' 【競合の可能性あり】' : '') + (r.changes?.length ? '\n' + r.changes.map(c => '  ' + c.field + ': ' + JSON.stringify(c.before) + ' → ' + JSON.stringify(c.after)).join('\n') : '')).join('\n\n') || '生成元に差があります。比較対象のタスク・マイルストーン・接続の項目には変更がありません。';
}

function options(select, values, value) { for (const v of values) { const o = el('option', v); o.value = v; select.append(o); } select.value = value; }
function renderStateLegend() {
  const meanings = { ACTIVE: '有効（常設を含む）', PROPOSED: '提案中', WAITING_EXTERNAL: '外部待ち', WAITING_USER: 'ユーザー待ち', USER_ONLY: 'ユーザー専任', DONE: '完了', EXCLUDED: '対象外', FROZEN: '凍結', ARCHIVED: '履歴化' };
  const samples = Object.entries(meanings).map(([state, meaning]) => { const item = el('div', undefined, 'state-sample'); item.append(stateBand(state), el('span', meaning, 'state-meaning')); return item; });
  $('stateLegend').replaceChildren(...samples);
}
function renderPending() {
  const data = JSON.parse($('pendingSeed').textContent), box = $('pendingList'); box.replaceChildren(); $('pendingCount').textContent = data.entries.length + '件'; $('pendingStamp').textContent = (data.sources || [{ path: data.source }]).map(s => (s.owner ? s.owner + '：' : '') + s.path).join(' · ') + ' · 取得 ' + data.generatedAt;
  for (const entry of data.entries) { const card = el('button', undefined, 'pending-card'); const source = entry.source || data.source; card.append(el('strong', entry.id), el('span', entry.title.replaceAll('`', '')), el('small', entry.state + (entry.owner ? ' · ' + entry.owner : ''))); card.onclick = () => { const dialog = $('documentDialog'); $('documentTitle').textContent = entry.id + ' · 採番待ち'; $('documentStamp').textContent = source + ' · 取得 ' + data.generatedAt; if (entry.html) { openDocument(source, { html: entry.html }); $('documentTitle').textContent = entry.id + ' · 採番待ち'; $('documentStamp').textContent = source + ' · 取得 ' + data.generatedAt; } else { $('documentBody').replaceChildren(el('pre', entry.raw)); if (!dialog.open) dialog.showModal(); } }; box.append(card); }
  if (!data.entries.length) box.append(el('p', '採番待ちはありません。', 'muted'));
}
function render() { renderProtection(); renderCards(); renderPlanTools(); renderNeighborhood(); renderPending(); renderStateLegend(); graph(); independent(); permanentMap(); editor(); banner(); if (!$('diffPanel').hidden) showDiff(); }
// A new selection also becomes the neighborhood center and drops the previous expansion (OPS-093). Reset only after the
// existing input guard, so a cancelled move keeps both the selection and the center.
function select(id) { if (formDirty && !confirm('編集中の入力を破棄して移動しますか？')) return; formDirty = false; selected = id; neighborCenter = id; neighborExpanded.clear(); render(); }
function cardWithDocuments(card, t) { const shell = el('div', undefined, 'task-shell'); shell.append(card); if (!t.proposal && taskDocumentPaths(t).length) { const a = el('a', '正本', 'card-document'); a.href = '#document'; a.setAttribute('aria-label', t.id + ' の正本を読む'); a.onclick = e => { e.preventDefault(); e.stopPropagation(); openTaskDocuments(t); }; shell.append(a); } return shell; }
function openTaskDocuments(t) { const paths = taskDocumentPaths(t); if (paths.length === 1) { openDocument(paths[0]); return; } const dialog = $('documentDialog'); $('documentTitle').textContent = t.id + ' の正本'; $('documentStamp').textContent = '読む文書を選択してください'; $('documentBody').replaceChildren(documentLinks(t.detail)); if (!dialog.open) dialog.showModal(); }

function svg(tag, attrs, text) { let n = document.createElementNS('http://www.w3.org/2000/svg', tag); for (const [k, v] of Object.entries(attrs)) n.setAttribute(k, v); if (text !== undefined) n.textContent = text; return n; }
// OPS-154 区切り1: the maps are derived as data (view models) and drawn by small views. An SVG view model is a tree of
// {tag, attrs, text, children, action, intent}; drawSvgSpec builds it in order and hands each intent to the view's binder.
// `action` is the common "clickable group" (tabindex, role, aria-label, pointer cursor, a title, Enter/Space = click).
// Pure: up to maxLines lines of at most `limit` pixels, the last one cut with "…"; `measure` returns a text's width.
function wrapLines(text, limit, maxLines, measure) { let out = ['']; for (const ch of text) { let i = out.length - 1; if (measure(out[i] + ch) > limit) out.push(ch); else out[i] += ch; } if (out.length > maxLines) { out = out.slice(0, maxLines); while (measure(out[maxLines - 1] + '…') > limit) out[maxLines - 1] = out[maxLines - 1].slice(0, -1); out[maxLines - 1] += '…'; } return out; }
function drawSvgSpec(spec, bind = () => { }, made = new Map()) {
  const n = svg(spec.tag, spec.attrs || {}, spec.text); made.set(spec, n); for (const child of spec.children || []) n.append(drawSvgSpec(child, bind, made));
  if (spec.action) { n.setAttribute('tabindex', 0); n.setAttribute('role', 'button'); n.setAttribute('aria-label', spec.action.title); n.style.cursor = 'pointer'; n.append(svg('title', {}, spec.action.title)); const fn = () => bind(spec.action.intent, n, made); n.onclick = fn; n.onkeydown = e => { if (e.key === 'Enter' || e.key === ' ') { e.preventDefault(); fn(); } }; }
  else if (spec.intent) bind(spec.intent, n, made);
  return n;
}
function independent() {
  drawIndependent($('independent'), $('independentCount'), independentViewModel(independentGroups(doc).regular, selected, t => taskDocumentPaths(t).length > 0), { select, openDocuments: openTaskDocuments });
}
// The independent-strip view: draws the view model as given (class, texts, band colors, document link) and reports intents.
function drawIndependent(strip, count, vm, intents) {
  count.textContent = vm.count; const scroll = strip.scrollLeft; strip.replaceChildren();
  for (const c of vm.items) {
    const b = el('button', undefined, c.className); b.setAttribute('aria-pressed', String(c.selected)); b.append(el('strong', c.heading), el('span', c.text), bandView(c.band)); b.title = c.title; b.onclick = () => intents.select(c.id);
    const shell = el('div', undefined, 'task-shell'); shell.append(b);
    if (c.documents) { const a = el('a', '正本', 'card-document'); a.href = '#document'; a.setAttribute('aria-label', c.id + ' の正本を読む'); a.onclick = e => { e.preventDefault(); e.stopPropagation(); intents.openDocuments(c.node); }; shell.append(a); }
    strip.append(shell);
  } strip.scrollLeft = scroll;
  if (!vm.items.length) strip.append(el('p', vm.empty, 'muted'));
}
// Pure: the independent strip (OPS-154). `node` is the task itself, kept only for the document link.
function independentViewModel(tasks, selected, hasDocuments) {
  return {
    count: tasks.length + '件', empty: '該当するタスクはありません。', items: tasks.map(t => ({
      id: t.id, node: t, selected: selected === t.id, className: 'task' + (selected === t.id ? ' selected' : '') + (t.proposal ? ' proposal' : ''),
      heading: t.proposal ? t.id + ' · 追加案' : t.id + (t.permanent ? ' · 常設' : ''), text: t.item.replace(/^\[(EXECUTION|DISCOVERY|DECISION)\]\s*/, ''), state: t.state, band: stateBandModel(t.state),
      title: t.proposal ? t.item + '\n追加案（正式採番前）\nメモ：' + (t.memo || 'なし') : t.item + '\n担当：' + t.owner + '\n状態：' + t.state + '\n条件：' + t.condition, documents: !t.proposal && hasDocuments(t)
    }))
  };
}
function permanentMap() {
  const measure = document.createElement('canvas').getContext('2d'); measure.font = '12px -apple-system, sans-serif';
  const vm = permanentMapViewModel(permanentMapData(doc), selected, text => measure.measureText(text).width);
  const s = drawSvgSpec(vm.svg, intent => { if (intent.type === 'select') select(intent.id); else if (intent.type === 'documents') openTaskDocuments(intent.node); else if (intent.type === 'document') openDocument(intent.path); });
  $('permanentMap').replaceChildren(s); $('permanentMapCount').textContent = vm.count;
}
// Pure (OPS-154): the permanent-task map as an SVG view model. Intents: select a task, open a task's documents, open one document.
function permanentMapViewModel(groups, selected, measure) {
  const W = 250, step = 295, top = 20, docTop = 160, docStep = 78;
  const height = Math.max(230, ...groups.map(g => docTop + g.descendants.length * 116 + g.documents.length * docStep + 20));
  const children = [], label = (text, x, y, maxLines = 2) => wrapLines(text, W - 24, maxLines, measure).map((line, i) => ({ tag: 'text', attrs: { x, y: y + i * 17, fill: '#243234' }, text: line }));
  const action = (title, intent) => ({ title, intent });
  groups.forEach(({ task: t, descendants: list, documents }, i) => {
    const childTop = 160, docTop = 160 + list.length * 116;
    const x = 20 + i * step, center = x + W / 2, c = stateStyle(t.state);
    if (documents.length) children.push({ tag: 'path', attrs: { d: `M${center},${top + 96} V${top + 120} H${x - 8} V${docTop + (documents.length - 1) * docStep + 29}`, stroke: '#b4c6be', 'stroke-width': 2, fill: 'none' } });
    children.push({
      tag: 'g', attrs: {}, children: [{ tag: 'rect', attrs: { x, y: top, width: W, height: 96, rx: 8, fill: selected === t.id ? '#edf6ef' : 'white', stroke: selected === t.id ? '#126c58' : '#b8ccc0', 'stroke-width': selected === t.id ? 3 : 1 } }, ...label(t.id + ' · ' + t.owner, x + 12, top + 18, 1), ...label(t.item.replace(/^\[[^\]]+\]\s*/, ''), x + 12, top + 40),
      { tag: 'rect', attrs: { x: x + 1, y: top + 72, width: W - 2, height: 23, fill: c.bg } }, { tag: 'text', attrs: { x: x + 12, y: top + 88, fill: c.fg }, text: t.state }], action: action(t.id + ' ' + t.item, { type: 'select', id: t.id })
    });
    list.forEach((child, j) => {
      const ind = child.depth * 18, cx = x + ind, cw = W - ind, y = childTop + j * 116, c = stateStyle(child.state);
      // Nested sub-tasks hang from their parent's row instead of the permanent task's spine.
      const pj = list.findIndex(p => p.id === child.parentTask), from = child.depth && pj >= 0 ? `M${x + (child.depth - 1) * 18 + 10},${childTop + pj * 116 + 96} V${y + 48} H${cx}` : `M${center},${top + 96} V${top + 120} H${x - 8} V${y + 48} H${x}`;
      children.push({ tag: 'path', attrs: { d: from, stroke: '#8ba7bd', fill: 'none' } }, {
        tag: 'g', attrs: {}, children: [{ tag: 'rect', attrs: { x: cx, y, width: cw, height: 96, rx: 8, fill: selected === child.id ? '#edf6ef' : 'white', stroke: '#8ba7bd' } }, ...label(child.id + ' · ' + (child.depth ? child.parentTask + ' のサブタスク' : 'サブタスク'), cx + 12, y + 18, 1), ...label(child.item.replace(/^\[[^\]]+\]\s*/, ''), cx + 12, y + 40),
        { tag: 'rect', attrs: { x: cx + 1, y: y + 72, width: cw - 2, height: 23, fill: c.bg } }, { tag: 'text', attrs: { x: cx + 12, y: y + 88, fill: c.fg }, text: child.state }], action: action(child.id + ' ' + child.item + '\n' + child.condition, { type: 'select', id: child.id })
      });
      if (child.documents.length) children.push({ tag: 'g', attrs: {}, children: [{ tag: 'rect', attrs: { x: x + W - 62, y: y + 6, width: 54, height: 20, rx: 5, fill: '#f3f6ef', stroke: '#cbd8c9' } }, { tag: 'text', attrs: { x: x + W - 54, y: y + 20, fill: '#126c58', 'font-size': 12 }, text: '正本 ' + child.documents.length }], action: action(child.id + ' の正本を読む（' + child.documents.join('、') + '）', { type: 'documents', node: child }) });
    });
    documents.forEach((path, j) => { const y = docTop + j * docStep; children.push({ tag: 'path', attrs: { d: `M${x - 8},${y + 29} H${x}`, stroke: '#b4c6be', fill: 'none' } }, { tag: 'g', attrs: {}, children: [{ tag: 'rect', attrs: { x, y, width: W, height: 58, rx: 7, fill: '#f3f6ef', stroke: '#cbd8c9' } }, ...label(path.split('/').pop(), x + 12, y + 20, 2)], action: action(path + ' を読む', { type: 'document', path }) }); });
    if (!documents.length) children.push({ tag: 'text', attrs: { x: x + 12, y: docTop + 20, fill: '#657477' }, text: '正本への参照なし' });
  });
  return { count: groups.length + '件', svg: { tag: 'svg', attrs: { width: Math.max(900, groups.length * step + 20), height, role: 'group', 'aria-label': '恒久タスクと正本の参照関係' }, children } };
}

// include-js:index.task.zoom.js
function field(parent, title, id, type, value) { const l = el('label', title); l.htmlFor = id; const e = el(type); e.id = id; if (type === 'textarea') e.rows = 5; e.value = value; parent.append(l, e); e.oninput = () => { formDirty = true; banner(); }; return e; }
const documentBundle = JSON.parse($('documents').textContent);
function documentLinks(detail) {
  const wrap = el('div'); const paths = [...detail.matchAll(/(?:Maintanance|Sources|Tests)\/[^`\s|]+?\.md/g)].map(m => m[0]);
  if (!paths.length) return el('pre', detail);
  for (const path of [...new Set(paths)]) { const a = el('a', path); a.href = '#document'; a.style.display = 'block'; a.onclick = e => { e.preventDefault(); openDocument(path); }; wrap.append(a); } return wrap;
}
const canonicalDocument = new CanonicalDocumentViewModel(documentBundle);
canonicalDocument.subscribe(renderCanonicalDocument);
function openDocument(path, overrideRecord) {
  canonicalDocument.select(path, overrideRecord);
}
$('closeDocument').onclick = () => $('documentDialog').close();
{
  const dialog = $('documentDialog'); let backdropPress = false;
  const outside = e => { const r = dialog.getBoundingClientRect(); return e.target === dialog && (e.clientX < r.left || e.clientX > r.right || e.clientY < r.top || e.clientY > r.bottom); };
  dialog.addEventListener('pointerdown', e => { backdropPress = outside(e); });
  dialog.addEventListener('pointercancel', () => { backdropPress = false; });
  dialog.addEventListener('click', e => { if (backdropPress && outside(e)) dialog.close(); backdropPress = false; });
  dialog.addEventListener('close', () => { backdropPress = false; });
}


// OPS-154 stage 3: the editor as a view model. editorViewModel reads only its inputs (the edit version, the graph nodes and
// lines as drawn, the selection) and returns the picker and the editor as blocks; drawEditor builds the DOM and returns intents;
// editorAct changes the Model by IDs with the existing functions. Typed values live in the drawn fields, not in the Model, so the
// editor is not redrawn while formDirty (a version change used to redraw it and lose the typed input).
const EDITOR_GUARD = '先に入力の「変更を適用」を押してください。';
function editorViewModel({ data, graph, selected }) {
  const picker = { options: [...graph.nodes].sort((a, b) => a.id.localeCompare(b.id, 'en', { numeric: true })).map(t => ({ value: t.id, title: t.item })), value: selected || '' };
  const t = graph.nodes.find(t => t.id === selected); if (!t) return { picker, title: null, blocks: [] };
  const text = (tag, text, cls) => ({ type: 'text', tag, text, cls }), muted = s => text('p', s, 'muted'), pick = (label, id, values, value, extra) => ({ type: 'field', label, id, control: 'select', value: '', options: { values, value, ...extra }, typing: false });
  const edge = (strong, note, relation) => ({ type: 'edge', strong, note, intent: { type: 'removeRelation', relation } }), none = list => list.length ? [] : [muted('まだありません。')];
  const blocks = [{ type: 'buttons', items: [{ text: '接続を見る', title: 'このノードの前提・後続を「接続を見る」タブで表示します（編集内容は変わりません）', intent: { type: 'look', id: t.id } }] }];
  if (t.proposal) return { picker, title: t.id + ' · 追加案', blocks: blocks.concat(proposalBlocks(data, t)) };
  if (t.kind === 'milestone') {
    if (planParts(t) || t.planned) blocks.push(...milestonePlanBlocks(data, t));
    blocks.push(muted(t.planned ? 'マイルストーンの計画案（編集版だけにあり、正本はまだありません）' : 'マイルストーン · 正本の内容（下の計画欄の変更は編集版の案で、正本は変わりません）'), text('h3', '条件・判断'), text('pre', t.condition), text('h3', '正本'), { type: 'documents', detail: t.detail });
    for (const e of graph.edges.filter(e => e.successor === t.id || e.prerequisite === t.id)) { const d = dataRelation(e); blocks.push(text('p', d.prerequisite + ' → ' + d.successor + ' / ' + linkLabel(d, data)), text('pre', e.constraint + (e.source ? '\n出典：' + e.source.path + ':' + e.source.line : ''))); }
    return { picker, title: t.item, blocks };
  }
  const typed = (label, id, control, value, options) => ({ type: 'field', label, id, control, value, options, typing: true }), rels = data.milestoneRelations || [], ms = data.milestones || [];
  blocks.push({ type: 'row', columns: [[typed('状態', 'state', 'select', '', { values: [...new Set([...STATES, t.state])], value: t.state })], [typed('担当', 'owner', 'input', t.owner)]] },
    text('h3', '項目'), text('p', t.item), text('h3', '条件・判断の原文'), text('pre', t.condition),
    { type: 'buttons', items: [{ text: '変更を適用', cls: 'primary', intent: { type: 'applyTask', id: t.id, read: { state: 'state', owner: 'owner' } } }] },
    text('h3', '詳細正本・出典'), { type: 'documents', detail: t.detail }, muted(data.source.path + ':' + t.sourceLine), { type: 'details', summary: '生成時の行を読む', text: t.raw }, text('h3', 'このタスクの前提'));
  for (const e of data.edges.filter(e => e.successor === t.id)) blocks.push(edge(e.prerequisite + ' · ' + e.flow, (e.conditionReview ? '条件：AIと相談待ち。元の条件：' : '') + (e.constraint || '未設定'), { ...e }));
  blocks.push({ type: 'row', columns: [[pick('前提タスク', 'prerequisite', data.tasks.filter(x => x.id !== t.id).map(x => x.id), data.tasks.find(x => x.id !== t.id)?.id)], [pick('合流位置', 'flow', ['SEQUENCE', 'PARALLEL_JOIN'], 'SEQUENCE')]] },
    muted('依存条件はAIと相談して決めます。追加した接続は相談待ちとして保存されます。'), { type: 'button', text: '前提を追加', intent: { type: 'addPrerequisite', id: t.id, read: { prerequisite: 'prerequisite', flow: 'flow' } } });
  const links = rels.filter(e => e.prerequisite === t.id), note = e => (e.conditionReview ? '条件：AIと相談待ち。' : '') + (e.constraint || '条件未設定');
  blocks.push(text('h3', 'このタスクがつながる到達点（このタスク → 到達点）'), ...none(links), ...links.map(e => edge(e.successor, note(e), { ...e, flow: 'PARALLEL_JOIN' })));
  const gateOf = new Map(rels.filter(r => r.prerequisite.startsWith('END-') && r.successor.startsWith('GATE-')).map(r => [r.prerequisite, r.successor])), targets = ms.filter(m => !m.id.startsWith('GATE-') && !m.id.startsWith('START-'));
  blocks.push({
    type: 'row', columns: [[pick('到達点（版のENDか途中のカード。版ゲートへは直接つなげない）', 'milestoneTarget', targets.map(m => m.id), targets.find(m => m.id.startsWith('END-') && m.state !== 'DONE')?.id || targets[0]?.id, { labels: Object.fromEntries(targets.filter(m => gateOf.has(m.id)).map(m => [m.id, m.id + '（→ ' + gateOf.get(m.id) + '）'])) })],
    [muted('線は関係の所在だけを示します。完了・着手・再開の条件は、取り込み時にAIと相談して正本（Registryのマイルストーン接続）の制約文へ書きます。')]]
  }, { type: 'button', text: '到達点へつなぐ', intent: { type: 'milestoneRelation', id: t.id, read: { target: 'milestoneTarget' } } });
  // Milestone as prerequisite (OPS-084): an intermediate card → this task. Shown and added separately so the arrow direction is explicit.
  const after = rels.filter(e => e.successor === t.id && !e.prerequisite.startsWith('START-'));
  blocks.push(text('h3', 'マイルストーンの後に続く（マイルストーン → このタスク）'), ...none(after), ...after.map(e => edge(e.prerequisite + ' → ' + t.id, note(e), { ...e, flow: 'PARALLEL_JOIN' })));
  const cards = ms.filter(m => !/^(START|END|GATE)-/.test(m.id)).map(m => m.id);
  if (cards.length) blocks.push({ type: 'row', columns: [[pick('前提にする途中のカード（このカードの後にこのタスクが続く）', 'milestoneSource', cards, cards[0])]] }, { type: 'button', text: 'マイルストーンを前提にする', intent: { type: 'milestoneRelation', id: t.id, direction: 'from', read: { target: 'milestoneSource' } } });
  // Separate item (OPS-069 step 3, user correction): where this task starts. The stored line is START-x → task; the figure draws it out of the release gate before that version.
  const startLinks = rels.filter(e => e.successor === t.id && e.prerequisite.startsWith('START-')), startIds = ms.filter(m => m.id.startsWith('START-')).map(m => m.id);
  blocks.push(text('h3', 'このタスクが始まる版（START）'), ...none(startLinks), ...startLinks.map(e => edge(e.prerequisite, note(e), { ...e, flow: 'PARALLEL_JOIN' })),
    {
      type: 'row', columns: [[pick('開始する版のSTART（この版の作業区間で始める仕事）', 'startSource', startIds, ms.find(m => m.id.startsWith('START-') && m.state !== 'DONE')?.id || startIds[startIds.length - 1])],
      [muted('図ではSTARTは描かれず、その版の前の版ゲートから線が出ます。開始条件は取り込み時に制約文（「開始側。」で始める）へ書きます。')]]
    }, { type: 'button', text: 'STARTからつなぐ', intent: { type: 'milestoneRelation', id: t.id, read: { target: 'startSource' } } });
  return { picker, title: t.id + (t.permanent ? ' · 常設タスク' : ''), blocks };
}
// The view: draws the supplied view model and returns intents with the values of the fields each intent reads.
function drawEditor(box, title, picker, vm, act) {
  picker.replaceChildren(); for (const o of vm.picker.options) { const option = el('option', o.value); option.value = o.value; option.title = o.title; picker.append(option); }
  picker.value = vm.picker.value; picker.onchange = () => act({ type: 'select', id: picker.value });
  box.replaceChildren(); if (vm.title !== null) title.textContent = vm.title;
  const fields = new Map(), press = intent => () => act(intent, Object.fromEntries(Object.entries(intent.read || {}).map(([k, id]) => [k, fields.get(id).value])));
  const button = (b, parent) => { const n = el('button', b.text, b.cls); if (b.title) n.title = b.title; n.onclick = press(b.intent); parent.append(n); };
  const draw = (b, parent) => {
    if (b.type === 'text') parent.append(el(b.tag, b.text, b.cls));
    else if (b.type === 'documents') parent.append(documentLinks(b.detail));
    else if (b.type === 'details') { const d = el('details'); d.append(el('summary', b.summary), el('pre', b.text)); parent.append(d); }
    else if (b.type === 'buttons') { const w = el('div', undefined, 'buttons'); for (const x of b.items) button(x, w); parent.append(w); }
    else if (b.type === 'button') button(b, parent);
    else if (b.type === 'edge') { const div = el('div', undefined, 'edge-row'), remove = el('button', '削除'); remove.onclick = press(b.intent); div.append(remove, el('strong', b.strong), el('p', b.note, 'muted')); parent.append(div); }
    else if (b.type === 'row') { const r = el('div', undefined, 'row'); parent.append(r); for (const column of b.columns) { const c = el('div'); r.append(c); for (const x of column) draw(x, c); } }
    else if (b.type === 'field') { const e = field(parent, b.label, b.id, b.control, b.value); if (b.options) { options(e, b.options.values, b.options.value); for (const o of e.children) { const label = b.options.labels?.[o.value]; if (label) o.textContent = label; } } if (!b.typing) e.oninput = null; fields.set(b.id, e); }
  };
  for (const b of vm.blocks) draw(b, box);
}
// The presenter: guards and the existing Model changes, unchanged; the intent names the target by ID.
function editorAct(intent, v = {}) {
  const guarded = () => { if (formDirty) { report(EDITOR_GUARD, true); return true; } return false; };
  const change = f => { try { f(); dirty = true; render(); } catch (e) { report(e.message, true); } };
  switch (intent.type) {
    case 'select': select(intent.id); $('taskPicker').value = selected || ''; return;
    case 'look': showNeighborhood(intent.id); return;
    case 'applyTask': { const t = doc.tasks.find(x => x.id === intent.id); for (const k of ['state', 'owner']) t[k] = v[k]; dirty = true; formDirty = false; render(); return; }
    case 'removeRelation': removeRelation(intent.relation); return;
    case 'addPrerequisite': { if (guarded()) return; const edge = { prerequisite: v.prerequisite, successor: intent.id, flow: v.flow, constraint: '', conditionReview: '相談待ち', raw: null, sourceLine: null }; doc.edges.push(edge); try { check(doc); } catch (e) { doc.edges.pop(); report(e.message, true); return; } dirty = true; render(); return; }
    case 'milestoneRelation': if (guarded()) return; change(() => { doc = addMilestoneRelation(doc, intent.id, v.target, intent.direction); }); return;
    case 'planEditText': change(() => { doc = planEditText(doc, intent.id, v.item, v.condition); formDirty = false; }); return;
    case 'planReorder': if (guarded()) return; change(() => { doc = planReorder(doc, intent.id, intent.step); }); return;
    case 'planMove': if (guarded()) return; change(() => { doc = planMove(doc, intent.id, v.version); }); return;
    case 'updateProposal': change(() => { doc = updateProposal(doc, intent.id, v.title, v.memo); formDirty = false; }); return;
    case 'removeProposal': if (!confirm(intent.id + ' を取り消しますか？ この案につながる線も一緒に消えます。')) return; change(() => { doc = removeProposal(doc, intent.id); selected = doc.tasks[0]?.id; formDirty = false; }); return;
    case 'proposalEdge': if (guarded()) return; change(() => { doc = intent.side === 'pre' ? addProposalEdge(doc, v.other, intent.id, v.flow) : addProposalEdge(doc, intent.id, v.other, v.flow); }); return;
  }
}
function editor() { if (formDirty) return; drawEditor($('editor'), $('selectedTitle'), $('taskPicker'), editorViewModel({ data: doc, graph: graphData(), selected }), editorAct); }
// Editor for a task proposal (OPS-081): title/memo correction, cancellation, and lines to tasks, proposals and milestones.
// Plan editor for an intermediate card (OPS-086): name / arrival condition as a proposal, order within its version, move to another version.
function milestonePlanBlocks(data, t) {
  const parts = planParts(t), text = (tag, s, cls) => ({ type: 'text', tag, text: s, cls }), blocks = [text('h3', '計画の編集（編集版の案・未反映）')];
  if (!parts) return blocks.concat([text('p', '計画で追加した版の始点・終点です。並び順と前後の版へのつなぎ方は未決のため、ここでは編集しません。', 'muted')]);
  const base = ((data.baseline && data.baseline.milestones) || []).find(m => m.id === t.id);
  blocks.push(text('p', '計画上の置き場所：' + t.gate + (base && base.gate !== t.gate ? '（正本では ' + base.gate + '）' : base ? '' : '（新しいカード）'), 'muted'),
    { type: 'field', label: '名前', id: 'planItem', control: 'input', value: t.item, typing: true }, { type: 'field', label: '到達条件の案（空欄なら変更なし）', id: 'planCondition', control: 'textarea', value: t.planCondition || '', typing: true },
    { type: 'buttons', items: [{ text: '名前・条件を適用', cls: 'primary', intent: { type: 'planEditText', id: t.id, read: { item: 'planItem', condition: 'planCondition' } } }, { text: '前へ', intent: { type: 'planReorder', id: t.id, step: -1 } }, { text: '後へ', intent: { type: 'planReorder', id: t.id, step: 1 } }] });
  const others = planVersions(data).filter(v => v !== parts.version);
  if (others.length) blocks.push({ type: 'row', columns: [[{ type: 'field', label: '別の版へ移動（移動先の最後に入ります）', id: 'planVersion', control: 'select', value: '', options: { values: others, value: others[0] }, typing: false }]] }, { type: 'button', text: 'この版へ移動', intent: { type: 'planMove', id: t.id, read: { version: 'planVersion' } } });
  blocks.push(text('p', 'IDとtaskからの接続はそのまま保ちます。task→ENDの接続は動きません。実際のファイルの移動・改名は、取り込み時にAIが行います。', 'muted'));
  return blocks;
}
// Card-list tools (OPS-086): add an intermediate card to a version, or add an unconnected version.
function renderPlanTools() {
  const outer = $('planTools'); if (!outer) return; outer.replaceChildren();
  // OPS-126 proposal 6: closed by default; the open state survives re-renders; pending input and plan changes stay visible in the summary.
  const box = el('details'), summary = el('summary'); box.id = 'planToolsDetails'; box.open = !!renderPlanTools.open;
  const planChangeCount = milestonePlanChanges(doc).length, note = () => '版・中間カードの編集（マイルストーン計画・編集版の案）' + (planChangeCount ? ' · 計画の変更' + planChangeCount + '件' : '') + (planDraftPending() ? ' · 入力途中あり' : '');
  summary.textContent = note(); box.ontoggle = () => { renderPlanTools.open = box.open; summary.textContent = note(); }; box.append(summary); outer.append(box);
  const versions = planVersions(doc), r = el('div', undefined, 'row'), a = el('div'), b = el('div'); r.append(a, b); box.append(r);
  const ver = el('select'); ver.id = 'planAddVersionOf'; options(ver, versions, versions.includes(planDraft.version) ? planDraft.version : versions.find(v => v === doc.milestoneHead) || versions[0]); ver.onchange = () => { planDraft.version = ver.value; }; const lv = el('label', 'カードを追加する版'); lv.append(ver); a.append(lv);
  const nm = el('input'); nm.id = 'planAddName'; nm.value = planDraft.name; nm.oninput = () => { planDraft.name = nm.value; }; const ln = el('label', '新しい中間カードの名前'); ln.append(nm); b.append(ln);
  const addCard = el('button', '中間カードを追加'); box.append(addCard); addCard.onclick = () => { if (formDirty) { report('先に入力の「変更を適用」を押してください。', true); return; } try { const res = planAddCard(doc, ver.value, nm.value, ''); doc = res.data; selected = res.id; planDraft.version = ver.value; planDraft.name = ''; dirty = true; render(); } catch (e) { report(e.message, true); } };
  const vn = el('input'); vn.id = 'planNewVersion'; vn.value = planDraft.versionName; vn.oninput = () => { planDraft.versionName = vn.value; }; const lvn = el('label', '新しい版の名前（前後の版とはつなぎません。並び順とつなぎ方は未決）'); lvn.append(vn); box.append(lvn);
  let after = null; if (doc.source && doc.source.kind === 'v3-export') { after = el('select'); after.id = 'planAddVersionAfter'; options(after, ['（先頭）'].concat(versions), versions[versions.length - 1]); const la = el('label', '追加する位置（この版の後）'); la.append(after); box.append(la); } const addVer = el('button', '版を追加'); box.append(addVer); addVer.onclick = () => { if (formDirty) { report('先に入力の「変更を適用」を押してください。', true); return; } try { const name = vn.value.trim(); doc = planAddVersion(doc, vn.value); if (after) { const s = doc.milestones.find(m => m.id === 'START-' + name); if (s) s.planPosition = { after: after.value === '（先頭）' ? null : after.value }; } planDraft.versionName = ''; dirty = true; render(); report('版 ' + name + ' を計画に追加しました（つながっていない版です）。'); } catch (e) { report(e.message, true); } };
  const changes = milestonePlanChanges(doc); box.append(el('p', changes.length ? '計画の変更 ' + changes.length + '件（保存すると取り込み用の差分に入ります）' : '計画の変更はまだありません。', 'muted'));
}
function proposalBlocks(data, t) {
  const muted = s => ({ type: 'text', tag: 'p', text: s, cls: 'muted' }), pick = (label, id, values, value) => ({ type: 'field', label, id, control: 'select', value: '', options: { values, value }, typing: false });
  const blocks = [muted('正式採番前の追加案です。保存したJSONをAIへ渡すと、取り込み時に正式IDと正本が付きます。状態・担当は取り込み時に決めます。'),
  { type: 'field', label: 'タイトル（必須）', id: 'proposalTitle', control: 'input', value: t.item, typing: true }, { type: 'field', label: 'メモ', id: 'proposalMemo', control: 'textarea', value: t.memo, typing: true },
  { type: 'buttons', items: [{ text: '変更を適用', cls: 'primary', intent: { type: 'updateProposal', id: t.id, read: { title: 'proposalTitle', memo: 'proposalMemo' } } }, { text: 'この追加案を取り消す', intent: { type: 'removeProposal', id: t.id } }] }];
  const others = data.tasks.map(x => x.id).concat(proposalNodes(data).map(x => x.id)).filter(id => id !== t.id), link = e => isMilestoneLink(e, data);
  const listEdges = (heading, edges, end) => { blocks.push({ type: 'text', tag: 'h3', text: heading }); if (!edges.length) blocks.push(muted('まだありません。')); for (const e of edges) blocks.push({ type: 'edge', strong: end(e) + (e.flow && !link(e) ? ' · ' + e.flow : ''), note: '条件：AIと相談待ち', intent: { type: 'removeRelation', relation: link(e) ? { ...e, flow: 'PARALLEL_JOIN' } : { ...e } } }); };
  const addEdgeRow = (label, id, side) => blocks.push({ type: 'row', columns: [[pick(label, id, others, others[0])], [pick('合流位置', id + 'Flow', ['SEQUENCE', 'PARALLEL_JOIN'], 'SEQUENCE')]] }, { type: 'button', text: label + 'に追加', intent: { type: 'proposalEdge', id: t.id, side, read: { other: id, flow: id + 'Flow' } } });
  listEdges('この案の前提', data.edges.filter(e => e.successor === t.id), e => e.prerequisite);
  if (others.length) addEdgeRow('前提', 'proposalPre', 'pre');
  listEdges('この案を前提にする後続', data.edges.filter(e => e.prerequisite === t.id), e => e.successor);
  if (others.length) addEdgeRow('後続', 'proposalNext', 'next');
  // Milestones on both sides (OPS-084): rows show the arrow so the direction cannot be mistaken.
  listEdges('マイルストーンとの接続', (data.milestoneRelations || []).filter(e => e.prerequisite === t.id || e.successor === t.id), e => e.prerequisite === t.id ? t.id + ' → ' + e.successor : e.prerequisite + ' → ' + t.id);
  const ms = data.milestones || [], ahead = ms.filter(m => !/^(START|GATE)-/.test(m.id)).map(m => m.id), behind = ms.filter(m => !/^(END|GATE)-/.test(m.id)).map(m => m.id);
  const msRow = (label, id, list, initial, button, direction) => { if (!list.length) return; blocks.push({ type: 'row', columns: [[pick(label, id, list, initial || list[0])]] }, { type: 'button', text: button, intent: { type: 'milestoneRelation', id: t.id, direction, read: { target: id } } }); };
  msRow('前提：マイルストーン → この案（途中のカードか、開始する版のSTART）', 'proposalSource', behind, behind.find(id => !id.startsWith('START-')), 'マイルストーンの後に続ける', 'from');
  msRow('後続：この案 → 到達点（ENDか途中のカード）', 'proposalTarget', ahead, ahead.find(id => id.startsWith('END-')), '到達点へつなぐ');
  return blocks;
}
function openProposalDialog() {
  if (formDirty) { report('先に入力の「変更を適用」を押してください。', true); return; }
  const dialog = $('proposalDialog'), box = $('proposalForm'); box.replaceChildren();
  const label = (text, control) => { const l = el('label', text); l.append(control); box.append(l); return control; };
  const title = label('タイトル（必須）', el('input')), memo = label('メモ（任意）', el('textarea')); memo.rows = 4;
  const place = label('置き場所', el('select')); const opt = (v, text) => { const o = el('option', text); o.value = v; place.append(o); }; opt('', '独立タスクとして置く');
  for (const m of (doc.milestones || []).filter(m => !m.id.startsWith('GATE-') && !m.id.startsWith('START-'))) opt('ms:' + m.id, '到達点 ' + m.id + ' へつなぐ');
  for (const x of doc.tasks.concat(proposalNodes(doc))) opt('task:' + x.id, x.id + ' の前提にする');
  const error = el('p', undefined, 'unsaved'); error.setAttribute('role', 'alert'); box.append(el('p', '線の条件は「AIと相談待ち」で保存します。正式IDと正本は取り込み時に付きます。', 'muted'), error);
  const buttons = el('div', undefined, 'buttons'), add = el('button', '追加', 'primary'), cancel = el('button', 'キャンセル'); buttons.append(add, cancel); box.append(buttons);
  add.onclick = () => { try { let { data, id } = addProposal(doc, title.value, memo.value); const v = place.value; if (v.startsWith('ms:')) data = addMilestoneRelation(data, id, v.slice(3)); else if (v.startsWith('task:')) data = addProposalEdge(data, id, v.slice(5), 'SEQUENCE'); doc = data; selected = id; dirty = true; dialog.close(); render(); } catch (e) { error.textContent = e.message; } };
  cancel.onclick = () => dialog.close(); dialog.showModal(); title.focus();
}
$('addProposal').onclick = openProposalDialog;
$('cardOrder').onchange = () => renderCards();
function showDiff() { $('diffPanel').hidden = false; $('diff').textContent = JSON.stringify(delta(), null, 2); }
for (const name of MAP_TABS) { const tab = $(name + 'Tab'), names = MAP_TABS; tab.onclick = () => switchMap(name); tab.onkeydown = e => { if (['ArrowLeft', 'ArrowRight', 'Home', 'End'].includes(e.key)) { e.preventDefault(); let i = names.indexOf(name); i = e.key === 'Home' ? 0 : e.key === 'End' ? names.length - 1 : (i + (e.key === 'ArrowRight' ? 1 : names.length - 1)) % names.length; switchMap(names[i]); $(names[i] + 'Tab').focus(); } }; }

// @endsection
// @section editing
$('refresh').onclick = async () => {
  if (location.protocol === 'file:') { report('JSON更新にはローカルサーバーを起動し、http://127.0.0.1:8088/ を開いてください。', true); return; }
  // Refresh fetches the newest canonical; it never discards edits (OPS-082). Save first; the saved edit version is resumed after reload.
  if (dirty || formDirty) { report('未保存の変更があります。先に「編集結果を保存」してください。保存した編集版は更新しても消えず、再読込後に再開します。', true); return; }
  if (planDraftPending()) { report('カード一覧の追加欄に、まだ追加していない入力があります。追加するか消してから「更新」してください。', true); return; }
  const button = $('refresh'); button.disabled = true; button.textContent = '更新中…'; const started = JSON.stringify(doc), startedDraft = JSON.stringify(planDraft);
  // A successful regeneration is not permission to reload: edits or pending input made while waiting stay on screen (OPS-082).
  try {
    const response = await fetch('/sync', { method: 'POST', headers: { 'X-Registry-Studio': 'sync' } }); const result = await response.json(); if (!response.ok) throw Error(result.error || result.output || '更新に失敗しました。');
    if (dirty || formDirty || JSON.stringify(doc) !== started || JSON.stringify(planDraft) !== startedDraft || planDraftPending()) { report('正本の再生成は完了しました。更新を待つ間に変更があったため、画面は読み直していません。保存してからもう一度「更新」を押すと、最新の正本を表示します。', true); return; }
    window.location.reload();
  }
  catch (error) { report('更新できませんでした：' + error.message, true); }
  finally { button.disabled = false; button.textContent = '更新'; }
};
$('changes').onclick = () => { showDiff(); $('diffPanel').scrollIntoView({ behavior: 'smooth' }); };
$('open').onchange = async e => { const f = e.target.files[0]; if (!f) return; try { const d = JSON.parse(await f.text()); check(d); if (((d.source || {}).kind || 'legacy') !== (canonical.kind || 'legacy')) throw Error('形式の違うJSON（' + ((d.source || {}).kind || '旧形式') + '）は、この画面では開けません。'); if ((dirty || formDirty) && !confirm('保存前の変更を破棄して読み込みますか？')) return; const meta = d.studioSave; delete d.studioSave; canonicalStartMode(false); taskFollowCanonical = false; initializeRelationBaseline(d); doc = d; workspace = meta && meta.saveId ? { saveId: meta.saveId, series: meta.series, heads: 1 } : null; selected = d.tasks[0]?.id; dirty = false; formDirty = false; render(); } catch (err) { report('読み込めません：' + err.message, true); } finally { e.target.value = ''; } };
// Served over http (serve.py): the edited JSON goes to the server's Inbox/ for the AI; no download or attachment (OPS-082).
// Only a confirmed save clears the unsaved mark; a failure keeps the edits and is not turned into a download. file:// keeps the download.
$('save').onclick = async () => {
  try {
    if (formDirty) throw Error('入力中の変更を先に「変更を適用」で確定してください。'); check(doc); const out = copy(doc); out.exportedAt = new Date().toISOString(); out.changes = delta();
    if (location.protocol !== 'file:') {
      const button = $('save'); button.disabled = true; out.studioSave = { parent: workspace ? workspace.saveId : null }; const sent = JSON.stringify(doc); try {
        const response = await fetch('/save', { method: 'POST', headers: { 'X-Registry-Studio': 'save', 'Content-Type': 'application/json' }, body: JSON.stringify(out) }); let result = {}; try { result = await response.json(); } catch (_) { } if (!response.ok || !result.ok) throw Error(result.error || ('HTTP ' + response.status));// Only the snapshot taken at the click is saved; edits made while waiting stay unsaved.
        const later = JSON.stringify(doc) !== sent; workspace = { saveId: result.save.saveId, series: result.save.series, heads: (workspace ? workspace.heads : 1) + (result.save.branched ? 1 : 0) }; dirty = later; try { canonicalStartMode(false); } catch (e) { report('保存は完了しましたが、再開方法を更新できませんでした：' + e.message, true); return; } banner(); report((result.save.branched ? '別のタブで新しい保存があったため、別の系列として保存しました：' : 'サーバーに保存しました：') + result.folder + '/' + result.file + (later ? '　保存ボタンの後の変更はまだ未保存です。' : '　AIに「Inboxを取り込んで」と伝えてください。') + (planDraftPending() ? '　カード一覧の追加欄の入力は、まだ追加していないので保存されていません。' : ''), later || planDraftPending());
      } catch (e) { report('保存できませんでした（編集はそのまま残っています）：' + e.message, true); } finally { button.disabled = false; } return;
    }
    const a = el('a'); const url = URL.createObjectURL(new Blob([JSON.stringify(out, null, 2) + '\n'], { type: 'application/json' })); a.href = url; a.download = 'registry-edited-' + new Date().toISOString().replace(/[:.]/g, '-') + '.json'; document.body.append(a); a.click(); a.remove(); setTimeout(() => URL.revokeObjectURL(url), 60000); dirty = false; banner(); report('保存用ファイルを作成しました。ダウンロード先を確認してください。');
  } catch (e) { report(e.message, true); }
};
window.addEventListener('beforeunload', e => { if (dirty || formDirty || planDraftPending()) { e.preventDefault(); e.returnValue = ''; } }); check(doc); render();
// Resume the latest saved edit version when served (OPS-082). Skipped if the user already started editing.
let workspaceGeneration = 0;
async function resumeWorkspace() { const generation = workspaceGeneration; if (canonicalStartMode() || location.protocol === 'file:' || typeof fetch !== 'function') return; try { const response = await fetch('/workspace'); if (!response.ok) return; const result = await response.json(); const legacyLeft = result && Array.isArray(result.unresolvedLegacy) ? result.unresolvedLegacy.length : 0; const legacyNote = result && result.reconciliation === 'unknown' ? '取り込み記録が読めないため、旧形式の編集版の照合状態は不明です（この画面では再開しません・削除しません）。' : legacyLeft ? '旧形式の未照合の編集版が' + legacyLeft + '件あります（この画面では再開しません・削除しません）。' : ''; if (legacyNote) report(legacyNote); if (!result || !result.save || dirty || formDirty || generation !== workspaceGeneration) return; const d = result.save, meta = d.studioSave; if (((d.source || {}).kind || 'legacy') !== (canonical.kind || 'legacy')) { report('形式の違う編集版（' + ((d.source || {}).kind || '旧形式') + '）は再開しません。' + legacyNote, true); return; } delete d.studioSave; check(d); taskFollowCanonical = false; initializeRelationBaseline(d); doc = d; workspace = { saveId: meta.saveId, series: meta.series, heads: result.heads }; if (!graphData().nodes.some(n => n.id === selected)) selected = doc.tasks[0]?.id; render(); } catch (e) { report('保存した編集版を開けませんでした：' + e.message, true); } }
let restartInputRevision = 0;
document.addEventListener('input', () => { restartInputRevision++; });
$('restart').onclick = async () => {
  if ($('save').disabled || $('refresh').disabled) { report('保存・更新処理が終わってから、正本に戻ってください。', true); return; }
  const pending = dirty || formDirty || planDraftPending(), local = location.protocol === 'file:';
  if (!confirm((pending ? '未保存の編集と、まだ適用・追加していない入力を破棄して、' : '') + (local ? '同梱の正本' : '最新の正本・採番待ちを取得し、正本') + 'から新しく始めますか？ 保存済みの履歴は削除されません。')) return;
  const started = JSON.stringify(doc), draft = JSON.stringify(planDraft), revision = restartInputRevision;
  workspaceGeneration++; const button = $('restart'); button.disabled = true; $('save').disabled = true; $('refresh').disabled = true;
  try {
    if (!local) {
      const response = await fetch('/sync', { method: 'POST', headers: { 'X-Registry-Studio': 'sync' } }), result = await response.json();
      if (!response.ok || !result.ok) throw Error(result.error || result.output || '正本の更新に失敗しました。');
      if (JSON.stringify(doc) !== started || JSON.stringify(planDraft) !== draft || restartInputRevision !== revision) { report('取得中に編集されたため、破棄・再読込はしていません。もう一度「正本から新しく始める」で確認してください。', true); return; }
    }
    canonicalStartMode(true);
    dirty = false; formDirty = false; planDraft = { version: null, name: '', versionName: '' }; workspace = null;
    if (!local) { window.location.reload(); return; }
    doc = JSON.parse($('seed').textContent); initializeRelationBaseline(doc); selected = doc.tasks[0]?.id;
    render(); report('同梱の正本に戻しました。ファイル表示では採番待ちの最新取得はできません。');
  } catch (e) { report('正本から開始できませんでした。編集は保持しています：' + e.message, true); }
  finally { button.disabled = false; $('save').disabled = false; $('refresh').disabled = false; }
};
// Compare user-editable changes, not inherited source quotes or rewritten condition prose.
let suggestionSnapshot = null, taskSourceFailed = false;
function receiveTaskState(snapshot) {
  if (snapshot.error || !snapshot.document) {
    taskSourceFailed = true;
    report('タスクの正本を取得できません。表示と編集内容は保持しています。', true);
    return;
  }
  const latest = snapshot.document;
  check(latest);
  if (taskSourceFailed) {
    taskSourceFailed = false;
    report('タスクの正本を再び取得できました。');
  }
  if (((latest.source || {}).kind || 'legacy') !== (canonical.kind || 'legacy')) {
    report('正本の形式が変わりました。編集を保存してからページを開き直してください。', true);
    return;
  }
  suggestionSnapshot = copy(latest);
  const changed = JSON.stringify(latest) !== JSON.stringify(canonicalSnapshot);
  const protectedEdit = !taskFollowCanonical || workspace || dirty || formDirty || planDraftPending()
    || $('save').disabled || $('refresh').disabled || $('restart').disabled;
  canonical = copy(latest.source);
  canonicalSnapshot = copy(latest);
  if (changed && !protectedEdit) {
    doc = copy(latest);
    initializeRelationBaseline(doc);
    if (!graphData().nodes.some(n => n.id === selected)) selected = doc.tasks[0]?.id;
    render();
  } else {
    banner();
  }
}
function observeTaskState() {
  if (location.protocol === 'file:' || typeof EventSource !== 'function') return;
  const source = new EventSource('/task-state/events');
  source.onmessage = event => {
    try { receiveTaskState(JSON.parse(event.data)); }
    catch (error) { report('タスクの更新を表示できません：' + error.message, true); }
  };
  // EventSource reconnects and receives the latest snapshot. Local edits stay untouched.
  source.onerror = () => {};
  window.addEventListener('pagehide', () => source.close(), { once: true });
  window.addEventListener('pageshow', event => { if (event.persisted) observeTaskState(); }, { once: true });
}
$('canonicalRestartAction').onclick = () => { $('restart').click(); };
document.addEventListener('input', () => { $('canonicalRestartNotice').hidden = true; });
async function checkServerRestart() {
  if (location.protocol === 'file:' || typeof fetch !== 'function') return;
  const notice = $('serverRestartNotice');
  try {
    const response = await fetch('/server-status', { cache: 'no-store' });
    if (response.status === 404) { notice.textContent = 'サーバーの更新状態を確認できない旧バージョンです。サーバーの再起動をおすすめします。編集中の内容は先に保存してください。'; notice.hidden = false; return; }
    if (!response.ok) return;
    const status = await response.json();
    if (typeof status.restartRecommended !== 'boolean') return;
    notice.textContent = 'サーバー側のコードが更新されています。サーバーの再起動をおすすめします。編集中の内容を保存し、起動したターミナルで停止してから起動し直してください。ページの再読み込みだけでは反映されません。';
    notice.hidden = !status.restartRecommended;
  } catch (e) {/* An unreachable server is not evidence of changed code. Keep the last notice. */ }
}
checkServerRestart();
if (typeof setInterval === 'function') setInterval(checkServerRestart, 30000);
window.addEventListener('focus', checkServerRestart);

// @endsection
// @section resume
const resumed = resumeWorkspace();
resumed.finally(observeTaskState);

// @endsection
