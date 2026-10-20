// @section events
// OPS-111: isolated history rows; no edit document, render, save or sync access.
const activityLabels = { request: '依頼', work: '作業', verification: '確認', acceptance: '受入', return: '返却', recheck: '再確認', complete: '完了', 'awaiting-commit': 'コミット待ち', commit: 'コミット' };
function validateActivityRows(value, kind) {
  if (!Array.isArray(value) || value.length > (kind === 'events' ? 200 : 30)) throw Error('Invalid rows');
  const seen = new Set(), text = (v, n, required = true) => { if (typeof v !== 'string' || v.length > n || (required && !v.trim()) || /[\x00-\x1f\x7f]/.test(v)) throw Error('Invalid text'); return v; };
  return value.map(v => {
    if (!v || typeof v !== 'object' || Array.isArray(v)) throw Error('Invalid row');
    const at = text(v.timestamp, 40); if (!/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.\d{1,3})?(?:Z|[+-]\d{2}:\d{2})$/.test(at) || !Number.isFinite(Date.parse(at))) throw Error('Invalid time');
    const shortTime = new Intl.DateTimeFormat(undefined, { month: '2-digit', day: '2-digit', hour: '2-digit', minute: '2-digit', second: '2-digit', hour12: false }).format(new Date(at));
    const localTime = new Intl.DateTimeFormat(undefined, { year: 'numeric', month: '2-digit', day: '2-digit', hour: '2-digit', minute: '2-digit', second: '2-digit', hour12: false, timeZoneName: 'short' }).format(new Date(at));
    let row;
    if (kind === 'events') {
      const id = text(v.id, 36), taskId = text(v.taskId, 40), event = text(v.event, 24), owner = text(v.owner, 80), reason = text(v.reason ?? '', 240, false), sha = text(v.commitSha ?? '', 40, false), next = text(v.next ?? '', 80, false), presence = v.presence ?? '';
      if (presence && !['waiting', 'ended', 'working'].includes(presence)) throw Error('Invalid presence');
      if (v.schemaVersion !== 1 || !(/^[a-f0-9]{32}$/).test(id) || !(/^[A-Z][A-Z0-9]*-[0-9]+$/).test(taskId) || !Object.hasOwn(activityLabels, event) || (sha && !(/^[a-f0-9]{40}$/).test(sha))) throw Error('Invalid event');
      const label = event === 'work' && /^検討中[:：]/.test(reason) ? '検討中' : activityLabels[event];
      const who = event === 'request' && next && !['none', 'unknown'].includes(next) ? owner + ' → ' + next : owner;  // user amendment: request cards show sender → recipient as recorded
      row = { id, event, raw: { taskId, owner, reason, at, shortTime, next, presence }, heading: taskId + ' · ' + who + ' · ' + label, detail: owner + ' · ' + shortTime + (reason ? ' · ' + reason : '') + (sha ? ' · ' + sha.slice(0, 8) : ''), title: taskId + ' · ' + label + ' · ' + owner + ' · ' + localTime + (reason ? ' · ' + reason : '') + (sha ? ' · commit ' + sha : '') };
    } else {
      const sha = text(v.sha, 40), subject = text(v.subject, 4096, false); if (!/^[a-f0-9]{40}$/.test(sha)) throw Error('Invalid commit');
      row = { id: sha, heading: sha.slice(0, 8) + ' · ' + subject, detail: shortTime, title: sha + ' · ' + localTime + ' · ' + subject };
    }
    if (seen.has(row.id)) throw Error('Duplicate identity'); seen.add(row.id); return row;
  });
}
// OPS-151: the one parser for a formal request ID at the very start of a reason ("H-20261019-05着手：…", "D-20261019-02：…").
// The ID ends at a non-alphanumeric boundary, so 02 never matches 020. Connectivity and update IDs are not requests.
function leadingRequestId(reason) {
  const m = /^([A-Z][A-Z0-9]*-\d{8}-[A-Z0-9]+)(?![A-Za-z0-9])/.exec(reason || '');
  return m && !/^(?:PING|WAKE|UPDATE)-/.test(m[1]) ? m[1] : '';
}
// A work record with a presence is a state notice and stays out of the lanes, except a confirmed start: working, whose
// leading request ID matches an earlier request of the same task addressed to this owner. Nothing else is guessed as a start.
function confirmedStarts(rows) {
  const asked = new Set(), starts = new Set();
  for (const row of rows) {
    const r = row.raw, id = r && leadingRequestId(r.reason); if (!id) continue;
    if (row.event === 'request' && r.next) asked.add(id + '\n' + r.taskId + '\n' + r.next);
    else if (row.event === 'work' && r.presence === 'working' && asked.has(id + '\n' + r.taskId + '\n' + r.owner)) starts.add(row.id);
  }
  return starts;
}
function isStateNotice(row, starts) { return !!(row.raw?.presence && row.event === 'work' && !starts.has(row.id)); }
function createActivityPoller({ kind, fetchRecord, view, isHidden, schedule, cancel, makeController }) {
  let inFlight = false, timer = null, controller = null;
  async function poll() {
    if (isHidden() || inFlight) return;
    inFlight = true; controller = makeController(); const active = controller;
    const timeout = schedule(() => active.abort(), 5000);
    try { const response = await fetchRecord('/activity-' + kind, { cache: 'no-store', signal: active.signal }); if (!response.ok) throw Error('Unavailable'); const rows = validateActivityRows(await response.json(), kind); if (!isHidden()) view.update(rows); }
    catch (e) { if (!isHidden()) view.failure(); }
    finally { cancel(timeout); controller = null; inFlight = false; if (!isHidden()) timer = schedule(poll, 3000); }
  }
  function visibility() { if (timer !== null) { cancel(timer); timer = null; } if (isHidden()) { if (controller) controller.abort(); } else poll(); }
  return { poll, visibility };
}
// OPS-153 区切り3: the timeline cards, their age step, the current band and the status text are composed by pure functions;
// the timeline view only draws them, keeps node identity, the follow/anchor scroll and focus.
function currentBandViewModel(rows) {
  const starts = confirmedStarts(rows), latest = rows.filter(row => !isProbeEvent(row.raw?.reason) && !isStateNotice(row, starts)).at(-1);
  return latest ? { heading: '現在：' + latest.heading, detail: latest.detail, title: latest.title || '' } : { heading: '現在の作業：未登録', detail: '担当が更新する進行記録です。', title: '' };
}
// OPS-138: one quiet step only: every card except the newest gets a slightly darker background.
// The current band is derived only for a timeline that shows one (withCurrent); otherwise it is null.
function activityTimelineViewModel(rows, withCurrent = true) { return { cards: rows.map((row, index) => ({ id: row.id, heading: row.heading, title: row.title, event: row.event || '', age: index === rows.length - 1 ? 'latest' : 'older' })), current: withCurrent ? currentBandViewModel(rows) : null, status: rows.length ? '' : '記録なし' }; }
const ACTIVITY_FAILURE_TEXT = '取得不調 · 最終情報を保持';
function createActivityTimelineView(track, status, makeNode, getActive = () => null, current = null) {
  const nodes = new Map(); let first = true;
  const set = (node, text) => { if (node.textContent !== text) node.textContent = text; };
  return {
    show(vm) {
      const active = getActive(), focusedCard = active && active !== track && track.contains(active);
      const follow = !focusedCard && (first || track.scrollWidth - track.clientWidth - track.scrollLeft <= 24), oldLeft = track.scrollLeft;
      const keep = new Set(vm.cards.map(card => card.id)), left = track.getBoundingClientRect().left;
      const retained = [...nodes].filter(([id]) => keep.has(id)).map(([, node]) => ({ node, rect: node.getBoundingClientRect() }));
      const anchor = retained.find(({ rect }) => rect.right > left && rect.left < left + track.clientWidth) || retained[0];
      const offset = anchor ? anchor.rect.left - left : 0;
      for (const [id, node] of nodes) if (!keep.has(id)) { node.remove(); nodes.delete(id); }
      vm.cards.forEach((card, index) => {
        let node = nodes.get(card.id);
        if (!node) { node = makeNode('article'); node.className = 'activity-card'; node.tabIndex = 0; node.appendChild(makeNode('strong')); nodes.set(card.id, node); }
        set(node.children[0], card.heading); node.dataset.event = card.event; if (node.title !== card.title) node.title = card.title;
        if (node.dataset.age !== card.age) node.dataset.age = card.age;
        if (track.children[index] !== node) track.insertBefore(node, track.children[index] || null);
      });
      if (follow) track.scrollLeft = track.scrollWidth; else if (anchor) track.scrollLeft += anchor.node.getBoundingClientRect().left - track.getBoundingClientRect().left - offset; else track.scrollLeft = oldLeft;
      if (current && vm.current) { set(current.heading, vm.current.heading); set(current.detail, vm.current.detail); current.heading.title = vm.current.title; current.detail.title = vm.current.title; }
      first = false; set(status, vm.status); status.dataset.stale = 'false';
    },
    showFailure(text) { set(status, text); status.dataset.stale = 'true'; }
  };
}
function createActivityView(track, status, makeNode, getActive = () => null, current = null) {
  const studio = createStudio({ views: { timeline: createActivityTimelineView(track, status, makeNode, getActive, current) }, withCurrent: !!current });
  return { update(rows) { studio.activity(rows); }, failure() { studio.activityFailure(); } };
}

// @endsection
// @section events-start
function startActivityTimelines() {
  for (const kind of ['events']) {
    const status = $('activity-' + kind + '-status');
    if (location.protocol === 'file:' || typeof fetch !== 'function') { status.textContent = 'ローカルサーバーで表示できます'; continue; }
    // OPS-153: the activity poller feeds the one shared studio; the timeline, cards, members and WAKE are its views.
    const view = { update(rows) { workLaneInstance().activity(rows); }, failure() { workLaneInstance().activityFailure(); } };
    const poller = createActivityPoller({ kind, fetchRecord: fetch, view, isHidden: () => document.hidden, schedule: setTimeout, cancel: clearTimeout, makeController: () => new AbortController() });
    document.addEventListener('visibilitychange', poller.visibility); poller.poll();
  }
}

// @endsection
