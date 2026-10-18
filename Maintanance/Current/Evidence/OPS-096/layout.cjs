// OPS-096: a task group that starts at an intermediate milestone is laid out under that milestone in the global map.
// Usage (repository root): node Maintanance/Current/Evidence/OPS-096/layout.cjs [template] [baseline-template]
//   template          default Maintanance/RegistryApp/index.template.html
//   baseline-template the layout before the fix, to check that unrelated cards keep their coordinates (optional;
//                     e.g. a file produced by `git show 46fd45a85:Maintanance/RegistryApp/index.template.html`)
// Checks real data (MS-SPI / DOC-027 in all, @head, 0.6.0) and ID-changed fixtures (single successor, successor chain,
// outside prerequisite, multiple origins). Prints one line per check, exits 1 on any failure.
'use strict';
const fs = require('fs'), vm = require('vm');
const W = 250, H = 96;
function load(file) {
  const src = fs.readFileSync(file, 'utf8');
  const data = JSON.parse(fs.readFileSync('Maintanance/Cache/RegistryStudio/registry.json', 'utf8'));
  const ctx = { doc: data, taskDocumentPaths: () => [] }; vm.createContext(ctx);
  vm.runInContext(src.slice(src.indexOf('function proposalNodes('), src.indexOf('function nextProposalId(')), ctx);
  vm.runInContext(src.slice(src.indexOf('function graphData('), src.indexOf('function independent(){')), ctx);
  return ctx;
}
const ctx = load(process.argv[2] || 'Maintanance/RegistryApp/index.template.html');
const base = process.argv[3] ? load(process.argv[3]) : null;
let failed = 0;
const check = (ok, text) => { console.log((ok ? 'PASS ' : 'FAIL ') + text); if (!ok) failed++; };

// Layout invariants: every used card placed once, no overlap, every edge drawn left→right or downward in a column.
function sound(nodes, edges, l) {
  const used = new Set(edges.flatMap(e => [e.prerequisite, e.successor])), problems = [];
  for (const id of used) if (!l.pos.has(id)) problems.push('unplaced ' + id);
  for (const e of edges) { const a = l.pos.get(e.prerequisite), b = l.pos.get(e.successor); if (a && b && !(a[0] < b[0] || (a[0] === b[0] && a[1] < b[1]))) problems.push('backward ' + e.prerequisite + '→' + e.successor); }
  const r = [...l.pos.entries()];
  for (let i = 0; i < r.length; i++) for (let j = 0; j < i; j++) if (Math.abs(r[i][1][0] - r[j][1][0]) < W && Math.abs(r[i][1][1] - r[j][1][1]) < H) problems.push('overlap ' + r[i][0] + '/' + r[j][0]);
  if (l.fallback) problems.push('fallback');
  return problems;
}
// The card is in the milestone's column (no later backbone card to its left) and below it / above it.
const owner = (l, id) => l.backbone.filter(b => l.pos.get(b)[0] <= l.pos.get(id)[0]).sort((a, b) => l.pos.get(b)[0] - l.pos.get(a)[0])[0];
const offset = (l, milestone, id) => l.pos.get(id)[0] - l.pos.get(milestone)[0];
const under = (l, milestone, id) => l.pos.has(id) && owner(l, id) === milestone && l.pos.get(id)[1] > l.pos.get(milestone)[1];
const over = (l, milestone, id) => l.pos.has(id) && owner(l, id) === milestone && l.pos.get(id)[1] < l.pos.get(milestone)[1];
const ordered = l => l.backbone.every((id, i) => !i || l.pos.get(l.backbone[i - 1])[0] < l.pos.get(id)[0]);

// 1. Real data: the DOC-027 group stacked under MS-SPI at the upper lane's offset (PERM-079 over GATE-0.6.0);
//    lines kept; cards left of the group unmoved, later cards shifted together horizontally only.
for (const v of ['', '@head', '0.6.0']) {
  const g = ctx.versionView(ctx.graphData(), v), l = ctx.graphLayout(g.nodes, g.edges), name = v || 'all';
  if (!l.pos.has('DOC-027')) { check(true, `${name}: DOC-027 not shown in this view`); continue; }
  const p = sound(g.nodes, g.edges, l), group = ['QUALITY-005', 'DOC-026', 'DOC-027'];
  check(!p.length && ordered(l), `${name}: layout sound, backbone order kept${p.length ? ' — ' + p.join(', ') : ''}`);
  const lane = offset(l, 'GATE-0.6.0', 'PERM-079'), offs = group.map(id => offset(l, 'MS-SPI', id));
  check(over(l, 'GATE-0.6.0', 'PERM-079'), `${name}: single PERM-079 stays in the upper lane of GATE-0.6.0 (offset ${lane})`);
  check(group.every(id => under(l, 'MS-SPI', id)) && offs.every(o => o === lane), `${name}: ${group.join(',')} stacked under MS-SPI at offset ${offs.join('/')} (= upper lane ${lane}) — DOC-027 ${l.pos.get('DOC-027').map(Math.round)}`);
  const lines = ['MS-SPI→DOC-027', 'DOC-026→DOC-027', 'QUALITY-005→DOC-026'];
  check(lines.every(s => g.edges.some(e => e.prerequisite + '→' + e.successor === s)), `${name}: lines kept between their real ends (${lines.join(', ')})`);
  if (base) {
    const bg = base.versionView(base.graphData(), v), bl = base.graphLayout(bg.nodes, bg.edges), from = bl.pos.get('MS-SPI')[0];
    const isolated = new Set(l.branches.filter(b => b.kind === 'isolated').flatMap(b => b.ids)), rest = [...bl.pos.keys()].filter(id => !group.includes(id));
    const left = rest.filter(id => !isolated.has(id) && bl.pos.get(id)[0] <= from), right = rest.filter(id => !isolated.has(id) && bl.pos.get(id)[0] > from);
    const leftMoved = left.filter(id => String(bl.pos.get(id)) !== String(l.pos.get(id)));
    const dx = new Set(right.map(id => bl.pos.get(id)[1] === l.pos.get(id)[1] ? Math.round((l.pos.get(id)[0] - bl.pos.get(id)[0]) * 1e6) / 1e6 : NaN));
    const dy = new Set([...isolated].filter(id => bl.pos.has(id)).map(id => bl.pos.get(id)[0] === l.pos.get(id)[0] ? bl.pos.get(id)[1] - l.pos.get(id)[1] : NaN));
    check(!leftMoved.length, `${name}: ${left.length} cards up to MS-SPI unmoved${leftMoved.length ? ' — moved ' + leftMoved.join(', ') : ''}`);
    check(dx.size <= 1 && ![...dx].some(Number.isNaN), `${name}: ${right.length} later cards shifted together, horizontally only (dx ${[...dx].join('/') || 'none'})`);
    check(dy.size <= 1 && ![...dy].some(Number.isNaN), `${name}: ${[...isolated].filter(id => bl.pos.has(id)).length} unconnected-chain cards keep x, row moved together (raised by ${[...dy].join('/') || 'none'})`);
  }
}

// 2. ID-changed fixtures. Backbone A0→A1→A2→A3 with a feeder F1 into A3 (a lower card under A2); groups start at A1.
const ms = ['A0', 'A1', 'A2', 'A3'];
function fixture(extraTasks, extraEdges) {
  const tasks = ms.map(id => ({ id, kind: 'milestone' })).concat(['F1', ...extraTasks].map(id => ({ id, kind: 'task' })));
  const edges = [['A0', 'A1'], ['A1', 'A2'], ['A2', 'A3'], ['F1', 'A3'], ...extraEdges].map(([prerequisite, successor]) => ({ prerequisite, successor, flow: 'REQUIRED' }));
  return { tasks, edges, l: ctx.graphLayout(tasks, edges) };
}
const plain = fixture([], []);
const single = fixture(['X1'], [['A1', 'X1']]), lane = offset(single.l, 'A1', 'X1');
{
  const p = sound(single.tasks, single.edges, single.l);
  check(!p.length && over(single.l, 'A1', 'X1'), `fixture single successor: X1 in the upper lane of A1 (offset ${lane})${p.length ? ' — ' + p.join(', ') : ''}`);
}
const cases = [
  ['successor chain', ['Y1', 'Y2', 'Y3'], [['A1', 'Y1'], ['Y1', 'Y2'], ['Y2', 'Y3']]],
  ['outside prerequisite', ['P1', 'P2', 'Z1'], [['P1', 'P2'], ['P2', 'Z1'], ['A1', 'Z1']]],
  ['long outside prerequisite', ['Q1', 'Q2', 'Q3', 'Q4', 'Z2'], [['Q1', 'Q2'], ['Q2', 'Q3'], ['Q3', 'Q4'], ['Q4', 'Z2'], ['A1', 'Z2']]],
  ['single and chain on the same milestone', ['X1', 'Y1', 'Y2'], [['A1', 'X1'], ['A1', 'Y1'], ['Y1', 'Y2']]],
];
for (const [name, tasks, edges] of cases) {
  const f = fixture(tasks, edges), p = sound(f.tasks, f.edges, f.l), stacked = tasks.filter(id => id !== 'X1');
  const ok = stacked.every(id => under(f.l, 'A1', id) && offset(f.l, 'A1', id) === lane) && (!tasks.includes('X1') || (over(f.l, 'A1', 'X1') && offset(f.l, 'A1', 'X1') === lane));
  check(!p.length && ordered(f.l) && ok, `fixture ${name}: ${stacked.join(',')} below A1${tasks.includes('X1') ? ', X1 above' : ''}, offset ${lane}${p.length ? ' — ' + p.join(', ') : ''}`);
}
{ // Width: the stack would meet A2's lower card F1, so only the A1→A2 gap widens; A0/A1 stay, later milestones keep order.
  const f = fixture(...cases[0].slice(1)), p = sound(f.tasks, f.edges, f.l), at = (l, id) => Math.round(l.pos.get(id)[0]);
  const before = ms.map(id => at(plain.l, id)), after = ms.map(id => at(f.l, id));
  const gap = (xs, i) => xs[i + 1] - xs[i], stackRight = at(f.l, 'Y1') + W, f1 = at(f.l, 'F1');
  const ok = !p.length && after[0] === before[0] && after[1] === before[1] && gap(after, 1) > gap(before, 1) && gap(after, 2) === gap(before, 2) && f1 >= stackRight + 1;
  check(ok, `fixture width: A1→A2 gap ${gap(before, 1)}→${gap(after, 1)}, A0/A1 unmoved, A2→A3 gap ${gap(before, 2)}→${gap(after, 2)}, stack right ${stackRight} < F1 ${f1}${p.length ? ' — ' + p.join(', ') : ''}`);
}
{ // No widening needed when the next milestone has no lower card at that height.
  const tasks = ['A0', 'A1', 'A2'].map(id => ({ id, kind: 'milestone' })).concat(['Y1', 'Y2'].map(id => ({ id, kind: 'task' })));
  const edges = [['A0', 'A1'], ['A1', 'A2'], ['A1', 'Y1'], ['Y1', 'Y2']].map(([prerequisite, successor]) => ({ prerequisite, successor, flow: 'REQUIRED' }));
  const l = ctx.graphLayout(tasks, edges), p = sound(tasks, edges, l);
  const gap = l.pos.get('A2')[0] - l.pos.get('A1')[0], usual = (W + 45) * 1.5;
  check(!p.length && under(l, 'A1', 'Y2') && Math.abs(gap - usual) < 1e-6, `fixture stack before a bare milestone: sound, A1→A2 gap ${Math.round(gap)} not widened (usual ${Math.round(usual)})${p.length ? ' — ' + p.join(', ') : ''}`);
}
{ // Multiple origins (A1 and A2 both start the group): the priority is undecided, so only soundness is checked.
  const f = fixture(['M1', 'M2'], [['A1', 'M1'], ['M1', 'M2'], ['A2', 'M2']]), p = sound(f.tasks, f.edges, f.l);
  check(!p.length, `fixture multiple origins (A1, A2): sound, placement not decided here — M1 in ${owner(f.l, 'M1')} column, M2 in ${owner(f.l, 'M2')} column${p.length ? ' — ' + p.join(', ') : ''}`);
}
console.log(failed ? `${failed} FAILED` : 'ALL PASS');
process.exit(failed ? 1 : 0);
