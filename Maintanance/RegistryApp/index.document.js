// @section main
// include-js:index.document.model.js
function startCanonicalDocumentTab() {
  const live = location.protocol !== 'file:' && typeof EventSource === 'function' ? subscribeCanonicalDocument : null;
  const model = new TaskCanonicalViewModel({
    context: async taskId => {
      const response = await fetch('/task-context?task=' + encodeURIComponent(taskId), { signal: AbortSignal.timeout(10000) });
      const value = await response.json(); if (!response.ok) throw Error(value.error || '通信エラー'); return value;
    },
    makeDocument: () => new CanonicalDocumentViewModel(documentBundle, live)
  });
  const select = $('canonical-document-select'), body = $('canonical-document-body');
  const stateSelect = $('canonical-task-state'), saveState = $('canonical-task-state-save'), stateMessage = $('canonical-task-state-message');
  const stateNames = {ACTIVE:'有効', WAITING_USER:'ユーザー待ち', WAITING_EXTERNAL:'外部待ち', FROZEN:'凍結', USER_ONLY:'ユーザー専任', PROPOSED:'提案中', DONE:'完了', EXCLUDED:'対象外', ARCHIVED:'履歴化'};
  for (const [value, label] of Object.entries(stateNames)) { const option = el('option', label); option.value = value; stateSelect.append(option); }
  let savingState = false, displayedStateKey = '';
  saveState.addEventListener('click', async () => {
    const task = model.state.task;
    if (!task || savingState || stateSelect.value === task.state) return;
    const taskId = task.id, next = stateSelect.value;
    savingState = true; saveState.disabled = true; stateSelect.disabled = true;
    stateMessage.textContent = taskId + ' を保存中…';
    try {
      const response = await fetch('/task-status', {method:'POST', headers:{'Content-Type':'application/json','X-Registry-Studio':'task-status'},
        body: JSON.stringify({taskId, baseState:task.state, state:next, generation:canonicalSnapshot.source.generation, operationId:crypto.randomUUID()})});
      const result = await response.json(); if (!response.ok) throw Error(result.error || '保存できませんでした');
      stateMessage.textContent = result.warning || taskId + ' の状態を保存しました';
      if (model.state.taskId === taskId) await model.select(taskId);
    } catch (error) { stateMessage.textContent = taskId + '：' + error.message + '（通信失敗の場合は再選択して保存結果を確認してください）'; }
    finally { savingState = false; stateSelect.disabled = !model.state.task; saveState.disabled = !model.state.task; }
  });
  let shownTask = '', blocks = [], previousLetters = null, workRecords = [];
  function drawRecent() {
    const tasks = recentCanonicalTasks(canonicalSnapshot, workRecords);
    const cards = independentViewModel(tasks, model.state.taskId, () => true);
    cards.items.forEach((card, i) => { card.workedAt = '作業 ' + new Date(tasks[i].workedAt).toLocaleString('ja-JP', { timeZone: 'Asia/Tokyo', hour12: false }); card.title += '\n' + card.workedAt + ' · ' + tasks[i].workedBy; });
    drawIndependent($('canonical-recent-cards'), $('canonical-recent-count'), cards, { select: taskId => model.select(taskId), openDocuments: task => model.select(task.id) });
  }
  function drawChoices() {
    select.replaceChildren(el('option', 'タスク番号を選んでください')); select.options[0].value = '';
    for (const task of canonicalTaskChoices(canonicalSnapshot)) {
      const option = el('option', task.id + ' · ' + task.title); option.value = task.id; select.append(option);
    }
    select.value = model.state.taskId;
    drawRecent();
  }
  model.subscribe(state => {
    select.value = state.taskId;
    const stateKey = state.task ? state.task.id + ':' + state.task.state : '';
    if (stateKey !== displayedStateKey) { stateSelect.value = state.task?.state || ''; displayedStateKey = stateKey; }
    stateSelect.disabled = savingState || !state.task;
    saveState.disabled = savingState || !state.task;
    drawRecent();
    $('canonical-document-title').textContent = state.task ? state.task.id + ' · ' + state.task.item.replace(/^\[[^\]]+\]\s*/, '') : state.taskId + ' · 正本';
    const loaded = state.documents.filter(part => part.status === 'ready').length;
    $('canonical-document-stamp').textContent = state.message || ('正本 ' + loaded + '/' + state.documents.length + '部分 · 更新通知を反映');
    if (shownTask !== state.taskId || blocks.length !== state.documents.length || state.status !== 'ready') {
      body.replaceChildren(); blocks = []; shownTask = state.taskId; body.scrollTop = 0;
      if (state.status !== 'ready' || !state.documents.length) body.append(el('p', state.message));
      for (const part of state.documents) {
        const section = el('section', undefined, 'canonical-part'), title = el('h3'), stamp = el('p', '', 'muted'), content = el('div');
        section.dataset.path = part.path; section.append(title, stamp, content); body.append(section);
        blocks.push({ title, stamp, body: content, state: null });
      }
    }
    const scroll = body.scrollTop;
    state.documents.forEach((part, index) => {
      const block = blocks[index]; if (block.state === part) return;
      renderCanonicalDocument(part, { ...block, openDocument });
      block.title.textContent = '正本 ' + (index + 1) + ' · ' + (documentBundle.files[part.path]?.title || part.path.split('/').pop());
      block.stamp.textContent = part.path + (part.stamp ? ' · ' + part.stamp : ''); block.state = part;
    });
    body.scrollTop = scroll;
    if (previousLetters !== state.letters) {
      previousLetters = state.letters;
      const list = $('canonical-task-letter-list'); list.replaceChildren();
      $('canonical-task-letters').querySelector('summary').textContent = '関連連絡（' + state.letters.length + '通 · 正本文書とは別の記録）';
      for (const letter of state.letters) list.append(el('p', letter.id + ' · ' + (letter.sender || '') + ' → ' + (letter.recipient || '') + ' · ' + (letter.stateLabel || letter.state || '')));
      if (!state.letters.length) list.append(el('p', '関連連絡はありません。', 'muted'));
    }
  });
  select.addEventListener('change', () => { if (select.value) model.select(select.value); });
  drawChoices();
  document.addEventListener('studio-work-state-change', event => {
    const snapshot = event.detail; workRecords = snapshot.recentTasks || [];
    drawRecent();
    $('canonical-recent-status').textContent = !snapshot.connected || snapshot.failed.letters ? '記録の取得不調 · 最後の情報を保持' : '連絡DBに記録された着手・返却の新しい順';
  });
  document.addEventListener('studio-area-change', event => { if (event.detail === 'document') drawChoices(); });
  document.addEventListener('studio-task-source-change', () => { drawChoices(); if (model.state.taskId) model.select(model.state.taskId); });
  window.addEventListener('pagehide', () => model.close());
  window.addEventListener('pageshow', event => { if (event.persisted && model.state.taskId) model.select(model.state.taskId); });
}
startCanonicalDocumentTab();
// @endsection
