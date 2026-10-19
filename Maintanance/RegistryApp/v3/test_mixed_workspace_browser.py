#!/usr/bin/env python3
"""OPS-177 browser tests: a mixed legacy/V3 saves folder behind the isolated server, in headless WebKit. The page's own
save, a fresh-context resume that takes only the V3 save even when a legacy save is newer, the page-side refusal when
the server hands it a save of another kind (P6), and 更新 (the no-op /sync, then the page's reload) keeping the resume
and the stale-base notice. Folders are TemporaryDirectories; the real Inbox is never used.

Run: python3 -B Maintanance/RegistryApp/v3/test_mixed_workspace_browser.py -v
"""
import hashlib
import sys
import unittest
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
sys.path.insert(0, str(HERE.parent))  # RegistryApp: inbox.py
import inbox as vi  # noqa: E402
import v3_studio_server as vs  # noqa: E402
from test_browser_roundtrip import Browser  # noqa: E402
from test_v3_inbox import legacy_doc  # noqa: E402

LEGACY_NOTE = '旧形式の未照合の編集版が1件あります（この画面では再開しません・削除しません）。'


class Mixed(Browser):
    EXTRA_PATHS = {'POST /sync'}

    def v3_save(self):
        out = self.browser('save', task='TASK-003', owner='担当X')
        self.assertIn('サーバーに保存しました', out['after']['status'])
        return self.saved()

    def newer_legacy(self):
        meta = vi.append_save(legacy_doc(), None, self.server.saves)
        path = self.server.saves / f"registry-edited-{meta['saveId']}.json"
        return meta, path, hashlib.sha256(path.read_bytes()).hexdigest()

    def test_only_the_v3_save_resumes(self):
        sid = self.v3_save()
        meta, path, digest = self.newer_legacy()
        out = self.browser('look')
        self.assertIn(f'編集版 {sid} を再開中', out['after']['banner'], 'the V3 save, though the legacy one is newer')
        self.assertIn(LEGACY_NOTE, out['after']['status'])
        self.assertEqual(hashlib.sha256(path.read_bytes()).hexdigest(), digest, 'the legacy save is not changed')
        self.assertEqual(self.server.latest()['unresolvedLegacy'][0]['saveId'], meta['saveId'])

    def test_page_refuses_another_kind(self):
        self.v3_save()
        meta, path, _ = self.newer_legacy()
        legacy = vi.load_saves(self.server.saves)[-1]['doc']
        self.assertEqual(legacy['studioSave']['saveId'], meta['saveId'])
        self.server.latest = lambda: {'save': legacy, 'heads': 1, 'saves': 1, 'unresolvedLegacy': [], 'invalid': []}  # a server that forgets the filter
        out = self.browser('look')
        self.assertNotIn('再開中', out['after']['banner'])
        self.assertIn('形式の違う編集版（旧形式）は再開しません。', out['after']['status'])
        self.assertIn(vs.PATCHES[-1][1], self.server.pages[0], 'P6 is in the served page')

    def test_refresh_keeps_the_resume_and_the_stale_notice(self):
        sid = self.v3_save()
        self.newer_legacy()
        self.db_change('db-1', 'owner', '担当C', '担当Y')  # the DB moves on after the save
        out = self.browser('refresh')
        self.assertIn('POST /sync', out['requests'])
        self.assertEqual(out['requests'].count('GET /'), 2, 'the page reloaded itself')
        for side in ('before', 'after'):
            self.assertIn(f'編集版 {sid} を再開中', out[side]['banner'], side)
            self.assertIn('DBが更新されています', out[side]['banner'], side)  # P3: the base generation/revision against the served export
            self.assertIn('owner: "担当C" → "担当Y"', out[side]['notice'] or '', side)
            self.assertIn('競合の可能性', out[side]['notice'], side)
        self.assertIn(LEGACY_NOTE, out['after']['status'])
        self.assertEqual(self.owner(), ('ACTIVE', '担当Y'), 'neither the save nor 更新 writes the DB')


    def test_unknown_history_is_told(self):
        sid = self.v3_save()
        self.newer_legacy()
        (self.server.saves / vi.IMPORTS).write_text('{"saveId": \n', encoding='utf-8')  # a broken import history
        out = self.browser('look')
        self.assertIn(f'編集版 {sid} を再開中', out['after']['banner'], 'the valid V3 save still resumes')
        self.assertIn('取り込み記録が読めないため、旧形式の編集版の照合状態は不明です', out['after']['status'])
        self.assertNotIn('未照合の編集版が', out['after']['status'], 'no count is inferred')
        self.assertEqual((self.server.latest()['reconciliation'], self.server.latest()['unresolvedLegacy']), ('unknown', None))


if __name__ == '__main__':
    sys.exit(0 if unittest.main(exit=False, verbosity=2 if '-v' in sys.argv else 1).result.wasSuccessful() else 1)
