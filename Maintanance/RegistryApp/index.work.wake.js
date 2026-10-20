// @section wake
// OPS-138: 待機完了. The user asks one owner (anyone already in the activity record, except the user) to end a continuous
// wait. The server fixes the WAKE ID, task and text; an unanswered request to the same owner comes back instead of a new
// one. "Answered" means a later record by that owner starting with exactly `ACK <id>`; until then it is only "依頼済み",
// never "終了". Nothing here starts or wakes a stopped AI, and nothing is resent automatically.
const WAKE_SENDER = 'ユーザー';
function wakeOwners(rows) { const seen = []; for (let i = rows.length - 1; i >= 0; i--) { const o = rows[i].raw?.owner; if (o && o !== WAKE_SENDER && !seen.includes(o)) seen.push(o); } return seen; }
function wakeStatus(rows, owner) {
  for (let i = rows.length - 1; i >= 0; i--) {
    const r = rows[i].raw || {}, m = /^(WAKE-\d{8}-[A-Z0-9]+)：/.exec(r.reason || '');
    if (r.owner === WAKE_SENDER && r.next === owner && rows[i].event === 'request' && m) {
      const ack = new RegExp('^ACK ' + m[1] + '(?![A-Za-z0-9])'), a = rows.slice(i + 1).find(x => x.raw?.owner === owner && ack.test(x.raw.reason || ''));
      return a ? { kind: 'acked', id: m[1], at: a.raw.at } : { kind: 'pending', id: m[1], at: r.at };
    }
  }
  return { kind: 'none' };
}
// OPS-153 区切り3: the 待機完了 control. The owner list, the button and the status text come from a pure view model; the
// chosen owner, "sending" and the last result note are inputs held here (UI and operation state), and the view only draws.
// The button state is display information, not a permission: the server re-checks every request.
function wakeSelection(owners, keep) { return owners.includes(keep) ? keep : owners[0] || ''; }
function wakeKey(rows, owner) { const st = owner ? wakeStatus(rows, owner) : { kind: 'none' }; return owner + '|' + st.kind + '|' + (st.id || ''); }
function wakeViewModel({ rows, selected, busy, note }) {
  const st = selected ? wakeStatus(rows, selected) : { kind: 'none' };
  const time = at => { const d = new Date(at); return Number.isFinite(d.getTime()) ? d.toLocaleTimeString('ja-JP', { hour12: false }) : ''; };
  return {
    owners: wakeOwners(rows), selected, disabled: busy || !selected || st.kind === 'pending',
    buttonTitle: st.kind === 'pending' ? 'この担当への依頼はまだACKがありません（' + st.id + '）' : '選んだ担当に待機終了を依頼します。届くのは待機中のAIだけです',
    text: busy ? '送信中…' : note || (st.kind === 'pending' ? '依頼済み・ACK待ち（' + time(st.at) + '）' : st.kind === 'acked' ? 'ACK済み・受信確認（' + time(st.at) + '）' : ''),
    kind: busy ? 'busy' : st.kind, statusTitle: st.kind === 'acked' ? 'ACKは受け取った確認です。待機が終わったかどうかは、その担当のメンバー状態（待機終了）で確かめます' : ''
  };
}
function createWakeView({ select, button, status, onChange, onClick }) {
  select.addEventListener('change', onChange); button.addEventListener('click', onClick);
  return {
    selected() { return select.value; },
    // The options are rebuilt only when the owner list changes; the chosen value is drawn as given.
    show(vm) {
      const current = [...select.options || []].map(o => o.value);
      if (vm.owners.join('\n') !== current.join('\n')) { while (select.options.length) select.remove(0); for (const o of vm.owners) { const opt = document.createElement('option'); opt.value = o; opt.textContent = o; select.add(opt); } }
      if (select.value !== vm.selected) select.value = vm.selected;
      button.disabled = vm.disabled; if (status.textContent !== vm.text) status.textContent = vm.text; status.dataset.kind = vm.kind; status.title = vm.statusTitle; button.title = vm.buttonTitle;
    }
  };
}
function createWakeControl({ select, button, status, send }) {
  const studio = createStudio({ views: { wake: createWakeView({ select, button, status, onChange: () => studio.wakeSelect(select.value), onClick: () => studio.wakeSend(send) }) } });
  return { rows(next) { studio.activity(next); } };
}
async function sendWake(owner) {
  const controller = new AbortController(), timer = setTimeout(() => controller.abort(), 5000);
  try {
    const response = await fetch('/activity-wake', { method: 'POST', headers: { 'X-Registry-Studio': 'activity-wake', 'Content-Type': 'application/json' }, body: JSON.stringify({ owner }), signal: controller.signal });
    const result = await response.json().catch(() => ({})); if (!response.ok) throw Error(result.error || '送信に失敗しました'); return result;
  }
  catch (e) { if (e && e.name === 'AbortError') { const unknown = Error('timeout'); unknown.unknown = true; throw unknown; } throw e; }
  finally { clearTimeout(timer); }
}



// @endsection
