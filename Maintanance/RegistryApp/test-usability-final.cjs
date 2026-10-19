// OPS-126 proposals 7 and 8: narrow-screen one-line scrolling (CSS) and spread end points of lines entering one card.
// Isolated tests of the actual code; no browser.
const fs=require('fs'),vm=require('vm'),assert=require('assert');
const html=fs.readFileSync(__dirname+'/index.template.html','utf8');
const a=html.indexOf('// OPS-126 proposal 8'),b=html.indexOf(' return out;\n }',a)+' return out;\n }'.length;assert(a>=0&&b>a);
const c={};vm.createContext(c);vm.runInContext(html.slice(a,b),c);
const H=96,edge=(p,s)=>({prerequisite:p,successor:s});

// 8. Three lines into M: spread in source-height order; ties by prerequisite ID; offsets inside the card, evenly spaced.
const pos=new Map([['A',[20,300]],['B',[20,100]],['C',[20,200]],['D',[20,200]],['M',[400,185]],['S',[20,500]],['T',[400,500]],['V',[400,700]]]);
const eA=edge('A','M'),eB=edge('B','M'),eC=edge('C','M'),eD=edge('D','M'),eS=edge('S','T'),eV=edge('T','V');
const off=c.edgeEntryOffsets([eA,eB,eC,eD,eS,eV],pos,H);
const order=[eB,eC,eD,eA].map(e=>off.get(e));
assert.deepEqual(order,[1,2,3,4].map(k=>H*k/5),'B(100) < C(200) = D(200, by ID) < A(300), evenly spaced');
for(const v of order)assert(v>0&&v<H,'inside the card');
assert(!off.has(eS),'a single line keeps the middle');
assert(!off.has(eV),'a vertical (same-column) line is not moved');
assert.equal(c.edgeEntryOffsets([edge('X','M'),eB],pos,H).size,0,'lines whose ends are not placed are ignored (B alone keeps the middle)');
// Deterministic: input order does not change the result.
const off2=c.edgeEntryOffsets([eD,eA,eC,eB],pos,H);for(const e of [eA,eB,eC,eD])assert.equal(off2.get(e),off.get(e));
// The path uses the offset for both the last control point and the end point; vertical paths are unchanged.
assert(html.includes("${u-20},${ey} ${u},${ey}`"),'curve ends at the spread point');
assert(html.includes("d:x===u?`M${x+W/2},${y+H} L${u+W/2},${v}`"),'vertical line unchanged');
assert(html.includes("const ey=v+(entryY.get(e)??H/2);"),'single lines keep the middle');

// 7. Only at 600px or narrower: title/actions row and the map tabs are single scrolling rows with visible focus.
const narrow=html.slice(html.lastIndexOf('@media(max-width:600px){.buttons[role=tablist]'),html.indexOf('</style>'));
// OPS-136: the header row no longer scrolls sideways (the menu list would be clipped); the tabs still do.
assert(!/header \.header-row\{[^}]*overflow-x:auto/.test(narrow),'header row does not scroll');
for(const rule of ['.buttons[role=tablist]{flex-wrap:nowrap;overflow-x:auto','header .header-row :focus-visible{outline:2px solid','.buttons[role=tablist]>button:focus-visible{outline:2px solid'])assert(narrow.includes(rule),'narrow rule: '+rule);
// User (2026-10-19, OPS-136): the header is one row on every width; only the approval part scrolls sideways.
assert(html.includes('header .header-row{display:grid;grid-template-columns:minmax(0,1fr) auto minmax(0,1fr);'),'one header row');
assert(html.includes('.header-row>.header-approval{justify-self:end;margin:0 0 0 auto;flex:0 1 auto;min-width:0;flex-wrap:nowrap;overflow-x:auto'),'the approval part scrolls instead of wrapping');
assert(/row\.addEventListener\('focusin',e=>\{if\(row\.scrollWidth>row\.clientWidth&&e\.target\.scrollIntoView\)e\.target\.scrollIntoView\(\{block:'nearest',inline:'nearest'\}\)/.test(html),'focused control shown fully only when the row overflows');
console.log('PASS: OPS-126 proposals 7 (narrow one-line scrolling rows, visible focus) and 8 (spread end points; single/vertical unchanged).');
