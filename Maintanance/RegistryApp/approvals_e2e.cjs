// OPS-188: headless WebKit driver for the approval lane through a real serve.py (test-approvals-e2e.py).
// It opens the real page of the real server and clicks the real buttons; it never answers a request itself. The only
// interference is holding (delaying, never answering) the page's own GET /commit-approvals while the test adds a request,
// so the click is made on a known displayed snapshot. Requests to other origins and same-origin paths in
// params.blockPaths (live stores without a path override) are aborted before sending. The browser is closed in finally.
//
// node approvals_e2e.cjs <origin> <params.json> <dir>
//   params: {a, b, c, d: card titles (taskId · title), blockPaths, timeoutMs}
//   A: wait for cards a and b (承認待ち); read a's 詳細; click a's 承認; wait until a is 承認済み; write A.json
//   B: wait for <dir>/c-added; wait until c shows; hold the next GET; write held.json; wait for <dir>/d-added;
//      click 表示中の未承認…件を承認; wait for the result; let the page poll again; write B.json
'use strict';
const pw = require('/opt/homebrew/lib/node_modules/playwright');
const fs = require('fs');
const path = require('path');
const [origin, paramsFile, dir] = process.argv.slice(2);
const params = JSON.parse(fs.readFileSync(paramsFile, 'utf8'));
const timeout = params.timeoutMs || 30000;
const write = (name, value) => fs.writeFileSync(path.join(dir, name), JSON.stringify(value, null, 1));
const waitFile = async (page, name) => {
  const end = Date.now() + timeout;
  while (!fs.existsSync(path.join(dir, name))) { if (Date.now() > end) throw Error('no ' + name + ' from the test'); await page.waitForTimeout(50); }
};

(async () => {
  const result = { requests: [], posts: [], blocked: [], blockedSameOrigin: [], held: 0, pageErrors: [] };
  let hold = false, releases = [];
  const browser = await pw.webkit.launch();
  try {
    const context = await browser.newContext({ viewport: { width: 1400, height: 1000 }, locale: 'ja-JP', timezoneId: 'Asia/Tokyo' });
    await context.route('**/*', async route => {
      const req = route.request(), u = new URL(req.url());
      if (u.origin === origin && (params.blockPaths || []).some(p => u.pathname === p || u.pathname.startsWith(p + '/'))) {
        result.blockedSameOrigin.push(u.pathname); return route.abort('blockedbyclient');
      }
      if (u.origin !== origin) { result.blocked.push(u.href); return route.abort('blockedbyclient'); }
      result.requests.push(req.method() + ' ' + u.pathname);
      if (req.method() === 'POST' && u.pathname === '/commit-approvals') result.posts.push(JSON.parse(req.postData()));
      if (hold && req.method() === 'GET' && u.pathname === '/commit-approvals') {
        result.held++;
        await new Promise(r => releases.push(r));  // the page itself aborts it when the click starts its POST
        return route.continue().catch(() => {});
      }
      return route.continue();
    });
    const page = await context.newPage();
    page.on('pageerror', e => result.pageErrors.push(e.message));
    await page.goto(origin + '/');
    const cards = () => page.evaluate(() => [...document.querySelectorAll('#approval-track .approval-card, #approval-history .approval-card')]
      .map(n => ({ title: n.querySelector('strong').textContent, state: n.querySelector('span').textContent, status: n.dataset.status })));
    const card = (title, state) => page.waitForFunction(([t, s]) => [...document.querySelectorAll('.approval-card')]
      .some(n => n.querySelector('strong').textContent === t && n.querySelector('span').textContent === s), [title, state], { timeout });
    const click = (title, label) => page.evaluate(([t, l]) => {
      const n = [...document.querySelectorAll('.approval-card')].find(x => x.querySelector('strong').textContent === t);
      const b = [...n.querySelectorAll('button')].find(x => x.textContent === l);
      if (!b || b.disabled || b.hidden) throw Error(l + ' of ' + t + ' is not clickable');
      b.click();
    }, [title, label]);
    // A: the two pending requests appear; a's details; approve a alone
    await card(params.a, '承認待ち'); await card(params.b, '承認待ち');
    await page.waitForFunction(() => !document.getElementById('approval-all').disabled, null, { timeout });
    await click(params.a, '詳細');
    result.detailA = await page.evaluate(() => document.getElementById('approval-detail').textContent);
    await page.evaluate(() => document.getElementById('approval-close').click());
    await page.waitForFunction(t => [...document.querySelectorAll('.approval-card')].some(n => n.querySelector('strong').textContent === t && !n.querySelector('button:nth-child(2)').disabled), params.a, { timeout });
    await click(params.a, '承認');
    await card(params.a, '承認済み');
    result.A = await cards();
    write('A.json', result);
    // B: a third request appears, then the page's next read is held while the test adds a fourth one
    await waitFile(page, 'c-added');
    await card(params.c, '承認待ち');
    await page.waitForFunction(() => document.getElementById('approval-all').textContent === '表示中の未承認2件を承認' && !document.getElementById('approval-all').disabled, null, { timeout });
    hold = true;
    const heldAt = Date.now();
    while (result.held === 0) { if (Date.now() - heldAt > 10000) throw Error('the page did not poll'); await page.waitForTimeout(20); }
    result.shownBeforeClick = await cards();
    result.allLabel = await page.evaluate(() => document.getElementById('approval-all').textContent);
    write('held.json', { held: result.held });
    await waitFile(page, 'd-added');
    if (await page.evaluate(() => document.getElementById('approval-all').disabled)) throw Error('the bulk button was disabled before the click');
    await page.evaluate(() => document.getElementById('approval-all').click());
    hold = false; releases.splice(0).forEach(r => r());
    await card(params.b, '承認済み'); await card(params.c, '承認済み'); await card(params.d, '承認待ち');
    result.afterClick = await cards();
    // a fresh read of the page's own poll (at least one GET after the POST) shows the same
    const before = result.requests.length;
    await page.waitForFunction(() => true, null, { timeout: 100 });
    const end = Date.now() + 10000;
    while (!result.requests.slice(before).includes('GET /commit-approvals')) { if (Date.now() > end) throw Error('no poll after the click'); await page.waitForTimeout(50); }
    await page.waitForTimeout(300);
    result.B = await cards();
    result.ok = true;
  } catch (e) {
    result.ok = false;
    result.error = String(e && e.stack || e);
  } finally {
    releases.splice(0).forEach(r => r());
    await browser.close();
    write('result.json', result);
  }
})();
