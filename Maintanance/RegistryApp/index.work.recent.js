// @section recent
// OPS-119 work lane: a derived view of the latest 200 activity events and the unfinished commit approvals.
// It stores nothing, never approves, and is redrawn only when activity or approvals are fetched.
const workLaneStages = { request: '依頼済み', work: '作業中', verification: '確認中', return: '返却・受入待ち', recheck: '再確認中', acceptance: '受入済み', complete: '作業区切り', 'awaiting-commit': 'コミット待ち', commit: '記録コミット済み' };
function isProbeEvent(reason) {
  // Only the dedicated connectivity notation is a probe: a send writes the ID immediately followed by a colon
  // ("PING-20261018-A：…", "WAKE-20261018-D：…"); a reply starts with "ACK <ID>". A practical event that merely
  // mentions an ID ("PING-20261018-Aの判定不具合を修正") or the word PING is not a probe.
  const id = '(?:PING|WAKE)-\\d{8}-[A-Z0-9]+';
  return new RegExp('^ACK ' + id + '(?![A-Za-z0-9])').test(reason || '') || new RegExp('(?:^|[\\s\u3000])' + id + '[：:]').test(reason || '');
}
function workLaneItems(events, approvals, registryState = () => '') {
  const starts = confirmedStarts(events), byTask = new Map(), item = id => byTask.get(id) || byTask.set(id, { taskId: id, last: null, start: null, approvals: { pending: 0, approved: 0, claimed: 0 }, registryState: registryState(id) || '' }).get(id);
  for (const row of events) {
    const r = row.raw; if (!r || isProbeEvent(r.reason) || isStateNotice(row, starts)) continue;  // OPS-141: a return with a presence stays
    const it = item(r.taskId);
    if (!it.last || Date.parse(r.at) >= Date.parse(it.last.at)) it.last = { event: row.event, ...r, start: starts.has(row.id) };
  }
  for (const row of events) { const r = row.raw, it = r && byTask.get(r.taskId); if (it && row.event === 'request' && !isProbeEvent(r.reason) && (!it.start || Date.parse(r.at) > Date.parse(it.start.at))) it.start = r; }
  for (const row of approvals) if (['pending', 'approved', 'claimed'].includes(row.status)) item(row.taskId).approvals[row.status]++;
  const time = it => it.last ? Date.parse(it.last.at) : 0;
  return [...byTask.values()].filter(it => it.last || it.approvals.pending + it.approvals.approved + it.approvals.claimed).sort((a, b) => time(b) - time(a) || a.taskId.localeCompare(b.taskId)).map(it => ({
    taskId: it.taskId, registryState: it.registryState, approvals: it.approvals,
    stage: it.last ? (it.last.start ? '着手' : it.last.event === 'work' && /^相談待ち[:：]/.test(it.last.reason) ? '相談待ち' : it.last.event === 'work' && /^検討中[:：]/.test(it.last.reason) ? it.last.owner + '検討中' : workLaneStages[it.last.event]) : '活動情報なし',
    owner: it.last?.owner || '', time: it.last?.shortTime || '', reason: it.last?.reason || '',
    // OPS-127: who picks it up next, from this task's latest practical event only (older values are not carried over).
    next: it.approvals.pending ? { kind: 'approval', text: '次：ユーザー（承認待ち）' } : it.last?.next === 'none' ? { kind: 'ended', text: 'この仕事は終了' } : it.last?.next === 'user' ? { kind: 'known', text: '次：ユーザー' } : it.last?.next ? { kind: 'known', text: '次：' + it.last.next } : { kind: 'unknown', text: '次：不明' },
    start: it.start ? '依頼 ' + it.start.shortTime : (it.last ? '開始：不明' : ''),
    startNote: it.start || !it.last ? '' : '開始：不明（記録範囲外または未記録）'
  }));
}
// OPS-153 区切り2: the card text, the approval badge, the title and the lane status are composed by pure functions;
// the card view only draws them, keeps node identity, focus and scroll.
function workCardViewModel(it) {
  const a = it.approvals, badge = a.pending + a.approved + a.claimed ? '承認 待ち' + a.pending + ' · 済み' + a.approved + (a.claimed ? ' · 確保' + a.claimed : '') : '承認なし';
  // OPS-132: the next taker / end has its own line right under the heading; nothing else is dropped.
  const lines = [it.taskId + ' · ' + it.stage, it.next ? it.next.text : '', [it.owner, it.time].filter(Boolean).join(' · ') + (it.reason ? ' · ' + it.reason : ''), 'Registry：' + (it.registryState || '不明') + ' · ' + badge, it.start];
  return { taskId: it.taskId, lines, title: lines.slice(0, 4).concat(it.startNote || it.start).filter(Boolean).join('\n'), stage: it.stage, next: it.next?.kind || 'unknown' };
}
function workLaneTrouble(activityTrouble, approvalTrouble) { const list = [activityTrouble && '活動の取得不調', approvalTrouble && '承認の取得不調'].filter(Boolean); return list.join(' · ') + (list.length ? ' · 最終情報を保持' : ''); }
function workLaneViewModel(items, trouble) { return { cards: items.map(workCardViewModel), status: (items.length ? items.length + '件' : '記録なし') + (trouble ? ' · ' + trouble : ''), stale: !!trouble }; }
function createWorkLaneView({ track, status, makeNode, getActive = () => null }) {
  const cards = new Map(); const set = (node, text) => { if (node.textContent !== text) node.textContent = text; };
  return {
    update(vm) {
      const active = getActive(), focused = active && track.contains(active), left = track.scrollLeft;
      const keep = new Set(vm.cards.map(i => i.taskId)); for (const [id, card] of cards) if (!keep.has(id) && !(focused && card.node.contains(active))) { card.node.remove(); cards.delete(id); }
      vm.cards.forEach((it, index) => {
        let card = cards.get(it.taskId);
        if (!card) { const node = makeNode('article'); node.className = 'approval-card work-card'; node.tabIndex = 0; const lines = ['strong', 'span', 'span', 'span', 'span'].map(t => makeNode(t)); lines[1].className = 'work-next'; lines.forEach(l => node.appendChild(l)); card = { node, lines }; cards.set(it.taskId, card); }
        it.lines.forEach((t, i) => set(card.lines[i], t)); if (card.node.title !== it.title) card.node.title = it.title; card.node.dataset.stage = it.stage; card.node.dataset.next = it.next;
        // Do not move cards while one has focus; only their text changes.
        if (!focused && track.children[index] !== card.node) track.insertBefore(card.node, track.children[index] || null);
      });
      track.scrollLeft = left;
      set(status, vm.status); status.dataset.stale = vm.stale ? 'true' : 'false';
    }
  };
}

// @endsection
// @section recent-control
// The work cards as one studio part (used alone in tests; the page uses the shared studio).
function createWorkLane({ view, registryState }) {
  const studio = createStudio({ views: { cards: view }, registryState });
  return { activity(rows) { studio.activity(rows); }, activityFailure() { studio.activityFailure(); }, approvals(rows) { studio.approvals(rows); }, approvalFailure() { studio.approvalFailure(); } };
}

// @endsection
