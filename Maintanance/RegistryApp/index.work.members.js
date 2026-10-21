// @section members
// OPS-141 member states (protocol 0.3). Per member, three separate things: the state the member declared last (presence
// working / waiting / ended = 作業中 / 待機中 / 待機終了), the member's last practical activity with its time, and the
// freshness of the member's own continuity mark. Practical events, PINGs and ACKs never change the declared state.
// Up to LEGACY_ACK_BOUNDARY a WAKE ACK was read as "wait ended"; those records keep that old reading, labelled as such
// and never as the member's own declaration. Later ACKs only confirm receipt.
const LEGACY_ACK_BOUNDARY = { id: 'feeb9d2cde9c43d0bc7d8cc0fa080e4b', at: '2026-10-18T19:35:45+00:00' };
const PRESENCE_LABELS = { working: '作業中', waiting: '待機中', ended: '待機終了', unknown: '未申告' };
function presenceStates(rows) {
  const states = new Map(), limit = Date.parse(LEGACY_ACK_BOUNDARY.at), starts = confirmedStarts(rows);
  for (const row of rows) {
    const r = row.raw; if (!r || r.owner === 'ユーザー') continue;
    const s = states.get(r.owner) || { state: 'unknown', at: '', legacy: false, last: null, seen: '' }; s.seen = r.at;
    if (r.presence) { s.state = r.presence; s.at = r.at; s.legacy = false; }
    else if (/^ACK WAKE-\d{8}-[A-Z0-9]+(?![A-Za-z0-9])/.test(r.reason) && Date.parse(r.at) <= limit) { s.state = 'ended'; s.at = r.at; s.legacy = true; }
    if (!isProbeEvent(r.reason) && !isStateNotice(row, starts)) s.last = { at: r.at, label: activityLabels[row.event] || row.event };
    states.set(r.owner, s);
  }
  // every member in the record window is listed (newest first here); no silent cap — the member area wraps.
  // The shown order is decided by stableMemberOrder: members keep the order in which they first appeared.
  return new Map([...states].sort((a, b) => Date.parse(b[1].seen) - Date.parse(a[1].seen)));
}
// OPS-151: a request with a leading ID opens "開始待ち" for its recipient. Only the recipient's own record with the same ID
// and task closes it, and only as working, ended or a return; a waiting with that ID leaves it open and unmarked. A declaration without that ID, or with another ID — an old WAKE ACK,
// an ended from before — never closes it and only marks it "対応未確認". There is no cancel record yet (format undecided).
// Per owner: a Map of open entries in request order; selfSeen tells "no own record yet" apart from "unanswered".
function startPendings(rows) {
  const open = new Map(), owners = new Set();
  for (const row of rows) {
    const r = row.raw; if (!r || r.owner === 'ユーザー') continue; const id = leadingRequestId(r.reason), key = id + '\n' + r.taskId;
    if (row.event === 'request' && id && r.next && !['none', 'user', 'unknown', 'ユーザー', r.owner].includes(r.next)) {
      const mine = open.get(r.next) || open.set(r.next, { entries: new Map(), selfSeen: owners.has(r.next) }).get(r.next);
      mine.entries.delete(key); mine.entries.set(key, { id, taskId: r.taskId, from: r.owner, at: r.at, unmatched: false }); continue;
    }
    owners.add(r.owner); const mine = open.get(r.owner); if (mine) mine.selfSeen = true;
    if (!mine || !(r.presence || row.event === 'return')) continue;
    if (id && mine.entries.has(key)) { if (r.presence === 'working' || r.presence === 'ended' || row.event === 'return') mine.entries.delete(key); continue; }
    for (const e of mine.entries.values()) e.unmatched = true;
  }
  for (const [owner, mine] of open) if (!mine.entries.size) open.delete(owner);
  return open;
}
function pendingLines(p) {
  if (!p) return ''; const list = [...p.entries.values()].reverse(), shown = list.slice(0, 3);
  return shown.map(e => '\n開始待ち ' + e.id + '（' + e.from + ' ' + memberTime(e.at) + '）' + (e.unmatched ? '・対応未確認' : p.selfSeen ? '' : '・本人記録なし')).join('') + (list.length > 3 ? '\nほか' + (list.length - 3) + '件の開始待ち' : '');
}
function memberTime(at) { const d = new Date(at); return Number.isFinite(d.getTime()) ? d.toLocaleTimeString('ja-JP', { hour12: false }) : ''; }
// Planned members stay visible; actual members outside the plan are marked red.
function memberViewModels(model) {
  return model.members.map(({ owner, attendance, planned }) => ({
    owner, attendance, planned, state: 'unknown', pending: false,
    border: !planned ? 'red' : attendance === 'present' ? 'solid' : 'dotted',
    head: owner,
    body: '\n' + (attendance === 'present' ? '出勤中' : '未出勤') + '\n' + (model.memberInfo?.[owner] || '通信記録なし')
  }));
}
// The shown order is a display input, not a reading of the history: members already shown keep their previous order,
// new members are added at the end in view-model order, members that left are dropped (one that returns goes to the end).
function stableMemberOrder(prevOrder, vms) {
  const by = new Map(vms.map(v => [v.owner, v])), kept = prevOrder.filter(o => by.has(o)), known = new Set(kept);
  return [...kept.map(o => by.get(o)), ...vms.filter(v => !known.has(v.owner))];
}
function memberFailureText(owner, continuityText) { return owner + '：取得不調（状態を読めません）\n' + continuityText(owner); }
// Owners with a record not seen before (they flash). Pure: returns the owners and the new seen set.
function newRecordOwners(seen, rows) { const ids = new Set(rows.map(r => r.id)); return { owners: new Set(seen ? rows.filter(r => !seen.has(r.id)).map(r => r.raw?.owner) : []), seen: seen ? new Set([...seen, ...ids]) : ids }; }
// The lamp view: DOM only. It draws the entries it is given, keeps lamp order, runs the flash, and shows a failure text.
function createMemberLampView({ box, makeNode, schedule = (fn, ms) => setTimeout(fn, ms), removePlanned = null }) {
  const lamps = new Map(); let shown = new Map();
  const set = (node, text) => { if (node.textContent !== text) node.textContent = text; };
  function paint(vm, fresh) {
    const owner = vm.owner; let lamp = lamps.get(owner); if (!lamp) { lamp = { node: makeNode('span'), text: makeNode('span'), fresh: 0 }; lamp.node.appendChild(lamp.text); lamp.node.className = 'presence-lamp'; lamps.set(owner, lamp); }
    lamp.node.dataset.border = vm.border; lamp.node.dataset.state = vm.state; if (vm.pending) lamp.node.dataset.pending = 'true'; else delete lamp.node.dataset.pending; if (fresh) {
      lamp.fresh++; const mine = lamp.fresh; lamp.node.dataset.fresh = 'true'; schedule(() => {
        // Only the latest flash of a lamp that is still shown clears; a fetch failure keeps its text until recovery.
        if (lamps.get(owner) !== lamp || lamp.fresh !== mine) return; delete lamp.node.dataset.fresh; if (box.dataset.stale === 'true') return; paint(shown.get(owner) || vm, false);
      }, 3000);
    }
    set(lamp.text, vm.head + (lamp.node.dataset.fresh ? '・新着' : '') + vm.body);
    if (lamp.remove) lamp.remove.disabled = box.dataset.stale === 'true';
    if (vm.planned && removePlanned && !lamp.remove) {
      const button = makeNode('button'); button.type = 'button'; button.className = 'member-remove-planned';
      button.textContent = '×'; button.setAttribute('aria-label', owner + 'を出勤予定から外す'); button.title = owner + 'を出勤予定から外す';
      button.addEventListener('click', async () => {
        button.disabled = true;
        try { await removePlanned(owner); }
        catch (error) { button.title = '予定を削除できませんでした：' + error.message; set(lamp.text, vm.head + vm.body + '\n予定を削除できませんでした'); }
        finally { button.disabled = false; }
      });
      lamp.remove = button; lamp.node.appendChild(button);
    } else if (!vm.planned && lamp.remove) { lamp.remove.remove(); lamp.remove = null; }
  }
  return {
    show(vms, freshOwners = new Set()) {
      shown = new Map(vms.map(v => [v.owner, v])); for (const [owner, lamp] of lamps) if (!shown.has(owner)) { lamp.node.remove(); lamps.delete(owner); } for (const v of vms) paint(v, freshOwners.has(v.owner));
      // The DOM follows the given order exactly; when it differs, the lamps are re-appended in that order.
      const nodes = vms.map(v => lamps.get(v.owner).node); if (nodes.some((n, i) => box.children[i] !== n)) for (const n of nodes) box.appendChild(n);
    },
    showFailure(textOf) { box.dataset.stale = 'true'; for (const [owner, lamp] of lamps) { lamp.node.dataset.state = 'unknown'; set(lamp.text, textOf(owner)); if (lamp.remove) lamp.remove.disabled = true; } },
    recovered() { delete box.dataset.stale; },
    stale() { return box.dataset.stale === 'true'; }
  };
}
// The member status as one studio part (used alone in tests; the page uses the shared studio).
function createPresenceLamps({ box, makeNode, schedule = (fn, ms) => setTimeout(fn, ms) }) {
  const studio = createStudio({ views: { members: createMemberLampView({ box, makeNode, schedule }) } });
  return { update(rows) { studio.activity(rows); }, continuity(fn, owners) { studio.continuity({ labelOf: fn, owners: owners || [] }); }, failure() { studio.activityFailure(); } };
}

async function removePlannedMember(owner) {
  const response = await fetch('/members/planned/remove', {
    method: 'POST', headers: { 'X-Registry-Studio': 'members-planned-remove', 'Content-Type': 'application/json' },
    body: JSON.stringify({ owner }), signal: AbortSignal.timeout(5000)
  });
  if (!response.ok) { const value = await response.json().catch(() => ({})); throw Error(value.error || '通信エラー'); }
}
// @endsection
