// OPS-138 待機完了: end-to-end on an isolated server whose activity log is a temporary file (see launch below); approvals
// are mocked in the browser. Nothing touches the real activity log, Inbox or approval store.
// Usage: node wake-check.cjs <studio URL> <output dir> <temp events.jsonl>
//   W=$(mktemp -d); REGISTRY_STUDIO_INBOX=$W/inbox python3 -B -c "import sys;sys.path.insert(0,'Maintanance/RegistryApp');import activity,serve;from pathlib import Path;activity.EVENTS=Path(sys.argv[1]);sys.argv=['serve.py','--port','18946'];serve.main()" $W/events.jsonl
const pw=require('/opt/homebrew/lib/node_modules/playwright');const fs=require('fs'),{execFileSync}=require('child_process');const [url,out,log]=process.argv.slice(2);
const append=(owner,reason,extra=[])=>execFileSync('python3',['-B','-c',"import sys;sys.path.insert(0,'Maintanance/RegistryApp');import activity;from pathlib import Path;activity.EVENTS=Path(sys.argv[1]);activity.append_event('OPS-1','work',sys.argv[2],sys.argv[3])",log,owner,reason]);
const wakes=()=>fs.readFileSync(log,'utf8').trim().split('\n').map(JSON.parse).filter(e=>e.owner==='ユーザー');
(async()=>{const b=await pw.webkit.launch();const r={};try{const p=await b.newPage({viewport:{width:1400,height:900}});const errors=[];p.on('pageerror',e=>errors.push(e.message));
 await p.route('**/commit-approvals',x=>x.request().method()==='GET'?x.fulfill({status:200,contentType:'application/json',body:JSON.stringify({policyNotice:'x',requests:[]})}):x.abort());
 let delay=0;await p.route('**/activity-wake',async x=>{if(delay){await new Promise(f=>setTimeout(f,delay));}return x.continue();});
 await p.goto(url);await p.waitForTimeout(3500);
 const look=()=>p.evaluate(()=>({owners:[...document.getElementById('wake-owner').options].map(o=>o.value),selected:document.getElementById('wake-owner').value,disabled:document.getElementById('wake-send').disabled,status:document.getElementById('wake-status').textContent}));
 r.initial=await look();await p.selectOption('#wake-owner','姫');
 await p.dblclick('#wake-send');await p.waitForTimeout(800);r.afterDouble={...await look(),userWakes:wakes().length};
 await p.waitForTimeout(3500);r.pending=await look();
 const id=wakes()[0].reason.split('：')[0];r.wakeId=id;r.wakeRecord=wakes()[0];
 append('姫','ACK '+id+'X：境界違い');append('Astra','ACK '+id+'：代理');await p.waitForTimeout(3800);r.nearMiss=await look();
 append('姫','ACK '+id+'：会話へ戻る');await p.waitForTimeout(3800);r.acked=await look();
 await p.screenshot({path:`${out}/wake-acked.png`,clip:{x:0,y:60,width:1400,height:260}});
 delay=6500;await p.click('#wake-send');await p.waitForTimeout(5600);r.unknown={...await look(),userWakes:wakes().length};
 await p.waitForTimeout(5000);r.afterUnknown={...await look(),userWakes:wakes().length};
 await p.screenshot({path:`${out}/wake-pending.png`,clip:{x:0,y:60,width:1400,height:260}});
 delay=0;r.errors=errors;await p.close();}finally{await b.close();}console.log(JSON.stringify(r,null,1));})();
