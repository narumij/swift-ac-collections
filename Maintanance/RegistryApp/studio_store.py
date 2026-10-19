#!/usr/bin/env python3
"""OPS-156: communication records (first: PING and its ACK) in the same SQLite file as the approvals (案A).

Server-side only; the command line is comm.py and goes through the server. Records are append-only. One PING is one
operation (its operation ID makes a resend safe) and one message. An ACK is a separate record that names the PING ID;
the first ACK recorded by the PING's target itself is the answer, later ones by the target are duplicates, ACKs claimed
for anyone else are foreign, and an ACK for the target recorded by someone else is a proxy record — never the target's
own answer, before or after it (H22 相当). `recorded_by` (who made the record) and `owner` (whose answer it claims to
be) are kept apart, and
`claimed_at` (when the member says it received the PING) is kept apart from `received_at` (when the server stored it).
No ACK is "unanswered", never "stopped". Nothing here starts, wakes or resends anything.
"""
import datetime
import json
import re
import uuid

import approvals

PING_ID = re.compile(r'PING-\d{8}-[0-9A-F]{32}')


def _local_date():
    return datetime.datetime.now().astimezone().strftime('%Y%m%d')


def _iso(value):
    if value is None:
        return None
    approvals.text(value, 40)
    try:
        parsed = datetime.datetime.fromisoformat(value.replace('Z', '+00:00'))
    except ValueError:
        raise ValueError('claimedAt must be ISO 8601 with a time zone') from None
    if parsed.tzinfo is None:
        raise ValueError('claimedAt must be ISO 8601 with a time zone')
    return value


class PingMixin:
    def ping(self, operation_id, target, task_id, actor='ユーザー'):
        if not isinstance(operation_id, str) or not approvals.OPERATION_ID.fullmatch(operation_id):
            raise ValueError('Invalid operation ID')
        approvals.text(target, 80)
        approvals.text(task_id, 40)
        if not re.fullmatch(r'[A-Z][A-Z0-9]*-[0-9]+', task_id):
            raise ValueError('Invalid task ID')
        payload = {'kind': 'ping', 'target': target, 'taskId': task_id}
        with self.transaction() as con:
            done = self._operation(con, operation_id, 'ping', payload)
            if done is not None:
                return self._message(con, done['result']['messageId']) | {'replayed': True}
            message_id = f'PING-{_local_date()}-{uuid.uuid4().hex.upper()}'
            self._record_operation(con, operation_id, 'ping', payload, actor, 'applied', {'messageId': message_id, 'target': target})
            con.execute('INSERT INTO messages VALUES (?,?,?,?,?,?,?)', (message_id, 'ping', target, task_id, actor, operation_id, approvals.now()))
            return self._message(con, message_id) | {'replayed': False}

    def ack(self, message_id, owner, recorded_by=None, claimed_at=None):
        if not isinstance(message_id, str) or not PING_ID.fullmatch(message_id):
            raise ValueError('Invalid PING ID')
        approvals.text(owner, 80)
        recorded_by = owner if recorded_by is None else approvals.text(recorded_by, 80)
        claimed_at = _iso(claimed_at)
        with self.transaction() as con:
            message = con.execute('SELECT * FROM messages WHERE id=?', (message_id,)).fetchone()
            if message is None:
                raise LookupError('Unknown PING')
            if owner != message['target']:
                status = 'foreign'
            elif recorded_by != owner:
                status = 'proxy'
            elif con.execute("SELECT 1 FROM acks WHERE message_id=? AND status='answer'", (message_id,)).fetchone():
                status = 'duplicate'
            else:
                status = 'answer'
            con.execute('INSERT INTO acks(message_id,owner,recorded_by,claimed_at,received_at,status) VALUES (?,?,?,?,?,?)',
                        (message_id, owner, recorded_by, claimed_at, approvals.now(), status))
            return self._message(con, message_id) | {'ack': status}

    def _message(self, con, message_id):
        row = con.execute('SELECT * FROM messages WHERE id=?', (message_id,)).fetchone()
        acks = [dict(a) for a in con.execute('SELECT * FROM acks WHERE message_id=? ORDER BY sequence', (message_id,))]
        answer = next((a for a in acks if a['status'] == 'answer'), None)
        return {'id': row['id'], 'kind': row['kind'], 'target': row['target'], 'taskId': row['task_id'], 'sender': row['sender'],
                'operationId': row['operation_id'], 'receivedAt': row['received_at'],
                'status': 'answered' if answer else 'unanswered', 'answer': answer, 'acks': acks}

    def messages(self, limit=200):
        with self.transaction() as con:
            ids = [r[0] for r in con.execute('SELECT id FROM messages ORDER BY rowid DESC LIMIT ?', (int(limit),))]
            return {'messages': [self._message(con, i) for i in ids]}

    def cutover(self, after_event_id):
        """Record once the point from which PING/ACK are kept here and no longer written to the activity jsonl."""
        if not isinstance(after_event_id, str) or not re.fullmatch(r'[0-9a-f]{32}', after_event_id):
            raise ValueError('Expected the ID of the last activity event before the cutover')
        value = json.dumps({'afterEventId': after_event_id}, sort_keys=True)
        with self.transaction() as con:
            row = con.execute("SELECT value, recorded_at FROM meta WHERE key='ping-cutover'").fetchone()
            if row is not None:
                if row['value'] != value:
                    raise approvals.Conflict('The PING cutover is already recorded with another point')
                return json.loads(row['value']) | {'recordedAt': row['recorded_at'], 'replayed': True}
            at = approvals.now()
            con.execute("INSERT INTO meta VALUES ('ping-cutover',?,?)", (value, at))
            return json.loads(value) | {'recordedAt': at, 'replayed': False}

    def cutover_point(self):
        with self.transaction() as con:
            row = con.execute("SELECT value, recorded_at FROM meta WHERE key='ping-cutover'").fetchone()
            return None if row is None else json.loads(row['value']) | {'recordedAt': row['recorded_at']}


# ---- H-20261019-25: letters (requests between members) ------------------------------------------------------------
# A letter is a request from a sender to a recipient about one task. Its original text (request) and the recipient's
# reply are kept here verbatim with every revision; the letter events are the activity record of the letter (they are not
# copied to the activity jsonl). Sending, replying and revising each write the text and the event in one transaction.
# Reading never records anything. An event changes the state only when it is the act of the right person recorded by that
# person; a record made by someone else on their behalf is kept as a proxy record and changes nothing.
# Names are local self-reports, not authentication: these rules decide which records the letter function accepts, and
# they grant no work authority. A revision keeps history; it does not let either side change an agreed scope on its own.
# A withdrawal records the sender's request to stop (停止要請, H-20261019-28): it is not an immediate stop, it stays in the
# recipient's inbox, and only the recipient's own `stopped` answer (or a reply finished before stopping) moves it on.
# There is no forced close: an unanswered stop request stays unanswered. No letter state releases any occupancy; that is
# recorded separately under the task rules. A reply after a stop request hands over what was done; it neither allows
# more work nor means acceptance.
LETTER_ID = re.compile(r'LTR-\d{8}-[0-9A-F]{32}')
MAX_BODY = 32 * 1024
STATES = {'sent': '未受領', 'received': '受領', 'started': '担当中', 'returned': '返答済み', 'declined': '辞退', 'withdrawn': '停止要請',
          'stopped': '停止済み（本人の応答）', 'closed': '閉じた'}
# event: (who may act, states it may follow, part of a text written with it or None)
TRANSITIONS = {
    'received': ('recipient', {'sent'}, None),
    'started': ('recipient', {'received'}, None),
    'returned': ('recipient', {'started', 'withdrawn'}, 'reply'),
    'declined': ('recipient', {'sent', 'received', 'withdrawn'}, None),
    'withdrawn': ('sender', {'sent', 'received', 'started'}, None),
    'stopped': ('recipient', {'withdrawn'}, 'reply'),
    'closed': ('sender', {'returned', 'declined', 'stopped'}, None),
}
OPTIONAL_TEXT = {'stopped'}           # the stop answer may carry what was done so far
NOTE_REQUIRED = {'declined', 'withdrawn', 'stopped'}
OPEN_FOR_RECIPIENT = {'sent', 'received', 'started', 'withdrawn'}


def _body(value):
    if not isinstance(value, str) or not value.strip() or '\x00' in value or len(value.encode('utf-8')) > MAX_BODY:
        raise ValueError(f'Expected a nonempty text of at most {MAX_BODY} bytes')
    return value


def _ref(doc, section):
    if doc is None and section is None:
        return None, None
    if not isinstance(doc, str) or not isinstance(section, str):
        raise ValueError('A reference needs both doc and section')
    import activity
    checked = activity.check_ref(doc, section)  # one heading with a nonempty body; the content is judged at acceptance
    return checked['path'], checked['section']


class LetterMixin:
    def _letter_state(self, con, letter_id):
        state = None
        for row in con.execute('SELECT event FROM letter_events WHERE letter_id=? AND effective=1 ORDER BY sequence', (letter_id,)):
            if row['event'] != 'revised':
                state = row['event']
        return state

    def senders(self):
        with self.transaction() as con:
            return self._senders(con)

    def _senders(self, con):
        row = con.execute("SELECT key, value, recorded_at FROM meta WHERE key LIKE 'letter-senders:%' ORDER BY CAST(substr(key, 16) AS INTEGER) DESC LIMIT 1").fetchone()
        return {'senders': [], 'version': 0, 'recordedAt': None} if row is None else json.loads(row['value']) | {'recordedAt': row['recorded_at']}

    def set_senders(self, names, recorded_by):
        """Append a new version of the list of names that may send letters (the unique, append-only meta keys are never
        overwritten: version n is the key letter-senders:n). The recorder's name is a local self-report."""
        if not isinstance(names, list) or not names or len(names) > 50:
            raise ValueError('Expected a nonempty list of names')
        for name in names:
            approvals.text(name, 80)
        approvals.text(recorded_by, 80)
        with self.transaction() as con:
            current = self._senders(con)
            version = current['version'] + 1
            value = {'senders': sorted(set(names)), 'version': version, 'recordedBy': recorded_by}
            con.execute('INSERT INTO meta VALUES (?,?,?)', (f'letter-senders:{version}', json.dumps(value, ensure_ascii=False, sort_keys=True), approvals.now()))
            return self._senders(con)

    def _insert_text(self, con, letter_id, part, body, reason, ref, recorded_by, operation_id):
        revision = con.execute('SELECT COALESCE(MAX(revision), 0) + 1 FROM letter_texts WHERE letter_id=? AND part=?', (letter_id, part)).fetchone()[0]
        cursor = con.execute('INSERT INTO letter_texts(letter_id,part,revision,body,reason,ref_doc,ref_section,recorded_by,received_at,operation_id) VALUES (?,?,?,?,?,?,?,?,?,?)',
                             (letter_id, part, revision, body, reason, ref[0], ref[1], recorded_by, approvals.now(), operation_id))
        return cursor.lastrowid

    def _insert_event(self, con, letter_id, event, actor, recorded_by, claimed_at, text_sequence, note, effective, operation_id):
        con.execute('INSERT INTO letter_events(letter_id,event,actor,recorded_by,claimed_at,received_at,text_sequence,note,effective,operation_id) VALUES (?,?,?,?,?,?,?,?,?,?)',
                    (letter_id, event, actor, recorded_by, claimed_at, approvals.now(), text_sequence, note, 1 if effective else 0, operation_id))

    def send(self, operation_id, sender, recipient, task_id, body, recorded_by=None, ref_doc=None, ref_section=None):
        if not isinstance(operation_id, str) or not approvals.OPERATION_ID.fullmatch(operation_id):
            raise ValueError('Invalid operation ID')
        for value in (sender, recipient):
            approvals.text(value, 80)
        recorded_by = sender if recorded_by is None else approvals.text(recorded_by, 80)
        approvals.text(task_id, 40)
        if not re.fullmatch(r'[A-Z][A-Z0-9]*-[0-9]+', task_id):
            raise ValueError('Invalid task ID')
        if sender == recipient:
            raise ValueError('A letter needs another member as recipient')
        _body(body)
        ref = _ref(ref_doc, ref_section)
        payload = {'kind': 'letter-send', 'sender': sender, 'recipient': recipient, 'taskId': task_id, 'body': body, 'recordedBy': recorded_by, 'ref': list(ref)}
        with self.transaction() as con:
            done = self._operation(con, operation_id, 'letter-send', payload)
            if done is not None:
                return self._letter(con, done['result']['letterId']) | {'replayed': True}
            if sender not in self._senders(con)['senders']:
                raise approvals.Conflict('This name is not in the list of letter senders')
            if recorded_by != sender:
                raise approvals.Conflict('A letter is sent by the sender itself; a proxy send is not accepted')
            letter_id = f'LTR-{_local_date()}-{uuid.uuid4().hex.upper()}'
            self._record_operation(con, operation_id, 'letter-send', payload, recorded_by, 'applied', {'letterId': letter_id})
            con.execute('INSERT INTO letters VALUES (?,?,?,?,?,?,?)', (letter_id, 'request', sender, recipient, task_id, operation_id, approvals.now()))
            text_id = self._insert_text(con, letter_id, 'request', body, '', ref, recorded_by, operation_id)
            self._insert_event(con, letter_id, 'sent', sender, recorded_by, None, text_id, '', True, operation_id)
            return self._letter(con, letter_id) | {'replayed': False}

    def event(self, operation_id, letter_id, event, actor, recorded_by=None, claimed_at=None, note='', body=None, ref_doc=None, ref_section=None, revision=None):
        """`revision` is required for `received`: the request revision the recipient actually read (H-20261019-27). It is
        kept as read; a later revision shows as revised after receipt. Receiving never means "the latest" by default."""
        if not isinstance(operation_id, str) or not approvals.OPERATION_ID.fullmatch(operation_id):
            raise ValueError('Invalid operation ID')
        if not isinstance(letter_id, str) or not LETTER_ID.fullmatch(letter_id):
            raise ValueError('Invalid letter ID')
        if event not in TRANSITIONS:
            raise ValueError('Unknown letter event')
        approvals.text(actor, 80)
        recorded_by = actor if recorded_by is None else approvals.text(recorded_by, 80)
        claimed_at = _iso(claimed_at)
        if not isinstance(note, str) or len(note) > 2000 or '\x00' in note:
            raise ValueError('Invalid note')
        who, after, part = TRANSITIONS[event]
        if part and (event not in OPTIONAL_TEXT or body is not None):
            _body(body)
        elif not part and body is not None:
            raise ValueError('This event has no text')
        if event in NOTE_REQUIRED and not note.strip():
            raise ValueError(f'{event} needs a reason or note')
        if event == 'received':
            if type(revision) is not int or revision < 1:
                raise ValueError('received needs the request revision that was read')
        elif revision is not None:
            raise ValueError('Only received names a revision')
        ref = _ref(ref_doc, ref_section)
        payload = {'kind': 'letter-event', 'letterId': letter_id, 'event': event, 'actor': actor, 'recordedBy': recorded_by,
                   'claimedAt': claimed_at, 'note': note, 'body': body, 'ref': list(ref), 'revision': revision}
        with self.transaction() as con:
            done = self._operation(con, operation_id, 'letter-event', payload)
            if done is not None:
                return self._letter(con, letter_id) | {'replayed': True, 'effective': done['result']['effective']}
            letter = con.execute('SELECT * FROM letters WHERE id=?', (letter_id,)).fetchone()
            if letter is None:
                raise LookupError('Unknown letter')
            if actor != letter[who]:
                raise approvals.Conflict(f'Only the {who} records this event')
            effective = recorded_by == actor
            if effective:
                state = self._letter_state(con, letter_id)
                if state not in after:
                    raise approvals.Conflict(f'Letter is {STATES.get(state, state)}; {event} is not possible now')
                if state == 'withdrawn' and event in ('returned', 'declined'):
                    # after a stop request: a reply only for work that was started, a decline only if it was not
                    started = con.execute("SELECT 1 FROM letter_events WHERE letter_id=? AND event='started' AND effective=1", (letter_id,)).fetchone() is not None
                    if event == 'returned' and not started:
                        raise approvals.Conflict('Nothing was started; answer the stop request with stopped or declined')
                    if event == 'declined' and started:
                        raise approvals.Conflict('Work was started; answer the stop request with stopped or returned')
            self._record_operation(con, operation_id, 'letter-event', payload, recorded_by, 'applied' if effective else 'proxy', {'letterId': letter_id, 'event': event, 'effective': effective})
            text_id = self._insert_text(con, letter_id, part, body, '', ref, recorded_by, operation_id) if part and effective and body is not None else None
            if event == 'received':
                # the request revision the recipient says it read; a later revision is shown as "revised after receipt"
                row = con.execute("SELECT sequence FROM letter_texts WHERE letter_id=? AND part='request' AND revision=?", (letter_id, revision)).fetchone()
                if row is None:
                    raise ValueError('No such request revision')
                text_id = row[0]
            self._insert_event(con, letter_id, event, actor, recorded_by, claimed_at, text_id, note, effective, operation_id)
            return self._letter(con, letter_id) | {'replayed': False, 'effective': effective}

    def revise(self, operation_id, letter_id, part, actor, body, reason, recorded_by=None, ref_doc=None, ref_section=None):
        """A new revision of the request (by the sender) or of the reply (by the recipient), with a reason. History is
        kept and the state does not change. Not possible once the letter is closed or withdrawn."""
        if not isinstance(operation_id, str) or not approvals.OPERATION_ID.fullmatch(operation_id):
            raise ValueError('Invalid operation ID')
        if not isinstance(letter_id, str) or not LETTER_ID.fullmatch(letter_id):
            raise ValueError('Invalid letter ID')
        if part not in ('request', 'reply'):
            raise ValueError('Expected request or reply')
        approvals.text(actor, 80)
        recorded_by = actor if recorded_by is None else approvals.text(recorded_by, 80)
        _body(body)
        approvals.text(reason, 2000)
        ref = _ref(ref_doc, ref_section)
        payload = {'kind': 'letter-revise', 'letterId': letter_id, 'part': part, 'actor': actor, 'recordedBy': recorded_by, 'body': body, 'reason': reason, 'ref': list(ref)}
        with self.transaction() as con:
            done = self._operation(con, operation_id, 'letter-revise', payload)
            if done is not None:
                return self._letter(con, letter_id) | {'replayed': True}
            letter = con.execute('SELECT * FROM letters WHERE id=?', (letter_id,)).fetchone()
            if letter is None:
                raise LookupError('Unknown letter')
            if actor != letter['sender' if part == 'request' else 'recipient']:
                raise approvals.Conflict('Only the sender revises the request and only the recipient revises the reply')
            if recorded_by != actor:
                raise approvals.Conflict('A revision is recorded by its author; a proxy revision is not accepted')
            state = self._letter_state(con, letter_id)
            if state in ('closed', 'withdrawn'):
                raise approvals.Conflict('A closed or withdrawn letter is not revised')
            if part == 'reply' and not con.execute("SELECT 1 FROM letter_texts WHERE letter_id=? AND part='reply'", (letter_id,)).fetchone():
                raise approvals.Conflict('There is no reply to revise')
            self._record_operation(con, operation_id, 'letter-revise', payload, recorded_by, 'applied', {'letterId': letter_id, 'part': part})
            revision_id = self._insert_text(con, letter_id, part, body, reason, ref, recorded_by, operation_id)
            self._insert_event(con, letter_id, 'revised', actor, recorded_by, None, revision_id, reason, True, operation_id)
            return self._letter(con, letter_id) | {'replayed': False}

    def _letter(self, con, letter_id, with_texts=True):
        row = con.execute('SELECT * FROM letters WHERE id=?', (letter_id,)).fetchone()
        if row is None:
            raise LookupError('Unknown letter')
        texts = [dict(t) for t in con.execute('SELECT * FROM letter_texts WHERE letter_id=? ORDER BY sequence', (letter_id,))]
        events = [dict(e) | {'effective': bool(e['effective'])} for e in con.execute('SELECT * FROM letter_events WHERE letter_id=? ORDER BY sequence', (letter_id,))]
        state = self._letter_state(con, letter_id)
        latest = {part: max((t for t in texts if t['part'] == part), key=lambda t: t['revision'], default=None) for part in ('request', 'reply')}
        received = next((e for e in events if e['event'] == 'received' and e['effective']), None)
        seen = next((t['revision'] for t in texts if received and t['sequence'] == received['text_sequence']), None)
        value = {'id': row['id'], 'kind': row['kind'], 'sender': row['sender'], 'recipient': row['recipient'], 'taskId': row['task_id'],
                 'sentAt': row['received_at'], 'state': state, 'stateLabel': STATES.get(state, state),
                 'request': latest['request'], 'reply': latest['reply'],
                 'requestRevisionAtReceipt': seen, 'revisedAfterReceipt': seen is not None and latest['request']['revision'] > seen,
                 'events': events}
        if with_texts:
            value['texts'] = texts
        return value

    def letter(self, letter_id):
        if not isinstance(letter_id, str) or not LETTER_ID.fullmatch(letter_id):
            raise ValueError('Invalid letter ID')
        with self.transaction() as con:
            return self._letter(con, letter_id)

    def inbox(self, owner):
        """Letters to OWNER that are not yet done for it (未受領・受領・担当中), with the latest request text. Reading records
        nothing. OWNER is a self-report."""
        approvals.text(owner, 80)
        with self.transaction() as con:
            ids = [r[0] for r in con.execute('SELECT id FROM letters WHERE recipient=? ORDER BY rowid', (owner,))]
            letters = [self._letter(con, i, with_texts=False) for i in ids]
            open_ = [x for x in letters if x['state'] in OPEN_FOR_RECIPIENT]
            for x in open_:
                stop = next((e for e in reversed(x['events']) if e['event'] == 'withdrawn' and e['effective']), None) if x['state'] == 'withdrawn' else None
                x['stopRequested'] = stop is not None
                x['stopReason'] = stop['note'] if stop else None
            return {'owner': owner, 'letters': open_}

    def letters_brief(self, task=None, member=None, state=None, limit=50, cursor=None, sender=None, recipient=None):
        """H-20261019-30: the list without any text. The queries read metadata, event kinds and revision numbers only;
        no body column is selected, so a long list does not read every original text.

        H-20261019-34: one page, newest first. Letters are append-only and never deleted, so their rowid is a stable order
        (unique, also for equal times); `cursor` ('r<rowid>') continues below the last letter of the previous page, so
        letters added meanwhile neither shift nor repeat an older page. Filters are applied here, before the page is cut.
        `nextCursor` and `hasMore` say whether older matches exist. A page is not a snapshot of the whole history: a
        letter whose state changes while pages are read is seen as it is when its page is read."""
        if state is not None and state not in STATES:
            raise ValueError('Unknown state')
        limit = int(limit)
        if not 0 < limit <= 1000:
            raise ValueError('Invalid limit')
        below = None
        if cursor is not None:
            if not isinstance(cursor, str) or not re.fullmatch(r'r[1-9][0-9]{0,18}', cursor):
                raise ValueError('Invalid cursor')
            below = int(cursor[1:])
        with self.transaction() as con:
            out, next_cursor, has_more = [], None, False
            sql, args = 'SELECT rowid, id, kind, sender, recipient, task_id, received_at FROM letters', []
            where = []
            if below is not None:
                where.append('rowid < ?')
                args.append(below)
            for column, value in (('task_id', task), ('sender', sender), ('recipient', recipient)):
                if value:
                    where.append(f'{column} = ?')
                    args.append(value)
            if member:
                where.append('(sender = ? OR recipient = ?)')
                args += [member, member]
            sql += (' WHERE ' + ' AND '.join(where) if where else '') + ' ORDER BY rowid DESC'
            for row in con.execute(sql, args).fetchall():
                events = con.execute('SELECT event, actor, recorded_by, effective, note, text_sequence, received_at FROM letter_events WHERE letter_id=? ORDER BY sequence', (row['id'],)).fetchall()
                current = None
                for e in events:
                    if e['effective'] and e['event'] != 'revised':
                        current = e['event']
                if state and current != state:
                    continue
                if len(out) >= limit:
                    has_more = True
                    break
                revisions = dict(con.execute('SELECT part, MAX(revision) FROM letter_texts WHERE letter_id=? GROUP BY part', (row['id'],)).fetchall())
                received = next((e for e in events if e['event'] == 'received' and e['effective']), None)
                seen = None
                if received is not None and received['text_sequence'] is not None:
                    seen = con.execute('SELECT revision FROM letter_texts WHERE sequence=?', (received['text_sequence'],)).fetchone()[0]
                stop = next((e for e in reversed(events) if e['event'] == 'withdrawn' and e['effective']), None) if current == 'withdrawn' else None
                meta = [{'event': e['event'], 'actor': e['actor'], 'recordedBy': e['recorded_by'], 'effective': bool(e['effective']), 'at': e['received_at']} for e in events]
                out.append({'id': row['id'], 'kind': row['kind'], 'sender': row['sender'], 'recipient': row['recipient'], 'taskId': row['task_id'],
                            'sentAt': row['received_at'], 'state': current, 'stateLabel': STATES.get(current, current),
                            'requestRevision': revisions.get('request'), 'replyRevision': revisions.get('reply'),
                            'requestRevisionAtReceipt': seen, 'revisedAfterReceipt': seen is not None and revisions.get('request', 0) > seen,
                            'stopRequested': stop is not None, 'stopReason': stop['note'] if stop else None,
                            'proxyRecords': sum(1 for e in events if not e['effective']), 'lastEventAt': events[-1]['received_at'] if events else None,
                            # OPS-183/184: who did what and when (no text). A proxy record (effective false) is kept and marked, not hidden.
                            'events': meta, 'lastEvent': meta[-1] if meta else None})
                next_cursor = f'r{row["rowid"]}'
            return {'letters': out, 'brief': True, 'limit': limit, 'cursor': cursor, 'hasMore': has_more, 'nextCursor': next_cursor if has_more else None}

    def letters(self, task=None, member=None, state=None, limit=200):
        if state is not None and state not in STATES:
            raise ValueError('Unknown state')
        limit = int(limit)
        if not 0 < limit <= 1000:
            raise ValueError('Invalid limit')
        with self.transaction() as con:
            ids = [r[0] for r in con.execute('SELECT id FROM letters ORDER BY rowid DESC')]
            out = []
            for letter_id in ids:
                value = self._letter(con, letter_id)
                if task and value['taskId'] != task or member and member not in (value['sender'], value['recipient']) or state and value['state'] != state:
                    continue
                out.append(value)
                if len(out) >= limit:
                    break
            return {'letters': out}


class Store(PingMixin, LetterMixin, approvals.Store):
    """Server-side store of PING / ACK and letters, in the approvals database (案A)."""
