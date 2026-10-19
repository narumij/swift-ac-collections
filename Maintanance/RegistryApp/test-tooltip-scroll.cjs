// OPS-126: the card explanation (#graphTip) closes when the page scrolls. Isolated test of the actual line; no browser.
const fs=require('fs'),vm=require('vm'),assert=require('assert');
const html=fs.readFileSync(__dirname+'/index.template.html','utf8');
const marker='// OPS-126: the card explanation is fixed to the viewport';
const a=html.indexOf(marker);assert(a>=0,'marker present');
const start=html.indexOf("if(typeof window!=='undefined')window.addEventListener('scroll'",a),line=html.slice(start,html.indexOf('\n',start));
const listeners=[],tip={hidden:false};
const c={window:{addEventListener:(type,fn,opts)=>listeners.push({type,fn,opts})},$:id=>{assert.equal(id,'graphTip');return tip;}};
vm.createContext(c);vm.runInContext(line,c);
assert.equal(listeners.length,1);assert.equal(listeners[0].type,'scroll');assert(listeners[0].opts&&listeners[0].opts.passive,'passive listener');
listeners[0].fn();assert.equal(tip.hidden,true,'page scroll closes the explanation');
// The existing paths are unchanged: graph-box scroll and leaving a card close it; the OFF setting suppresses it.
assert(html.includes("$('graph').onscroll=()=>tip.hidden=true;"),'graph box scroll still closes it');
assert(html.includes("g.onpointerleave=()=>tip.hidden=true;"),'leaving a card still closes it');
assert(html.includes("function show(t,x,y){if(!$('graphHoverEnabled').checked){tip.hidden=true;return;}"),'OFF setting still suppresses it');
console.log('PASS: OPS-126 page scroll closes the card explanation; existing hover/OFF/graph-scroll paths unchanged.');
