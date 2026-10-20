const fs=require('fs'),vm=require('vm'),assert=require('assert');
const c={}; vm.createContext(c); vm.runInContext(fs.readFileSync(__dirname+'/index.work.wake.js','utf8'),c);
(async()=>{
 const buttons=['thanks','pause','cancel','return'].map(teamKind=>({dataset:{teamKind},disabled:false})), reason={value:'optional'},status={};
 let resolve,reject,calls=[],next=0;
 c.createTeamNoticeControl({buttons,reason,status,operationId:()=>String(++next),send:body=>{calls.push({...body});return new Promise((r,j)=>{resolve=r;reject=j;});}});
 const first=buttons[0].onclick(); await buttons[0].onclick(); assert.equal(calls.length,1); assert(buttons.every(b=>b.disabled));
 reject(Error('connection lost'));await first;
 assert(!buttons[0].disabled && buttons[1].disabled && reason.disabled);
 const retry=buttons[0].onclick();assert.deepEqual(calls[0],calls[1]);resolve({sentCount:2,targets:['A','B']});await retry;
 assert.equal(status.textContent,'送信済み 2名・受領未確認');assert(buttons.every(b=>!b.disabled));assert(!reason.disabled);
 for(const button of buttons.slice(1)){
  const sent=button.onclick();assert.equal(calls.at(-1).kind,button.dataset.teamKind);resolve({sentCount:2,targets:['A','B']});await sent;
 }
 const refused=buttons[0].onclick();const error=Error('no members');error.refused=true;reject(error);await refused;assert(buttons.every(b=>!b.disabled));
 const html=fs.readFileSync(__dirname+'/index.work.html','utf8');assert.equal((html.match(/data-team-kind=/g)||[]).length,4);assert(html.includes('team-notice-reason'));
 console.log('PASS team notice UI: four buttons, optional reason, double-click guard, same-operation safe retry, receipt wording and failure recovery');
})().catch(e=>{console.error(e);process.exitCode=1;});
