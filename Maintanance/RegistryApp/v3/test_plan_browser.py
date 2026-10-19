#!/usr/bin/env python3
"""OPS-173 tests: existing-card plan edits (OPS-172) through the isolated server and headless WebKit: real editor edits,
the page's own save, a fresh-context resume, an explicit /v3/apply-groups with a confirmation, and the latest export.
Saving never writes the DB. Reuses the OPS-166 server, driver, origin interception and cleanup.

Run: python3 -B Maintanance/RegistryApp/v3/test_plan_browser.py -v
"""
import json
import sys
import unittest
import urllib.error
import urllib.request
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
import registry_v3_write as w3  # noqa: E402
import v3_studio_server as vs  # noqa: E402
from test_browser_roundtrip import ACTOR, EVIDENCE, Browser  # noqa: E402

PLAN = 'plan:milestones'
EV = ['計画の確認（headless試験）']


class PlanBrowser(Browser):
    def post(self, path, body):
        req = urllib.request.Request(self.server.origin + path, data=json.dumps(body, ensure_ascii=False).encode('utf-8'), headers={'Content-Type': 'application/json'}, method='POST')
        try:
            with urllib.request.urlopen(req, timeout=30) as r:
                return r.status, json.loads(r.read())
        except urllib.error.HTTPError as e:
            with e:
                return e.code, json.loads(e.read())

    def latest_export(self):
        with urllib.request.urlopen(self.server.origin + '/v3/latest', timeout=30) as r:
            return json.loads(r.read())

    def plan(self, actions):
        before = self.db_state()
        out = self.browser('plan', actions=actions)
        self.assertIn('サーバーに保存しました', out['after']['status'])
        self.assertEqual(self.db_state(), before, 'the save alone writes nothing to the DB')
        return out

    def db_state(self):
        c = self.conn
        return (c.execute('SELECT * FROM version_members ORDER BY 1, 3').fetchall(), c.execute("SELECT id, name FROM nodes WHERE kind = 'card' ORDER BY id").fetchall(),
                c.execute('SELECT * FROM graph_edges ORDER BY 1,2,3').fetchall(), w3.revision(c), c.execute('SELECT COUNT(*) FROM operations').fetchone()[0])

    def apply_plan(self, save_id, cards, renames):
        return self.post('/v3/apply-groups', {'saveId': save_id, 'selected': [PLAN], 'actor': ACTOR, 'evidence': EVIDENCE,
                                              'resolutions': {'plan': {'cards': cards, 'renames': renames, 'evidence': EV}}})

    def order(self):
        return [r[0] for r in self.conn.execute("SELECT node FROM version_members WHERE version = '0.1.0' ORDER BY position")]


class RoundTrip(PlanBrowser):
    def test_reorder_save_resume_apply_replay(self):
        self.plan([{'select': 'MS-A1'}, {'press': '後へ'}])
        save = self.server.latest()['save']
        sid = save['studioSave']['saveId']
        skeleton = [(r['prerequisite'], r['successor']) for r in save['milestoneRelations'] if r['source']['path'] == 'v3-db:skeleton']
        self.assertIn(('START-0.1.0', 'MS-A2'), skeleton)
        self.assertNotIn(('START-0.1.0', 'MS-A1'), skeleton, 'P4 in the served page: no stale derived line')
        self.assertEqual(len(skeleton), len(set(skeleton)), 'no duplicate derived lines')
        self.assertFalse([r for r in save['milestoneRelations'] if 'README' in (r['source'].get('path') or '')])
        reopened = self.browser('reopen', task='MS-A1')
        self.assertIn('を再開中', reopened['after']['banner'], 'a fresh context resumes the saved plan')
        status, body = self.post('/v3/apply-groups', {'saveId': sid, 'selected': [PLAN], 'actor': ACTOR, 'evidence': EVIDENCE})
        self.assertEqual((status, body['pending']), (200, [{'groupId': PLAN, 'needs': ['plan-confirmation']}]), 'nothing without a confirmation')
        status, body = self.apply_plan(sid, {'0.1.0': ['MS-A2', 'MS-A1']}, {})
        self.assertEqual((status, [e['groupId'] for e in body['applied']], body['complete']), (200, [PLAN], True))
        self.assertEqual(self.order(), ['MS-A2', 'MS-A1'])
        latest = self.latest_export()
        self.assertEqual([m['id'] for m in latest['milestones'] if m['gate'].startswith('Maintanance/Milestones/0.1.0/') and 'recordedDone' in m], ['MS-A2', 'MS-A1'])
        self.assertIn({'prerequisite': 'TASK-002', 'successor': 'MS-A2'}, [{'prerequisite': r['prerequisite'], 'successor': r['successor']} for r in latest['milestoneRelations']
                                                                          if r['source']['path'] == 'v3-db:milestone'], 'the task link stays on its card')
        revision = w3.revision(self.conn)
        status, again = self.apply_plan(sid, {'0.1.0': ['MS-A2', 'MS-A1']}, {})
        self.assertEqual(([e['groupId'] for e in again['replayed']], w3.revision(self.conn)), ([PLAN], revision))

    def test_move_and_rename_in_one_plan(self):
        self.plan([{'select': 'MS-B1'}, {'fill': {'planItem': 'B の中間（改名）'}}, {'press': '名前・条件を適用'}, {'choose': {'planVersion': '0.3.0'}}, {'press': 'この版へ移動'}])
        sid = self.server.latest()['save']['studioSave']['saveId']
        status, body = self.apply_plan(sid, {'0.2.0': [], '0.3.0': ['MS-B1']}, {'MS-B1': 'B の中間（改名）'})
        self.assertEqual((status, [e['groupId'] for e in body['applied']]), (200, [PLAN]))
        self.assertEqual(self.conn.execute("SELECT version FROM version_members WHERE node = 'MS-B1'").fetchone()[0], '0.3.0')
        self.assertEqual(self.conn.execute("SELECT name FROM nodes WHERE id = 'MS-B1'").fetchone()[0], 'B の中間（改名）')
        self.assertEqual(w3.revision(self.conn), 1, 'one operation')
        self.assertIn(('MS-B1', 'TASK-004'), self.conn.execute("SELECT prerequisite, successor FROM graph_edges WHERE graph = 'milestone'").fetchall())


class Conflict(PlanBrowser):
    def test_stale_base_from_a_second_browser_edit(self):
        self.plan([{'select': 'MS-A1'}, {'press': '後へ'}])
        first = self.server.latest()['save']['studioSave']['saveId']
        second_run = self.plan([{'select': 'MS-A2'}, {'fill': {'planItem': '別の名前'}}, {'press': '名前・条件を適用'}])
        self.assertEqual(second_run['resumedFrom'], first, 'the second page resumed the first save and continued its series')
        second = self.server.latest()['save']['studioSave']['saveId']
        self.apply_plan(first, {'0.1.0': ['MS-A2', 'MS-A1']}, {})
        before = self.db_state()
        status, body = self.apply_plan(second, {'0.1.0': ['MS-A2', 'MS-A1']}, {'MS-A2': '別の名前'})
        self.assertEqual((status, [e['groupId'] for e in body['conflict']]), (200, [PLAN]))
        self.assertIn('conflict on version 0.1.0', body['conflict'][0]['error'])
        self.assertEqual(self.db_state()[:3], before[:3], 'the rename is not applied either')
        status, body = self.post('/v3/apply-groups', {'saveId': second, 'selected': [PLAN], 'actor': ACTOR, 'evidence': EVIDENCE,
                                                      'resolutions': {'plan': {'cards': {'0.1.0': ['MS-A1', 'MS-A2']}, 'renames': {}, 'evidence': EV}}})
        self.assertEqual((status, body['kind']), (409, 'SaveRejected'), 'a confirmation that does not match the save is rejected')

    def test_page_has_p4(self):
        self.browser('plan', actions=[{'select': 'MS-A1'}, {'press': '後へ'}])
        self.assertIn(vs.PATCHES[-1][1], self.server.pages[0])


if __name__ == '__main__':
    sys.exit(0 if unittest.main(exit=False, verbosity=2 if '-v' in sys.argv else 1).result.wasSuccessful() else 1)
