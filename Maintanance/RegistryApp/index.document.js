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
  let shownTask = '', blocks = [], previousLetters = null;
  function drawChoices() {
    select.replaceChildren(el('option', 'タスク番号を選んでください')); select.options[0].value = '';
    for (const task of canonicalTaskChoices(canonicalSnapshot)) {
      const option = el('option', task.id + ' · ' + task.title); option.value = task.id; select.append(option);
    }
    select.value = model.state.taskId;
  }
  model.subscribe(state => {
    select.value = state.taskId;
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
  document.addEventListener('studio-area-change', event => { if (event.detail === 'document') drawChoices(); });
  document.addEventListener('studio-task-source-change', () => { drawChoices(); if (model.state.taskId) model.select(model.state.taskId); });
  window.addEventListener('pagehide', () => model.close());
  window.addEventListener('pageshow', event => { if (event.persisted && model.state.taskId) model.select(model.state.taskId); });
}
startCanonicalDocumentTab();
// @endsection
