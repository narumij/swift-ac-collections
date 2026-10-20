// @section letters
// OPS-156 H-20261019-32: letters, read only. Pure view model from the brief list, the chosen letter's detail and the UI
// inputs (chosen ID, filters). The list has no texts (brief), so a row is told by its ID, task and sender → recipient.
// The detail is shown only for the chosen letter; the last good detail is kept only while it is that same letter.
const LETTER_STATE_CHOICES = [['', 'すべて'], ['sent', '未受領'], ['received', '受領'], ['started', '担当中'], ['withdrawn', '停止要請'], ['stopped', '停止済み（本人の応答）'], ['returned', '返答済み'], ['declined', '辞退'], ['closed', '閉じた']];
const LETTER_EVENT_LABELS = { sent: '送信', received: '受領', started: '着手', returned: '返答', declined: '辞退', withdrawn: '停止要請（取り下げ）', stopped: '停止の応答', closed: '閉じた', revised: '改訂' };
function letterTime(at) { const d = new Date(at); return Number.isFinite(d.getTime()) ? d.toLocaleString('ja-JP', { hour12: false }) : String(at || ''); }
function letterReceipt(l) {
  const latest = l.requestRevision ?? (l.request && l.request.revision);
  if (l.requestRevisionAtReceipt == null) return 'まだ受領していない（最新 v' + (latest ?? '?') + '）';
  return l.revisedAfterReceipt ? '受領した版 v' + l.requestRevisionAtReceipt + '／最新 v' + latest + '（受領のあとに改訂あり）' : '受領した版 v' + l.requestRevisionAtReceipt + '（最新）';
}
// H-20261019-34: the list is one page of the server's brief list (newest first), already filtered on the server. The page
// key (cursor and filters) is a UI input; polling re-reads the page shown, it never jumps back to the newest by itself.
function letterListKey(ui) { return JSON.stringify([ui.letterCursor, ui.letterMember, ui.letterState]); }
function letterListQuery(ui) { const q = [['brief', '1'], ['limit', '50'], ['cursor', ui.letterCursor], ['member', ui.letterMember], ['state', ui.letterState]].filter(([, v]) => v); return '/letters?' + q.map(([k, v]) => k + '=' + encodeURIComponent(v)).join('&'); }
// CP-20261020-002: every event time is the server time of that event; only the send and the recipient's own receipt have
// their own names, the others are "記録日時" (a proxy record is not a receipt)
function letterTimeLabel(event, effective) { return event === 'sent' ? '送信日時' : event === 'received' && effective ? '受領日時' : '記録日時'; }
function lettersViewModel(s) {
  const src = s.sources.letters, det = s.sources.letterDetail, ui = s.ui, last = src.value && !Array.isArray(src.value) ? src.value : { letters: src.value || [], hasMore: false, nextCursor: null };
  // H-20261019-35: the last good page belongs to the key it was read for. While the page or filters shown differ from it, it
  // is not presented as the result of the new ones and its cursor is not offered (that would skip the new first page).
  const current = src.key === undefined || src.key === letterListKey(ui), page = current ? last : { letters: [], hasMore: false, nextCursor: null }, all = page.letters || [];
  const members = [...new Set([...all.flatMap(l => [l.sender, l.recipient]), ...(ui.letterMember ? [ui.letterMember] : [])])].sort();
  const rows = all.map(l => {
    const flags = [];
    if (l.revisedAfterReceipt) flags.push(letterReceipt(l));
    if (l.stopRequested) flags.push('停止要請：' + (l.stopReason || '理由の記録なし'));
    if (l.proxyRecords) flags.push('代理の記録 ' + l.proxyRecords + '件（状態は変えていない）');
    return {
      id: l.id, state: l.state, selected: l.id === ui.letterSelected, text: l.taskId + ' · ' + l.sender + ' → ' + l.recipient + ' · ' + l.stateLabel + '\n' + l.id.slice(0, 21) + '…' +
        // CP-20261020-002: the server times of the send and of the recipient's own receipt
        '\n送信日時 ' + letterTime(l.sentAt) + ' · 受領日時 ' + (l.receivedAt ? letterTime(l.receivedAt) : '未受領') + (flags.length ? '\n' + flags.join('\n') : ''), title: l.id
    };
  });
  const filtered = !!(ui.letterMember || ui.letterState);
  // never presented as the whole history: which page, its count, and whether older letters exist
  const failedNow = src.ok === false && (src.failureKey === undefined || src.failureKey === letterListKey(ui));
  const status = src.ok === null ? '読み込み待ち' : !current ? (failedNow ? '一覧の取得不調 · この条件ではまだ読めていません' : 'この条件で読み込み中') : (src.ok === false ? '一覧の取得不調 · 最後に読めた内容' : (ui.letterCursor ? 'より古いページ' : '最新のページ') + '：' + rows.length + '件（新しい順）' +
    (page.hasMore ? ' · さらに古い連絡あり' : ' · これより古い連絡はなし') + (filtered ? ' · 絞り込み（サーバー側）' : ''));
  let detail = null;
  if (ui.letterSelected) {
    const d = det.value && det.value.id === ui.letterSelected ? det.value : null;
    detail = { id: ui.letterSelected, status: det.ok === false ? '本文の取得不調' + (d ? ' · 最後に読めた内容' : '') : (d ? '' : '本文を読み込み中'), body: null };
    if (d) detail.body = {
      heading: d.taskId + ' · ' + d.sender + ' → ' + d.recipient + ' · ' + d.stateLabel, state: d.state, receipt: letterReceipt(d),
      stop: d.state === 'withdrawn' ? '停止要請中（宛先の本人の応答を待っています。停止の確認でも、占有の解除でもありません）' : d.state === 'stopped' ? '停止済み（宛先の本人の応答）' : '',
      texts: (d.texts || []).map(x => ({
        heading: (x.part === 'request' ? '依頼' : '返答') + ' v' + x.revision + (x.reason ? '（改訂の理由：' + x.reason + '）' : ''), body: x.body,
        meta: '記録 ' + x.recorded_by + ' · 記録日時 ' + letterTime(x.received_at) + (x.ref_doc ? ' · 参照 ' + x.ref_doc + ' § ' + x.ref_section : '')
      })),
      events: (d.events || []).map(e => ({
        proxy: !e.effective, text: (LETTER_EVENT_LABELS[e.event] || e.event) + ' — ' + e.actor + (e.effective ? '' : '（代理の記録：記録者 ' + e.recorded_by + '。状態は変わらない）') + (e.note ? '：' + e.note : ''),
        meta: letterTimeLabel(e.event, e.effective) + ' ' + letterTime(e.received_at) + (e.claimed_at ? ' · 本人の申告 ' + e.claimed_at : '')
      }))
    };
  }
  return {
    members: [['', 'すべて'], ...members.map(m => [m, m])], states: LETTER_STATE_CHOICES, member: ui.letterMember, state: ui.letterState, status, rows,
    paging: { canOlder: !!page.hasMore && !!page.nextCursor, olderCursor: page.nextCursor || null, canLatest: !!ui.letterCursor },
    hint: ui.letterSelected ? '' : '一覧から連絡を選ぶと、原文・改訂の版・出来事の記録が出ます。', detail
  };
}
// The letters view: draws the view model as given. Rows are keyed by ID (nodes and focus survive polling); the detail is
// rebuilt only when its content changes. Texts are drawn with textContent and never interpreted as HTML. Intents: choose
// a letter, change a filter. No other operation exists here.
function createLettersView({ list, detail, status, member, state, older, latest, makeNode, onSelect, onFilter, onPage }) {
  const rows = new Map(); let detailKey = null;
  const set = (node, text) => { if (node.textContent !== text) node.textContent = text; };
  const options = (select, choices, value) => {
    const now = [...select.options].map(o => o.value + '\n' + o.textContent).join('\t'), want = choices.map(c => c[0] + '\n' + c[1]).join('\t');
    if (now !== want) { while (select.options.length) select.remove(0); for (const [v, label] of choices) { const o = makeNode('option'); o.value = v; o.textContent = label; select.add(o); } }
    if (select.value !== value) select.value = value;
  };
  member.addEventListener('change', () => onFilter({ letterMember: member.value })); state.addEventListener('change', () => onFilter({ letterState: state.value }));
  let olderCursor = null; older.addEventListener('click', () => { if (olderCursor) onPage(olderCursor); }); latest.addEventListener('click', () => onPage(null));
  return {
    show(vm) {
      options(member, vm.members, vm.member); options(state, vm.states, vm.state); set(status, vm.status);
      olderCursor = vm.paging.olderCursor; older.disabled = !vm.paging.canOlder; latest.disabled = !vm.paging.canLatest;
      const keep = new Set(vm.rows.map(r => r.id)); for (const [id, node] of rows) if (!keep.has(id)) { node.remove(); rows.delete(id); }
      vm.rows.forEach((r, i) => {
        let b = rows.get(r.id); if (!b) { b = makeNode('button'); b.type = 'button'; const id = r.id; b.addEventListener('click', () => onSelect(id)); rows.set(r.id, b); }
        set(b, r.text); if (b.title !== r.title) b.title = r.title; b.setAttribute('aria-pressed', String(r.selected)); b.dataset.state = r.state || '';
        if (list.children[i] !== b) list.insertBefore(b, list.children[i] || null);
      });
      const key = JSON.stringify([vm.hint, vm.detail]); if (key === detailKey) return; detailKey = key;
      const parts = []; const add = (tag, text, cls) => { const n = makeNode(tag); n.textContent = text; if (cls) n.className = cls; parts.push(n); return n; };
      if (!vm.detail) add('p', vm.hint, 'muted');
      else {
        if (vm.detail.status) add('p', vm.detail.status, 'letter-flag'); const b = vm.detail.body;
        if (b) {
          add('h3', b.heading); add('p', b.receipt); if (b.stop) add('p', b.stop, 'letter-flag');
          for (const x of b.texts) { add('h3', x.heading); add('pre', x.body); add('p', x.meta, 'muted'); }
          add('h3', '出来事の記録'); for (const e of b.events) { add('p', e.text, e.proxy ? 'letter-proxy' : ''); add('p', e.meta, 'muted'); }
        }
      }
      detail.replaceChildren(...parts);
    }
  };
}

// @endsection
// @section letters-poll
// GET-only pollers of the letters: the brief list and the chosen letter's detail, each single-flight. A detail asked while
// another is in flight is asked again when that one ends; an answer for a letter no longer chosen is dropped by the studio.
function createLetterPolls({ studio, fetchJson }) {
  let listBusy = false, listAgain = false, detailBusy = false, again = false;
  const polls = {
    async list() {
      if (listBusy) { listAgain = true; return; } listBusy = true; const ui = studio.snapshot().ui, key = letterListKey(ui);
      try { studio.letters(await fetchJson(letterListQuery(ui)), key); } catch (e) { studio.lettersFailure(key); } finally { listBusy = false; if (listAgain) { listAgain = false; polls.list(); } }
    },
    async detail() {
      const id = studio.snapshot().ui.letterSelected; if (!id) return; if (detailBusy) { again = true; return; } detailBusy = true;
      try { const value = await fetchJson('/letters/' + encodeURIComponent(id)); studio.letterDetail(id, value); } catch (e) { studio.letterDetailFailure(id); }
      finally { detailBusy = false; if (again) { again = false; polls.detail(); } }
    }
  };
  return polls;
}

// @endsection
