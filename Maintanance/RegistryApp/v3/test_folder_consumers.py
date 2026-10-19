#!/usr/bin/env python3
"""OPS-167 K9 boundary tests: what the current folder consumer (sync.build, which also gates document/pending refresh
through serve.py's startup sync and POST /sync) sees after DB-only changes, once the Registry/Rules views were
regenerated in place. registry_v3_views does NOT regenerate the Milestones folders or HEAD.md (the K8 limitation), so
these tests pin that boundary instead of claiming the old readers stay correct. Fixture trees in TemporaryDirectory.

Run: python3 -B Maintanance/RegistryApp/v3/test_folder_consumers.py -v
"""
import hashlib
import sys
import tempfile
import unittest
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
import registry_v3_read as r3  # noqa: E402
import registry_v3_views as rv  # noqa: E402
import registry_v3_write as w3  # noqa: E402
import shadow_import as si  # noqa: E402
import test_shadow_import as tsi  # noqa: E402

ACTOR = '姫（K9境界試験）'


def card(cid, name):
    return f'# カード情報\n\n## ID\n\n`{cid}`\n\n## 名前\n\n{name}\n\n## 状態\n\n- [ ] DONE\n\n# 正本\n\nこのファイル\n\n# 記録\n'


class Consumers(unittest.TestCase):
    def setUp(self):
        tmp = tempfile.TemporaryDirectory()
        self.addCleanup(tmp.cleanup)
        d = Path(tmp.name).resolve()
        self.root = tsi.tree(d / 'root')
        copy = d / 'copy'
        copy.mkdir()
        manifest = si.snapshot(self.root, copy)
        fixture, _ = si.parse(copy, manifest, si.load_sync().vkey)
        w3.create(str(d / 'db.sqlite3'), fixture)
        self.conn = w3.open_db(str(d / 'db.sqlite3'))
        self.addCleanup(self.conn.close)

    def plan(self, **req):
        w3.apply(self.conn, 'p', {'kind': 'apply_plan', 'generation': w3.generation(self.conn), 'actor': ACTOR, 'evidence': [], **req})

    def consumer(self):
        """(differences between sync.build and the DB, the reader's HEAD) after regenerating the views; or refusal."""
        rv.replace_in_place(self.root, self.conn)
        reader, errors = si.reader_contract(si.load_sync(), self.root)
        if reader is None:
            return 'refused', errors
        mine = si.db_contract(r3.read(self.conn, 'all'))
        return sorted(k for k in set(reader[0]) | set(mine) if reader[0].get(k) != mine.get(k)), reader[2]

    def new_card(self, rel):
        (self.root / rel).parent.mkdir(parents=True, exist_ok=True)
        (self.root / rel).write_text(card('MS-NEW', '新カード'), encoding='utf-8')
        digest = hashlib.sha256((self.root / rel).read_bytes()).hexdigest()
        self.plan(cardsBase={'0.2.0': ['MS-B1']}, cards={'0.2.0': ['MS-B1', 'MS-NEW']}, draftMap={'draft-ms-1': 'MS-NEW'},
                  newCards={'MS-NEW': {'name': '新カード', 'detail': rel, 'documentEvidence': {'path': rel, 'sha256': digest}}})

    def new_version(self):
        versions = [r[0] for r in self.conn.execute('SELECT name FROM versions ORDER BY position')]
        self.plan(cardsBase={}, cards={}, versionsBase=versions, newVersions=[{'name': '0.4.0', 'position': len(versions)}])

    def test_baseline_is_equal(self):
        self.assertEqual(self.consumer(), ([], '0.2.0'))

    def test_reorder_is_stale_for_folder_readers(self):
        self.plan(cardsBase={'0.1.0': ['MS-A1', 'MS-A2']}, cards={'0.1.0': ['MS-A2', 'MS-A1']})
        self.assertEqual(self.consumer(), (['cards', 'skeleton'], '0.2.0'), 'the reader keeps the file-name order')

    def test_new_card_document_in_its_version_folder_is_seen(self):
        self.new_card('Maintanance/Milestones/0.2.0/20_NEW.md')  # appended last, and its file name sorts last
        self.assertEqual(self.consumer(), ([], '0.2.0'))

    def test_new_card_document_elsewhere_is_invisible(self):
        self.new_card('Maintanance/Current/NEW正本.md')
        self.assertEqual(self.consumer(), (['cards', 'milestones', 'skeleton'], '0.2.0'))

    def test_new_version_without_a_folder_is_invisible(self):
        self.new_version()
        self.assertEqual(self.consumer(), (['cards', 'skeleton', 'versions'], '0.2.0'))

    def test_new_version_with_a_folder_stops_the_reader(self):
        """B4: the unconnected folder makes sync.build refuse; serve.py's startup sync (check=True) and POST /sync fail."""
        self.new_version()
        (self.root / si.MILESTONES / '0.4.0').mkdir()
        (self.root / si.MILESTONES / '0.4.0' / '10_D.md').write_text(card('MS-D', 'D'), encoding='utf-8')
        self.assertEqual(self.consumer(), ('refused', ['Release path must be one connected sequence without cycles']))

    def test_focus_is_read_from_head_md(self):
        """There is no write operation for focus yet; a direct change in this temporary DB shows that HEAD.md, which the
        views do not regenerate, stays the reader's position."""
        self.conn.execute("UPDATE focus SET version = '0.3.0'")
        self.assertEqual(self.consumer(), ([], '0.2.0'))
        self.assertEqual(self.conn.execute('SELECT version FROM focus').fetchone()[0], '0.3.0')


if __name__ == '__main__':
    sys.exit(0 if unittest.main(exit=False, verbosity=2 if '-v' in sys.argv else 1).result.wasSuccessful() else 1)
