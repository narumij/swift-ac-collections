// @section approvals
// OPS-114: this lane owns only approval DOM and HTTP state, never the editor.
const approvalStatusLabels = { pending: '承認待ち', approved: '承認済み', claimed: '実行直前に確保済み・取消不可', consumed: '使用済み', cancelled: '取消済み' };
function validateApprovalList(value) {
  if (!value || !Array.isArray(value.requests) || typeof value.policyNotice !== 'string') throw Error('Invalid approval list');
  const seen = new Set();
  const requests = value.requests.map(row => {
    if (!row || typeof row.id !== 'string' || !row.id || seen.has(row.id) || !Number.isSafeInteger(row.revision) || row.revision < 1 || !Object.hasOwn(approvalStatusLabels, row.status)) throw Error('Invalid approval identity');
    for (const key of ['taskId', 'title', 'scope', 'condition', 'branch', 'createdAt', 'updatedAt']) if (typeof row[key] !== 'string') throw Error('Invalid approval content');
    if (!Array.isArray(row.paths) || !row.paths.length || row.paths.some(path => typeof path !== 'string' || !path)) throw Error('Invalid approval paths');
    for (const key of ['approvedAt', 'commitSha']) if (row[key] != null && typeof row[key] !== 'string') throw Error('Invalid approval history');
    seen.add(row.id); return { ...row, paths: [...row.paths] };
  });
  return { requests, policyNotice: value.policyNotice };
}
function createApprovalController({ fetchRecord, view, isHidden, schedule, cancel, makeController, endpoint = "/commit-approvals" }) {
  let rows = [], fresh = false, busy = false, reading = false, generation = 0, timer = null, getController = null;
  const clear = () => { if (timer !== null) { cancel(timer); timer = null; } };
  const later = () => { clear(); if (!isHidden() && !busy && !reading) timer = schedule(poll, 3000); };
  const availability = () => view.availability(fresh && !busy && !isHidden(), busy);
  async function request(options, controller) {
    let timeout;
    try {
      return await Promise.race([
        (async () => { const response = await fetchRecord(endpoint, { ...options, signal: controller.signal }); if (!response.ok) throw Error(response.status === 409 ? '依頼が更新されました。確認し直してください。' : '取得・変更に失敗しました。'); return validateApprovalList(await response.json()); })(),
        new Promise((_, reject) => { timeout = schedule(() => { controller.abort(); reject(Error('応答がありません。')); }, 5000); controller.signal.addEventListener('abort', () => reject(Error('中断しました。')), { once: true }); })
      ]);
    } finally { cancel(timeout); }
  }
  function apply(value) { rows = value.requests; fresh = true; view.update(value); }
  async function poll() {
    clear(); if (isHidden() || reading || busy) return;
    reading = true; const mine = generation, controller = makeController(); getController = controller;
    try { const result = await request({ cache: 'no-store' }, controller); if (mine === generation && !isHidden()) apply(result); }
    catch (e) { if (mine === generation && !isHidden()) { fresh = false; view.failure('取得不調 · 最終情報を保持。操作停止中'); } }
    finally { if (getController === controller) getController = null; reading = false; availability(); later(); }
  }
  async function act(action, targets) {
    // Copy the displayed click-time identities before any await or network activity.
    const snapshot = targets.map(({ id, revision }) => ({ id, revision }));
    if (!fresh || busy || isHidden() || !snapshot.length || !['approve', 'cancel'].includes(action)) return;
    if (new Set(snapshot.map(t => t.id)).size !== snapshot.length || snapshot.some(t => !rows.some(r => r.id === t.id && r.revision === t.revision && (action === 'approve' ? r.status === 'pending' : ['pending', 'approved'].includes(r.status))))) return;
    busy = true; fresh = false; generation++; clear(); if (getController) getController.abort(); availability();
    const controller = makeController();
    try { const result = await request({ method: 'POST', headers: { 'Content-Type': 'application/json', 'X-Registry-Studio': endpoint.slice(1) }, body: JSON.stringify({ action, targets: snapshot }) }, controller); apply(result); }
    catch (e) { view.failure(e.message + ' 最終情報を保持。操作停止中'); }
    finally { busy = false; availability(); later(); }
  }
  function visibility() { clear(); generation++; fresh = false; if (getController) getController.abort(); availability(); if (!isHidden()) poll(); }
  return { poll, act, visibility };
}
function createApprovalView({ track, history, historySummary, status, policy, all, dialog, detail, close, makeNode, signals = false, extraStatuses = [], extraAllButtons = [] }) {
  const cards = new Map(); let rows = [], enabled = false, busy = false, action = () => { }, inspected = null;
  const statuses = [status, ...extraStatuses], allButtons = [all, ...extraAllButtons];
  const setStatus = text => statuses.forEach(node => { if (node.textContent !== text) node.textContent = text; });
  const stale = value => statuses.forEach(node => { node.dataset.stale = value; });
  const set = (node, text) => { if (node.textContent !== text) node.textContent = text; };
  function details(row) {
    inspected = row.id;
    set(detail, ['依頼：' + row.id + ' / revision ' + row.revision, 'タスク：' + row.taskId + ' · ' + row.title, '状態：' + approvalStatusLabels[row.status], '目的・範囲：\n' + row.scope, '対象ファイル：\n' + row.paths.join('\n'), '受入条件：\n' + row.condition, 'branch：' + row.branch, '登録：' + row.createdAt, '更新：' + row.updatedAt, '承認：' + (row.approvedAt || '未承認'), '実コミット：' + (row.commitSha || '未記録')].join('\n\n'));
  }
  close.onclick = () => dialog.close();
  function controls() {
    const count = rows.filter(r => r.status === 'pending').length; for (const button of allButtons) { set(button, '表示中の未承認' + count + '件を承認'); button.disabled = !enabled || !count; }
    for (const { row, approve, revoke } of cards.values()) {
      approve.hidden = row.status !== 'pending'; approve.disabled = !enabled || row.status !== 'pending';
      revoke.hidden = !['pending', 'approved', 'claimed'].includes(row.status); revoke.disabled = !enabled || !['pending', 'approved'].includes(row.status);
      set(revoke, row.status === 'claimed' ? '取消不可' : '取消');
    }
  }
  for (const button of allButtons) button.onclick = () => action('approve', rows.filter(r => r.status === 'pending').map(({ id, revision }) => ({ id, revision })));
  return {
    bind(fn) { action = fn; },
    update(value) {
      rows = value.requests; set(policy, value.policyNotice);
      const pending = rows.filter(r => r.status === 'pending').length, approved = rows.filter(r => r.status === 'approved').length, claimed = rows.filter(r => r.status === 'claimed').length;
      setStatus(signals ? ([pending && '🔴 承認待ち ' + pending + '件', approved && '🟢 承認済み・Astra未処理 ' + approved + '件', claimed && '🟡 Astra処理中 ' + claimed + '件'].filter(Boolean).join(' · ') || '⚪ 未処理なし') : (rows.length ? '承認待ち ' + pending + '件 · 承認済み ' + approved + '件' : '依頼なし'));
      stale('false');
      const keep = new Set(rows.map(r => r.id)); for (const [id, card] of cards) if (!keep.has(id)) { card.node.remove(); cards.delete(id); }
      const positions = new Map([[track, 0], [history, 0]]), scrolls = [track.scrollLeft, history.scrollLeft, history.scrollTop];
      for (const row of rows) {
        let card = cards.get(row.id);
        if (!card) {
          const node = makeNode('article'), title = makeNode('strong'), state = makeNode('span'), buttons = makeNode('div'), inspect = makeNode('button'), approve = makeNode('button'), revoke = makeNode('button');
          node.className = 'approval-card'; buttons.className = 'approval-actions'; inspect.type = approve.type = revoke.type = 'button';
          set(inspect, '詳細'); set(approve, '承認'); buttons.appendChild(inspect); buttons.appendChild(approve); buttons.appendChild(revoke); node.appendChild(title); node.appendChild(state); node.appendChild(buttons);
          card = { node, title, state, inspect, approve, revoke, row }; cards.set(row.id, card);
          inspect.onclick = () => { details(card.row); if (!dialog.open) dialog.showModal(); };
          approve.onclick = () => action('approve', [{ id: card.row.id, revision: card.row.revision }]); revoke.onclick = () => action('cancel', [{ id: card.row.id, revision: card.row.revision }]);
        }
        card.row = row; set(card.title, row.taskId + ' · ' + row.title); card.title.title = row.taskId + ' · ' + row.title; set(card.state, approvalStatusLabels[row.status]); card.node.dataset.status = row.status;
        const parent = ['consumed', 'cancelled'].includes(row.status) ? history : track, index = positions.get(parent); positions.set(parent, index + 1);
        if (parent.children[index] !== card.node) parent.insertBefore(card.node, parent.children[index] || null);
        if (dialog.open && inspected === row.id) details(row);
      }
      track.scrollLeft = scrolls[0]; history.scrollLeft = scrolls[1]; history.scrollTop = scrolls[2];
      set(historySummary, '使用・取消の履歴（' + rows.filter(r => ['consumed', 'cancelled'].includes(r.status)).length + '件）'); controls();
    },
    availability(value, inProgress) { enabled = value; busy = inProgress; controls(); if (busy) setStatus('変更を確認中 · 操作停止中'); },
    failure(message) { setStatus(message); stale('true'); }
  };
}
function startCommitApprovals() {
  const status = $('approval-status');
  if (location.protocol === 'file:' || typeof fetch !== 'function') { status.textContent = $('header-approval-status').textContent = 'ローカルサーバーで表示できます'; return; }
  const view = createApprovalView({ track: $('approval-track'), history: $('approval-history'), historySummary: $('approval-history-summary'), status, policy: $('approval-policy'), all: $('approval-all'), dialog: $('approval-dialog'), detail: $('approval-detail'), close: $('approval-close'), makeNode: tag => document.createElement(tag), signals: true, extraStatuses: [$('header-approval-status')], extraAllButtons: [$('header-approval-all')] });
  const laneView = { update(value) { view.update(value); workLaneInstance().approvals(value.requests); }, failure(message) { view.failure(message); workLaneInstance().approvalFailure(); }, availability: (value, inProgress) => view.availability(value, inProgress), bind: fn => view.bind(fn) };
  const controller = createApprovalController({ fetchRecord: fetch, view: laneView, isHidden: () => document.hidden, schedule: setTimeout, cancel: clearTimeout, makeController: () => new AbortController() });
  view.bind(controller.act); document.addEventListener('visibilitychange', controller.visibility); controller.poll();
}
startCommitApprovals();

// @endsection
