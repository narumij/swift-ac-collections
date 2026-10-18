// OPS-110: exercise the actual isolated poller without browser operations.
const fs=require('fs'),vm=require('vm'),assert=require('assert');
const html=fs.readFileSync(__dirname+'/index.template.html','utf8');
const source=html.slice(html.indexOf('function validateWorkProgress('),html.indexOf('function startWorkProgress('));
const c={};vm.createContext(c);vm.runInContext(source,c);
const record={schemaVersion:1,taskId:'OPS-110',title:'<img onerror=alert(1)>',owner:'Sol',stage:'work',updatedAt:'2026-10-18T12:00:00Z'};
assert.equal(c.validateWorkProgress(record).title,record.title);assert.equal(c.validateWorkProgress(null),null);
for(const change of [{stage:'ACTIVE'},{taskId:'../OPS-110'},{owner:'x\n'},{updatedAt:'yesterday'},{title:'x'.repeat(161)},{waitingReason:4}])assert.throws(()=>c.validateWorkProgress({...record,...change}));
async function main(){
 let hidden=false,calls=0,pending,clock=Date.parse(record.updatedAt),mode='pending',summary,detail,stale;
 const timers=new Map();let id=0,aborted=0;
 const schedule=(fn,ms)=>{timers.set(++id,{fn,ms});return id;},cancel=id=>timers.delete(id);
 const fetchRecord=(path,options)=>{calls++;assert.equal(path,'/work-progress');assert.equal(options.cache,'no-store');return new Promise((resolve,reject)=>{pending={resolve,reject};options.signal.reject=reject;});};
 const view={summary:t=>summary=t,detail:t=>detail=t,stale:v=>stale=v};
 const p=c.createWorkProgressPoller({fetchRecord,view,isHidden:()=>hidden,schedule,cancel,now:()=>clock,makeController:()=>({signal:{},abort(){aborted++;this.signal.reject(Error('abort'));}})});
 const respond=async data=>{pending.resolve({ok:true,json:async()=>data});await new Promise(r=>setImmediate(r));};
 const tick=async()=>{const timer=[...timers].find(([,v])=>v.ms===3000);assert(timer);timers.delete(timer[0]);timer[1].fn();await Promise.resolve();};
 let first=p.poll();p.poll();assert.equal(calls,1,'never overlaps');await respond(record);await first;
 assert(summary.includes('OPS-110')&&summary.includes(record.title));assert(detail.includes('【作業】')&&detail.includes(record.updatedAt));assert(!stale);
 await tick();pending.reject(Error('offline'));await new Promise(r=>setImmediate(r));assert(summary.includes('OPS-110')&&detail.startsWith('通信・記録不調：最終記録を保持')&&stale);
 await tick();await respond({...record,stage:'acceptance'});assert(detail.includes('【受入】')&&!stale,'recovers');
 hidden=true;p.visibility();assert.equal(timers.size,0);await p.poll();assert.equal(calls,3,'hidden pauses');
 clock+=61000;hidden=false;p.visibility();assert(stale&&detail.includes('1分以上前'));
 const timeout=[...timers].find(([,v])=>v.ms===5000);assert(timeout);timeout[1].fn();await new Promise(r=>setImmediate(r));assert.equal(aborted,1);assert(stale&&summary.includes('OPS-110'));
 await tick();await respond(null);assert(summary.includes('未登録')&&!stale);
 await tick();await respond(record);hidden=true;p.visibility();assert.equal(timers.size,0);
 // Hiding during a request aborts it; returning visible starts a fresh read.
 hidden=false;p.visibility();hidden=true;p.visibility();await new Promise(r=>setImmediate(r));assert.equal(aborted,2);assert.equal(timers.size,0);
 hidden=false;p.visibility();await respond(record);
 assert(!source.includes('innerHTML')&&!source.includes('render(')&&!source.includes('/sync'),'poller only updates advisory view');
 assert(html.includes('.work-progress{height:48px')&&html.includes('text-overflow:ellipsis'),'stable bounded footprint');
 console.log('PASS: progress validation, text-only view, isolated state, one request, recovery, age, missing file, hidden pause/abort, timeout.');
}
main().catch(e=>{console.error(e);process.exitCode=1;});
