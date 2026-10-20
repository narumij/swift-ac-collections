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
function createApprovalController({ fetchRecord, view, isHidden, schedule, cancel, makeController, endpoint = "/commit-approvals", autoPoll = true }) {
  let rows = [], fresh = false, busy = false, reading = false, generation = 0, timer = null, getController = null, pending = false, retries = 0;
  const clear = () => { if (timer !== null) { cancel(timer); timer = null; } };
  const later = () => { clear(); if (!isHidden() && !busy && !reading && (autoPoll || pending)) timer = schedule(poll, pending && !retries ? 0 : 3000); };
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
  function apply(value) { retries = 0; rows = value.requests; fresh = true; view.update(value); }
  async function poll() {
    clear(); if (isHidden()) return; if (reading || busy) { pending = true; return; }
    pending = false;
    reading = true; const mine = generation, controller = makeController(); getController = controller;
    try { const result = await request({ cache: 'no-store' }, controller); if (mine === generation && !isHidden()) apply(result); }
    catch (e) { if (mine === generation && !isHidden()) { fresh = false; if (retries++ < 2) pending = true; view.failure('取得不調 · 最終情報を保持。操作停止中'); } }
    finally { if (getController === controller) getController = null; reading = false; availability(); later(); }
  }
  async function act(action, targets) {
    // Copy the displayed click-time identities before any await or network activity.
    const snapshot = targets.map(({ id, revision }) => ({ id, revision }));
    if (!fresh || busy || isHidden() || !snapshot.length || !['approve', 'cancel'].includes(action)) return;
    if (new Set(snapshot.map(t => t.id)).size !== snapshot.length || snapshot.some(t => !rows.some(r => r.id === t.id && r.revision === t.revision && (action === 'approve' ? r.status === 'pending' : ['pending', 'approved'].includes(r.status))))) return;
    busy = true; fresh = false; generation++; clear(); if (getController) getController.abort(); availability();
    const controller = makeController(), mine = generation;
    try { const result = await request({ method: 'POST', headers: { 'Content-Type': 'application/json', 'X-Registry-Studio': endpoint.slice(1) }, body: JSON.stringify({ action, targets: snapshot }) }, controller); if (mine === generation && !isHidden()) apply(result); }
    catch (e) { view.failure(e.message + ' 最終情報を保持。操作停止中'); }
    finally { busy = false; availability(); later(); }
  }
  function visibility() { clear(); generation++; fresh = false; if (getController) getController.abort(); availability(); if (!isHidden()) poll(); }
  function disconnected() { clear(); pending = false; generation++; fresh = false; if (getController) getController.abort(); availability(); view.failure('取得不調 · 最終情報を保持。操作停止中'); }
  return { poll, act, visibility, disconnected, receive(value) { generation++; if (getController) getController.abort(); apply(value); availability(); } };
}
function createApprovalView({ track, status, policy, all, dialog, detail, close, makeNode, signals = false, extraStatuses = [], extraAllButtons = [] }) {
  const cards = new Map(); let rows = [], enabled = false, busy = false, action = () => { }, inspected = null;
  const statuses = [status, ...extraStatuses], allButtons = [all, ...extraAllButtons];
  const setStatus = text => statuses.forEach(node => { if (node.textContent !== text) node.textContent = text; });
  const stale = value => statuses.forEach(node => { node.dataset.stale = value; });
  const set = (node, text) => { if (node.textContent !== text) node.textContent = text; };
  function details(row) {
    inspected = row.id;
    set(detail, row.detailText);
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
      rows = value.visible; set(policy, value.policyNotice);
      setStatus(value.status);
      stale('false');
      const visible = rows.filter(r => !['consumed', 'cancelled'].includes(r.status));
      if (dialog.open && inspected) { const row = value.entries.find(r => r.id === inspected); if (row) details(row); }
      const keep = new Set(visible.map(r => r.id)); for (const [id, card] of cards) if (!keep.has(id)) { card.node.remove(); cards.delete(id); }
      let index = 0; const scrollLeft = track.scrollLeft;
      for (const row of visible) {
        let card = cards.get(row.id);
        if (!card) {
          const node = makeNode('article'), title = makeNode('strong'), state = makeNode('span'), buttons = makeNode('div'), inspect = makeNode('button'), approve = makeNode('button'), revoke = makeNode('button');
          node.className = 'approval-card'; buttons.className = 'approval-actions'; inspect.type = approve.type = revoke.type = 'button';
          set(inspect, '詳細'); set(approve, '承認'); buttons.appendChild(inspect); buttons.appendChild(approve); buttons.appendChild(revoke); node.appendChild(title); node.appendChild(state); node.appendChild(buttons);
          card = { node, title, state, inspect, approve, revoke, row }; cards.set(row.id, card);
          inspect.onclick = () => { details(card.row); if (!dialog.open) dialog.showModal(); };
          approve.onclick = () => action('approve', [{ id: card.row.id, revision: card.row.revision }]); revoke.onclick = () => action('cancel', [{ id: card.row.id, revision: card.row.revision }]);
        }
        card.row = row; set(card.title, row.heading); card.title.title = row.heading; set(card.state, row.stateText); card.node.dataset.status = row.status;
        if (track.children[index] !== card.node) track.insertBefore(card.node, track.children[index] || null);
        index++;
        if (dialog.open && inspected === row.id) details(row);
      }
      track.scrollLeft = scrollLeft; controls();
    },
    availability(value, inProgress) { enabled = value; busy = inProgress; controls(); if (busy) setStatus('変更を確認中 · 操作停止中'); },
    failure(message) { setStatus(message); stale('true'); }
  };
}
// @endsection
