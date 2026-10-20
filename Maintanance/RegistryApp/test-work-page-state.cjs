const vm=require('node:vm'),fs=require('node:fs'),assert=require('node:assert/strict');
const c=vm.createContext({}); vm.runInContext(fs.readFileSync(__dirname+'/index.work.connect.js','utf8'),c);
const Model=vm.runInContext('WorkPageViewModel',c),model=new Model();let calls=0;model.subscribe(()=>calls++);
const data={revision:1,cards:{cards:[],status:"記録なし",stale:false},wake:{owners:['A','B'],statuses:{A:{kind:'none'},B:{kind:'none'}}},failed:{activity:false,approvals:false}};
model.receive(data);assert.equal(model.snapshot().wake.selected,'A');model.select('B');assert.equal(model.snapshot().wake.selected,'B');
(async()=>{let resolve;const sent=model.send(()=>new Promise(r=>resolve=r));assert(model.snapshot().wake.disabled);model.select('A');resolve({created:true});await sent;assert.equal(model.snapshot().wake.text,'');model.disconnected();assert.equal(model.snapshot().connected,false);assert(calls>=5);console.log('PASS: observable interaction state and late WAKE response isolation')})().catch(e=>{console.error(e);process.exitCode=1});
