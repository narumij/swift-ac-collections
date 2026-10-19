#!/usr/bin/env python3
"""OPS-177/179 tests: inbox.py keeping legacy and V3 saves side by side (accepted as the copy v3_inbox in OPS-177,
merged into inbox.py in OPS-179). V3 saves come from the real Studio editor (harness); legacy saves are minimal
hand-built Studio documents. Legacy compatibility is checked against the previous inbox.py, read from git at PREVIOUS
into a temporary file (no kept copy). Every folder is a TemporaryDirectory and every call names it; the real Inbox is
never read or written (CLI runs get REGISTRY_STUDIO_INBOX).

Run: python3 -B Maintanance/RegistryApp/v3/test_v3_inbox.py -v
"""
import copy
import hashlib
import importlib.util
import json
import os
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
import hermetic  # noqa: E402,F401  (first: temporary roots for every live path, OPS-167 K9)
sys.path.insert(0, str(HERE.parent))  # RegistryApp: inbox.py, always called with an explicit folder here
import inbox as vi  # noqa: E402
from test_change_groups import Groups  # noqa: E402

PREVIOUS = 'ea1d7e62efee3b71e869c823ba9b63304db6eff1'  # the last commit of inbox.py before OPS-179 (legacy only)
INBOX_PY = HERE.parent / 'inbox.py'
_previous = {}


def setUpModule():
    tmp = tempfile.TemporaryDirectory()
    _previous['tmp'] = tmp
    path = Path(tmp.name) / 'inbox.py'
    path.write_bytes(subprocess.run(['git', 'show', f'{PREVIOUS}:Maintanance/RegistryApp/inbox.py'], cwd=HERE, capture_output=True, check=True).stdout)
    spec = importlib.util.spec_from_file_location('inbox_previous', path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    _previous.update(module=module, path=path)


def tearDownModule():
    _previous.pop('tmp').cleanup()


def cli(script, folder, *args):
    """inbox.py's CLI on a temporary folder only (REGISTRY_STUDIO_INBOX)."""
    return subprocess.run([sys.executable, '-B', str(script), *args], capture_output=True, text=True, timeout=60,
                          env=dict(os.environ, REGISTRY_STUDIO_INBOX=str(folder)))


def legacy_doc(n=1):
    return {'schemaVersion': 1, 'source': {'path': 'Maintanance/ProgressV2/TASK_REGISTRY_V2.md', 'sha256': f'{n:064x}', 'head': 'abc1234', 'generatedAt': 't'},
            'tasks': [], 'edges': [], 'baseline': {'tasks': [], 'edges': []}, 'exportedAt': f'2026-10-19T00:00:0{n}Z'}


class Inbox(Groups):
    def setUp(self):
        super().setUp()
        self.folder = self.dir / 'inbox'

    def v3_doc(self):
        save = self.stored([{'select': 'TASK-003'}, {'set': {'owner': '担当X'}}, {'apply': True}], 'x')
        save.pop('studioSave')
        return save

    def files(self):
        return sorted(p.name for p in self.folder.glob('*')) if self.folder.exists() else []

    def digest(self, name):
        return hashlib.sha256((self.folder / name).read_bytes()).hexdigest()


class Bases(Inbox):
    def test_v3_base_has_no_sha256(self):
        doc = self.v3_doc()
        meta = vi.append_save(doc, None, self.folder)
        self.assertEqual(meta['base'], {'kind': 'v3-export', 'generation': doc['v3']['generation'], 'revision': doc['v3']['revision'],
                                        'payloadHash': doc['source']['payloadHash'], 'payloadHashOf': doc['source']['payloadHashOf']})
        stored = json.loads((self.folder / f"registry-edited-{meta['saveId']}.json").read_text(encoding='utf-8'))
        self.assertNotIn('sha256', stored['studioSave']['base'])
        self.assertEqual(vi.find(meta['saveId'], vi.V3, self.folder)['tasks'], doc['tasks'])

    def test_malformed_bases_are_refused_never_legacy(self):
        good = self.v3_doc()
        cases = {}
        cases['unknown kind'] = copy.deepcopy(good)
        cases['unknown kind']['source']['kind'] = 'v4-export'
        cases['v3 block, no kind'] = legacy_doc()
        cases['v3 block, no kind']['v3'] = copy.deepcopy(good['v3'])
        cases['kind, no v3 block'] = copy.deepcopy(good)
        del cases['kind, no v3 block']['v3']
        cases['source/v3 disagree'] = copy.deepcopy(good)
        cases['source/v3 disagree']['v3']['revision'] += 1
        cases['revision text'] = copy.deepcopy(good)
        for part in (cases['revision text']['source'], cases['revision text']['v3']):
            part['revision'] = '0'
        cases['empty generation'] = copy.deepcopy(good)
        for part in (cases['empty generation']['source'], cases['empty generation']['v3']):
            part['generation'] = ''
        cases['bad payloadHash'] = copy.deepcopy(good)
        cases['bad payloadHash']['source']['payloadHash'] = 'x' * 64
        cases['no payloadHashOf'] = copy.deepcopy(good)
        del cases['no payloadHashOf']['source']['payloadHashOf']
        cases['sha256 in a V3 source'] = copy.deepcopy(good)
        cases['sha256 in a V3 source']['source']['sha256'] = ''
        cases['source not an object'] = copy.deepcopy(good)
        cases['source not an object']['source'] = 'v3-export'
        for name, doc in cases.items():
            with self.assertRaises(vi.InvalidBase, msg=name):
                vi.append_save(doc, None, self.folder)
        self.assertEqual(self.files(), [], 'nothing stored')

    def test_invalid_stored_saves_are_listed_not_resumed(self):
        ok = vi.append_save(self.v3_doc(), None, self.folder)
        bad = vi.append_save(self.v3_doc(), None, self.folder)
        path = self.folder / f"registry-edited-{bad['saveId']}.json"
        doc = json.loads(path.read_text(encoding='utf-8'))
        doc['v3']['revision'] += 1  # edited by hand afterwards: source and v3 disagree
        path.write_text(json.dumps(doc, ensure_ascii=False), encoding='utf-8')
        meta_only = vi.append_save(self.v3_doc(), None, self.folder)
        path = self.folder / f"registry-edited-{meta_only['saveId']}.json"
        doc = json.loads(path.read_text(encoding='utf-8'))
        doc['studioSave']['base']['revision'] = 99  # the stored base no longer matches the save
        path.write_text(json.dumps(doc, ensure_ascii=False), encoding='utf-8')
        out = vi.latest(self.folder, vi.V3)
        self.assertEqual(out['save']['studioSave']['saveId'], ok['saveId'], 'the newest valid V3 save, not a newer invalid one')
        self.assertEqual({e['saveId']: e['reason'] for e in out['invalid']},
                         {bad['saveId']: 'source and v3 disagree on generation/revision', meta_only['saveId']: 'the stored base does not match the save'})
        with self.assertRaises(ValueError):
            vi.find(bad['saveId'], vi.V3, self.folder)


class Mixed(Inbox):
    def test_newer_legacy_is_reported_not_resumed(self):
        v3 = vi.append_save(self.v3_doc(), None, self.folder)
        old = vi.append_save(legacy_doc(), None, self.folder)  # newer than the V3 save
        name = f"registry-edited-{old['saveId']}.json"
        before = self.digest(name)
        out = vi.latest(self.folder, vi.V3)
        self.assertEqual((out['save']['studioSave']['saveId'], out['heads'], out['saves']), (v3['saveId'], 1, 1))
        self.assertEqual(out['unresolvedLegacy'], [{'saveId': old['saveId'], 'savedAt': old['savedAt'], 'file': name}])
        self.assertEqual(vi.latest(self.folder, vi.LEGACY)['save']['studioSave']['saveId'], old['saveId'])
        self.assertEqual(vi.latest(self.folder)['save']['studioSave']['saveId'], old['saveId'], 'without a kind: inbox.latest as it is')
        vi.record_import(old['saveId'], '照合済み（試験）', self.folder)
        self.assertEqual(vi.latest(self.folder, vi.V3)['unresolvedLegacy'], [], 'an IMPORTS record ends the report')
        self.assertEqual(self.digest(name), before, 'the legacy file is never changed')
        with self.assertRaises(ValueError):
            vi.find(old['saveId'], vi.V3, self.folder)

    def test_series_never_mix_kinds(self):
        v3 = vi.append_save(self.v3_doc(), None, self.folder)
        old = vi.append_save(legacy_doc(), None, self.folder)
        files = self.files()
        with self.assertRaises(ValueError) as caught:
            vi.append_save(self.v3_doc(), old['saveId'], self.folder)
        self.assertIn('never mixes kinds', str(caught.exception))
        with self.assertRaises(ValueError):
            vi.append_save(legacy_doc(2), v3['saveId'], self.folder)
        with self.assertRaises(ValueError):
            vi.append_save(self.v3_doc(), 'no-such-save', self.folder)
        self.assertEqual(self.files(), files)
        child = vi.append_save(self.v3_doc(), v3['saveId'], self.folder)
        self.assertEqual((child['series'], child['branched']), (v3['series'], False))
        stale = vi.append_save(self.v3_doc(), v3['saveId'], self.folder)
        self.assertEqual((stale['series'], stale['branched']), (stale['saveId'], True), 'an older tab starts a new series, as inbox does')



class Malformed(Inbox):
    """Malformed stored files next to a valid V3 save: each is listed as invalid, none breaks the folder (acceptance)."""

    def test_bad_files_are_listed_and_the_valid_save_resumes(self):
        good = vi.append_save(self.v3_doc(), None, self.folder)
        dup = vi.append_save(legacy_doc(2), None, self.folder)
        dup_text = (self.folder / f"registry-edited-{dup['saveId']}.json").read_text(encoding='utf-8')
        bad = {'source-list.json': {'source': ['bad']}, 'empty-meta.json': {'source': {}, 'studioSave': {}},
               'saved-at-number.json': dict(legacy_doc(), studioSave={'saveId': 'n1', 'savedAt': 5, 'series': 'n1', 'parent': None, 'base': {}}),
               'extra-meta-key.json': dict(legacy_doc(), studioSave={'saveId': 'n2', 'savedAt': '', 'series': 'n2', 'parent': None, 'base': {}, 'file': 'x'}),
               'exported-at-number.json': dict(legacy_doc(), exportedAt=5), 'a-list.json': [1]}
        for name, doc in bad.items():
            (self.folder / name).write_text(json.dumps(doc), encoding='utf-8')
        (self.folder / 'zz-duplicate.json').write_text(dup_text, encoding='utf-8')  # a second file claiming dup's saveId
        before = {p.name: p.read_bytes() for p in self.folder.glob('*')}
        out = vi.latest(self.folder, vi.V3)
        self.assertEqual(out['save']['studioSave']['saveId'], good['saveId'])
        reasons = {e['file']: e['reason'] for e in out['invalid']}
        self.assertEqual(set(reasons), set(bad) | {'zz-duplicate.json', f"registry-edited-{dup['saveId']}.json"})
        self.assertEqual(reasons['source-list.json'], 'source is not an object')
        self.assertIn('malformed studioSave: fields', reasons['empty-meta.json'])
        self.assertIn('wrong type', reasons['saved-at-number.json'])
        self.assertIn('fields file', reasons['extra-meta-key.json'])
        self.assertEqual(reasons['exported-at-number.json'], 'exportedAt is not text')
        self.assertEqual(reasons['a-list.json'], 'not a JSON object')
        self.assertEqual(reasons['zz-duplicate.json'], 'duplicate saveId ' + dup['saveId'])
        self.assertEqual(out['unresolvedLegacy'], [], 'a duplicated legacy save is invalid, not an unresolved candidate')
        self.assertEqual(vi.latest(self.folder)['save']['studioSave']['saveId'], good['saveId'], 'the kind-less view skips unusable identities')
        with self.assertRaises(ValueError):
            vi.append_save(legacy_doc(3), dup['saveId'], self.folder)  # an ambiguous parent
        child = vi.append_save(self.v3_doc(), good['saveId'], self.folder)
        self.assertEqual(child['series'], good['series'])
        run = cli(INBOX_PY, self.folder, 'list')
        self.assertEqual(run.returncode, 0, run.stderr)
        self.assertIn('invalid (source is not an object)', run.stdout)
        self.assertTrue(all(p.read_bytes() == before[p.name] for p in self.folder.glob('*') if p.name in before), 'nothing is rewritten')


class History(Inbox):
    """A malformed IMPORTS.jsonl: the reconciliation is unknown, nothing is inferred, the V3 save still resumes, and
    nothing is recorded while duplicates cannot be checked (OPS-179)."""

    def setUp(self):
        super().setUp()
        self.v3 = vi.append_save(self.v3_doc(), None, self.folder)
        self.old = vi.append_save(legacy_doc(), None, self.folder)
        self.other = vi.append_save(legacy_doc(2), None, self.folder)
        vi.record_import(self.old['saveId'], '照合済み', self.folder)

    def break_history(self, line):
        with open(self.folder / vi.IMPORTS, 'a', encoding='utf-8') as out:
            out.write(line + '\n')
        return (self.folder / vi.IMPORTS).read_bytes()

    def test_known_history(self):
        out = vi.latest(self.folder, vi.V3)
        self.assertEqual((out['reconciliation'], [e['saveId'] for e in out['unresolvedLegacy']]), ('known', [self.other['saveId']]))

    def test_unknown_history_keeps_the_resume(self):
        for bad in ('{"saveId": ', '5'):
            with self.subTest(bad=bad):
                self.break_history(bad)
                out = vi.latest(self.folder, vi.V3)
                self.assertEqual(out['save']['studioSave']['saveId'], self.v3['saveId'], 'the valid V3 save still resumes')
                self.assertEqual((out['reconciliation'], out['unresolvedLegacy']), ('unknown', None), 'neither imported nor unimported is inferred')
                self.assertEqual(out['importProblems'][-1]['line'], 2 if bad.startswith('{') else 3)
                self.assertEqual(vi.latest(self.folder)['save']['studioSave']['saveId'], self.other['saveId'], 'the kind-less view does not read the history')
                records, problems = vi.read_imports(self.folder)
                self.assertEqual(([r['saveId'] for r in records], len(problems)), ([self.old['saveId']], 1 if bad.startswith('{') else 2))
                with self.assertRaises(ValueError):
                    vi.imports(self.folder)

    def test_record_is_refused_while_unknown(self):
        history = self.break_history('not json')
        with self.assertRaises(ValueError) as caught:
            vi.record_import(self.other['saveId'], 'n', self.folder)
        self.assertIn('duplicates cannot be checked', str(caught.exception))
        run = cli(INBOX_PY, self.folder, 'record', self.old['saveId'], '--note', 'again')
        self.assertNotEqual(run.returncode, 0)
        self.assertEqual((self.folder / vi.IMPORTS).read_bytes(), history, 'nothing appended')
        listed = cli(INBOX_PY, self.folder, 'list')
        self.assertEqual(listed.returncode, 0, listed.stderr)
        self.assertIn('IMPORTS.jsonl: unreadable lines 2; import state unknown', listed.stdout)
        self.assertEqual(listed.stdout.count('import state unknown'), 3, 'the header and both legacy saves')
        self.assertNotIn('not imported', listed.stdout)


    def unknown_and_blocked(self, history):
        out = vi.latest(self.folder, vi.V3)
        self.assertEqual(out['save']['studioSave']['saveId'], self.v3['saveId'], 'the valid V3 save still resumes')
        self.assertEqual((out['reconciliation'], out['unresolvedLegacy']), ('unknown', None))
        with self.assertRaises(ValueError):
            vi.record_import(self.other['saveId'], 'n', self.folder)
        self.assertEqual((self.folder / vi.IMPORTS).read_bytes(), history, 'nothing appended')
        listed = cli(INBOX_PY, self.folder, 'list')
        self.assertEqual(listed.returncode, 0, listed.stderr)
        self.assertIn('import state unknown', listed.stdout)
        return out

    def test_malformed_records_are_unknown(self):
        good = (self.folder / vi.IMPORTS).read_bytes()
        for bad in ('{"saveId": []}', '{"recordedAt": "t", "note": "n"}', '{"saveId": 5, "recordedAt": "t", "note": "n"}',
                    '{"saveId": "", "recordedAt": "t", "note": "n"}', '{"saveId": "x", "recordedAt": 1, "note": "n"}', '{"saveId": "x", "recordedAt": "t"}'):
            with self.subTest(bad=bad):
                (self.folder / vi.IMPORTS).write_bytes(good)
                out = self.unknown_and_blocked(self.break_history(bad))
                self.assertEqual(out['importProblems'], [{'line': 2, 'error': 'not a record: saveId (non-empty text), recordedAt and note (text) are required'}])

    def test_undecodable_history_is_unknown(self):
        (self.folder / vi.IMPORTS).write_bytes(b'\xff\xfe{"saveId"\n')
        out = self.unknown_and_blocked((self.folder / vi.IMPORTS).read_bytes())
        self.assertEqual(out['importProblems'][0]['line'], None)
        self.assertIn('cannot be read', out['importProblems'][0]['error'])


class LegacyOnly(Inbox):
    """The same legacy-only folder read by the previous inbox.py (git PREVIOUS) and by the merged one."""

    def build(self):
        self.folder.mkdir()
        (self.folder / 'registry-edited-old.json').write_text(json.dumps(legacy_doc(1)), encoding='utf-8')  # an older save without studioSave
        (self.folder / 'broken.json').write_text('{', encoding='utf-8')
        old = _previous['module']
        first = old.append_save(legacy_doc(2), None, self.folder)
        old.append_save(legacy_doc(3), first['saveId'], self.folder)
        old.append_save(legacy_doc(4), first['saveId'], self.folder)  # stale parent: a branch

    def test_reads_equal_inbox(self):
        self.build()
        old = _previous['module']
        strip = lambda saves: [{k: v for k, v in s.items() if k not in ('kind', 'invalid')} for s in saves]
        self.assertEqual(strip(vi.load_saves(self.folder)), old.load_saves(self.folder))
        self.assertEqual({s.get('kind') for s in vi.load_saves(self.folder) if 'error' not in s}, {'legacy'})
        self.assertEqual(vi.latest(self.folder), old.latest(self.folder))
        legacy = vi.latest(self.folder, vi.LEGACY)
        self.assertEqual((legacy['save'], legacy['heads'], legacy['saves'], legacy['invalid']), (old.latest(self.folder)['save'], 3, 4, []))
        self.assertIsNone(vi.latest(self.folder, vi.V3)['save'])
        self.assertEqual(len(vi.latest(self.folder, vi.V3)['unresolvedLegacy']), 4)

    def test_appends_equal_inbox(self):
        self.build()
        old = _previous['module']
        twin = self.dir / 'twin'
        twin.mkdir()
        for p in self.folder.glob('*'):
            (twin / p.name).write_bytes(p.read_bytes())
        parent = old.load_saves(self.folder)[1]['saveId']
        a = old.append_save(legacy_doc(5), parent, self.folder)
        b = vi.append_save(legacy_doc(5), parent, twin)
        same = lambda m: {k: v for k, v in m.items() if k not in ('saveId', 'savedAt', 'series')}
        self.assertEqual(same(a), same(b))
        self.assertEqual((a['series'] == a['saveId'], b['series'] == b['saveId']), (True, True), 'both branch from the stale parent')
        self.assertEqual(json.loads((self.folder / f"registry-edited-{a['saveId']}.json").read_text(encoding='utf-8'))['tasks'],
                         json.loads((twin / f"registry-edited-{b['saveId']}.json").read_text(encoding='utf-8'))['tasks'])
        vi.record_import(b['saveId'], 'n', twin)
        old.record_import(a['saveId'], 'n', self.folder)
        self.assertEqual([r['note'] for r in vi.imports(twin)], [r['note'] for r in old.imports(self.folder)])

    def test_cli_list_equals_previous(self):
        self.build()
        old = _previous['module']
        old.record_import(old.load_saves(self.folder)[1]['saveId'], 'n', self.folder)
        before, now = cli(_previous['path'], self.folder, 'list'), cli(INBOX_PY, self.folder, 'list')
        self.assertEqual((now.returncode, now.stdout), (before.returncode, before.stdout))
        self.assertIn('imported', now.stdout)


if __name__ == '__main__':
    sys.exit(0 if unittest.main(exit=False, verbosity=2 if '-v' in sys.argv else 1).result.wasSuccessful() else 1)
