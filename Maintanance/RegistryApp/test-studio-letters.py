#!/usr/bin/env python3
"""H-20261019-25: isolated tests of the letters (requests between members) in the approvals database (案A): the original
texts and revisions, the state machine, who may act, proxy records, same-transaction writes, reading without side
effects, idempotency, concurrency, the HTTP routes and the comm.py command line. Temporary files and servers only."""
import concurrent.futures
import contextlib
import io
import json
import os
import socket
import sqlite3
import sys
import tempfile
import threading
import unittest
import uuid
from pathlib import Path
from unittest.mock import patch

import activity
import approvals
import comm
import serve
import studio_client
import studio_store

RealComm = studio_store.Store
op = lambda: uuid.uuid4().hex
BODY = '# 依頼\n\n1. 改行と **Markdown** を\n2. そのまま保持する。\n\n```\ncode\n```\n'


class Base(unittest.TestCase):
    def setUp(self):
        temp = tempfile.TemporaryDirectory()
        self.addCleanup(temp.cleanup)
        self.root = Path(temp.name)
        self.db = self.root / 'Approvals' / 'letters.sqlite3'
        self.s = RealComm(self.db, self.root)
        doc = self.root / 'Doc.md'
        doc.write_text('# Doc\n\n## 仕様\n\n本文がある。\n\n## 空\n\n## 空でない\n\nx\n', encoding='utf-8')
        p = patch.object(activity, 'ROOT', self.root)
        p.start()
        self.addCleanup(p.stop)
        self.s.set_senders(['Astra', 'ユーザー'], 'ユーザー')

    def raw(self, sql, *args):
        con = sqlite3.connect(self.db)
        try:
            return con.execute(sql, args).fetchall()
        finally:
            con.close()

    def send(self, **kw):
        a = dict(operation_id=op(), sender='Astra', recipient='姫', task_id='OPS-156', body=BODY) | kw
        return self.s.send(**a)

    def ev(self, letter, event, actor='姫', **kw):
        if event == 'received' and 'revision' not in kw:
            kw['revision'] = 1  # the version these tests read
        return self.s.event(kw.pop('operation_id', op()), letter['id'], event, actor, **kw)


class StoreTests(Base):
    def test_original_text_and_state_machine(self):
        sent = self.send()
        self.assertRegex(sent['id'], r'^LTR-\d{8}-[0-9A-F]{32}$')
        self.assertEqual((sent['state'], sent['stateLabel'], sent['request']['body'], sent['request']['revision']), ('sent', '未受領', BODY, 1), 'the original text is kept verbatim')
        self.assertIsNone(sent['reply'])
        x = self.ev(sent, 'received')
        self.assertEqual((x['state'], x['requestRevisionAtReceipt'], x['revisedAfterReceipt']), ('received', 1, False))
        self.assertEqual(self.ev(sent, 'started')['state'], 'started')
        with self.assertRaises(ValueError):
            self.ev(sent, 'returned')  # a reply needs its text
        done = self.ev(sent, 'returned', body='返答の原文\n', ref_doc='Doc.md', ref_section='仕様')
        self.assertEqual((done['state'], done['reply']['body'], done['reply']['ref_doc'], done['reply']['ref_section']), ('returned', '返答の原文\n', 'Doc.md', '仕様'))
        self.assertEqual(self.ev(done, 'closed', actor='Astra')['state'], 'closed')
        events = [e['event'] for e in self.s.letter(sent['id'])['events']]
        self.assertEqual(events, ['sent', 'received', 'started', 'returned', 'closed'])

    def test_refused_transitions_and_who_may_act(self):
        sent = self.send()
        for event, actor in (('started', '姫'), ('returned', '姫'), ('closed', 'Astra')):
            with self.assertRaises(approvals.Conflict, msg=event):
                self.ev(sent, event, actor=actor, **({'body': 'r'} if event == 'returned' else {}))
        for event, actor in (('received', 'Astra'), ('closed', '姫'), ('withdrawn', '姫'), ('received', '他人')):
            with self.assertRaisesRegex(approvals.Conflict, 'Only the', msg=event):
                self.ev(sent, event, actor=actor, **({'note': '理由'} if event == 'withdrawn' else {}))
        with self.assertRaisesRegex(ValueError, 'reason'):
            self.ev(sent, 'declined')
        self.assertEqual(self.ev(sent, 'declined', note='範囲外').get('state'), 'declined')
        with self.assertRaises(approvals.Conflict):
            self.ev(sent, 'received')
        self.assertEqual(self.ev(sent, 'closed', actor='Astra')['state'], 'closed')
        w = self.send()
        self.ev(w, 'received')
        self.ev(w, 'started')
        with self.assertRaisesRegex(ValueError, 'reason'):
            self.ev(w, 'withdrawn', actor='Astra')
        self.assertEqual(self.ev(w, 'withdrawn', actor='Astra', note='範囲変更')['stateLabel'], '停止要請', 'a withdrawal is a stop request')

    def test_senders_and_no_proxy_send(self):
        with self.assertRaisesRegex(approvals.Conflict, 'not in the list'):
            self.send(sender='姫', recipient='Astra')
        with self.assertRaisesRegex(approvals.Conflict, 'proxy send'):
            self.send(recorded_by='姫')
        before = self.s.senders()
        after = self.s.set_senders(['Astra', 'ユーザー', '姫'], 'ユーザー')
        self.assertEqual((before['version'], after['version'], after['senders']), (1, 2, ['Astra', 'ユーザー', '姫']))
        self.assertEqual(len(self.raw("SELECT * FROM meta WHERE key LIKE 'letter-senders:%'")), 2, 'a new version is appended, never overwritten')
        con = sqlite3.connect(self.db)
        with self.assertRaises(sqlite3.DatabaseError):
            con.execute("UPDATE meta SET value='[]' WHERE key='letter-senders:1'")
        con.close()
        self.assertEqual(self.send(sender='姫', recipient='Astra')['sender'], '姫')
        with self.assertRaises(ValueError):
            self.send(recipient='Astra')  # sender == recipient

    def test_proxy_records_change_nothing(self):
        sent = self.send()
        proxy = self.ev(sent, 'received', recorded_by='Astra')
        self.assertEqual((proxy['effective'], proxy['state']), (False, 'sent'), 'recorded by someone else: kept, but the state does not move')
        self.assertEqual([(e['event'], e['effective']) for e in proxy['events']], [('sent', True), ('received', False)])
        own = self.ev(sent, 'received')
        self.assertEqual((own['effective'], own['state']), (True, 'received'))
        self.ev(sent, 'started')
        proxy_reply = self.ev(sent, 'returned', recorded_by='Astra', body='代理の返答')
        self.assertEqual((proxy_reply['state'], proxy_reply['reply']), ('started', None), 'a proxy reply writes no reply text')
        with self.assertRaisesRegex(approvals.Conflict, 'proxy revision'):
            self.s.revise(op(), sent['id'], 'request', 'Astra', '新', '理由', recorded_by='姫')

    def test_revisions_keep_history_and_mark_after_receipt(self):
        sent = self.send()
        self.ev(sent, 'received')
        with self.assertRaises(approvals.Conflict):
            self.s.revise(op(), sent['id'], 'request', '姫', '新', '理由')  # only the sender revises the request
        with self.assertRaises(ValueError):
            self.s.revise(op(), sent['id'], 'request', 'Astra', '新', '')
        r = self.s.revise(op(), sent['id'], 'request', 'Astra', '第2版\n', '誤字の訂正')
        self.assertEqual(r['request']['revision'], 2)
        self.assertEqual((r['request']['revision'], r['request']['body'], r['request']['reason'], r['state']), (2, '第2版\n', '誤字の訂正', 'received'), 'state unchanged')
        self.assertEqual((r['requestRevisionAtReceipt'], r['revisedAfterReceipt']), (1, True), 'a revision after receipt is visible')
        self.assertEqual([(t['part'], t['revision'], t['body']) for t in r['texts']], [('request', 1, BODY), ('request', 2, '第2版\n')], 'every revision is kept')
        with self.assertRaisesRegex(approvals.Conflict, 'no reply'):
            self.s.revise(op(), sent['id'], 'reply', '姫', 'x', '理由')
        self.ev(sent, 'started')
        self.ev(sent, 'returned', body='返答1')
        rr = self.s.revise(op(), sent['id'], 'reply', '姫', '返答2', '補足')
        self.assertEqual((rr['reply']['revision'], rr['reply']['body']), (2, '返答2'))
        self.ev(sent, 'closed', actor='Astra')
        with self.assertRaisesRegex(approvals.Conflict, 'closed'):
            self.s.revise(op(), sent['id'], 'reply', '姫', '返答3', '後から')

    def test_receipt_names_the_revision_that_was_read(self):
        # H-20261019-27: the recipient reads v1 in its inbox, the sender revises to v2, then the recipient receives.
        sent = self.send()
        read = self.s.inbox('姫')['letters'][0]['request']
        self.assertEqual(read['revision'], 1)
        self.s.revise(op(), sent['id'], 'request', 'Astra', '第2版', '範囲の訂正')
        with self.assertRaisesRegex(ValueError, 'revision that was read'):
            self.s.event(op(), sent['id'], 'received', '姫')
        with self.assertRaisesRegex(ValueError, 'No such request revision'):
            self.s.event(op(), sent['id'], 'received', '姫', revision=3)
        x = self.s.event(op(), sent['id'], 'received', '姫', revision=read['revision'])
        self.assertEqual((x['state'], x['requestRevisionAtReceipt'], x['revisedAfterReceipt']), ('received', 1, True), 'v1 was read; v2 is not taken as read')
        self.assertEqual(x['request']['revision'], 2)
        with self.assertRaisesRegex(ValueError, 'Only received'):
            self.ev(sent, 'started', revision=2)
        other = self.send()
        self.s.revise(op(), other['id'], 'request', 'Astra', '第2版', '訂正')
        y = self.ev(other, 'received', revision=2)
        self.assertEqual((y['requestRevisionAtReceipt'], y['revisedAfterReceipt']), (2, False))
        o = op()
        self.s.event(o, other['id'], 'started', '姫')
        with self.assertRaisesRegex(approvals.Conflict, 'different content'):
            self.s.event(o, other['id'], 'started', '姫', note='別')

    def test_stop_request_and_answers(self):
        # before receipt: the stop request stays in the inbox, and the recipient answers without receiving
        a = self.send()
        self.ev(a, 'withdrawn', actor='Astra', note='依頼を取りやめる')
        box = {x['id']: x for x in self.s.inbox('姫')['letters']}
        self.assertEqual((box[a['id']]['state'], box[a['id']]['stopRequested'], box[a['id']]['stopReason']), ('withdrawn', True, '依頼を取りやめる'), 'not lost from the inbox')
        with self.assertRaisesRegex(approvals.Conflict, 'not possible now'):
            self.ev(a, 'closed', actor='Astra')  # no forced close: an unanswered stop request stays unanswered
        with self.assertRaisesRegex(approvals.Conflict, 'Nothing was started'):
            self.ev(a, 'returned', body='x')
        with self.assertRaisesRegex(ValueError, 'note'):
            self.ev(a, 'stopped')
        proxy = self.ev(a, 'stopped', recorded_by='Astra', note='止まっているはず')
        self.assertEqual((proxy['effective'], proxy['state']), (False, 'withdrawn'), 'a proxy stop answer does not move it')
        own = self.ev(a, 'stopped', note='着手していない')
        self.assertEqual((own['state'], own['stateLabel'], own['reply']), ('stopped', '停止済み（本人の応答）', None))
        self.assertNotIn(a['id'], [x['id'] for x in self.s.inbox('姫')['letters']])
        self.assertEqual(self.ev(a, 'closed', actor='Astra')['state'], 'closed')
        # during work: a stop answer with what was done so far
        b = self.send()
        self.ev(b, 'received')
        self.ev(b, 'started')
        self.ev(b, 'withdrawn', actor='Astra', note='優先の変更')
        with self.assertRaisesRegex(approvals.Conflict, 'Work was started'):
            self.ev(b, 'declined', note='やめる')
        stopped = self.ev(b, 'stopped', note='途中まで', body='途中成果の原文\r\n')
        self.assertEqual((stopped['state'], stopped['reply']['body']), ('stopped', '途中成果の原文\r\n'))
        self.assertEqual(self.ev(b, 'closed', actor='Astra')['state'], 'closed')
        # during work: a reply finished before stopping is still accepted (and is not acceptance)
        c = self.send()
        self.ev(c, 'received')
        self.ev(c, 'started')
        self.ev(c, 'withdrawn', actor='Astra', note='やめてよい')
        done = self.ev(c, 'returned', body='間に合った返答')
        self.assertEqual((done['state'], done['reply']['body']), ('returned', '間に合った返答'))
        # received but not started: a decline answers the stop request
        d = self.send()
        self.ev(d, 'received')
        self.ev(d, 'withdrawn', actor='Astra', note='取りやめ')
        self.assertEqual(self.ev(d, 'declined', note='未着手のため辞退')['state'], 'declined')
        with self.assertRaisesRegex(approvals.Conflict, 'not possible now'):
            self.ev(self.send(), 'stopped', note='要請がない')
        self.assertEqual([e['event'] for e in self.s.letter(b['id'])['events']], ['sent', 'received', 'started', 'withdrawn', 'stopped', 'closed'], 'history is kept')

    def test_older_withdrawals_still_derive(self):
        # a withdrawal recorded before notes were required (H25) is read the same way: a stop request
        sent = self.send()
        con = sqlite3.connect(self.db)
        o = op()
        con.execute('INSERT INTO operations VALUES (?,?,?,?,?,?,?,?)', (o, 'letter-event', 'x', 'Astra', 'Astra', approvals.now(), 'applied', '{}'))
        con.execute("INSERT INTO letter_events(letter_id,event,actor,recorded_by,claimed_at,received_at,text_sequence,note,effective,operation_id) VALUES (?,?,?,?,NULL,?,NULL,'',1,?)",
                    (sent['id'], 'withdrawn', 'Astra', 'Astra', approvals.now(), o))
        con.commit()
        con.close()
        x = self.s.inbox('姫')['letters'][0]
        self.assertEqual((x['state'], x['stopRequested'], x['stopReason']), ('withdrawn', True, ''))
        self.assertEqual(self.ev(sent, 'stopped', note='了解')['state'], 'stopped')

    def test_brief_list_reads_no_text(self):
        a, b = self.send(), self.send(recipient='Fable')
        self.ev(a, 'received')
        self.s.revise(op(), a['id'], 'request', 'Astra', '第2版', '訂正')
        self.ev(a, 'started')
        self.ev(a, 'withdrawn', actor='Astra', note='止める')
        self.ev(a, 'stopped', recorded_by='Astra', note='代理')
        statements, real = [], sqlite3.connect
        def traced(*args, **kwargs):
            con = real(*args, **kwargs)
            con.set_trace_callback(statements.append)
            return con
        with patch.object(approvals.sqlite3, 'connect', traced):
            brief = self.s.letters_brief()
        reads = [s for s in statements if s.lstrip().upper().startswith('SELECT')]
        self.assertTrue(reads)
        self.assertFalse([s for s in reads if 'body' in s.lower() or ('select *' in s.lower() and 'letter_texts' in s.lower())], 'no query reads a text')
        self.assertNotIn('body', json.dumps(brief, ensure_ascii=False))
        self.assertNotIn(BODY.splitlines()[0], json.dumps(brief, ensure_ascii=False))
        x = next(l for l in brief['letters'] if l['id'] == a['id'])
        self.assertEqual((x['state'], x['stateLabel'], x['requestRevision'], x['replyRevision'], x['requestRevisionAtReceipt'], x['revisedAfterReceipt'], x['stopRequested'], x['stopReason'], x['proxyRecords']),
                         ('withdrawn', '停止要請', 2, None, 1, True, True, '止める', 1))
        self.assertEqual([l['id'] for l in self.s.letters_brief(member='Fable')['letters']], [b['id']])
        self.assertEqual([l['id'] for l in self.s.letters_brief(state='withdrawn')['letters']], [a['id']])
        full = {l['id']: l for l in self.s.letters()['letters']}
        for l in brief['letters']:
            f = full[l['id']]
            self.assertEqual((l['state'], l['requestRevision'], l['revisedAfterReceipt']), (f['state'], f['request']['revision'], f['revisedAfterReceipt']), 'the brief list agrees with the full one')
            # OPS-183/184: who did what and when, without any text; a proxy record stays marked as not effective
            meta = [{'event': e['event'], 'actor': e['actor'], 'recordedBy': e['recorded_by'], 'effective': e['effective'], 'at': e['received_at']} for e in f['events']]
            self.assertEqual(l['events'], meta)
            self.assertEqual(l['lastEvent'], meta[-1])
        self.assertEqual([(e['event'], e['actor'], e['recordedBy'], e['effective']) for e in x['events']][-1], ('stopped', '姫', 'Astra', False), 'a proxy stop is told apart')

    def test_brief_pages_are_stable_complete_and_filtered_on_the_server(self):
        self.s.set_senders(['Astra', 'ユーザー', '姫'], 'ユーザー')
        made, who = [], {}
        for i in range(130):
            sender, recipient = (('Astra', '姫'), ('Astra', 'Fable'), ('ユーザー', '姫'), ('姫', 'Astra'))[i % 4]
            made.append(self.send(sender=sender, recipient=recipient, body=f'#{i}')['id'])
            who[made[-1]] = (sender, recipient)
        newest_first = list(reversed(made))
        def pages(**kw):
            seen, cursor, count = [], None, 0
            while True:
                page = self.s.letters_brief(limit=50, cursor=cursor, **kw)
                count += 1
                self.assertLessEqual(len(page['letters']), 50)
                seen += [l['id'] for l in page['letters']]
                if not page['hasMore']:
                    self.assertIsNone(page['nextCursor'])
                    return seen, count
                cursor = page['nextCursor']
        everything, n = pages()
        self.assertEqual((everything, n), (newest_first, 3), 'every letter once, newest first, over 3 pages')
        first = self.s.letters_brief(limit=50)
        self.assertEqual((first['limit'], first['hasMore'], len(first['letters'])), (50, True, 50))
        # letters added between pages neither shift nor repeat the older pages
        added = [self.send(body='new')['id'] for _ in range(5)]
        who.update({a: ('Astra', '姫') for a in added})
        second = self.s.letters_brief(limit=50, cursor=first['nextCursor'])
        self.assertEqual([l['id'] for l in second['letters']], newest_first[50:100])
        self.assertEqual([l['id'] for l in self.s.letters_brief(limit=5)['letters']], list(reversed(added)))
        # filters on the server, before the page is cut
        all_ids = list(reversed(made + added))
        for kw, keep in (({'sender': 'Astra'}, lambda s, r: s == 'Astra'), ({'recipient': '姫'}, lambda s, r: r == '姫'),
                         ({'member': 'Astra'}, lambda s, r: 'Astra' in (s, r)), ({'sender': 'Astra', 'recipient': 'Fable'}, lambda s, r: (s, r) == ('Astra', 'Fable'))):
            expect = [i for i in all_ids if keep(*who[i])]
            got, _ = pages(**kw)
            self.assertEqual(got, expect, kw)
        # a sender picks up every reply, however many
        replies = [i for i in made if who[i][0] == 'Astra'][:60]
        self.assertEqual(len(replies), 60)
        for lid in replies:
            l, actor = {'id': lid}, who[lid][1]
            self.ev(l, 'received', actor=actor)
            self.ev(l, 'started', actor=actor)
            self.ev(l, 'returned', actor=actor, body='返答')
        got, n = pages(sender='Astra', state='returned')
        self.assertEqual((sorted(got), n), (sorted(replies), 2), '60 replies over 2 pages, none dropped')
        with self.assertRaises(ValueError):
            self.s.letters_brief(cursor='x5')
        with self.assertRaises(ValueError):
            self.s.letters_brief(cursor='r0')

    def test_body_limits_and_optional_references(self):
        with self.assertRaises(ValueError):
            self.send(body='   ')
        with self.assertRaises(ValueError):
            self.send(body='x' * (studio_store.MAX_BODY + 1))
        self.assertEqual(self.send(body='あ' * (studio_store.MAX_BODY // 3))['request']['body'], 'あ' * (studio_store.MAX_BODY // 3))
        for doc, section in (('Doc.md', '空'), ('Doc.md', 'ない'), ('../x.md', '仕様'), ('Doc.md', None)):
            with self.assertRaises(ValueError, msg=(doc, section)):
                self.send(ref_doc=doc, ref_section=section)
        ok = self.send(ref_doc='Doc.md', ref_section='空でない')
        self.assertEqual((ok['request']['ref_doc'], ok['request']['ref_section']), ('Doc.md', '空でない'))
        self.assertIsNone(self.send()['request']['ref_doc'], 'a reference is optional')

    def test_reading_records_nothing_and_inbox_lists_only_open_letters_to_me(self):
        a, b, c, d = self.send(), self.send(), self.send(), self.send(recipient='Fable')
        self.ev(b, 'received')
        self.ev(b, 'started')
        self.ev(c, 'declined', note='不可')
        count = lambda: (len(self.raw('SELECT * FROM letter_events')), len(self.raw('SELECT * FROM operations')))
        before = count()
        box = self.s.inbox('姫')
        self.s.letters()
        self.s.letter(a['id'])
        self.assertEqual(count(), before, 'reading is not a receipt')
        self.assertEqual([x['id'] for x in box['letters']], [a['id'], b['id']], 'only mine, only 未受領・受領・担当中')
        self.assertEqual([x['state'] for x in box['letters']], ['sent', 'started'])
        self.assertIn('body', box['letters'][0]['request'])
        self.assertEqual([x['id'] for x in self.s.letters(member='Fable')['letters']], [d['id']])
        self.assertEqual([x['id'] for x in self.s.letters(state='declined')['letters']], [c['id']])
        with self.assertRaises(ValueError):
            self.s.letters(state='done')

    def test_idempotent_operations_and_reused_ids(self):
        o = op()
        first = self.send(operation_id=o)
        self.assertEqual(self.send(operation_id=o)['id'], first['id'])
        self.assertTrue(self.send(operation_id=o)['replayed'])
        with self.assertRaisesRegex(approvals.Conflict, 'different content'):
            self.send(operation_id=o, body='別の本文')
        e = op()
        self.ev(first, 'received', operation_id=e)
        self.assertTrue(self.ev(first, 'received', operation_id=e)['replayed'])
        self.assertEqual(len(self.raw("SELECT * FROM letter_events WHERE event='received'")), 1)
        self.assertEqual(len(self.raw('SELECT * FROM letters')), 1)

    def test_failure_rolls_back_text_event_and_operation(self):
        sent = self.send()
        self.ev(sent, 'received')
        self.ev(sent, 'started')
        before = [len(self.raw(f'SELECT * FROM {t}')) for t in ('letter_texts', 'letter_events', 'operations')]
        with patch.object(studio_store.LetterMixin, '_insert_event', side_effect=RuntimeError('injected')):
            with self.assertRaises(RuntimeError):
                self.ev(sent, 'returned', body='返答')
            with self.assertRaises(RuntimeError):
                self.send()
        self.assertEqual([len(self.raw(f'SELECT * FROM {t}')) for t in ('letter_texts', 'letter_events', 'operations')], before, 'no text or event alone')
        self.assertEqual(self.s.letter(sent['id'])['state'], 'started')

    def test_append_only_tables(self):
        sent = self.send()
        con = sqlite3.connect(self.db)
        for sql in ("UPDATE letters SET recipient='x'", 'DELETE FROM letters', "UPDATE letter_texts SET body='x'", 'DELETE FROM letter_texts',
                    "UPDATE letter_events SET event='x'", 'DELETE FROM letter_events'):
            with self.assertRaises(sqlite3.DatabaseError, msg=sql):
                con.execute(sql)
        con.close()

    def test_concurrent_events_one_winner(self):
        sent = self.send()
        def receive(_):
            try:
                return RealComm(self.db, self.root).event(op(), sent['id'], 'received', '姫', revision=1)['state']
            except approvals.Conflict:
                return 'refused'
        with concurrent.futures.ThreadPoolExecutor(6) as pool:
            results = list(pool.map(receive, range(6)))
        self.assertEqual(sorted(results), ['received'] + ['refused'] * 5)
        same = op()
        with concurrent.futures.ThreadPoolExecutor(6) as pool:
            sends = list(pool.map(lambda _: RealComm(self.db, self.root).send(same, 'Astra', '姫', 'OPS-156', BODY)['id'], range(6)))
        self.assertEqual(len(set(sends)), 1)


class HttpTests(Base):
    def setUp(self):
        super().setUp()
        p = patch.object(serve.studio_store, 'Store', lambda *a, **k: RealComm(self.db, self.root))
        p.start()
        self.addCleanup(p.stop)
        class Quiet(serve.Handler):
            def log_message(self, *args):
                pass
        self.server = serve.ThreadingHTTPServer(('127.0.0.1', 0), Quiet)
        threading.Thread(target=self.server.serve_forever, daemon=True).start()
        self.addCleanup(self.server.server_close)
        self.addCleanup(self.server.shutdown)
        e = patch.dict(os.environ, {'REGISTRY_STUDIO_URL': f'http://127.0.0.1:{self.server.server_port}'})
        e.start()
        self.addCleanup(e.stop)
        self.main = threading.current_thread()
        # OPS-184: watch also reads /activity-events; the record is a temporary file, never the live Activity/
        self.events = self.root / 'Activity' / 'events.jsonl'
        a = patch.object(activity, 'EVENTS', self.events)
        a.start()
        self.addCleanup(a.stop)

    def cli(self, *argv, stdin=b''):
        out, real = io.StringIO(), sqlite3.connect
        def guarded(*a, **k):
            if threading.current_thread() is self.main:
                raise AssertionError('the command line opened SQLite directly')
            return real(*a, **k)
        with patch.object(sys, 'argv', ['comm.py', *argv]), patch.object(sqlite3, 'connect', guarded), patch.object(sys, 'stdin', io.TextIOWrapper(io.BytesIO(stdin if isinstance(stdin, bytes) else stdin.encode('utf-8')), encoding='utf-8')), contextlib.redirect_stdout(out):
            try:
                comm.main()
                return 0, out.getvalue()
            except SystemExit as exit_:
                return exit_.code, out.getvalue()

    def test_full_exchange_through_comm_cli(self):
        body = self.root / 'req.md'
        body.write_text(BODY, encoding='utf-8')
        code, out = self.cli('letter', 'send', '--sender', 'Astra', '--recipient', '姫', '--task', 'OPS-156', '--body-file', str(body))
        self.assertEqual(code, 0)
        lid = json.loads(out)['id']
        code, out = self.cli('letter', 'inbox', '--owner', '姫')
        self.assertEqual([x['id'] for x in json.loads(out)['letters']], [lid])
        self.assertEqual(json.loads(self.cli('letter', 'show', lid)[1])['request']['body'], BODY, 'the original text over HTTP')
        self.assertEqual(self.cli('letter', 'receive', lid, '--actor', '姫')[0], 2, 'receive needs --revision')
        self.assertEqual(self.cli('letter', 'receive', lid, '--actor', '姫', '--revision', '1')[0], 0)
        self.assertEqual(self.cli('letter', 'start', lid, '--actor', '姫')[0], 0)
        code, out = self.cli('letter', 'return', lid, '--actor', '姫', '--body-file', '-', stdin='返答\nです\n')
        self.assertEqual((code, json.loads(out)['reply']['body']), (0, '返答\nです\n'))
        self.assertEqual(json.loads(self.cli('letter', 'inbox', '--owner', '姫')[1])['letters'], [], 'returned: no longer open for me')
        self.assertEqual(self.cli('letter', 'close', lid, '--actor', '姫')[0], 1, 'only the sender closes')
        self.assertEqual(json.loads(self.cli('letter', 'close', lid, '--actor', 'Astra')[1])['state'], 'closed')
        self.assertEqual(json.loads(self.cli('letter', 'list', '--state', 'closed')[1])['letters'][0]['id'], lid)
        self.assertEqual(json.loads(self.cli('letter', 'senders')[1])['senders'], ['Astra', 'ユーザー'])
        self.assertEqual(self.cli('letter', 'senders', '--set', '姫')[0], 1, '--set needs --recorded-by')

    def test_line_endings_are_kept_from_files_and_standard_input(self):
        crlf = '一行目\r\n二行目\r\n\r\n- 箇条\r\n'
        f = self.root / 'crlf.md'
        f.write_bytes(crlf.encode('utf-8'))
        code, out = self.cli('letter', 'send', '--sender', 'Astra', '--recipient', '姫', '--task', 'OPS-156', '--body-file', str(f))
        lid = json.loads(out)['id']
        self.assertEqual(self.s.letter(lid)['request']['body'], crlf, 'CRLF from a file is stored as is')
        mixed = 'LF\nCRLF\r\nCR\rend'
        code, out = self.cli('letter', 'send', '--sender', 'Astra', '--recipient', '姫', '--task', 'OPS-156', '--body-file', '-', stdin=mixed.encode('utf-8'))
        self.assertEqual(json.loads(out)['request']['body'], mixed, 'mixed newlines from standard input are stored as is')
        lf = self.root / 'lf.md'
        lf.write_bytes(b'a\nb\n')
        self.cli('letter', 'receive', lid, '--actor', '姫', '--revision', '1')
        self.cli('letter', 'start', lid, '--actor', '姫')
        code, out = self.cli('letter', 'return', lid, '--actor', '姫', '--body-file', str(lf))
        self.assertEqual((code, json.loads(out)['reply']['body']), (0, 'a\nb\n'))

    def test_stop_request_and_answer_through_comm_cli(self):
        sent = self.send()
        self.assertEqual(self.cli('letter', 'withdraw', sent['id'], '--actor', 'Astra')[0], 1, 'a stop request needs a reason')
        self.assertEqual(json.loads(self.cli('letter', 'withdraw', sent['id'], '--actor', 'Astra', '--note', '取りやめ')[1])['stateLabel'], '停止要請')
        box = json.loads(self.cli('letter', 'inbox', '--owner', '姫')[1])['letters']
        self.assertEqual((box[0]['stopRequested'], box[0]['stopReason']), (True, '取りやめ'))
        code, out = self.cli('letter', 'stop', sent['id'], '--actor', '姫', '--note', '未着手', '--body-file', '-', stdin=b'partial\r\n')
        self.assertEqual((code, json.loads(out)['state'], json.loads(out)['reply']['body']), (0, 'stopped', 'partial\r\n'))

    def test_watch_reports_changes_once_and_never_loses_them(self):
        state = self.root / 'watch-hime.json'
        gets = []
        original = serve.Handler.do_GET
        def counting(handler):
            gets.append(handler.path)
            return original(handler)
        watch = lambda owner='姫', f=state: self.cli('letter', 'watch', '--owner', owner, '--state-file', str(f))
        with patch.object(serve.Handler, 'do_GET', counting):
            code, out = watch()
            self.assertEqual((code, json.loads(out)['changes']), (3, []), 'empty inbox: nothing new')
            sent = self.send()
            events_before = len(self.raw('SELECT * FROM letter_events'))
            gets.clear()
            code, out = watch()
            self.assertEqual(len(gets), 1, 'one GET only')
            self.assertEqual((code, [c['changes'] for c in json.loads(out)['changes']]), (0, [['new']]))
            self.assertEqual(len(self.raw('SELECT * FROM letter_events')), events_before, 'watching records no receipt')
            self.assertEqual(watch()[0], 3, 'reported once')
            self.s.revise(op(), sent['id'], 'request', 'Astra', '第2版', '訂正')
            self.assertEqual([c['changes'] for c in json.loads(watch()[1])['changes']], [['revision']])
            self.ev(sent, 'received', revision=2)
            self.assertEqual([c['changes'] for c in json.loads(watch()[1])['changes']], [['state']])
            self.ev(sent, 'withdrawn', actor='Astra', note='止める')
            changed = json.loads(watch()[1])['changes'][0]
            self.assertEqual((changed['changes'], changed['stopReason']), (['state', 'stop'], '止める'))
            # a failure leaves the state file as it was, and the change is still reported afterwards
            self.ev(sent, 'stopped', note='了解')
            other = self.send()
            saved = state.read_bytes()
            with socket.socket() as s:
                s.bind(('127.0.0.1', 0))
                dead = s.getsockname()[1]
            with patch.dict(os.environ, {'REGISTRY_STUDIO_URL': f'http://127.0.0.1:{dead}'}):
                code, out = self.cli('letter', 'watch', '--owner', '姫', '--state-file', str(self.root / 'watch-dead.json'))
            self.assertEqual((code, json.loads(out)['outcome']), (1, 'not-sent'))
            original_get = studio_client.get
            def fail(path):
                raise studio_client.StudioError('lost', 'unknown')
            with patch.object(studio_client, 'get', fail):
                code, out = watch()
            self.assertEqual((code, json.loads(out)['outcome']), (1, 'unknown'))
            self.assertEqual(state.read_bytes(), saved, 'the state file did not move')
            code, out = watch()
            self.assertEqual((code, sorted(c['id'] for c in json.loads(out)['changes'])), (0, [other['id']]), 'the new letter is still reported; the stopped one left the inbox')
        # a state file is bound to its owner and server
        self.assertEqual(watch(owner='Fable')[0], 2)
        with patch.dict(os.environ, {'REGISTRY_STUDIO_URL': f'http://127.0.0.1:{self.server.server_port + 1}'}):
            self.assertEqual(watch()[0], 2)
        port = self.server.server_port
        damaged = ['{not json', '[]', 'null', '"x"', '{}', json.dumps({'owner': '姫', 'server': str(port), 'seen': {}}),
                   json.dumps({'owner': '姫', 'server': port, 'seen': []}), json.dumps({'owner': '姫', 'server': port, 'seen': {'L': None}}),
                   json.dumps({'owner': '姫', 'server': port, 'seen': {'L': {'state': 'sent'}}}),
                   json.dumps({'owner': '姫', 'server': port, 'seen': {'L': {'state': 'sent', 'requestRevision': '1', 'stopRequested': False}}}),
                   json.dumps({'owner': '姫', 'server': port, 'seen': {'L': {'state': 'sent', 'requestRevision': 1, 'stopRequested': 0}}})]
        for i, text in enumerate(damaged):
            bad = self.root / f'bad{i}.json'
            bad.write_text(text, encoding='utf-8')
            code, out = watch(f=bad)
            self.assertEqual(code, 2, text)
            self.assertEqual(bad.read_text(encoding='utf-8'), text, 'a damaged file is left as it was')

    def test_watch_save_failure_is_explicit_and_keeps_the_old_file(self):
        state = self.root / 'watch-save.json'
        watch = lambda: self.cli('letter', 'watch', '--owner', '姫', '--state-file', str(state))
        self.assertEqual(watch()[0], 3)
        saved = state.read_bytes()
        sent = self.send()
        real_replace = os.replace
        def failing(src, dst):
            if dst == str(state):
                raise OSError('disk full')
            return real_replace(src, dst)
        with patch.object(os, 'replace', failing):
            code, out = watch()
        self.assertEqual(code, 4)
        self.assertIn('not saved', out)
        self.assertIn(sent['id'], out, 'the change was printed')
        self.assertEqual(state.read_bytes(), saved, 'the previous file is kept')
        self.assertFalse((self.root / 'watch-save.json.tmp').exists(), 'no temporary file is left')
        code, out = watch()
        self.assertEqual((code, [c['id'] for c in json.loads(out)['changes']]), (0, [sent['id']]), 'printed again: not lost')
        self.assertEqual(json.loads(self.cli('letter', 'list', '--brief')[1])['brief'], True)

    def test_list_pages_through_comm_cli(self):
        for i in range(55):
            self.send(body=f'#{i}')
        code, out = self.cli('letter', 'list', '--brief')
        page = json.loads(out)
        self.assertEqual((code, len(page['letters']), page['hasMore'], page['nextCursor'] is not None), (0, 50, True, True), 'one page prints its next cursor')
        code, out = self.cli('letter', 'list', '--brief', '--cursor', page['nextCursor'])
        self.assertEqual(len(json.loads(out)['letters']), 5)
        code, out = self.cli('letter', 'list', '--brief', '--sender', 'Astra', '--recipient', '姫', '--all')
        every = json.loads(out)
        self.assertEqual((code, len(every['letters']), every['pages']), (0, 55, 2))
        self.assertEqual(len({l['id'] for l in every['letters']}), 55, 'no repeats')
        self.assertEqual(self.cli('letter', 'list', '--all')[0], 1, '--all needs --brief')
        with self.assertRaisesRegex(studio_client.StudioError, '400'):
            studio_client.get('/letters?cursor=r5')

    def test_http_guards_and_queries(self):
        call = lambda path, action, body: studio_client._call('POST', path, action, body)
        with self.assertRaisesRegex(studio_client.StudioError, '403'):
            call('/letters-send', 'letters-event', {})
        with self.assertRaisesRegex(studio_client.StudioError, '400'):
            call('/letters-send', 'letters-send', {'operationId': op(), 'sender': 'Astra'})
        with self.assertRaisesRegex(studio_client.StudioError, '409'):
            call('/letters-event', 'letters-event', {'operationId': op(), 'letterId': 'LTR-20261019-' + 'A' * 32, 'event': 'received', 'actor': '姫', 'revision': 1})
        for path, code in (('/letters-inbox', '400'), ('/letters-inbox?owner=a&owner=b', '400'), ('/letters?x=1', '400'), ('/letters/LTR-bad', '400'),
                           ('/letters/LTR-20261019-' + 'B' * 32, '404'), ('/letters?state=done', '400'), ('/letters?limit=0', '400')):
            with self.assertRaisesRegex(studio_client.StudioError, code, msg=path):
                studio_client.get(path)
        self.assertEqual(studio_client.get('/letters-inbox?owner=' + '%E5%A7%AB')['owner'], '姫')

    def test_unreachable_server_sends_nothing(self):
        with socket.socket() as s:
            s.bind(('127.0.0.1', 0))
            port = s.getsockname()[1]
        body = self.root / 'b.md'
        body.write_text('x', encoding='utf-8')
        with patch.dict(os.environ, {'REGISTRY_STUDIO_URL': f'http://127.0.0.1:{port}'}):
            code, _ = self.cli('letter', 'send', '--sender', 'Astra', '--recipient', '姫', '--task', 'OPS-156', '--body-file', str(body))
        self.assertEqual(code, 1)
        self.assertEqual(self.raw('SELECT * FROM letters'), [])
        code, _ = self.cli('letter', 'send', '--sender', 'Astra', '--recipient', '姫', '--task', 'OPS-156', '--body-file', str(self.root / 'missing.md'))
        self.assertEqual(code, 1, 'an unreadable body file sends nothing')


if __name__ == '__main__':
    unittest.main()
