// OPS-166 headless WebKit driver for the isolated V3 Studio server. Experiment only; no install, no production access.
// Every request is intercepted BEFORE it is sent: only the isolated origin is continued, anything else is aborted and
// recorded. The browser is closed in finally, also on failure.
//
// node browser_roundtrip.cjs <origin> <mode> <params.json> <out.json>
//   params.blockPaths (any mode, OPS-167 K9): same-origin paths aborted before sending, recorded in blockedSameOrigin
//   save:     open /, task area, select params.task, set params.owner/state, 変更を適用, (params.addPrerequisite), 保存
//   reopen:   open / in a fresh context; the page's own resumeWorkspace loads the latest save; read fields, banner, notice
//   plan:     OPS-173: params.actions (select / fill / choose / press) in the real editor, then 保存
//             OPS-176: tool (+ toolSet {id: value}) presses a button of the card list's plan tools (#planTools)
//   look:     OPS-177: open /, let the page's own resume settle, read (no edit, no save)
//   refresh:  OPS-177: resume, press 更新 (POST /sync, then the page reloads), read the resumed page again
//   openFile: OPS-180: choose params.file in the page's own 開く (#open), then read
//   blocked:  negative control of the interception: fetch params.url from the page; it must be aborted before sending
'use strict';
const pw = require('/opt/homebrew/lib/node_modules/playwright');
const fs = require('fs');
const [origin, mode, paramsFile, out] = process.argv.slice(2);
const params = JSON.parse(fs.readFileSync(paramsFile, 'utf8'));

(async () => {
  const result = { mode, requests: [], blocked: [], pageErrors: [] };
  const browser = await pw.webkit.launch();
  try {
    const context = await browser.newContext({ viewport: { width: 1400, height: 1000 }, locale: 'ja-JP', timezoneId: 'UTC' });
    await context.route('**/*', route => {
      const url = route.request().url();
      const u = new URL(url);
      // OPS-167 K9: params.blockPaths are same-origin paths aborted before sending (a real serve.py's live pollers)
      if (u.origin === origin && (params.blockPaths || []).some(p => u.pathname === p || u.pathname.startsWith(p + '/'))) { result.blockedSameOrigin = (result.blockedSameOrigin || []).concat(u.pathname); return route.abort('blockedbyclient'); }
      if (u.origin === origin) { result.requests.push(route.request().method() + ' ' + u.pathname); return route.continue(); }
      result.blocked.push(url);
      return route.abort('blockedbyclient');
    });
    const page = await context.newPage();
    page.on('pageerror', e => result.pageErrors.push(e.message));
    await page.goto(origin + '/');
    await page.waitForTimeout(300);
    const read = () => page.evaluate(() => ({
      owner: (document.getElementById('owner') || {}).value, state: (document.getElementById('state') || {}).value,
      title: document.getElementById('selectedTitle').textContent, banner: document.getElementById('sourceInfo').textContent,
      notice: document.getElementById('canonicalNotice').hidden ? null : document.getElementById('canonicalSummary').textContent + '\n' + document.getElementById('canonicalDiff').textContent,
      status: document.getElementById('status').textContent,
      restartSuggested: !(document.getElementById('canonicalRestartNotice') || { hidden: true }).hidden }));  // OPS-181
    if (mode === 'save') {
      await page.click('#taskAreaTab');
      await page.selectOption('#taskPicker', params.task);
      if (params.owner !== undefined) await page.fill('#owner', params.owner);
      if (params.state !== undefined) await page.selectOption('#state', params.state);
      await page.evaluate(() => [...document.querySelectorAll('#editor button')].find(b => b.textContent === '変更を適用').click());
      if (params.addPrerequisite) {
        await page.selectOption('#prerequisite', params.addPrerequisite);
        await page.evaluate(() => [...document.querySelectorAll('#editor button')].find(b => b.textContent === '前提を追加').click());
      }
      await page.evaluate(() => document.getElementById('save').click());
      await page.waitForFunction(() => /保存しました|保存できませんでした/.test(document.getElementById('status').textContent), null, { timeout: 10000 });
      result.after = await read();
    } else if (mode === 'reopen') {
      await page.click('#taskAreaTab');
      await page.waitForFunction(() => /再開中/.test(document.getElementById('sourceInfo').textContent), null, { timeout: 10000 });
      await page.selectOption('#taskPicker', params.task);
      result.after = await read();
      if (params.screenshot) await page.screenshot({ path: params.screenshot });
    } else if (mode === 'plan') {
      // OPS-173: existing-card plan edits through the real editor, then the page's own save
      await page.evaluate(() => typeof resumed === 'undefined' ? true : resumed.then(() => true));  // let the page's own resume settle first
      result.resumedFrom = await page.evaluate(() => (document.getElementById('sourceInfo').textContent.match(/編集版 (\S+) を再開中/) || [])[1] || null);
      await page.click('#taskAreaTab');
      for (const a of params.actions) {
        if (a.select) await page.selectOption('#taskPicker', a.select);
        if (a.fill) for (const [id, v] of Object.entries(a.fill)) await page.fill('#' + id, v);
        if (a.choose) for (const [id, v] of Object.entries(a.choose)) await page.selectOption('#' + id, v);
        if (a.press) await page.evaluate(t => [...document.querySelectorAll('#editor button')].find(b => b.textContent === t).click(), a.press);
        if (a.tool) {  // OPS-176: the card list's plan tools (new card, new version with its position)
          // the tools sit in a panel closed by default: set the value and fire the page's own input/change handlers
          await page.evaluate(([t, values]) => {
            for (const [id, v] of Object.entries(values)) {
              const e = document.getElementById(id); if (!e) throw Error('no field ' + id);
              e.value = v; if (e.value !== v) throw Error('value not accepted: ' + id + '=' + v);
              e.dispatchEvent(new Event(e.tagName === 'SELECT' ? 'change' : 'input', { bubbles: true }));
            }
            const b = [...document.querySelectorAll('#planTools button')].find(n => n.textContent === t); if (!b) throw Error('no tool ' + t); b.click();
          }, [a.tool, a.toolSet || {}]);
        }
      }
      await page.evaluate(() => document.getElementById('save').click());
      await page.waitForFunction(() => /保存しました|保存できませんでした/.test(document.getElementById('status').textContent), null, { timeout: 10000 });
      result.after = await read();
    } else if (mode === 'look') {
      // OPS-177: open /, let the page's own resume settle (it may refuse to resume), then read; no edit, no save
      await page.evaluate(() => typeof resumed === 'undefined' ? true : resumed.then(() => true));
      await page.waitForTimeout(300);
      result.after = await read();
    } else if (mode === 'refresh') {
      // OPS-177: resume, press 更新 (POST /sync, then the page reloads itself), and read the resumed page again
      await page.waitForFunction(() => /再開中/.test(document.getElementById('sourceInfo').textContent), null, { timeout: 10000 });
      result.before = await read();
      await Promise.all([page.waitForNavigation({ timeout: 10000 }), page.evaluate(() => document.getElementById('refresh').click())]);
      await page.waitForFunction(() => /再開中/.test(document.getElementById('sourceInfo').textContent), null, { timeout: 10000 });
      result.after = await read();
    } else if (mode === 'openFile') {
      // OPS-180: the page's own 開く (file input #open) with params.file; read the status and banner afterwards
      await page.evaluate(() => typeof resumed === 'undefined' ? true : resumed.then(() => true));
      await page.setInputFiles('#open', params.file);
      await page.waitForTimeout(500);
      result.after = await read();
    } else if (mode === 'blocked') {
      result.fetch = await page.evaluate(async url => { try { await fetch(url); return 'sent'; } catch (e) { return 'failed: ' + e.message; } }, params.url);
    }
  } finally {
    await browser.close();
    fs.writeFileSync(out, JSON.stringify(result, null, 1) + '\n');
  }
})().catch(e => { console.error(e); process.exit(1); });
