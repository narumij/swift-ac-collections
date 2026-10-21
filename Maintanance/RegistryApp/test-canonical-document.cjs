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

// Live updates obey selection lifetime; delayed messages cannot reopen old documents.
{
 const streams=[];
 const live=new CanonicalDocumentViewModel(fixture,(path,receive)=>{
   const stream={path,receive,closed:false};streams.push(stream);return ()=>{stream.closed=true};
 });
 live.select('first.md');
 streams[0].receive({document:{path:'first.md',html:'new first',status:'ready',stamp:'live',message:''}});
 assert.equal(live.state.html,'new first');
 live.select('second.md');
 assert.equal(streams[0].closed,true);
 streams[0].receive({document:{path:'first.md',html:'late',status:'ready'}});
 assert.equal(live.state.path,'second.md');
 streams[1].receive({document:{path:'second.md',html:'',status:'missing',stamp:'',message:'deleted'}});
 assert.equal(live.state.html,'');assert.equal(live.state.status,'missing');
 streams[1].receive({error:'offline'});assert.equal(live.state.status,'error');
 streams[1].receive({document:{path:'second.md',html:'recovered',status:'ready',stamp:'',message:''}});
 assert.equal(live.state.html,'recovered');
 live.close();assert.equal(streams[1].closed,true);
 streams[1].receive({document:{path:'second.md',html:'after close',status:'ready'}});
 assert.equal(live.state.html,'recovered');
 live.select('first.md',{html:'override'});
 assert.equal(streams.length,2);assert.equal(live.state.html,'override');
 console.log('canonical document live selection: PASS');
}
