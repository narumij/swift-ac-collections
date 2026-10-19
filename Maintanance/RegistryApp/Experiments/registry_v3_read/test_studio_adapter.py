#!/usr/bin/env python3
"""OPS-165 tests: V3 export -> real Studio functions (studio_harness.cjs, function harness, not a browser) -> saved JSON
written and read back -> three-way rows against a fresh export -> apply to the V3 experiment DB.
Each test owns a TemporaryDirectory and closes its connections. Expected values are written by hand.

Run: python3 -B Maintanance/RegistryApp/Experiments/registry_v3_read/test_studio_adapter.py -v
"""
import copy
import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
import registry_v3_recovery as rc  # noqa: E402
import registry_v3_write as w3  # noqa: E402
import studio_adapter as sa  # noqa: E402

BASE = json.loads((HERE / 'fixtures' / 'base.json').read_text(encoding='utf-8'))
ACTOR, EVIDENCE = '姫（試験）', ['TASK_REGISTRY_V3_STUDIO_ADAPTER.md#接続契約の受入と実装区切り（2026-10-19）']


class Studio(unittest.TestCase):
    def setUp(self):
        tmp = tempfile.TemporaryDirectory()
        self.addCleanup(tmp.cleanup)
        self.dir = Path(tmp.name)
        w3.create(str(self.dir / 'db.sqlite3'), copy.deepcopy(BASE))
        self.conn = self.open(self.dir / 'db.sqlite3')
        self.n = 0

    def open(self, path):
        conn = w3.open_db(str(path))
        self.addCleanup(conn.close)
        return conn

    def file(self, name, data):
        p = self.dir / name
        p.write_text(json.dumps(data, ensure_ascii=False), encoding='utf-8')
        return p

    def harness(self, *args):
        out = subprocess.run(['node', str(HERE / 'studio_harness.cjs'), *map(str, args)], capture_output=True, text=True, timeout=60)
        self.assertEqual(out.returncode, 0, out.stderr)
        return json.loads(out.stdout)

    def edit(self, actions, conn=None):
        """Export now, edit in the harness, and read the saved JSON back from its file."""
        self.n += 1
        exported = self.file(f'export-{self.n}.json', sa.export_doc(conn or self.conn))
        result = self.harness('edit', exported, self.file(f'actions-{self.n}.json', actions), self.dir / f'save-{self.n}.json')
        return json.loads((self.dir / f'save-{self.n}.json').read_text(encoding='utf-8')), result

    def latest_rows(self, save):
        saved = self.file(f'resume-save-{self.n}.json', save)
        return self.harness('resume', saved, self.file(f'latest-{self.n}.json', sa.export_doc(self.conn)))

    def db_change(self, op, tid, field, base, new):
        w3.apply(self.conn, op, {'kind': 'update_task', 'id': tid, 'base': {field: base}, 'changes': {field: new}, 'generation': w3.generation(self.conn),
                                 'actor': 'DB側の別の編集', 'evidence': []})

    def task(self, tid):
        return dict(zip(('state', 'owner'), self.conn.execute('SELECT state, owner FROM tasks WHERE id = ?', (tid,)).fetchone()))

    def nothing_written(self, before):
        self.assertEqual(w3.revision(self.conn), before[0])
        self.assertEqual(self.conn.execute('SELECT COUNT(*) FROM operations').fetchone()[0], before[1])

    def counts(self):
        return w3.revision(self.conn), self.conn.execute('SELECT COUNT(*) FROM operations').fetchone()[0]


class Export(Studio):
    def test_export_is_explicit_about_its_base_and_gaps(self):
        d = sa.export_doc(self.conn)
        self.assertNotIn('sha256', d['source'], 'the old field is not filled with a new meaning')
        self.assertEqual((d['source']['kind'], d['source']['generation'], d['source']['revision']), ('v3-export', w3.generation(self.conn), 0))
        self.assertEqual(len(d['source']['payloadHash']), 64)
        self.assertIn('task.raw', d['v3']['absent'])
        self.assertEqual(d['milestoneHead'], '0.2.0')
        cards = {m['id']: m for m in d['milestones']}
        self.assertEqual((cards['MS-A2']['state'], cards['MS-A2']['recordedDone']), ('DONE', False), 'display state derived from the focus, the box kept apart')
        self.assertEqual((cards['MS-B1']['state'], cards['START-0.2.0']['state'], cards['END-0.2.0']['state']), ('ACTIVE', 'DONE', 'ACTIVE'))

    def test_unpatched_check_refuses_and_patched_banner_is_honest(self):
        exported = self.file('e.json', sa.export_doc(self.conn))
        out = subprocess.run(['node', '-e', '''
const fs=require('fs'),vm=require('vm');const html=fs.readFileSync(process.argv[1],'utf8');
const a=html.indexOf('\\nfunction check(');const m=/\\)\\s*\\{/g;m.lastIndex=a;let i=html.indexOf('{',m.exec(html).index),d=0;for(;i<html.length;i++){if(html[i]==='{')d++;else if(html[i]==='}'&&--d===0)break;}
const c={};vm.createContext(c);vm.runInContext(html.slice(a+1,i+1)+';function proposalNodes(){return [];}',c);
try{c.check(JSON.parse(fs.readFileSync(process.argv[2],'utf8')));console.log('accepted');}catch(e){console.log('refused: '+e.message);}''',
                              str(HERE.parent.parent / 'index.template.html'), str(exported)], capture_output=True, text=True, timeout=60)
        self.assertTrue(out.stdout.startswith('refused'), 'the production check() does not accept a V3 export (P1 is needed)')
        save, result = self.edit([])
        self.assertEqual(len(result['patches']), 3)
        banner = self.latest_rows(save)['banner']
        self.assertIn('世代 ' + w3.generation(self.conn), banner)
        self.assertIn('改訂 0', banner)
        for word in ('コミット済み版', '未コミット差分', 'HEAD', 'SHA-256 '):
            self.assertNotIn(word, banner)

    def test_retired_tasks_and_hidden_edges_are_listed(self):
        w3.apply(self.conn, 'r', {'kind': 'retire_task', 'id': 'TASK-003', 'reason': '試験', 'generation': w3.generation(self.conn), 'actor': ACTOR, 'evidence': []})
        d = sa.export_doc(self.conn)
        self.assertNotIn('TASK-003', [t['id'] for t in d['tasks']])
        self.assertEqual(d['v3']['retired'], ['TASK-003'])
        self.assertEqual(sorted((e['graph'], e['prerequisite'], e['successor']) for e in d['v3']['hiddenEdges']),
                         [('milestone', 'START-0.2.0', 'TASK-003'), ('milestone', 'TASK-003', 'END-0.2.0'), ('progress', 'TASK-002', 'TASK-003')])
        self.edit([])  # the real check() (patched P1) accepts it


class RoundTrip(Studio):
    def test_owner_and_state_in_one_atomic_operation(self):
        save, result = self.edit([{'select': 'TASK-003'}, {'set': {'owner': '担当X', 'state': 'DONE'}}, {'apply': True}])
        self.assertEqual(sorted((c['field'], c['new']) for c in result['delta']), [('owner', '担当X'), ('state', 'DONE')])
        op, applied = sa.apply_save(self.conn, save, ACTOR, EVIDENCE)
        self.assertEqual((applied['applied'], applied['revision']), (['owner', 'state'], 1))
        self.assertEqual(self.task('TASK-003'), {'state': 'DONE', 'owner': '担当X'})
        rec = w3.operation(self.conn, op)
        self.assertEqual((rec['before'], rec['after']), ({'id': 'TASK-003', 'owner': '担当C', 'state': 'ACTIVE'}, {'id': 'TASK-003', 'owner': '担当X', 'state': 'DONE'}))
        self.assertEqual(sa.apply_save(self.conn, save, ACTOR, EVIDENCE), (op, applied), 'the same save replays')
        self.assertEqual(w3.revision(self.conn), 1)
        rows = self.latest_rows(save)
        self.assertTrue(rows['reflected'], 'after applying, the latest export already has the edit')


class ThreeWay(Studio):
    def test_same_value(self):
        save, _ = self.edit([{'select': 'TASK-003'}, {'set': {'owner': '担当X'}}, {'apply': True}])
        self.db_change('db-1', 'TASK-003', 'owner', '担当C', '担当X')
        rows = self.latest_rows(save)['rows']
        self.assertEqual([(r['label'], r['conflict']) for r in rows], [('タスク TASK-003 変更', False)])
        _, applied = sa.apply_save(self.conn, save, ACTOR, EVIDENCE)
        self.assertEqual((applied['applied'], applied['alreadyReflected']), ([], ['owner']))

    def test_another_field_changed_meanwhile(self):
        save, _ = self.edit([{'select': 'TASK-003'}, {'set': {'owner': '担当X'}}, {'apply': True}])
        self.db_change('db-1', 'TASK-003', 'state', 'ACTIVE', 'DONE')
        rows = self.latest_rows(save)['rows']
        self.assertEqual([(r['label'], r['conflict'], [c['field'] for c in r['changes']]) for r in rows], [('タスク TASK-003 変更', False, ['state'])])
        sa.apply_save(self.conn, save, ACTOR, EVIDENCE)
        self.assertEqual(self.task('TASK-003'), {'state': 'DONE', 'owner': '担当X'}, 'both independent changes stay')

    def test_same_field_conflict(self):
        save, _ = self.edit([{'select': 'TASK-003'}, {'set': {'owner': '担当X'}}, {'apply': True}])
        self.db_change('db-1', 'TASK-003', 'owner', '担当C', '担当Y')
        rows = self.latest_rows(save)['rows']
        self.assertEqual([(r['label'], r['conflict']) for r in rows], [('タスク TASK-003 変更', True)])
        with self.assertRaises(w3.Refused) as caught:
            sa.apply_save(self.conn, save, ACTOR, EVIDENCE)
        self.assertIn('conflict on TASK-003: owner', str(caught.exception))
        self.assertEqual(self.task('TASK-003')['owner'], '担当Y')


class FailClosed(Studio):
    """Acceptance corrections (2026-10-19): unsupported edits must not pass because a baseline field is missing, and
    duplicates must not hide changes. Every rejection leaves data, revision and operations unchanged."""

    def unchanged(self, save, words):
        before = (self.counts(), self.conn.execute('SELECT * FROM tasks ORDER BY id').fetchall(), self.conn.execute('SELECT * FROM graph_edges ORDER BY 1, 2, 3').fetchall())
        with self.assertRaises(sa.SaveRejected) as caught:
            sa.apply_save(self.conn, save, ACTOR, EVIDENCE)
        self.assertIn(words, str(caught.exception))
        self.assertEqual((self.counts(), self.conn.execute('SELECT * FROM tasks ORDER BY id').fetchall(), self.conn.execute('SELECT * FROM graph_edges ORDER BY 1, 2, 3').fetchall()), before)

    def raw(self, change):
        d = sa.export_doc(self.conn)
        d['tasks'][2]['owner'] = '担当X'  # one supported change, plus the change under test
        change(d)
        return d

    def test_raw_export_plan_and_focus_edits(self):
        self.unchanged(self.raw(lambda d: d['milestones'][1].update(item='計画の名前')), 'milestones (plan)')
        self.unchanged(self.raw(lambda d: d.update(milestoneHead='0.3.0')), 'focus (milestoneHead)')

    def test_raw_export_missing_baseline_fields(self):
        for field in ('milestones', 'milestoneHead', 'tasks', 'edges', 'milestoneRelations'):
            self.unchanged(self.raw(lambda d: d['baseline'].pop(field)), 'malformed V3 base: baseline lacks ' + field)

    def test_duplicates_are_rejected_not_collapsed(self):
        self.unchanged(self.raw(lambda d: d['tasks'].append(dict(d['tasks'][0]))), 'duplicate in tasks: TASK-001')
        self.unchanged(self.raw(lambda d: d['edges'].append(dict(d['edges'][0]))), 'duplicate in edges: TASK-002 -> TASK-003')
        self.unchanged(self.raw(lambda d: d['baseline']['tasks'].append(dict(d['baseline']['tasks'][0]))), 'duplicate in baseline.tasks: TASK-001')
        self.unchanged(self.raw(lambda d: d['milestones'].append(dict(d['milestones'][1]))), 'duplicate in milestones: MS-A1')

    def test_malformed_v3_base(self):
        self.unchanged(self.raw(lambda d: d['v3'].update(generation='gen-other')), 'malformed V3 base: source and v3 disagree')
        self.unchanged(self.raw(lambda d: d['source'].update(revision=1)), 'malformed V3 base: source and v3 disagree')
        self.unchanged(self.raw(lambda d: (d['source'].update(revision='0'), d['v3'].update(revision='0'))), 'malformed V3 base: revision')
        self.unchanged(self.raw(lambda d: (d['source'].update(revision=9), d['v3'].update(revision=9))), 'malformed V3 base: revision 9 is newer than the DB (0)')
        self.unchanged(self.raw(lambda d: d.update(somethingNew=[1])), 'unknown field: somethingNew')
        self.unchanged(self.raw(lambda d: d['source'].update(sha256='0' * 64)), 'old save')

    def test_roundtrip_with_a_plan_edit_in_the_real_editor(self):
        save, result = self.edit([{'select': 'MS-A1'}, {'set': {'planItem': '計画の名前'}}, {'press': '名前・条件を適用'},
                                  {'select': 'TASK-003'}, {'set': {'owner': '担当X'}}, {'apply': True}])
        self.assertIn('milestones', [c['field'] for c in result['delta']])
        self.unchanged(save, 'milestones (plan)')

    def test_roundtrip_with_a_focus_edit(self):
        save, _ = self.edit([{'select': 'TASK-003'}, {'set': {'owner': '担当X'}}, {'apply': True}])
        save['milestoneHead'] = '0.3.0'
        self.unchanged(save, 'focus (milestoneHead)')
        save['milestoneHead'] = '0.2.0'
        sa.apply_save(self.conn, save, ACTOR, EVIDENCE)  # the same save without the focus change goes through
        self.assertEqual(self.task('TASK-003')['owner'], '担当X')


class Rejections(Studio):
    def test_generation_changed_by_a_restore(self):
        save, _ = self.edit([{'select': 'TASK-003'}, {'set': {'owner': '担当X'}}, {'apply': True}])
        rc.backup(self.conn, self.dir / 'b.sqlite3')
        rc.restore(self.dir / 'b.sqlite3', self.dir / 'restored.sqlite3', ACTOR, EVIDENCE)
        new = self.open(self.dir / 'restored.sqlite3')
        rc.enable_writes(new, ACTOR, EVIDENCE, {'TASK': 5})
        with self.assertRaises(sa.SaveRejected) as caught:
            sa.apply_save(new, save, ACTOR, EVIDENCE)
        self.assertIn('generation changed', str(caught.exception))
        self.assertEqual(new.execute("SELECT owner FROM tasks WHERE id = 'TASK-003'").fetchone()[0], '担当C')
        self.assertEqual(new.execute('SELECT COUNT(*) FROM operations').fetchone()[0], 0)

    def test_task_retired_after_export(self):
        save, _ = self.edit([{'select': 'TASK-003'}, {'set': {'owner': '担当X'}}, {'apply': True}])
        w3.apply(self.conn, 'r', {'kind': 'retire_task', 'id': 'TASK-003', 'reason': '試験', 'generation': w3.generation(self.conn), 'actor': ACTOR, 'evidence': []})
        with self.assertRaises(w3.Refused) as caught:
            sa.apply_save(self.conn, save, ACTOR, EVIDENCE)
        self.assertIn('retired', str(caught.exception))
        self.assertEqual(self.task('TASK-003')['owner'], '担当C')

    def test_mixed_unsupported_changes_reject_the_whole_save(self):
        before = self.counts()
        save, result = self.edit([{'select': 'TASK-003'}, {'set': {'owner': '担当X'}}, {'apply': True}, {'addPrerequisite': 'TASK-005'}])
        self.assertIn('edges', [c['field'] for c in result['delta']])
        with self.assertRaises(sa.SaveRejected) as caught:
            sa.apply_save(self.conn, save, ACTOR, EVIDENCE)
        self.assertIn('unsupported changes, nothing applied: edges', str(caught.exception))
        self.assertEqual(self.task('TASK-003')['owner'], '担当C', 'no partial success')
        self.nothing_written(before)

    def test_more_than_one_task(self):
        before = self.counts()
        save, _ = self.edit([{'select': 'TASK-003'}, {'set': {'owner': '担当X'}}, {'apply': True}, {'select': 'TASK-004'}, {'set': {'owner': '担当Z'}}, {'apply': True}])
        with self.assertRaises(sa.SaveRejected) as caught:
            sa.apply_save(self.conn, save, ACTOR, EVIDENCE)
        self.assertIn('exactly one task, it changes 2: TASK-003, TASK-004', str(caught.exception))
        self.nothing_written(before)

    def test_no_change_and_other_fields(self):
        save, _ = self.edit([])
        with self.assertRaises(sa.SaveRejected):
            sa.apply_save(self.conn, save, ACTOR, EVIDENCE)
        changed = copy.deepcopy(save)
        changed['tasks'][0]['item'] = '項目を書き換えた'
        with self.assertRaises(sa.SaveRejected) as caught:
            sa.apply_save(self.conn, changed, ACTOR, EVIDENCE)
        self.assertIn(': item', str(caught.exception))
        changed = copy.deepcopy(save)
        changed['proposals'] = [{'id': 'draft-1', 'title': '案', 'memo': ''}]
        with self.assertRaises(sa.SaveRejected) as caught:
            sa.apply_save(self.conn, changed, ACTOR, EVIDENCE)
        self.assertIn('proposals', str(caught.exception))
        changed = copy.deepcopy(save)
        changed['milestones'][1]['item'] = '計画の名前'
        with self.assertRaises(sa.SaveRejected) as caught:
            sa.apply_save(self.conn, changed, ACTOR, EVIDENCE)
        self.assertIn('milestones (plan)', str(caught.exception))

    def test_old_save_is_rejected(self):
        save, _ = self.edit([{'select': 'TASK-003'}, {'set': {'owner': '担当X'}}, {'apply': True}])
        old = copy.deepcopy(save)
        old['source'] = {'path': 'Maintanance/ProgressV2/TASK_REGISTRY_V2.md', 'sha256': '0' * 64, 'head': 'abc', 'dirty': False}
        del old['v3']
        before = self.counts()
        with self.assertRaises(sa.SaveRejected) as caught:
            sa.apply_save(self.conn, old, ACTOR, EVIDENCE)
        self.assertIn('old save', str(caught.exception))
        self.nothing_written(before)


if __name__ == '__main__':
    sys.exit(0 if unittest.main(exit=False, verbosity=2 if '-v' in sys.argv else 1).result.wasSuccessful() else 1)
