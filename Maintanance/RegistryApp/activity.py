#!/usr/bin/env python3
"""Append-only local activity records. Advisory history, never Registry authority."""
import argparse
import datetime
import fcntl
import json
import os
from pathlib import Path
import re
import uuid

EVENTS = Path(__file__).resolve().parent / 'Activity' / 'events.jsonl'
ROOT = Path(__file__).resolve().parents[2]  # repository root; --doc paths are relative to it (OPS-129)
KINDS = ('request', 'work', 'verification', 'acceptance', 'return', 'recheck', 'complete', 'awaiting-commit', 'commit')
# OPS-127: optional handoff fields. next = who picks the task up next (an owner name, 'user', or 'none' = this work is
# finished); presence = the owner's own state for the Studio lamp. Older records without them stay valid.
PRESENCE = ('waiting', 'ended')
MAX_LINE = 4096


def text(value, limit, required=True):
    if not isinstance(value, str) or len(value) > limit or (required and not value.strip()) or re.search(r'[\x00-\x1f\x7f]', value):
        raise ValueError('Invalid activity text')
    return value


def timestamp(value):
    text(value, 40)
    if not re.fullmatch(r'\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.\d{1,3})?(?:Z|[+-]\d{2}:\d{2})', value):
        raise ValueError('Timestamp requires seconds and timezone')
    datetime.datetime.fromisoformat(value.replace('Z', '+00:00'))
    return value


def validate_event(value):
    if not isinstance(value, dict) or type(value.get('schemaVersion')) is not int or value['schemaVersion'] != 1:
        raise ValueError('Invalid activity version')
    event = {'schemaVersion': 1, 'id': text(value.get('id'), 36), 'taskId': text(value.get('taskId'), 40),
             'event': text(value.get('event'), 24), 'owner': text(value.get('owner'), 80),
             'timestamp': timestamp(value.get('timestamp')), 'reason': text(value.get('reason', ''), 240, False),
             'commitSha': text(value.get('commitSha', ''), 40, False)}
    if not re.fullmatch(r'[a-f0-9]{32}', event['id']) or not re.fullmatch(r'[A-Z][A-Z0-9]*-[0-9]+', event['taskId']) or event['event'] not in KINDS:
        raise ValueError('Invalid activity identity or event')
    if event['commitSha'] and not re.fullmatch(r'[a-f0-9]{40}', event['commitSha']):
        raise ValueError('Commit SHA requires 40 lowercase hex digits')
    if value.get('next') not in (None, ''):
        event['next'] = text(value['next'], 80)
    if value.get('ref') is not None:
        ref = value['ref']
        if not isinstance(ref, dict):
            raise ValueError('Invalid activity reference')
        event['ref'] = {'path': text(ref.get('path'), 300), 'section': text(ref.get('section'), 120)}
    if value.get('presence') not in (None, ''):
        if value['presence'] not in PRESENCE:
            raise ValueError('Invalid activity presence')
        event['presence'] = value['presence']
    return event


def read_events():
    """Bounded tail read; retain append order, including repeated trips."""
    try:
        with EVENTS.open('rb') as stream:
            fcntl.flock(stream, fcntl.LOCK_SH)
            stream.seek(0, 2)
            end = stream.tell()
            stream.seek(max(0, end - (201 * MAX_LINE)))
            start = stream.tell()
            raw = stream.read()
    except FileNotFoundError:
        return []
    if start:
        raw = raw.partition(b'\n')[2]
    lines = raw.splitlines()[-200:]
    result = []
    for line in lines:
        if len(line) > MAX_LINE:
            raise ValueError('Activity line too large')
        result.append(validate_event(json.loads(line.decode('utf-8'))))
    if len({event['id'] for event in result}) != len(result):
        raise ValueError('Duplicate activity identity')
    return result


HEADING = re.compile(r'^ {0,3}(#{1,6})[ \t]+(.*?)(?:[ \t]+#+)?[ \t]*$')
FENCE = re.compile(r'^ {0,3}(`{3,}|~{3,})(.*)$')


def check_ref(doc, section):
    """OPS-129: confirm, at send time only, that DOC (repo-root relative) has exactly one heading SECTION outside code
    blocks and that its body (up to the next heading of the same or a shallower level) is not empty. Content is judged
    at acceptance, not here. Returns the reference to store."""
    text(doc, 300)
    text(section, 120)
    if Path(doc).is_absolute():
        raise ValueError('--doc must be relative to the repository root')
    root = ROOT.resolve()
    path = (root / doc).resolve()
    try:
        relative = path.relative_to(root)
    except ValueError:
        raise ValueError('--doc is outside the repository') from None
    if not path.is_file():
        raise ValueError(f'--doc not found: {relative.as_posix()}')
    lines = path.read_text(encoding='utf-8').splitlines()
    headings, fence = [], None
    for index, line in enumerate(lines):
        mark = FENCE.match(line)
        if mark:
            # a fence closes only on the same character, at least as long, followed by nothing but spaces
            if fence is None:
                fence = mark.group(1)
            elif mark.group(1)[0] == fence[0] and len(mark.group(1)) >= len(fence) and not mark.group(2).strip():
                fence = None
            continue
        if fence is None:
            found = HEADING.match(line)
            if found:
                headings.append((index, len(found.group(1)), found.group(2)))
    hits = [h for h in headings if h[2] == section]
    if not hits:
        names = ', '.join(h[2] for h in headings[-10:])
        raise ValueError(f'--section not found: {section!r}. Headings: {names}')
    if len(hits) > 1:
        raise ValueError(f'--section is not unique: {section!r} appears {len(hits)} times')
    start, level, _ = hits[0]
    end = next((h[0] for h in headings if h[0] > start and h[1] <= level), len(lines))
    if not '\n'.join(lines[start + 1:end]).strip():
        raise ValueError(f'--section is empty: {section!r}')
    return {'path': relative.as_posix(), 'section': section}


def append_event(task_id, kind, owner, reason='', commit_sha='', at=None, next_owner='', presence='', ref=None):
    event = validate_event(dict(schemaVersion=1, id=uuid.uuid4().hex, taskId=task_id, event=kind, owner=owner,
                                timestamp=at or datetime.datetime.now(datetime.timezone.utc).isoformat(timespec='seconds'),
                                reason=reason, commitSha=commit_sha, next=next_owner, presence=presence, ref=ref))
    raw = (json.dumps(event, ensure_ascii=False) + '\n').encode('utf-8')
    if len(raw) > MAX_LINE:
        raise ValueError('Activity line too large')
    EVENTS.parent.mkdir(parents=True, exist_ok=True)
    with EVENTS.open('a+b') as stream:
        fcntl.flock(stream, fcntl.LOCK_EX)
        stream.seek(0, 2)
        if stream.tell():
            stream.seek(-1, 2)
            if stream.read(1) != b'\n':
                raise ValueError('Incomplete final record; preserve it and investigate before appending')
        stream.write(raw)
        stream.flush()
        os.fsync(stream.fileno())
    return event


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--task', required=True)
    parser.add_argument('--event', required=True, choices=KINDS)
    parser.add_argument('--owner', required=True)
    parser.add_argument('--reason', default='')
    parser.add_argument('--commit', default='', dest='commit_sha')
    parser.add_argument('--at', help='Actual occurrence time, with seconds and timezone; default now')
    parser.add_argument('--next', default='', dest='next_owner', help="Who picks this task up next: an owner name, 'user', or 'none' (this work is finished)")
    parser.add_argument('--presence', default='', choices=('',) + PRESENCE, help="The owner's own state for the Studio lamp")
    parser.add_argument('--doc', default='', help='return only: canonical document, relative to the repository root (needs --section and --next)')
    parser.add_argument('--section', default='', help='return only: exact heading of the Return section in --doc')
    args = parser.parse_args()
    ref = None
    if args.doc or args.section:
        if args.event != 'return':
            parser.exit(1, 'Activity not appended: --doc/--section are for --event return only\n')
        if not (args.doc and args.section and args.next_owner):
            parser.exit(1, 'Activity not appended: --doc, --section and --next are all required together\n')
    try:
        if args.doc:
            ref = check_ref(args.doc, args.section)
        event = append_event(args.task, args.event, args.owner, args.reason, args.commit_sha, args.at, args.next_owner, args.presence, ref)
    except (ValueError, OSError) as error:
        parser.exit(1, f'Activity not appended: {error}\n')
    print(json.dumps(event, ensure_ascii=False))


if __name__ == '__main__':
    main()
