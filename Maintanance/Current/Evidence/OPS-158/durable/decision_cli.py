#!/usr/bin/env python3
"""OPS-158 isolated decision store CLI (experiment). Every input is explicit; nothing is inferred or created implicitly.

  init    --db NEW_PATH                         create a new store (an existing path is refused)
  apply   --db PATH --op ID --request FILE|-    one operation (see decision_store); the same --op replays
  query   --db PATH --id ID [--review]          one decision (all revisions, references); --review: copy review candidates
  export  --db PATH                             every event in order (for review)
  backup  --db PATH --to NEW_PATH               a validated SQLite backup into a new file (an existing path is refused)
  validate --db PATH                            integrity, schema and fold of a store or backup, read-only
query, export and validate open the store read-only and print the authority note. A backup is only read (query it);
there is no restore writer.

Output: one JSON object on stdout with "ok" and "status". Exit: 0 ok/replayed, 1 refused, 2 malformed,
3 not found (no store at the path, or no such decision), 5 operation ID used with a different request.
"""
import argparse
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import decision_store as ds  # noqa: E402

EXIT = {'ok': 0, 'refused': 1, 'malformed': 2, 'notFound': 3, 'operationMismatch': 5}


def emit(status, **body):
    print(json.dumps({'ok': status == 'ok', 'status': status, **body}, ensure_ascii=False, indent=1))
    return EXIT[status]


def load(source):
    try:
        value = json.loads(sys.stdin.read() if source == '-' else Path(source).read_text(encoding='utf-8'))
    except (OSError, json.JSONDecodeError) as error:
        raise ValueError(f'{source}: {error}') from None
    if not isinstance(value, dict):
        raise ValueError(f'{source} must hold a JSON object')
    return value


def main(argv):
    ap = argparse.ArgumentParser(prog='decision_cli.py', description=__doc__.split('\n')[0])
    sub = ap.add_subparsers(dest='command', required=True)
    for name, extra in (('init', []), ('apply', [('--op', True), ('--request', True)]), ('query', [('--id', True)]), ('export', []),
                        ('backup', [('--to', True)]), ('validate', [])):
        p = sub.add_parser(name)
        p.add_argument('--db', required=True)
        for flag, required in extra:
            p.add_argument(flag, required=required)
        if name == 'query':
            p.add_argument('--review', action='store_true')
    try:
        args = ap.parse_args(argv)
    except SystemExit as error:
        return 0 if error.code == 0 else emit('malformed', error='bad arguments (see usage on stderr)')
    if args.command == 'init':
        try:
            return emit('ok', created=str(ds.init(args.db)))
        except FileExistsError:
            return emit('refused', error=f'{args.db} already exists; init never overwrites')
        except OSError as error:
            return emit('malformed', error=str(error))
    if args.command == 'validate':
        try:
            return emit('ok', result=ds.validate(args.db), authority=ds.AUTHORITY)
        except FileNotFoundError as error:
            return emit('notFound', error=str(error))
        except ds.NotADecisionStore as error:
            return emit('malformed', error=str(error))
    try:
        conn = ds.open_store(args.db, readonly=args.command in ('query', 'export'))
    except FileNotFoundError as error:
        return emit('notFound', error=str(error))
    except ds.NotADecisionStore as error:
        return emit('malformed', error=str(error))
    try:
        if args.command == 'apply':
            try:
                return emit('ok', operationId=args.op, result=ds.apply(conn, args.op, load(args.request)))
            except ds.OperationMismatch as error:
                return emit('operationMismatch', error=str(error))
            except ds.Refused as error:
                return emit('refused', operationId=args.op, error=str(error))
            except ValueError as error:
                return emit('malformed', error=str(error))
        if args.command == 'query':
            value = ds.review_candidates(conn, args.id) if args.review else ds.decision(conn, args.id)
            return emit('notFound', error=f'no decision {args.id}') if value is None else emit('ok', result=value, authority=ds.AUTHORITY)
        if args.command == 'backup':
            try:
                return emit('ok', result=ds.backup(conn, args.to))
            except FileExistsError:
                return emit('refused', error=f'{args.to} already exists; a backup never overwrites')
        return emit('ok', result=ds.export(conn), authority=ds.AUTHORITY)
    finally:
        conn.close()


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
