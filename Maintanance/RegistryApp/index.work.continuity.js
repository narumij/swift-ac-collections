// @section continuity
// OPS-139/141: the members' own one-shot continuity marks (continuity.py), shown in the member states of the work area.
// The age is the server clock at fetch time plus the time elapsed here since, minus the mark's time, so neither a late
// response nor this browser's clock makes an old mark look fresh. Over 55 s means only "the confirmation is old": the
// declared state is not changed, and a long tool run looks the same. Fetch trouble is shown as such.
const CONTINUITY_LIMIT_MS = 55000;
function continuityState(mark, ageMs, failed) {
  if (failed) return { kind: 'trouble', label: '継続 不調' + (mark ? '（最後に読めた確認 ' + memberTime(mark.at) + '）' : '') };
  if (!mark || ageMs === null || !Number.isFinite(ageMs) || ageMs < -5000) return { kind: 'unknown', label: '継続 未確認' + (mark ? '（時刻が未来）' : '') };
  if (mark.state === 'ended') return { kind: 'ended', label: '連続動作の終了 ' + memberTime(mark.at) };
  if (ageMs <= CONTINUITY_LIMIT_MS) return { kind: 'alive', label: '継続 ' + memberTime(mark.at) + '（' + Math.max(0, Math.round(ageMs / 1000)) + '秒前）' };
  return { kind: 'lapsed', label: '継続 確認が古い（' + memberTime(mark.at) + '、' + Math.ceil(ageMs / 1000) + '秒前）' };
}
// Pure: one owner's continuity text from the last good marks, the fetch state and the clock (shared by the snapshot derive).
function continuityLabel(base, failed, now, owner) { const mark = base?.owners[owner] || null, age = mark ? base.serverMs + (now - base.perf) - Date.parse(mark.at) : null; return continuityState(mark, age, failed).label; }
function validateContinuity(value) {
  if (!value || typeof value !== 'object' || !Number.isFinite(Date.parse(value.serverNow)) || !value.owners || typeof value.owners !== 'object' || Array.isArray(value.owners)) throw Error('Invalid continuity');
  for (const mark of Object.values(value.owners)) if (!mark || !['alive', 'ended'].includes(mark.state) || !Number.isFinite(Date.parse(mark.at))) throw Error('Invalid continuity mark');
  return { serverMs: Date.parse(value.serverNow), owners: value.owners };
}
// The continuity input boundary: a late or older answer never replaces a newer one. onData passes the accepted marks and the
// fetch state to the snapshot; onChange (label function and owners) is kept for the isolated continuity test.
function createContinuityStatus({ onChange = null, onData = null, fetchRecord, now = () => performance.now() }) {
  let seq = 0, applied = 0, base = null, failed = false;
  const paint = () => { if (!onChange) return; const owners = base ? Object.keys(base.owners) : [], t = now(); onChange(owner => continuityLabel(base, failed, t, owner), owners); };
  const poll = async () => {
    const mine = ++seq; try {
      const got = validateContinuity(await fetchRecord());
      if (mine < applied || (base && got.serverMs < base.serverMs)) return;  // a late or older answer never replaces a newer one
      applied = mine; base = { ...got, perf: now() }; failed = false;
    } catch (e) { if (mine >= applied) failed = true; } if (onData) onData({ base, failed }); paint();
  };
  return { poll, paint };
}

// @endsection
