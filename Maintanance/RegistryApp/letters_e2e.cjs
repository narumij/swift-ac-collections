// OPS-187: headless WebKit driver for the letters round trip through a real serve.py (test-letters-e2e.py).
// It opens the real page of the real server and waits for the page's own letter poller; it never answers a request
// itself. Requests to other origins are aborted before sending; same-origin paths in params.blockPaths (live stores that
// have no path override) are aborted too and recorded. The browser is closed in finally, also on failure.
//
// node letters_e2e.cjs <origin> <params.json> <dir>
//   params: {letterId, blockPaths, phaseTimeoutMs}
//   1. open /, wait until the work-page letter list shows letterId, click it, wait for the detail text;
//      write <dir>/phase1.json (row text, detail heading/texts/events, requests so far)
//   2. wait for <dir>/go.json (written by the test after the recipient's explicit receive), then wait until the row of
//      letterId shows a receipt time; write <dir>/phase2.json
'use strict';
const pw = require('/opt/homebrew/lib/node_modules/playwright');
const fs = require('fs');
const path = require('path');
const [origin, paramsFile, dir] = process.argv.slice(2);
const params = JSON.parse(fs.readFileSync(paramsFile, 'utf8'));
const timeout = params.phaseTimeoutMs || 30000;

(async () => {
  const result = { requests: [], blocked: [], blockedSameOrigin: [], pageErrors: [] };
  const browser = await pw.webkit.launch();
  try {
    const context = await browser.newContext({ viewport: { width: 1400, height: 1000 }, locale: 'ja-JP', timezoneId: 'Asia/Tokyo' });
    await context.route('**/*', route => {
      const u = new URL(route.request().url());
      if (u.origin === origin && (params.blockPaths || []).some(p => u.pathname === p || u.pathname.startsWith(p + '/'))) {
        result.blockedSameOrigin.push(u.pathname);
        return route.abort('blockedbyclient');
      }
      if (u.origin === origin) { result.requests.push(route.request().method() + ' ' + u.pathname + u.search); return route.continue(); }
      result.blocked.push(u.href);
      return route.abort('blockedbyclient');
    });
    const page = await context.newPage();
    page.on('pageerror', e => result.pageErrors.push(e.message));
    await page.goto(origin + '/');
    const read = id => page.evaluate(id => {
      const row = [...document.querySelectorAll('#letters-list > *')].find(n => n.title === id);
      const detail = document.getElementById('letters-detail');
      return {
        row: row ? row.textContent : null, selected: row ? row.getAttribute('aria-pressed') : null,
        status: document.getElementById('letters-status').textContent,
        detail: detail.textContent, pre: [...detail.querySelectorAll('pre')].map(p => p.textContent)
      };
    }, id);
    // phase 1: the letter appears through the page's own poller; selecting it shows its text
    await page.waitForFunction(id => [...document.querySelectorAll('#letters-list > *')].some(n => n.title === id), params.letterId, { timeout });
    await page.evaluate(id => [...document.querySelectorAll('#letters-list > *')].find(n => n.title === id).click(), params.letterId);
    await page.waitForFunction(() => document.querySelectorAll('#letters-detail pre').length > 0, null, { timeout });
    result.phase1 = await read(params.letterId);
    result.phase1.requests = result.requests.slice();
    fs.writeFileSync(path.join(dir, 'phase1.json'), JSON.stringify(result, null, 1));
    // phase 2: after the explicit receive (made by the test through the CLI), the poll shows the receipt time
    const deadline = Date.now() + timeout;
    while (!fs.existsSync(path.join(dir, 'go.json'))) {
      if (Date.now() > deadline) throw Error('no go.json from the test in ' + dir + ': ' + fs.readdirSync(dir).join(','));
      await page.waitForTimeout(100);
    }
    const go = JSON.parse(fs.readFileSync(path.join(dir, 'go.json'), 'utf8'));
    // the oracle times are formatted here from the server's own values, independently of the page's code
    result.expect = await page.evaluate(go => ({
      sent: new Date(go.sentAt).toLocaleString('ja-JP', { hour12: false }),
      received: new Date(go.receivedAt).toLocaleString('ja-JP', { hour12: false })
    }), go);
    await page.waitForFunction(([id, received]) => {
      const row = [...document.querySelectorAll('#letters-list > *')].find(n => n.title === id);
      return row && row.textContent.includes('受領日時 ' + received) && document.getElementById('letters-detail').textContent.includes('受領日時 ' + received);
    }, [params.letterId, result.expect.received], { timeout });
    result.phase2 = await read(params.letterId);
    result.ok = true;
  } catch (e) {
    result.ok = false;
    result.error = String(e && e.stack || e);
    try { result.last = await (await browser.contexts()[0].pages()[0]).evaluate(() => document.getElementById('letters-list').textContent + '\n---\n' + document.getElementById('letters-status').textContent); } catch (_) { /* best effort */ }
  } finally {
    await browser.close();
    fs.writeFileSync(path.join(dir, 'result.json'), JSON.stringify(result, null, 1));
  }
})();
