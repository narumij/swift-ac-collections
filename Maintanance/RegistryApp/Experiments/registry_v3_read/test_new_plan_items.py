#!/usr/bin/env python3
"""OPS-176 tests: new versions (explicit position) and new cards (prepared canonical document first), draft task ->
draft card through the plan mapping, and durable document-proposal acknowledgements. Saves come from the real Studio
editor and plan tools (studio_harness.cjs with the P5 position select). Documents live in a per-test document root.

Run: python3 -B Maintanance/RegistryApp/Experiments/registry_v3_read/test_new_plan_items.py -v
"""
import copy
import sys
import unittest
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
import registry_v3_read as r3  # noqa: E402
import registry_v3_write as w3  # noqa: E402
import studio_adapter as sa  # noqa: E402
from test_change_groups import Groups  # noqa: E402
from test_studio_adapter import ACTOR, EVIDENCE  # noqa: E402

PLAN = 'plan:milestones'
EV = ['計画の確認 2026-10-19']
DOC = 'Maintanance/Milestones/0.2.0/30_NEW.md'


def card_doc(cid, name):
    return f'# カード情報\n\n## ID\n\n`{cid}`\n\n## 名前\n\n{name}\n\n## 状態\n\n- [ ] DONE\n\n# 正本\n\nこのファイル\n\n# 記録\n'


class New(Groups):
    def setUp(self):
        super().setUp()
        self.docs = self.dir / 'docs'
        self.docs.mkdir()

    def write_doc(self, rel, cid, name):
        p = self.docs / rel
        p.parent.mkdir(parents=True, exist_ok=True)
        p.write_text(card_doc(cid, name), encoding='utf-8')

    def new_card_save(self, save_id='S-1', version='0.2.0', name='新しいカード'):
        return self.stored([{'set': {'planAddVersionOf': version, 'planAddName': name}}, {'pressTool': '中間カードを追加'}], save_id)

    def plan(self, save):
        return next(g for g in sa.plan_groups(self.conn, save) if g['groupId'] == PLAN)

    def confirm(self, save, new_cards=None):
        g = self.plan(save)
        r = {'cards': g['cards'], 'renames': {k: v['name'] for k, v in g['renames'].items()}, 'evidence': EV}
        if new_cards is not None:
            r['newCards'] = new_cards
        return {'plan': r}

    def apply(self, save, selected, resolutions=None, ancestry=None):
        return sa.apply_groups(self.conn, save, selected, ACTOR, EVIDENCE, resolutions, ancestry, document_root=self.docs)

    def state(self):
        c = self.conn
        return (c.execute('SELECT * FROM versions ORDER BY position').fetchall(), c.execute('SELECT * FROM version_members ORDER BY 1, 3').fetchall(),
                c.execute("SELECT id FROM nodes ORDER BY id").fetchall(), w3.revision(c))


class NewCard(New):
    def test_card_waits_for_its_document_then_registers(self):
        save = self.new_card_save()
        g = self.plan(save)
        self.assertEqual((g['newCards'], g['pending']), ({'draft-ms-1': {'name': '新しいカード', 'version': '0.2.0'}}, ['plan-confirmation', 'document']))
        res = self.confirm(save, {'draft-ms-1': {'id': 'MS-NEW', 'document': DOC}})
        before = self.state()
        out = self.apply(save, [PLAN], res)
        self.assertEqual(out['pending'], [{'groupId': PLAN, 'needs': [f'document: {DOC} is not prepared (the card stays a proposal)']}])
        self.assertEqual(self.state(), before, 'no node before its document exists')
        self.write_doc(DOC, 'MS-OTHER', '新しいカード')
        out = self.apply(save, [PLAN], res)
        self.assertIn('declares MS-OTHER', out['refused'][0]['error'])
        self.assertEqual(self.state(), before)
        self.write_doc(DOC, 'MS-NEW', '新しいカード')
        out = self.apply(save, [PLAN], res)
        self.assertEqual((self.ids(out, 'applied'), out['applied'][0]['result']['newCards']), ([PLAN], {'draft-ms-1': 'MS-NEW'}))
        view = r3.read(self.conn, 'all')
        self.assertEqual(view['order']['cards']['0.2.0'], ['MS-B1', 'MS-NEW'])
        self.assertEqual(view['ids']['milestones']['MS-NEW'], {'name': '新しいカード', 'detail': DOC, 'recordedDone': False})
        rec = w3.operation(self.conn, sa.unit_operation_id('S-1', PLAN))
        self.assertEqual(rec['request']['newCards']['MS-NEW']['documentEvidence']['path'], DOC)
        self.assertEqual(self.ids(self.apply(save, [PLAN], res), 'replayed'), [PLAN])

    def test_ids_are_never_reused(self):
        for formal in ('MS-B1', 'TASK-003', 'START-0.2.0'):
            save = self.new_card_save('S-' + formal)
            self.write_doc(DOC, formal, '新しいカード')
            out = self.apply(save, [PLAN], self.confirm(save, {'draft-ms-1': {'id': formal, 'document': DOC}}))
            self.assertEqual(self.ids(out, 'refused'), [PLAN], formal)

    def two_cards(self):
        save = self.stored([{'set': {'planAddVersionOf': '0.2.0', 'planAddName': 'カード一'}}, {'pressTool': '中間カードを追加'},
                            {'set': {'planAddVersionOf': '0.2.0', 'planAddName': 'カード二'}}, {'pressTool': '中間カードを追加'}], 'S-1')
        self.write_doc('d/1.md', 'MS-N1', 'カード一')
        self.write_doc('d/2.md', 'MS-N2', 'カード二')
        return save

    def test_one_formal_id_per_draft(self):
        save = self.two_cards()
        self.write_doc('d/2.md', 'MS-N1', 'カード二')
        before = self.state()
        with self.assertRaises(sa.SaveRejected) as caught:
            self.apply(save, [PLAN], self.confirm(save, {'draft-ms-1': {'id': 'MS-N1', 'document': 'd/1.md'}, 'draft-ms-2': {'id': 'MS-N1', 'document': 'd/2.md'}}))
        self.assertIn('two new cards cannot share a formal ID', str(caught.exception))
        self.assertEqual(self.state(), before)

    def test_writer_draft_map_is_one_to_one(self):
        save = self.two_cards()
        captured = []
        real = w3.apply
        def capture(conn, op, req):
            captured.append(copy.deepcopy(req))
            raise w3.Refused('captured, not applied')
        w3.apply = capture
        try:
            self.apply(save, [PLAN], self.confirm(save, {'draft-ms-1': {'id': 'MS-N1', 'document': 'd/1.md'}, 'draft-ms-2': {'id': 'MS-N2', 'document': 'd/2.md'}}))
        finally:
            w3.apply = real
        good = captured[0]
        self.assertEqual(good['draftMap'], {'draft-ms-1': 'MS-N1', 'draft-ms-2': 'MS-N2'})
        before = self.state()
        bad = []
        two_onto_one = copy.deepcopy(good)  # two drafts onto one card: the card set still matches, the mapping is not one-to-one
        two_onto_one['draftMap'] = {'draft-ms-1': 'MS-N1', 'draft-ms-2': 'MS-N1', 'draft-ms-3': 'MS-N2'}
        bad.append(two_onto_one)
        for key in ('draft-1', 'ms-1', 'draft-ms-0', 7):
            wrong_key = copy.deepcopy(good)
            wrong_key['draftMap'] = {key: 'MS-N1', 'draft-ms-2': 'MS-N2'}
            bad.append(wrong_key)
        missing = copy.deepcopy(good)
        missing['draftMap'] = {'draft-ms-1': 'MS-N1'}
        bad.append(missing)
        for i, req in enumerate(bad):
            req.pop('consumes', None), req.pop('consumerScope', None)  # direct writer calls: no save identity to consume
            if any(not isinstance(k, str) for k in req['draftMap']):
                with self.assertRaises((w3.Refused, TypeError, ValueError)):
                    real(self.conn, f'w-{i}', req)
                continue
            with self.assertRaises(w3.Refused, msg=req['draftMap']) as caught:
                real(self.conn, f'w-{i}', req)
            self.assertIn('one-to-one', str(caught.exception))
        self.assertEqual(self.state()[:3], before[:3])
        self.assertEqual(real(self.conn, 'w-good', good)['newCards'], good['draftMap'])

    def test_stale_base_and_series_duplicate(self):
        first = self.new_card_save('S-1')
        self.write_doc(DOC, 'MS-NEW', '新しいカード')
        res = self.confirm(first, {'draft-ms-1': {'id': 'MS-NEW', 'document': DOC}})
        self.apply(first, [PLAN], res)
        child = copy.deepcopy(first)  # the next save in the same series still carries the draft card
        child['studioSave'] = {'saveId': 'S-2', 'parent': 'S-1'}
        out = self.apply(child, [PLAN], res)
        self.assertEqual(self.ids(out, 'conflict'), [PLAN], 'the base changed (0.2.0 now has MS-NEW): no second registration')
        self.assertEqual(self.conn.execute("SELECT COUNT(*) FROM nodes WHERE id = 'MS-NEW'").fetchone()[0], 1)


class NewVersion(New):
    def version_save(self, save_id='S-1', name='0.2.5', after='0.2.0'):
        return self.stored([{'set': {'planNewVersion': name, 'planAddVersionAfter': after}}, {'pressTool': '版を追加'}], save_id)

    def test_new_version_at_the_selected_position(self):
        save = self.version_save()
        g = self.plan(save)
        self.assertEqual(g['newVersions'], [{'name': '0.2.5', 'after': '0.2.0', 'positionGiven': True}])
        out = self.apply(save, [PLAN], self.confirm(save))
        self.assertEqual(self.ids(out, 'applied'), [PLAN])
        view = r3.read(self.conn, 'all')
        self.assertEqual(view['order']['versions'], ['0.1.0', '0.2.0', '0.2.5', '0.3.0'])
        sk = view['relations']['skeleton']
        self.assertIn(['START-0.2.5', 'END-0.2.5'], sk)
        self.assertIn(['GATE-0.3.0', 'START-0.2.5'], sk, 'the gate of 0.2.0 leads to the next version in the DB order')
        self.assertFalse([e for e in sk if e[0] == 'END-0.2.5'], 'no gate is invented: 0.2.5 is not connected onward')

    def test_position_must_be_selected(self):
        save = self.version_save()
        next(m for m in save['milestones'] if m['id'] == 'START-0.2.5').pop('planPosition')
        before = self.state()
        out = self.apply(save, [PLAN], self.confirm(save))
        self.assertEqual(out['pending'][0]['needs'], ['version-position: a new version needs the position selected in Studio'])
        self.assertEqual(self.state(), before)

    def test_stale_version_order(self):
        first, second = self.version_save('S-1', '0.2.5'), self.version_save('S-2', '0.2.7')
        self.apply(first, [PLAN], self.confirm(first))
        out = self.apply(second, [PLAN], self.confirm(second))
        self.assertEqual(self.ids(out, 'conflict'), [PLAN])
        self.assertIn('version order', out['conflict'][0]['error'])

    def test_card_in_a_new_version(self):
        save = self.stored([{'set': {'planNewVersion': '0.2.5', 'planAddVersionAfter': '0.2.0'}}, {'pressTool': '版を追加'},
                            {'set': {'planAddVersionOf': '0.2.5', 'planAddName': '新版のカード'}}, {'pressTool': '中間カードを追加'}], 'S-1')
        rel = 'Maintanance/Milestones/0.2.5/10_X.md'
        self.write_doc(rel, 'MS-X', '新版のカード')
        out = self.apply(save, [PLAN], self.confirm(save, {'draft-ms-1': {'id': 'MS-X', 'document': rel}}))
        self.assertEqual(self.ids(out, 'applied'), [PLAN])
        self.assertEqual(r3.read(self.conn, 'all')['order']['cards']['0.2.5'], ['MS-X'])


class DraftToDraft(New):
    def linked_save(self):
        return self.stored([{'set': {'planAddVersionOf': '0.3.0', 'planAddName': '提案のための新カード'}}, {'pressTool': '中間カードを追加'},
                            {'proposal': {'title': 'カードへつなぐ提案', 'place': 'ms:draft-ms-1'}}], 'S-1')

    PROPOSAL = {'proposals': {'proposal:draft-1': {'prefix': 'TASK', 'fields': {'state': 'PROPOSED', 'owner': '担当P', 'condition': '条件', 'detail': 'd', 'group': '現行'},
                                                    'constraints': {'link:draft-1->draft-ms-1': 'この到達点の前に完了が必要。'}, 'evidence': ['e']}}}

    def test_card_first_then_the_task_proposal(self):
        save = self.linked_save()
        rel = 'Maintanance/Milestones/0.3.0/10_P.md'
        alone = self.apply(save, ['proposal:draft-1'], self.PROPOSAL, {'independent': True})
        self.assertEqual(alone['pending'], [{'groupId': 'proposal:draft-1', 'needs': ['depends on plan:milestones (new card draft-ms-1 not registered yet)']}])
        self.write_doc(rel, 'MS-P', '提案のための新カード')
        res = dict(self.PROPOSAL, **self.confirm(save, {'draft-ms-1': {'id': 'MS-P', 'document': rel}}))
        out = self.apply(save, [PLAN, 'proposal:draft-1'], res, {'independent': True})
        self.assertEqual((self.ids(out, 'applied'), out['complete']), ([PLAN, 'proposal:draft-1'], True))
        tid = out['applied'][1]['result']['id']
        self.assertEqual(self.conn.execute("SELECT constraint_text FROM graph_edges WHERE graph = 'milestone' AND prerequisite = ? AND successor = 'MS-P'", (tid,)).fetchone()[0],
                         'この到達点の前に完了が必要。')

    def test_plan_success_then_proposal_refusal_is_not_complete(self):
        save = self.linked_save()
        rel = 'Maintanance/Milestones/0.3.0/10_P.md'
        self.write_doc(rel, 'MS-P', '提案のための新カード')
        bad = copy.deepcopy(self.PROPOSAL)
        bad['proposals']['proposal:draft-1']['fields']['condition'] = 3
        res = dict(bad, **self.confirm(save, {'draft-ms-1': {'id': 'MS-P', 'document': rel}}))
        out = self.apply(save, [PLAN, 'proposal:draft-1'], res, {'independent': True})
        self.assertEqual((self.ids(out, 'applied'), self.ids(out, 'refused'), out['complete']), ([PLAN], ['proposal:draft-1'], False))
        later = self.apply(save, ['proposal:draft-1'], dict(self.PROPOSAL, **self.confirm(save, {'draft-ms-1': {'id': 'MS-P', 'document': rel}})), {'independent': True})
        self.assertEqual(self.ids(later, 'changedContent'), ['proposal:draft-1'], 'the refused request stays recorded; a corrected one needs a new save')


class Conditions(New):
    def condition_save(self, text='到達条件の案', save_id='S-1'):
        return self.stored([{'select': 'MS-A2'}, {'set': {'planItem': 'A の次', 'planCondition': text}}, {'press': '名前・条件を適用'}], save_id)

    def test_acknowledgement_is_explicit_and_durable(self):
        save = self.condition_save()
        gid = 'card-condition:MS-A2'
        rel = 'Maintanance/Milestones/0.1.0/20_A2.md'
        self.write_doc(rel, 'MS-A2', 'A の次')
        out = self.apply(save, [gid])
        self.assertEqual(out['pending'], [{'groupId': gid, 'needs': ['document']}], 'an existing document alone does not satisfy the proposal')
        ack = {'documents': {gid: {'document': rel, 'evidence': ['本文へ反映した 2026-10-19']}}}
        out = self.apply(save, [gid], ack)
        self.assertEqual(self.ids(out, 'applied'), [gid])
        rec = w3.operation(self.conn, sa.unit_operation_id('S-1', gid))
        self.assertEqual(rec['request']['textDigest'], sa.hashlib.sha256('到達条件の案'.encode('utf-8')).hexdigest())
        self.assertEqual(self.ids(self.apply(save, [gid], ack), 'replayed'), [gid], 'survives a refresh: same save, same result')
        changed = self.condition_save('別の条件の案')
        changed['studioSave'] = {'saveId': 'S-1', 'parent': None}
        self.assertEqual(self.ids(self.apply(changed, [gid], ack), 'changedContent'), [gid], 'a changed text under the same identity is refused')
        self.assertIsNone(self.conn.execute("SELECT 1 FROM nodes WHERE name = '到達条件の案'").fetchone(), 'the text never becomes DB data')

    def test_missing_document_stays_pending(self):
        save = self.condition_save()
        gid = 'card-condition:MS-A2'
        out = self.apply(save, [gid], {'documents': {gid: {'document': 'Maintanance/Milestones/0.1.0/none.md', 'evidence': ['e']}}})
        self.assertEqual(out['pending'][0]['groupId'], gid)



class Cli(New):
    """apply-groups --document-root: given explicitly, or the groups stay pending (no cwd or repository fallback)."""

    def cli(self, *args, cwd=None):
        import json
        import subprocess
        out = subprocess.run([sys.executable, '-B', str(HERE / 'registry_v3_cli.py'), *map(str, args)], capture_output=True, text=True, timeout=60, cwd=cwd)
        return out.returncode, json.loads(out.stdout)

    def test_document_root_only_when_given(self):
        import json
        save = self.new_card_save()
        self.write_doc(DOC, 'MS-NEW', '新しいカード')
        (self.dir / 'save.json').write_text(json.dumps(save, ensure_ascii=False), encoding='utf-8')
        sel = {'selected': [PLAN], 'actor': ACTOR, 'evidence': EVIDENCE, 'resolutions': self.confirm(save, {'draft-ms-1': {'id': 'MS-NEW', 'document': DOC}})}
        (self.dir / 'sel.json').write_text(json.dumps(sel, ensure_ascii=False), encoding='utf-8')
        common = ('apply-groups', '--db', self.dir / 'db.sqlite3', '--save', self.dir / 'save.json', '--selection', self.dir / 'sel.json')
        before = self.state()
        code, out = self.cli(*common, cwd=self.docs)  # the documents are in the cwd: still not read
        self.assertEqual((code, out['result']['pending'][0]['groupId']), (6, PLAN))
        code, out = self.cli(*common, '--document-root', self.dir / 'nowhere')
        self.assertEqual((code, out['status']), (2, 'malformed'))
        self.assertEqual(self.state(), before)
        code, out = self.cli(*common, '--document-root', self.docs)
        self.assertEqual((code, out['result']['applied'][0]['result']['newCards']), (0, {'draft-ms-1': 'MS-NEW'}))


if __name__ == '__main__':
    sys.exit(0 if unittest.main(exit=False, verbosity=2 if '-v' in sys.argv else 1).result.wasSuccessful() else 1)
