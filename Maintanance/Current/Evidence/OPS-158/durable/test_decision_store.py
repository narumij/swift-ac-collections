#!/usr/bin/env python3
"""OPS-158 isolated continuation tests. Every store is a file in a unittest TemporaryDirectory (removed when each test
ends); no live DB, server or repository file is written. The D1-D3 fixture is derived from ../result.json.

Run: python3 -B Maintanance/Current/Evidence/OPS-158/durable/test_decision_store.py -v
"""
import json
import sqlite3
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
import decision_store as ds  # noqa: E402
import fixtures  # noqa: E402

ACTOR = '姫（試験）'
SOURCE = {'letter': 'LTR-TEST', 'note': 'a test locator'}


class Store(unittest.TestCase):
    def setUp(self):
        tmp = tempfile.TemporaryDirectory()
        self.addCleanup(tmp.cleanup)
        self.dir = Path(tmp.name)
        self.path = ds.init(self.dir / 'decisions.sqlite3')
        self.conn = self.open()

    def open(self):
        conn = ds.open_store(self.path)
        self.addCleanup(conn.close)
        return conn

    def load_fixture(self, conn=None):
        for op, req in fixtures.operations():
            ds.apply(conn or self.conn, op, req)

    def events(self):
        return self.conn.execute('SELECT COUNT(*) FROM events').fetchone()[0]

    def propose(self, op, did='D1', base=1, statement='simulation: a revised statement'):
        return ds.apply(self.conn, op, {'kind': 'propose', 'actor': ACTOR, 'id': did, 'base_revision': base, 'statement': statement, 'source': SOURCE})

    def adopt(self, op, did='D1', revision=2, replaces=1, decided_by='user', source=SOURCE):
        req = {'kind': 'record_adoption', 'actor': ACTOR, 'id': did, 'revision': revision, 'replaces': replaces, 'decided_by': decided_by, 'source': source}
        return ds.apply(self.conn, op, req)


class Lifecycle(Store):
    def test_init_is_explicit_and_never_overwrites(self):
        with self.assertRaises(FileExistsError):
            ds.init(self.path)
        missing = self.dir / 'none.sqlite3'
        with self.assertRaises(FileNotFoundError):
            ds.open_store(missing)
        self.assertFalse(missing.exists(), 'an operation never creates a store')
        other = self.dir / 'other.sqlite3'
        sqlite3.connect(other).execute('CREATE TABLE t (x)').connection.close()
        with self.assertRaises(ds.NotADecisionStore):
            ds.open_store(other)

    def test_fixture_matches_the_accepted_sample_and_survives_reopen(self):
        self.load_fixture()
        self.conn.close()
        conn = self.open()
        sample = json.loads(fixtures.RESULT.read_text(encoding='utf-8'))
        for did in ('D1', 'D2', 'D3'):
            d = ds.decision(conn, did)
            self.assertEqual((d['adopted'], d['revisions']['1']['statement']), (1, sample['decisions'][did]['text']))
            self.assertEqual([(rid, r['kind']) for rid, r in d['references'].items()], [(r['id'], r['kind']) for r in sample['queries'][did]])
        self.assertEqual(ds.decision(conn, 'D3')['revisions']['1']['source']['line'], 236, 'the adopted restore wording')


class Contracts(Store):
    def test_replay_and_mismatch(self):
        self.load_fixture()
        first = self.propose('p1')
        count = self.events()
        again = self.propose('p1')
        self.assertEqual((again['revision'], again['replayed'], self.events()), (first['revision'], True, count), 'a replay appends nothing')
        with self.assertRaises(ds.OperationMismatch):
            self.propose('p1', statement='another text')
        self.assertEqual(self.events(), count)

    def test_base_conflict_and_recorded_refusal(self):
        self.load_fixture()
        self.propose('p1')
        count = self.events()
        with self.assertRaises(ds.Refused) as caught:
            self.propose('p2', base=1)  # someone proposed revision 2 meanwhile
        self.assertIn('the latest revision is 2', str(caught.exception))
        self.assertEqual(self.events(), count + 1, 'the refusal is recorded')
        with self.assertRaises(ds.Refused):
            self.propose('p2', base=1)  # the same op replays the same refusal
        self.assertEqual(self.events(), count + 1)
        self.assertEqual(sorted(ds.decision(self.conn, 'D1')['revisions']), ['1', '2'])

    def test_proposal_is_not_adoption_and_old_revisions_stay(self):
        self.load_fixture()
        self.propose('p1')
        d = ds.decision(self.conn, 'D1')
        self.assertEqual((d['adopted'], d['revisions']['2']['adoption']), (1, None), 'proposing changes nothing adopted')
        self.adopt('a1')
        d = ds.decision(self.conn, 'D1')
        self.assertEqual(d['adopted'], 2)
        self.assertEqual(d['revisions']['1']['statement'], fixtures.operations()[0][1]['statement'], 'revision 1 is kept as it was')
        self.assertEqual(d['revisions']['2']['adoption']['replaces'], 1)

    def test_adoption_records_an_external_fact_only(self):
        self.load_fixture()
        self.propose('p1')
        for op, kwargs, words in (('x1', {'decided_by': ''}, 'decided_by'), ('x2', {'source': {}}, 'source'),
                                  ('x3', {'replaces': None}, 'replaces must name the adopted revision 1'),
                                  ('x4', {'replaces': 2}, 'replaces must name the adopted revision 1'),
                                  ('x5', {'revision': 9}, 'no revision 9'), ('x6', {'revision': 1}, 'not an open proposal')):
            with self.subTest(op=op), self.assertRaises(ds.Refused) as caught:
                self.adopt(op, **kwargs)
            self.assertIn(words, str(caught.exception))
        out = self.adopt('a1')
        self.assertIn('grants no authority', out['note'])
        with self.assertRaises(ds.Refused):
            self.adopt('a2')  # revision 2 is already adopted
        self.assertEqual(ds.decision(self.conn, 'D1')['adopted'], 2)

    def test_one_scope_per_id(self):
        self.load_fixture()
        with self.assertRaises(ds.Refused) as caught:
            ds.apply(self.conn, 'r1', {'kind': 'register', 'actor': ACTOR, 'id': 'D1', 'scope': 'another/scope', 'statement': 's', 'source': SOURCE})
        self.assertIn('never reused', str(caught.exception))
        ds.apply(self.conn, 'r2', {'kind': 'register', 'actor': ACTOR, 'id': 'D1-OTHER', 'scope': 'another/scope', 'statement': 's', 'source': SOURCE})
        self.assertEqual((ds.decision(self.conn, 'D1')['scope'], ds.decision(self.conn, 'D1-OTHER')['scope']), ('registry-v3/version-order', 'another/scope'))

    def test_append_only(self):
        self.load_fixture()
        for sql in ("UPDATE events SET actor = 'x'", 'DELETE FROM events'):
            with self.subTest(sql=sql), self.assertRaises(sqlite3.IntegrityError):
                self.conn.execute(sql)
        self.assertEqual(self.events(), len(fixtures.operations()))

    def test_reference_integrity(self):
        self.load_fixture()
        base = {'kind': 'add_reference', 'actor': ACTOR, 'ref_id': 'R9', 'decision': 'D1', 'revision': 1, 'ref_kind': 'copy', 'locator': SOURCE}
        for op, change, words in (('f1', {'decision': 'D9'}, 'unknown decision'), ('f2', {'revision': 5}, 'no revision 5'),
                                  ('f3', {'ref_kind': 'opinion'}, 'ref_kind must be one of'), ('f4', {'ref_id': 'R1'}, 'already exists'),
                                  ('f5', {'locator': {}}, 'locator')):
            with self.subTest(op=op), self.assertRaises(ds.Refused) as caught:
                ds.apply(self.conn, op, dict(base, **change))
            self.assertIn(words, str(caught.exception))

    def test_selective_review_changes_nothing(self):
        self.load_fixture()
        self.assertEqual([ds.review_candidates(self.conn, d) for d in ('D1', 'D2', 'D3')], [[], [], []])
        self.propose('p1')
        self.assertEqual(ds.review_candidates(self.conn, 'D1'), [], 'a proposal alone puts nothing under review')
        self.adopt('a1')
        count, before = self.events(), ds.decision(self.conn, 'D1')
        self.assertEqual([ds.review_candidates(self.conn, d) for d in ('D1', 'D2', 'D3')], [['R1'], [], []],
                         "only D1's copy of revision 1; its historical-open record and other decisions are not candidates")
        self.assertEqual((self.events(), ds.decision(self.conn, 'D1')), (count, before), 'listing changes nothing')

    def test_review_only_counts_copies_older_than_the_adoption(self):
        """Acceptance correction: nothing adopted → nothing to review; a copy of a newer, unadopted proposal is not stale;
        a copy of the previously adopted revision is."""
        ds.apply(self.conn, 'n1', {'kind': 'register', 'actor': ACTOR, 'id': 'DX', 'scope': 'test/x', 'statement': 's1', 'source': SOURCE})
        ref = lambda op, rid, rev: ds.apply(self.conn, op, {'kind': 'add_reference', 'actor': ACTOR, 'ref_id': rid, 'decision': 'DX', 'revision': rev,
                                                             'ref_kind': 'copy', 'locator': SOURCE})
        ref('n2', 'C1', 1)
        self.assertEqual(ds.review_candidates(self.conn, 'DX'), [], 'no adoption yet: nothing is stale')
        self.adopt('n3', did='DX', revision=1, replaces=None)
        self.propose('n4', did='DX', base=1, statement='s2')
        ref('n5', 'C2', 2)  # a copy made from the newer proposal, before it is adopted
        self.assertEqual(ds.review_candidates(self.conn, 'DX'), [], 'the copy of revision 1 matches the adoption; the copy of proposal 2 is not stale')
        self.adopt('n6', did='DX', revision=2, replaces=1)
        self.assertEqual(ds.review_candidates(self.conn, 'DX'), ['C1'], 'only the copy of the replaced revision')

    def test_two_writers_with_the_same_base(self):
        """Two connections propose from the same base: BEGIN IMMEDIATE serializes them, the second is a conflict."""
        self.load_fixture()
        other = self.open()
        ds.apply(self.conn, 'w1', {'kind': 'propose', 'actor': 'A', 'id': 'D2', 'base_revision': 1, 'statement': 'from A', 'source': SOURCE})
        with self.assertRaises(ds.Refused):
            ds.apply(other, 'w2', {'kind': 'propose', 'actor': 'B', 'id': 'D2', 'base_revision': 1, 'statement': 'from B', 'source': SOURCE})
        self.assertEqual(ds.decision(other, 'D2')['revisions']['2']['statement'], 'from A', 'no last-writer-wins')
        lock = sqlite3.connect(str(self.path), isolation_level=None, timeout=0.1)
        self.addCleanup(lock.close)
        lock.execute('BEGIN IMMEDIATE')
        busy = ds.open_store(self.path, timeout=0.1)
        self.addCleanup(busy.close)
        with self.assertRaises(sqlite3.OperationalError):
            ds.apply(busy, 'w3', {'kind': 'propose', 'actor': 'C', 'id': 'D2', 'base_revision': 2, 'statement': 'blocked', 'source': SOURCE})
        lock.execute('ROLLBACK')
        self.assertIsNone(busy.execute("SELECT 1 FROM events WHERE op_id = 'w3'").fetchone(), 'nothing half-written while locked')



class Daily(Store):
    """日常接続前の隔離実装範囲: copy supersedes, withdrawal, read-only reading, backup and validate."""

    def ref(self, op, rid, rev, did='D1', kind='copy', supersedes=None):
        req = {'kind': 'add_reference', 'actor': ACTOR, 'ref_id': rid, 'decision': did, 'revision': rev, 'ref_kind': kind, 'locator': SOURCE}
        if supersedes is not None:
            req['supersedes'] = supersedes
        return ds.apply(self.conn, op, req)

    def withdraw(self, op, did='D2', base=1, decided_by='user', source=SOURCE):
        return ds.apply(self.conn, op, {'kind': 'record_withdrawal', 'actor': ACTOR, 'id': did, 'base_adopted': base, 'decided_by': decided_by, 'source': source})

    def test_superseding_a_checked_copy(self):
        self.load_fixture()
        self.propose('p1')
        self.adopt('a1')
        self.assertEqual(ds.review_candidates(self.conn, 'D1'), ['R1'])
        self.ref('s1', 'R1b', 2, supersedes='R1')  # R1 was checked against revision 2
        self.assertEqual(ds.review_candidates(self.conn, 'D1'), [], 'the checked copy leaves the review list')
        refs = ds.decision(self.conn, 'D1')['references']
        self.assertEqual((refs['R1']['supersededBy'], refs['R1']['revision'], refs['R1b']['supersededBy']), ('R1b', 1, None), 'the old reference stays')
        for op, kwargs, words in (('s2', {'rid': 'R1c', 'rev': 2, 'supersedes': 'R1'}, 'already superseded by R1b'),
                                  ('s3', {'rid': 'R2b', 'rev': 2, 'supersedes': 'R2'}, 'is not one'),  # R2 is historical-open
                                  ('s4', {'rid': 'R3b', 'rev': 1, 'did': 'D2', 'supersedes': 'R1b'}, 'is not one'),  # another decision
                                  ('s5', {'rid': 'R1d', 'rev': 2, 'kind': 'evidence', 'supersedes': 'R1b'}, 'is not one'),
                                  ('s6', {'rid': 'R1e', 'rev': 2, 'supersedes': 'R404'}, 'is not one')):
            with self.subTest(op=op), self.assertRaises(ds.Refused) as caught:
                self.ref(op, **kwargs)
            self.assertIn(words, str(caught.exception))

    def test_withdrawal_is_recorded_and_never_readopted(self):
        self.load_fixture()
        self.ref('c1', 'C1', 1, did='D2')
        for op, kwargs, words in (('w0', {'base': 2}, 'base_adopted must name the adopted revision 1'), ('w1', {'decided_by': ''}, 'decided_by'),
                                  ('w2', {'source': {}}, 'source')):
            with self.subTest(op=op), self.assertRaises(ds.Refused) as caught:
                self.withdraw(op, **kwargs)
            self.assertIn(words, str(caught.exception))
        out = self.withdraw('w3')
        self.assertIn('grants no authority', out['note'])
        d = ds.decision(self.conn, 'D2')
        self.assertEqual((d['adopted'], d['withdrawn'], d['revisions']['1']['withdrawal']['decidedBy']), (None, 1, 'user'))
        self.assertEqual(d['revisions']['1']['statement'], json.loads(fixtures.RESULT.read_text(encoding='utf-8'))['decisions']['D2']['text'], 'nothing deleted')
        self.assertEqual(ds.review_candidates(self.conn, 'D2'), ['C1'], 'copies of the withdrawn revision are to be reviewed')
        with self.assertRaises(ds.Refused) as caught:
            self.adopt('w4', did='D2', revision=1, replaces=None)
        self.assertIn('cannot be adopted again', str(caught.exception))
        with self.assertRaises(ds.Refused):
            self.withdraw('w5', base=1)  # nothing adopted any more
        self.propose('w6', did='D2', base=1, statement='a new proposal after the withdrawal')
        self.adopt('w7', did='D2', revision=2, replaces=None)
        self.assertEqual((ds.decision(self.conn, 'D2')['adopted'], ds.review_candidates(self.conn, 'D2')), (2, ['C1']))

    def test_reading_is_read_only_with_the_authority_note(self):
        self.load_fixture()
        before = self.path.read_bytes()
        reader = ds.open_store(self.path, readonly=True)
        self.addCleanup(reader.close)
        self.assertEqual(ds.decision(reader, 'D1')['authority'], ds.AUTHORITY)
        with self.assertRaises(sqlite3.OperationalError) as caught:
            ds.apply(reader, 'ro1', {'kind': 'propose', 'actor': ACTOR, 'id': 'D1', 'base_revision': 1, 'statement': 'x', 'source': SOURCE})
        self.assertIn('readonly', str(caught.exception))
        self.assertEqual(self.path.read_bytes(), before)

    def test_backup_and_validate(self):
        self.load_fixture()
        target = self.dir / 'backup.sqlite3'
        out = ds.backup(self.conn, target)
        self.assertEqual((out['events'], out['decisions']), (len(fixtures.operations()), ['D1', 'D2', 'D3']))
        kept = self.dir / 'kept.sqlite3'
        kept.write_bytes(b'not mine')
        with self.assertRaises(FileExistsError):
            ds.backup(self.conn, kept)
        self.assertEqual(kept.read_bytes(), b'not mine')
        before = target.read_bytes()
        reader = ds.open_store(target, readonly=True)
        self.addCleanup(reader.close)
        self.assertEqual(ds.decision(reader, 'D3')['adopted'], 1, 'a backup is queried read-only')
        self.assertEqual(target.read_bytes(), before)
        broken = self.dir / 'broken.sqlite3'
        broken.write_bytes(before[:len(before) // 2])
        foreign = self.dir / 'foreign.sqlite3'
        sqlite3.connect(foreign).execute('CREATE TABLE t (x)').connection.close()
        for bad in (broken, foreign, kept):
            with self.subTest(bad=bad.name), self.assertRaises(ds.NotADecisionStore):
                ds.validate(bad)


class Cli(Store):
    def cli(self, *args, stdin=None):
        run = subprocess.run([sys.executable, '-B', str(HERE / 'decision_cli.py'), *map(str, args)], input=stdin, capture_output=True, text=True, timeout=60)
        return run.returncode, json.loads(run.stdout)

    def test_roundtrip(self):
        fresh = self.dir / 'cli.sqlite3'
        self.assertEqual(self.cli('init', '--db', fresh)[0], 0)
        self.assertEqual(self.cli('init', '--db', fresh)[0], 1, 'never overwrites')
        self.assertEqual(self.cli('query', '--db', self.dir / 'none.sqlite3', '--id', 'D1')[0], 3)
        for op, req in fixtures.operations():
            code, out = self.cli('apply', '--db', fresh, '--op', op, '--request', '-', stdin=json.dumps(req, ensure_ascii=False))
            self.assertEqual(code, 0, out)
        req = {'kind': 'propose', 'actor': ACTOR, 'id': 'D1', 'base_revision': 1, 'statement': 's2', 'source': SOURCE}
        self.assertEqual(self.cli('apply', '--db', fresh, '--op', 'c1', '--request', '-', stdin=json.dumps(req))[0], 0)
        code, out = self.cli('apply', '--db', fresh, '--op', 'c1', '--request', '-', stdin=json.dumps(req))
        self.assertEqual((code, out['result']['replayed']), (0, True))
        self.assertEqual(self.cli('apply', '--db', fresh, '--op', 'c1', '--request', '-', stdin=json.dumps(dict(req, statement='x')))[0], 5)
        self.assertEqual(self.cli('apply', '--db', fresh, '--op', 'c2', '--request', '-', stdin=json.dumps(req))[0], 1, 'stale base')
        self.assertEqual(self.cli('apply', '--db', fresh, '--op', 'c3', '--request', '-', stdin='[1]')[0], 2)
        code, out = self.cli('query', '--db', fresh, '--id', 'D1')
        self.assertEqual((code, sorted(out['result']['revisions'])), (0, ['1', '2']))
        code, out = self.cli('query', '--db', fresh, '--id', 'D1', '--review')
        self.assertEqual((code, out['result']), (0, []))
        code, out = self.cli('export', '--db', fresh)
        self.assertEqual(([e['status'] for e in out['result']][-2:], out['authority']), (['done', 'refused'], ds.AUTHORITY))
        before = fresh.read_bytes()
        self.assertEqual(self.cli('query', '--db', fresh, '--id', 'D1')[1]['authority'], ds.AUTHORITY)
        self.assertEqual(fresh.read_bytes(), before, 'query and export do not write')
        code, out = self.cli('backup', '--db', fresh, '--to', self.dir / 'cli-backup.sqlite3')
        self.assertEqual((code, out['result']['decisions']), (0, ['D1', 'D2', 'D3']))
        self.assertEqual(self.cli('backup', '--db', fresh, '--to', self.dir / 'cli-backup.sqlite3')[0], 1, 'never overwrites')
        self.assertEqual(self.cli('validate', '--db', self.dir / 'cli-backup.sqlite3')[0], 0)
        (self.dir / 'junk.sqlite3').write_bytes(b'junk')
        self.assertEqual(self.cli('validate', '--db', self.dir / 'junk.sqlite3')[0], 2)
        self.assertEqual(self.cli('validate', '--db', self.dir / 'none.sqlite3')[0], 3)


if __name__ == '__main__':
    sys.exit(0 if unittest.main(exit=False, verbosity=2 if '-v' in sys.argv else 1).result.wasSuccessful() else 1)
