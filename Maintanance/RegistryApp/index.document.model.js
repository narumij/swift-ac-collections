// Task IDs are the entry point; the server defines each task's canonical parts.
function canonicalTaskChoices(registry) {
  return (registry.tasks || []).map(task => ({ id: task.id, title: task.item.replace(/^\[[^\]]+\]\s*/, '') }))
    .sort((a, b) => a.id.localeCompare(b.id, 'en', { numeric: true }));
}
class TaskCanonicalViewModel {
  constructor({ context, makeDocument }) {
    this.context = context; this.makeDocument = makeDocument; this.generation = 0; this.parts = []; this.listeners = new Set();
    this.state = { taskId: '', task: null, documents: [], letters: [], status: 'empty', message: '' };
  }
  subscribe(listener) { this.listeners.add(listener); return () => this.listeners.delete(listener); }
  publish() { for (const listener of this.listeners) listener(this.state); }
  close() { this.generation++; for (const part of this.parts) part.close(); this.parts = []; }
  async select(taskId) {
    this.close(); const generation = this.generation;
    this.state = { taskId, task: null, documents: [], letters: [], status: 'loading', message: 'タスクの正本を取得中…' }; this.publish();
    try {
      const value = await this.context(taskId);
      if (generation !== this.generation) return;
      if (value.task?.id !== taskId || !Array.isArray(value.documents)) throw Error('タスクの取得結果が一致しません');
      this.state = { taskId, task: value.task, documents: value.documents.map(part => ({ path: part.path, html: '', stamp: '', status: part.status === 'ok' ? 'loading' : part.status, message: part.status === 'outside' ? '正本がリポジトリの外を参照しています。' : part.status === 'missing' ? '正本が見つかりません。' : '正本を取得中…' })), letters: value.letters || [], status: 'ready', message: value.documents.length ? '' : 'このタスクには正本の指定がありません。' };
      this.publish();
      value.documents.forEach((part, index) => {
        if (part.status === 'outside') return;
        const document = this.makeDocument(); this.parts.push(document);
        document.subscribe(state => {
          if (generation !== this.generation) return;
          const documents = this.state.documents.slice(); documents[index] = state;
          this.state = { ...this.state, documents }; this.publish();
        });
        document.select(part.path);
      });
    } catch (error) {
      if (generation !== this.generation) return;
      this.state = { taskId, task: null, documents: [], letters: [], status: 'error', message: 'タスクの正本を取得できません：' + error.message }; this.publish();
    }
  }
}
if (typeof module !== 'undefined') module.exports = { canonicalTaskChoices, TaskCanonicalViewModel };
