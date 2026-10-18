const pw=require('/opt/homebrew/lib/node_modules/playwright');const [url]=process.argv.slice(2);
(async()=>{const b=await pw.webkit.launch({headless:true});const r=[];try{
 const p=await b.newPage({viewport:{width:1400,height:900}});await p.goto(url);await p.waitForTimeout(2500);
 const c=await p.$('#graph g.node:has(text:text-matches("^DOC-026"))');
 for(const wait of [0,16,50,100,300]){await c.scrollIntoViewIfNeeded();await c.hover();await p.waitForTimeout(200);
  const v=await p.evaluate(async w=>{document.querySelector('#requestSection').scrollIntoView();await new Promise(res=>setTimeout(res,w));return !document.querySelector('#graphTip').hidden;},wait);r.push({waitMs:wait,stillVisible:v});}
}finally{await b.close();}console.log(JSON.stringify(r));})();
