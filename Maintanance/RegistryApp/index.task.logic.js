// Task behavior shared by the page and its tests. No page initialization.
function initializeRelationBaseline(d) { if (d.milestoneRelations && !d.baseline.milestoneRelations) d.baseline.milestoneRelations = copy(d.milestoneRelations); if (d.milestones && !d.baseline.milestones) d.baseline.milestones = copy(d.milestones); }  // milestones baseline: OPS-086

function check(d) {
  if (d.schemaVersion !== 1 || !d.source || (d.source.kind === 'v3-export' ? !(d.v3 && typeof d.source.generation === 'string' && Number.isInteger(d.source.revision) && d.source.sha256 === undefined) : typeof d.source.sha256 !== 'string') || !Array.isArray(d.tasks) || !Array.isArray(d.edges) || !d.baseline) throw Error('Registry Studio形式のJSONではありません。');
  function model(tasks, edges) {
    if (!Array.isArray(tasks) || !Array.isArray(edges)) throw Error('task/edge一覧がありません');
    const ids = new Set(); for (const t of tasks) { if (!t.id || ids.has(t.id)) throw Error('IDの欠落・重複'); ids.add(t.id); for (const f of ['id', 'state', 'owner', 'item', 'condition', 'detail', 'raw']) if (typeof t[f] !== 'string') throw Error('taskの欄が不正: ' + f); }
    const seen = new Set(), adj = new Map(tasks.map(t => [t.id, []])); for (const e of edges) { if (!ids.has(e.prerequisite) || !ids.has(e.successor) || e.prerequisite === e.successor) throw Error('依存の参照先が不正'); if (!['SEQUENCE', 'PARALLEL_JOIN'].includes(e.flow) || typeof e.constraint !== 'string') throw Error('Flowまたは条件が不正'); let k = e.prerequisite + '>' + e.successor; if (seen.has(k)) throw Error('依存の重複'); seen.add(k); adj.get(e.prerequisite).push(e.successor); }
    const done = new Set(), stack = new Set(); function walk(x) { if (stack.has(x)) throw Error('循環する依存は追加できません'); if (done.has(x)) return; stack.add(x); for (const y of adj.get(x)) walk(y); stack.delete(x); done.add(x); } tasks.forEach(t => walk(t.id));
  } const props = proposalNodes(d, true); model(d.tasks.concat(props), d.edges); model(d.baseline.tasks, d.baseline.edges);
  if ((d.baseline.proposals || []).length) throw Error('baselineに追加案は入れられません。');
  if (d.milestones !== undefined || d.milestoneRelations !== undefined) {
    if (!Array.isArray(d.milestones) || !Array.isArray(d.milestoneRelations)) throw Error('マイルストーン形式が不正');
    if (d.milestoneRelations.some(e => 'relation' in e) || (d.baseline.milestoneRelations || []).some(e => 'relation' in e)) throw Error('旧形式（線の種類あり）のJSONは読み込めません。2026-10-17に線の種類を廃止し、条件は正本の制約文へ移しました。sync.pyで作り直した現行データを使ってください。');
    for (const e of d.milestoneRelations) if (!e.source || typeof e.source.path !== 'string' || typeof e.source.quote !== 'string' || typeof e.constraint !== 'string') throw Error('到達点への接続の出典・条件が不正');
    model(d.tasks.concat(props, d.milestones), d.edges.concat(d.milestoneRelations.map(e => ({ ...e, flow: 'PARALLEL_JOIN' }))));
  }

  if (d.tasks.length !== d.baseline.tasks.length || d.tasks.some(t => !d.baseline.tasks.some(b => b.id === t.id))) throw Error('この試作ではtask追加・削除は扱いません。');
}
// Task proposals (OPS-081): drafts made in Studio before formal numbering. They live in doc.proposals, never in doc.tasks,
// so the guard against adding formal tasks stays. Draft IDs (draft-N) are lower-case and cannot collide with formal IDs;
// lines use the existing edges/milestoneRelations with conditions left 相談待ち. The importing AI assigns formal IDs.
function proposalNodes(d, validate) {
  const list = d.proposals === undefined ? [] : d.proposals; if (!Array.isArray(list)) throw Error('追加案の形式が不正です。');
  if (validate) {
    const taken = new Set(d.tasks.map(t => t.id).concat((d.milestones || []).map(m => m.id))), ids = new Set();
    for (const p of list) {
      if (!p || typeof p.id !== 'string' || !/^draft-[1-9]\d*$/.test(p.id)) throw Error('追加案の仮IDが不正です: ' + (p && p.id)); if (ids.has(p.id)) throw Error('追加案の仮IDが重複しています: ' + p.id); if (taken.has(p.id)) throw Error('追加案の仮IDが既存のIDと衝突しています: ' + p.id); ids.add(p.id);
      if (typeof p.title !== 'string' || !p.title.trim()) throw Error('追加案のタイトルが空です: ' + p.id); if (typeof p.memo !== 'string') throw Error('追加案のメモが不正です: ' + p.id);
    }
  }
  return list.map(p => ({ id: p.id, kind: 'proposal', proposal: true, item: p.title, memo: p.memo, state: '追加案', owner: '', condition: p.memo, detail: '', raw: '', sourceLine: '' }));
}
function nextProposalId(d) { let n = 0; for (const p of d.proposals || []) { const m = /^draft-(\d+)$/.exec(p.id); if (m) n = Math.max(n, +m[1]); } return 'draft-' + (n + 1); }
function addProposal(data, title, memo) { const c = JSON.parse(JSON.stringify(data)); const id = nextProposalId(c); c.proposals = (c.proposals || []).concat([{ id, title: String(title || '').trim(), memo: String(memo || '') }]); check(c); return { data: c, id }; }
function updateProposal(data, id, title, memo) { const c = JSON.parse(JSON.stringify(data)), p = (c.proposals || []).find(p => p.id === id); if (!p) throw Error('追加案が見つかりません: ' + id); p.title = String(title || '').trim(); p.memo = String(memo || ''); check(c); return c; }
function removeProposal(data, id) {
  const c = JSON.parse(JSON.stringify(data)); if (!(c.proposals || []).some(p => p.id === id)) throw Error('追加案が見つかりません: ' + id); const touches = e => e.prerequisite === id || e.successor === id;
  c.proposals = c.proposals.filter(p => p.id !== id); if (!c.proposals.length) delete c.proposals; c.edges = c.edges.filter(e => !touches(e)); if (c.milestoneRelations) c.milestoneRelations = c.milestoneRelations.filter(e => !touches(e)); check(c); return c;
}
function addProposalEdge(data, prerequisite, successor, flow) { const c = JSON.parse(JSON.stringify(data)); c.edges.push({ prerequisite, successor, flow: flow || 'SEQUENCE', constraint: '', conditionReview: '相談待ち', raw: null, sourceLine: null }); check(c); return c; }
// Milestone plan (OPS-086 trial): the edit version reorganizes milestones in place. A card's `gate` becomes its planned file path
// (move = other folder, reorder = renumbered file names, since DESIGN orders cards by file name); IDs and task lines stay.
// The generated backbone lines (source Milestones/README) of the touched versions are rebuilt START → cards → END.
// New cards (draft-ms-N) and new versions are marked planned; nothing is written to Milestones/ or the Registry.
const PLAN_DIR = 'Maintanance/Milestones/', PLAN_SOURCE = 'Maintanance/Milestones/README.md'; const PLAN_SOURCE_FILE = PLAN_SOURCE;
function planClone(d) { return JSON.parse(JSON.stringify(d)); }
function planParts(m) { const f = /^Maintanance\/Milestones\/([^/_][^/]*)\/([^/]+\.md)$/.exec(m.gate || ''); return f && !m.virtual && !f[2].startsWith('GATE-') && f[2] !== 'GOAL.md' ? { version: f[1], file: f[2] } : null; }
function planCards(d, version) { return (d.milestones || []).filter(m => planParts(m) && planParts(m).version === version).sort((a, b) => planParts(a).file < planParts(b).file ? -1 : planParts(a).file > planParts(b).file ? 1 : 0); }
function planVersions(d) { return (d.milestones || []).filter(m => m.virtual && m.id.startsWith('START-')).map(m => m.id.slice(6)); }
function planRenumber(d, version, ordered) { ordered.forEach((m, i) => { const rest = planParts(m).file.replace(/^\d+_/, ''); m.gate = PLAN_DIR + version + '/' + String((i + 1) * 10).padStart(2, '0') + '_' + rest; m.condition = (m.condition || '').replace(/^ゲート：[^\n]*/, 'ゲート：' + m.gate + '（編集案・未反映）'); }); }
function planRebuild(d, versions) {
  const PLAN_SOURCE = (d.source && d.source.kind === 'v3-export') ? 'v3-db:skeleton' : PLAN_SOURCE_FILE;
  const template = (d.milestoneRelations || []).find(r => r.source && r.source.path === PLAN_SOURCE) || { constraint: '接続はゲートの配置から生成。条件は各カードの本文。', source: { path: PLAN_SOURCE, quote: '' } };
  // Drop every generated line among the touched versions' nodes in one pass (a moved card leaves its old version), then rebuild their chains.
  const chains = [...new Set(versions)].map(v => ['START-' + v, ...planCards(d, v).map(m => m.id), 'END-' + v]), touched = new Set(chains.flat());
  d.milestoneRelations = d.milestoneRelations.filter(r => !(r.source && r.source.path === PLAN_SOURCE && touched.has(r.prerequisite) && touched.has(r.successor)));
  for (const chain of chains) for (let i = 0; i + 1 < chain.length; i++)d.milestoneRelations.push({ prerequisite: chain[i], successor: chain[i + 1], constraint: template.constraint, source: { ...template.source } });
}
function planCard(d, id) { const m = (d.milestones || []).find(m => m.id === id); if (!m || !planParts(m)) throw Error('途中のカードではありません: ' + id); return m; }
function planEditText(data, id, item, condition) {
  const d = planClone(data), m = planCard(d, id); if (typeof item !== 'string' || !item.trim()) throw Error('カードの名前が空です。'); m.item = item.trim();
  if (typeof condition === 'string' && condition.trim()) m.planCondition = condition; else delete m.planCondition; check(d); return d;
}
function planReorder(data, id, step) {
  const d = planClone(data), m = planCard(d, id), v = planParts(m).version, list = planCards(d, v), i = list.indexOf(m), j = i + step;
  if (j < 0 || j >= list.length) throw Error('これ以上動かせません。');[list[i], list[j]] = [list[j], list[i]]; planRenumber(d, v, list); planRebuild(d, [v]); check(d); return d;
}
function planMove(data, id, version) {
  const d = planClone(data), m = planCard(d, id), from = planParts(m).version; if (!planVersions(d).includes(version)) throw Error('版がありません: ' + version); if (from === version) throw Error('同じ版です。');
  const rest = planParts(m).file; m.gate = PLAN_DIR + version + '/' + rest; planRenumber(d, from, planCards(d, from)); planRenumber(d, version, [...planCards(d, version).filter(x => x !== m), m]); planRebuild(d, [from, version]); check(d); return d;
}
function planAddCard(data, version, item, condition) {
  const d = planClone(data); if (!planVersions(d).includes(version)) throw Error('版がありません: ' + version); if (typeof item !== 'string' || !item.trim()) throw Error('カードの名前が空です。');
  let n = 0; for (const m of d.milestones) { const x = /^draft-ms-(\d+)$/.exec(m.id); if (x) n = Math.max(n, +x[1]); } const id = 'draft-ms-' + (n + 1);
  const m = { id, kind: 'milestone', item: item.trim(), state: 'ACTIVE', owner: 'ユーザー同席（AI単独では扱わない）', condition: '', detail: '', raw: '', gate: PLAN_DIR + version + '/DRAFT_MS_' + (n + 1) + '.md', planned: true }; if (typeof condition === 'string' && condition.trim()) m.planCondition = condition;
  d.milestones.push(m); planRenumber(d, version, [...planCards(d, version).filter(x => x !== m), m]); planRebuild(d, [version]); check(d); return { data: d, id };
}
function planAddVersion(data, name) {
  const d = planClone(data); name = String(name || '').trim();
  if (!/^[0-9A-Za-z][0-9A-Za-z.\-]*$/.test(name)) throw Error('版の名前は英数字・点・ハイフンで、先頭は英数字にしてください。');
  if (new Set((d.milestones || []).map(m => (m.gate || '').split('/')[2])).has(name)) throw Error('その版はすでにあります: ' + name);
  const v = (id) => ({ id, kind: 'milestone', item: id, state: 'ACTIVE', owner: '', condition: '', raw: '', detail: PLAN_SOURCE, gate: PLAN_DIR + name + '/', virtual: true, planned: true });
  d.milestones.push(v('START-' + name), v('END-' + name)); planRebuild(d, [name]); check(d); return d;
}
function milestonePlanChanges(d) {
  if (!d.baseline || !d.baseline.milestones) return [];  // no milestone baseline yet: nothing has been planned
  const before = new Map(d.baseline.milestones.map(m => [m.id, m])), out = [];
  for (const m of d.milestones || []) {
    const b = before.get(m.id); if (!b) { out.push({ change: 'added', id: m.id, item: m.item, gate: m.gate, virtual: !!m.virtual, planCondition: m.planCondition }); continue; }
    if (b.gate !== m.gate) { const pv = planParts(b), nv = planParts(m); out.push({ change: pv && nv && pv.version === nv.version ? 'reordered' : 'moved', id: m.id, from: b.gate, to: m.gate }); }
    if (b.item !== m.item) out.push({ change: 'renamed', id: m.id, from: b.item, to: m.item });
    if (m.planCondition !== undefined && m.planCondition !== b.planCondition) out.push({ change: 'condition', id: m.id, to: m.planCondition });
  }
  return out;
}
function stateStyle(state) {
  const colors = { ACTIVE: ['#b9dfc8', '#17523d'], WAITING_USER: ['#dfc5ed', '#63427c'], WAITING_EXTERNAL: ['#dceafa', '#244e7b'], FROZEN: ['#f3f4f5', '#68717d'], USER_ONLY: ['#f5e0ef', '#7b3e6a'], PROPOSED: ['#e6f2e9', '#42654d'], DONE: ['#e9e6e2', '#625a50'], EXCLUDED: ['#e9e6e2', '#625a50'], ARCHIVED: ['#ffffff', '#565656'], '追加案': ['#fff4d6', '#7a5600'] };
  const [bg, fg] = colors[state] || ['#ece9dc', '#5f5940']; return { bg, fg };
}
// The state band drawn from a view model's band ({text, bg, fg}); no color is decided here.
function bandView(band) { const b = el('span', band.text, 'state-band'); b.style.background = band.bg; b.style.color = band.fg; return b; }
function stateBandModel(state) { const c = stateStyle(state); return { text: state, bg: c.bg, fg: c.fg }; }
function stateBand(state) { const b = el('span', state, 'state-band'); const c = stateStyle(state); b.style.background = c.bg; b.style.color = c.fg; return b; }

function delta() { let result = []; for (const t of doc.tasks) { let b = doc.baseline.tasks.find(x => x.id === t.id); for (const k of ['state', 'owner', 'item', 'condition']) if (t[k] !== b[k]) result.push({ task: t.id, field: k, old: b[k], new: t[k] }); } if (JSON.stringify(doc.edges) !== JSON.stringify(doc.baseline.edges)) result.push({ field: 'edges', old: doc.baseline.edges, new: doc.edges }); if (JSON.stringify(doc.milestoneRelations || []) !== JSON.stringify(doc.baseline.milestoneRelations || doc.milestoneRelations || [])) result.push({ field: 'milestoneRelations', old: doc.baseline.milestoneRelations, new: doc.milestoneRelations }); if (JSON.stringify(doc.proposals || []) !== JSON.stringify(doc.baseline.proposals || [])) result.push({ field: 'proposals', old: doc.baseline.proposals || [], new: doc.proposals || [] }); const plan = typeof milestonePlanChanges === 'function' ? milestonePlanChanges(doc) : []; if (plan.length) result.push({ field: 'milestones', changes: plan }); return result; }

function canonicalDifferences(base, current, latest) {
  const rows = [];
  const groups = [['tasks', 'タスク', ['item', 'state', 'owner', 'condition', 'detail']], ['milestones', 'マイルストーン', ['item', 'state', 'owner', 'condition', 'detail', 'gate', 'version', 'name', 'path']], ['edges', '依存', ['flow', 'constraint']], ['milestoneRelations', '接続', ['constraint']]];
  const equal = (a, b) => JSON.stringify(a ?? null) === JSON.stringify(b ?? null);
  for (const [group, label, fields] of groups) {
    if (!Array.isArray(base[group])) { if ((latest[group] || []).length) rows.push({ label: label + '：保存版に比較用の土台がありません', unknown: true }); continue; }
    const key = x => x.id || x.prerequisite + ' → ' + x.successor;
    const map = xs => new Map((xs || []).map(x => [key(x), x]));
    const b = map(base[group]), u = map(current[group]), n = map(latest[group]);
    const value = x => x ? fields.map(k => x[k] ?? null) : null;
    for (const id of new Set([...b.keys(), ...n.keys()])) {
      const before = b.get(id), now = n.get(id), edit = u.get(id);
      if (equal(value(before), value(now))) continue;
      const changed = before && now ? fields.filter(k => !equal(before[k], now[k])) : [];
      const conflict = before && now && edit ? changed.some(k => !equal(edit[k], before[k]) && !equal(edit[k], now[k])) : !equal(value(edit), value(before)) && !equal(value(edit), value(now));
      rows.push({ label: label + ' ' + id + ' ' + (!before ? '追加' : !now ? '削除' : '変更'), conflict, changes: changed.map(k => ({ field: k, before: before[k] ?? null, after: now[k] ?? null })), title: now?.item || before?.item || '' });
    }
  }
  return rows;
}

function protectionRecords(data) {
  const records = [];
  for (const task of data.tasks) {
    const marks = [...task.detail.matchAll(/`([^`]+)`（配置維持; /g)];
    for (let i = 0; i < marks.length; i++) {
      const m = marks[i], tail = task.detail.slice(m.index + m[0].length, marks[i + 1]?.index ?? task.detail.length), end = tail.lastIndexOf('）');
      if (end < 0) continue;
      const body = tail.slice(0, end), reasonAt = body.indexOf('理由='), fields = {};
      const metadata = reasonAt < 0 ? body : body.slice(0, reasonAt);
      for (const part of metadata.split('; ')) { const eq = part.indexOf('='); if (eq > 0) fields[part.slice(0, eq)] = part.slice(eq + 1); }
      if (reasonAt >= 0) fields['理由'] = body.slice(reasonAt + 3);
      records.push({ path: m[1], task: task.id, ...fields });
    }
  }
  return records;
}
function protectionDays(start, today) {
  if (start === '不明' || start == null || start === '') return '不明';
  const valid = s => /^\d{4}-\d{2}-\d{2}$/.test(s) && Number.isFinite(Date.parse(s + 'T00:00:00Z')) && new Date(s + 'T00:00:00Z').toISOString().slice(0, 10) === s;
  if (!valid(start) || !valid(today)) return '日付要確認';
  const days = (Date.parse(today + 'T00:00:00Z') - Date.parse(start + 'T00:00:00Z')) / 86400000;
  return days < 0 ? '日付要確認' : (days + 1) + '日目';
}

function taskDocumentPaths(t) { return [...new Set([...t.detail.matchAll(/(?:Maintanance|Sources|Tests)\/[^`\s|]+?\.md/g)].map(m => m[0]))]; }

function graphData() {
  // END-xyz is not drawn: lines into an END are drawn into the release gate it leads to (2026-10-17).
  // START-xyz is not drawn either when a release gate precedes it: the gate stands for both the END before it and the START after it,
  // and lines out of the START are drawn out of that gate (2026-10-18, OPS-069 step 3). Data keeps START/END; shownFor/shownFrom are display-only.
  const ms = doc.milestones || [], ends = new Map(), starts = new Map();
  for (const e of doc.milestoneRelations || []) { if (e.prerequisite.startsWith('END-') && e.successor.startsWith('GATE-')) ends.set(e.prerequisite, e.successor); if (e.prerequisite.startsWith('GATE-') && e.successor.startsWith('START-')) starts.set(e.successor, e.prerequisite); }
  const hidden = new Set(ms.filter(m => m.id.startsWith('END-') || (m.id.startsWith('START-') && starts.has(m.id))).map(m => m.id));
  const asMilestone = !ms.some(m => m.id === 'MS-QUALITY');  // older data drew QUALITY-001 as the 1.0 milestone; MS-QUALITY now plays that part
  const nodes = doc.tasks.map(t => asMilestone && t.id === 'QUALITY-001' ? { ...t, kind: 'milestone', item: '1.0 品質判断' } : t).concat(proposalNodes(doc), ms.filter(m => !hidden.has(m.id)));
  const rel = []; for (const e of doc.milestoneRelations || []) {
    const out = { ...e };
    if (hidden.has(e.prerequisite)) { const from = starts.get(e.prerequisite); if (!from) continue; out.prerequisite = from; out.shownFrom = e.prerequisite; }
    if (hidden.has(e.successor)) { const to = ends.get(e.successor); if (!to) continue; out.successor = to; out.shownFor = e.successor; }
    rel.push(out);
  }
  const edges = doc.edges.concat(rel.map(e => ({ ...e, flow: 'PARALLEL_JOIN' })));  // one kind of line: the relation is the location, conditions live in the constraint text
  return { nodes, edges };
}
// `source` is the edit version the milestones come from (the page passes nothing and gets the open `doc`).
function versionFolders(source = doc) {
  const seen = []; for (const m of source.milestones || []) { const f = (m.gate || '').split('/')[2]; if (f && !seen.includes(f)) seen.push(f); } return seen;
}
function versionView(data, v, source = doc) {
  // One version folder (or '@head': HEAD and every later folder): its gates and release gate, plus every
  // task upstream of them. Earlier versions are not shown; only the release gate knows where a version goes.
  if (!v) return data;
  const folders = versionFolders(source), from = folders.indexOf(source.milestoneHead);
  const wanted = new Set(v === '@head' ? (from < 0 ? folders : folders.slice(from)) : [v]);
  const keep = new Set(data.nodes.filter(n => n.kind === 'milestone' && wanted.has((n.gate || '').split('/')[2])).map(n => n.id));
  const ms = new Set(data.nodes.filter(n => n.kind === 'milestone' && n.gate).map(n => n.id));
  for (let grew = true; grew;) { grew = false; for (const e of data.edges) if (keep.has(e.successor) && !keep.has(e.prerequisite) && !ms.has(e.prerequisite)) { keep.add(e.prerequisite); grew = true; } }
  // Start-side work (OPS-069): tasks downstream of a wanted START, and their downstream task chains, stay in the view.
  // The START itself is drawn as the release gate before it (which sits in the previous folder), so that gate is kept too — after the
  // upstream closure above, so the previous version's tasks are not pulled in with it.
  const starts = new Set((source.milestones || []).filter(m => m.id.startsWith('START-') && wanted.has((m.gate || '').split('/')[2])).map(m => m.id));
  for (const e of data.edges) if (starts.has(e.shownFrom) && data.nodes.some(n => n.id === e.prerequisite)) keep.add(e.prerequisite);
  for (let grew = true; grew;) { grew = false; for (const e of data.edges) if (keep.has(e.prerequisite) && !keep.has(e.successor) && !ms.has(e.successor) && (starts.has(e.shownFrom) || !/^(END|GATE)-/.test(e.prerequisite))) { keep.add(e.successor); grew = true; } }  // tasks after a START or an intermediate card (OPS-084) stay in the view
  // A downstream task can have additional task prerequisites. Close the task component
  // after milestone seeding, without crossing into milestones from other versions.
  for (let grew = true; grew;) {
    grew = false; for (const e of data.edges) {
      if (ms.has(e.prerequisite) || ms.has(e.successor)) continue;
      if (keep.has(e.prerequisite) || keep.has(e.successor)) for (const id of [e.prerequisite, e.successor]) if (!keep.has(id)) { keep.add(id); grew = true; }
    }
  }
  return { nodes: data.nodes.filter(n => keep.has(n.id)), edges: data.edges.filter(e => keep.has(e.prerequisite) && keep.has(e.successor)) };
}

function graphLayout(tasks, edges) {
  const W = 250, H = 96, gutter = 45, step = W + gutter, row = H + 20, drop = H + 40, golden = W * (3 - Math.sqrt(5)) / 2;
  // Derive the backbone from milestone-only edges; stable input order breaks ties.
  const milestone = new Set(tasks.filter(t => t.kind === 'milestone').map(t => t.id));
  const paths = new Map();
  function longest(id) { if (paths.has(id)) return paths.get(id); let best = []; for (const e of edges.filter(e => e.prerequisite === id && milestone.has(e.successor))) { const p = longest(e.successor); if (p.length > best.length) best = p; } const result = [id, ...best]; paths.set(id, result); return result; }
  let backbone = []; for (const id of milestone) { const p = longest(id); if (p.length > backbone.length) backbone = p; }
  // Classify non-backbone weak components by their backbone entrances/exits.
  const nonBackbone = new Set(tasks.map(t => t.id).filter(id => !backbone.includes(id))), horizontal = new Set(), branches = [];
  while (nonBackbone.size) {
    const component = new Set(), queue = [nonBackbone.values().next().value]; while (queue.length) { const id = queue.pop(); if (!nonBackbone.delete(id)) continue; component.add(id); for (const e of edges) { if (e.prerequisite === id && nonBackbone.has(e.successor)) queue.push(e.successor); if (e.successor === id && nonBackbone.has(e.prerequisite)) queue.push(e.prerequisite); } }
    const starts = edges.filter(e => backbone.includes(e.prerequisite) && component.has(e.successor)).map(e => backbone.indexOf(e.prerequisite));
    const ends = edges.filter(e => component.has(e.prerequisite) && backbone.includes(e.successor)).map(e => backbone.indexOf(e.successor));
    const kind = starts.length ? (ends.length ? 'route' : 'escape') : (ends.length ? 'feeder' : 'isolated');
    const forward = starts.length && ends.length && Math.max(...starts) < Math.min(...ends);
    if (kind === 'route' && forward) for (const id of component) horizontal.add(id);
    branches.push({ ids: [...component], kind, forward: Boolean(forward) });
  }
  const outgoing = new Map(tasks.map(t => [t.id, edges.filter(e => e.prerequisite === t.id).map(e => e.successor)]));
  const groups = backbone.map(anchor => ({ anchor, below: [], route: [], escape: [] }));
  const groupById = new Map(groups.map(g => [g.anchor, g]));
  const leadGroup = { below: [], route: [], escape: [] };
  // Distance to the first backbone destination determines the column before it.
  function destinations(id, seen = new Set()) {
    if (backbone.includes(id)) return [{ index: backbone.indexOf(id), distance: 0 }];
    if (seen.has(id)) return []; const next = new Set(seen); next.add(id);
    return (outgoing.get(id) || []).flatMap(to => destinations(to, next).map(d => ({ ...d, distance: d.distance + ((edges.find(e => e.prerequisite === id && e.successor === to)?.flow === 'SEQUENCE' && !milestone.has(to)) ? 0 : 1) })));
  }
  const ranking = new Map();
  for (const t of tasks) {
    if (groupById.has(t.id)) continue;
    const targets = destinations(t.id).sort((a, b) => a.index - b.index || b.distance - a.distance);
    if (targets.length) {
      const target = targets[0], index = target.index - (horizontal.has(t.id) ? 1 : target.distance), g = index < 0 ? leadGroup : groups[index];
      if (!g) continue; ranking.set(t.id, target.distance);
      if (milestone.has(t.id) && !g.header) g.header = t.id;
      else (horizontal.has(t.id) ? g.route : g.below).push(t.id);
    } else {
      // A branch without a later join can use an upper escape lane. This has no
      // task-status meaning; it avoids routing through the lower joining branches.
      const source = edges.find(e => e.successor === t.id && groupById.has(e.prerequisite));
      if (source) groupById.get(source.prerequisite).escape.push(t.id);
    }
  }
  // A task that never reaches the backbone but follows a task in a lower column (a later task after a feeder) continues
  // that column below its prerequisites, in the rightmost such column (OPS-116). Left unplaced, it made the whole map fall back.
  const escapeIds = new Set(branches.filter(b => b.kind === 'escape').flatMap(b => b.ids)), allGroups = [leadGroup, ...groups];
  const listed = id => allGroups.some(g => g.header === id || g.below.includes(id) || g.route.includes(id) || g.escape.includes(id));
  for (let changed = true; changed;) {
    changed = false;
    for (const t of tasks) {
      if (groupById.has(t.id) || escapeIds.has(t.id) || listed(t.id)) continue;
      const homes = edges.filter(e => e.successor === t.id).map(e => allGroups.findIndex(g => g.below.includes(e.prerequisite))).filter(i => i >= 0);
      if (homes.length) { allGroups[Math.max(...homes)].below.push(t.id); changed = true; }
    }
  }
  function reaches(a, b, seen = new Set()) { if (a === b) return true; if (seen.has(a)) return false; seen.add(a); return (outgoing.get(a) || []).some(n => reaches(n, b, seen)); }
  function chainOrder(ids) {
    const remaining = new Set(ids), ordered = [];
    function visit(id) { if (!remaining.has(id)) return; if (ids.some(p => remaining.has(p) && p !== id && reaches(p, id))) return; remaining.delete(id); ordered.push(id); for (const next of outgoing.get(id) || []) if (ids.includes(next)) visit(next); }
    while (remaining.size) { const before = remaining.size;[...remaining].sort((a, b) => Number((outgoing.get(b) || []).some(n => remaining.has(n))) - Number((outgoing.get(a) || []).some(n => remaining.has(n)))).forEach(visit); if (before === remaining.size) break; }
    return ordered;
  }
  for (const g of [leadGroup, ...groups]) { g.below = chainOrder(g.below); g.route = chainOrder(g.route); }

  const used = new Set(edges.flatMap(e => [e.prerequisite, e.successor])), pos = new Map();
  const nodes = tasks.filter(t => used.has(t.id));
  // A group that starts at one milestone stays with it (OPS-096, TASK_REGISTRY_APP.md「途中マイルストーンから始まるタスク群の配置」).
  // A lone card keeps the upper lane; a group with more cards (a chain, outside prerequisites) is stacked in dependency
  // order below, at the same horizontal offset `lane`, so lines from other prerequisites stay between their real ends.
  // Groups started from several milestones keep the later layout (priority undecided).
  const lane = step, assigned = new Set([leadGroup, ...groups].flatMap(g => [g.header, ...g.below, ...g.route, ...g.escape]));
  for (const branch of branches.filter(b => b.kind === 'escape')) {
    const ids = branch.ids.filter(id => used.has(id)); if (!ids.some(id => !assigned.has(id))) continue;
    const origins = [...new Set(edges.filter(e => !ids.includes(e.prerequisite) && ids.includes(e.successor)).map(e => e.prerequisite))];
    if (origins.length !== 1 || !groupById.has(origins[0])) continue;
    const g = groupById.get(origins[0]); g.escape = g.escape.filter(id => !ids.includes(id)); g.stack = (g.stack || []).concat(chainOrder(ids));
  }
  let x = 20;
  // A feeder into the first milestone needs space before the backbone.
  // Keep its chain vertical in a leading column rather than clamping it onto column zero.
  const leading = [leadGroup.header, ...leadGroup.below, ...leadGroup.route].filter(id => used.has(id));
  if (leading.length) { leading.forEach((id, i) => pos.set(id, [x, 185 + drop + i * row])); x += step; }
  for (const [k, group] of groups.entries()) {
    if (!used.has(group.anchor)) continue;
    const y = 185, below = (group.below || []).filter(id => used.has(id)), above = (group.escape || []).filter(id => used.has(id)), route = (group.route || []).filter(id => used.has(id));
    pos.set(group.anchor, [x, y]);
    const header = used.has(group.header); if (header) pos.set(group.header, [x, y + row]);
    below.forEach((id, i) => pos.set(id, [x + golden, y + (header ? row : 0) + drop + i * row]));
    above.forEach((id, i) => pos.set(id, [x + lane, y - 130 - i * row]));
    route.forEach((id, i) => pos.set(id, [x + step * (i + 1), y + drop]));
    const stack = group.stack || [];
    if (stack.length) { const top = Math.max(y, ...[...pos.values()].filter(p => p[0] < x + lane + W && p[0] + W > x + lane).map(p => p[1])) + drop; stack.forEach((id, i) => pos.set(id, [x + lane, top + i * row])); }
    // Routes reserve their columns. Upper branches share the next milestone's span.
    let advance = route.length ? step * (route.length + 1) : above.length ? step + golden : step * 1.5;
    // A lower stack widens only this gap, as far as the next milestone's lower cards (header or below column) need.
    const next = groups.slice(k + 1).find(g => used.has(g.anchor));
    const nextLower = !next ? null : used.has(next.header) ? 0 : next.below.some(id => used.has(id)) ? golden : null;
    if (stack.length && nextLower !== null) advance = Math.max(advance, lane + step - nextLower);
    x += advance;
  }
  // A terminal milestone branch may also have its own prerequisite tasks.
  // Lay out that whole branch below the backbone instead of leaving its feeders unplaced.
  for (const branch of branches.filter(b => b.kind === 'escape' && b.ids.some(id => used.has(id) && !pos.has(id)))) {
    const ids = new Set(branch.ids.filter(id => used.has(id))), depth = new Map([...ids].map(id => [id, 0]));
    for (let i = 0; i < ids.size; i++)for (const e of edges) if (ids.has(e.prerequisite) && ids.has(e.successor)) depth.set(e.successor, Math.max(depth.get(e.successor), depth.get(e.prerequisite) + 1));
    const entrances = edges.filter(e => !ids.has(e.prerequisite) && ids.has(e.successor));
    const start = Math.max(20, ...entrances.map(e => (pos.get(e.prerequisite)?.[0] || 20) + step));
    for (const id of ids) pos.delete(id);
    const span = Math.max(...[...ids].map(id => depth.get(id))), left = start, right = start + span * step + W;
    const top = Math.max(185, ...[...pos.entries()].filter(([, p]) => p[0] < right && p[0] + W > left).map(([, p]) => p[1])) + drop, counts = new Map();
    for (const id of chainOrder([...ids])) { const col = depth.get(id), n = counts.get(col) || 0; pos.set(id, [start + col * step, top + n * row]); counts.set(col, n + 1); }
  }
  // Disconnected task chains occupy a separate row below the milestone map.
  const detached = nodes.filter(t => !pos.has(t.id)), detachedIds = new Set(detached.map(t => t.id));
  if (pos.size && detached.length && !edges.some(e => detachedIds.has(e.prerequisite) !== detachedIds.has(e.successor))) {
    const depth = new Map(detached.map(t => [t.id, 0]));
    for (let i = 0; i < detached.length; i++)for (const e of edges) if (detachedIds.has(e.successor)) depth.set(e.successor, Math.max(depth.get(e.successor), depth.get(e.prerequisite) + 1));
    const top = Math.max(...[...pos.values()].map(p => p[1])) + drop, counts = new Map();
    for (const t of detached) { const col = depth.get(t.id), n = counts.get(col) || 0; pos.set(t.id, [20 + col * step, top + n * row]); counts.set(col, n + 1); }
  }
  // Unknown/new groups get a dependency-ranked layout; fall back as a whole if
  // rewiring would make the presentation groups misleading or overlap cards.
  function valid() {
    if (pos.size !== nodes.length) return false;
    for (const e of edges) { const a = pos.get(e.prerequisite), b = pos.get(e.successor); if (!(a[0] < b[0] || (a[0] === b[0] && a[1] < b[1]))) return false; }
    const rects = [...pos.values()]; for (let i = 0; i < rects.length; i++)for (let j = 0; j < i; j++)if (Math.abs(rects[i][0] - rects[j][0]) < W && Math.abs(rects[i][1] - rects[j][1]) < H) return false;
    return true;
  }
  let fallback = !valid();
  if (fallback) {
    pos.clear(); const depth = new Map(nodes.map(t => [t.id, 0]));
    for (let i = 0; i < nodes.length; i++)for (const e of edges) depth.set(e.prerequisite, Math.max(depth.get(e.prerequisite), depth.get(e.successor) + 1));
    const max = Math.max(0, ...depth.values()), counts = new Map();
    for (const t of nodes) { const col = max - depth.get(t.id), n = counts.get(col) || 0; pos.set(t.id, [20 + col * step, 185 + n * row]); counts.set(col, n + 1); }
  }
  return { pos, fallback, backbone, branches, offset: 0, hasIsolated: false, hasEdges: edges.length > 0, width: Math.max(900, ...[...pos.values()].map(p => p[0] + step)), height: Math.max(180, ...[...pos.values()].map(p => p[1] + H + 34)) };
}

function independentGroups(data) {
  // Grouped by state color in the STATES order, Registry order within a color (2026-10-17).
  const ORDER = typeof STATES !== 'undefined' ? STATES : ['ACTIVE', 'WAITING_USER', 'WAITING_EXTERNAL', 'FROZEN', 'USER_ONLY', 'PROPOSED', 'DONE', 'EXCLUDED', 'ARCHIVED'];
  const stateRank = s => { const r = ORDER.indexOf(s); return r < 0 ? ORDER.length : r; };
  // Placement (OPS-095, TASK_REGISTRY_APP.md「タスク配置の要求」): outside the permanent tree, a task with any line — a task
  // dependency or a milestone connection — belongs on the dependency map (including groups not connected to a milestone);
  // only tasks without lines go to the independent strip. 「独立」 means no lines, not "not connected to a milestone".
  // The version filter only hides lines and does not move a task here.
  const links = data.edges.concat(data.milestoneRelations || []);
  const used = new Set(links.flatMap(e => [e.successor, e.prerequisite]));
  const permanentIds = new Set(data.tasks.filter(t => t.permanent).map(t => t.id));
  // Sub-tasks at any depth under a permanent task are drawn in the permanent map (2026-10-17, OPS-070 children).
  const byId = new Map(data.tasks.map(t => [t.id, t]));
  const underPermanent = t => { const seen = new Set(); for (let p = t.parentTask; p && !seen.has(p); p = byId.get(p)?.parentTask) { if (permanentIds.has(p)) return true; seen.add(p); } return false; };
  const regular = data.tasks.filter(t => !t.permanent && !used.has(t.id) && !underPermanent(t));
  // Task proposals (OPS-081) follow the same rule.
  const proposals = (typeof proposalNodes === 'function' ? proposalNodes(data) : []).filter(p => !used.has(p.id));
  return { regular: regular.sort((a, b) => stateRank(a.state) - stateRank(b.state)).concat(proposals), permanent: data.tasks.filter(t => t.permanent && !used.has(t.id)) };
}

function permanentMapData(data) {
  const kids = id => data.tasks.filter(t => t.parentTask === id).sort((a, b) => Number(a.state === 'DONE') - Number(b.state === 'DONE')).map(child => ({ ...child, documents: taskDocumentPaths(child) }));
  // descendants: depth-first, each sub-task followed by its own sub-tasks (depth 0 = direct child).
  const walk = (id, depth, seen) => kids(id).flatMap(c => seen.has(c.id) ? [] : [{ ...c, depth }, ...walk(c.id, depth + 1, new Set([...seen, c.id]))]);
  return data.tasks.filter(t => t.permanent).map(task => ({ task, children: kids(task.id), descendants: walk(task.id, 0, new Set([task.id])), documents: taskDocumentPaths(task) }));
}  // sub-tasks keep their own canonical documents (2026-10-17, OPS-064)
// Card list (OPS-085): every formal task, milestone and proposal of the loaded edit version, independent of lines and version views.
function cardListGroups(data, mode = "grouped") {
  if (mode === "id") {
    const groups = new Map();
    const cards = [...(data.tasks || []), ...(data.milestones || []), ...(typeof proposalNodes === 'function' ? proposalNodes(data) : [])].sort((a, b) => a.id < b.id ? -1 : a.id > b.id ? 1 : 0);
    for (const card of cards) { const prefix = card.id.split('-')[0]; if (!groups.has(prefix)) groups.set(prefix, []); groups.get(prefix).push(card); }
    return [...groups].map(([title, cards]) => ({ title, cards }));
  }
  const done = new Set(['DONE', 'EXCLUDED', 'ARCHIVED']), user = new Set(['WAITING_USER', 'USER_ONLY']), tasks = data.tasks || [];
  return [['マイルストーン', data.milestones || []], ['恒久タスク', tasks.filter(t => t.permanent)], ['ユーザー判断', tasks.filter(t => !t.permanent && user.has(t.state))], ['タスク（未完了）', tasks.filter(t => !t.permanent && !done.has(t.state) && !user.has(t.state))], ['完了・除外', tasks.filter(t => !t.permanent && done.has(t.state))], ['追加案', typeof proposalNodes === 'function' ? proposalNodes(data) : []]].map(([title, cards]) => ({ title, cards: [...cards].sort((a, b) => a.id < b.id ? -1 : a.id > b.id ? 1 : 0) }));
}
// Only documents bundled with this page are offered; proposals have none (their canonical documents are made at import).
function cardDocumentPaths(t, bundle) { return t.proposal ? [] : taskDocumentPaths(t).filter(p => bundle && bundle.files && bundle.files[p]); }
// Pure: the card list (OPS-154). Group headings with counts, and per card its class, heading, text, state and documents.
function cardListViewModel(groups, selected, documentPaths) {
  return {
    count: groups.reduce((n, g) => n + g.cards.length, 0) + '件', groups: groups.filter(g => g.cards.length).map(g => ({
      heading: g.title + '（' + g.cards.length + '件）', cards: g.cards.map(t => ({
        id: t.id, selected: selected === t.id,
        className: 'task' + (selected === t.id ? ' selected' : '') + (t.proposal ? ' proposal' : ''), heading: t.id + (t.planned ? ' · 計画案' : t.kind === 'milestone' ? ' · 到達点' : t.proposal ? ' · 追加案' : t.permanent ? ' · 常設' : ''),
        text: (t.item || '').replace(/^\[(EXECUTION|DISCOVERY|DECISION)\]\s*/, ''), state: t.state || '', band: stateBandModel(t.state || ''), paths: documentPaths(t)
      }))
    }))
  };
}
function renderCards() {
  drawCardList($('cardList'), $('cardsCount'), cardListViewModel(cardListGroups(doc, $('cardOrder').value), selected, t => cardDocumentPaths(t, documentBundle)), { select, openDocument, openDocuments: (id, paths) => { const dialog = $('documentDialog'); $('documentTitle').textContent = id + ' の正本'; $('documentStamp').textContent = '読む文書を選択してください'; $('documentBody').replaceChildren(documentLinks(paths.join('\n'))); if (!dialog.open) dialog.showModal(); } });
}
// The card-list view: draws the view model as given and reports intents (select, open one document, choose among several).
function drawCardList(box, count, vm, intents) {
  box.replaceChildren(); count.textContent = vm.count;
  for (const g of vm.groups) {
    box.append(el('h3', g.heading)); const strip = el('div', undefined, 'independent-strip'); box.append(strip);
    for (const c of g.cards) {
      const b = el('button', undefined, c.className); b.setAttribute('aria-pressed', String(c.selected));
      b.append(el('strong', c.heading), el('span', c.text), bandView(c.band)); b.onclick = () => intents.select(c.id);
      const shell = el('div', undefined, 'task-shell'); shell.append(b); const paths = c.paths;
      if (paths.length) { const a = el('a', '正本', 'card-document'); a.href = '#document'; a.setAttribute('aria-label', c.id + ' の正本を読む'); a.onclick = e => { e.preventDefault(); e.stopPropagation(); if (paths.length === 1) { intents.openDocument(paths[0]); return; } intents.openDocuments(c.id, paths); }; shell.append(a); }
      strip.append(shell);
    }
  }
}
// Neighborhood view (OPS-091): the direct prerequisites and successors of one node, expanded one step at a time on request.
// Built from the whole open edit version (tasks, proposals, milestones; edges, milestoneRelations) with original endpoints
// (START/END included); no version filter. Pure: never changes the data.
function neighborhood(data, center, expanded) {
  const nodes = new Map(); for (const t of data.tasks || []) nodes.set(t.id, { id: t.id, item: t.item, state: t.state, kind: 'task' });
  for (const p of (typeof proposalNodes === 'function' ? proposalNodes(data) : [])) nodes.set(p.id, { id: p.id, item: p.item, state: '追加案', kind: 'proposal' });
  for (const m of data.milestones || []) nodes.set(m.id, { id: m.id, item: m.item, state: m.state, kind: 'milestone' });
  const lines = (data.edges || []).map(e => ({ prerequisite: e.prerequisite, successor: e.successor, kind: '依存', flow: e.flow, constraint: e.constraint || '' }))
    .concat((data.milestoneRelations || []).map(e => ({ prerequisite: e.prerequisite, successor: e.successor, kind: '到達点の接続', constraint: e.constraint || '' })));
  if (!nodes.has(center)) return { center, nodes: [], edges: [] };
  const shown = new Map([[center, 0]]), edges = new Map(), open = [center, ...[...(expanded || [])].filter(id => id !== center)];
  for (const id of open) {
    if (!shown.has(id)) continue; const depth = shown.get(id);
    for (const e of lines) if (e.prerequisite === id || e.successor === id) { const other = e.prerequisite === id ? e.successor : e.prerequisite; edges.set(e.prerequisite + '>' + e.successor, e); if (!shown.has(other)) shown.set(other, depth + 1); }
  }
  return { center, nodes: [...shown].map(([id, depth]) => ({ ...(nodes.get(id) || { id, item: '（データにないID）', state: '', kind: 'unknown' }), depth, expanded: id === center || (expanded && expanded.has(id)) })), edges: [...edges.values()] };
}
// Local map layout (OPS-094): columns relative to the center (center = column 0, prerequisites left, successors right).
// Every shown line a → b ends in a column right of its start; the center never moves. Rows are spread around the middle.
// Lines are drawn between their real ends, so a node found by expansion is tied to its actual neighbor, not to the center.
function neighborhoodLayout(view) {
  const col = new Map([[view.center, 0]]), queue = [view.center];
  while (queue.length) {
    const id = queue.shift(); for (const e of view.edges) {
      if (e.prerequisite === id && !col.has(e.successor)) { col.set(e.successor, col.get(id) + 1); queue.push(e.successor); }
      else if (e.successor === id && !col.has(e.prerequisite)) { col.set(e.prerequisite, col.get(id) - 1); queue.push(e.prerequisite); }
    }
  }
  for (let i = 0, changed = true; changed && i <= view.nodes.length * view.edges.length + 1; i++) {
    changed = false; for (const e of view.edges) {
      const a = col.get(e.prerequisite), b = col.get(e.successor); if (a === undefined || b === undefined || b > a) continue;
      if (e.successor !== view.center && (a >= 0 || e.prerequisite === view.center)) col.set(e.successor, a + 1); else col.set(e.prerequisite, b - 1); changed = true;
    }
  }
  const byCol = new Map(); for (const n of view.nodes) { const c = col.has(n.id) ? col.get(n.id) : 0; if (!byCol.has(c)) byCol.set(c, []); byCol.get(c).push(n.id); }
  const pos = new Map(); for (const [c, ids] of byCol) {
    const list = c === 0 ? [view.center, ...ids.filter(x => x !== view.center)] : ids;
    // Center column: the center in the middle row, others alternately below and above. Other columns: centered around the middle.
    list.forEach((id, i) => pos.set(id, [c, c === 0 ? (i === 0 ? 0 : (i % 2 ? 1 : -1) * Math.ceil(i / 2)) : i - (list.length - 1) / 2]));
  }
  const span = Math.max(0, ...[...col.values()].map(Math.abs)), rows = Math.max(0, ...[...pos.values()].map(p => Math.abs(p[1])));
  return { pos, span, rows };
}
let neighborCenter = null; const neighborExpanded = new Set();
// OPS-126 proposal 4: local-map card titles use up to two lines (the full text stays in the card's <title>, the
// heading of the center and the inspector). measure(text) returns a width; without a canvas, a character estimate is used.
function twoLineTitle(text, width, measure) {
  const fits = str => measure ? measure(str) <= width : [...str].reduce((n, ch) => n + (ch.charCodeAt(0) > 255 ? 12 : 6.6), 0) <= width;
  const out = [''];
  for (const ch of text) {
    const i = out.length - 1; if (fits(out[i] + ch)) { out[i] += ch; continue; }
    if (out.length === 2) { while (out[1] && !fits(out[1] + '…')) out[1] = out[1].slice(0, -1); out[1] += '…'; return out; }
    out.push(ch);
  }
  return out[0] ? out : [];
}
function neighborMeasure() {
  const ctx = typeof document !== 'undefined' && document.createElement('canvas').getContext?.('2d');
  if (!ctx || typeof ctx.measureText !== 'function') return null; ctx.font = '600 12px -apple-system, sans-serif'; return str => ctx.measureText(str).width;
}
function renderNeighborhood() {
  const box = $('neighborBox'); if (!box) return; if (!neighborCenter) neighborCenter = selected;
  const vm = neighborhoodViewModel({ data: doc, center: neighborCenter, expanded: neighborExpanded, measure: neighborMeasure(), documentPaths: t => t.proposal ? [] : cardDocumentPaths(t, documentBundle) });
  drawNeighborhood(box, $('neighborCount'), vm, {
    select,
    reset: () => { neighborExpanded.clear(); renderNeighborhood(); },
    center: id => { neighborCenter = id; neighborExpanded.clear(); renderNeighborhood(); },
    expand: id => { neighborExpanded.add(id); renderNeighborhood(); },
    documents: (id, paths) => { if (paths.length === 1) { openDocument(paths[0]); return; } const dialog = $('documentDialog'); $('documentTitle').textContent = id + ' の正本'; $('documentStamp').textContent = '読む文書を選択してください'; $('documentBody').replaceChildren(documentLinks(paths.join('\n'))); if (!dialog.open) dialog.showModal(); }
  });
}
// OPS-154 stage 2: the neighborhood (local map) as a pure view model. Inputs: the edit version, the center, the expanded
// IDs, a text-width function (or null for the character estimate) and the document paths of a node. Nothing global is
// read and the data are never changed. The SVG is a view model tree (drawSvgSpec); hover texts are the SVG titles.
// Intents: select (a card), documents (a card's link), reset, center and expand (the rows below the map).
function neighborhoodViewModel({ data, center, expanded, measure, documentPaths }) {
  const view = neighborhood(data, center, expanded);
  if (!view.nodes.length) return { count: '', empty: '中心にするノードがありません。インスペクタの「接続を見る」で選んでください。' };
  const byId = new Map(view.nodes.map(n => [n.id, n])), label = id => { const n = byId.get(id); return id + (n ? ' · ' + (n.kind === 'milestone' ? '到達点' : n.kind === 'proposal' ? '追加案' : n.state) : ''); };
  const c = byId.get(center), L = neighborhoodLayout(view), W = 210, H = 84, GX = 90, GY = 26, source = new Map([...(data.tasks || []), ...proposalNodes(data), ...(data.milestones || [])].map(t => [t.id, t]));
  const cols = 2 * L.span + 1, width = cols * W + (cols - 1) * GX + 40, height = (2 * L.rows + 1) * H + 2 * L.rows * GY + 40, cx = id => 20 + (L.pos.get(id)[0] + L.span) * (W + GX), cy = id => 20 + (L.pos.get(id)[1] + L.rows) * (H + GY);
  const children = [{ tag: 'defs', attrs: {}, children: [{ tag: 'marker', attrs: { id: 'neighborArrow', viewBox: '0 0 10 10', refX: 9, refY: 5, markerWidth: 6, markerHeight: 6, orient: 'auto' }, children: [{ tag: 'path', attrs: { d: 'M 0 0 L 10 5 L 0 10 z', fill: '#78998c' } }] }] }];
  for (const e of view.edges) {
    const x1 = cx(e.prerequisite) + W, y1 = cy(e.prerequisite) + H / 2, x2 = cx(e.successor), y2 = cy(e.successor) + H / 2;
    children.push({
      tag: 'path', attrs: { d: `M${x1},${y1} C${x1 + GX / 2},${y1} ${x2 - GX / 2},${y2} ${x2},${y2}`, fill: 'none', stroke: '#78998c', 'stroke-width': 1.5, 'marker-end': 'url(#neighborArrow)', 'data-edge': e.prerequisite + '>' + e.successor },
      children: [{ tag: 'title', attrs: {}, text: e.prerequisite + ' → ' + e.successor + '\n' + e.kind + ' / ' + (e.constraint || '条件文なし') }]
    });
  }
  for (const n of view.nodes) {
    const t = source.get(n.id) || { id: n.id, item: '（データにないID）', state: '', detail: '' }, x = cx(n.id), y = cy(n.id), isCenter = n.id === center, band = stateStyle(t.proposal ? '追加案' : (t.state || ''));
    children.push({
      tag: 'g', attrs: { class: 'node', tabindex: 0, role: 'button', 'aria-label': n.id + ' ' + (t.item || ''), 'data-node': n.id, transform: `translate(${x} ${y})` }, intent: { type: 'select', id: n.id }, children: [
        { tag: 'rect', attrs: { width: W, height: H, rx: 7, fill: isCenter ? '#d4edbc' : n.kind === 'milestone' ? '#fff1c9' : '#fff', stroke: isCenter ? '#126c58' : '#b8ccc0', 'stroke-width': isCenter ? 2.5 : 1, 'stroke-dasharray': t.proposal ? '5 3' : '' } },
        { tag: 'text', attrs: { x: 10, y: 17, fill: '#657477' }, text: n.id + (isCenter ? ' · 中心' : n.kind === 'milestone' ? ' · 到達点' : t.proposal ? ' · 追加案' : '') },
        ...twoLineTitle((t.item || '').replace(/^\[(EXECUTION|DISCOVERY|DECISION)\]\s*/, ''), W - 20, measure).map((line, i) => ({ tag: 'text', attrs: { x: 10, y: 34 + i * 16, fill: '#213b32', 'font-weight': 600, 'font-size': 12 }, text: line })),
        { tag: 'title', attrs: {}, text: n.id + ' ' + (t.item || '') },
        { tag: 'path', attrs: { d: `M0 58 H${W} V${H - 7} Q${W} ${H} ${W - 7} ${H} H7 Q0 ${H} 0 ${H - 7} Z`, fill: band.bg } }, { tag: 'text', attrs: { x: 10, y: 76, fill: band.fg, 'font-weight': 600 }, text: t.proposal ? '追加案' : (t.state || '') }]
    });
    const paths = documentPaths(t);
    if (paths.length) children.push({
      tag: 'a', attrs: { href: '#document', tabindex: 0, 'aria-label': n.id + ' の正本を読む', transform: `translate(${x + W - 46} ${y + 2})` }, intent: { type: 'documents', id: n.id, paths },
      children: [{ tag: 'rect', attrs: { width: 42, height: 20, fill: 'transparent' } }, { tag: 'text', attrs: { x: 8, y: 14, fill: '#126c58' }, text: '正本' }]
    });
  }
  const row = (e, other, arrow) => { const n = byId.get(other), known = !!(n && n.kind !== 'unknown'); return { arrow, text: e.kind + (e.flow ? ' · ' + e.flow : '') + ' / ' + (e.constraint || '条件文なし'), other, canCenter: known, canExpand: known && !n.expanded }; };
  const pre = view.edges.filter(e => e.successor === center), post = view.edges.filter(e => e.prerequisite === center), further = view.edges.filter(e => e.successor !== center && e.prerequisite !== center);
  const sections = [{ heading: '前提（→ 中心）' + pre.length + '本', rows: pre.map(e => row(e, e.prerequisite, label(e.prerequisite) + ' → ' + center)) },
  { heading: '後続（中心 →）' + post.length + '本', rows: post.map(e => row(e, e.successor, center + ' → ' + label(e.successor))) }];
  if (further.length) sections.push({ heading: '展開した先 ' + further.length + '本', rows: further.map(e => { const other = byId.get(e.prerequisite) && byId.get(e.prerequisite).depth >= (byId.get(e.successor) || { depth: 0 }).depth ? e.prerequisite : e.successor; return row(e, other, label(e.prerequisite) + ' → ' + label(e.successor)); }), noEmpty: true });
  return {
    count: view.nodes.length + 'ノード・' + view.edges.length + '本', empty: null, heading: '中心：' + label(center), item: c.item || '', width,
    svg: { tag: 'svg', attrs: { width, height, viewBox: `0 0 ${width} ${height}`, role: 'group', 'aria-label': center + ' を中心にした局所見取り図' }, children }, sections
  };
}
// The neighborhood view: draws the view model as given and turns clicks into intents. The map is centered horizontally.
function drawNeighborhood(box, count, vm, intents) {
  box.replaceChildren(); count.textContent = vm.count;
  if (vm.empty) { box.append(el('p', vm.empty, 'muted')); return; }
  const top = el('div', undefined, 'buttons'), reset = el('button', '1段に戻す'); reset.onclick = () => intents.reset(); top.append(reset); box.append(top);
  box.append(el('h3', vm.heading), el('p', vm.item, 'muted'));
  const s = drawSvgSpec(vm.svg, (intent, node) => {
    if (intent.type === 'select') { node.onclick = () => intents.select(intent.id); node.onkeydown = ev => { if (ev.key === 'Enter') intents.select(intent.id); }; }
    else if (intent.type === 'documents') node.onclick = ev => { ev.preventDefault(); ev.stopPropagation(); intents.documents(intent.id, intent.paths); };
  });
  const area = el('div', undefined, 'graph neighbor-map'); area.append(s); box.append(area);
  // Keep the center card in view: scroll the local map so its middle column is centered.
  if (typeof area.scrollLeft === 'number' && area.clientWidth) area.scrollLeft = Math.max(0, (vm.width - area.clientWidth) / 2);
  for (const sec of vm.sections) {
    box.append(el('h3', sec.heading)); if (!sec.rows.length && !sec.noEmpty) box.append(el('p', 'ありません。', 'muted'));
    for (const r of sec.rows) {
      const div = el('div', undefined, 'edge-row'); div.append(el('strong', r.arrow), el('p', r.text, 'muted'));
      if (r.canCenter) {
        const go = el('button', 'ここを中心に'); go.onclick = () => intents.center(r.other); div.append(go);
        if (r.canExpand) { const more = el('button', 'この先を展開'); more.onclick = () => intents.expand(r.other); div.append(more); }
      }
      box.append(div);
    }
  }
}
function showNeighborhood(id) { neighborCenter = id; neighborExpanded.clear(); switchMap('neighbor'); renderNeighborhood(); }

function removeRelation(e) {
  if (formDirty) { report('先に入力の「変更を適用」を押してください。', true); return; }
  e = dataRelation(e);
  if (isChainLink(e)) { report(CHAIN_NOTE, true); return; }
  if (!confirm(e.prerequisite + ' → ' + e.successor + '\n' + linkLabel(e) + '：' + e.constraint + '\n\nこの関係を除去しますか？ 保存するJSONの変更に含まれます。')) return;
  const key = isMilestoneLink(e) ? 'milestoneRelations' : 'edges', before = doc[key].length;
  doc[key] = doc[key].filter(x => !(x.prerequisite === e.prerequisite && x.successor === e.successor));
  if (doc[key].length !== before) dirty = true; render();
}
// Lines drawn into a release gate may stand for a line into its END (END is not drawn, 2026-10-17).
// Editing works on the data relation; the gate chain itself comes from Milestones/ placement.
const CHAIN_NOTE = 'ゲートの列は Milestones/ のフォルダとファイルの配置から作られます。ここでは変えられません。ファイルを動かして sync.py を実行してください。';
function isMilestoneLink(e, data) { const ms = new Set(((data || doc).milestones || []).map(m => m.id)); return ms.has(e.successor) || ms.has(e.prerequisite); }
function linkLabel(e, data) { return isMilestoneLink(e, data) ? '到達点への接続' : e.flow; }
function dataRelation(e) { if (!e.shownFor && !e.shownFrom) return e; const { shownFor, shownFrom, ...rest } = e; if (shownFor) rest.successor = shownFor; if (shownFrom) rest.prerequisite = shownFrom; return rest; }
function isChainLink(e) { const ms = new Set((doc.milestones || []).map(m => m.id)); return ms.has(e.prerequisite) && ms.has(e.successor); }
function gateEntry(id) { for (const r of doc.milestoneRelations || []) if (r.successor === id && r.prerequisite.startsWith('END-')) return r.prerequisite; return id; }
function rewireRelation(data, e, prerequisite, successor) {
  const link = isMilestoneLink(e, data), key = link ? 'milestoneRelations' : 'edges', candidate = copy(data);
  const i = candidate[key].findIndex(x => x.prerequisite === e.prerequisite && x.successor === e.successor);
  if (i < 0) throw Error('元の関係が見つかりません。選び直してください。');
  if (link && successor.startsWith('GATE-') && !prerequisite.startsWith('END-')) throw Error('版ゲートへはタスクをつなげません。その版のEND-x.y.zを選んでください。');
  if (link && successor.startsWith('START-') && !prerequisite.startsWith('GATE-')) throw Error('版のSTARTへはタスクをつなげません。STARTは出発点なので、STARTを前提（出発点）側に置いてください。');
  if (link && prerequisite.startsWith('START-') && (data.milestones || []).some(m => m.id === successor) && !isChainLink(e)) throw Error('STARTから出る線はタスクへだけです。到達点どうしの列は配置から作られます。');
  candidate[key][i] = { ...candidate[key][i], prerequisite, successor };
  if (prerequisite !== e.prerequisite || successor !== e.successor) candidate[key][i].conditionReview = '相談待ち';
  check(candidate); return candidate;
}
function addMilestoneRelation(data, taskId, targetId, direction) {
  // direction 'from' (OPS-084): the milestone is the prerequisite (milestone → task), e.g. MS-SPI → a follow-up task. Only intermediate cards
  // and START can lead into a task; END only leads to its release gate and gates are the backbone, so neither is offered as a prerequisite.

  // Connect a task to an END or an intermediate card (2026-10-17, OPS-061/062). Release gates are entered only from END, so GATE-* is refused. Lines have no kind; conditions are text.
  if (!data.tasks.some(t => t.id === taskId) && !(data.proposals || []).some(p => p.id === taskId)) throw Error('タスクが見つかりません: ' + taskId);
  const ms = new Map((data.milestones || []).map(m => [m.id, m])); if (!ms.has(targetId)) throw Error('到達点が見つかりません: ' + targetId);
  if (targetId.startsWith('GATE-')) throw Error('版ゲートへはタスクをつなげません。版ゲートへ入る線はENDからだけです。その版のEND-x.y.zを選んでください。');
  // A version START is the source of the line (START → task): the task starts in that version's interval (OPS-069).
  if (direction === 'from' && targetId.startsWith('END-')) throw Error('ENDは版ゲートへの集合点なので、タスクの前提にはできません。途中のカードかSTARTを選んでください。');
  const link = targetId.startsWith('START-') || direction === 'from' ? { prerequisite: targetId, successor: taskId } : { prerequisite: taskId, successor: targetId };
  if ((data.milestoneRelations || []).some(r => r.prerequisite === link.prerequisite && r.successor === link.successor)) throw Error('この接続は既にあります: ' + link.prerequisite + ' → ' + link.successor);
  const candidate = copy(data); candidate.milestoneRelations = (candidate.milestoneRelations || []).concat([{ ...link, constraint: '', conditionReview: '相談待ち', source: { path: '', quote: '' } }]);
  check(candidate); return candidate;
}
function editRelation(e) {
  if (formDirty) { report('先に入力の「変更を適用」を押してください。', true); return; }
  const orig = dataRelation(e);
  if (isChainLink(orig)) { report(CHAIN_NOTE, true); return; }
  const target = id => id;
  const dialog = $('relationDialog'), box = $('relationEditor'); box.replaceChildren();
  box.append(el('p', '変更前：' + orig.prerequisite + ' → ' + orig.successor + (orig.prerequisite !== e.prerequisite || orig.successor !== e.successor ? '（図では ' + e.prerequisite + ' → ' + e.successor + '）' : '')), el('pre', linkLabel(orig) + ' / ' + e.constraint + (e.source ? '\n出典（変更前の根拠）：' + e.source.path + ':' + e.source.line : '')));
  const nodes = isMilestoneLink(orig) ? doc.tasks.concat(proposalNodes(doc), (doc.milestones || []).filter(m => !m.id.startsWith('GATE-'))) : doc.tasks.concat(proposalNodes(doc));  // tasks never connect to a release gate
  function picker(label, value) { const l = el('label', label), select = el('select'); for (const n of nodes) { const o = el('option', n.id + ' — ' + n.item); o.value = n.id; select.append(o); } select.value = value; l.append(select); box.append(l); return select; }
  const pre = picker('前提（矢印の出発点）', orig.prerequisite), next = picker('後続（矢印の到着点）', orig.successor), preview = el('p'), error = el('p', undefined, 'unsaved'); error.setAttribute('role', 'alert');
  const refresh = () => { const t = target(next.value); preview.textContent = '変更後：' + pre.value + ' → ' + next.value + (t !== next.value ? '（データ上は ' + t + '）' : ''); }; pre.onchange = refresh; next.onchange = refresh; refresh(); box.append(preview, el('p', '元の条件文は参照用に保持します。つなぎ替え後の条件はAIとの相談待ちとして保存し、正本反映前に一緒に決めます。' + (!isMilestoneLink(orig) ? ' タスク間の依存はタスク同士でつなぎ替えます。' : ''), 'muted'), error);
  const buttons = el('div', undefined, 'buttons'), apply = el('button', 'つなぎ替えを適用', 'primary'), remove = el('button', 'この依存を除去'), cancel = el('button', 'キャンセル'); buttons.append(apply, remove, cancel); box.append(buttons);
  apply.onclick = () => { try { const to = target(next.value); if (pre.value !== orig.prerequisite || to !== orig.successor) { doc = rewireRelation(doc, orig, pre.value, to); dirty = true; } dialog.close(); render(); } catch (err) { error.textContent = err.message; } };
  remove.onclick = () => { removeRelation(orig); if (!doc[isMilestoneLink(orig) ? 'milestoneRelations' : 'edges'].some(x => x.prerequisite === orig.prerequisite && x.successor === orig.successor)) dialog.close(); }; cancel.onclick = () => dialog.close(); dialog.showModal();
}
// Pure (OPS-154): the dependency map as an SVG view model. `data` is graphData(), `source` the edit version it was drawn
// from (its milestones and HEAD decide the version filter and which lines are milestone links), `version` the filter value,
// `measure` a text-width function, `hasDocuments(t)` whether a task has canonical documents. Nothing global is read.
// Intents: node (select / hover tip), relation (edit a line), documents (open a task's documents). Data are never changed.
function graphViewModel({ data, source, version, selected, measure, hasDocuments }) {
  // OPS-126 proposal 8: when two or more left-to-right lines enter the same card, spread their end points down its left
  // side in the order of their start heights (ties by prerequisite ID). Single lines and vertical (same-column) lines keep
  // the middle; card positions, ends, direction and line kinds are unchanged. Returns Map(edge -> y offset inside the card).
  function edgeEntryOffsets(edges, pos, H) {
    const into = new Map(), out = new Map();
    for (const e of edges) { const a = pos.get(e.prerequisite), b = pos.get(e.successor); if (!a || !b || a[0] === b[0]) continue; (into.get(e.successor) || into.set(e.successor, []).get(e.successor)).push(e); }
    for (const list of into.values()) {
      if (list.length < 2) continue;
      list.sort((p, q) => pos.get(p.prerequisite)[1] - pos.get(q.prerequisite)[1] || (p.prerequisite < q.prerequisite ? -1 : p.prerequisite > q.prerequisite ? 1 : 0));
      list.forEach((e, k) => out.set(e, H * (k + 1) / (list.length + 1)));
    }
    return out;
  }

  const view = versionView(data, version, source); let { pos, fallback, offset, hasIsolated, hasEdges, width, height } = graphLayout(view.nodes, view.edges);
  // A version with no lines (e.g. only its release gate) still shows its cards in a row.
  const lone = !!version && !hasEdges && view.nodes.length > 0;
  if (lone) { pos = new Map(view.nodes.map((n, i) => [n.id, [20 + i * 295, 50]])); width = 40 + view.nodes.length * 295; height = 170; hasIsolated = false; }
  const W = 250, H = 96, children = [{ tag: 'defs', children: [{ tag: 'marker', attrs: { id: 'arrow', viewBox: '0 0 10 10', refX: 9, refY: 5, markerWidth: 6, markerHeight: 6, orient: 'auto' }, children: [{ tag: 'path', attrs: { d: 'M 0 0 L 10 5 L 0 10 z', fill: '#78998c' } }] }] }];
  const entryY = edgeEntryOffsets(view.edges, pos, H);
  for (const e of view.edges) {
    let [x, y] = pos.get(e.prerequisite), [u, v] = pos.get(e.successor); const ey = v + (entryY.get(e) ?? H / 2);
    const line = { tag: 'path', attrs: { d: x === u ? `M${x + W / 2},${y + H} L${u + W / 2},${v}` : `M${x + W},${y + H / 2} C${x + W + 20},${y + H / 2} ${u - 20},${ey} ${u},${ey}`, fill: 'none', stroke: '#78998c', 'stroke-width': 1.5, 'stroke-dasharray': !isMilestoneLink(e, source) && e.flow === 'PARALLEL_JOIN' ? '5 4' : '', 'marker-end': 'url(#arrow)' }, children: [{ tag: 'title', attrs: {}, text: linkLabel(e, source) + ' / ' + e.constraint + (e.source ? '\n出典：' + e.source.path + ':' + e.source.line : '') }] };
    children.push(line, { tag: 'path', attrs: { d: line.attrs.d, fill: 'none', stroke: 'transparent', 'stroke-width': 16, 'pointer-events': 'stroke', tabindex: 0, role: 'button', 'aria-label': e.prerequisite + ' → ' + e.successor + ' の関係を編集', style: 'cursor:pointer' }, children: [{ tag: 'title', attrs: {}, text: e.prerequisite + ' → ' + e.successor + '\nクリックしてつなぎ替え・除去' }], intent: { type: 'relation', edge: e, line } });
  }
  const note = (x, y, text) => ({ tag: 'text', attrs: { x, y, fill: '#657477' }, text });
  if (hasIsolated) children.push(note(20, 28, '独立タスク（明示依存なし）'));
  if (!hasEdges && !lone) children.push(note(20, 60, '明示された依存はありません。'));
  if (lone) children.push(note(20, 28, 'この版には途中のゲートもタスクもまだありません。'));
  if (hasEdges) children.push(note(20 + offset * 295, 28, fallback ? '依存順の自動配置 →' : '前提からゲートへ →'));
  for (const t of view.nodes.filter(t => pos.has(t.id))) {
    let [x, y] = pos.get(t.id); const band = stateStyle(t.state);
    const tip = t.id + (t.kind === 'milestone' ? ' · 到達点' : t.permanent ? ' · 常設' : '') + '\n' + t.item + '\n\n状態：' + t.state + '\n担当：' + t.owner + '\n\n条件：' + t.condition;
    children.push({
      tag: 'g', attrs: { class: 'node', tabindex: 0, role: 'button', 'aria-label': t.id + ' ' + t.item, transform: `translate(${x} ${y})` }, intent: { type: 'node', id: t.id, tip }, children: [
        { tag: 'rect', attrs: { width: W, height: H, rx: 7, fill: t.id === selected ? '#d4edbc' : t.kind === 'milestone' ? '#fff1c9' : '#fff', stroke: t.id === selected ? '#126c58' : '#b8ccc0', 'stroke-dasharray': t.proposal ? '5 3' : '' } },
        { tag: 'text', attrs: { x: 12, y: 18, fill: '#657477' }, text: t.id + (t.kind === 'milestone' ? ' · 到達点' : t.proposal ? ' · 追加案' : t.permanent ? ' · 常設' : '') },
        ...wrapLines(t.item.replace(/^\[(EXECUTION|DISCOVERY|DECISION)\]\s*/, ''), W - 24, 2, measure).map((line, i) => ({ tag: 'text', attrs: { x: 12, y: 40 + i * 17, fill: '#213b32', 'font-weight': 600 }, text: line })),
        { tag: 'path', attrs: { d: `M0 70 H${W} V${H - 7} Q${W} ${H} ${W - 7} ${H} H7 Q0 ${H} 0 ${H - 7} Z`, fill: band.bg } }, { tag: 'text', attrs: { x: 12, y: 87, fill: band.fg, 'font-weight': 600 }, text: t.state }]
    });
    if (!t.proposal && hasDocuments(t)) children.push({ tag: 'a', attrs: { href: '#document', tabindex: 0, 'aria-label': t.id + ' の正本を読む', transform: `translate(${x + W - 46} ${y + 3})` }, intent: { type: 'documents', node: t }, children: [{ tag: 'rect', attrs: { width: 42, height: 22, fill: 'transparent' } }, { tag: 'text', attrs: { x: 8, y: 15, fill: '#126c58' }, text: '正本' }] });
  }
  return { tag: 'svg', attrs: { width, height, viewBox: `0 0 ${width} ${height}`, role: 'group', 'aria-label': '全taskの明示依存グラフ' }, children };
}
// The dependency-map view: draws the view model and turns its intents into the existing operations.

const MAP_TABS = ['dependency', 'permanent', 'protection', 'cards', 'neighbor'];  // neighborhood view added (OPS-091)  // card list added (OPS-085)
function switchMap(value) {
  const mode = value === true ? 'permanent' : value === false ? 'dependency' : value;
  for (const name of MAP_TABS) { const active = name === mode; $(name + 'View').hidden = !active; const tab = $(name + 'Tab'); tab.setAttribute('aria-selected', String(active)); tab.tabIndex = active ? 0 : -1; }
}

function editsReflected(base, edited, latest) {
  if (!base || !latest || (edited.proposals || []).length) return false;
  const groups = [['tasks', ['state', 'owner']], ['edges', ['flow']], ['milestoneRelations', []], ['milestones', ['item', 'state', 'version', 'name', 'path', 'gate', 'condition']]];
  let changes = 0;
  const eq = (a, b) => JSON.stringify(a ?? null) === JSON.stringify(b ?? null);
  for (const [group, fields] of groups) {
    if (![base[group], edited[group], latest[group]].every(Array.isArray)) return false;
    const key = x => x.id || x.prerequisite + ' → ' + x.successor;
    const map = a => new Map(a.map(x => [key(x), x]));
    const b = map(base[group]), e = map(edited[group]), n = map(latest[group]);
    for (const id of new Set([...b.keys(), ...e.keys()])) {
      const before = b.get(id), after = e.get(id), now = n.get(id);
      if (!after) { changes++; if (now) return false; continue; }
      if (!before) { changes++; if (!now || fields.some(f => !eq(after[f], now[f]))) return false; continue; }
      for (const f of fields) if (!eq(before[f], after[f])) { changes++; if (!now || !eq(after[f], now[f])) return false; }
    }
  }
  return changes > 0;
}

function renderCanonicalRestartSuggestion() {
  const notice = $('canonicalRestartNotice'); if (!notice) return;
  notice.hidden = !(workspace && !dirty && !formDirty && !planDraftPending() && editsReflected(doc.baseline, doc, suggestionSnapshot));
}

function renderProtection() {
  const parts = new Intl.DateTimeFormat('en-US', { timeZone: 'Asia/Tokyo', year: 'numeric', month: '2-digit', day: '2-digit' }).formatToParts(new Date()), get = t => parts.find(p => p.type === t).value, today = get('year') + '-' + get('month') + '-' + get('day');
  const table = el('table'), head = el('tr'); for (const title of ['文書', 'タスク', '区分', '付与日', '経過', '記録日', '記録者', '理由']) head.append(el('th', title)); table.append(head);
  const records = protectionRecords(doc);
  for (const r of records) { const row = el('tr'), cell = el('td'), link = el('a', r.path); link.href = '#document'; link.onclick = e => { e.preventDefault(); openDocument(r.path); }; cell.append(link); row.append(cell); for (const value of [r.task, r['区分'], r['付与日'], protectionDays(r['付与日'], today), r['記録日'], r['記録者'], r['理由']]) row.append(el('td', value || '未記録')); table.append(row); }
  $('protectionList').replaceChildren(records.length ? table : el('p', '配置維持の指定はありません。'));
}

function graph() {
  const tip = $('graphTip'); tip.hidden = true;
  const picker = $('versionPicker'), folders = versionFolders();
  if (picker && picker.options.length !== folders.length + 2) { picker.replaceChildren(); const all = el('option', '全体'); all.value = ''; const fromHead = el('option', 'HEAD から（' + (doc.milestoneHead || '?') + ' 以降）'); fromHead.value = '@head'; picker.append(all, fromHead); for (const f of folders) { const o = el('option', f); o.value = f; picker.append(o); } picker.value = '@head';/* opens at HEAD (2026-10-17) */picker.onchange = () => render(); }
  const measure = document.createElement('canvas').getContext('2d'); measure.font = '12px -apple-system, sans-serif';
  const vm = graphViewModel({ data: graphData(), source: doc, version: picker ? picker.value : '', selected, measure: text => measure.measureText(text).width, hasDocuments: t => taskDocumentPaths(t).length > 0 });
  function show(t, x, y) { if (!$('graphHoverEnabled').checked) { tip.hidden = true; return; } tip.textContent = t; tip.hidden = false; const r = tip.getBoundingClientRect(); tip.style.left = Math.max(12, Math.min(x + 14, innerWidth - r.width - 12)) + 'px'; tip.style.top = Math.max(12, Math.min(y + 14, innerHeight - r.height - 12)) + 'px'; }
  const s = drawSvgSpec(vm, (intent, g, made) => {
    if (intent.type === 'relation') { const e = intent.edge, p = made.get(intent.line); g.onclick = () => editRelation(e); g.onkeydown = event => { if (event.key === 'Enter' || event.key === ' ') { event.preventDefault(); editRelation(e); } }; g.onfocus = () => { p.setAttribute('stroke-width', 5); }; g.onblur = () => { p.setAttribute('stroke-width', 1.5); }; }
    else if (intent.type === 'node') { const text = intent.tip; g.onpointerenter = e => show(text, e.clientX, e.clientY); g.onpointermove = e => show(text, e.clientX, e.clientY); g.onpointerleave = () => tip.hidden = true; g.onfocus = () => { const r = g.getBoundingClientRect(); show(text, r.left, r.bottom); }; g.onblur = () => tip.hidden = true; g.onclick = () => { tip.hidden = true; select(intent.id); }; g.onkeydown = e => { if (e.key === 'Enter') select(intent.id); if (e.key === 'Escape') tip.hidden = true; }; }
    else if (intent.type === 'documents') { const open = e => { e.preventDefault(); e.stopPropagation(); tip.hidden = true; openTaskDocuments(intent.node); }; g.onclick = open; g.onkeydown = e => { if (e.key === 'Enter' || e.key === ' ') open(e); }; }
  });
  $('graph').replaceChildren(s); applyGraphZoom(); $('graph').onscroll = () => tip.hidden = true;
}

