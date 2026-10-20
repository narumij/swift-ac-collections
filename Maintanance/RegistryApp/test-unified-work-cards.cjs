const fs = require('fs'), vm = require('vm'), assert = require('assert');
const context = {}; vm.createContext(context);
for (const file of ['index.work.recent.js', 'index.work.approvals.js']) vm.runInContext(fs.readFileSync(__dirname + '/' + file, 'utf8'), context);
class Node {
  constructor() { this.children = []; this.dataset = {}; this.textContent = ''; this.scrollLeft = 0; this.open = false; }
  appendChild(node) { this.insertBefore(node, null); }
  insertBefore(node, next) { node.remove(); const index = next ? this.children.indexOf(next) : this.children.length; this.children.splice(index, 0, node); node.parent = this; }
  remove() { if (this.parent) this.parent.children.splice(this.parent.children.indexOf(this), 1); this.parent = null; }
  contains(node) { return this === node || this.children.some(c => c.contains(node)); }
  showModal() { this.open = true; }
  close() { this.open = false; }
}
const make = () => new Node(), track = make(), status = make(), dialog = make(), detail = make(), all = make();
const work = context.createWorkLaneView({ track, status, makeNode: make });
const cards = ids => ({ cards: ids.map(taskId => ({ taskId, lines: [taskId, '', '', '', '開始：不明'], title: taskId, stage: '作業中', next: 'approval' })), status: '', stale: false });
work.update(cards(['T-2', 'T-1']));
const approval = context.createApprovalView({ track, status: make(), policy: make(), all, dialog, detail, close: make(), makeNode: make, taskTrack: work.approvalTrack });
let clicked; approval.bind((action, targets) => { clicked = { action, targets: JSON.parse(JSON.stringify(targets)) }; });
const row = (id, taskId, state = 'pending', revision = 1) => ({ id, taskId, status: state, revision, heading: taskId + ' <plain>', stateText: state, detailText: '<script>safe</script> ' + id });
let rows = [row('a', 'T-1'), row('b', 'T-1', 'approved'), row('c', 'T-2', 'claimed')];
const value = () => ({ visible: rows.filter(r => !['consumed', 'cancelled'].includes(r.status)), entries: rows, status: '', policyNotice: 'policy' });
approval.update(value()); approval.availability(true, false);
assert.equal(track.children.length, 2, 'one card per task');
assert.equal(work.approvalTrack('T-1').children.length, 2, 'all active approvals stay in their task');
const first = work.approvalTrack('T-1').children[0], buttons = first.children[2];
buttons.children[0].onclick(); assert.equal(detail.textContent, '<script>safe</script> a'); assert(dialog.open);
buttons.children[1].onclick(); assert.deepEqual(clicked, { action: 'approve', targets: [{ id: 'a', revision: 1 }] });
buttons.children[2].onclick(); assert.equal(clicked.action, 'cancel');
all.onclick(); assert.deepEqual(clicked.targets, [{ id: 'a', revision: 1 }]);
assert(work.approvalTrack('T-2').children[0].children[2].children[2].disabled, 'claimed cancellation stays disabled');
work.update(cards(['T-2', 'T-1'])); approval.update(value());
assert.strictEqual(work.approvalTrack('T-1').children[0], first, 'refresh keeps approval input identity');
approval.availability(false, false); assert(buttons.children[1].disabled && all.disabled);
rows[0] = row('a', 'T-1', 'consumed', 2); approval.update(value()); assert.equal(work.approvalTrack('T-1').children.length, 1, 'completed history is not restored');
const html = fs.readFileSync(__dirname + '/index.work.html', 'utf8');
assert(!html.includes('id="approval-track"') && !html.includes('id="approval-details"'), 'old separate section removed');
assert(!html.includes('member-preference'), 'rolled-back preference is not restored');
console.log('PASS unified work cards: one task/card, multiple approvals, exact targets, safe detail, claimed guard, disabled state, stable DOM and no old section/history');
