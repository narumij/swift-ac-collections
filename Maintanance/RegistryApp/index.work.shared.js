// @section shared
// OPS-153 区切り4: one shared input snapshot and one derive per input. Each source (activity, approvals, continuity) keeps its
// last good value, whether its latest result succeeded, a generation and the receipt time; the sources are combined as they
// were received and never presented as one simultaneous server state. The clock and the UI state (the chosen WAKE owner,
// sending, the last result note, the kept member order) are inputs too. Every input derives the whole snapshot once and every
// view the studio has gets that same revision (a view may skip DOM writes for unchanged values). receivedAt is the studio's
// injectable wall clock in milliseconds since the epoch (Date.now by default); the continuity clock is performance.now().
// Late or failed answers are ordered at the input boundary: the activity and approval pollers are single-flight, and the
// continuity fetch drops older answers; a failed fetch is recorded as ok=false and keeps the last good value.
function emptyStudioSnapshot(parts, { registryState = () => '', withCurrent = true } = {}) {
  const source = value => ({ generation: 0, receivedAt: null, ok: null, value });
  return {
    revision: 0, parts: [...parts], registryState, withCurrent, last: '', clock: 0, activitySeen: null, freshOwners: new Set(),
    sources: { members: source({ members: [] }), activity: source([]), approvals: source([]), continuity: source(null), letters: source([]), letterDetail: source(null) },
    ui: { memberOrder: [], wakeSelected: '', wakeBusy: false, wakeSending: null, wakeNote: '', wakeNoteFor: '', letterSelected: '', letterMember: '', letterState: '', letterCursor: null }
  };
}
// Pure: the next snapshot for one input. A failed result keeps the last good value. A member-only or WAKE-only snapshot does
// only the work its parts need (the helpers of the other parts are not required). OPS-156 H-20261019-32: a letter-detail
// answer (or failure) for a letter that is no longer the chosen one is ignored: the same snapshot comes back and nothing is
// redrawn, so a slow old answer never shows as the new choice.
function applyStudioInput(s, input) {
  if (input.source === 'letterDetail' && input.forId !== s.ui.letterSelected) return s;
  // H-20261019-34: a list page answer (or failure) for another page or filter than the one now shown is ignored the same way.
  if (input.source === 'letters' && input.forKey !== undefined && input.forKey !== letterListKey(s.ui)) return s;
  const n = { ...s, sources: { ...s.sources }, ui: { ...s.ui }, revision: s.revision + 1, last: input.source, freshOwners: new Set() }, has = p => s.parts.includes(p);
  if (['members', 'activity', 'approvals', 'continuity', 'letters', 'letterDetail'].includes(input.source)) {
    const old = s.sources[input.source]; n.sources[input.source] = { generation: old.generation + 1, receivedAt: input.at ?? null, ok: !!input.ok, value: input.ok ? input.value : old.value, ...(old.key !== undefined ? { key: old.key } : {}) };
    if (input.source === 'continuity' && Number.isFinite(input.now)) n.clock = input.now;
    // H-20261019-35: a list page is kept with the key (page and filters) it was read for
    if (input.source === 'letters' && input.ok) n.sources.letters.key = input.forKey === undefined ? letterListKey(n.ui) : input.forKey;
    if (input.source === 'letters' && !input.ok) n.sources.letters.failureKey = input.forKey === undefined ? letterListKey(n.ui) : input.forKey;
    if (input.source === 'activity' && input.ok && has('members')) { const f = newRecordOwners(s.activitySeen, input.value); n.activitySeen = f.seen; n.freshOwners = f.owners; }
  } else if (input.source === 'clock') n.clock = input.now;
  else if (input.source === 'wake') Object.assign(n.ui, input.patch);
  else if (input.source === 'letters-ui') Object.assign(n.ui, input.patch);  // the chosen letter and the filters (UI inputs)
  else throw Error('Unknown studio input');
  // WAKE: the choice falls back to the first owner when it is no longer listed; a result note belongs to one owner and request.
  if (has('wake')) { const rows = n.sources.activity.value, sel = wakeSelection(wakeOwners(rows), n.ui.wakeSelected); n.ui.wakeSelected = sel; if (n.ui.wakeNoteFor !== wakeKey(rows, sel)) n.ui.wakeNote = ''; }
  return n;
}
// Continuity text: from the marks, the server time at receipt and the clock; a test seam may give a label function instead.
// A failed continuity fetch is the source's ok=false; the marks shown are the last good ones.
function studioContinuity(s) {
  const src = s.sources.continuity, v = src.value, failed = src.ok === false;
  if (!v) return { owners: [], text: () => failed ? '継続 不調' : '継続 未確認' };
  if (v.labelOf) return { owners: v.owners || [], text: v.labelOf };
  return { owners: v.base ? Object.keys(v.base.owners) : [], text: owner => continuityLabel(v.base, failed, s.clock, owner) };
}
// Pure: the view models of the requested parts, all of the same revision.
function deriveStudio(s, parts = s.parts) {
  const out = { revision: s.revision }, act = s.sources.activity, want = p => parts.includes(p);
  if (want('members')) {
    const cont = studioContinuity(s), entries = stableMemberOrder(s.ui.memberOrder, memberViewModels(s.sources.members.value, cont.owners, cont.text));
    out.members = { entries, order: entries.map(e => e.owner), fresh: s.last === 'activity' ? s.freshOwners : new Set(), failed: s.sources.members.ok === false, failureText: owner => memberFailureText(owner, cont.text) };
  }
  if (want('cards')) out.cards = workLaneViewModel(workLaneItems(act.value, s.sources.approvals.value, s.registryState), workLaneTrouble(act.ok === false, s.sources.approvals.ok === false));
  if (want('timeline')) out.timeline = act.ok === false ? { failed: true, text: ACTIVITY_FAILURE_TEXT } : activityTimelineViewModel(act.value, s.withCurrent);
  if (want('wake')) out.wake = wakeViewModel({ rows: act.value, selected: s.ui.wakeSelected, busy: s.ui.wakeBusy, note: s.ui.wakeNote });
  if (want('letters')) out.letters = lettersViewModel(s);
  return out;
}
// The one presenter: applies each input, derives once, and hands the parts that depend on that input to their views with the
// same revision. The shown member order is written back as a UI input. Operations (WAKE send) run here, never in a view.
function createStudio({ views, registryState, withCurrent = true, now = () => Date.now() }) {
  const parts = Object.keys(views).filter(k => views[k]); let s = emptyStudioSnapshot(parts, { registryState, withCurrent });
  const draw = {
    letters: (v, vm, rev) => v.show(vm, rev), members: (v, vm, rev) => { if (vm.failed) v.showFailure(vm.failureText, rev); else { v.show(vm.entries, vm.fresh, rev); v.recovered(); } },
    cards: (v, vm, rev) => v.update(vm, rev), timeline: (v, vm, rev) => vm.failed ? v.showFailure(vm.text, rev) : v.show(vm, rev), wake: (v, vm, rev) => v.show(vm, rev)
  };
  const input = x => {
    const next = applyStudioInput(s, x); if (next === s) return null; s = next; const vm = deriveStudio(s);
    if (vm.members) s = { ...s, ui: { ...s.ui, memberOrder: vm.members.order } };
    for (const p of parts) draw[p](views[p], vm[p], vm.revision); return vm;
  };
  const wakeNote = e => e && e.unknown ? '結果が分かりません。記録を読み直してから判断してください（自動では再送しません）' : '送信できませんでした：' + (e && e.message || '不明');
  return {
    input, snapshot: () => s,
    activity: rows => input({ source: 'activity', ok: true, value: rows, at: now() }), activityFailure: () => input({ source: 'activity', ok: false, at: now() }),
    approvals: rows => input({ source: 'approvals', ok: true, value: rows, at: now() }), approvalFailure: () => input({ source: 'approvals', ok: false, at: now() }),
    // from the continuity boundary: {base, failed}; a label function (labelOf, owners) is the isolated-test seam
    continuity: (data, perf) => input(data && data.failed ? { source: 'continuity', ok: false, at: now(), now: perf } : { source: 'continuity', ok: true, value: data && data.labelOf ? data : { base: data.base }, at: now(), now: perf }),
    tick: perf => input({ source: 'clock', now: perf }),
    // OPS-156 H-20261019-32: letters, read only (GET). The detail names the letter it was asked for.
    letters: (value, forKey) => input({ source: 'letters', ok: true, value, forKey, at: now() }), lettersFailure: forKey => input({ source: 'letters', ok: false, forKey, at: now() }),
    letterDetail: (forId, value) => input({ source: 'letterDetail', ok: true, value, forId, at: now() }), letterDetailFailure: forId => input({ source: 'letterDetail', ok: false, forId, at: now() }),
    letterSelect: id => input({ source: 'letters-ui', patch: { letterSelected: id } }), letterFilter: patch => input({ source: 'letters-ui', patch: { ...patch, letterCursor: null } }),
    letterPage: cursor => input({ source: 'letters-ui', patch: { letterCursor: cursor } }),
    wakeSelect: owner => input({ source: 'wake', patch: { wakeSelected: owner, wakeNote: '' } }),
    // The owner and its request state are fixed when the send starts; the result note belongs to them even if the choice changes
    // while waiting, so it is never shown for another owner.
    async wakeSend(send) {
      const owner = s.ui.wakeSelected; if (s.ui.wakeBusy || !owner) return; const sending = { owner, key: wakeKey(s.sources.activity.value, owner) };
      input({ source: 'wake', patch: { wakeBusy: true, wakeSending: sending } });
      let note; try { const result = await send(sending.owner); note = result && result.created === false ? '未応答の依頼があります（同じ依頼を表示しています）' : '送信しました。記録の反映を待っています'; } catch (e) { note = wakeNote(e); }
      input({ source: 'wake', patch: { wakeBusy: false, wakeSending: null, wakeNote: note, wakeNoteFor: sending.key } });
    }
  };
}

// @endsection
