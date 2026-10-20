#!/usr/bin/env python3
"""OPS-192 review round 2: disposable reproduction. The real studio_store.Store on a temporary DB and the real
comm.watch_command, with studio_client.get routed in-process to the store (no server, no live store). It shows
(1) the current gap, (2) what the current watch does when a returned letter re-enters the inbox, and (3) a prototype of
the proposed rules: a reply names the request revision it answers; watch keeps the last signature of letters that left."""
import contextlib
import io
import json
import os
import sys
import tempfile
import uuid
from pathlib import Path

APP = Path(sys.argv[1])
sys.path.insert(0, str(APP))
os.environ['REGISTRY_STUDIO_URL'] = 'http://127.0.0.1:9'  # only parsed by watch for the state file; never contacted
import comm, studio_client, studio_store, activity  # noqa: E402

d = Path(tempfile.mkdtemp(dir=os.environ.get('TMPDIR')))
store = studio_store.Store(d / 'letters.sqlite3', d)
activity.ROOT = d
op = lambda: uuid.uuid4().hex
store.set_senders(['Astra'], 'ユーザー')
answers = {}  # prototype of the proposed reply field: reply text revision -> the request revision it answers


def pending(letter_id):
    """Proposed: open for the recipient while the latest request revision is newer than every revision a reply answered."""
    full = store.letter(letter_id)
    replies = [t for t in full['texts'] if t['part'] == 'reply']
    answered = max((answers.get((letter_id, t['revision']), 0) for t in replies), default=0)
    return full['state'] == 'returned' and full['request']['revision'] > answered


def proposed_inbox(owner):
    base = store.inbox(owner)
    ids = {x['id'] for x in base['letters']}
    extra = [store.letter(x['id']) for x in store.letters(member=owner)['letters'] if x['recipient'] == owner and x['id'] not in ids and pending(x['id'])]
    for x in extra:
        x['stopRequested'], x['stopReason'] = False, None
    return {'owner': owner, 'letters': base['letters'] + extra}


def watch(inbox, keep_left=False):
    original = comm.watch_command
    studio_client.get = lambda path: inbox('姫')
    out = io.StringIO()
    args = type('A', (), {'owner': '姫', 'state_file': str(d / 'watch.json')})
    if keep_left and (d / 'watch.json').exists():  # prototype: remember letters that left the inbox
        before = json.loads((d / 'watch.json').read_text())['seen']
    with contextlib.redirect_stdout(out):
        code = original(args)
    if keep_left and 'before' in locals():
        st = json.loads((d / 'watch.json').read_text())
        st['seen'] = {**before, **st['seen']}
        (d / 'watch.json').write_text(json.dumps(st))
    printed = json.loads(out.getvalue().split('\n}\n')[0] + '\n}')
    return code, [(c['id'][-6:], c['changes']) for c in printed['changes']]


def run(label, inbox, keep_left):
    (d / 'watch.json').unlink(missing_ok=True)
    # answers keep earlier letters (keys include the letter ID)
    a = store.send(op(), 'Astra', '姫', 'OPS-192', '依頼 v1')
    lid = a['id']
    log = [('send', watch(inbox, keep_left))]
    store.event(op(), lid, 'received', '姫', revision=1)
    store.event(op(), lid, 'started', '姫')
    log.append(('receive+start', watch(inbox, keep_left)))
    store.event(op(), lid, 'returned', '姫', body='返答 v1'); answers[(lid, 1)] = 1
    log.append(('return (answers v1)', watch(inbox, keep_left)))
    store.revise(op(), lid, 'request', 'Astra', '依頼 v2', '補正')
    log.append(('sender revises request to v2', watch(inbox, keep_left)))
    store.revise(op(), lid, 'reply', '姫', '返答 v2（誤字だけ）', '誤字'); answers[(lid, 2)] = 1
    log.append(('recipient fixes a typo, answering v1', watch(inbox, keep_left)))
    pend1 = pending(lid)
    store.revise(op(), lid, 'reply', '姫', '返答 v3（v2への答え）', 'v2への返答'); answers[(lid, 3)] = 2
    log.append(('recipient answers v2', watch(inbox, keep_left)))
    pend2 = pending(lid)
    print(f'== {label}')
    for step, (code, ch) in log:
        print(f'  {step:40s} watch exit {code} {ch}')
    print(f'  pending after typo fix: {pend1}; after answering v2: {pend2}')


run('current inbox, current watch', store.inbox, False)
run('proposed inbox, current watch', proposed_inbox, False)
run('proposed inbox, watch keeps letters that left', proposed_inbox, True)
