// OPS-138: older activity-event cards get one darker step; the newest keeps the current look. Actual createActivityView.
const fs=require('fs'),vm=require('vm'),assert=require('assert');
const html=fs.readFileSync(__dirname+'/index.template.html','utf8');
const slice=(a,b)=>{const i=html.indexOf(a),j=html.indexOf(b);assert(i>=0&&j>i,'markers '+a);return html.slice(i,j);};
const c={};vm.createContext(c);vm.runInContext(slice('const activityLabels=','function startActivityTimelines('),c);
class Node{constructor(t){this.tag=t;this.children=[];this.dataset={};this.textContent='';this.title='';this.parent=null;this.scrollLeft=0;this.scrollWidth=0;this.clientWidth=0;}
 appendChild(n){this.insertBefore(n,null);}insertBefore(n,b){if(n.parent)n.remove();n.parent=this;const i=b?this.children.indexOf(b):this.children.length;this.children.splice(i,0,n);}
 remove(){if(this.parent){const a=this.parent.children;a.splice(a.indexOf(this),1);this.parent=null;}}contains(n){return n===this||this.children.some(x=>x.contains(n));}
 getBoundingClientRect(){return {left:0,right:0,top:0,bottom:0};}}
let seq=0;const ev=()=>{seq++;return {schemaVersion:1,id:seq.toString(16).padStart(32,'0'),taskId:'OPS-1',event:['request','work','return'][seq%3],owner:'姫',reason:'r'+seq,timestamp:new Date(Date.UTC(2026,9,19,1,0,seq)).toISOString().replace('.000Z','Z')};};
const track=new Node('track'),status=new Node('status');const view=c.createActivityView(track,status,t=>new Node(t));
const list=[ev(),ev(),ev()];view.update(c.validateActivityRows(list,'events'));
assert.deepEqual(track.children.map(n=>n.dataset.age),['older','older','latest'],'only the newest is latest');
const kept=track.children[2];list.push(ev());view.update(c.validateActivityRows(list,'events'));
assert.deepEqual(track.children.map(n=>n.dataset.age),['older','older','older','latest']);assert.equal(kept.dataset.age,'older','the previous newest steps down once');
assert.strictEqual(track.children[2],kept,'nodes are reused, not rebuilt');
view.update(c.validateActivityRows([list[0]],'events'));assert.deepEqual(track.children.map(n=>n.dataset.age),['latest'],'a single card is the newest');
const css=html.slice(0,html.indexOf('</style>'));
assert(css.includes('.activity-card[data-age="older"]{background:rgba(0,0,0,.22)}'),'one quiet step, background only');
assert(!/\.activity-card\[data-age="older"\]\{[^}]*(color|border|outline|opacity|filter)/.test(css),'text, state colour and focus untouched');
assert(!/data-age="(oldest|very|older-\d)/.test(html),'no further darkening steps');
console.log('PASS: OPS-138 older event cards one step darker (newest unchanged, reused nodes, background only).');
