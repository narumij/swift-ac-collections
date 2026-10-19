#!/usr/bin/env python3
"""OPS-163 fixed-source shadow import: copy the current canonical inputs once, check the copy, parse only the copy into
the V3 experiment DB, and compare it with the current reader (sync.build()) run on the same copy.

Read-only towards the repository: the inputs are read and hashed, never written. The copy and the DB live in a temporary
directory that is removed at the end. No live DB, server, Inbox or Studio output is touched.

Steps
1. snapshot(): copy TASK_REGISTRY_V2.md, TASK_RULES_V2.md, Milestones/README.md, HEAD.md, every entry of the version
   folders, and the files their # 正本 links name; record path, role, size, SHA-256, the Git basis (HEAD commit, the HEAD
   blob of the path, the blob of the captured bytes, dirty/untracked). Then re-read every original and re-list the
   folders: any change while capturing is Drift and nothing is parsed.
2. verify(): re-hash the copy against the manifest (Tampered if not equal).
3. parse(): an independent reader of the copy. Every table row of the target sections must be consumed; a row in an
   unknown shape, a precedence row inside a ### subsection, a malformed card, an unknown file in a version folder, a bad
   HEAD or ledger is an explicit refusal (Unknown). Table rows outside the target sections are reported, not consumed.
   The version order is the current implementation's (sync.vkey), recorded as a fixed input, not as a comparator.
4. compare(): load the fixture into an isolated DB (registry_v3_write.create) and compare its whole read with
   sync.build() on the same copy: task attributes, parent/child, precedence (flow, constraint), milestone links
   (constraint), version and card order, gates. recordedDone is checked against the reader's derived state only where
   the reader uses the box (folders from HEAD on). The current/all ranges and the reserved highwater per prefix are
   reported. Excluded fields are listed with their reason; the exclusion is not full compatibility.
   Known DESIGN deviations (gate ID used as destination, missing or terminal gate) are reported separately.

Run: python3 -B Maintanance/RegistryApp/v3/shadow_import.py [--evidence FILE.json] [--create-db NEW.sqlite3]
Exit: 0 equal, 1 differences, 2 refused (drift, tampering or unknown input; with --create-db also an existing path).
--create-db (B3, OPS-167 K9): import_db keeps a V3 DB at a new path, only when equal; see import_db.
"""
import argparse
import hashlib
import importlib.util
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
import registry_v3_read as r3  # noqa: E402
import registry_v3_write as w3  # noqa: E402

REPO = HERE.parent.parent.parent
SYNC = HERE.parent / 'sync.py'
REGISTRY = 'Maintanance/ProgressV2/TASK_REGISTRY_V2.md'
RULES = 'Maintanance/ProgressV2/TASK_RULES_V2.md'
MILESTONES = 'Maintanance/Milestones'
TARGETS = {'Task Registry': 6, '恒久タスクの親子関係': 2, 'Task precedence': 4, 'マイルストーン接続': 3}
EXCLUDED = {
    'raw, sourceLine': 'Markdown text and line positions; the DB keeps provenance instead and does not pretend to have lines',
    'milestone state': 'derived from HEAD by the reader (compat display value); only checked against recordedDone where the reader reads the box',
    'milestone owner / condition / raw': 'constant or generated text of the reader',
    'source block (sha256, head, dirty, generatedAt)': 'file identity; recorded in the manifest, never written into the DB as a revision',
    'relation source objects, chain relations': 'Markdown provenance and the derived skeleton; the skeleton is compared as structure',
}


class Refusal(ValueError):
    kind = 'refused'


class Drift(Refusal):
    kind = 'drift'


class Tampered(Refusal):
    kind = 'tampered'


class Unknown(Refusal):
    kind = 'unknown input'


class Exists(Refusal):
    kind = 'exists'


def sha256(data):
    return hashlib.sha256(data).hexdigest()


def git_blob(data):
    return hashlib.sha1(b'blob %d\0' % len(data) + data).hexdigest()


def load_sync():
    spec = importlib.util.spec_from_file_location('sync_for_ops163', SYNC)
    sync = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(sync)
    return sync


# ---- 1. snapshot --------------------------------------------------------------------------------------------------

def _git(root, *args):
    try:
        out = subprocess.run(['git', *args], cwd=root, capture_output=True, text=True, timeout=30)
    except OSError:
        return None
    return out.stdout.strip() if out.returncode == 0 else None


def _listing(root):
    """Every entry under the version folders (names starting with '_' are not version folders, Milestones/DESIGN.md)."""
    base = Path(root) / MILESTONES
    entries = []
    for d in sorted(p for p in base.iterdir() if p.is_dir() and not p.name.startswith('_')):
        entries.append(d.relative_to(root).as_posix() + '/')  # the folder itself: an empty version folder is still a version
        for e in sorted(d.iterdir()):
            entries.append(e.relative_to(root).as_posix() + ('/' if e.is_dir() else ''))
    return entries


def _links(text):
    top = _sections(text, '#')
    m = re.search(r'\]\(([^)]+)\)', top.get('正本', ''))
    return m.group(1) if m else None


def snapshot(root, dest, after_copy=None):
    """Copy the inputs from root to dest and return the manifest. after_copy(dest) is a test hook run before the drift
    check."""
    root, dest = Path(root), Path(dest)
    files, roles = [], {}
    def take(rel, role):
        if rel in roles:
            return
        src = root / rel
        if not src.is_file():
            raise Unknown(f'input missing: {rel}')
        data = src.read_bytes()
        (dest / rel).parent.mkdir(parents=True, exist_ok=True)
        (dest / rel).write_bytes(data)
        roles[rel] = role
        files.append({'path': rel, 'role': role, 'bytes': len(data), 'sha256': sha256(data), 'capturedBlob': git_blob(data)})
    for rel, role in ((REGISTRY, 'registry'), (RULES, 'rules'), (MILESTONES + '/README.md', 'milestone rules'), (MILESTONES + '/HEAD.md', 'head')):
        take(rel, role)
    listing = _listing(root)
    for rel in listing:
        if rel.endswith('/'):
            if rel.count('/') == 3:
                (dest / rel).mkdir(parents=True, exist_ok=True)  # version folder, kept even when empty
            continue  # deeper folders are reported by parse() as unknown entries
        take(rel, 'version folder entry')
    for rel in [f['path'] for f in files if f['role'] == 'version folder entry' and f['path'].endswith('.md')]:
        link = _links((dest / rel).read_text(encoding='utf-8'))
        if link:
            target = os.path.normpath(os.path.join(os.path.dirname(rel), link))
            if target.startswith('..') or os.path.isabs(target):
                raise Unknown(f'{rel}: 正本 link leaves the repository: {link}')
            if (root / target).is_file():
                take(Path(target).as_posix(), 'linked 正本')
    if after_copy:
        after_copy(dest)
    for f in files:  # drift: the originals must still be what was copied
        now = (root / f['path']).read_bytes() if (root / f['path']).is_file() else None
        if now is None or sha256(now) != f['sha256']:
            raise Drift(f"input changed while capturing: {f['path']}")
    if _listing(root) != listing:
        raise Drift('a version folder changed while capturing')
    head = _git(root, 'rev-parse', 'HEAD')
    git = {'available': head is not None, 'head': head}
    if head:
        status = _git(root, 'status', '--porcelain', '--', *[f['path'] for f in files]) or ''
        git['statusLines'] = status.splitlines()
        for f in files:
            tree = _git(root, 'ls-tree', 'HEAD', '--', f['path']) or ''
            f['headBlob'] = tree.split()[2] if tree else None
            f['dirty'] = f['headBlob'] != f['capturedBlob']
            f['untracked'] = f['headBlob'] is None
    return {'files': files, 'listing': listing, 'git': git}


# ---- 2. verify ----------------------------------------------------------------------------------------------------

def verify(dest, manifest):
    dest = Path(dest)
    for f in manifest['files']:
        p = dest / f['path']
        if not p.is_file() or sha256(p.read_bytes()) != f['sha256']:
            raise Tampered(f"captured copy differs from the manifest: {f['path']}")
    present = sorted(p.relative_to(dest).as_posix() for p in dest.rglob('*') if p.is_file())
    if present != sorted(f['path'] for f in manifest['files']):
        raise Tampered('the captured copy has files that are not in the manifest')
    base = dest / MILESTONES
    folders = sorted(p.relative_to(dest).as_posix() + '/' for p in base.iterdir() if p.is_dir() and not p.name.startswith('_')) if base.is_dir() else []
    if folders != sorted(e for e in manifest['listing'] if e.count('/') == 3 and e.endswith('/')):
        raise Tampered('the version folders of the copy differ from the manifest')


# ---- 3. parse -----------------------------------------------------------------------------------------------------

def _cells(line):
    return [p.strip() for p in re.split(r'(?<!\\)\|', line.strip())[1:-1]]


def _unquote(s):
    return s[1:-1] if len(s) >= 2 and s[0] == s[-1] == '`' else s


def _sections(text, level):
    out, name = {}, None
    for line in text.split('\n'):
        m = re.match('^' + level + r' (.+)$', line)
        if m:
            name = m.group(1).strip()
            out[name] = []
        elif name is not None:
            out[name].append(line)
    return {k: '\n'.join(v).strip() for k, v in out.items()}


def _table_rows(lines):
    """(line number, line, section, group) of every data row: table rows that are neither a header nor a separator."""
    rows, section, group = [], None, None
    for i, line in enumerate(lines):
        if line.startswith('## '):
            section, group = line[3:].strip(), None
        elif line.startswith('### '):
            group = line[4:].strip()
        if not line.startswith('|'):
            if line.lstrip().startswith('|'):
                rows.append((i + 1, line, section, group))  # indented: the current reader does not see it; the caller decides
            continue
        if re.fullmatch(r'\|(\s*:?-{3,}:?\s*\|)+\s*', line):
            continue  # separator
        if i + 1 < len(lines) and re.fullmatch(r'\|(\s*:?-{3,}:?\s*\|)+\s*', lines[i + 1]):
            continue  # header
        rows.append((i + 1, line, section, group))
    return rows


ID = r'`[A-Z]+-\d+`'


def parse_registry(text):
    tasks, management, progress, milestone, out_of_scope, task_shaped = [], [], [], [], [], []
    headings = [line[3:].strip() for line in text.split('\n') if line.startswith('## ')]
    for name in TARGETS:
        if headings.count(name) == 0:
            raise Unknown(f'TASK_REGISTRY_V2.md: required section missing: {name}')
        if headings.count(name) > 1:
            raise Unknown(f'TASK_REGISTRY_V2.md: section appears more than once: {name}')
    for no, line, section, group in _table_rows(text.split('\n')):
        indented = not line.startswith('|')
        if section not in TARGETS:
            out_of_scope.append({'line': no, 'section': section, **({'indented': True} if indented else {})})
            first = _cells(line.strip())[:1]
            if first and re.fullmatch(ID, first[0]):
                task_shaped.append({'line': no, 'section': section})  # looks like a task, precedence or connection row
            continue
        if indented:
            raise Unknown(f'TASK_REGISTRY_V2.md:{no} ({section}): indented table row; the current reader skips it')
        c = _cells(line)
        where = f'TASK_REGISTRY_V2.md:{no} ({section}{" / " + group if group else ""})'
        if len(c) != TARGETS[section]:
            raise Unknown(f'{where}: expected {TARGETS[section]} cells, got {len(c)}')
        if section == 'Task Registry':
            if not re.fullmatch(ID, c[0]) or not re.fullmatch(r'`[A-Z_]+`', c[1]):
                raise Unknown(f'{where}: ID and state must be backticked (`PREFIX-n`, `STATE`)')
            tasks.append({'id': _unquote(c[0]), 'state': _unquote(c[1]), 'owner': c[2], 'item': c[3], 'condition': c[4], 'detail': c[5], 'group': group})
        elif section == '恒久タスクの親子関係':
            if group or not all(re.fullmatch(ID, x) for x in c):
                raise Unknown(f'{where}: needs `PARENT-ID` | `CHILD-ID` outside subsections')
            management.append({'prerequisite': _unquote(c[0]), 'successor': _unquote(c[1])})
        elif section == 'Task precedence':
            if group:
                raise Unknown(f'{where}: a precedence row inside a subsection is not read by the current reader; move it or remove it')
            if not (re.fullmatch(ID, c[0]) and re.fullmatch(ID, c[1]) and c[2] in ('`SEQUENCE`', '`PARALLEL_JOIN`')):
                raise Unknown(f'{where}: needs `SUCCESSOR` | `PREREQUISITE` | `SEQUENCE|PARALLEL_JOIN` | 制約')
            progress.append({'successor': _unquote(c[0]), 'prerequisite': _unquote(c[1]), 'flow': _unquote(c[2]), 'constraint': c[3]})
        else:
            if group or not (c[0].startswith('`') and c[0].endswith('`') and c[1].startswith('`') and c[1].endswith('`')):
                raise Unknown(f'{where}: needs `接続元` | `接続先` | 制約 outside subsections')
            milestone.append({'prerequisite': _unquote(c[0]), 'successor': _unquote(c[1]), 'constraint': c[2].replace(r'\|', '|')})
    return tasks, management, progress, milestone, out_of_scope, task_shaped


def parse_rules(text):
    m = re.search(r'^(.*?)は常設の支援nodeとして', text, re.M)
    if not m:
        raise Unknown('TASK_RULES_V2.md: the permanent-task sentence (…は常設の支援nodeとして) is missing')
    permanent = set(re.findall(r'`([A-Z]+-\d+)`', m.group(1)))
    body = _sections(text, '##').get('Task ID採番状態')
    if body is None:
        raise Unknown('TASK_RULES_V2.md: ## Task ID採番状態 is missing')
    ledger = {}
    for no, line, _, _ in _table_rows(body.split('\n')):
        if not line.startswith('|'):
            raise Unknown(f'TASK_RULES_V2.md Task ID採番状態 row {no}: indented table row')
        c = _cells(line)
        if len(c) != 2 or not re.fullmatch(r'`[A-Z]+`', c[0]) or not re.fullmatch(r'`\d+`', c[1]):
            raise Unknown(f'TASK_RULES_V2.md Task ID採番状態 row {no}: needs `PREFIX` | `NNN`')
        prefix = _unquote(c[0])
        if prefix in ledger:
            raise Unknown(f'TASK_RULES_V2.md Task ID採番状態: {prefix} appears twice')
        ledger[prefix] = int(_unquote(c[1]))
    if not ledger:
        raise Unknown('TASK_RULES_V2.md Task ID採番状態: no ledger rows')
    return permanent, ledger


def _card(rel, text, version_gate):
    top = _sections(text, '#')
    card = _sections(top.get('カード情報', ''), '##')
    cid = card.get('ID', '').strip('` \n')
    name = card.get('名前', '').split('\n')[0].strip()
    if not cid or not name:
        raise Unknown(f'{rel}: カード情報 needs ## ID and ## 名前')
    boxes = re.findall(r'^- \[( |x)\] DONE\s*$', card.get('状態', ''), re.M)
    if not version_gate and len(boxes) != 1:
        raise Unknown(f'{rel}: ## 状態 needs exactly one "- [ ] DONE" or "- [x] DONE", found {len(boxes)}')
    canon = top.get('正本', '')
    link = re.search(r'\]\(([^)]+)\)', canon)
    if link:
        detail = os.path.normpath(os.path.join(os.path.dirname(rel), link.group(1)))
    elif canon.startswith('このファイル'):
        detail = rel
    else:
        raise Unknown(f'{rel}: # 正本 needs a link or このファイル')
    return {'id': cid, 'name': name, 'detail': Path(detail).as_posix(), **({} if version_gate else {'recordedDone': boxes[0] == 'x'})}


def parse(dest, manifest, vkey):
    dest = Path(dest)
    read = lambda rel: (dest / rel).read_text(encoding='utf-8')
    tasks, management, progress, milestone, out_of_scope, task_shaped = parse_registry(read(REGISTRY))
    permanent, ledger = parse_rules(read(RULES))
    m = re.search(r'^# (\d+\.\d+\.\d+)\s*$', read(MILESTONES + '/HEAD.md'), re.M)
    if not m:
        raise Unknown("Milestones/HEAD.md needs a line '# x.y.z'")
    head = m.group(1)
    folders = {}
    for entry in manifest['listing']:
        parts = entry.rstrip('/').split('/')
        folders.setdefault(parts[2], [])
        if len(parts) == 3:
            continue  # the version folder itself
        folder, name = parts[2], parts[3]
        if entry.endswith('/') or not name.endswith('.md'):
            raise Unknown(f'{entry}: not a card, gate or GOAL.md (unknown entry in a version folder)')
        if name != 'GOAL.md':
            folders[folder].append(name)
    order = sorted(folders, key=vkey)
    if head not in folders:
        raise Unknown(f'HEAD names {head}, but there is no version folder {head}')
    versions = []
    for v in order:
        names = sorted(folders[v])  # file name order, as the current reader
        gates = [n for n in names if n.startswith('GATE-')]
        if len(gates) > 1:
            raise Unknown(f'{v}: more than one gate file')
        if gates and not re.fullmatch(r'GATE-\d+\.\d+\.\d+\.md', gates[0]):
            raise Unknown(f'{v}/{gates[0]}: a gate file must be named GATE-x.y.z.md')
        cards = [_card(f'{MILESTONES}/{v}/{n}', read(f'{MILESTONES}/{v}/{n}'), False) for n in names if not n.startswith('GATE-')]
        gate = _card(f'{MILESTONES}/{v}/{gates[0]}', read(f'{MILESTONES}/{v}/{gates[0]}'), True) if gates else None
        if gate and gate['id'] != gates[0][:-3]:
            raise Unknown(f'{v}/{gates[0]}: ## ID must be {gates[0][:-3]}')
        versions.append({'name': v, 'cards': cards, 'gate': gate})
    for t in tasks:
        t['permanent'] = t['id'] in permanent
    fixture = {'versions': versions, 'focus': head, 'tasks': tasks, 'management': management, 'progress': progress, 'milestone': milestone,
               'issuedThrough': ledger}
    consumption = {'tasks': len(tasks), 'management': len(management), 'progress': len(progress), 'milestone': len(milestone),
                   'versions': len(versions), 'cards': sum(len(v['cards']) for v in versions), 'gates': sum(1 for v in versions if v['gate']),
                   'ledgerPrefixes': len(ledger), 'outOfScopeRows': out_of_scope,
                   'taskShapedOutOfScope': task_shaped}
    return fixture, consumption


# ---- 4. compare ---------------------------------------------------------------------------------------------------

def deviations(fixture):
    """Places where the structural DESIGN and the current reader's gate rule differ (reported, never used as rules)."""
    out, names = [], [v['name'] for v in fixture['versions']]
    for i, v in enumerate(fixture['versions']):
        nxt = names[i + 1] if i + 1 < len(names) else None
        if v['gate'] is None:
            if nxt:
                out.append({'version': v['name'], 'case': 'missing gate', 'design': f'END-{v["name"]} and START-{nxt} unconnected'})
        elif nxt is None:
            out.append({'version': v['name'], 'case': 'terminal gate', 'design': f"END-{v['name']} -> {v['gate']['id']} ends there"})
        elif v['gate']['id'] != 'GATE-' + nxt:
            out.append({'version': v['name'], 'case': 'gate ID is not the next version', 'design': f"{v['gate']['id']} -> START-{nxt}"})
    return out


def reader_contract(sync, dest):
    root = Path(dest).resolve()
    sync.ROOT, sync.REGISTRY, sync.RULES, sync.MILESTONES = root, root / REGISTRY, root / RULES, root / MILESTONES
    data, errors = sync.build()
    if data is None:
        return None, errors
    cards = {}
    for m in data['milestones']:
        folder = m['gate'].split('/')[2]
        cards.setdefault(folder, [])
        if not m.get('virtual') and not m['id'].startswith('GATE-'):
            cards[folder].append(m['id'])
    reg = [r for r in data['milestoneRelations'] if r['source']['path'].endswith('TASK_REGISTRY_V2.md')]
    chain = [r for r in data['milestoneRelations'] if r['source']['path'].endswith('Milestones/README.md')]
    contract = {
        'tasks': {t['id']: {k: t[k] for k in ('state', 'owner', 'item', 'condition', 'detail', 'permanent', 'group')} for t in data['tasks']},
        'management': sorted([t['parentTask'], t['id']] for t in data['tasks'] if 'parentTask' in t),
        'progress': sorted([e['prerequisite'], e['successor'], e['flow'], e['constraint']] for e in data['edges']),
        'milestone': sorted([r['prerequisite'], r['successor'], r['constraint']] for r in reg),
        'skeleton': [[r['prerequisite'], r['successor']] for r in chain],
        'versions': list(cards),
        'cards': cards,
        'gates': {m['gate'].split('/')[2]: m['id'] for m in data['milestones'] if m['id'].startswith('GATE-')},
        'milestones': {m['id']: {'name': m['item'], 'detail': m['detail']} for m in data['milestones'] if not m.get('virtual')},
    }
    states = {m['id']: (m['state'], m['gate'].split('/')[2]) for m in data['milestones'] if not m.get('virtual') and not m['id'].startswith('GATE-')}
    return (contract, states, data['milestoneHead']), None


def db_contract(view):
    return {
        'tasks': view['ids']['tasks'],
        'management': view['relations']['management'],
        'progress': sorted([e['prerequisite'], e['successor'], e['flow'], e['constraint']] for e in view['edges']['progress']),
        'milestone': sorted([e['prerequisite'], e['successor'], e['constraint']] for e in view['edges']['milestone']),
        'skeleton': view['relations']['skeleton'],
        'versions': view['order']['versions'],
        'cards': view['order']['cards'],
        'gates': view['order']['gates'],
        'milestones': {k: {'name': v['name'], 'detail': v['detail']} for k, v in view['ids']['milestones'].items()},
    }


def compare(dest, fixture, sync, work):
    path = str(Path(work) / 'shadow.sqlite3')
    try:
        w3.create(path, fixture)
    except w3.Refused as error:  # a structural or ledger refusal of the experiment DB
        raise Unknown(f'the experiment DB refused the parsed input: {error}') from None
    conn = w3.open_db(path)
    try:
        whole, current = r3.read(conn, 'all'), r3.read(conn, 'current')
        allocations = dict(conn.execute('SELECT prefix, highwater FROM id_allocations'))
        reservation = {p: {'issuedThrough': fixture['issuedThrough'].get(p), 'highwater': n, 'next': f'{p}-{n + 1:03d}',
                           'reservedThroughHighwater': w3.is_reserved(conn, p, n) and not w3.is_reserved(conn, p, n + 1)} for p, n in sorted(allocations.items())}
        present = {}
        for t in fixture['tasks']:
            p, n = t['id'].rsplit('-', 1)
            present[p] = max(present.get(p, 0), int(n))
        ledger_gaps = sorted(p for p in present if p not in fixture['issuedThrough'])
    finally:
        conn.close()
    mine = db_contract(whole)
    reader, errors = reader_contract(sync, dest)
    result = {'reservation': reservation, 'ledgerMissingPrefixes': ledger_gaps,
              'ranges': {'focus': current['range']['focus'], 'currentVersions': current['order']['versions'], 'currentNodes': len(current['ids']['nodes']),
                         'allNodes': len(whole['ids']['nodes']), 'boundary': len(current['range']['boundary']), 'currentSources': len(current['sources']),
                         'allSources': len(whole['sources'])},
              'excluded': EXCLUDED, 'deviations': deviations(fixture)}
    if reader is None:
        result.update(equal=False, readerRefused=errors, differences=['current reader refused the copy'])
        return result
    contract, states, head = reader
    result['differences'] = sorted(k for k in set(contract) | set(mine) if contract.get(k) != mine.get(k))
    result['detail'] = {k: {'reader': contract.get(k), 'db': mine.get(k)} for k in result['differences']}
    order = [v['name'] for v in fixture['versions']]
    checked, before_head = [], []
    for v in fixture['versions']:
        for c in v['cards']:
            state, folder = states[c['id']]
            if order.index(folder) < order.index(head):
                before_head.append({'id': c['id'], 'recordedDone': c['recordedDone'], 'readerState': state})
            elif (state == 'DONE') != c['recordedDone']:
                result['differences'].append('recordedDone ' + c['id'])
            else:
                checked.append(c['id'])
    result['recordedDone'] = {'checkedAgainstReader': checked, 'beforeHeadReaderDerived': before_head}
    result['equal'] = not result['differences']
    result['compared'] = sorted(contract) + ['recordedDone (folders from HEAD on)']
    return result


def run(root=REPO, after_copy=None, tamper=None):
    """The whole pipeline on root. Returns the report; raises Refusal on drift, tampering or unknown input."""
    sync = load_sync()
    with tempfile.TemporaryDirectory(prefix='ops163-shadow-') as tmp:
        dest, work = Path(tmp) / 'copy', Path(tmp) / 'work'
        dest.mkdir()
        work.mkdir()
        manifest = snapshot(root, dest, after_copy)
        if tamper:
            tamper(dest)
        verify(dest, manifest)
        fixture, consumption = parse(dest, manifest, sync.vkey)
        result = compare(dest, fixture, sync, work)
    return {'manifest': manifest, 'orderSource': 'sync.vkey on the captured folder names (current implementation order, fixed input)',
            'consumption': consumption, **result}


def import_db(db_path, root=REPO, after_copy=None, tamper=None, _before_link=None):
    """B3 (OPS-167 K9): a persistent V3 DB from the same pipeline as run() (snapshot, verify, parse, compare), made only
    when the comparison is equal. db_path must not exist (never overwritten) and its directory must exist (never
    created). The DB is created under a temporary name in that directory from the same parsed fixture, read back and
    compared with the current reader on the same copy once more, and then linked into place without clobbering. The
    temporary DB lives in a directory this call creates exclusively (tempfile.mkdtemp) next to db_path, so the link stays
    on one filesystem; only that owned directory is removed afterwards, and no file it did not create is touched. Any
    failure leaves nothing at db_path. Returns the report with 'created' (the path, or None when the comparison found
    differences)."""
    db = Path(db_path)
    if db.exists() or db.is_symlink():
        raise Exists(f'{db} already exists; an import never overwrites a DB')
    if not db.parent.is_dir():
        raise Unknown(f'{db.parent} is not an existing directory; an import never creates one')
    sync = load_sync()
    with tempfile.TemporaryDirectory(prefix='k9-import-') as tmp:
        dest, work = Path(tmp) / 'copy', Path(tmp) / 'work'
        dest.mkdir()
        work.mkdir()
        manifest = snapshot(root, dest, after_copy)
        if tamper:
            tamper(dest)
        verify(dest, manifest)
        fixture, consumption = parse(dest, manifest, sync.vkey)
        result = compare(dest, fixture, sync, work)
        report = {'manifest': manifest, 'orderSource': 'sync.vkey on the captured folder names (current implementation order, fixed input)',
                  'consumption': consumption, **result, 'created': None}
        if not result['equal']:
            return report
        owned = Path(tempfile.mkdtemp(prefix=f'.{db.name}.importing-', dir=db.parent))  # exclusively ours
        partial = owned / db.name
        try:
            w3.create(str(partial), fixture)
            conn = w3.open_db(str(partial))
            try:
                mine = db_contract(r3.read(conn, 'all'))
            finally:
                conn.close()
            reader, errors = reader_contract(sync, dest)
            if reader is None or reader[0] != mine:
                raise Unknown(f'the created DB does not read back as the current reader: {errors or "differences"}')
            if _before_link:
                _before_link(db)
            try:
                os.link(partial, db)  # never clobbers: FileExistsError if something appeared at db_path meanwhile
            except FileExistsError:
                raise Exists(f'{db} appeared while importing; nothing was overwritten') from None
        finally:
            shutil.rmtree(owned)  # only the directory this call created
    report['created'] = str(db)
    return report


def main(argv):
    ap = argparse.ArgumentParser(description=__doc__.split('\n')[0])
    ap.add_argument('--evidence', help='write the report JSON here')
    ap.add_argument('--create-db', help='B3: also create a persistent V3 DB at this new path when the comparison is equal')
    args = ap.parse_args(argv[1:])
    try:
        report = import_db(args.create_db) if args.create_db else run()
    except Refusal as error:
        print(f'{error.kind}: {error}', file=sys.stderr)
        return 2
    if args.evidence:
        Path(args.evidence).write_text(json.dumps(report, ensure_ascii=False, indent=1) + '\n', encoding='utf-8')
    c = report['consumption']
    print(f"equal={report['equal']} differences={report['differences']}")
    print(f"consumed: tasks {c['tasks']}, management {c['management']}, progress {c['progress']}, milestone links {c['milestone']}, "
          f"versions {c['versions']}, cards {c['cards']}, gates {c['gates']}, ledger prefixes {c['ledgerPrefixes']}; out-of-scope table rows {len(c['outOfScopeRows'])}, "
          f"task-shaped among them {len(c['taskShapedOutOfScope'])}")
    print(f"deviations={report['deviations']} ledgerMissingPrefixes={report['ledgerMissingPrefixes']}")
    print(f"ranges={report['ranges']}")
    if args.create_db:
        print(f"created={report['created']}")
    return 0 if report['equal'] else 1


if __name__ == '__main__':
    sys.exit(main(sys.argv))
