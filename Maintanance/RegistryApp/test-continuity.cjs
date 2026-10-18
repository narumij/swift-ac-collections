// OPS-139/141: continuity marks in the member states (actual continuityState / validateContinuity / createContinuityStatus).
const fs=require('fs'),vm=require('vm'),assert=require('assert');
const html=fs.readFileSync(__dirname+'/index.template.html','utf8');
const a=html.indexOf("const CONTINUITY_LIMIT_MS="),b=html.indexOf("// OPS-136: when focus leaves the scrolled approval part");assert(a>=0&&b>a);
const c={};vm.createContext(c);vm.runInContext(html.slice(html.indexOf('function memberTime('),html.indexOf('function createPresenceLamps('))+'\n'+html.slice(a,b),c);
const st=(mark,age,failed=false)=>c.continuityState(mark,age,failed);
const alive={state:'alive',at:'2026-10-19T01:00:00Z'},ended={state:'ended',at:'2026-10-19T01:00:00Z'};
// 55 s boundary; over it the confirmation is "old" (never "stopped"); explicit end; unknown; future; trouble
assert.equal(st(alive,55000).kind,'alive');assert.equal(st(alive,55001).kind,'lapsed');assert(st(alive,55001).label.startsWith('継続 確認が古い'));assert(st(alive,55001).label.includes('56秒前'));
assert(!/停止|止まり|途切れ/.test(st(alive,90000).label));
assert.equal(st(ended,999999).kind,'ended');assert(st(ended,1).label.startsWith('連続動作の終了'),'continuous-run end, not wait end');
assert.equal(st(null,null).label,'継続 未確認');assert.equal(st(alive,-6000).kind,'unknown');assert.equal(st(alive,-3000).kind,'alive');
assert.equal(st(alive,1000,true).kind,'trouble');assert(st(alive,1000,true).label.includes('最後に読めた確認'));
// validation over all owners
assert.throws(()=>c.validateContinuity({serverNow:'x',owners:{}}));assert.throws(()=>c.validateContinuity({serverNow:'2026-10-19T01:00:00Z',owners:[]}));
assert.throws(()=>c.validateContinuity({serverNow:'2026-10-19T01:00:00Z',owners:{Sol:{state:'waiting',at:'2026-10-19T01:00:00Z'}}}),'any owner is validated');
assert.deepEqual(Object.keys(c.validateContinuity({serverNow:'2026-10-19T01:00:00Z',owners:{'姫':alive,Astra:alive}}).owners),['姫','Astra']);
(async()=>{let perf=0;const queue=[];let last=null;
 const fetchRecord=()=>new Promise((res,rej)=>queue.push({res,rej}));const v=c.createContinuityStatus({onChange:(fn,owners)=>{last={fn,owners};},fetchRecord,now:()=>perf});
 const answer=(i,serverNow,owners)=>{queue[i].res({serverNow,owners});return new Promise(r=>setImmediate(r));};
 v.poll();await answer(0,'2026-10-19T01:00:10Z',{Astra:alive,Sol:ended});assert.deepEqual(last.owners,['Astra','Sol']);
 assert(last.fn('Astra').startsWith('継続 ')&&last.fn('Astra').includes('10秒前'));assert(last.fn('Sol').startsWith('連続動作の終了'));assert.equal(last.fn('姫'),'継続 未確認','no mark = 未確認');
 perf=45000;v.paint();assert(last.fn('Astra').includes('55秒前')&&!last.fn('Astra').includes('古い'));perf=45001;v.paint();assert(last.fn('Astra').startsWith('継続 確認が古い'),'ages from elapsed time alone');
 v.poll();v.poll();await answer(2,'2026-10-19T01:01:00Z',{Astra:{state:'alive',at:'2026-10-19T01:00:58Z'}});perf=46000;v.paint();assert(!last.fn('Astra').includes('古い'));
 await answer(1,'2026-10-19T01:00:59Z',{Astra:alive});v.paint();assert(!last.fn('Astra').includes('古い'),'late answer ignored');
 v.poll();queue[3].rej(Error('down'));await new Promise(r=>setImmediate(r));assert(last.fn('Astra').startsWith('継続 不調'));
 // markup: no longer in the top bar; fed into the member states of the work area
 const hdr=html.slice(html.indexOf('<header>'),html.indexOf('</header>'));assert(!hdr.includes('continuity-status')&&!hdr.includes('Astra 未確認'),'moved out of the top bar');
 assert(html.includes("onData:data=>studio.continuity(data,performance.now())"),'feeds the member states through the shared snapshot (OPS-153)');
 assert(html.includes("setInterval(()=>studio.tick(performance.now()),1000)")&&html.includes("if(!document.hidden)status.poll();},5000)"),'1 s clock input, 5 s fetch, paused when hidden');
 assert(!/CONTINUITY_OWNER/.test(html),'not fixed to Astra');
 console.log('PASS: OPS-139/141 continuity (all members, 55 s = confirmation old, end = continuous-run end, unknown/future/trouble, late answers ignored, moved to member states).');})().catch(e=>{console.error(e);process.exit(1);});
