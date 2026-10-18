// Isolated tests of the actual timeline code; no live browser or server.
const fs=require('fs'),vm=require('vm'),assert=require('assert');
const html=fs.readFileSync(__dirname+'/index.template.html','utf8');
const source=html.slice(html.indexOf('const activityLabels='),html.indexOf('function startActivityTimelines('));
const c={};vm.createContext(c);vm.runInContext(source,c);
const event=(n,kind='return')=>({schemaVersion:1,id:n.toString(16).padStart(32,'0'),taskId:'OPS-111',event:kind,owner:'<img src=x onerror=alert(1)>',timestamp:'2026-10-18T12:00:00Z',reason:'repeat '+n,commitSha:'a'.repeat(40)});
const rows=ns=>c.validateActivityRows(ns.map(n=>event(n)),'events');
assert.equal(rows([1,2]).length,2);
assert(!html.includes('id="activity-commits"'));
assert(html.includes("for(const kind of ['events'])"));
assert(rows([1])[0].detail.includes('<img')&&rows([1])[0].title.includes('a'.repeat(40)));
for(const changes of [{event:'success'},{taskId:'../OPS-111'},{id:'bad'},{owner:'bad\n'},{timestamp:'today'},{commitSha:'abcdef'},{reason:'x'.repeat(241)}])assert.throws(()=>c.validateActivityRows([{...event(1),...changes}],'events'));
assert.throws(()=>c.validateActivityRows([event(1),event(1)],'events'));
assert.throws(()=>c.validateActivityRows(Array(201).fill(event(1)),'events'));
assert.equal(c.validateActivityRows([{sha:'a'.repeat(40),timestamp:event(1).timestamp,subject:'actual commit'}],'commits')[0].heading,'aaaaaaaa · actual commit');

class Node{
 constructor(tag){this.tag=tag;this.children=[];this.dataset={};this.textContent='';this.title='';this.parent=null;this._left=0;this.clientWidth=500;this.moves=0;}
 get scrollWidth(){return this.children.length*266;}
 get scrollLeft(){return this._left;}set scrollLeft(v){this._left=Math.max(0,Math.min(v,this.scrollWidth-this.clientWidth));}
 appendChild(n){this.insertBefore(n,null);}
 insertBefore(n,before){if(n.parent)n.remove();n.parent=this;const i=before?this.children.indexOf(before):this.children.length;this.children.splice(i,0,n);this.moves++;}
 remove(){if(this.parent){const a=this.parent.children;a.splice(a.indexOf(this),1);this.parent=null;}}
 contains(n){return this.children.some(child=>child===n||child.contains(n));}
 getBoundingClientRect(){const left=this.parent?this.parent.children.indexOf(this)*266-this.parent.scrollLeft:0;return {left,right:left+(this.parent?260:this.clientWidth)};}
}
{
 const track=new Node('track'),status=new Node('status');let active=null;
 const current={heading:new Node('heading'),detail:new Node('detail')};
 const view=c.createActivityView(track,status,t=>new Node(t),()=>active,current);
 view.update(rows([1,2,3,4,5,6]));assert.equal(track.scrollLeft,1096,'initial latest');
 assert.equal(current.heading.textContent,'現在：OPS-111 · <img src=x onerror=alert(1)> · 返却');assert(current.detail.textContent.includes('repeat 6'),'latest detail restored separately');
 assert.equal(track.children[0].children.length,1,'one line only');assert.equal(track.children[0].dataset.event,'return');
 const stable=track.children[2],moves=track.moves;view.update(rows([1,2,3,4,5,6]));
 assert.strictEqual(track.children[2],stable);assert.equal(track.moves,moves,'unchanged nodes never move');
 track.scrollLeft=300;const anchor=track.children[1],offset=anchor.getBoundingClientRect().left;
 active=stable.children[0];view.update(rows([2,3,4,5,6,7]));
 assert.equal(anchor.getBoundingClientRect().left,offset,'rolling window keeps retained visible card at same offset');
 assert.strictEqual(track.children[1],stable);assert(track.contains(active),'focus node retained');
 assert.equal(track.scrollLeft,34,'past browsing does not follow');
 active=null;track.scrollLeft=track.scrollWidth;view.update(rows([2,3,4,5,6,7,8]));assert.equal(track.scrollLeft,1362,'latest follows');
 active=track.children[5];const old=track.scrollLeft;view.update(rows([2,3,4,5,6,7,8,9]));assert.equal(track.scrollLeft,old,'focused card inhibits follow');
 const detailBefore=current.detail.textContent;view.failure();assert.equal(current.detail.textContent,detailBefore,'failure retains latest detail');assert(status.textContent.includes('最終情報を保持'));assert.equal(track.children.length,8);
 view.update(rows([2,3,4,5,6,7,8,9]));assert.equal(status.dataset.stale,'false');
}
async function main(){
 let hidden=false,calls=0,pending,last,failed=0,aborts=0,id=0;
 const timers=new Map(),schedule=(fn,ms)=>{timers.set(++id,{fn,ms});return id;},cancel=id=>timers.delete(id);
 const poll=c.createActivityPoller({kind:'events',fetchRecord:(path,options)=>{calls++;assert.equal(path,'/activity-events');assert.equal(options.cache,'no-store');return new Promise((resolve,reject)=>{pending={resolve,reject};options.signal.reject=reject;});},view:{update:r=>{last=r;},failure:()=>failed++},isHidden:()=>hidden,schedule,cancel,makeController:()=>({signal:{},abort(){aborts++;this.signal.reject(Error('aborted'));}})});
 const settle=()=>new Promise(r=>setImmediate(r));
 const respond=async data=>{pending.resolve({ok:true,json:async()=>data});await settle();};
 const tick=async ms=>{const t=[...timers].find(([,v])=>v.ms===ms);assert(t);timers.delete(t[0]);t[1].fn();await settle();};
 const first=poll.poll();poll.poll();assert.equal(calls,1,'no overlap');await respond([event(1)]);await first;
 await tick(3000);pending.reject(Error('offline'));await settle();assert.equal(last[0].id,event(1).id);assert.equal(failed,1);
 await tick(3000);await respond([event(1),event(2,'recheck')]);assert.equal(last.length,2,'repeated trips retained after recovery');
 hidden=true;poll.visibility();assert.equal(timers.size,0);await poll.poll();assert.equal(calls,3,'hidden pauses');
 hidden=false;poll.visibility();await tick(5000);assert.equal(aborts,1);assert.equal(last.length,2,'timeout retains last result');
 await tick(3000);hidden=true;poll.visibility();await settle();assert.equal(aborts,2);assert.equal(timers.size,0,'hidden abort leaves no timer');
 hidden=false;poll.visibility();await respond([]);assert.equal(last.length,0,'missing log empty');
 const eventsLast=last;
 const commits=c.createActivityPoller({kind:'commits',fetchRecord:async path=>{assert.equal(path,'/activity-commits');return {ok:false};},view:{update:()=>assert.fail('failed commit row must not paint'),failure:()=>{}},isHidden:()=>false,schedule,cancel,makeController:()=>({signal:{},abort(){}})});
 await commits.poll();assert.strictEqual(last,eventsLast,'commit failure cannot affect event row');
 assert(!source.includes('innerHTML')&&!source.includes('render(')&&!source.includes('/sync')&&!source.includes('window.scroll'),'isolated text-only updates');
 assert(html.includes('.activity-timelines{height:48px')&&html.includes('overflow-anchor:none'),'fixed footprint, explicit scroll anchoring');
 console.log('PASS: activity validation; repeated trips; stable DOM/focus; rolling-window scroll anchor; latest follow; isolated polling, recovery, hidden pause/abort, timeout.');
}
main().catch(e=>{console.error(e);process.exitCode=1;});
