// OPS-132: the next taker / end on its own card line, and the compact map controls. Isolated tests of the actual code.
const fs=require('fs'),vm=require('vm'),assert=require('assert');
const html=fs.readFileSync(__dirname+'/index.template.html','utf8');
const slice=(a,b)=>{const i=html.indexOf(a),j=html.indexOf(b);assert(i>=0&&j>i,'markers '+a);return html.slice(i,j);};
const c={};vm.createContext(c);
vm.runInContext(slice('const activityLabels=','function startActivityTimelines(')+'\n'+slice('// OPS-119 work lane','// OPS-114: this lane owns only approval DOM'),c);
let seq=0;
const ev=(taskId,event,owner,reason='',extra={})=>{seq++;return {schemaVersion:1,id:seq.toString(16).padStart(32,'0'),taskId,event,owner,reason,timestamp:new Date(Date.UTC(2026,9,19,1,0,seq)).toISOString().replace('.000Z','Z'),...extra};};
const rows=list=>c.validateActivityRows(list,'events');
const appr=(id,taskId,status)=>({id,revision:1,taskId,title:'t',scope:'s',paths:['a'],condition:'c',branch:'b',status,createdAt:'x',updatedAt:'x'});
class Node{constructor(t){this.tag=t;this.children=[];this.dataset={};this.textContent='';this.title='';this.className='';this.parent=null;this.scrollLeft=0;}
 appendChild(n){this.insertBefore(n,null);}insertBefore(n,b){if(n.parent)n.remove();n.parent=this;const i=b?this.children.indexOf(b):this.children.length;this.children.splice(i,0,n);}
 remove(){if(this.parent){const a=this.parent.children;a.splice(a.indexOf(this),1);this.parent=null;}}contains(n){return n===this||this.children.some(x=>x.contains(n));}}
const track=new Node('track'),status=new Node('status');
const lane=c.createWorkLane({view:c.createWorkLaneView({track,status,makeNode:t=>new Node(t)}),registryState:id=>({'OPS-1':'ACTIVE'})[id]});
const long='Astra-'+'とても長い担当名'.repeat(6);
lane.activity(rows([ev('OPS-1','return','姫','返却',{next:'Astra'}),ev('OPS-2','acceptance','Astra','受入',{next:'none'}),ev('OPS-3','awaiting-commit','Astra','承認待ち',{next:'user'}),ev('OPS-4','work','Fable','検討中：別件'),ev('OPS-5','return','姫','返却',{next:long})]));
lane.approvals([appr('a','OPS-3','pending')]);
const card=id=>track.children.find(n=>n.children[0].textContent.startsWith(id));
// line order: heading, next, owner/time/reason, Registry/approval, start; nothing dropped
const one=card('OPS-1');assert.equal(one.children.length,5);
assert.deepEqual([one.children[0].textContent,one.children[1].textContent],['OPS-1 · 返却・受入待ち','次：Astra']);
assert(one.children[2].textContent.startsWith('姫 · ')&&one.children[2].textContent.endsWith(' · 返却'),'owner, time and reason kept');
assert.equal(one.children[3].textContent,'Registry：ACTIVE · 承認なし');assert.equal(one.children[4].textContent,'開始：不明');
assert.equal(one.children[1].className,'work-next');assert.equal(one.dataset.next,'known');
assert.equal(card('OPS-2').children[1].textContent,'この仕事は終了');assert.equal(card('OPS-2').dataset.next,'ended');
assert.equal(card('OPS-3').children[1].textContent,'次：ユーザー（承認待ち）','approval first');assert.equal(card('OPS-3').dataset.next,'approval');
assert(card('OPS-3').children[3].textContent.includes('承認 待ち1'));
assert.equal(card('OPS-4').children[1].textContent,'次：不明');assert.equal(card('OPS-4').dataset.next,'unknown');
// full text reachable: the card title holds every line, including a long next taker
const five=card('OPS-5');assert.equal(five.children[1].textContent,'次：'+long);
for(const line of five.children.slice(0,4))assert(five.title.includes(line.textContent),'title has '+line.textContent);
assert(five.title.includes('開始：不明（記録範囲外または未記録）'));
// CSS: the next line wraps (two lines at most) instead of being cut; colours follow the left line; fixed lane height
const css=html.slice(0,html.indexOf('</style>'));
assert(/\.work-card \.work-next\{white-space:normal;overflow-wrap:anywhere;[^}]*-webkit-line-clamp:2;font-weight:700/.test(css));
for(const [kind,colour] of [['approval','#c0392b'],['known','#2f6db5']]){
 assert(css.includes(`.work-lane .work-card[data-next="${kind}"]{border-left-color:${colour}`),'left line '+kind);
 assert(css.includes(`.work-lane .work-card[data-next="${kind}"] .work-next{color:${colour}}`),'text colour '+kind);}
assert(css.includes('.work-lane .work-card[data-next="ended"] .work-next{color:#4f5b57}'));
assert(css.includes('#work-lane-track{height:138px}#work-lane-track .work-card{height:122px}'),'fixed heights keep polling from moving the page');
assert(css.includes('.work-card span{white-space:nowrap;'),'other lines stay one line');// .work-card .work-next (two classes) is more specific than .work-card span, whatever the order
// Map controls: one wrapping row in DOM order version -> help -> zoom/hover; open help takes the full width
const panel=slice('<section id="dependencyView"','<div id="graph" class="graph">');
const at=s=>{const i=panel.indexOf(s);assert(i>=0,s);return i;};
assert(at('<div class="graph-controls">')<at('id="versionPicker"')&&at('id="versionPicker"')<at('class="graph-help"')&&at('class="graph-help"')<at('id="graphZoomOut"')&&at('id="graphZoomIn"')<at('id="graphHoverEnabled"'));
assert(css.includes('.graph-controls{display:flex;flex-wrap:wrap;align-items:center;'));
assert(css.includes('.graph-controls select{width:auto;max-width:100%'));
assert(css.includes('.graph-controls>.graph-help[open]{flex-basis:100%;order:1}'));
console.log('PASS: OPS-132 next line (order, approval first, end, unknown, long text in title, colours, fixed height) and compact map controls (order, wrap, open help full width).');
