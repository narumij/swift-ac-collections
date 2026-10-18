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
KINDS = ('request', 'work', 'verification', 'acceptance', 'return', 'recheck', 'complete', 'awaiting-commit', 'commit')
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


def append_event(task_id, kind, owner, reason='', commit_sha='', at=None):
    event = validate_event(dict(schemaVersion=1, id=uuid.uuid4().hex, taskId=task_id, event=kind, owner=owner,
                                timestamp=at or datetime.datetime.now(datetime.timezone.utc).isoformat(timespec='seconds'),
                                reason=reason, commitSha=commit_sha))
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
    args = parser.parse_args()
    try:
        event = append_event(args.task, args.event, args.owner, args.reason, args.commit_sha, args.at)
    except (ValueError, OSError) as error:
        parser.exit(1, f'Activity not appended: {error}\n')
    print(json.dumps(event, ensure_ascii=False))


if __name__ == '__main__':
    main()
