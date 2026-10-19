#!/usr/bin/env python3
"""OPS-175 K8a: generated read-only views from the V3 experiment DB. Experiment only; nothing is written in place.

- render_registry(template, conn): splices ONLY the data rows of the tables the importer consumes (every Task Registry
  group table, the top-level Task precedence table, 恒久タスクの親子関係, マイルストーン接続). Every other line (prose,
  headings, header and separator rows, other sections) is kept byte for byte.
- render_rules(template, conn): splices ONLY the data rows of the Task ID採番状態 table (DB highwater per prefix).
- render_structure(conn) / parse_structure(text): a separate generated view of the DB milestone structure (versions in
  order, cards in order, gates, focus), parsed back independently. Card order is DB data, never taken from file names.
- check(outputs, conn, milestones_root=None): a scoped equivalence check (Registry tables, Rules ledger and permanent
  report, STRUCTURE view), with retirements and hidden edges accounted for, and placement drift reported apart.
  It does not claim that the Milestones folders or HEAD.md match the DB.

Row order is presentation only: existing rows keep their order, new rows are appended by ID. Each generated table gets
a guard line right before its header: <!-- V3-GENERATED rows: ... sha256=H -->. When a template already carries a
guard, its current rows must still hash to H; otherwise generation is refused (the generated rows were edited by
hand). Unknown or ambiguous layouts and unrenderable values are refused, never guessed.
"""
import hashlib
import json
import os
import re
import shutil
import sys
import tempfile
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
import registry_v3_read as r3  # noqa: E402
import registry_v3_write as w3  # noqa: E402
import shadow_import as si  # noqa: E402

SEP = re.compile(r'\|(\s*:?-{3,}:?\s*\|)+\s*')
GUARD = re.compile(r'<!-- V3-GENERATED rows: (?P<body>.*) sha256=(?P<hash>[0-9a-f]{64}) -->')
TARGETS = ('Task Registry', 'Task precedence', '恒久タスクの親子関係', 'マイルストーン接続')


class ViewRefused(ValueError):
    """The template layout or a value cannot be rendered safely; nothing was generated."""


class ViewPartial(OSError):
    """replace_in_place: publishing failed after some files were already replaced (an I/O failure, not a refusal).
    published and unpublished name the files; rerunning replace_in_place regenerates from the current state."""

    def __init__(self, message, published, unpublished):
        super().__init__(message)
        self.published, self.unpublished = published, unpublished


def _natural(s):
    return [(0, int(x), '') if x.isdigit() else (1, 0, x) for x in re.split(r'(\d+)', s)]


def _tables(lines):
    """Every table: {section, group, guard (line index or None), header, sep, rows: [line indexes]}. Data rows are the
    contiguous '|' lines after the separator."""
    out, section, group, i = [], None, None, 0
    while i < len(lines):
        line = lines[i]
        if line.startswith('## '):
            section, group = line[3:].strip(), None
        elif line.startswith('### '):
            group = line[4:].strip()
        if line.lstrip().startswith('|') and i + 1 < len(lines) and SEP.fullmatch(lines[i + 1].strip()):
            if line != line.lstrip() or lines[i + 1] != lines[i + 1].lstrip():
                raise ViewRefused(f'line {i + 1}: an indented table')
            rows, j = [], i + 2
            while j < len(lines) and lines[j].lstrip().startswith('|'):
                if lines[j] != lines[j].lstrip():
                    raise ViewRefused(f'line {j + 1}: an indented table row')
                rows.append(j)
                j += 1
            guard = i - 1 if i > 0 and GUARD.fullmatch(lines[i - 1].strip()) else None
            out.append({'section': section, 'group': group, 'guard': guard, 'header': i, 'sep': i + 1, 'rows': rows})
            i = j
            continue
        i += 1
    return out


def _digest(rows):
    return hashlib.sha256('\n'.join(rows).encode('utf-8')).hexdigest()


def _check_guard(lines, t, where):
    if t['guard'] is None:
        return
    m = GUARD.fullmatch(lines[t['guard']].strip())
    if _digest([lines[r] for r in t['rows']]) != m.group('hash'):
        raise ViewRefused(f'{where}: the generated rows were edited by hand since generation; refusing to overwrite them')


def _cell(value, where, pipe_ok=False):
    if not isinstance(value, str):
        raise ViewRefused(f'{where}: not text: {value!r}')
    if '\n' in value or '\r' in value:
        raise ViewRefused(f'{where}: a line break cannot be rendered in a table cell')
    if value != value.strip():
        raise ViewRefused(f'{where}: leading or trailing whitespace would be lost')
    if '|' in value:
        if not pipe_ok:
            raise ViewRefused(f'{where}: a "|" here is not read back by the importer')
        value = value.replace('|', r'\|')
    return value


def _ident(value, where, pattern=r'[A-Za-z0-9._-]+'):
    if not isinstance(value, str) or not re.fullmatch(pattern, value):
        raise ViewRefused(f'{where}: not a renderable ID: {value!r}')
    return f'`{value}`'


def _splice(lines, t, keys_existing, rows_by_key, new_keys, label, generation, revision):
    """Rows of one table: existing keys in their order (dropped when gone), then new keys by ID."""
    rendered = [rows_by_key[k] for k in keys_existing if k in rows_by_key] + [rows_by_key[k] for k in new_keys]
    guard = f'<!-- V3-GENERATED rows: table={label}; generation={generation}; revision={revision}; rows={len(rendered)}; sha256={_digest(rendered)} -->'
    return rendered, guard


def _db(conn):
    view = r3.read(conn, 'all')
    retired = sorted(r[0] for r in conn.execute('SELECT id FROM retirements'))
    live = lambda *ids: not any(x in retired for x in ids)
    tasks = {tid: t for tid, t in view['ids']['tasks'].items() if tid not in retired}
    edges = {g: [e for e in view['edges'][g] if live(e['prerequisite'], e['successor'])] for g in ('management', 'progress', 'milestone')}
    hidden = [dict(e, graph=g) for g in ('management', 'progress', 'milestone') for e in view['edges'][g] if not live(e['prerequisite'], e['successor'])]
    return view, tasks, edges, retired, hidden


def _key(row, section):
    c = si._cells(row)
    u = si._unquote
    if section == 'Task Registry':
        return u(c[0])
    if section == 'Task precedence':
        return (u(c[0]), u(c[1]))  # (successor, prerequisite)
    return (u(c[0]), u(c[1]))


def _rows_by_key(lines):
    """The importer's view of the target sections: every data row ('|' line that is neither a header nor a separator)
    keyed by (section, group-for-Task-Registry), with its line index, plus header lines and generated guards. Rows may
    sit in several blank-line separated blocks of one group; each keeps its line position (layout)."""
    rows, headers, guards, section, group = {}, {}, {}, None, None
    for i, line in enumerate(lines):
        if line.startswith('## '):
            section, group = line[3:].strip(), None
        elif line.startswith('### '):
            group = line[4:].strip()
        if section not in TARGETS:
            continue
        key = (section, group if section == 'Task Registry' else None)
        m = GUARD.fullmatch(line.strip())
        if m:
            guards.setdefault(key, []).append((i, m))
            continue
        if not line.lstrip().startswith('|'):
            continue
        if line != line.lstrip():
            raise ViewRefused(f'line {i + 1}: an indented table row (unknown layout)')
        if section != 'Task Registry' and group is not None:
            raise ViewRefused(f'{section}: a table row inside the subsection {group} (unknown layout)')
        if SEP.fullmatch(line.strip()):
            continue
        if i + 1 < len(lines) and SEP.fullmatch(lines[i + 1].strip()):
            headers.setdefault(key, []).append(i)
            continue
        rows.setdefault(key, []).append(i)
    return rows, headers, guards


def _validate_registry(template):
    """Pre-validation with the accepted importer: every row of the target sections has the importer's full shape, and
    no key appears twice. Malformed or ambiguous input is refused, never normalized or dropped."""
    try:
        tasks, management, progress, milestone, _, _ = si.parse_registry(template)
    except si.Refusal as error:
        raise ViewRefused(f'template: {error}') from None
    for what, keys in (('task', [t['id'] for t in tasks]), ('precedence row', [(e['successor'], e['prerequisite']) for e in progress]),
                       ('parent row', [(e['prerequisite'], e['successor']) for e in management]), ('milestone connection', [(e['prerequisite'], e['successor']) for e in milestone])):
        seen = set()
        for k in keys:
            if k in seen:
                raise ViewRefused(f'template: duplicate {what} {k}')
            seen.add(k)


def render_registry(template, conn):
    lines = template.split('\n')
    headings = [line[3:].strip() for line in lines if line.startswith('## ')]
    for name in TARGETS:
        if headings.count(name) != 1:
            raise ViewRefused(f'section {name} appears {headings.count(name)} times; exactly once is required')
    _validate_registry(template)
    rows, headers, guards = _rows_by_key(lines)
    for name in TARGETS[1:]:
        if len(headers.get((name, None), [])) != 1:
            raise ViewRefused(f'{name}: {len(headers.get((name, None), []))} tables; exactly one is required')
    keys = set(headers) | set(rows)
    for k in keys:
        if not headers.get(k):
            raise ViewRefused(f'{k[0]} / {k[1]}: rows without any table header (unknown layout)')
    for k, gs in guards.items():  # a guard must still match the rows it was generated for
        if len(gs) != 1:
            raise ViewRefused(f'{k[0]} / {k[1]}: {len(gs)} generated guards (ambiguous)')
        if _digest([lines[r] for r in rows.get(k, [])]) != gs[0][1].group('hash'):
            raise ViewRefused(f'{k[0]}{" / " + k[1] if k[1] else ""}: the generated rows were edited by hand since generation; refusing to overwrite them')
    gen, rev = w3.generation(conn), w3.revision(conn)
    view, tasks, edges, retired, hidden = _db(conn)
    groups = {k[1] for k in keys if k[0] == 'Task Registry'}
    for tid, t in tasks.items():
        if t['group'] not in groups:
            raise ViewRefused(f'{tid}: group {t["group"]!r} has no table in the template (a new heading is not invented)')
    rendered = {}
    for tid, t in tasks.items():
        rendered[('Task Registry', t['group'], tid)] = '| ' + ' | '.join([
            _ident(tid, tid, r'[A-Z]+-\d+'), _ident(t['state'], tid, r'[A-Z_]+'), _cell(t['owner'], tid + ' owner'), _cell(t['item'], tid + ' item'),
            _cell(t['condition'], tid + ' condition'), _cell(t['detail'], tid + ' detail')]) + ' |'
    for e in edges['progress']:
        rendered[('Task precedence', None, (e['successor'], e['prerequisite']))] = '| ' + ' | '.join([
            _ident(e['successor'], 'edge'), _ident(e['prerequisite'], 'edge'), _ident(e['flow'], 'edge flow', r'SEQUENCE|PARALLEL_JOIN'),
            _cell(e['constraint'], f"edge {e['prerequisite']}->{e['successor']}")]) + ' |'
    for e in edges['management']:
        rendered[('恒久タスクの親子関係', None, (e['prerequisite'], e['successor']))] = f"| {_ident(e['prerequisite'], 'parent')} | {_ident(e['successor'], 'child')} |"
    for e in edges['milestone']:
        rendered[('マイルストーン接続', None, (e['prerequisite'], e['successor']))] = '| ' + ' | '.join([
            _ident(e['prerequisite'], 'link'), _ident(e['successor'], 'link'), _cell(e['constraint'], f"link {e['prerequisite']}->{e['successor']}", pipe_ok=True)]) + ' |'
    by_key = {}
    for (section, group, item), text in rendered.items():
        by_key.setdefault((section, group), {})[item] = text
    replace, insert_after, out_rows = {}, {}, {}
    for k in keys | set(by_key):
        mine = by_key.get(k, {})
        kept = []
        for r in rows.get(k, []):
            item = _key(lines[r], k[0])
            if item in mine and item not in kept:
                replace[r] = mine[item]
                kept.append(item)
            else:
                replace[r] = None  # gone from this table (removed, retired or moved to another group)
        new = sorted((x for x in mine if x not in kept), key=lambda x: _natural(x) if isinstance(x, str) else (_natural(x[0]), _natural(x[1])))
        anchor = max([r for r in rows.get(k, []) if replace[r] is not None] or [headers[k][0] + 1])
        insert_after.setdefault(anchor, []).extend(mine[x] for x in new)
        out_rows[k] = [replace[r] for r in rows.get(k, []) if replace[r] is not None] + [mine[x] for x in new]
    guard_line = {headers[k][0]: f"<!-- V3-GENERATED rows: table={k[0]}{'/' + k[1] if k[1] else ''}; generation={gen}; revision={rev}; rows={len(out_rows[k])}; sha256={_digest(out_rows[k])} -->"
                  for k in keys}
    drop = {i for gs in guards.values() for i, _ in gs}
    out = []
    for i, line in enumerate(lines):
        if i in drop:
            continue
        if i in guard_line:
            out.append(guard_line[i])
        if i in replace:
            if replace[i] is not None:
                out.append(replace[i])
        else:
            out.append(line)
        out.extend(insert_after.get(i, []))
    return '\n'.join(out)


def render_rules(template, conn):
    try:
        si.parse_rules(template)  # the accepted importer: full row shape, no duplicate prefix
    except si.Refusal as error:
        raise ViewRefused(f'template: {error}') from None
    lines = template.split('\n')
    tables = [t for t in _tables(lines) if t['section'] == 'Task ID採番状態']
    if len(tables) != 1:
        raise ViewRefused(f'Task ID採番状態: {len(tables)} tables; exactly one is required')
    t = tables[0]
    _check_guard(lines, t, 'Task ID採番状態')
    highwater = dict(conn.execute('SELECT prefix, highwater FROM id_allocations'))
    rows = {p: f'| {_ident(p, p, r"[A-Z]+")} | `{n:03d}` |' for p, n in highwater.items()}
    keys = [si._unquote(si._cells(lines[r])[0]) for r in t['rows']]
    keep = [k for k in keys if k in rows]
    rendered, guard = _splice(lines, t, keep, rows, sorted(k for k in rows if k not in keep), 'Task ID採番状態', w3.generation(conn), w3.revision(conn))
    out = []
    for i, line in enumerate(lines):
        if i in t['rows'] or i == t['guard']:
            continue
        if i == t['header']:
            out.append(guard)
        out.append(line)
        if i == t['sep']:
            out.extend(rendered)
    return '\n'.join(out)


def _structure(conn):
    view = r3.read(conn, 'all')
    ms = view['ids']['milestones']
    return {'focus': view['range']['focus'],
            'versions': [{'name': v, 'cards': [{'id': c, 'name': ms[c]['name'], 'recordedDone': ms[c]['recordedDone'], 'detail': ms[c]['detail']} for c in view['order']['cards'][v]],
                          'gate': ({'id': view['order']['gates'][v], 'name': ms[view['order']['gates'][v]]['name'], 'detail': ms[view['order']['gates'][v]]['detail']}
                                   if v in view['order']['gates'] else None)} for v in view['order']['versions']]}


def render_structure(conn):
    s = _structure(conn)
    body = ['focus ' + json.dumps(s['focus'], ensure_ascii=False)]
    for v in s['versions']:
        body.append('version ' + json.dumps(v['name'], ensure_ascii=False))
        body += ['card ' + json.dumps(c, ensure_ascii=False, sort_keys=True) for c in v['cards']]
        body.append('gate ' + json.dumps(v['gate'], ensure_ascii=False, sort_keys=True))
    digest = _digest(body)
    return '\n'.join(['# V3 milestone structure (generated from the DB, read-only)', '',
                      f'<!-- V3-GENERATED structure: generation={w3.generation(conn)}; revision={w3.revision(conn)}; sha256={digest} -->',
                      'Card and gate files stay documents; their folder and file names are not this structure.', '', *body, ''])


def parse_structure(text):
    lines = [line for line in text.split('\n')]
    m = re.search(r'<!-- V3-GENERATED structure: .* sha256=([0-9a-f]{64}) -->', text)
    body = [line for line in lines if re.match(r'^(focus|version|card|gate) ', line)]
    if not m or _digest(body) != m.group(1):
        raise ViewRefused('STRUCTURE: missing guard or the generated lines were edited')
    out, cur = {'focus': None, 'versions': []}, None
    for line in body:
        kind, value = line.split(' ', 1)
        v = json.loads(value)
        if kind == 'focus':
            out['focus'] = v
        elif kind == 'version':
            cur = {'name': v, 'cards': [], 'gate': None}
            out['versions'].append(cur)
        elif kind == 'card':
            cur['cards'].append(v)
        else:
            cur['gate'] = v
    return out


def check(registry_text, rules_text, structure_text, conn, milestones_listing=None):
    """Scoped equivalence. Returns a report; 'equal' is true only when every scoped part is equal."""
    view, tasks, edges, retired, hidden = _db(conn)
    reg = si.parse_registry(registry_text)
    r_tasks, r_mgmt, r_prog, r_link, _ = reg[:5]
    parts = {}
    parts['tasks'] = {t['id']: {k: t[k] for k in ('state', 'owner', 'item', 'condition', 'detail', 'group')} for t in r_tasks} == \
        {tid: {k: t[k] for k in ('state', 'owner', 'item', 'condition', 'detail', 'group')} for tid, t in tasks.items()}
    parts['progress'] = sorted((e['prerequisite'], e['successor'], e['flow'], e['constraint']) for e in r_prog) == \
        sorted((e['prerequisite'], e['successor'], e['flow'], e['constraint']) for e in edges['progress'])
    parts['management'] = sorted((e['prerequisite'], e['successor']) for e in r_mgmt) == sorted((e['prerequisite'], e['successor']) for e in edges['management'])
    parts['milestone'] = sorted((e['prerequisite'], e['successor'], e['constraint']) for e in r_link) == \
        sorted((e['prerequisite'], e['successor'], e['constraint']) for e in edges['milestone'])
    permanent, ledger = si.parse_rules(rules_text)
    parts['ledger'] = ledger == dict(conn.execute('SELECT prefix, highwater FROM id_allocations'))
    parts['structure'] = parse_structure(structure_text) == _structure(conn)
    db_perm = sorted(tid for tid, t in tasks.items() if t['permanent'])
    report = {'equal': False, 'parts': parts,
              'scope': 'Registry tables, Rules ledger and the STRUCTURE view; not the Milestones folders, HEAD.md or other Registry/Rules text',
              'accounting': {'tasksInDb': len(view['ids']['tasks']), 'retired': retired, 'tasksRendered': len(r_tasks),
                             'hiddenEdges': [[e['graph'], e['prerequisite'], e['successor']] for e in hidden],
                             'edgesRendered': {'progress': len(r_prog), 'management': len(r_mgmt), 'milestone': len(r_link)}},
              'permanent': {'rulesProse': sorted(permanent), 'db': db_perm, 'equal': sorted(permanent) == db_perm,
                            'note': 'reported only: the prose is not rewritten'}}
    report['accounting']['complete'] = (report['accounting']['tasksRendered'] + len(retired) == report['accounting']['tasksInDb'])
    report['equal'] = all(parts.values()) and report['permanent']['equal'] and report['accounting']['complete']
    if milestones_listing is not None:
        report['placementDrift'] = drift(milestones_listing, conn)
    return report


def drift(listing, conn):
    """Milestones files whose folder or file-name order differs from the DB structure (reported, not verification).
    listing: {version: [card id in file-name order]} as read from a folder tree."""
    db = {v['name']: [c['id'] for c in v['cards']] for v in _structure(conn)['versions']}
    return {v: {'files': listing.get(v, []), 'db': db.get(v, [])} for v in sorted(set(db) | set(listing)) if listing.get(v, []) != db.get(v, [])}


def replace_in_place(root, conn, structure_rel=None, _before_write=None):
    """B2 (OPS-167 K9): regenerate the Registry and Rules views in place under root (and the STRUCTURE view at
    structure_rel, when given). Only the generated rows change (render_*: prose, headings and other sections are kept
    byte for byte), and a guard refuses rows edited by hand since the last generation. Before anything is written:
    - every DB read of the rendering and of check() shares one read snapshot (a caller's transaction is kept);
    - check() of the rendered texts must be equal;
    - an existing STRUCTURE file must still carry its own valid guard;
    - every target file must still hold the exact bytes that were read (else drift: refused).
    A refusal (ViewRefused) writes nothing. Then every changed file is staged in a directory this call creates
    exclusively next to its target (tempfile.mkdtemp, same filesystem) and published by one rename per file. Publishing
    several files is not atomic as a whole: if a later rename fails, ViewPartial names the published and unpublished
    files (a mixed view until rerun; rerunning regenerates from the current state). Only the owned staging directories
    are removed; no file this call did not create is touched.
    The drift check does not lock the files: an edit after it can be overwritten. Run this as the only writer of these
    files (the freeze / exclusive-writer boundary of the cutover procedure).
    Returns {'changed': [relative paths whose bytes changed], 'report': check()}."""
    root = Path(root)
    targets = [si.REGISTRY, si.RULES] + ([structure_rel] if structure_rel else [])
    before = {rel: (root / rel).read_bytes() if (root / rel).exists() else None for rel in targets}
    if before[si.REGISTRY] is None or before[si.RULES] is None:
        raise ViewRefused('the Registry and Rules files must exist; they are views of existing documents')
    if structure_rel and before[structure_rel] is not None:
        parse_structure(before[structure_rel].decode('utf-8'))  # an edited STRUCTURE view is refused, not overwritten
    own = not conn.in_transaction
    if own:
        conn.execute('BEGIN')
    try:
        rendered = {si.REGISTRY: render_registry(before[si.REGISTRY].decode('utf-8'), conn), si.RULES: render_rules(before[si.RULES].decode('utf-8'), conn)}
        structure = render_structure(conn)
        if structure_rel:
            rendered[structure_rel] = structure
        report = check(rendered[si.REGISTRY], rendered[si.RULES], structure, conn)
    finally:
        if own:
            conn.execute('ROLLBACK')
    if not report['equal']:
        raise ViewRefused(f"the regenerated views do not check equal ({report['parts']}); nothing was written")
    if _before_write:
        _before_write(root)
    for rel in targets:
        now = (root / rel).read_bytes() if (root / rel).exists() else None
        if now != before[rel]:
            raise ViewRefused(f'{rel} changed while regenerating; nothing was written')
    changed = [rel for rel in targets if rendered[rel].encode('utf-8') != before[rel]]
    owned, staged = [], {}
    try:
        for rel in changed:  # stage everything first: nothing is published until every file is written
            target = root / rel
            d = Path(tempfile.mkdtemp(prefix=f'.{target.name}.regenerating-', dir=target.parent))
            owned.append(d)
            staged[rel] = d / target.name
            with open(staged[rel], 'xb') as f:
                f.write(rendered[rel].encode('utf-8'))
        published = []
        for rel in changed:
            try:
                os.replace(staged[rel], root / rel)
            except OSError as error:
                if published:
                    raise ViewPartial(f'published {published}, then {rel} failed ({error}); rerun to finish', published,
                                      [r for r in changed if r not in published]) from error
                raise
            published.append(rel)
    finally:
        for d in owned:
            shutil.rmtree(d, ignore_errors=True)
    return {'changed': changed, 'report': report}


def generate(root, conn, out_dir):
    """Read the Registry and Rules from a (fixed, read-only) copy at root; write the views into a fresh out_dir."""
    out = Path(out_dir)
    if out.exists() and any(out.iterdir()):
        raise ViewRefused(f'{out} is not empty; views are only written to a fresh tree')
    root = Path(root)
    registry = render_registry((root / si.REGISTRY).read_text(encoding='utf-8'), conn)
    rules = render_rules((root / si.RULES).read_text(encoding='utf-8'), conn)
    structure = render_structure(conn)
    for rel, text in ((si.REGISTRY, registry), (si.RULES, rules), ('STRUCTURE.generated.md', structure)):
        p = out / rel
        p.parent.mkdir(parents=True, exist_ok=True)
        with open(p, 'x', encoding='utf-8') as f:
            f.write(text)
    return {'registry': registry, 'rules': rules, 'structure': structure}
