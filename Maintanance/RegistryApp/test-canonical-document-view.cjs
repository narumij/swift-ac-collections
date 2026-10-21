const assert = require('node:assert/strict');
const fs = require('node:fs');
const {chromium} = require('playwright');
const root = __dirname + '/';
(async()=>{
 const browser = await chromium.launch({channel:'chrome',headless:true});
 try {
 const page=await browser.newPage();
 await page.setContent('<dialog id="documentDialog"><h2 id="documentTitle"></h2><p id="documentStamp"></p><article id="documentBody"></article></dialog>');
 await page.addScriptTag({content:"const $=id=>document.getElementById(id); function el(tag,text){const e=document.createElement(tag);e.textContent=text;return e;}"});
 await page.addScriptTag({content:fs.readFileSync(root+'index.task.document.js','utf8')});
 const fixture=require(root+'test-canonical-document.cjs');
 await page.evaluate(f=>{window.model=new CanonicalDocumentViewModel(f); model.subscribe(renderCanonicalDocument);window.openDocument=p=>model.select(p);model.select('first.md');},fixture);
 assert.equal(await page.locator('#documentBody h1').textContent(),'最初の正本');
 assert.equal(await page.locator('#documentTitle').textContent(),'first.md');
 await page.evaluate(()=>model.select('missing.md'));
 assert.match(await page.locator('#documentBody').textContent(),/同梱されていません/);
 assert.equal(await page.locator('#documentBody h1').count(),0);
 await page.evaluate(()=>model.select('second.md'));
 assert.equal(await page.locator('#documentBody h1').textContent(),'次の正本');
 console.log('canonical document view fixtures: PASS');

 } finally {await browser.close();}
})().catch(e=>{console.error(e);process.exit(1)});
