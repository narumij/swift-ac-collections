#!/usr/bin/env python3
"""OPS-174 thin CLI over the ACCEPTED V3 experiment operations. Experiment only; no production DB, server or views.

Every input is explicit: the DB path, the operation ID, and JSON requests that already carry generation, actor and
evidence; save groups take an explicit selection, resolutions and ancestry. The CLI infers nothing (no IDs, generation,
authority, resolutions or ancestry) and never invents a new operation ID: after an unknown response, run the same
command again (same --op), which replays. The DB must already exist and be a V3 experiment DB; a mistyped path is
never created.

  read          --db PATH [--scope current|all]          registry_v3_read.read
  export        --db PATH                                 studio_adapter.export_doc
  operation     --db PATH --op ID                         registry_v3_write.operation (the stored record)
  apply         --db PATH --op ID --request FILE|-        registry_v3_write.apply
  plan-groups   --db PATH --save FILE|-                   studio_adapter.plan_groups (read-only)
  apply-groups  --db PATH --save FILE|- --selection FILE|-   studio_adapter.apply_groups
                selection = {"selected": [...], "actor": "...", "evidence": [...], "resolutions": {...}?, "ancestry": {...}?}

Output: one JSON object on stdout, always with "ok" and "status". Exit statuses:
  0 ok (read; applied, alreadyReflected or replayed; groups complete)
  1 refused (a deterministic refusal, recorded; for example a conflict)
  2 malformed input (bad JSON or arguments, a request the API rejects as malformed, not a V3 experiment DB)
  3 not found (no DB at the path; no such operation)
  4 not writable now (another generation, an operation of an earlier generation, writes closed, identity held)
  5 operation ID already used with a different request
  6 groups not complete (pending, unselected, conflict, refused or changed content; the full result is printed)
  7 whole save rejected (studio_adapter.SaveRejected; nothing written)
"""
import argparse
import json
import sqlite3
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
import registry_v3_read as r3  # noqa: E402
import registry_v3_write as w3  # noqa: E402
import studio_adapter as sa  # noqa: E402

EXIT = {'ok': 0, 'refused': 1, 'malformed': 2, 'notFound': 3, 'notWritable': 4, 'operationMismatch': 5, 'incomplete': 6, 'saveRejected': 7}


class Fail(Exception):
    def __init__(self, status, message, **extra):
        super().__init__(message)
        self.status, self.extra = status, extra


def emit(status, **body):
    print(json.dumps({'ok': status == 'ok', 'status': status, **body}, ensure_ascii=False, indent=1, default=sorted))
    return EXIT[status]


def open_existing(path):
    p = Path(path)
    if not p.is_file():
        raise Fail('notFound', f'no DB at {path} (the CLI never creates one)')
    conn = None
    try:
        # an escaped absolute file URI: '#', '?', '%' and spaces in the path name the file, not URI syntax; rw never creates
        conn = sqlite3.connect(p.resolve().as_uri() + '?mode=rw', uri=True, isolation_level=None, timeout=5.0)
        conn.execute('PRAGMA foreign_keys = ON')
        conn.execute('SELECT generation FROM db_meta').fetchone()
    except sqlite3.DatabaseError as error:
        if conn is not None:
            conn.close()
        raise Fail('malformed', f'{path} is not a V3 experiment DB: {error}') from None
    return conn


def load_json(source):
    try:
        text = sys.stdin.read() if source == '-' else Path(source).read_text(encoding='utf-8')
        value = json.loads(text)
    except OSError as error:
        raise Fail('malformed', f'cannot read {source}: {error}') from None
    except json.JSONDecodeError as error:
        raise Fail('malformed', f'{source} is not JSON: {error}') from None
    if not isinstance(value, dict):
        raise Fail('malformed', f'{source} must hold a JSON object')
    return value


def explicit(obj, fields, where):
    """The CLI contract: these fields are present and typed in the input itself; nothing is defaulted or invented.
    generation and actor are non-empty text; evidence is a list of text (an explicit empty list is allowed)."""
    for f in fields:
        if f not in obj:
            raise Fail('malformed', f'{where}: {f} must be given explicitly')
        v = obj[f]
        if f in ('generation', 'actor') and (not isinstance(v, str) or not v.strip()):
            raise Fail('malformed', f'{where}: {f} must be non-empty text')
        if f == 'evidence' and (not isinstance(v, list) or not all(isinstance(x, str) and x for x in v)):
            raise Fail('malformed', f'{where}: evidence must be a list of non-empty text')


def cmd_read(conn, args):
    return emit('ok', result=r3.read(conn, args.scope))


def cmd_export(conn, args):
    return emit('ok', result=sa.export_doc(conn))


def cmd_operation(conn, args):
    record = w3.operation(conn, args.op)
    if record is None:
        raise Fail('notFound', f'no operation {args.op}')
    return emit('ok', result=record)


def cmd_apply(conn, args):
    request = load_json(args.request)
    explicit(request, ('generation', 'actor', 'evidence'), 'request')
    known = w3.operation(conn, args.op)
    try:
        result = w3.apply(conn, args.op, request)
    except w3.OperationMismatch as error:
        raise Fail('operationMismatch', str(error)) from None
    except w3.Refused as error:
        raise Fail('refused', str(error), operationId=args.op, replayed=bool(known)) from None
    except (w3.GenerationMismatch, w3.OperationFromEarlierGeneration, w3.WriteDisabled, w3.IdentityHeld) as error:
        raise Fail('notWritable', str(error), kind=type(error).__name__) from None
    except (ValueError, KeyError, TypeError) as error:
        raise Fail('malformed', f'the request was rejected as malformed: {error!r}') from None
    return emit('ok', operationId=args.op, replayed=bool(known), result=result)


def cmd_plan_groups(conn, args):
    save = load_json(args.save)
    try:
        groups = sa.plan_groups(conn, save)
    except sa.SaveRejected as error:
        raise Fail('saveRejected', str(error)) from None
    except (ValueError, KeyError, TypeError) as error:
        raise Fail('malformed', f'the save was rejected as malformed: {error!r}') from None
    return emit('ok', groups=groups)


def cmd_apply_groups(conn, args):
    save, sel = load_json(args.save), load_json(args.selection)
    if set(sel) - {'selected', 'actor', 'evidence', 'resolutions', 'ancestry'} or not {'selected', 'actor', 'evidence'} <= set(sel):
        raise Fail('malformed', 'selection needs selected, actor and evidence (resolutions and ancestry are optional, never inferred)')
    explicit(sel, ('actor', 'evidence'), 'selection')
    try:
        out = sa.apply_groups(conn, save, sel['selected'], sel['actor'], sel['evidence'], sel.get('resolutions'), sel.get('ancestry'))
    except sa.SaveRejected as error:
        raise Fail('saveRejected', str(error)) from None
    except (w3.GenerationMismatch, w3.WriteDisabled) as error:
        raise Fail('notWritable', str(error), kind=type(error).__name__) from None
    except (ValueError, KeyError, TypeError) as error:
        raise Fail('malformed', f'the selection or save was rejected as malformed: {error!r}') from None
    return emit('ok' if out['complete'] else 'incomplete', result=out)


def parser():
    ap = argparse.ArgumentParser(prog='registry_v3_cli.py', description=__doc__.split('\n')[0])
    sub = ap.add_subparsers(dest='command', required=True)
    for name, fn, extra in (('read', cmd_read, [('--scope', {'choices': ['current', 'all'], 'default': 'current'})]),
                            ('export', cmd_export, []),
                            ('operation', cmd_operation, [('--op', {'required': True})]),
                            ('apply', cmd_apply, [('--op', {'required': True}), ('--request', {'required': True})]),
                            ('plan-groups', cmd_plan_groups, [('--save', {'required': True})]),
                            ('apply-groups', cmd_apply_groups, [('--save', {'required': True}), ('--selection', {'required': True})])):
        p = sub.add_parser(name)
        p.add_argument('--db', required=True)
        for flag, kw in extra:
            p.add_argument(flag, **kw)
        p.set_defaults(fn=fn)
    return ap


def main(argv):
    ap = parser()
    try:
        args = ap.parse_args(argv)
    except SystemExit as error:  # argparse already printed the usage to stderr
        if error.code == 0:
            return 0
        return emit('malformed', error='bad arguments (see usage on stderr)')
    try:
        conn = open_existing(args.db)
    except Fail as error:
        return emit(error.status, error=str(error), **error.extra)
    try:
        return args.fn(conn, args)
    except Fail as error:
        return emit(error.status, error=str(error), **error.extra)
    finally:
        conn.close()


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
