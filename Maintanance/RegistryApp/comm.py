#!/usr/bin/env python3
"""OPS-156: PING / ACK through the Studio server (no direct database or jsonl write).

  comm.py ack PING-YYYYMMDD-XXXX --owner 姫 [--claimed-at 2026-10-19T04:00:00+09:00] [--recorded-by 姫]
  comm.py ping --target 姫 --task OPS-155 [--operation-id <32 hex>]   (the manual route of the screen's PING button)
  comm.py list

Letters (H-20261019-25; the original texts are kept by the server, with every revision):
  comm.py letter send --sender Astra --recipient 姫 --task OPS-156 --body-file request.md [--ref-doc D --ref-section S]
  comm.py letter inbox --owner 姫          (to me, not yet done: 未受領・受領・担当中; reading records nothing)
  comm.py letter show LTR-...
  comm.py letter receive LTR-... --actor 姫 --revision N   (the request revision you read; see inbox / show)
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
  comm.py letter watch --owner 姫 --state-file F   (one GET of my inbox, compared with F: new / state / revision / stop)
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
    for name in ('ref-doc', 'ref-section', 'operation-id'):
        send.add_argument('--' + name)
    letter.add_parser('inbox').add_argument('--owner', required=True)
    letter.add_parser('show').add_argument('letter_id')
    for name in ('receive', 'start', 'return', 'decline', 'withdraw', 'stop', 'close'):
        cmd = letter.add_parser(name)
        cmd.add_argument('letter_id')
        cmd.add_argument('--actor', required=True)
        for option in ('recorded-by', 'claimed-at', 'note', 'operation-id', 'ref-doc', 'ref-section'):
            cmd.add_argument('--' + option)
        cmd.add_argument('--body-file', required=name == 'return')
        if name == 'receive':
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
    watch = letter.add_parser('watch')
    watch.add_argument('--owner', required=True)
    watch.add_argument('--state-file', required=True)
    senders = letter.add_parser('senders')
    senders.add_argument('--set', nargs='+')
    senders.add_argument('--recorded-by')
    args = parser.parse_args()
    if args.command == 'letter' and args.letter == 'watch':
        sys.exit(watch_command(args))
    if args.command == 'letter':
        try:
            result = letter_command(args)
        except studio_client.StudioError as error:
            parser.exit(1, f'{error}\n')
        except (OSError, UnicodeDecodeError, ValueError) as error:
            parser.exit(1, f'{error}; nothing was sent\n')
        print(json.dumps(result, ensure_ascii=False, indent=2))
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


EVENTS = {'receive': 'received', 'start': 'started', 'return': 'returned', 'decline': 'declined', 'withdraw': 'withdrawn', 'stop': 'stopped', 'close': 'closed'}


def read_body(path):
    """The text exactly as written: bytes are decoded as UTF-8 with no newline translation (CRLF stays CRLF)."""
    if path == '-':
        return sys.stdin.buffer.read().decode('utf-8')
    with open(path, 'rb') as stream:
        return stream.read().decode('utf-8')


def optional(base, **values):
    return base | {k: v for k, v in values.items() if v is not None}


def letter_command(args):
    op = lambda: args.operation_id or uuid.uuid4().hex
    if args.letter == 'send':
        return studio_client.post('/letters-send', 'letters-send', optional({'operationId': op(), 'sender': args.sender, 'recipient': args.recipient,
                                  'taskId': args.task, 'body': read_body(args.body_file)}, refDoc=args.ref_doc, refSection=args.ref_section))
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


def _signature(letter):
    return {'state': letter['state'], 'requestRevision': (letter.get('request') or {}).get('revision'), 'stopRequested': bool(letter.get('stopRequested'))}


def watch_command(args):
    """One GET of OWNER's inbox compared with STATE_FILE. The file records the owner and the server it was made for, and
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
