const fs = require('node:fs');
const vm = require('node:vm');
const assert = require('node:assert/strict');
const context = vm.createContext({ AbortController });
for (const name of ['events', 'approvals']) vm.runInContext(fs.readFileSync(`${__dirname}/index.work.${name}.js`, 'utf8').replace(/^startCommitApprovals\(\);$/m, ''), context);
async function check(factory, value) {
  const timers = new Map(); let id = 0, calls = 0, failures = 0, enabled = false, resolve;
  const options = {
    kind: 'events', autoPoll: false, isHidden: () => false,
    schedule(fn, delay) { timers.set(++id, { fn, delay }); return id; }, cancel(id) { timers.delete(id); },
    makeController: () => new AbortController(),
    view: { update() {}, failure() { failures++; }, availability(value) { enabled = value; } },
    fetchRecord: async () => { calls++; return { ok: true, json: async () => value }; }
  };
  let controller = factory(options);
  await controller.poll();
  assert.equal(calls, 1);
  assert.equal(timers.size, 0, 'successful snapshot must not schedule polling');
  options.fetchRecord = async () => { calls++; throw Error('temporary failure'); };
  controller = factory(options);
  await controller.poll();
  assert.equal(failures, 1);
  assert.equal(timers.size, 1, 'failed snapshot gets a bounded retry');
  for (let i = 0; i < 2; i++) { const [key, timer] = timers.entries().next().value; timers.delete(key); await timer.fn(); }
  assert.equal(timers.size, 0, 'retries stop after two attempts');
  options.fetchRecord = () => new Promise(r => { resolve = r; });
  controller = factory(options);
  const active = controller.poll();
  await controller.poll();
  if (controller.disconnected) controller.disconnected();
  resolve({ ok: true, json: async () => value });
  await active;
  if (controller.disconnected) {
    assert.equal(enabled, false, 'disconnect cannot re-enable approval controls');
    assert.equal(timers.size, 0);
  } else assert.equal(timers.size, 1, 'change during fetch requires a trailing snapshot');
}
(async () => {
  await check(vm.runInContext('createActivityPoller', context), []);
  await check(vm.runInContext('createApprovalController', context), { requests: [], policyNotice: '' });
  console.log('PASS: observer snapshots, bounded retries, in-flight changes and disconnect');
})().catch(error => { console.error(error); process.exitCode = 1; });
