#!/usr/bin/env python3
"""OPS-163 tests: the fixed-source shadow import on small canonical-shaped trees in a per-test TemporaryDirectory.
Expected values are written by hand. The real repository is not read here (run shadow_import.py for that).

Run: python3 -B Maintanance/RegistryApp/v3/test_shadow_import.py -v
"""
import copy
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
import shadow_import as si  # noqa: E402

TASKS = [('TASK-001', 'ACTIVE', '担当A', '親の常設タスク', '常設の判断を保つこと', 'Maintanance/Current/常設.md', None),
         ('TASK-002', 'DONE', '担当B', 'Aでの仕事', 'Aの成果物がそろったら完了', 'Maintanance/Current/A作業.md', '現行'),
         ('TASK-003', 'ACTIVE', '担当C', 'Bで始まる仕事', 'Bの開始後に着手', 'Maintanance/Current/B作業.md', '現行')]


def registry(extra_sections='', precedence_extra='', task_extra='', milestone_extra=''):
    rows = ['# Registry', '', '## Task Registry', '', '| ID | 状態 | 担当 | 項目 | 条件 | 正本 |', '| --- | --- | --- | --- | --- | --- |']
    group = None
    for t in TASKS:
        if t[6] != group:
            rows += ['', f'### {t[6]}', '', '| ID | 状態 | 担当 | 項目 | 条件 | 正本 |', '| --- | --- | --- | --- | --- | --- |']
            group = t[6]
        rows.append(f'| `{t[0]}` | `{t[1]}` | {t[2]} | {t[3]} | {t[4]} | {t[5]} |')
    rows += [task_extra, '', '## Task precedence', '', '| 後続 | 前提 | Flow | 制約 |', '| --- | --- | --- | --- |',
             '| `TASK-003` | `TASK-002` | `SEQUENCE` | Aの結果を使う |', precedence_extra,
             '', '## 恒久タスクの親子関係', '', '| 親 | 子 |', '| --- | --- |', '| `TASK-001` | `TASK-002` |',
             '', '## マイルストーン接続', '', '| 接続元 | 接続先 | 制約 |', '| --- | --- | --- |',
             '| `TASK-002` | `MS-A1` | A1の材料 |', '| `START-0.2.0` | `TASK-003` | 開始側。Bで始める \\| 区間の最初 |', '| `TASK-003` | `END-0.2.0` | Bの完了条件 |',
             milestone_extra, extra_sections]
    return '\n'.join(rows) + '\n'


RULES = '`TASK-001`は常設の支援nodeとして`ACTIVE`を保つ。\n\n## Task ID採番状態\n\n| Prefix | 最後に使用した番号 |\n| --- | ---: |\n| `TASK` | `100` |\n| `OPS` | `160` |\n'


def card(cid, name, box, canon):
    return f'# カード情報\n\n## TL;DR（人間向け）\n\n本文\n\n## ID\n\n`{cid}`\n\n## 名前\n\n{name}\n\n## 状態\n\n{box}\n\n# 正本\n\n{canon}\n\n# 記録\n\n自由記述\n'


def gate(gid, name):
    return f'# カード情報\n\n## ID\n\n`{gid}`\n\n## 名前\n\n{name}\n\n# 正本\n\nこのファイル\n'


def tree(root, **change):
    files = {
        si.REGISTRY: registry(),
        si.RULES: RULES,
        si.MILESTONES + '/README.md': '- END-x.y.z は版フォルダごとの集合点で、実ファイルを置かない。\n',
        si.MILESTONES + '/HEAD.md': '# 0.2.0\n',
        si.MILESTONES + '/0.1.0/10_A1.md': card('MS-A1', 'A の最初', '- [x] DONE', '[正本](../../Current/A1正本.md)'),
        si.MILESTONES + '/0.1.0/20_A2.md': card('MS-A2', 'A の次', '- [ ] DONE', 'このファイル'),
        si.MILESTONES + '/0.1.0/GATE-0.2.0.md': gate('GATE-0.2.0', '0.2.0 リリース'),
        si.MILESTONES + '/0.2.0/10_B1.md': card('MS-B1', 'B の中間', '- [ ] DONE', 'このファイル'),
        si.MILESTONES + '/0.2.0/GATE-0.3.0.md': gate('GATE-0.3.0', '0.3.0 リリース'),
        si.MILESTONES + '/0.3.0/GOAL.md': '置物\n',
        si.MILESTONES + '/_Archived/old.md': '無視される\n',
        'Maintanance/Current/A1正本.md': '# A1\n',
    }
    files.update(change)
    for rel, text in files.items():
        if text is None:
            continue
        p = Path(root) / rel
        p.parent.mkdir(parents=True, exist_ok=True)
        p.write_text(text, encoding='utf-8')
    return Path(root)


class Shadow(unittest.TestCase):
    def root(self, **change):
        tmp = tempfile.TemporaryDirectory()
        self.addCleanup(tmp.cleanup)
        return tree(Path(tmp.name).resolve(), **change)

    def refused(self, error, words, **change):
        with self.assertRaises(error) as caught:
            si.run(self.root(**change))
        self.assertIn(words, str(caught.exception))


class Clean(Shadow):
    def test_clean_tree_matches_the_current_reader(self):
        r = si.run(self.root())
        self.assertTrue(r['equal'], r.get('detail'))
        c = r['consumption']
        self.assertEqual({k: c[k] for k in ('tasks', 'management', 'progress', 'milestone', 'versions', 'cards', 'gates', 'ledgerPrefixes')},
                         {'tasks': 3, 'management': 1, 'progress': 1, 'milestone': 3, 'versions': 3, 'cards': 3, 'gates': 2, 'ledgerPrefixes': 2})
        self.assertEqual(c['outOfScopeRows'], [])
        self.assertEqual(r['deviations'], [])
        self.assertEqual(r['reservation']['TASK'], {'issuedThrough': 100, 'highwater': 100, 'next': 'TASK-101', 'reservedThroughHighwater': True})
        self.assertEqual(r['reservation']['OPS']['next'], 'OPS-161')
        self.assertEqual(r['ranges']['focus'], '0.2.0')
        self.assertEqual(r['ranges']['currentVersions'], ['0.2.0', '0.3.0'])
        self.assertEqual(r['recordedDone'], {'checkedAgainstReader': ['MS-B1'], 'beforeHeadReaderDerived': [
            {'id': 'MS-A1', 'recordedDone': True, 'readerState': 'DONE'}, {'id': 'MS-A2', 'recordedDone': False, 'readerState': 'DONE'}]},
            'MS-A2: the box is open, the reader derives DONE from HEAD; kept apart, not compared')
        self.assertIn('raw, sourceLine', r['excluded'])
        roles = {f['path']: f['role'] for f in r['manifest']['files']}
        self.assertEqual(roles['Maintanance/Current/A1正本.md'], 'linked 正本')
        self.assertNotIn(si.MILESTONES + '/_Archived/old.md', roles, '_ folders are not inputs')
        self.assertFalse(r['manifest']['git']['available'], 'a plain directory has no Git basis, and none is invented')

    def test_out_of_scope_rows_are_reported_not_consumed(self):
        r = si.run(self.root(**{si.REGISTRY: registry(extra_sections='\n## 目標の記録\n\n| 目標 | 状態 |\n| --- | --- |\n| `GOAL-1` | 未達 |\n')}))
        self.assertTrue(r['equal'])
        self.assertEqual(r['consumption']['outOfScopeRows'], [{'line': len(registry().split('\n')) + 4, 'section': '目標の記録'}])

    def test_comparison_detects_a_difference(self):
        # negative control: the same compare on a fixture that differs from the copy
        root = self.root()
        sync = si.load_sync()
        with tempfile.TemporaryDirectory() as tmp:
            dest, work = Path(tmp) / 'copy', Path(tmp) / 'work'
            dest.mkdir()
            work.mkdir()
            manifest = si.snapshot(root, dest)
            fixture, _ = si.parse(dest, manifest, sync.vkey)
            changed = copy.deepcopy(fixture)
            changed['tasks'][1]['owner'] = '別の担当'
            changed['milestone'][1]['constraint'] = '別の条件'
            result = si.compare(dest, changed, sync, work)
        self.assertEqual(result['differences'], ['milestone', 'tasks'])


class Malformed(Shadow):
    def test_rows_in_unknown_shape(self):
        self.refused(si.Unknown, 'expected 6 cells, got 5', **{si.REGISTRY: registry(task_extra='| `TASK-004` | `ACTIVE` | 担当 | 項目 | 条件 |')})
        self.refused(si.Unknown, 'ID and state must be backticked', **{si.REGISTRY: registry(task_extra='| TASK-004 | `ACTIVE` | 担当 | 項目 | 条件 | 正本 |')})
        self.refused(si.Unknown, 'needs `接続元`', **{si.REGISTRY: registry(milestone_extra='| TASK-003 | `MS-B1` | 条件 |')})
        self.refused(si.Unknown, 'needs `SUCCESSOR`', **{si.REGISTRY: registry(precedence_extra='| `TASK-003` | `TASK-001` | `MAYBE` | 条件 |')})

    def test_silent_skips_of_the_current_reader_are_refused(self):
        # the current reader ignores precedence rows under a ### heading; the shadow import refuses them instead
        self.refused(si.Unknown, 'inside a subsection', **{si.REGISTRY: registry(precedence_extra='\n### 受入済み\n\n| 後続 | 前提 | Flow | 制約 |\n| --- | --- | --- | --- |\n| `TASK-003` | `TASK-001` | `SEQUENCE` | 隠れた前提 |')})

    def test_cards_files_and_head(self):
        self.refused(si.Unknown, 'exactly one', **{si.MILESTONES + '/0.2.0/10_B1.md': card('MS-B1', 'B', '- [ ] DONE\n- [x] DONE', 'このファイル')})
        self.refused(si.Unknown, 'exactly one', **{si.MILESTONES + '/0.2.0/10_B1.md': card('MS-B1', 'B', '未記入', 'このファイル')})
        self.refused(si.Unknown, '# 正本 needs', **{si.MILESTONES + '/0.2.0/10_B1.md': card('MS-B1', 'B', '- [ ] DONE', 'あとで')})
        self.refused(si.Unknown, 'unknown entry', **{si.MILESTONES + '/0.2.0/notes.txt': 'メモ'})
        self.refused(si.Unknown, 'unknown entry', **{si.MILESTONES + '/0.2.0/sub/x.md': 'x'})
        self.refused(si.Unknown, "needs a line '# x.y.z'", **{si.MILESTONES + '/HEAD.md': '0.2.0\n'})
        self.refused(si.Unknown, 'input missing', **{si.MILESTONES + '/HEAD.md': None})

    def test_ledger(self):
        self.refused(si.Unknown, 'needs `PREFIX` | `NNN`', **{si.RULES: RULES.replace('| `OPS` | `160` |', '| OPS | 160 |')})
        self.refused(si.Unknown, 'appears twice', **{si.RULES: RULES + '| `TASK` | `101` |\n'})
        self.refused(si.Unknown, '## Task ID採番状態 is missing', **{si.RULES: RULES.split('## Task ID')[0]})
        self.refused(si.Unknown, 'below the present TASK-003', **{si.RULES: RULES.replace('`100`', '`002`')})

    def test_missing_prefix_in_the_ledger_is_reported(self):
        r = si.run(self.root(**{si.RULES: RULES.replace('| `TASK` | `100` |\n', '')}))
        self.assertEqual(r['ledgerMissingPrefixes'], ['TASK'])
        self.assertEqual(r['reservation']['TASK']['next'], 'TASK-004', 'without a ledger row, only the present IDs reserve numbers')


class FalseGreens(Shadow):
    """Acceptance regressions (2026-10-19): inputs the first version accepted as equal while consuming nothing."""

    def test_target_sections_must_appear_exactly_once(self):
        self.refused(si.Unknown, 'missing: Task precedence', **{si.REGISTRY: registry().replace('## Task precedence', '## Task precedenc')})
        self.refused(si.Unknown, 'more than once: マイルストーン接続', **{si.REGISTRY: registry() + '\n## マイルストーン接続\n'})

    def test_task_shaped_rows_in_other_sections_are_reported(self):
        r = si.run(self.root(**{si.REGISTRY: registry(extra_sections='\n## 古い表\n\n| 後続 | 前提 | Flow | 制約 |\n| --- | --- | --- | --- |\n| `TASK-003` | `TASK-001` | `SEQUENCE` | 置き場所違い |\n')}))
        self.assertEqual([x['section'] for x in r['consumption']['taskShapedOutOfScope']], ['古い表'])
        self.assertTrue(r['equal'], 'reported, not consumed; the reader does not read it either')

    def test_indented_table_rows(self):
        self.refused(si.Unknown, 'indented table row', **{si.REGISTRY: registry(precedence_extra='  | `TASK-003` | `TASK-001` | `SEQUENCE` | 字下げ |')})
        self.refused(si.Unknown, 'indented table row', **{si.RULES: RULES.replace('| `OPS` | `160` |', '  | `OPS` | `160` |')})
        r = si.run(self.root(**{si.REGISTRY: registry(extra_sections='\n## 目標の記録\n\n| 目標 | 状態 |\n| --- | --- |\n  | 字下げ | 未達 |\n')}))
        self.assertEqual([x.get('indented') for x in r['consumption']['outOfScopeRows']], [True])

    def test_empty_version_folder_is_kept_and_flagged(self):
        root = self.root()
        (root / si.MILESTONES / '0.4.0').mkdir()
        r = si.run(root)
        self.assertEqual(r['consumption']['versions'], 4)
        self.assertIn(si.MILESTONES + '/0.4.0/', r['manifest']['listing'])
        self.assertEqual(r['deviations'], [{'version': '0.3.0', 'case': 'missing gate', 'design': 'END-0.3.0 and START-0.4.0 unconnected'}])
        self.assertFalse(r['equal'])
        self.assertTrue(any('one connected sequence' in e for e in r['readerRefused']), 'the reader refuses; the empty version is not dropped')
        self.assertIn('0.4.0', r['ranges']['currentVersions'])

    def test_empty_folder_added_while_capturing(self):
        root = self.root()
        with self.assertRaises(si.Drift):
            si.run(root, after_copy=lambda dest: (root / si.MILESTONES / '0.4.0').mkdir())

    def test_version_folders_of_the_copy_are_verified(self):
        with self.assertRaises(si.Tampered):
            si.run(self.root(), tamper=lambda dest: (dest / si.MILESTONES / '0.9.0').mkdir())
        root = self.root()
        (root / si.MILESTONES / '0.4.0').mkdir()
        with self.assertRaises(si.Tampered):
            si.run(root, tamper=lambda dest: (dest / si.MILESTONES / '0.4.0').rmdir())


class Drift(Shadow):
    def test_input_changed_while_capturing(self):
        root = self.root()
        with self.assertRaises(si.Drift):
            si.run(root, after_copy=lambda dest: (root / si.REGISTRY).write_text(registry() + '\n追記\n', encoding='utf-8'))
        root = self.root()
        with self.assertRaises(si.Drift):
            si.run(root, after_copy=lambda dest: (root / si.MILESTONES / '0.3.0' / '10_C1.md').write_text(card('MS-C1', 'C', '- [ ] DONE', 'このファイル'), encoding='utf-8'))

    def test_tampered_copy(self):
        with self.assertRaises(si.Tampered):
            si.run(self.root(), tamper=lambda dest: (dest / si.REGISTRY).write_text(registry().replace('担当B', '改ざん'), encoding='utf-8'))
        with self.assertRaises(si.Tampered):
            si.run(self.root(), tamper=lambda dest: (dest / si.MILESTONES / '0.3.0' / 'extra.md').write_text('x', encoding='utf-8'))


class Deviations(Shadow):
    def test_known_design_deviation_is_reported_apart(self):
        r = si.run(self.root(**{si.MILESTONES + '/0.2.0/GATE-0.3.0.md': None, si.MILESTONES + '/0.2.0/GATE-9.9.9.md': gate('GATE-9.9.9', '9.9.9 リリース')}))
        self.assertEqual(r['deviations'], [{'version': '0.2.0', 'case': 'gate ID is not the next version', 'design': 'GATE-9.9.9 -> START-0.3.0'}])
        self.assertFalse(r['equal'])
        self.assertTrue(any('destination folder missing' in e for e in r['readerRefused']))


class GitBasis(Shadow):
    def test_head_and_dirty_files_are_recorded(self):
        root = self.root()
        git = ['git', '-c', 'user.name=t', '-c', 'user.email=t@example.invalid', '-c', 'commit.gpgsign=false']
        subprocess.run(['git', 'init', '-q'], cwd=root, check=True)
        subprocess.run(git + ['add', '-A'], cwd=root, check=True)
        subprocess.run(git + ['commit', '-q', '-m', 'fixture'], cwd=root, check=True)
        (root / si.REGISTRY).write_text(registry().replace('担当C', '担当C2'), encoding='utf-8')
        r = si.run(root)
        self.assertTrue(r['manifest']['git']['available'])
        self.assertEqual(len(r['manifest']['git']['head']), 40)
        dirty = [f['path'] for f in r['manifest']['files'] if f['dirty']]
        self.assertEqual(dirty, [si.REGISTRY])
        self.assertTrue(r['equal'], 'the captured (dirty) bytes are what is compared')
        self.assertEqual(r['manifest']['files'][0]['sha256'], si.sha256((root / si.REGISTRY).read_bytes()))


if __name__ == '__main__':
    sys.exit(0 if unittest.main(exit=False, verbosity=2 if '-v' in sys.argv else 1).result.wasSuccessful() else 1)
