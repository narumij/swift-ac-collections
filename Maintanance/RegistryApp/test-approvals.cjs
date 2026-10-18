// Tests the actual isolated approval code, without a server or durable approval store.
const fs=require('fs'),vm=require('vm'),assert=require('assert');
const html=fs.readFileSync(__dirname+'/index.template.html','utf8');
const source=html.slice(html.indexOf('const approvalStatusLabels='),html.indexOf('function startCommitApprovals('));
const c={};vm.createContext(c);vm.runInContext(source,c);
const row=(id,status='pending',revision=1)=>({id,revision,taskId:'OPS-114',title:'<img src=x onerror=alert(1)>',scope:'limited\n'+'範囲'.repeat(1000),paths:['Maintanance/RegistryApp/index.template.html','long/'+ 'p'.repeat(500)],condition:'受入条件\n全件確認',branch:'example',status,createdAt:'2026-10-18T12:00:00Z',updatedAt:'2026-10-18T12:00:00Z',approvedAt:null,commitSha:null});
const list=(...requests)=>({requests,policyNotice:'規則反映前はAstraが会話で直前承認を確認します'});
const plain=value=>JSON.parse(JSON.stringify(value));
class Node{
 constructor(tag){this.tag=tag;this.children=[];this.dataset={};this.parent=null;this.textContent='';this.disabled=false;this.hidden=false;this.scrollLeft=0;this.scrollTop=0;this.open=false;this.moves=0;}
 appendChild(node){this.insertBefore(node,null);}
 insertBefore(node,before){if(node.parent)node.remove();node.parent=this;this.children.splice(before?this.children.indexOf(before):this.children.length,0,node);this.moves++;}
 remove(){if(this.parent){const siblings=this.parent.children;siblings.splice(siblings.indexOf(this),1);this.parent=null;}}
 showModal(){this.open=true;}close(){this.open=false;}
}
function makeView(){const nodes={};for(const key of ['track','history','historySummary','status','policy','all','dialog','detail','close'])nodes[key]=new Node(key);nodes.all.disabled=true;return {...nodes,view:c.createApprovalView({...nodes,makeNode:tag=>new Node(tag)})};}
const v=makeView();let clicked;
v.view.bind((action,targets)=>clicked={action,targets:plain(targets)});
v.view.update(list(row('a'),row('b','approved'),row('c','claimed'),row('d','consumed'),row('e','cancelled')));v.view.availability(true,false);
assert.equal(v.track.children.length,3);assert.equal(v.history.children.length,2);assert.equal(v.all.textContent,'表示中の未承認1件を承認');
v.all.onclick();assert.deepEqual(clicked,{action:'approve',targets:[{id:'a',revision:1}]});
const a=v.track.children[0],buttons=a.children[2];buttons.children[1].onclick();assert.deepEqual(clicked.targets,[{id:'a',revision:1}]);buttons.children[2].onclick();assert.equal(clicked.action,'cancel');
buttons.children[0].onclick();assert(v.dialog.open);assert(v.detail.textContent.includes(row('a').scope));assert(v.detail.textContent.includes(row('a').paths[1]));assert(v.detail.textContent.includes('<img'));assert.equal(v.detail.children.length,0,'untrusted text never becomes DOM');
const moves=v.track.moves;v.track.scrollLeft=125;v.view.update(list(row('a'),row('b','approved'),row('c','claimed'),row('d','consumed'),row('e','cancelled')));
assert.strictEqual(v.track.children[0],a,'retains focused card and button identity');assert.strictEqual(a.children[2],buttons);assert.equal(v.track.moves,moves);assert.equal(v.track.scrollLeft,125);assert(v.dialog.open);
assert(v.track.children[2].children[2].children[2].disabled,'claimed cannot cancel');assert.equal(v.track.children[2].children[2].children[2].textContent,'取消不可');
v.view.availability(false,false);assert(v.all.disabled&&buttons.children[1].disabled&&buttons.children[2].disabled);
v.view.failure('offline');assert.equal(v.track.children.length,3);assert.equal(v.status.dataset.stale,'true');
for(const value of [{},list({...row('a'),revision:0}),list(row('a'),row('a')),list({...row('a'),paths:[]}),list({...row('a'),status:'unknown'}),list({...row('a'),condition:null})])assert.throws(()=>c.validateApprovalList(value));
function harness(){
 let hidden=false,id=0;const timers=new Map(),requests=[],updates=[],failures=[],available=[];
 const schedule=(fn,ms)=>{timers.set(++id,{fn,ms});return id;},cancel=id=>timers.delete(id);
 const controller=c.createApprovalController({fetchRecord:(path,options)=>{assert.equal(path,'/commit-approvals');return new Promise((resolve,reject)=>requests.push({options,resolve,reject}));},view:{update:value=>updates.push(plain(value)),failure:text=>failures.push(text),availability:(...args)=>available.push(args)},isHidden:()=>hidden,schedule,cancel,makeController:()=>new AbortController()});
 const settle=()=>new Promise(resolve=>setImmediate(resolve));
 const respond=async(index,value,status=200)=>{requests[index].resolve({ok:status===200,status,json:async()=>value});await settle();};
 const tick=async ms=>{const t=[...timers].find(([,t])=>t.ms===ms);assert(t,'timer '+ms);timers.delete(t[0]);t[1].fn();await settle();};
 return {controller,requests,updates,failures,available,timers,respond,tick,settle,setHidden:value=>hidden=value};
}
async function main(){
 const h=harness();const {controller:p}=h;
 p.poll();p.poll();assert.equal(h.requests.length,1,'GET no overlap');await h.respond(0,list(row('a'),row('b')));
 // A poll already underway must never rewind a later POST result.
 await h.tick(3000);assert.equal(h.requests.length,2);
 const target=[{id:'a',revision:1},{id:'b',revision:1}];const mutation=p.act('approve',target);target.push({id:'future',revision:1});target[0].revision=99;
 assert(h.requests[1].options.signal.aborted);assert.equal(h.requests.length,3);
 const sent=h.requests[2].options;assert.equal(sent.method,'POST');assert.equal(sent.headers['X-Registry-Studio'],'commit-approvals');assert.deepEqual(JSON.parse(sent.body),{action:'approve',targets:[{id:'a',revision:1},{id:'b',revision:1}]});
 await p.act('approve',[{id:'a',revision:1}]);assert.equal(h.requests.length,3,'double click blocked');
 await h.respond(2,list(row('a','approved',2),row('b','approved',2),row('future')));await mutation;
 await h.respond(1,list(row('a'),row('b')));assert.equal(h.updates.at(-1).requests[0].status,'approved','late GET discarded');
 const before=h.requests.length;await p.act('approve',[]);await p.act('approve',[{id:'a',revision:1}]);await p.act('cancel',[{id:'a',revision:2},{id:'a',revision:2}]);assert.equal(h.requests.length,before,'empty, stale and duplicate targets refused');
 // A real view click sends only its current pending cards, excluding added-after-click rows.
 const w=makeView();w.view.bind(p.act);w.view.update(h.updates.at(-1));w.view.availability(true,false);w.all.onclick();assert.deepEqual(JSON.parse(h.requests[3].options.body).targets,[{id:'future',revision:1}]);
 await h.respond(3,{},409);assert(h.failures.at(-1).includes('更新'));assert.equal(h.available.at(-1)[0],false);await p.act('approve',[{id:'future',revision:1}]);assert.equal(h.requests.length,4,'failure disables action');
 await h.tick(3000);h.requests[4].reject(Error('offline'));await h.settle();assert.equal(h.updates.at(-1).requests[0].status,'approved','failure retains last good list');assert.equal(h.available.at(-1)[0],false);
 await h.tick(3000);await h.respond(5,list(row('future')));assert.equal(h.available.at(-1)[0],true,'healthy GET re-enables actions');
 await h.tick(3000);await h.tick(5000);assert(h.requests[6].options.signal.aborted);assert.equal(h.available.at(-1)[0],false,'timeout disables action');
 await h.tick(3000);h.setHidden(true);p.visibility();await h.settle();assert(h.requests[7].options.signal.aborted);assert.equal(h.timers.size,0);await p.poll();assert.equal(h.requests.length,8,'hidden pauses');
 h.setHidden(false);p.visibility();await h.respond(8,list());assert.equal(h.updates.at(-1).requests.length,0);assert.equal(h.available.at(-1)[0],true);
 assert(!source.includes('innerHTML')&&!source.includes('render(')&&!source.includes('/sync')&&!source.includes('window.scroll'),'isolated text-only code');
 assert(html.indexOf('class="approval-lane"')>html.indexOf('</header>'),'lane outside sticky header');
 console.log('PASS: actual approval view + controller; safe complete detail, retained DOM/scroll; individual and all click snapshots; empty/stale/duplicate rejection; claimed cancellation guard; conflict/offline/timeout/recovery; late GET cannot rewind POST; no duplicate/hidden polling.');
}
main().catch(error=>{console.error(error);process.exitCode=1;});

// Header and lower lane use one view/controller, not a second polling loop.
{
 const nodes={};for(const key of ['track','history','historySummary','status','policy','all','dialog','detail','close','topStatus','topAll'])nodes[key]=new Node(key);
 const view=c.createApprovalView({...nodes,makeNode:t=>new Node(t),signals:true,extraStatuses:[nodes.topStatus],extraAllButtons:[nodes.topAll]});
 let calls=[];view.bind((action,targets)=>calls.push({action,targets:plain(targets)}));
 const same=()=>{assert.equal(nodes.status.textContent,nodes.topStatus.textContent);assert.equal(nodes.status.dataset.stale,nodes.topStatus.dataset.stale);assert.equal(nodes.all.textContent,nodes.topAll.textContent);assert.equal(nodes.all.disabled,nodes.topAll.disabled);};
 view.update(list());view.availability(true,false);same();assert(nodes.topAll.disabled);
 view.update(list(row('new', 'pending', 3)));same();assert(!nodes.topAll.disabled);
 nodes.topAll.onclick();assert.deepEqual(calls,[{action:'approve',targets:[{id:'new',revision:3}]}]);
 view.availability(false,true);same();assert(nodes.topAll.disabled);assert(nodes.topStatus.textContent.includes('操作停止中'));
 view.failure('取得不調');same();assert.equal(nodes.topStatus.dataset.stale,'true');
 view.update(list(row('new','approved',4)));view.availability(true,false);same();assert(nodes.topAll.disabled);
 view.update(list(row('second')));same();assert(!nodes.topAll.disabled);
 console.log('PASS: header approval mirrors count, signal, failure, busy state and shared action; new requests enable both buttons.');
}
