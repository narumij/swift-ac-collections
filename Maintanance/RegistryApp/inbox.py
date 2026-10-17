#!/usr/bin/env python3
"""Studio edit versions kept in Inbox/ (OPS-082 trial).

Each save is one JSON file, never overwritten or deleted: the whole edited Studio document (its source/baseline is the
base it was edited on) plus `studioSave` = {saveId, savedAt, series, parent, base}. Saves without `studioSave` (older
OPS-082 saves) are read as single-save series. Import records go to Inbox/IMPORTS.jsonl, separate from the saves.

  python3 inbox.py list                      saves, series, parent, base and whether imported
  python3 inbox.py record SAVE_ID --note N   append an import record (refuses an ID already recorded)
REGISTRY_STUDIO_INBOX overrides the folder (tests only).
"""
import argparse
import datetime
import json
import os
import secrets
import sys
import threading
from pathlib import Path

APP = Path(__file__).resolve().parent
INBOX = Path(os.environ.get('REGISTRY_STUDIO_INBOX', APP / 'Inbox'))
IMPORTS = 'IMPORTS.jsonl'
LOCK = threading.Lock()


def load_saves(folder=None):
    """Every save in the folder, oldest first. Unreadable files are reported, not skipped silently."""
    folder = Path(folder or INBOX)
    saves = []
    for path in sorted(folder.glob('*.json')) if folder.exists() else []:
        try:
            doc = json.loads(path.read_text(encoding='utf-8'))
        except (OSError, UnicodeDecodeError, json.JSONDecodeError) as error:
            saves.append(dict(file=path.name, error=str(error)))
            continue
        meta = doc.get('studioSave') if isinstance(doc, dict) else None
        if not isinstance(meta, dict):  # an older single save: its own series, no parent
            stamp = doc.get('exportedAt') if isinstance(doc, dict) else None
            meta = dict(saveId=path.stem, savedAt=stamp or '', series=path.stem, parent=None,
                        base=dict(sha256=(doc.get('source') or {}).get('sha256', '')) if isinstance(doc, dict) else {})
        saves.append(dict(file=path.name, **meta, doc=doc))
    return sorted((s for s in saves if 'error' not in s), key=lambda s: (s['savedAt'], s['file'])) + [s for s in saves if 'error' in s]


def append_save(data, parent, folder=None):
    """Store `data` as a new save. A parent that already has a later save (an older tab) starts a new series instead
    of overwriting history, so a newer edit is never rolled back silently. Returns the stored studioSave."""
    folder = Path(folder or INBOX)
    with LOCK:
        saves = [s for s in load_saves(folder) if 'error' not in s]
        by_id = {s['saveId']: s for s in saves}
        if parent is not None and parent not in by_id:
            raise ValueError(f'unknown parent save: {parent}')
        stale = parent is not None and any(s.get('parent') == parent for s in saves)
        now = datetime.datetime.now(datetime.timezone.utc)
        save_id = now.strftime('%Y%m%dT%H%M%S%fZ') + '-' + secrets.token_hex(4)
        series = save_id if parent is None or stale else by_id[parent]['series']
        source = data.get('source') or {}
        meta = dict(saveId=save_id, savedAt=now.isoformat(), series=series, parent=parent,
                    base=dict(sha256=source.get('sha256', ''), head=source.get('head', ''), generatedAt=source.get('generatedAt', '')))
        stored = dict(data, studioSave=meta)
        folder.mkdir(parents=True, exist_ok=True)
        with open(folder / f'registry-edited-{save_id}.json', 'x', encoding='utf-8') as out:  # never overwrite
            out.write(json.dumps(stored, ensure_ascii=False, indent=2) + '\n')
        return dict(meta, branched=stale)


def latest(folder=None):
    """The most recent save (what Studio resumes), with how many series heads exist."""
    saves = [s for s in load_saves(folder) if 'error' not in s]
    if not saves:
        return None
    parents = {s.get('parent') for s in saves}
    heads = [s for s in saves if s['saveId'] not in parents]
    return dict(save=saves[-1]['doc'], heads=len(heads), saves=len(saves))


def imports(folder=None):
    path = Path(folder or INBOX) / IMPORTS
    return [json.loads(line) for line in path.read_text(encoding='utf-8').splitlines() if line.strip()] if path.exists() else []


def record_import(save_id, note, folder=None):
    folder = Path(folder or INBOX)
    with LOCK:
        if not any(s.get('saveId') == save_id for s in load_saves(folder)):
            raise ValueError(f'no such save: {save_id}')
        if any(r.get('saveId') == save_id for r in imports(folder)):
            raise ValueError(f'already recorded: {save_id}')
        entry = dict(saveId=save_id, recordedAt=datetime.datetime.now(datetime.timezone.utc).isoformat(), note=note)
        with open(folder / IMPORTS, 'a', encoding='utf-8') as out:
            out.write(json.dumps(entry, ensure_ascii=False) + '\n')
        return entry


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = parser.add_subparsers(dest='command', required=True)
    sub.add_parser('list')
    rec = sub.add_parser('record')
    rec.add_argument('save_id')
    rec.add_argument('--note', required=True)
    args = parser.parse_args()
    if args.command == 'list':
        done = {r['saveId'] for r in imports()}
        for s in load_saves():
            if 'error' in s:
                print(f"{s['file']}: unreadable ({s['error']})")
                continue
            print(f"{s['saveId']}  series={s['series']}  parent={s['parent']}  base={s['base'].get('sha256', '')[:12]}"
                  f"  {'imported' if s['saveId'] in done else 'not imported'}  {s['file']}")
    else:
        try:
            print(json.dumps(record_import(args.save_id, args.note), ensure_ascii=False))
        except ValueError as error:
            sys.exit(str(error))


if __name__ == '__main__':
    main()
