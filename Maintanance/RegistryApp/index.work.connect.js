// @section connect
// Observable browser interaction state. Domain display state comes from WorkState;
// selection and in-flight commands are private to this browser, never shared between users.
class WorkPageViewModel {
  constructor() { this.listeners = new Set(); this.value = null; this.selected = ''; this.busy = false; this.note = ''; this.noteKey = ''; this.connected = false; }
  subscribe(listener) { this.listeners.add(listener); if (this.value) listener(this.snapshot()); return () => this.listeners.delete(listener); }
  publish() { if (this.value) { const value = this.snapshot(); for (const listener of this.listeners) listener(value); } }
  wakeKey() { const st = this.value?.wake.statuses[this.selected] || { kind: 'none' }; return this.selected + '|' + st.kind + '|' + (st.id || ''); }
  receive(value) { this.value = value; this.connected = true; if (!value.wake.owners.includes(this.selected)) this.selected = value.wake.owners[0] || ''; if (this.noteKey !== this.wakeKey()) this.note = ''; this.publish(); }
  disconnected() { this.connected = false; this.publish(); }
  select(owner) { this.selected = owner; this.note = ''; this.publish(); }
  snapshot() {
    const state = this.value.wake.statuses[this.selected] || { kind: 'none' };
    const time = at => new Date(at).toLocaleTimeString('ja-JP', { hour12: false });
    return { ...this.value, connected: this.connected, cards: this.connected ? this.value.cards : { ...this.value.cards, stale: true, status: this.value.cards.status + ' · 接続不調 · 最終情報を保持' }, wake: {
      owners: this.value.wake.owners, selected: this.selected,
      disabled: this.busy || !this.selected || state.kind === 'pending',
      buttonTitle: state.kind === 'pending' ? 'この担当への依頼はまだACKがありません（' + state.id + '）' : '選んだ担当に待機終了を依頼します。届くのは待機中のAIだけです',
      text: this.busy ? '送信中…' : this.note || (state.kind === 'pending' ? '依頼済み・ACK待ち（' + time(state.at) + '）' : state.kind === 'acked' ? 'ACK済み・受信確認（' + time(state.at) + '）' : ''),
      kind: this.busy ? 'busy' : state.kind,
      statusTitle: state.kind === 'acked' ? 'ACKは受け取った確認です。待機が終わったかどうかは、その担当のメンバー状態（待機終了）で確かめます' : ''
    } };
  }
  async send(send) {
    if (!this.value || this.snapshot().wake.disabled) return;
    const owner = this.selected, key = this.wakeKey(); this.busy = true; this.publish();
    let note;
    try { const result = await send(owner); note = result && result.created === false ? '未応答の依頼があります（同じ依頼を表示しています）' : '送信しました。記録の反映を待っています'; }
    catch (e) { note = e?.unknown ? '結果が分かりません。記録を読み直してから判断してください（自動では再送しません）' : '送信できませんでした：' + (e?.message || '不明'); }
    this.busy = false;
    if (this.selected === owner && this.wakeKey() === key) { this.note = note; this.noteKey = key; }
    this.publish();
  }
}
function startWorkPage() {
  if (location.protocol === 'file:') return;
  const make = tag => document.createElement(tag), model = new WorkPageViewModel();
  const timeline = createActivityTimelineView($('activity-events'), $('activity-events-status'), make, () => document.activeElement, { heading: $('activity-current-heading'), detail: $('activity-current-detail') });
  const cards = createWorkLaneView({ track: $('work-lane-track'), status: $('work-lane-status'), makeNode: make, getActive: () => document.activeElement });
  const wake = createWakeView({ select: $('wake-owner'), button: $('wake-send'), status: $('wake-status'), onChange: () => model.select($('wake-owner').value), onClick: () => model.send(sendWake) });
  const approval = createApprovalView({ track: $('approval-track'), status: $('approval-status'), policy: $('approval-policy'), all: $('approval-all'), dialog: $('approval-dialog'), detail: $('approval-detail'), close: $('approval-close'), makeNode: make, extraStatuses: [$('header-approval-status')], extraAllButtons: [$('header-approval-all')] });
  const commands = createApprovalController({ fetchRecord: fetch, view: { update() {}, availability: approval.availability, failure: approval.failure }, isHidden: () => document.hidden, schedule: setTimeout, cancel: clearTimeout, makeController: () => new AbortController(), autoPoll: false });
  approval.bind(commands.act);
  model.subscribe(value => {
    timeline.show(value.timeline); if (!value.connected || value.failed.activity) timeline.showFailure(ACTIVITY_FAILURE_TEXT);
    cards.update(value.cards); wake.show(value.wake); approval.update(value.approvals);
    if (!value.connected || value.failed.approvals) commands.disconnected(); else commands.receive(value.approvals);
  });
  let stream;
  function connect() {
    if (stream) stream.close();
    commands.disconnected();
    if (document.hidden) return;
    stream = new EventSource('/work-state/events');
    stream.onmessage = event => { try { const value = JSON.parse(event.data); model.receive(value); } catch (_) { model.disconnected(); commands.disconnected(); } };
    stream.onerror = () => { model.disconnected(); commands.disconnected(); };
  }
  document.addEventListener('visibilitychange', connect);
  window.addEventListener('pagehide', () => { if (stream) stream.close(); });
  window.addEventListener('pageshow', event => { if (event.persisted) connect(); });
  connect();
  const memberView = createMemberLampView({ box: $('presence-lamps'), makeNode: make });
  let order = [], seen = null, memberEntries = [];
  const memberEvents = new EventSource('/members/events');
  memberEvents.onmessage = event => {
    try { const value = JSON.parse(event.data), entries = stableMemberOrder(order, memberViewModels(value)); order = entries.map(e => e.owner); memberEntries = entries; memberView.show(entries); memberView.recovered(); }
    catch (_) { memberView.showFailure(owner => owner + '：取得不調'); }
  };
  memberEvents.onerror = () => memberView.showFailure(owner => owner + '：取得不調');
  // Preserve the existing new-activity flash while member details remain owned by MemberState.
  model.subscribe(value => { const fresh = newRecordOwners(seen, value.activity); seen = fresh.seen; if (memberEntries.length && !memberView.stale()) memberView.show(memberEntries, fresh.owners); });
  window.addEventListener('pagehide', () => memberEvents.close());
  window.addEventListener('pageshow', event => { if (event.persisted) window.location.reload(); });
}
// @endsection
