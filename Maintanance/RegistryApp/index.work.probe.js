// @section probe
function startApprovalProbe() {
  const status = $('probe-status');
  if (location.protocol === 'file:') { status.textContent = 'ローカルサーバーで表示できます'; return; }
  const view = createApprovalView({ track: $('probe-track'), history: $('probe-history'), historySummary: $('probe-history-summary'), status, policy: $('probe-policy'), all: $('probe-all'), dialog: $('probe-dialog'), detail: $('probe-detail'), close: $('probe-close'), makeNode: tag => document.createElement(tag) });
  const update = view.update;
  view.update = value => { update(value); const last = value.requests.filter(r => r.status === 'consumed').sort((a, b) => a.updatedAt.localeCompare(b.updatedAt)).at(-1); if (last) { $('probe-result').textContent = last.result + ' · Astra処理済み'; $('probe-result').style.color = last.color; } };
  const controller = createApprovalController({ fetchRecord: fetch, view, isHidden: () => document.hidden, schedule: setTimeout, cancel: clearTimeout, makeController: () => new AbortController(), endpoint: '/approval-probe' });
  view.bind(controller.act); document.addEventListener('visibilitychange', controller.visibility); controller.poll();
}
startApprovalProbe();


// @endsection
