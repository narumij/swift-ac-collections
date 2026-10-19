#!/usr/bin/env python3
"""Local approval handoff. Only Astra uses add/list/claim/finish/abandon; never commits.

OPS-156: only the Studio server opens the database. The command line below talks to the server over HTTP
(studio_client) and never opens SQLite itself. If the server cannot be reached, nothing is sent; if a request was sent
but no answer came back, the result is unknown (check `list` before sending again).
"""
import argparse
import datetime
import hashlib
import hmac
import json
import os
import re
import secrets
import sqlite3
import subprocess
import uuid
from contextlib import contextmanager
from pathlib import Path, PurePosixPath

APP = Path(__file__).resolve().parent
ROOT = APP.parent.parent
# REGISTRY_STUDIO_APPROVALS_DB exists only so isolated servers and tests use their own file.
DATABASE = Path(os.environ['REGISTRY_STUDIO_APPROVALS_DB']) if os.environ.get('REGISTRY_STUDIO_APPROVALS_DB') else APP / 'Approvals' / 'approvals.sqlite3'
POLICY_NOTICE = '規則反映前はAstraが会話で直前承認を確認します'
FIELDS = ('taskId', 'title', 'scope', 'paths', 'condition', 'branch')


class Conflict(ValueError):
    pass


def text(value, limit=16000):
    if not isinstance(value, str) or not value.strip() or len(value) > limit or '\x00' in value:
        raise ValueError('Expected nonempty text within size limit')
    return value


def validate_card(card):
    if not isinstance(card, dict) or set(card) != set(FIELDS):
        raise ValueError('Expected taskId, title, scope, paths, condition, branch')
    for name in FIELDS:
        if name != 'paths':
            text(card[name])
    if not re.fullmatch(r'[A-Z][A-Z0-9]*-[0-9]+', card['taskId']):
        raise ValueError('Invalid task ID')
    paths = card['paths']
    if not isinstance(paths, list) or not paths or len(paths) > 1000:
        raise ValueError('Expected explicit repository-relative paths')
    for path in paths:
        text(path, 4096)
        p = PurePosixPath(path)
        if not p.parts or p.is_absolute() or '..' in p.parts or path != p.as_posix() or any(c in path for c in '*?[]\\\n\r') or p.parts[0] == '.git':
            raise ValueError('Paths must be canonical, explicit repository-relative paths')
    if len(set(paths)) != len(paths):
        raise ValueError('Duplicate path')
    return card


# OPS-156 (案A): the operation, communication and meta tables live in the same SQLite file as the approvals, so an
# approval change and its operation record are written in one transaction. Every table here is append-only.
STUDIO_SCHEMA = (
    'CREATE TABLE IF NOT EXISTS operations (id TEXT PRIMARY KEY, kind TEXT NOT NULL, payload_sha256 TEXT NOT NULL, actor TEXT NOT NULL, '
    'recorded_by TEXT NOT NULL, received_at TEXT NOT NULL, status TEXT NOT NULL, result TEXT NOT NULL)',
    'CREATE TABLE IF NOT EXISTS messages (id TEXT PRIMARY KEY, kind TEXT NOT NULL, target TEXT NOT NULL, task_id TEXT NOT NULL, '
    'sender TEXT NOT NULL, operation_id TEXT NOT NULL REFERENCES operations(id), received_at TEXT NOT NULL)',
    'CREATE TABLE IF NOT EXISTS acks (sequence INTEGER PRIMARY KEY AUTOINCREMENT, message_id TEXT NOT NULL REFERENCES messages(id), '
    'owner TEXT NOT NULL, recorded_by TEXT NOT NULL, claimed_at TEXT, received_at TEXT NOT NULL, status TEXT NOT NULL)',
    'CREATE TABLE IF NOT EXISTS meta (key TEXT PRIMARY KEY, value TEXT NOT NULL, recorded_at TEXT NOT NULL)',
    # H-20261019-25: letters (requests between members). The original texts and their revisions, and the events that are
    # the activity record of these letters (not copied to the activity jsonl).
    'CREATE TABLE IF NOT EXISTS letters (id TEXT PRIMARY KEY, kind TEXT NOT NULL, sender TEXT NOT NULL, recipient TEXT NOT NULL, '
    'task_id TEXT NOT NULL, operation_id TEXT NOT NULL REFERENCES operations(id), received_at TEXT NOT NULL)',
    'CREATE TABLE IF NOT EXISTS letter_texts (sequence INTEGER PRIMARY KEY AUTOINCREMENT, letter_id TEXT NOT NULL REFERENCES letters(id), '
    'part TEXT NOT NULL, revision INTEGER NOT NULL, body TEXT NOT NULL, reason TEXT NOT NULL, ref_doc TEXT, ref_section TEXT, '
    'recorded_by TEXT NOT NULL, received_at TEXT NOT NULL, operation_id TEXT NOT NULL REFERENCES operations(id), UNIQUE (letter_id, part, revision))',
    'CREATE TABLE IF NOT EXISTS letter_events (sequence INTEGER PRIMARY KEY AUTOINCREMENT, letter_id TEXT NOT NULL REFERENCES letters(id), '
    'event TEXT NOT NULL, actor TEXT NOT NULL, recorded_by TEXT NOT NULL, claimed_at TEXT, received_at TEXT NOT NULL, '
    'text_sequence INTEGER REFERENCES letter_texts(sequence), note TEXT NOT NULL, effective INTEGER NOT NULL, operation_id TEXT NOT NULL REFERENCES operations(id))',
)
OPERATION_ID = re.compile(r'[0-9a-f]{32}')


def payload_sha256(value):
    return hashlib.sha256(json.dumps(value, ensure_ascii=False, sort_keys=True, separators=(',', ':')).encode()).hexdigest()


def now():
    return datetime.datetime.now(datetime.timezone.utc).isoformat(timespec='microseconds').replace('+00:00', 'Z')


class Store:
    def __init__(self, database=DATABASE, root=ROOT):
        self.database, self.root = Path(database), Path(root).resolve()

    @contextmanager
    def transaction(self):
        self.database.parent.mkdir(parents=True, exist_ok=True)
        con = sqlite3.connect(self.database, timeout=10, isolation_level=None)
        con.row_factory = sqlite3.Row
        try:
            con.execute('PRAGMA foreign_keys=ON')
            con.execute('BEGIN IMMEDIATE')
            con.execute('CREATE TABLE IF NOT EXISTS requests (id TEXT PRIMARY KEY, card TEXT NOT NULL, state TEXT NOT NULL, token_hash TEXT)')
            con.execute('CREATE TABLE IF NOT EXISTS history (sequence INTEGER PRIMARY KEY AUTOINCREMENT, request_id TEXT NOT NULL REFERENCES requests(id), event TEXT NOT NULL)')
            con.execute("CREATE TRIGGER IF NOT EXISTS immutable_card BEFORE UPDATE OF card ON requests BEGIN SELECT RAISE(ABORT, 'immutable request'); END")
            con.execute("CREATE TRIGGER IF NOT EXISTS retain_requests BEFORE DELETE ON requests BEGIN SELECT RAISE(ABORT, 'retain request'); END")
            for operation in ('UPDATE', 'DELETE'):
                con.execute(f"CREATE TRIGGER IF NOT EXISTS retain_history_{operation} BEFORE {operation} ON history BEGIN SELECT RAISE(ABORT, 'append-only history'); END")
            for statement in STUDIO_SCHEMA:
                con.execute(statement)
            for table in ('operations', 'messages', 'acks', 'meta', 'letters', 'letter_texts', 'letter_events'):
                for operation in ('UPDATE', 'DELETE'):
                    con.execute(f"CREATE TRIGGER IF NOT EXISTS retain_{table}_{operation} BEFORE {operation} ON {table} BEGIN SELECT RAISE(ABORT, 'append-only {table}'); END")
            yield con
            con.execute('COMMIT')
        except BaseException:
            if con.in_transaction:
                con.execute('ROLLBACK')
            raise
        finally:
            con.close()

    def _list(self, con):
        requests = []
        for row in con.execute('SELECT * FROM requests ORDER BY rowid'):
            item = json.loads(row['card']) | json.loads(row['state']) | {'id': row['id']}
            item['history'] = [json.loads(h[0]) for h in con.execute('SELECT event FROM history WHERE request_id=? ORDER BY sequence', (row['id'],))]
            requests.append(item)
        return {'requests': requests, 'policyNotice': POLICY_NOTICE}

    def list(self):
        with self.transaction() as con:
            return self._list(con)

    def _row(self, con, identity):
        text(identity, 100)
        row = con.execute('SELECT * FROM requests WHERE id=?', (identity,)).fetchone()
        if row is None:
            raise Conflict('Unknown request')
        return row, json.loads(row['card']), json.loads(row['state'])

    def _save(self, con, identity, state, action, details=None, token_hash=None):
        state['revision'] += 1
        state['updatedAt'] = now()
        event = {'action': action, 'at': state['updatedAt'], 'revision': state['revision']} | (details or {})
        con.execute('UPDATE requests SET state=?,token_hash=? WHERE id=?', (json.dumps(state), token_hash, identity))
        con.execute('INSERT INTO history(request_id,event) VALUES (?,?)', (identity, json.dumps(event)))

    def add(self, card):
        validate_card(card)
        for path in card['paths']:
            target = self.root / path
            if any(part.is_symlink() for part in (target, *target.parents)):
                raise ValueError('Symlink paths are not supported')
        identity, at = uuid.uuid4().hex, now()
        state = {'revision': 1, 'status': 'pending', 'createdAt': at, 'updatedAt': at, 'approvedAt': None, 'commitSha': None}
        with self.transaction() as con:
            con.execute('INSERT INTO requests VALUES (?,?,?,NULL)', (identity, json.dumps(card), json.dumps(state)))
            con.execute('INSERT INTO history(request_id,event) VALUES (?,?)', (identity, json.dumps({'action': 'add', 'at': at, 'revision': 1, 'content': card})))
        return {'id': identity} | card | state

    def _operation(self, con, operation_id, kind, payload):
        """An existing operation with this ID: its stored result for the same content, Conflict for different content."""
        row = con.execute('SELECT * FROM operations WHERE id=?', (operation_id,)).fetchone()
        if row is None:
            return None
        if row['kind'] != kind or row['payload_sha256'] != payload_sha256(payload):
            raise Conflict('Operation ID already used with different content')
        return dict(row) | {'result': json.loads(row['result'])}

    def _record_operation(self, con, operation_id, kind, payload, actor, status, result):
        con.execute('INSERT INTO operations VALUES (?,?,?,?,?,?,?,?)', (operation_id, kind, payload_sha256(payload), actor, actor, now(), status, json.dumps(result, ensure_ascii=False)))

    def operations(self, limit=200):
        with self.transaction() as con:
            rows = con.execute('SELECT * FROM operations ORDER BY rowid DESC LIMIT ?', (int(limit),)).fetchall()
            return {'operations': [dict(r) | {'result': json.loads(r['result'])} for r in rows]}

    def mutate(self, body):
        """Approve or cancel the listed requests, all or nothing. OPS-156: each call is one operation (operationId from the
        client, or a new one). The same ID with the same content returns the recorded result without applying again; with
        different content it is refused. A refused change is recorded too, with the request that did not match."""
        if not isinstance(body, dict) or not {'action', 'targets'} <= set(body) <= {'action', 'targets', 'operationId'} or body['action'] not in ('approve', 'cancel'):
            raise ValueError('Expected approve/cancel and targets')
        operation_id = body.get('operationId', uuid.uuid4().hex)
        if not isinstance(operation_id, str) or not OPERATION_ID.fullmatch(operation_id):
            raise ValueError('Invalid operation ID')
        targets = body['targets']
        if not isinstance(targets, list) or len(targets) > 1000:
            raise ValueError('Invalid targets')
        seen = set()
        for target in targets:
            if not isinstance(target, dict) or set(target) != {'id', 'revision'} or type(target['revision']) is not int or target['revision'] < 1:
                raise ValueError('Invalid target')
            text(target['id'], 100)
            if target['id'] in seen:
                raise ValueError('Duplicate target')
            seen.add(target['id'])
        payload, refused = {'action': body['action'], 'targets': targets}, None
        with self.transaction() as con:
            done = self._operation(con, operation_id, body['action'], payload)
            if done is not None:
                if done['status'] == 'refused':
                    refused = done['result']['reason']
                else:
                    return self._list(con) | {'operation': {'id': operation_id, 'status': done['status'], 'replayed': True, **done['result']}}
            else:
                allowed = ('pending',) if body['action'] == 'approve' else ('pending', 'approved')
                checked = []
                for target in targets:
                    try:
                        row, card, state = self._row(con, target['id'])
                    except Conflict:
                        refused = {'id': target['id'], 'reason': 'Unknown request'}
                        break
                    if state['revision'] != target['revision'] or state['status'] not in allowed:
                        refused = {'id': target['id'], 'reason': 'Request changed; refresh the displayed cards', 'revision': state['revision'], 'status': state['status']}
                        break
                    checked.append((row, card, state))
                ids = [t['id'] for t in targets]
                if refused:
                    self._record_operation(con, operation_id, body['action'], payload, 'ユーザー', 'refused', {'targets': ids, 'changed': [], 'reason': refused})
                else:
                    for row, card, state in checked:
                        state['status'] = 'approved' if body['action'] == 'approve' else 'cancelled'
                        details = {'operationId': operation_id}
                        if body['action'] == 'approve':
                            state['approvedAt'] = now()
                            details['content'] = card
                        self._save(con, row['id'], state, body['action'], details)
                    self._record_operation(con, operation_id, body['action'], payload, 'ユーザー', 'applied', {'targets': ids, 'changed': ids})
                    return self._list(con) | {'operation': {'id': operation_id, 'status': 'applied', 'replayed': False, 'targets': ids, 'changed': ids}}
        # recorded and committed; the change itself was not made
        raise Conflict('Request changed; refresh the displayed cards' if refused.get('reason') != 'Unknown request' else 'Unknown request')

    def _git(self, *args, raw=False):
        result = subprocess.run(['git', *args], cwd=self.root, check=True, capture_output=True, text=True, timeout=5)
        return result.stdout if raw else result.stdout.strip()

    def _context(self, repo, branch):
        if Path(text(repo, 4096)).resolve() != self.root or self._git('rev-parse', '--show-toplevel') != str(self.root):
            raise Conflict('Repository does not match the fixed checkout')
        if self._git('symbolic-ref', '--quiet', '--short', 'HEAD') != branch:
            raise Conflict('Actual checkout branch does not match')

    def claim(self, identity, repo, branch, acceptance_ref):
        text(acceptance_ref, 4096)
        with self.transaction() as con:
            row, card, state = self._row(con, identity)
            if state['status'] != 'approved' or card['branch'] != branch:
                raise Conflict('Approved request and branch required')
            self._context(repo, branch)
            if any(json.loads(r[0])['status'] == 'claimed' for r in con.execute('SELECT state FROM requests')):
                raise Conflict('Another request already holds this checkout')
            token = secrets.token_urlsafe(32)
            state.update(status='claimed', claimedAt=now(), acceptanceRef=acceptance_ref, claimHead=self._git('rev-parse', 'HEAD'), repo=str(self.root))
            self._save(con, identity, state, 'claim', {'acceptanceRef': acceptance_ref, 'head': state['claimHead'], 'repo': str(self.root), 'branch': branch}, hashlib.sha256(token.encode()).hexdigest())
            return {'id': identity, 'token': token, 'status': 'claimed', 'revision': state['revision']}

    def _claimed(self, con, identity, token):
        text(token, 256)
        row, card, state = self._row(con, identity)
        if state['status'] != 'claimed' or not row['token_hash'] or not hmac.compare_digest(row['token_hash'], hashlib.sha256(token.encode()).hexdigest()):
            raise Conflict('Active claim token required')
        return card, state

    def finish(self, identity, token, sha):
        if not isinstance(sha, str) or not re.fullmatch(r'[0-9a-f]{40}', sha):
            raise ValueError('Full commit SHA required')
        with self.transaction() as con:
            card, state = self._claimed(con, identity, token)
            self._context(state['repo'], card['branch'])
            actual = self._git('show', '-s', '--format=%H %P', sha, '--').split()
            if actual != [sha, state['claimHead']] or self._git('rev-parse', 'HEAD') != sha:
                raise Conflict('Expected one new commit on the claimed branch HEAD')
            paths = self._git('diff-tree', '--no-commit-id', '--name-only', '--no-renames', '-r', '-z', sha, '--', raw=True).split('\0')[:-1]
            if not paths or not set(paths).issubset(card['paths']):
                raise Conflict('Commit changes files outside approved paths')
            state.update(status='consumed', commitSha=sha, consumedAt=now())
            self._save(con, identity, state, 'finish', {'commitSha': sha})
            return {'id': identity, 'status': state['status'], 'commitSha': sha}

    def abandon(self, identity, token, reason):
        text(reason, 4096)
        with self.transaction() as con:
            card, state = self._claimed(con, identity, token)
            state['status'] = 'cancelled'
            self._save(con, identity, state, 'abandon', {'reason': reason})
            return {'id': identity, 'status': state['status']}


def main():
    """The command line goes through the Studio server (OPS-156): the same arguments and printed JSON as before, but no
    direct database access. Errors are printed and exit 1, saying whether nothing was sent or the result is unknown."""
    import studio_client
    parser = argparse.ArgumentParser(description=__doc__)
    commands = parser.add_subparsers(dest='command', required=True)
    add = commands.add_parser('add')
    for name in ('task-id', 'title', 'scope', 'condition', 'branch'):
        add.add_argument('--' + name, required=True)
    add.add_argument('--path', dest='paths', action='append', required=True)
    commands.add_parser('list')
    for name in ('claim', 'finish', 'abandon'):
        cmd = commands.add_parser(name)
        cmd.add_argument('id')
        for option in {'claim': ('repo', 'branch', 'acceptance-ref'), 'finish': ('token', 'sha'), 'abandon': ('token', 'reason')}[name]:
            cmd.add_argument('--' + option, required=True)
    args = vars(parser.parse_args())
    command = args.pop('command')
    if command == 'add':
        args['taskId'] = args.pop('task_id')
    elif command != 'list':
        args['identity'] = args.pop('id')
    try:
        result = studio_client.post('/approvals-cli', 'approvals-cli', {'command': command, 'args': args})
    except studio_client.StudioError as error:
        parser.exit(1, f'{error}\n')
    print(json.dumps(result, ensure_ascii=False, indent=2))


# Server side of the command line: the commands and argument names it accepts, mapped to Store methods.
CLI_COMMANDS = {'add': set(FIELDS), 'list': set(), 'claim': {'identity', 'repo', 'branch', 'acceptance_ref'},
                'finish': {'identity', 'token', 'sha'}, 'abandon': {'identity', 'token', 'reason'}}


def run_cli_command(store, body):
    if not isinstance(body, dict) or set(body) != {'command', 'args'} or body['command'] not in CLI_COMMANDS or not isinstance(body['args'], dict):
        raise ValueError('Expected command and args')
    command, args = body['command'], body['args']
    if set(args) != CLI_COMMANDS[command]:
        raise ValueError('Unexpected arguments')
    if command == 'add':
        return store.add(args)
    if command == 'list':
        return store.list()
    return getattr(store, command)(**args)


if __name__ == '__main__':
    main()
