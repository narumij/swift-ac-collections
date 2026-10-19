#!/usr/bin/env python3
"""OPS-176 browser tests: new versions and cards through the real plan tools in headless WebKit, the page's own save, a
fresh-context resume, an explicit /v3/apply-groups (first pending, then with temporary prepared documents and explicit
resolutions), the latest export and a replay; and a card-condition acknowledgement. The isolated server is given a
document root under the test's TemporaryDirectory; live documents are never read.

Run: python3 -B Maintanance/RegistryApp/Experiments/registry_v3_read/test_new_plan_browser.py -v
"""
import sys
import unittest
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
import registry_v3_write as w3  # noqa: E402
from test_browser_roundtrip import ACTOR, EVIDENCE  # noqa: E402
from test_new_plan_items import card_doc  # noqa: E402
from test_plan_browser import EV, PLAN, PlanBrowser  # noqa: E402

NEW_DOC = 'Maintanance/Milestones/0.2.5/10_NEW.md'


class NewItems(PlanBrowser):
    DOCUMENT_ROOT = 'docs'

    def prepare(self, rel, cid, name):
        p = self.dir / self.DOCUMENT_ROOT / rel
        p.parent.mkdir(parents=True, exist_ok=True)
        p.write_text(card_doc(cid, name), encoding='utf-8')

    def groups(self, sid, selected, resolutions=None):
        return self.post('/v3/apply-groups', {'saveId': sid, 'selected': selected, 'actor': ACTOR, 'evidence': EVIDENCE, **({'resolutions': resolutions} if resolutions else {})})

    def test_new_version_and_card_save_resume_apply(self):
        self.assertTrue(str(self.server.document_root).startswith(str(self.dir)), 'a temporary document root only')
        self.plan([{'tool': '版を追加', 'toolSet': {'planNewVersion': '0.2.5', 'planAddVersionAfter': '0.2.0'}},
                   {'tool': '中間カードを追加', 'toolSet': {'planAddVersionOf': '0.2.5', 'planAddName': '新版のカード'}}])
        save = self.server.latest()['save']
        sid = save['studioSave']['saveId']
        start = next(m for m in save['milestones'] if m['id'] == 'START-0.2.5')
        self.assertEqual(start['planPosition'], {'after': '0.2.0'}, 'P5 in the served page stores the selected position')
        self.assertIn('draft-ms-1', [m['id'] for m in save['milestones']])
        reopened = self.browser('reopen', task='TASK-003')
        self.assertIn('を再開中', reopened['after']['banner'], 'a fresh context resumes the saved plan')
        before = self.db_state()
        status, body = self.groups(sid, [PLAN])
        self.assertEqual((status, body['pending']), (200, [{'groupId': PLAN, 'needs': ['plan-confirmation', 'document']}]))
        confirm = {'cards': {'0.2.5': ['draft-ms-1']}, 'renames': {}, 'evidence': EV, 'newCards': {'draft-ms-1': {'id': 'MS-NEW', 'document': NEW_DOC}}}
        status, body = self.groups(sid, [PLAN], {'plan': confirm})
        self.assertEqual(body['pending'], [{'groupId': PLAN, 'needs': [f'document: {NEW_DOC} is not prepared (the card stays a proposal)']}])
        self.assertEqual(self.db_state(), before, 'nothing before the document is prepared')
        self.prepare(NEW_DOC, 'MS-NEW', '新版のカード')
        status, body = self.groups(sid, [PLAN], {'plan': confirm})
        self.assertEqual((status, [e['groupId'] for e in body['applied']], body['complete']), (200, [PLAN], True), body)
        self.assertEqual(body['applied'][0]['result']['newCards'], {'draft-ms-1': 'MS-NEW'})
        latest = self.latest_export()
        self.assertEqual(latest['source']['revision'], w3.revision(self.conn), 'the latest export')
        ids = [m['id'] for m in latest['milestones']]
        self.assertTrue({'START-0.2.5', 'END-0.2.5', 'MS-NEW'} <= set(ids))
        self.assertNotIn('draft-ms-1', ids)
        self.assertEqual([r[0] for r in self.conn.execute('SELECT name FROM versions ORDER BY position')], ['0.1.0', '0.2.0', '0.2.5', '0.3.0'])
        revision = w3.revision(self.conn)
        status, again = self.groups(sid, [PLAN], {'plan': confirm})
        self.assertEqual(([e['groupId'] for e in again['replayed']], w3.revision(self.conn)), ([PLAN], revision))

    def test_condition_acknowledgement(self):
        self.plan([{'select': 'MS-A2'}, {'fill': {'planCondition': '到達条件の案'}}, {'press': '名前・条件を適用'}])
        sid = self.server.latest()['save']['studioSave']['saveId']
        gid = 'card-condition:MS-A2'
        rel = 'Maintanance/Milestones/0.1.0/20_A2.md'
        self.prepare(rel, 'MS-A2', 'A の次')
        status, body = self.groups(sid, [gid])
        self.assertEqual(body['pending'], [{'groupId': gid, 'needs': ['document']}], 'the prepared document alone does not satisfy it')
        ack = {'documents': {gid: {'document': rel, 'evidence': ['本文へ反映した（headless試験）']}}}
        status, body = self.groups(sid, [gid], ack)
        self.assertEqual(([e['groupId'] for e in body['applied']], body['complete']), ([gid], True), body)
        status, body = self.groups(sid, [gid], ack)
        self.assertEqual([e['groupId'] for e in body['replayed']], [gid])

    def test_without_a_document_root_it_stays_pending(self):
        self.server.document_root = None  # the constructor default
        self.plan([{'tool': '中間カードを追加', 'toolSet': {'planAddVersionOf': '0.2.0', 'planAddName': 'カード'}}])
        sid = self.server.latest()['save']['studioSave']['saveId']
        self.prepare('d/x.md', 'MS-X', 'カード')
        before = self.db_state()
        status, body = self.groups(sid, [PLAN], {'plan': {'cards': {'0.2.0': ['MS-B1', 'draft-ms-1']}, 'renames': {}, 'evidence': EV,
                                                          'newCards': {'draft-ms-1': {'id': 'MS-X', 'document': 'd/x.md'}}}})
        self.assertEqual(body['pending'][0]['groupId'], PLAN)
        self.assertEqual(self.db_state(), before)


if __name__ == '__main__':
    sys.exit(0 if unittest.main(exit=False, verbosity=2 if '-v' in sys.argv else 1).result.wasSuccessful() else 1)
