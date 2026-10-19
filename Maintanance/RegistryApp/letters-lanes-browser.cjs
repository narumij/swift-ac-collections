// OPS-183/184: the browser half of test-letters-lanes-browser.py. Opens the isolated server's page in headless WebKit and
// waits for each expected display; between steps it prints "STEP <name> <json>" and waits for "GO" on stdin, so the
// Python side can change the server state. Only the given origin is reached; anything else is aborted and reported.
const {webkit}=require(process.env.PLAYWRIGHT_MODULE||'playwright');
const origin=process.argv[2],readline=require('readline').createInterface({input:process.stdin});
const lines=[];let wake=null;readline.on('line',l=>{lines.push(l);if(wake){const w=wake;wake=null;w();}});
const go=()=>new Promise(r=>{if(lines.length){lines.shift();r();}else wake=()=>{lines.shift();r();};});
const step=async(name,value)=>{console.log('STEP '+name+' '+JSON.stringify(value));await go();};
(async()=>{
 const browser=await webkit.launch(),page=await browser.newPage(),errors=[],blocked=[];
 page.on('pageerror',e=>errors.push(e.message));
 await page.route('**/*',r=>r.request().url().startsWith(origin)?r.continue():(blocked.push(r.request().url()),r.abort()));
 const text=()=>page.evaluate(()=>({lamps:[...document.querySelectorAll('#presence-lamps .presence-lamp')].map(n=>n.textContent),
  cards:[...document.querySelectorAll('#work-lane-track [data-task-id], #work-lane-track .work-card')].map(n=>n.textContent),
  laneStatus:document.getElementById('work-lane-status').textContent,wake:document.getElementById('wake-status').textContent}));
 const until=async(pred,what)=>{const end=Date.now()+30000;let t;while(Date.now()<end){t=await text();if(pred(t))return t;await page.waitForTimeout(300);}throw Error('timeout: '+what+' '+JSON.stringify(t));};
 try{
  await page.goto(origin+'/');
  let t=await until(x=>x.lamps.some(l=>l.includes('担当中 LTR')),'letters shown');
  await step('shown',t);
  t=await until(x=>x.lamps.some(l=>l.includes('連絡 取得不調')),'failure shown');
  await step('failure',t);
  t=await until(x=>!x.lamps.some(l=>l.includes('連絡 取得不調')),'recovered');
  await step('recovered',t);
  console.log('DONE '+JSON.stringify({errors,blocked}));
 }catch(e){console.log('ERROR '+JSON.stringify({message:e.message,errors,blocked}));process.exitCode=1;}
 finally{await browser.close();readline.close();}
})();
