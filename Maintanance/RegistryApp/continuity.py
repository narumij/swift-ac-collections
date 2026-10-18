#!/usr/bin/env python3
"""One-shot continuity marks (OPS-139). Each owner writes its own latest mark — `alive` at milestones of a running turn
and before/after waiting, `ended` when it stops on purpose — into one fixed file. Studio shows the age of the mark; an
old mark means only "the confirmations stopped", never that the owner has stopped. Do not run this from a background
job or timer: a mark must come from the owner's own turn, otherwise it would keep reporting after the turn has ended."""
import argparse
import datetime
import fcntl
import json
import os
from pathlib import Path
import re
import tempfile

RECORD = Path(__file__).resolve().parent / 'Activity' / 'continuity.json'
STATES = ('alive', 'ended')
MAX_OWNERS = 16
MAX_BYTES = 16 * 1024


def text(value, limit):
    if not isinstance(value, str) or not value.strip() or len(value) > limit or re.search(r'[\x00-\x1f\x7f]', value):
        raise ValueError('Invalid continuity text')
    return value


def timestamp(value):
    text(value, 40)
    if not re.fullmatch(r'\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.\d{1,6})?(?:Z|[+-]\d{2}:\d{2})', value):
        raise ValueError('Continuity time requires seconds and timezone')
    datetime.datetime.fromisoformat(value.replace('Z', '+00:00'))
    return value


def validate(data):
    if not isinstance(data, dict) or data.get('schemaVersion') != 1 or not isinstance(data.get('owners'), dict):
        raise ValueError('Invalid continuity record')
    if len(data['owners']) > MAX_OWNERS:
        raise ValueError('Too many continuity owners')
    owners = {}
    for owner, mark in data['owners'].items():
        if not isinstance(mark, dict) or mark.get('state') not in STATES:
            raise ValueError('Invalid continuity mark')
        owners[text(owner, 80)] = {'state': mark['state'], 'at': timestamp(mark.get('at'))}
    return {'schemaVersion': 1, 'owners': owners}


def read():
    """The whole bounded record; an absent file is an empty record (nobody has written yet)."""
    try:
        with RECORD.open('rb') as stream:
            fcntl.flock(stream, fcntl.LOCK_SH)
            raw = stream.read(MAX_BYTES + 1)
    except FileNotFoundError:
        return {'schemaVersion': 1, 'owners': {}}
    if len(raw) > MAX_BYTES:
        raise ValueError('Continuity record too large')
    return validate(json.loads(raw.decode('utf-8')))


def mark(owner, state, at=None):
    """Replace this owner's mark only; other owners' marks are kept as they are."""
    if state not in STATES:
        raise ValueError('Invalid continuity state')
    entry = {'state': state, 'at': timestamp(at or datetime.datetime.now(datetime.timezone.utc).isoformat(timespec='seconds'))}
    text(owner, 80)
    RECORD.parent.mkdir(parents=True, exist_ok=True)
    with (RECORD.parent / '.continuity.lock').open('a') as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        data = read()
        data['owners'][owner] = entry
        data = validate(data)
        raw = (json.dumps(data, ensure_ascii=False, sort_keys=True) + '\n').encode('utf-8')
        if len(raw) > MAX_BYTES:
            raise ValueError('Continuity record too large')
        fd, temp = tempfile.mkstemp(dir=RECORD.parent, prefix='.continuity-')
        try:
            with os.fdopen(fd, 'wb') as stream:
                stream.write(raw)
                stream.flush()
                os.fsync(stream.fileno())
            os.replace(temp, RECORD)
        except BaseException:
            Path(temp).unlink(missing_ok=True)
            raise
    return entry


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--owner', required=True)
    parser.add_argument('--state', required=True, choices=STATES)
    parser.add_argument('--at', help='Actual time, with seconds and timezone; default now')
    args = parser.parse_args()
    try:
        entry = mark(args.owner, args.state, args.at)
    except (ValueError, OSError) as error:
        parser.exit(1, f'Continuity not written: {error}\n')
    print(json.dumps({args.owner: entry}, ensure_ascii=False))


if __name__ == '__main__':
    main()
