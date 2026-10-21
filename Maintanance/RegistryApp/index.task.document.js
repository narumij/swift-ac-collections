// Display state for one specified canonical document. Task selection stays outside.
class CanonicalDocumentViewModel {
  constructor(bundle, subscribeLive = null) {
    this.bundle = bundle;
    this.subscribeLive = subscribeLive;
    this.disconnect = null;
    this.generation = 0;
    this.listeners = new Set();
    this.state = Object.freeze({ path: '', html: '', stamp: '', status: 'empty', message: '' });
  }
  subscribe(listener) {
    this.listeners.add(listener);
    return () => this.listeners.delete(listener);
  }
  close() {
    this.generation++;
    if (this.disconnect) this.disconnect();
    this.disconnect = null;
  }
  select(path, overrideRecord) {
    this.close();
    const generation = this.generation;
    const record = overrideRecord || this.bundle.files[path];
    this.state = Object.freeze({
      path, html: record?.html || '',
      stamp: !overrideRecord && this.subscribeLive ? '最新の正本を取得中…' : '表示用コピー：' + new Date(this.bundle.generatedAt).toLocaleString() + '（正本の更新は自動反映しません）',
      status: record ? 'ready' : 'missing',
      message: record ? '' : 'この文書は同梱されていません。表示用データを更新してください。'
    });
    for (const listener of this.listeners) listener(this.state);
    if (!overrideRecord && this.subscribeLive) {
      this.disconnect = this.subscribeLive(path, snapshot => {
        if (generation !== this.generation) return;
        const record = snapshot.document;
        if (record && record.path !== path) return;
        if (snapshot.error) {
          this.state = Object.freeze({ path, html: '', stamp: '', status: 'error', message: '正本を取得できません。接続が回復すると再取得します。' });
        } else if (record) {
          this.state = Object.freeze({ ...record, stamp: record.status === 'ready' ? '正本を自動更新 · SHA-256 ' + String(record.stamp || '').slice(0, 12) : '' });
        } else return;
        for (const listener of this.listeners) listener(this.state);
      });
    }
  }
}

function renderCanonicalDocument(state, target = null) {
  const { path, html, stamp, status, message } = state;
  const dialog = target ? null : $('documentDialog'), body = target ? target.body : $('documentBody');
  const scroll = body.dataset.path === path ? body.scrollTop : 0;
  body.dataset.path = path; body.replaceChildren(); (target ? target.title : $('documentTitle')).textContent = path;
  (target ? target.stamp : $('documentStamp')).textContent = stamp;
  if (status !== 'ready') body.append(el('p', message));
  else {
    const parsed = new DOMParser().parseFromString(html, 'text/html');
    const allowed = new Set('P H1 H2 H3 H4 H5 H6 UL OL LI BLOCKQUOTE PRE CODE STRONG EM DEL A TABLE THEAD TBODY TR TH TD HR BR INPUT'.split(' '));
    function clean(source, parent) {
      for (const n of source.childNodes) {
        if (n.nodeType === 3) { parent.append(document.createTextNode(n.textContent)); continue; } if (n.nodeType !== 1) continue; if (!allowed.has(n.tagName)) { if (!['SCRIPT', 'STYLE', 'IFRAME', 'OBJECT'].includes(n.tagName)) clean(n, parent); continue; } const dst = document.createElement(n.tagName); if (n.tagName === 'INPUT') { dst.type = 'checkbox'; dst.disabled = true; dst.checked = n.hasAttribute('checked'); } if (n.tagName === 'A') {
          const href = n.getAttribute('href') || '';
          if (/^https?:\/\//i.test(href)) { dst.href = href; dst.target = '_blank'; dst.rel = 'noopener noreferrer'; }
          else if (!/^[a-z][a-z0-9+.-]*:/i.test(href) && !href.startsWith('//')) { dst.href = '#document'; dst.onclick = e => { e.preventDefault(); const base = new URL(path, 'https://repository.invalid/'); const destination = new URL(href, base); const navigate = target?.openDocument || openDocument; navigate(decodeURIComponent(destination.pathname.slice(1))); }; }
        } clean(n, dst); parent.append(dst);
      }
    }
    clean(parsed.body, body);
  }
  if (dialog && !dialog.open) dialog.showModal(); body.scrollTop = scroll;
}

if (typeof module !== 'undefined') module.exports = { CanonicalDocumentViewModel, renderCanonicalDocument };
