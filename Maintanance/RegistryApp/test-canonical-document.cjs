const assert = require('node:assert/strict');
const { CanonicalDocumentViewModel } = require('./index.task.document.js');
const fixture = {
  generatedAt: '2026-10-21T00:00:00Z',
  files: {
    'first.md': { html: '<h1>最初の正本</h1><p>本文です</p>' },
    'second.md': { html: '<h1>次の正本</h1>' }
  }
};
const model = new CanonicalDocumentViewModel(fixture);
assert.equal(model.state.status, 'empty');
const received = [];
const unsubscribe = model.subscribe(state => received.push(state));
model.select('first.md');
assert.equal(model.state.path, 'first.md');
assert.equal(model.state.html, fixture.files['first.md'].html);
assert.equal(model.state.status, 'ready');
model.select('missing.md');
assert.equal(model.state.status, 'missing');
assert.equal(model.state.html, ''); // Previous document must not remain visible.
assert.ok(model.state.message);
model.select('second.md');
assert.equal(model.state.html, fixture.files['second.md'].html);
assert.equal(model.state.message, '');
model.select('first.md', { html: '<p>承認待ちの版</p>' });
assert.equal(model.state.html, '<p>承認待ちの版</p>');
assert.equal(received.length, 4);
assert.equal(received[0].html, fixture.files['first.md'].html);
unsubscribe();
model.select('second.md');
assert.equal(received.length, 4);
console.log('canonical document model: PASS');
module.exports = fixture;
