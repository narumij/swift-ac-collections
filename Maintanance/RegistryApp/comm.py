#!/usr/bin/env python3
"""OPS-156: PING / ACK through the Studio server (no direct database or jsonl write).

  comm.py ack PING-YYYYMMDD-XXXX --owner 姫 [--claimed-at 2026-10-19T04:00:00+09:00] [--recorded-by 姫]
  comm.py ping --target 姫 --task OPS-155 [--operation-id <32 hex>]   (the manual route of the screen's PING button)
  comm.py list

Letters (H-20261019-25; the original texts are kept by the server, with every revision):
  comm.py letter send --sender Astra --recipient 姫 --task OPS-156 --body-file request.md [--ref-doc D --ref-section S]
      [--follows LTR-...]   (OPS-192: this letter continues that one; the link is recorded with the send, never later)
  comm.py letter read LTR-... [--full] [--json]   (the thread: by default this letter's current texts and the revision
      difference from the revision its recipient read; --full every letter, event and revision of the thread in time order)
  comm.py letter inbox --owner 姫          (to me, not yet done: 未受領・受領・担当中; reading records nothing)
  comm.py letter show LTR-...
  comm.py letter receive LTR-... --actor 姫 --revision N   (the request revision you read; see inbox / show)
  comm.py letter receive-revision LTR-... --actor 姫 --revision N   (returned, no stop-request history; state and original receipt stay)
  comm.py letter start LTR-... --actor 姫
  comm.py letter return LTR-... --actor 姫 --body-file reply.md [--ref-doc D --ref-section S]
  comm.py letter decline LTR-... --actor 姫 --note '理由'            (not after work was started)
  comm.py letter withdraw LTR-... --actor Astra --note '理由'         (a stop request; it stays in the inbox)
  comm.py letter stop LTR-... --actor 姫 --note '状況' [--body-file partial.md]   (the answer to a stop request)
  comm.py letter close LTR-... --actor Astra                          (after a reply, a decline or a stop answer)
  comm.py letter revise LTR-... --part request|reply --actor A --reason '理由' --body-file new.md
  comm.py letter list [--task T] [--member M] [--state sent|received|started|returned|declined|withdrawn|stopped|closed] [--brief]
      --brief pages: [--sender S] [--recipient R] [--cursor C] [--all]. One page (newest first) prints nextCursor;
      --all follows every page. A sender reads its replies with: --brief --sender Astra --state returned --all
  comm.py letter watch --owner 姫 --state-file F   [--wait SECONDS --interval SECONDS] (inbox and returned metadata; new / state / revision / stop)
      exit 0 = something changed (printed), 3 = nothing new, 1 = server trouble (F unchanged), 2 = F is damaged or
      belongs to another owner or server, 4 = changes printed but F could not be saved (F unchanged; they will be
      printed again next time). A change may be printed more than once, never lost. It never records a receipt and
      never starts anything; receive with `letter receive --revision N`.
  comm.py letter senders [--set NAME ... --recorded-by ユーザー]
--body-file - reads standard input. Names are self-reports, not authentication; the letter rules grant no work
authority. A withdrawal records a request to stop: it is not an immediate stop, there is no forced close, and no letter
state releases an occupancy (that is recorded under the task rules).

The record is a local self-report (see studio_client). An ACK whose recorder is someone else (--recorded-by) is a
proxy record, never the member's own answer. Two failures are told apart: "nothing was sent" (say so in the
conversation as unrecorded, and send the same ACK with --claimed-at once the server is back) and "result unknown"
(the request was sent but no answer came back; check `comm.py list` before sending again).
"""
import argparse
import time
import math
import io
import contextlib
import json
import os
import sys
import urllib.parse
import uuid

import studio_client


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    commands = parser.add_subparsers(dest='command', required=True)
    ack = commands.add_parser('ack')
    ack.add_argument('message_id')
    ack.add_argument('--owner', required=True)
    ack.add_argument('--recorded-by')
    ack.add_argument('--claimed-at')
    ping = commands.add_parser('ping')
    ping.add_argument('--target', required=True)
    ping.add_argument('--task', required=True)
    ping.add_argument('--operation-id')
    commands.add_parser('list')
    letter = commands.add_parser('letter').add_subparsers(dest='letter', required=True)
    send = letter.add_parser('send')
    for name in ('sender', 'recipient', 'task', 'body-file'):
        send.add_argument('--' + name, required=True)
    for name in ('ref-doc', 'ref-section', 'operation-id', 'follows'):
        send.add_argument('--' + name)
    letter.add_parser('inbox').add_argument('--owner', required=True)
    letter.add_parser('show').add_argument('letter_id')
    for name in ('receive', 'receive-revision', 'start', 'return', 'decline', 'withdraw', 'stop', 'close'):
        cmd = letter.add_parser(name)
        cmd.add_argument('letter_id')
        cmd.add_argument('--actor', required=True)
        for option in ('recorded-by', 'claimed-at', 'note', 'operation-id', 'ref-doc', 'ref-section'):
            cmd.add_argument('--' + option)
        cmd.add_argument('--body-file', required=name == 'return')
        if name in ('receive', 'receive-revision'):
            cmd.add_argument('--revision', type=int, required=True)
    revise = letter.add_parser('revise')
    revise.add_argument('letter_id')
    for name in ('part', 'actor', 'reason', 'body-file'):
        revise.add_argument('--' + name, required=True)
    for name in ('recorded-by', 'ref-doc', 'ref-section', 'operation-id'):
        revise.add_argument('--' + name)
    lst = letter.add_parser('list')
    for name in ('task', 'member', 'state', 'limit'):
        lst.add_argument('--' + name)
    lst.add_argument('--brief', action='store_true')
    for name in ('sender', 'recipient', 'cursor'):
        lst.add_argument('--' + name)
    lst.add_argument('--all', action='store_true')
    task = letter.add_parser('task')  # OPS-192: a task's canonical documents and its explicitly associated letters
    task.add_argument('task_id')
    task.add_argument('--full', action='store_true')
    task.add_argument('--json', action='store_true')
    task.add_argument('--doc-lines', type=int, default=40)
    read = letter.add_parser('read')  # OPS-192 D1: read a thread from one of its letters
    read.add_argument('letter_id')
    read.add_argument('--full', action='store_true')
    read.add_argument('--json', action='store_true')
    watch = letter.add_parser('watch')
    watch.add_argument('--owner', required=True)
    watch.add_argument('--state-file', required=True)
    watch.add_argument('--wait', type=positive_seconds)
    watch.add_argument('--interval', type=positive_seconds, default=5)
    senders = letter.add_parser('senders')
    senders.add_argument('--set', nargs='+')
    senders.add_argument('--recorded-by')
    turns=letter.add_parser('turns').add_subparsers(dest='turn_action',required=True)
    t=turns.add_parser('open');t.add_argument('letter_id');t.add_argument('--actor',required=True);t.add_argument('--members',nargs='+',required=True);t.add_argument('--operation-id',required=True)
    t=turns.add_parser('for-letter');t.add_argument('letter_id')
    t=turns.add_parser('add-member');t.add_argument('round_id');t.add_argument('--actor',required=True);t.add_argument('--turn',type=int,required=True);t.add_argument('--member',required=True);t.add_argument('--operation-id',required=True)
    for name in ('show','watch','speak','nop'):
        t=turns.add_parser(name);t.add_argument('round_id')
        if name=='watch':
            t.add_argument('--context',required=True);t.add_argument('--wait',type=float,default=30)
            t.add_argument('--owner');t.add_argument('--inbox-context')
        if name in ('speak','nop'):
            t.add_argument('--actor',required=True);t.add_argument('--turn',type=int,required=True);t.add_argument('--context',required=True);t.add_argument('--operation-id',required=True)
            if name=='speak':t.add_argument('--body-file',required=True)
    args = parser.parse_args()
    if args.command == 'letter' and args.letter == 'turns':
        sys.exit(turns_command(args))
    if args.command == 'letter' and args.letter == 'watch':
        sys.exit(watch_command(args))
    if args.command == 'letter' and args.letter == 'read':
        sys.exit(read_command(args))
    if args.command == 'letter' and args.letter == 'task':
        sys.exit(task_command(args))
    if args.command == 'letter':
        try:
            result = letter_command(args)
        except studio_client.StudioError as error:
            parser.exit(1, f'{error}\n')
        except (OSError, UnicodeDecodeError, ValueError) as error:
            parser.exit(1, f'{error}; nothing was sent\n')
        print(json.dumps(result, ensure_ascii=False, indent=2))
        check = result.get('docCheck') if isinstance(result, dict) else None
        if check and check['status'] != 'match':
            # OPS-192: told, not hidden; the receipt itself is recorded and nothing is stopped
            print(f"注意：正本 {check['doc']} は依頼時の記録と一致しない（{DOC_STATUS[check['status']]}）。"
                  f"依頼時 {check['baseSha256'] or 'なし'} / 今 {check['sha256'] or 'なし'}", file=sys.stderr)
        return
    try:
        if args.command == 'ack':
            body = {'messageId': args.message_id, 'owner': args.owner}
            if args.recorded_by:
                body['recordedBy'] = args.recorded_by
            if args.claimed_at:
                body['claimedAt'] = args.claimed_at
            result = studio_client.post('/comm-ack', 'comm-ack', body)
        elif args.command == 'ping':
            result = studio_client.post('/comm-ping', 'comm-ping', {'operationId': args.operation_id or uuid.uuid4().hex, 'target': args.target, 'taskId': args.task})
        else:
            result = studio_client.get('/comm-messages')
    except studio_client.StudioError as error:
        parser.exit(1, f'{error}\n')
    print(json.dumps(result, ensure_ascii=False, indent=2))


EVENTS = {'receive': 'received', 'receive-revision': 'revision-received', 'start': 'started', 'return': 'returned', 'decline': 'declined', 'withdraw': 'withdrawn', 'stop': 'stopped', 'close': 'closed'}


def read_body(path):
    """The text exactly as written: bytes are decoded as UTF-8 with no newline translation (CRLF stays CRLF)."""
    if path == '-':
        return sys.stdin.buffer.read().decode('utf-8')
    with open(path, 'rb') as stream:
        return stream.read().decode('utf-8')


def optional(base, **values):
    return base | {k: v for k, v in values.items() if v is not None}


def turns_command(args):
    """Turns belong to an existing request; never infer receipt, return or approval."""
    try:
        action=args.turn_action
        if action=='for-letter':
            result=studio_client.get('/letter-turns?'+urllib.parse.urlencode({'letter':args.letter_id}))
        elif action in ('show','watch'):
            q={'round':args.round_id}
            timeout=15
            if action=='watch':
                if not 0<=args.wait<=30:raise ValueError('wait must be 0..30')
                q.update(after=args.context,wait=args.wait)
                if args.owner is not None:q['owner']=args.owner
                if args.inbox_context is not None:q['inboxAfter']=args.inbox_context
                timeout=args.wait+5
            result=studio_client._call('GET','/letter-turns?'+urllib.parse.urlencode(q),timeout=timeout)
        else:
            b={'action':'create' if action=='open' else action,'actor':args.actor,'operationId':args.operation_id}
            if action=='open':b.update(letter=args.letter_id,members=args.members)
            elif action=='add-member':b.update(round=args.round_id,turn=args.turn,member=args.member)
            else:
                b.update(round=args.round_id,turn=args.turn,context=args.context)
                if action=='speak':
                    from pathlib import Path
                    b['body']=sys.stdin.read() if args.body_file=='-' else Path(args.body_file).read_text()
            result=studio_client.post('/letter-turns','letter-turns',b)
        print(json.dumps(result,ensure_ascii=False,indent=2));return 0
    except (studio_client.StudioError,ValueError,OSError) as e:
        print(str(e),file=sys.stderr);return 1


def letter_command(args):
    op = lambda: args.operation_id or uuid.uuid4().hex
    if args.letter == 'send':
        return studio_client.post('/letters-send', 'letters-send', optional({'operationId': op(), 'sender': args.sender, 'recipient': args.recipient,
                                  'taskId': args.task, 'body': read_body(args.body_file)}, refDoc=args.ref_doc, refSection=args.ref_section, follows=args.follows))
    if args.letter == 'inbox':
        return studio_client.get('/letters-inbox?' + urllib.parse.urlencode({'owner': args.owner}))
    if args.letter == 'show':
        return studio_client.get('/letters/' + urllib.parse.quote(args.letter_id))
    if args.letter in EVENTS:
        body = optional({'operationId': op(), 'letterId': args.letter_id, 'event': EVENTS[args.letter], 'actor': args.actor},
                        recordedBy=args.recorded_by, claimedAt=args.claimed_at, note=args.note, refDoc=args.ref_doc, refSection=args.ref_section,
                        revision=getattr(args, 'revision', None),
                        body=read_body(args.body_file) if args.body_file else None)
        return studio_client.post('/letters-event', 'letters-event', body)
    if args.letter == 'revise':
        return studio_client.post('/letters-revise', 'letters-revise', optional({'operationId': op(), 'letterId': args.letter_id, 'part': args.part,
                                  'actor': args.actor, 'reason': args.reason, 'body': read_body(args.body_file)}, recordedBy=args.recorded_by,
                                  refDoc=args.ref_doc, refSection=args.ref_section))
    if args.letter == 'list':
        query = {k: v for k, v in (('task', args.task), ('member', args.member), ('state', args.state), ('limit', args.limit)) if v}
        paging = {k: v for k, v in (('sender', args.sender), ('recipient', args.recipient), ('cursor', args.cursor)) if v}
        if (paging or args.all) and not args.brief:
            raise ValueError('--sender, --recipient, --cursor and --all need --brief')
        if not args.brief:
            return studio_client.get('/letters' + ('?' + urllib.parse.urlencode(query) if query else ''))
        query = query | paging | {'brief': '1'}
        page = studio_client.get('/letters?' + urllib.parse.urlencode(query))
        if not args.all:
            return page
        letters, pages = list(page['letters']), 1
        while page.get('hasMore'):
            page = studio_client.get('/letters?' + urllib.parse.urlencode(query | {'cursor': page['nextCursor']}))
            letters += page['letters']
            pages += 1
        return {'letters': letters, 'brief': True, 'pages': pages, 'hasMore': False, 'nextCursor': None}
    if args.set:
        if not args.recorded_by:
            raise ValueError('--set needs --recorded-by')
        return studio_client.post('/letters-senders', 'letters-senders', {'names': args.set, 'recordedBy': args.recorded_by})
    return studio_client.get('/letters-senders')


def task_command(args):
    """OPS-192: read a task's canonical documents (the paths its Registry detail names) and the letters explicitly
    associated with it (same taskId, or a text revision referencing one of those documents), through the server only.
    Read only. Exit: 0 read; 1 server not reachable or result unknown; 2 refused request; 3 unknown task; 4 read, but a
    document is missing or the detail names none."""
    try:
        got = studio_client.get('/task-context?' + urllib.parse.urlencode({'task': args.task_id}))
        if args.full:
            for letter in got['letters']:
                letter['texts'] = studio_client.get('/letters/' + urllib.parse.quote(letter['id']))['texts']
    except studio_client.StudioError as error:
        print(str(error), file=sys.stderr)
        return 3 if error.outcome == 'refused' and '(404)' in str(error) else 2 if error.outcome == 'refused' else 1
    incomplete = not got['documents'] or any(d['status'] != 'ok' for d in got['documents'])
    if args.json:
        print(json.dumps(got, ensure_ascii=False, indent=1))
        return 4 if incomplete else 0
    t = got['task']
    print(f"{t['id']} · {t['state']} · {t['owner']} · {t['item']}\n詳細（Registry）: {t['detail']}\n\n## 正本")
    if not got['documents']:
        print('（Registryの詳細に .md の正本パスがない）')
    for d in got['documents']:
        if d['status'] != 'ok':
            print(f"- {d['path']}：{'見つからない' if d['status'] == 'missing' else 'リポジトリの外'}")
            continue
        lines = d['text'].splitlines()
        shown = lines if args.doc_lines <= 0 else lines[:args.doc_lines]
        print(f"- {d['path']}（{len(lines)}行）\n" + '\n'.join(shown))
        if len(shown) < len(lines):
            print(f"…（省略：全{len(lines)}行のうち{len(shown)}行。全文は --doc-lines 0）")
    print(f"\n## 連絡（{len(got['letters'])}通、古い順。閉じた連絡も含む）")
    for x in got['letters']:
        why = (['同じtaskId'] if x['association']['taskId'] else []) + [
            f"{r['part']} v{r['revision']} が {r['doc']} § {r['section']} を参照（{'今の参照' if r['current'] else '前の版の参照'}）" for r in x['association']['refs']]
        print(f"- {x['id']} · {x['taskId']} · {x['sender']} → {x['recipient']} · {x['stateLabel']} · 送信 {x['sentAt']}\n  関連：{' / '.join(why)}")
        for text in x.get('texts', []):
            print(f"  ### {'依頼' if text['part'] == 'request' else '返答'} v{text['revision']}（記録 {text['recorded_by']} · {text['received_at']}）\n" + text['body'])
    if not args.full:
        print('\n本文は --full で全版を表示（各連絡は letter show <ID> でも読める）。')
    return 4 if incomplete else 0


PART = {'request': '依頼', 'reply': '返答'}
DOC_STATUS = {'recorded': '記録', 'missing': 'ファイルがない', 'match': '一致', 'mismatch': '不一致', 'no-record': '依頼時の記録がない',
              'diff': '差分を記録', 'unchanged': '変更なし', 'base-unavailable': '比較元の本文が記録にもGitにもない（導入前の記録）・diff未作成', 'not-text': 'UTF-8でない・diff未作成'}
EVENT_LABEL = {'sent': '送信', 'received': '受領', 'started': '着手', 'returned': '返答', 'declined': '辞退', 'withdrawn': '停止要請',
               'stopped': '停止の応答', 'closed': '閉じた', 'revised': '改訂', 'revision-received': '補正版受領'}


def _text_head(t):
    return f"{PART[t['part']]} v{t['revision']}（記録 {t['recorded_by']} · {t['received_at']}{' · 理由：' + t['reason'] if t['reason'] else ''}）"


def read_command(args):
    """OPS-192 D1: read the thread of a letter through the server only. Read only. Exit: 0 read; 1 server not reachable or
    result unknown; 2 refused request; 3 unknown letter."""
    try:
        got = studio_client.get('/letters/' + urllib.parse.quote(args.letter_id) + '/thread')
    except studio_client.StudioError as error:
        print(str(error), file=sys.stderr)
        return 3 if error.outcome == 'refused' and '(404)' in str(error) else 2 if error.outcome == 'refused' else 1
    if args.json:
        print(json.dumps(got, ensure_ascii=False, indent=1))
        return 0
    letters = {x['id']: x for x in got['letters']}
    me = letters[got['letter']]
    print(f"{me['id']} · {me['taskId']} · {me['sender']} → {me['recipient']} · {me['stateLabel']} · 送信 {me['sentAt']}")
    print(f"前の連絡：{me['follows'] or 'なし'} · 続き：{' / '.join(me['followedBy']) or 'なし'} · スレッド {got['root']}（{len(letters)}通）")
    if not args.full:
        for part in ('request', 'reply'):
            d = got['delta'][part]
            if d is None:
                print(f"\n## {PART[part]}：まだない")
                continue
            print(f"\n## {_text_head(d['text'])}\n{d['text']['body']}")
            if d['basis'] == 'receipt':
                print(f"### 受領で読んだ v{d['base']} からの差\n{d['diff'] or '（差なし）'}")
            else:
                why = '受領の記録がない' if part == 'request' else '返答を読んだ版の記録はない'
                print(f"### 差：基準不明（{why}。読んだとは扱わない。全版は --full）")
        try:
            records = studio_client.get('/letters/' + urllib.parse.quote(me['id'])).get('docRecords', [])
        except studio_client.StudioError as error:
            print(str(error), file=sys.stderr)
            return 1
        if records:
            print('\n## 正本のハッシュ（同一性の確認。内容の妥当性ではない）')
            for r in records:
                print(f"- #{r['sequence']} {r['kind']} · {r['doc']} · {DOC_STATUS.get(r['status'], r['status'])} · {r['sha256'] or 'なし'}")
                if r['baseSha256']:
                    kind = next((x['kind'] for x in records if x['sequence'] == r['baseRecord']), None)
                    print(f"  比較元 #{r['baseRecord']} {kind or '記録'}（{r['baseSha256'][:12]}）→ 比較先 #{r['sequence']}（{(r['sha256'] or 'なし')[:12]}）")
                if r['diff']:
                    print(r['diff'], end='')
        print('\nスレッド全体の原文は --full。')
        return 0
    print('\n## 連絡')
    for x in got['letters']:
        print(f"- {x['id']} · {x['taskId']} · {x['sender']} → {x['recipient']} · {x['stateLabel']} · 前：{x['follows'] or 'なし'}")
    texts = {(t['letter_id'], t['part'], t['revision']): t for t in got['texts']}
    print('\n## 流れ（出来事の順、原文）')
    for e in got['events']:
        who = e['actor'] if e['recordedBy'] == e['actor'] else f"{e['actor']}（代理記録 {e['recordedBy']}、状態は変えない）"
        print(f"\n[{e['sequence']}] {e['letterId']} · {EVENT_LABEL.get(e['event'], e['event'])} · {who} · {e['receivedAt']}{' · ' + e['note'] if e['note'] else ''}")
        if e['text'] is None:
            continue
        t = texts[(e['letterId'], e['text']['part'], e['text']['revision'])]
        if e['event'] in ('received', 'revision-received'):
            print(f"{PART[t['part']]} v{t['revision']} を読んだと記録")
        else:
            print(f"### {_text_head(t)}\n{t['body']}")
    return 0


def _signature(letter):
    return {'state': letter['state'], 'requestRevision': (letter.get('request') or {}).get('revision', letter.get('requestRevision')), 'stopRequested': bool(letter.get('stopRequested'))}


def positive_seconds(value):
    import argparse
    try:
        result = float(value)
        if not math.isfinite(result) or result <= 0:
            raise ValueError()
        return result
    except ValueError:
        raise argparse.ArgumentTypeError('seconds must be positive and finite')


def watch_command(args):
    wait = getattr(args, 'wait', None)
    if wait is None:
        return watch_once(args)
    deadline = time.monotonic() + wait
    while True:
        out = io.StringIO()
        with contextlib.redirect_stdout(out):
            result = watch_once(args)
        remaining = deadline - time.monotonic()
        if result != 3 or remaining <= 0:
            print(out.getvalue(), end='', flush=True)
            return result
        time.sleep(min(getattr(args, 'interval', 5), remaining))


def watch_once(args):
    """OWNER's inbox and paged returned metadata compared with STATE_FILE. The file records the owner and the server it was made for, and
    is replaced only after a successful fetch and after the changes were printed, so a failure loses nothing."""
    path = os.path.abspath(args.state_file)
    try:
        server = studio_client.server_address()
    except studio_client.StudioError as error:
        print(json.dumps({'error': str(error), 'outcome': error.outcome}, ensure_ascii=False))
        return 1
    previous = {'owner': args.owner, 'server': server, 'seen': {}}
    if os.path.exists(path):
        try:
            with open(path, encoding='utf-8') as stream:
                previous = json.load(stream)
        except (OSError, ValueError) as error:
            print(json.dumps({'error': f'state file unreadable: {error}'}, ensure_ascii=False))
            return 2
        if not _valid_state(previous):
            print(json.dumps({'error': 'state file is damaged (not the shape watch writes); nothing was changed'}, ensure_ascii=False))
            return 2
        if previous['owner'] != args.owner or previous['server'] != server:
            print(json.dumps({'error': 'state file belongs to another owner or server', 'stateFile': {'owner': previous['owner'], 'server': previous['server']}}, ensure_ascii=False))
            return 2
    try:
        inbox = studio_client.get('/letters-inbox?' + urllib.parse.urlencode({'owner': args.owner}))
        returned = studio_client.get('/letters?' + urllib.parse.urlencode({'brief': '1', 'recipient': args.owner, 'state': 'returned', 'limit': 1000}))
        while returned.get('hasMore'):
            page = studio_client.get('/letters?' + urllib.parse.urlencode({'brief': '1', 'recipient': args.owner, 'state': 'returned', 'limit': 1000, 'cursor': returned['nextCursor']}))
            returned['letters'] += page['letters']
            returned['hasMore'], returned['nextCursor'] = page.get('hasMore'), page.get('nextCursor')
        inbox['letters'] += returned['letters']
    except studio_client.StudioError as error:
        print(json.dumps({'error': str(error), 'outcome': error.outcome}, ensure_ascii=False))
        return 1
    seen, changes, now = previous['seen'], [], {}
    for letter in inbox['letters']:
        sig = _signature(letter)
        now[letter['id']] = sig
        old = seen.get(letter['id'])
        kinds = ['new'] if old is None else [k for k, field in (('state', 'state'), ('revision', 'requestRevision'), ('stop', 'stopRequested')) if old.get(field) != sig[field]]
        if kinds:
            changes.append({'id': letter['id'], 'taskId': letter['taskId'], 'sender': letter['sender'], 'changes': kinds, 'state': letter['state'],
                            'stateLabel': letter['stateLabel'], 'requestRevision': sig['requestRevision'], 'stopRequested': sig['stopRequested'],
                            'stopReason': letter.get('stopReason')})
    print(json.dumps({'owner': args.owner, 'open': len(now), 'changes': changes}, ensure_ascii=False, indent=2), flush=True)
    temp = path + '.tmp'
    try:
        with open(temp, 'w', encoding='utf-8') as stream:
            json.dump({'owner': args.owner, 'server': server, 'seen': now}, stream, ensure_ascii=False)
        os.replace(temp, path)
    except OSError as error:
        with contextlib.suppress(OSError):
            os.remove(temp)
        print(json.dumps({'error': f'state file not saved ({error}); the previous file is kept and these changes will be printed again', 'saved': False}, ensure_ascii=False), flush=True)
        return 4
    return 0 if changes else 3


def _valid_state(value):
    if not isinstance(value, dict) or not isinstance(value.get('owner'), str) or type(value.get('server')) is not int or not isinstance(value.get('seen'), dict):
        return False
    for key, sig in value['seen'].items():
        if not isinstance(key, str) or not isinstance(sig, dict) or set(sig) != {'state', 'requestRevision', 'stopRequested'}:
            return False
        if not isinstance(sig['state'], str) or not (sig['requestRevision'] is None or type(sig['requestRevision']) is int) or type(sig['stopRequested']) is not bool:
            return False
    return True


if __name__ == '__main__':
    main()
