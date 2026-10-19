#!/usr/bin/env python3
"""OPS-177 isolated copy of inbox.py (Studio edit versions) that also keeps V3 saves. Experiment only.

Copied from Maintanance/RegistryApp/inbox.py (OPS-082); the production file is unchanged. Differences:
- The folder is always explicit. There is no default Inbox and no REGISTRY_STUDIO_INBOX: this copy never touches the
  real Inbox.
- Every save has a kind, from base_of(doc):
  - legacy: no source.kind and no v3 block. Its base is today's {sha256, head, generatedAt}, unchanged.
  - v3-export: validated like studio_adapter's whole-save check. Its base is {kind, generation, revision, payloadHash,
    payloadHashOf}, with no sha256 key at all (never an empty or made-up one).
  - Anything else (an unknown kind; a v3 block without the kind; source and v3 disagreeing; a malformed value) is
    invalid. It is never read as legacy: append refuses it, and load_saves lists it as invalid (never resumed).
- A parent of another kind is refused, so no series mixes kinds. Saves are still never overwritten.
- latest(folder, kind) returns the newest valid save of that kind only. For V3 it also reports, for display:
  - unresolvedLegacy: legacy saves without an IMPORTS record. That means "not reconciled yet", not that work is needed.
  - invalid: saves that cannot be resumed.
  Nothing is converted, applied or deleted. latest(folder) without a kind answers exactly as inbox.latest.
- V3 consumption lives in the DB's operations, not in IMPORTS.jsonl (only legacy imports are recorded there).

  python3 v3_inbox.py list --folder DIR                     saves with kind, base, series and import state
  python3 v3_inbox.py record SAVE_ID --note N --folder DIR  append an import record (refuses an ID already recorded)
"""
import argparse
import datetime
import json
import re
import secrets
import sys
import threading
from pathlib import Path

IMPORTS = 'IMPORTS.jsonl'
LOCK = threading.Lock()
LEGACY, V3 = 'legacy', 'v3-export'
HEX64 = re.compile(r'[0-9a-f]{64}')


class InvalidBase(ValueError):
    """A save that is neither a legacy save nor a well-formed V3 export save."""


def base_of(doc):
    """(kind, base) of a Studio document, or InvalidBase. Never falls back to legacy for something that claims V3."""
    if not isinstance(doc, dict):
        raise InvalidBase('not a JSON object')
    source = doc.get('source')
    if source is not None and not isinstance(source, dict):
        raise InvalidBase('source is not an object')
    source = source or {}
    if 'kind' not in source and 'v3' not in doc:  # the existing legacy base, exactly as inbox.append_save writes it
        return LEGACY, dict(sha256=source.get('sha256', ''), head=source.get('head', ''), generatedAt=source.get('generatedAt', ''))
    if source.get('kind') != V3:
        raise InvalidBase(f"unknown kind {source.get('kind')!r}" if 'kind' in source else 'a v3 block without source.kind v3-export')
    v3 = doc.get('v3')
    if not isinstance(v3, dict):
        raise InvalidBase('a v3-export save without its v3 block')
    if 'sha256' in source:
        raise InvalidBase('a v3-export save has no source.sha256')
    gen, rev = source.get('generation'), source.get('revision')
    if (gen, rev) != (v3.get('generation'), v3.get('revision')):
        raise InvalidBase('source and v3 disagree on generation/revision')
    if not isinstance(gen, str) or not gen or type(rev) is not int or rev < 0:
        raise InvalidBase(f'malformed generation {gen!r} / revision {rev!r}')
    if not isinstance(source.get('payloadHash'), str) or not HEX64.fullmatch(source['payloadHash']) \
            or not isinstance(source.get('payloadHashOf'), str) or not source['payloadHashOf']:
        raise InvalidBase('malformed payloadHash / payloadHashOf')
    return V3, dict(kind=V3, generation=gen, revision=rev, payloadHash=source['payloadHash'], payloadHashOf=source['payloadHashOf'])


META = ('saveId', 'savedAt', 'series', 'parent', 'base')


def _meta(path, doc):
    """(meta, why): the save's identity, checked before any sorting or identity use. An older save without studioSave
    gets inbox's single-save series. Anything malformed gives a placeholder identity and the reason (listed, never used
    as a save or a parent)."""
    placeholder = dict(saveId=None, savedAt='', series=None, parent=None, base={})
    meta = doc.get('studioSave') if isinstance(doc, dict) else None
    if not isinstance(meta, dict):  # an older single save: its own series, no parent (as inbox.load_saves)
        stamp = doc.get('exportedAt') if isinstance(doc, dict) else None
        source = doc.get('source') if isinstance(doc, dict) else None
        if source and not isinstance(source, dict):
            return placeholder, 'source is not an object'
        if stamp and not isinstance(stamp, str):
            return placeholder, 'exportedAt is not text'
        return dict(saveId=path.stem, savedAt=stamp or '', series=path.stem, parent=None,
                    base=dict(sha256=(source or {}).get('sha256', '')) if isinstance(doc, dict) else {}), None
    if set(meta) != set(META):
        return placeholder, 'malformed studioSave: fields ' + ', '.join(sorted(set(meta) ^ set(META)))
    if not isinstance(meta['saveId'], str) or not meta['saveId'] or not isinstance(meta['savedAt'], str) or not isinstance(meta['series'], str) \
            or not meta['series'] or not (meta['parent'] is None or isinstance(meta['parent'], str) and meta['parent']) or not isinstance(meta['base'], dict):
        return placeholder, 'malformed studioSave: saveId, savedAt, series, parent or base has the wrong type'
    return dict(meta), None


def _kind(doc, meta):
    """kind of a stored save, and why it is invalid (None when valid). A V3 save must also carry its own base."""
    try:
        kind, base = base_of(doc)
    except InvalidBase as error:
        return 'invalid', str(error)
    if kind == V3 and meta.get('base') != base:
        return 'invalid', 'the stored base does not match the save'
    return kind, None


def load_saves(folder):
    """Every save in the folder, oldest first, each with its kind (inbox.load_saves plus kind/invalid). Unreadable
    files are reported, not skipped silently. Each file is checked on its own: a malformed one is listed as invalid
    (with its reason) and never breaks the others. Two files claiming one saveId are both invalid."""
    folder = Path(folder)
    saves = []
    for path in sorted(folder.glob('*.json')) if folder.exists() else []:
        try:
            doc = json.loads(path.read_text(encoding='utf-8'))
        except (OSError, UnicodeDecodeError, json.JSONDecodeError) as error:
            saves.append(dict(file=path.name, error=str(error)))
            continue
        meta, why = _meta(path, doc)
        kind, why = ('invalid', why) if why else _kind(doc, meta)
        saves.append(dict(file=path.name, **meta, doc=doc, kind=kind, **({'invalid': why} if why else {}), **({'malformedMeta': True} if meta['saveId'] is None else {})))
    claimed = [s['saveId'] for s in saves if s.get('saveId') is not None]
    for s in saves:
        if s.get('saveId') is not None and claimed.count(s['saveId']) > 1:
            s.update(kind='invalid', invalid='duplicate saveId ' + s['saveId'], duplicate=True)
    return sorted((s for s in saves if 'error' not in s), key=lambda s: (s['savedAt'], s['file'])) + [s for s in saves if 'error' in s]


def append_save(data, parent, folder):
    """Store `data` as a new save of its own kind. A parent that already has a later save (an older tab) starts a new
    series instead of overwriting history. A parent of another kind, or an invalid base, is refused. Returns the stored
    studioSave."""
    folder = Path(folder)
    kind, base = base_of(data)  # InvalidBase (a ValueError): nothing is stored
    with LOCK:
        saves = [s for s in load_saves(folder) if 'error' not in s and 'malformedMeta' not in s]
        by_id = {s['saveId']: s for s in saves}
        if parent is not None and parent not in by_id:
            raise ValueError(f'unknown parent save: {parent}')
        if parent is not None and by_id[parent]['kind'] != kind:
            raise ValueError(f"parent save {parent} is {by_id[parent]['kind']}, this save is {kind}: a series never mixes kinds")
        stale = parent is not None and any(s.get('parent') == parent for s in saves)
        now = datetime.datetime.now(datetime.timezone.utc)
        save_id = now.strftime('%Y%m%dT%H%M%S%fZ') + '-' + secrets.token_hex(4)
        series = save_id if parent is None or stale else by_id[parent]['series']
        meta = dict(saveId=save_id, savedAt=now.isoformat(), series=series, parent=parent, base=base)
        stored = dict(data, studioSave=meta)
        folder.mkdir(parents=True, exist_ok=True)
        with open(folder / f'registry-edited-{save_id}.json', 'x', encoding='utf-8') as out:  # never overwrite
            out.write(json.dumps(stored, ensure_ascii=False, indent=2) + '\n')
        return dict(meta, branched=stale)


def latest(folder, kind=None):
    """The most recent save Studio resumes. Without a kind: exactly inbox.latest (every readable save). With a kind:
    only valid saves of that kind; for V3 also the legacy saves without an IMPORTS record and the invalid saves, for
    display only."""
    saves = [s for s in load_saves(folder) if 'error' not in s]
    if kind is None:  # inbox semantics, over the saves that have a usable identity
        saves = [s for s in saves if 'malformedMeta' not in s and 'duplicate' not in s]
        if not saves:
            return None
        parents = {s.get('parent') for s in saves}
        heads = [s for s in saves if s['saveId'] not in parents]
        return dict(save=saves[-1]['doc'], heads=len(heads), saves=len(saves))
    if kind not in (LEGACY, V3):
        raise ValueError(f'unknown kind {kind!r}')
    mine = [s for s in saves if s['kind'] == kind]
    parents = {s.get('parent') for s in mine}
    out = dict(save=mine[-1]['doc'] if mine else None, heads=len([s for s in mine if s['saveId'] not in parents]), saves=len(mine),
               invalid=[dict(saveId=s['saveId'], file=s['file'], reason=s['invalid']) for s in saves if s['kind'] == 'invalid'])
    if kind == V3:
        done = {r.get('saveId') for r in imports(folder)}
        out['unresolvedLegacy'] = [dict(saveId=s['saveId'], savedAt=s['savedAt'], file=s['file']) for s in saves if s['kind'] == LEGACY and s['saveId'] not in done]
    return out


def find(folder, save_id, kind):
    """The stored save with this saveId and kind, or ValueError (unknown, another kind or invalid)."""
    for s in load_saves(folder):
        if s.get('saveId') == save_id and 'error' not in s:
            if s['kind'] != kind:
                raise ValueError(f"save {save_id} is {s['kind']}, not {kind}" + (f" ({s['invalid']})" if 'invalid' in s else ''))
            return s['doc']
    raise ValueError(f'no such save: {save_id}')


def imports(folder):
    path = Path(folder) / IMPORTS
    return [json.loads(line) for line in path.read_text(encoding='utf-8').splitlines() if line.strip()] if path.exists() else []


def record_import(save_id, note, folder):
    folder = Path(folder)
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
    ls = sub.add_parser('list')
    ls.add_argument('--folder', required=True)
    rec = sub.add_parser('record')
    rec.add_argument('save_id')
    rec.add_argument('--note', required=True)
    rec.add_argument('--folder', required=True)
    args = parser.parse_args()
    if args.command == 'list':
        done = {r['saveId'] for r in imports(args.folder)}
        for s in load_saves(args.folder):
            if 'error' in s:
                print(f"{s['file']}: unreadable ({s['error']})")
                continue
            if s['kind'] == V3:
                base, state = f"generation={s['base']['generation']} revision={s['base']['revision']}", 'V3 (reflected through DB operations)'
            elif s['kind'] == LEGACY:
                base, state = f"base={s['base'].get('sha256', '')[:12]}", 'imported' if s['saveId'] in done else 'unresolved legacy (not reconciled yet)'
            else:
                base, state = '', f"invalid ({s['invalid']})"
            print(f"{s['saveId']}  {s['kind']}  series={s['series']}  parent={s['parent']}  {base}  {state}  {s['file']}")
    else:
        try:
            print(json.dumps(record_import(args.save_id, args.note, args.folder), ensure_ascii=False))
        except ValueError as error:
            sys.exit(str(error))


if __name__ == '__main__':
    main()
