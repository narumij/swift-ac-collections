const { webkit } = require('/opt/homebrew/lib/node_modules/playwright');
const fs = require('node:fs'), assert = require('node:assert/strict');
(async () => {
  const [origin, root, first, second] = process.argv.slice(2), browser = await webkit.launch();
  try {
    const page = await browser.newPage(), errors = [];
    page.on('pageerror', error => errors.push(error.message));
    await page.route('**/*', route => new URL(route.request().url()).origin === origin ? route.continue() : route.abort());
    await page.goto(origin);
    await page.locator('#taskAreaTab').click();
    await page.locator('#owner').fill('preserved task edit');
    await page.locator('#documentAreaTab').click();
    await page.locator('#canonical-document-select').selectOption(first);
    await page.waitForFunction(() => { const text=document.getElementById('canonical-document-body').textContent;return text.includes('First live')&&text.includes('Second live')&&text.includes('見つかりません'); });
    assert.deepEqual(await page.locator('.canonical-part').evaluateAll(nodes=>nodes.map(n=>n.dataset.path)), ['Maintanance/Current/first.md','Maintanance/Current/second.md','Maintanance/Current/missing.md']);
    assert.match(await page.locator('#canonical-task-letter-list').textContent(),/LTR-fixture/);
    assert.ok(!(await page.locator('#canonical-document-body').textContent()).includes('LTR-fixture'));
    fs.writeFileSync(root+'/Maintanance/Current/first.md','# Updated first');
    fs.writeFileSync(root+'/Maintanance/Current/second.md','# Updated second');
    await page.waitForFunction(()=>{const text=document.getElementById('canonical-document-body').textContent;return text.includes('Updated first')&&text.includes('Updated second');});
    await page.locator('#canonical-document-select').selectOption(second);
    await page.waitForFunction(()=>document.querySelectorAll('.canonical-part').length===1&&document.getElementById('canonical-document-body').textContent.includes('Updated second'));
    fs.writeFileSync(root+'/Maintanance/Current/first.md','# Old task must not appear');
    await page.waitForTimeout(200);
    assert.ok(!(await page.locator('#canonical-document-body').textContent()).includes('Old task'));
    fs.unlinkSync(root+'/Maintanance/Current/second.md');
    await page.waitForFunction(()=>document.getElementById('canonical-document-body').textContent.includes('見つかりません'));
    fs.writeFileSync(root+'/Maintanance/Current/second.md','# Restored second');
    await page.waitForFunction(()=>document.getElementById('canonical-document-body').textContent.includes('Restored second'));
    assert.equal(await page.locator('footer').isVisible(),false);
    assert.equal(await page.locator('.header-info').isVisible(),false);
    await page.locator('#workAreaTab').click();assert.equal(await page.locator('#workArea').isVisible(),true);
    await page.locator('#taskAreaTab').click();assert.equal(await page.locator('#owner').inputValue(),'preserved task edit');
    await page.locator('#documentAreaTab').click();assert.match(await page.locator('#canonical-document-body').textContent(),/Restored second/);
    assert.deepEqual(errors,[]);
    console.log('PASS: task-context multipart order, missing source, both live updates, task switching, deletion/recovery, source separation and task input retention');
  } finally { await browser.close(); }
})().catch(error=>{console.error(error);process.exit(1)});
