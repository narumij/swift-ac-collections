// OPS-167 B4: the check of sync.py --v3-db's output (the legacy verify.cjs validates the Markdown/folder structure,
// which V3 mode does not use). Reads REGISTRY_STUDIO_APP/{index.html, registry.json}; exits non-zero on any failure.
// - the page script compiles, and the page's own check() accepts the DB export
// - the HTML seed is the export (registry.json without its extraDocuments list)
// - every document the DB refers to (task and milestone details) and the Registry view are bundled; none is missing
// - the pending queue block is present
'use strict';
const fs = require('fs'), path = require('path'), vm = require('vm'), assert = require('assert');
const output = process.env.REGISTRY_STUDIO_APP || path.resolve(__dirname, '../../Cache/RegistryStudio');
const html = fs.readFileSync(path.join(output, 'index.html'), 'utf8');
const data = JSON.parse(fs.readFileSync(path.join(output, 'registry.json'), 'utf8'));
const block = id => { const m = html.match(new RegExp('<script id="' + id + '" type="application/json">([\\s\\S]*?)</script>')); assert.ok(m, 'no ' + id + ' block'); return JSON.parse(m[1]); };
const script = html.split('<script>')[1].split('</script>')[0];
new vm.Script(script);
assert.equal(data.source.kind, 'v3-export', 'registry.json is not a V3 export');
const ctx = {}; vm.createContext(ctx);
vm.runInContext(fs.readFileSync(path.join(__dirname, '../index.task.logic.js'), 'utf8'), ctx);
const { extraDocuments = [], ...seed } = data;
ctx.check(JSON.parse(JSON.stringify(seed)));
assert.deepEqual(block('seed'), seed, 'the HTML seed is not the export');
const docs = block('documents');
const refs = new Set(extraDocuments);
for (const item of [...data.tasks, ...data.milestones]) for (const m of (item.detail || '').matchAll(/(?:Maintanance|Sources|Tests)\/[^`\s|]+?\.md/g)) refs.add(m[0]);
const absent = [...refs].filter(r => !docs.files[r]);
assert.deepEqual(absent, [], 'documents referenced by the DB are not bundled');
assert.deepEqual(docs.missing.filter(r => refs.has(r)), [], 'documents referenced by the DB are listed missing');
block('pendingSeed');
console.log(`PASS (V3): page script, check() of the DB export, seed, ${refs.size} referenced documents bundled, pending queue`);
