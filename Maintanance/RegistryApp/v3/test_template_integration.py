#!/usr/bin/env python3
"""OPS-180 tests: the V3 branches P1-P6 are part of index.template.html, and V3-only behavior is gated on source.kind.
The real Studio functions run in the harness with a legacy-shaped document (the export with its V3 marks replaced
by a legacy source), next to the V3 export they were accepted with. Temporary files only; the template is read only.

Run: python3 -B Maintanance/RegistryApp/v3/test_template_integration.py -v
"""
import copy
import json
import subprocess
import sys
import unittest
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
import hermetic  # noqa: E402,F401  (first: temporary roots for every live path, OPS-167 K9)
import studio_adapter as sa  # noqa: E402
from test_browser_roundtrip import V3_BRANCHES  # noqa: E402
from test_studio_adapter import Studio  # noqa: E402

TEMPLATE = HERE.parent / 'index.template.html'


class Template(Studio):
    def legacy(self):
        doc = sa.export_doc(self.conn)
        doc.pop('v3')
        doc['source'] = {'path': 'Maintanance/ProgressV2/TASK_REGISTRY_V2.md', 'sha256': '0' * 64, 'head': '0' * 40, 'generatedAt': 't', 'dirty': False}
        return doc

    def run_edit(self, doc, actions):
        self.n += 1
        out = subprocess.run(['node', str(HERE / 'studio_harness.cjs'), 'edit', str(self.file(f'doc-{self.n}.json', doc)),
                              str(self.file(f'actions-{self.n}.json', actions)), str(self.dir / f'save-{self.n}.json')], capture_output=True, text=True, timeout=60)
        return out, (json.loads((self.dir / f'save-{self.n}.json').read_text(encoding='utf-8')) if out.returncode == 0 else None)

    def test_each_branch_is_in_the_template_once(self):
        html = TEMPLATE.read_text(encoding='utf-8')
        for name, marker in V3_BRANCHES.items():
            self.assertEqual(html.count(marker), 1, name)

    def test_legacy_plan_tools_have_no_position(self):
        out, _ = self.run_edit(self.legacy(), [{'set': {'planAddVersionAfter': '0.1.0'}}])
        self.assertNotEqual(out.returncode, 0)
        self.assertIn('field not found: planAddVersionAfter', out.stderr, 'no position select on a legacy page')
        out, save = self.run_edit(self.legacy(), [{'set': {'planNewVersion': '0.4.0'}}, {'pressTool': '版を追加'}])
        self.assertEqual(out.returncode, 0, out.stderr[-1500:])
        start = next(m for m in save['milestones'] if m['id'] == 'START-0.4.0')
        self.assertNotIn('planPosition', start, 'a legacy save gains no V3 field')
        self.assertNotIn('kind', save['source'])

    def test_v3_plan_tools_keep_the_position(self):
        out, save = self.run_edit(sa.export_doc(self.conn), [{'set': {'planNewVersion': '0.4.0', 'planAddVersionAfter': '0.1.0'}}, {'pressTool': '版を追加'}])
        self.assertEqual(out.returncode, 0, out.stderr[-1500:])
        self.assertEqual(next(m for m in save['milestones'] if m['id'] == 'START-0.4.0')['planPosition'], {'after': '0.1.0'})

    def test_legacy_check_is_unchanged(self):
        """check() of the template: a legacy document as before; a V3 export only when well-formed."""
        script = '''
const fs=require('fs'),vm=require('vm');const html=fs.readFileSync(process.argv[1],'utf8');
const a=html.indexOf('\\nfunction check(');const m=/\\)\\s*\\{/g;m.lastIndex=a;let i=html.indexOf('{',m.exec(html).index),d=0;for(;i<html.length;i++){if(html[i]==='{')d++;else if(html[i]==='}'&&--d===0)break;}
const c={};vm.createContext(c);vm.runInContext(html.slice(a+1,i+1)+';function proposalNodes(){return [];}',c);
for(const f of process.argv.slice(2)){try{c.check(JSON.parse(fs.readFileSync(f,'utf8')));console.log('accepted');}catch(e){console.log('refused');}}'''
        legacy, v3 = self.legacy(), sa.export_doc(self.conn)
        no_sha = copy.deepcopy(legacy)
        del no_sha['source']['sha256']
        v3_no_generation = copy.deepcopy(v3)
        del v3_no_generation['source']['generation']
        v3_with_sha = copy.deepcopy(v3)
        v3_with_sha['source']['sha256'] = '0' * 64
        files = [self.file(f'c-{i}.json', d) for i, d in enumerate((legacy, no_sha, v3, v3_no_generation, v3_with_sha))]
        out = subprocess.run(['node', '-e', script, str(TEMPLATE), *map(str, files)], capture_output=True, text=True, timeout=60)
        self.assertEqual(out.stdout.split(), ['accepted', 'refused', 'accepted', 'refused', 'refused'], out.stderr)


if __name__ == '__main__':
    sys.exit(0 if unittest.main(exit=False, verbosity=2 if '-v' in sys.argv else 1).result.wasSuccessful() else 1)
