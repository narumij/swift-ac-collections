// OPS-189: headless WebKit driver for the restart notice of a real serve.py (test-startup-safety.py).
// It opens the real page and reads #serverRestartNotice; it never answers a request itself. Requests to other origins and
// same-origin paths in params.blockPaths are aborted before sending. The browser is closed in finally.
//
// node startup_notice_e2e.cjs <origin> <params.json> <dir>
//   1. open /, wait until the page's own /server-status check has run, write <dir>/phase1.json (notice hidden/text)
//   2. wait for <dir>/go.json (the test edited studio_store.py), fire the page's own focus check (the page also checks
//      every 30 s), wait until the notice is shown, write <dir>/result.json
'use strict';
const pw = require('/opt/homebrew/lib/node_modules/playwright');
const fs = require('fs');
const path = require('path');
const [origin, paramsFile, dir] = process.argv.slice(2);
const params = JSON.parse(fs.readFileSync(paramsFile, 'utf8'));
const timeout = params.timeoutMs || 30000;

(async () => {
  const result = { requests: [], blocked: [], blockedSameOrigin: [], pageErrors: [], statusAnswers: [] };
  const browser = await pw.webkit.launch();
  try {
    const context = await browser.newContext({ viewport: { width: 1400, height: 1000 }, locale: 'ja-JP', timezoneId: 'Asia/Tokyo' });
    await context.route('**/*', route => {
      const u = new URL(route.request().url());
      if (u.origin === origin && (params.blockPaths || []).some(p => u.pathname === p || u.pathname.startsWith(p + '/'))) {
        result.blockedSameOrigin.push(u.pathname); return route.abort('blockedbyclient');
      }
      if (u.origin !== origin) { result.blocked.push(u.href); return route.abort('blockedbyclient'); }
      result.requests.push(route.request().method() + ' ' + u.pathname);
      return route.continue();
    });
    const page = await context.newPage();
    page.on('pageerror', e => result.pageErrors.push(e.message));
    page.on('response', async r => { if (new URL(r.url()).pathname === '/server-status') result.statusAnswers.push(await r.json().catch(() => null)); });
    const notice = () => page.evaluate(() => { const n = document.getElementById('serverRestartNotice'); return { hidden: n.hidden, text: n.textContent }; });
    await page.goto(origin + '/');
    await page.waitForFunction(() => performance.getEntriesByType('resource').some(e => new URL(e.name).pathname === '/server-status'), null, { timeout });
    await page.waitForTimeout(300);
    result.before = await notice();
    fs.writeFileSync(path.join(dir, 'phase1.json'), JSON.stringify(result, null, 1));
    const end = Date.now() + timeout;
    while (!fs.existsSync(path.join(dir, 'go.json'))) { if (Date.now() > end) throw Error('no go.json from the test'); await page.waitForTimeout(50); }
    await page.evaluate(() => window.dispatchEvent(new Event('focus')));
    await page.waitForFunction(() => !document.getElementById('serverRestartNotice').hidden, null, { timeout });
    result.after = await notice();
    result.ok = true;
  } catch (e) {
    result.ok = false;
    result.error = String(e && e.stack || e);
  } finally {
    await browser.close();
    fs.writeFileSync(path.join(dir, 'result.json'), JSON.stringify(result, null, 1));
  }
})();
