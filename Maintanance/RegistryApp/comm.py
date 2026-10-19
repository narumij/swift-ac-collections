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
  comm.py letter list [--task T] [--member M] [--state sent|received|started|returned|declined|withdrawn|closed]
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
import json
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
    senders = letter.add_parser('senders')
    senders.add_argument('--set', nargs='+')
    senders.add_argument('--recorded-by')
    args = parser.parse_args()
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
        return studio_client.get('/letters' + ('?' + urllib.parse.urlencode(query) if query else ''))
    if args.set:
        if not args.recorded_by:
            raise ValueError('--set needs --recorded-by')
        return studio_client.post('/letters-senders', 'letters-senders', {'names': args.set, 'recordedBy': args.recorded_by})
    return studio_client.get('/letters-senders')


if __name__ == '__main__':
    main()
