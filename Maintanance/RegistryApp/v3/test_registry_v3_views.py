#!/usr/bin/env python3
"""OPS-175 tests: generated read-only views (K8a). Templates are fixed read-only copies; outputs go to fresh trees.

Run: python3 -B Maintanance/RegistryApp/v3/test_registry_v3_views.py -v
"""
import copy
import hashlib
import json
import subprocess
import sys
import tempfile
import unittest
import unittest.mock
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
import hermetic  # noqa: E402,F401  (first: temporary roots for every live path, OPS-167 K9)
import registry_v3_views as rv  # noqa: E402
import registry_v3_write as w3  # noqa: E402
import shadow_import as si  # noqa: E402
import test_shadow_import as tsi  # noqa: E402

ACTOR, EVIDENCE = '姫（view試験）', ['TASK_REGISTRY_V3_READ_VIEWS.md#実装と検証']
REPO = HERE.parent.parent.parent


class Views(unittest.TestCase):
    def setUp(self):
        tmp = tempfile.TemporaryDirectory()
        self.addCleanup(tmp.cleanup)
        self.dir = Path(tmp.name).resolve()

    def build(self, root):
        """A fixed copy of root and a DB made from it by the accepted shadow import."""
        copy_dir = self.dir / f'copy-{len(list(self.dir.iterdir()))}'
        copy_dir.mkdir()
        manifest = si.snapshot(root, copy_dir)
        fixture, _ = si.parse(copy_dir, manifest, si.load_sync().vkey)
        db = self.dir / f'db-{len(list(self.dir.iterdir()))}.sqlite3'
        w3.create(str(db), fixture)
        conn = w3.open_db(str(db))
        self.addCleanup(conn.close)
        return copy_dir, conn, db, manifest

    def out(self):
        d = self.dir / f'out-{len(list(self.dir.iterdir()))}'
        return d

    def preserved(self, before, after):
        """Lines of the template outside generated rows and guards must be kept in order and byte for byte."""
        strip = lambda text: [l for l in text.split('\n') if not rv.GUARD.fullmatch(l.strip())]
        b, a = strip(before), strip(after)
        rows = lambda ls: {i for i, l in enumerate(ls) if l.startswith('| `')}
        return [l for i, l in enumerate(b) if i not in rows(b)] == [l for i, l in enumerate(a) if i not in rows(a)]

    def hashes(self, root):
        return {rel: hashlib.sha256((Path(root) / rel).read_bytes()).hexdigest() for rel in (si.REGISTRY, si.RULES)}


class Fixture(Views):
    def tree(self, **change):
        root = self.dir / 'tree'
        tsi.tree(root, **change)
        return root

    def test_generate_and_check_on_the_fixture(self):
        copy_dir, conn, _, _ = self.build(self.tree())
        before = self.hashes(copy_dir)
        views = rv.generate(copy_dir, conn, self.out())
        self.assertEqual(self.hashes(copy_dir), before, 'the template copy is read-only')
        report = rv.check(views['registry'], views['rules'], views['structure'], conn)
        self.assertTrue(report['equal'], report)
        self.assertTrue(self.preserved((copy_dir / si.REGISTRY).read_text(encoding='utf-8'), views['registry']))
        self.assertTrue(self.preserved((copy_dir / si.RULES).read_text(encoding='utf-8'), views['rules']))
        self.assertEqual(views['registry'].count('<!-- V3-GENERATED rows:'), 5, '2 task group tables (none + 現行) and 3 relation tables')
        self.assertEqual(report['accounting']['retired'], [])
        self.assertTrue(report['accounting']['complete'])
        self.assertTrue(report['permanent']['equal'])

    def test_cli_update_changes_only_its_row_and_the_guard_protects_generated_input(self):
        copy_dir, conn, db, _ = self.build(self.tree())
        first = rv.generate(copy_dir, conn, self.out())
        req = {'kind': 'update_task', 'id': 'TASK-003', 'base': {'owner': '担当C'}, 'changes': {'owner': '担当X'}, 'generation': w3.generation(conn), 'actor': ACTOR, 'evidence': EVIDENCE}
        p = self.dir / 'req.json'
        p.write_text(json.dumps(req, ensure_ascii=False), encoding='utf-8')
        run = subprocess.run([sys.executable, '-B', str(HERE / 'registry_v3_cli.py'), 'apply', '--db', str(db), '--op', 'op-1', '--request', str(p)], capture_output=True, text=True)
        self.assertEqual(run.returncode, 0, run.stdout)
        second_root = self.dir / 'gen1'
        (second_root / si.REGISTRY).parent.mkdir(parents=True)
        (second_root / si.REGISTRY).write_text(first['registry'], encoding='utf-8')
        (second_root / si.RULES).write_text(first['rules'], encoding='utf-8')
        second = rv.generate(second_root, conn, self.out())
        diff = [(a, b) for a, b in zip(first['registry'].split('\n'), second['registry'].split('\n')) if a != b]
        self.assertEqual([b for a, b in diff if not b.startswith('<!--')], ['| `TASK-003` | `ACTIVE` | 担当X | Bで始まる仕事 | Bの開始後に着手 | Maintanance/Current/B作業.md |'])
        self.assertTrue(rv.check(second['registry'], second['rules'], second['structure'], conn)['equal'])
        edited = first['registry'].replace('| 担当B |', '| 手で書き換え |')
        (second_root / si.REGISTRY).write_text(edited, encoding='utf-8')
        with self.assertRaises(rv.ViewRefused) as caught:
            rv.generate(second_root, conn, self.out())
        self.assertIn('edited by hand', str(caught.exception))

    def test_retirement_is_accounted_for(self):
        copy_dir, conn, _, _ = self.build(self.tree())
        w3.apply(conn, 'r', {'kind': 'retire_task', 'id': 'TASK-003', 'reason': '試験', 'generation': w3.generation(conn), 'actor': ACTOR, 'evidence': EVIDENCE})
        views = rv.generate(copy_dir, conn, self.out())
        self.assertNotIn('`TASK-003`', views['registry'].split('## 恒久タスクの親子関係')[0].split('## Task Registry')[1])
        report = rv.check(views['registry'], views['rules'], views['structure'], conn)
        self.assertTrue(report['equal'])
        self.assertEqual(report['accounting']['retired'], ['TASK-003'])
        self.assertEqual(sorted(tuple(e) for e in report['accounting']['hiddenEdges']),
                         [('milestone', 'START-0.2.0', 'TASK-003'), ('milestone', 'TASK-003', 'END-0.2.0'), ('progress', 'TASK-002', 'TASK-003')])
        self.assertTrue(report['accounting']['complete'])
        dropped = '\n'.join(l for l in views['registry'].split('\n') if not l.startswith('| `TASK-002` |'))
        self.assertFalse(rv.check(dropped, views['rules'], views['structure'], conn)['equal'], 'an omitted live row is not hidden by the accounting')

    def test_refusals(self):
        copy_dir, conn, _, _ = self.build(self.tree())
        reg = (copy_dir / si.REGISTRY).read_text(encoding='utf-8')
        for text, words in ((reg.replace('## Task precedence', '## Task precedenc'), 'appears 0 times'),
                            (reg + '\n## マイルストーン接続\n', 'appears 2 times'),
                            (reg.replace('## 恒久タスクの親子関係', '## 恒久タスクの親子関係\n\n| a | b |\n| --- | --- |\n| `X-1` | `X-2` |\n\n'), '2 tables'),
                            (reg.replace('## Task precedence', '## Task precedence\n\n### 内側\n\n| a | b | c | d |\n| --- | --- | --- | --- |\n'), 'inside a subsection'),
                            (reg.replace('### 現行', '### 別名'), "group '現行' has no table")):
            with self.assertRaises(rv.ViewRefused) as caught:
                rv.render_registry(text, conn)
            self.assertIn(words, str(caught.exception))
        for value, words in (('一行目\n二行目', 'line break'), ('A | B', 'not read back'), (' 前後に空白', 'whitespace')):
            conn.execute('UPDATE tasks SET condition = ? WHERE id = ?', (value, 'TASK-002'))
            with self.assertRaises(rv.ViewRefused) as caught:
                rv.render_registry(reg, conn)
            self.assertIn(words, str(caught.exception))
        conn.execute("UPDATE tasks SET condition = 'Aの成果物がそろったら完了' WHERE id = 'TASK-002'")
        out = self.out()
        out.mkdir()
        (out / 'x').write_text('x')
        with self.assertRaises(rv.ViewRefused):
            rv.generate(copy_dir, conn, out)

    def test_structure_view_is_parsed_independently_and_drift_is_separate(self):
        copy_dir, conn, _, manifest = self.build(self.tree())
        stale = rv.render_structure(conn)  # before the plan change
        w3.apply(conn, 'p', {'kind': 'apply_plan', 'cardsBase': {'0.1.0': ['MS-A1', 'MS-A2']}, 'cards': {'0.1.0': ['MS-A2', 'MS-A1']},
                             'generation': w3.generation(conn), 'actor': ACTOR, 'evidence': EVIDENCE})
        views = rv.generate(copy_dir, conn, self.out())
        parsed = rv.parse_structure(views['structure'])
        self.assertEqual([c['id'] for c in parsed['versions'][0]['cards']], ['MS-A2', 'MS-A1'], 'card order is DB data')
        listing = {'0.1.0': ['MS-A1', 'MS-A2'], '0.2.0': ['MS-B1'], '0.3.0': []}  # the folder files, in file-name order
        report = rv.check(views['registry'], views['rules'], views['structure'], conn, listing)
        self.assertTrue(report['equal'])
        self.assertEqual(report['placementDrift'], {'0.1.0': {'files': ['MS-A1', 'MS-A2'], 'db': ['MS-A2', 'MS-A1']}})
        self.assertIn('not the Milestones folders', report['scope'])
        with self.assertRaises(rv.ViewRefused):
            rv.parse_structure(views['structure'].replace('"MS-A2"', '"MS-A9"'))
        old = rv.check(views['registry'], views['rules'], stale, conn)
        self.assertEqual((old['equal'], old['parts']['structure']), (False, False), 'a STRUCTURE view of another DB state is not equal')

    def test_new_rows_are_appended_by_id(self):
        copy_dir, conn, _, _ = self.build(self.tree())
        w3.apply(conn, 'n', {'kind': 'register_task', 'prefix': 'TASK', 'fields': {'state': 'PROPOSED', 'owner': '担当N', 'item': '新しい仕事', 'condition': '条件', 'detail': 'd', 'group': '現行'},
                             'generation': w3.generation(conn), 'actor': ACTOR, 'evidence': EVIDENCE})
        views = rv.generate(copy_dir, conn, self.out())
        group = views['registry'].split('### 現行')[1].split('## ')[0]
        ids = [l.split('`')[1] for l in group.split('\n') if l.startswith('| `')]
        self.assertEqual(ids, ['TASK-002', 'TASK-003', 'TASK-101'], 'existing order kept, the new row appended (ledger TASK 100)')
        self.assertTrue(rv.check(views['registry'], views['rules'], views['structure'], conn)['equal'])
        self.assertIn('| `TASK` | `101` |', views['rules'])
        wrong = views['rules'].replace('| `TASK` | `101` |', '| `TASK` | `100` |')
        report = rv.check(views['registry'], wrong, views['structure'], conn)
        self.assertEqual((report['equal'], report['parts']['ledger']), (False, False), 'a ledger that lags the DB is not equal')



class InPlace(Views):
    """B2 (OPS-167 K9): guarded in-place regeneration of the views under an explicit (temporary) root."""
    STRUCTURE = 'Maintanance/ProgressV2/STRUCTURE.generated.md'
    tree = Fixture.tree  # the fixture tree only, not Fixture's tests again

    def update(self, conn, owner='担当X', base='担当C'):
        w3.apply(conn, f'op-{owner}', {'kind': 'update_task', 'id': 'TASK-003', 'base': {'owner': base}, 'changes': {'owner': owner},
                                       'generation': w3.generation(conn), 'actor': ACTOR, 'evidence': EVIDENCE})

    def test_first_and_later_regeneration_change_only_generated_rows(self):
        root, conn, _, _ = self.build(self.tree())
        hand = {rel: (root / rel).read_text(encoding='utf-8') for rel in (si.REGISTRY, si.RULES)}
        out = rv.replace_in_place(root, conn, self.STRUCTURE)
        self.assertTrue(out['report']['equal'])
        self.assertEqual(sorted(out['changed']), sorted([si.REGISTRY, si.RULES, self.STRUCTURE]), 'the first run adds guards and the STRUCTURE view')
        for rel in (si.REGISTRY, si.RULES):
            self.assertTrue(self.preserved(hand[rel], (root / rel).read_text(encoding='utf-8')), rel)
        first = (root / si.REGISTRY).read_text(encoding='utf-8')
        self.assertEqual(rv.replace_in_place(root, conn, self.STRUCTURE)['changed'], [], 'nothing to change: no write')
        rules_before = (root / si.RULES).read_text(encoding='utf-8')
        self.update(conn)
        out = rv.replace_in_place(root, conn, self.STRUCTURE)
        self.assertEqual(sorted(out['changed']), sorted([si.REGISTRY, si.RULES, self.STRUCTURE]), 'every guard records the new revision')
        rules_diff = [b for a, b in zip(rules_before.split('\n'), (root / si.RULES).read_text(encoding='utf-8').split('\n')) if a != b]
        self.assertTrue(rules_diff and all(rv.GUARD.fullmatch(line.strip()) for line in rules_diff), 'in Rules only the guard line moved')
        diff = [b for a, b in zip(first.split('\n'), (root / si.REGISTRY).read_text(encoding='utf-8').split('\n')) if a != b and not b.startswith('<!--')]
        self.assertEqual(diff, ['| `TASK-003` | `ACTIVE` | 担当X | Bで始まる仕事 | Bの開始後に着手 | Maintanance/Current/B作業.md |'])
        self.assertEqual(sorted(p.name for p in (root / si.REGISTRY).parent.iterdir() if p.name.startswith('.')), [], 'no temporary file is left')

    def test_refusals_write_nothing(self):
        root, conn, _, _ = self.build(self.tree())
        rv.replace_in_place(root, conn, self.STRUCTURE)
        self.update(conn)
        state = lambda: {rel: (root / rel).read_bytes() for rel in (si.REGISTRY, si.RULES, self.STRUCTURE)}
        edited = (root / si.REGISTRY).read_text(encoding='utf-8').replace('| 担当B |', '| 手で書き換え |')
        (root / si.REGISTRY).write_text(edited, encoding='utf-8')
        before = state()
        with self.assertRaises(rv.ViewRefused) as caught:
            rv.replace_in_place(root, conn, self.STRUCTURE)
        self.assertIn('edited by hand', str(caught.exception))
        self.assertEqual(state(), before)
        root2, conn2, _, _ = self.build(self.tree())
        rv.replace_in_place(root2, conn2, self.STRUCTURE)
        (root2 / self.STRUCTURE).write_text((root2 / self.STRUCTURE).read_text(encoding='utf-8').replace('focus', 'focus ', 1), encoding='utf-8')
        with self.assertRaises(rv.ViewRefused):
            rv.replace_in_place(root2, conn2, self.STRUCTURE)
        root3, conn3, _, _ = self.build(self.tree())
        rv.replace_in_place(root3, conn3)
        self.update(conn3)
        snapshot = {rel: (root3 / rel).read_bytes() for rel in (si.REGISTRY, si.RULES)}
        with self.assertRaises(rv.ViewRefused) as caught:
            rv.replace_in_place(root3, conn3, _before_write=lambda r: (r / si.RULES).write_text((r / si.RULES).read_text(encoding='utf-8') + '\n追記\n', encoding='utf-8'))
        self.assertIn('changed while regenerating', str(caught.exception))
        self.assertEqual((root3 / si.REGISTRY).read_bytes(), snapshot[si.REGISTRY], 'the Registry was not written either')

    def test_one_snapshot_while_a_writer_commits(self):
        root, conn, db, _ = self.build(self.tree())
        conn.execute('PRAGMA journal_mode = WAL')
        writer = w3.open_db(str(db))
        self.addCleanup(writer.close)
        real = rv.render_rules

        def rules_then_write(template, c):  # the CLI commits between the Registry and the Rules rendering
            text = real(template, c)
            self.update(writer)
            return text
        with unittest.mock.patch.object(rv, 'render_rules', side_effect=rules_then_write):
            out = rv.replace_in_place(root, conn)
        self.assertTrue(out['report']['equal'], 'the whole regeneration is the state before the commit')
        self.assertIn('| 担当C |', (root / si.REGISTRY).read_text(encoding='utf-8'))
        self.assertEqual(w3.revision(conn), 1, 'the commit happened meanwhile')
        self.assertIn('| 担当X |', rv.replace_in_place(root, conn) and (root / si.REGISTRY).read_text(encoding='utf-8'), 'the next run shows it')

    def test_unowned_files_are_kept_and_partial_publication_is_reported(self):
        """Review correction: staging uses owned directories only; a failure while publishing the second file is reported
        as ViewPartial (Registry published, Rules not), never as 'nothing written'; a rerun finishes it."""
        root, conn, _, _ = self.build(self.tree())
        rv.replace_in_place(root, conn)
        self.update(conn)
        folder = (root / si.REGISTRY).parent
        decoy = folder / '.TASK_RULES_V2.md.regenerating'
        decoy.write_bytes(b'not mine')
        real = rv.os.replace
        calls = []

        def second_fails(src, dst):
            calls.append(Path(dst).name)
            if len(calls) == 2:
                raise OSError('injected publication failure')
            return real(src, dst)
        rules_before = (root / si.RULES).read_bytes()
        with unittest.mock.patch.object(rv.os, 'replace', side_effect=second_fails), self.assertRaises(rv.ViewPartial) as caught:
            rv.replace_in_place(root, conn)
        self.assertEqual((caught.exception.published, caught.exception.unpublished), ([si.REGISTRY], [si.RULES]))
        self.assertIn('| 担当X |', (root / si.REGISTRY).read_text(encoding='utf-8'), 'the Registry was published')
        self.assertEqual((root / si.RULES).read_bytes(), rules_before, 'the Rules were not')
        self.assertEqual(decoy.read_bytes(), b'not mine')
        self.assertEqual(sorted(p.name for p in folder.iterdir() if p.name.startswith('.')), [decoy.name], 'only owned staging was removed')
        out = rv.replace_in_place(root, conn)
        self.assertEqual((out['changed'], out['report']['equal']), ([si.RULES], True), 'a rerun finishes the mixed view')

    def test_check_must_be_equal_and_the_caller_transaction_is_kept(self):
        root, conn, _, _ = self.build(self.tree())
        before = self.hashes(root)
        real = rv.check
        with unittest.mock.patch.object(rv, 'check', side_effect=lambda *a, **k: dict(real(*a, **k), equal=False)), self.assertRaises(rv.ViewRefused):
            rv.replace_in_place(root, conn)
        self.assertEqual(self.hashes(root), before)
        self.assertFalse(conn.in_transaction, 'the read snapshot is ended')
        conn.execute('BEGIN')
        rv.replace_in_place(root, conn)
        self.assertTrue(conn.in_transaction)
        conn.execute('ROLLBACK')


class Corrections(Views):
    """Acceptance (2026-10-19): overall success needs permanent agreement and complete accounting; malformed or
    ambiguous template rows are refused before splicing, never normalized or discarded."""
    tree = Fixture.tree

    def test_permanent_disagreement_is_not_equal(self):
        copy_dir, conn, _, _ = self.build(self.tree())
        conn.execute("UPDATE tasks SET permanent = 1 WHERE id = 'TASK-003'")
        views = rv.generate(copy_dir, conn, self.out())
        report = rv.check(views['registry'], views['rules'], views['structure'], conn)
        self.assertFalse(report['permanent']['equal'])
        self.assertFalse(report['equal'], 'the overall result includes the permanent agreement (the prose is not rewritten)')
        self.assertIn('`TASK-001`は常設の支援nodeとして', views['rules'])

    def test_malformed_or_duplicate_template_rows_are_refused(self):
        copy_dir, conn, _, _ = self.build(self.tree())
        reg = (copy_dir / si.REGISTRY).read_text(encoding='utf-8')
        row = next(l for l in reg.split('\n') if l.startswith('| `TASK-003` |'))
        for text, words in ((reg.replace(row, row + ' 余分 |'), 'expected 6 cells'),
                            (reg.replace(row, row + '\n' + row), 'duplicate'),
                            (reg.replace('| `TASK-001` | `TASK-002` |', '| `TASK-001` | `TASK-002` |\n| `TASK-001` | `TASK-002` |'), 'duplicate parent row'),
                            (reg.replace('| `TASK-003` | `TASK-002` | `SEQUENCE` |', '| `TASK-003` | `TASK-002` | `SEQUENCE` | 重複 |\n| `TASK-003` | `TASK-002` | `SEQUENCE` |'), 'duplicate precedence row'),
                            (reg.replace(row, row.replace('`TASK-003`', 'TASK-003')), 'backticked')):
            with self.assertRaises(rv.ViewRefused) as caught:
                rv.render_registry(text, conn)
            self.assertIn(words, str(caught.exception))
        rules = (copy_dir / si.RULES).read_text(encoding='utf-8')
        for text, words in ((rules.replace('| `OPS` | `160` |', '| `OPS` | `160` | 余分 |'), 'PREFIX'), (rules + '| `OPS` | `161` |\n', 'appears twice')):
            with self.assertRaises(rv.ViewRefused) as caught:
                rv.render_rules(text, conn)
            self.assertIn(words, str(caught.exception))


@unittest.skipUnless((REPO / si.REGISTRY).is_file(), 'the current canonical is not available here')
class CurrentCanonical(Views):
    def test_frozen_copy_of_the_current_canonical(self):
        copy_dir, conn, _, manifest = self.build(REPO)
        before = self.hashes(copy_dir)
        views = rv.generate(copy_dir, conn, self.out())
        self.assertEqual(self.hashes(copy_dir), before)
        listing = {}
        for entry in manifest['listing']:
            parts = entry.rstrip('/').split('/')
            listing.setdefault(parts[2], [])
        fixture, _ = si.parse(copy_dir, manifest, si.load_sync().vkey)
        for v in fixture['versions']:
            listing[v['name']] = [c['id'] for c in v['cards']]
        report = rv.check(views['registry'], views['rules'], views['structure'], conn, listing)
        self.assertTrue(report['equal'], report['parts'])
        self.assertEqual(report['placementDrift'], {}, 'just imported: the folders match the DB')
        self.assertTrue(self.preserved((copy_dir / si.REGISTRY).read_text(encoding='utf-8'), views['registry']))
        self.assertTrue(self.preserved((copy_dir / si.RULES).read_text(encoding='utf-8'), views['rules']))
        same = [l for l in (copy_dir / si.REGISTRY).read_text(encoding='utf-8').split('\n')] == [l for l in views['registry'].split('\n') if not rv.GUARD.fullmatch(l.strip())]
        self.assertTrue(same, 'rendering the imported DB reproduces the current Registry exactly, apart from the guard lines')


if __name__ == '__main__':
    sys.exit(0 if unittest.main(exit=False, verbosity=2 if '-v' in sys.argv else 1).result.wasSuccessful() else 1)
