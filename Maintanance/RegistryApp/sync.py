#!/usr/bin/env python3
"""Regenerate the Registry Studio snapshot from the Task Registry in one command.

Usage (from the repository root):
  python3 Maintanance/RegistryApp/sync.py --check   # report drift only; writes nothing
  python3 Maintanance/RegistryApp/sync.py           # regenerate registry.json and the HTML seed
  python3 Maintanance/RegistryApp/sync.py --show-tools  # which node/marked would be used, and from where
  python3 Maintanance/RegistryApp/sync.py --v3-db PATH  # V3 mode (OPS-167 B4): see main_v3

registry.json is built from nothing on every run (2026-10-17): tasks, edges and the milestone connection
table come from the Task Registry; milestone cards from the gate files in Maintanance/Milestones/; the
current position from Milestones/HEAD.md. Nothing is carried over from the previous registry.json. The
existing file is read only to report what changed, and it may be missing.
"""
import datetime, hashlib, json, re, subprocess, sys
from pathlib import Path

import os, shutil, tempfile
ROOT = Path(__file__).resolve().parent.parent.parent
CODE = Path(__file__).resolve().parent
APP = Path(os.environ.get('REGISTRY_STUDIO_APP', ROOT / 'Maintanance/Cache/RegistryStudio'))
REGISTRY = ROOT / 'Maintanance/ProgressV2/TASK_REGISTRY_V2.md'
RULES = ROOT / 'Maintanance/ProgressV2/TASK_RULES_V2.md'
JSON = APP / 'registry.json'
HTML = APP / 'index.html'
JST = datetime.timezone(datetime.timedelta(hours=9))


def assemble_template():
    text = (CODE / 'index.template.html').read_text(encoding='utf-8')
    text = text.replace('/* include:index.css */', (CODE / 'index.css').read_text(encoding='utf-8'))
    for name in ('topbar', 'work', 'task'):
        marker = f'<!-- include:index.{name}.html -->'
        if text.count(marker) != 1:
            raise ValueError(f'Expected one template include: {marker}')
        text = text.replace(marker, (CODE / f'index.{name}.html').read_text(encoding='utf-8'))
    def include_script(match):
        name, section = match.groups()
        source = (CODE / f'index.{name}.js').read_text(encoding='utf-8')
        blocks = re.findall(r'(?ms)^// @section (\w+)\n(.*?)\n// @endsection(?:\n|$)', source)
        matches = [body for key, body in blocks if key == section]
        if len(matches) != 1:
            raise ValueError(f'Expected one script section: {name}#{section}')
        body = matches[0]
        def include_work(match):
            region, part = match.groups()
            source = (CODE / f'index.work.{region}.js').read_text(encoding='utf-8')
            blocks = re.findall(r'(?ms)^// @section ([\w-]+)\n(.*?)\n// @endsection(?:\n|$)', source)
            selected = [text for key, text in blocks if key == part]
            if len(selected) != 1:
                raise ValueError(f'Expected one work section: {region}#{part}')
            return selected[0]
        return re.sub(r'// include-work:([a-z-]+)#([a-z-]+)\n?', include_work, body)
    text = re.sub(r'(?m)^[ \t]*// include:index\.(topbar|work|task)\.js#(\w+)\n', include_script, text)
    return text


def sha256(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def cells(line):
    # Split a Markdown table row on unescaped pipes.
    parts = re.split(r'(?<!\\)\|', line.strip())
    return [p.strip() for p in parts[1:-1]]


def unquote(s):
    return s[1:-1] if len(s) >= 2 and s[0] == s[-1] == '`' else s


def permanent_ids():
    text = RULES.read_text(encoding='utf-8')
    m = re.search(r'^(.*?)は常設の支援nodeとして', text, re.M)
    return set(re.findall(r'`([A-Z]+-\d+)`', m.group(1))) if m else set()


def parse_registry():
    lines = REGISTRY.read_text(encoding='utf-8').split('\n')
    perm = permanent_ids()
    tasks, edges, section, group, parents, bad = [], [], None, None, {}, []
    for no, line in enumerate(lines, 1):
        if line.startswith('## '):
            section, group = line[3:].strip(), None
        elif line.startswith('### '):
            group = line[4:].strip()
        if not line.startswith('| `'):
            continue
        c = cells(line)
        if section == 'Task Registry' and len(c) == 6:
            tasks.append(dict(id=unquote(c[0]), state=unquote(c[1]), owner=c[2], item=c[3], condition=c[4],
                              detail=c[5], raw=line, sourceLine=no, group=group, permanent=unquote(c[0]) in perm))
        elif section == '恒久タスクの親子関係' and len(c) == 2:
            parents[unquote(c[1])] = unquote(c[0])
            if not all(re.fullmatch(r'`[A-Z]+-\d+`', x) for x in c):
                bad.append(f'Registry line {no}: 恒久タスクの親子関係 needs `PARENT-ID` | `CHILD-ID` only, got: {line}')
        elif section == 'Task precedence' and len(c) == 4 and group is None:
            edges.append(dict(successor=unquote(c[0]), prerequisite=unquote(c[1]), flow=unquote(c[2]),
                              constraint=c[3], raw=line, sourceLine=no))
    ids = {t['id'] for t in tasks}
    for child, parent in parents.items():
        if child in ids and parent not in ids:
            bad.append(f'恒久タスクの親子関係: parent {parent} of {child} is not in the Task Registry')
    for t in tasks:
        if t['id'] in parents:
            t['parentTask'] = parents[t['id']]
    REGISTRY_PROBLEMS[:] = bad
    return tasks, edges


REGISTRY_PROBLEMS = []  # filled by parse_registry(); build() stops on them


def git(*args):
    return subprocess.run(['git', *args], cwd=ROOT, capture_output=True, text=True).stdout.strip()


MILESTONES = ROOT / 'Maintanance/Milestones'


def vkey(name):
    """Sort key for version folder names: numbers numerically, anything else as text."""
    return tuple((0, int(x), '') if x.isdigit() else (1, 0, x) for x in re.split(r'[.\-]', name))


def version_folders():
    """Every folder under Milestones/ is a version folder, except names starting with '_'."""
    return sorted((d for d in MILESTONES.iterdir() if d.is_dir() and not d.name.startswith('_')),
                  key=lambda d: vkey(d.name))


def folder_id(name):
    return name  # the folder name as it is (END-0.5.4); dots are kept so 0.1.10 and 0.11.0 stay distinct


def head_name():
    """Current position from Milestones/HEAD.md ('# x.y.z'). Raises ValueError when missing or malformed."""
    path = MILESTONES / 'HEAD.md'
    if not path.exists():
        raise ValueError('Milestones/HEAD.md is missing')
    m = re.search(r'^# (\d+\.\d+\.\d+)\s*$', path.read_text(encoding='utf-8'), re.M)
    if not m:
        raise ValueError("Milestones/HEAD.md needs a line '# x.y.z'")
    return m.group(1)


def head_version():
    """Version gates up to HEAD are passed."""
    return vkey(head_name())


def sections(text, level):
    """Split markdown into {heading: body} at the given heading level ('#' or '##')."""
    out, name = {}, None
    for line in text.split('\n'):
        m = re.match(r'^' + level + r' (.+)$', line)
        if m:
            name = m.group(1).strip()
            out[name] = []
        elif name is not None:
            out[name].append(line)
    return {k: '\n'.join(v).strip() for k, v in out.items()}


def gate_state(path, version_gate, state):
    """Version gates are passed when HEAD has reached their version (no checkbox). Gates in a folder
    before HEAD are passed with it; intermediate cards follow their DONE checkbox."""
    head, folder = head_version(), vkey(path.parent.name)
    if version_gate:
        return 'DONE' if vkey('.'.join(re.findall(r'\d+', path.stem))) <= head else 'ACTIVE'
    return 'DONE' if folder < head or '- [x] DONE' in state else 'ACTIVE'


def read_gates():
    """Milestone cards from Maintanance/Milestones/<version>/*.md (2026-10-17 gate format).

    Each gate file has three parts: '# カード情報' (## ID / ## 名前 / ## 状態), '# 正本' (a link or
    'このファイル'), and '# 記録' (free text, never read). The ID is the gate's identity: never reuse or repurpose one. Gates whose ID
    is 'なし' or a Task Registry task are not Studio milestones. Returns (cards, errors)."""
    cards, errors = [], []
    task_ids = {t['id'] for t in parse_registry()[0]}
    def order(p):  # file name order within a folder; a number prefix is recommended, not required
        return p.name
    for path in [p for d in version_folders() for p in sorted(d.glob('*.md'), key=order)]:
        if path.name == 'GOAL.md':
            continue  # GOAL.md only keeps the folder and is ignored (Milestones/DESIGN.md「GOALファイル」, OPS-080)
        rel = path.relative_to(ROOT).as_posix()
        if path.name.startswith('GATE-') and not re.fullmatch(r'GATE-\d+\.\d+\.\d+\.md', path.name):
            errors.append(f'{rel}: a release gate file must be named GATE-x.y.z.md'); continue
        top = sections(path.read_text(encoding='utf-8'), '#')
        card = sections(top.get('カード情報', ''), '##')
        gid = card.get('ID', '').strip('` \n')
        name = card.get('名前', '').split('\n')[0].strip()
        state = card.get('状態', '')
        version_gate = path.name.startswith('GATE-')
        if not gid or not name or (not version_gate and not re.search(r'- \[( |x)\] DONE', state)):
            errors.append(f'{rel}: カード情報 needs ## ID, ## 名前 (and "- [ ] DONE" under ## 状態 for intermediate cards)'); continue
        vm = re.fullmatch(r'GATE-(\d+)\.(\d+)\.(\d+)\.md', path.name)
        if vm and (gid != 'GATE-' + '.'.join(vm.groups()) or not name.startswith('.'.join(vm.groups()) + ' ')):
            errors.append(f"{rel}: version gate needs ## ID `GATE-{'.'.join(vm.groups())}` and ## 名前 "
                          f"'{'.'.join(vm.groups())} リリース'"); continue
        if gid == 'なし':
            errors.append(f'{rel}: ## ID is なし; every gate needs its own ID'); continue
        if gid in task_ids:
            errors.append(f'{rel}: ## ID {gid} is also a Task Registry task'); continue
        canon = top.get('正本', '')  # its own top-level part since 2026-10-17 (not part of the card)
        link = re.search(r'\]\(([^)]+)\)', canon)
        if link:
            target = (path.parent / link.group(1)).resolve()
            if not target.exists():
                errors.append(f'{rel}: 正本 link not found: {link.group(1)}'); continue
            detail = target.relative_to(ROOT).as_posix()
        elif canon.startswith('このファイル'):
            detail = rel
        else:
            errors.append(f'{rel}: # 正本 needs a link or "このファイル"'); continue
        cond = f'ゲート：{rel}\n正本：{detail}'
        cards.append(dict(id=gid, kind='milestone', item=name,
                          state=gate_state(path, version_gate, state),
                          owner='ユーザー同席（AI単独では扱わない）', condition=cond, detail=detail, raw=cond,
                          gate=rel))
    cards = add_ends(cards, errors)
    for gid in sorted({c['id'] for c in cards}):
        files = [c['gate'] for c in cards if c['id'] == gid]
        if len(files) > 1:
            errors.append(f'duplicate ID {gid}: ' + ', '.join(files))
    return cards, errors


END_RULE = 'END-x.y.z は版フォルダごとの集合点で、実ファイルを置かない'


def add_ends(cards, errors=None):
    """Each version folder gets a virtual END-xyz just before its release gate (no file)."""
    folders = [d.name for d in version_folders()]
    out = []
    for name in folders:
        mine = [c for c in cards if Path(c['gate']).parent.name == name]
        mid = [c for c in mine if not Path(c['gate']).name.startswith('GATE-')]
        rel = [c for c in mine if Path(c['gate']).name.startswith('GATE-')]
        sid = 'START-' + folder_id(name)  # entry of the folder's work interval (OPS-069, step 1); identifier only
        eid = 'END-' + folder_id(name)  # identifier only: no name or condition of its own
        virtual = lambda i, done: dict(id=i, kind='milestone', item=i, state='DONE' if done else 'ACTIVE', owner='',
                                       condition='', raw='', detail='Maintanance/Milestones/README.md',
                                       gate=f'Maintanance/Milestones/{name}/', virtual=True)
        out += [virtual(sid, vkey(name) <= head_version())] + mid + [virtual(eid, vkey(name) < head_version())] + rel
    # Folder placement defines the source; gate ID defines the destination.
    errors = errors if errors is not None else []
    groups = {name: [c for c in out if (Path(c['gate'].rstrip('/')).name if c.get('virtual')
                                      else Path(c['gate']).parent.name) == name] for name in folders}
    targets = {}
    for name, group in groups.items():
        gates = [c for c in group if c['id'].startswith('GATE-')]
        if len(gates) > 1:
            errors.append(f'{name}: multiple release gates'); continue
        if gates:
            target = gates[0]['id'][5:]
            if target not in groups:
                errors.append(f'{name}: destination folder missing: {target}')
            else:
                targets[name] = target
    incoming = list(targets.values())
    if len(incoming) != len(set(incoming)):
        errors.append('Release gates merge into the same folder')
    roots = [name for name in folders if name not in incoming]
    ordered, seen = [], set()
    current = roots[0] if len(roots) == 1 else None
    while current is not None and current not in seen:
        seen.add(current)
        ordered.extend(groups[current])
        current = targets.get(current)
    if current is not None or len(seen) != len(folders):
        errors.append('Release path must be one connected sequence without cycles')
    return ordered if len(seen) == len(folders) else out


def registry_milestone_relations():
    """Task/milestone connections come exclusively from the Registry table."""
    result, active = [], False
    for no, line in enumerate(REGISTRY.read_text(encoding='utf-8').splitlines(), 1):
        if line.startswith('## '):
            active = line == '## マイルストーン接続'
        if not active or not line.startswith('| `'):
            continue
        c = cells(line)
        if len(c) != 3:
            raise ValueError(f'Registry line {no}: invalid milestone connection row (expected 3 columns: 接続元 | 接続先 | 制約; line kinds were retired 2026-10-17)')
        result.append(dict(prerequisite=unquote(c[0]), successor=unquote(c[1]),
                           constraint=c[2].replace(r'\|', '|'),
                           source=dict(path=REGISTRY.relative_to(ROOT).as_posix(), quote=line,
                                       sha256=sha256(REGISTRY), line=no)))
    return result


def chain_relations(cards):
    """Topology comes from placement. Lines have no kind (retired 2026-10-17); conditions live in card text."""
    path = ROOT / 'Maintanance/Milestones/README.md'
    lines = path.read_text(encoding='utf-8').splitlines()
    no = lines.index(next(line for line in lines if END_RULE in line)) + 1
    chain = []
    for a, b in zip(cards, cards[1:]):
        chain.append(dict(prerequisite=a['id'], successor=b['id'],
                          constraint='接続はゲートの配置から生成。条件は各カードの本文。',
                          source=dict(path=path.relative_to(ROOT).as_posix(), quote=END_RULE,
                                      sha256=sha256(path), line=no)))
    return registry_milestone_relations() + chain


def build():
    """The whole snapshot from the sources of truth; no input from an earlier registry.json.
    Returns (data, errors); data is None when the sources are invalid, so nothing gets written."""
    tasks, edges = parse_registry()
    if REGISTRY_PROBLEMS:
        return None, list(REGISTRY_PROBLEMS)
    try:
        head = head_name()
    except ValueError as e:
        return None, [str(e)]
    milestones, errors = read_gates()
    if head not in [d.name for d in version_folders()]:
        errors.append(f'Milestones/HEAD.md names {head}, but Milestones/{head}/ does not exist')
    if errors:
        return None, errors
    try:
        relations = chain_relations(milestones)
    except ValueError as e:
        return None, [str(e)]
    copy = lambda x: json.loads(json.dumps(x))
    return dict(
        schemaVersion=1,
        source=dict(path='Maintanance/ProgressV2/TASK_REGISTRY_V2.md', head=git('rev-parse', '--short=8', 'HEAD'),
                    sha256=sha256(REGISTRY), dirty=bool(git('status', '--porcelain', '--', str(REGISTRY))),
                    generatedAt=datetime.datetime.now(JST).isoformat(), generator='sync.py',
                    rulesSha256=sha256(RULES)),
        tasks=tasks, edges=edges,
        baseline=dict(tasks=copy(tasks), edges=copy(edges), milestoneRelations=copy(relations)),
        milestones=milestones, milestoneRelations=relations,
        milestoneHead=head), []  # current position for the Studio picker


def diff(old, new):
    out = []
    o, n = {t['id']: t for t in old['tasks']}, {t['id']: t for t in new['tasks']}
    for i in sorted(set(o) | set(n)):
        if i not in o:
            out.append(f'+ task {i}')
        elif i not in n:
            out.append(f'- task {i}')
        else:
            changed = [k for k in sorted(set(o[i]) | set(n[i])) if o[i].get(k) != n[i].get(k) and k != 'sourceLine']
            if changed:
                out.append(f'~ task {i}: {", ".join(changed)}')
    key = lambda e: (e['successor'], e['prerequisite'])
    oe, ne = {key(e): e for e in old['edges']}, {key(e): e for e in new['edges']}
    out += [f'+ edge {a} <- {b}' for a, b in sorted(set(ne) - set(oe))]
    out += [f'- edge {a} <- {b}' for a, b in sorted(set(oe) - set(ne))]
    out += [f'~ edge {a} <- {b}' for a, b in sorted(set(ne) & set(oe)) if ne[(a, b)]['flow'] != oe[(a, b)]['flow'] or ne[(a, b)]['constraint'] != oe[(a, b)]['constraint']]
    moved = sum(1 for k in set(ne) & set(oe) if ne[k]['sourceLine'] != oe[k]['sourceLine']) + sum(1 for i in set(o) & set(n) if o[i].get('sourceLine') != n[i].get('sourceLine'))
    if moved:
        out.append(f'~ sourceLine moved for {moved} rows (position only)')
    om, nm = {m['id']: m for m in old.get('milestones', [])}, {m['id']: m for m in new.get('milestones', [])}
    out += [f'+ milestone {i}' for i in sorted(set(nm) - set(om))] + [f'- milestone {i}' for i in sorted(set(om) - set(nm))]
    out += [f'~ milestone {i}: ' + ', '.join(k for k in ('item', 'state', 'detail', 'gate') if om[i].get(k) != nm[i].get(k))
            for i in sorted(set(om) & set(nm)) if any(om[i].get(k) != nm[i].get(k) for k in ('item', 'state', 'detail', 'gate'))]
    rk = lambda r: (r['prerequisite'], r['successor'])
    orr, nrr = {rk(r) for r in old.get('milestoneRelations', [])}, {rk(r) for r in new.get('milestoneRelations', [])}
    out += [f'+ relation {a} -> {b}' for a, b in sorted(nrr - orr)] + [f'- relation {a} -> {b}' for a, b in sorted(orr - nrr)]
    if old['source'].get('sha256') != new['source']['sha256']:
        out.append(f"~ source sha256 {old['source'].get('sha256', '')[:12]} -> {new['source']['sha256'][:12]}")
    for k in ('rulesSha256', 'head', 'dirty'):
        if old['source'].get(k) != new['source'].get(k):
            out.append(f'~ source {k}')
    return out


def seed_of(html):
    m = re.search(r'<script id="seed" type="application/json">(.*?)</script>', html, re.S)
    return json.loads(m.group(1)) if m else None


def same_content(a, b):
    strip = lambda d: {**d, 'source': {k: v for k, v in d['source'].items() if k != 'generatedAt'}}
    return strip(a) == strip(b)


def embed(data):
    s = HTML.read_text(encoding='utf-8')
    block = '<script id="seed" type="application/json">' + json.dumps(data, ensure_ascii=False).replace('<', '\\u003c') + '</script>'
    s, n = re.subn(r'<script id="seed" type="application/json">.*?</script>', lambda m: block, s, count=1, flags=re.S)
    if n != 1:
        raise ValueError('seed block not found in index.html')
    HTML.write_text(s, encoding='utf-8')


def tool(flag, env, default):
    if flag in sys.argv:
        return sys.argv[sys.argv.index(flag) + 1]
    return os.environ.get(env) or default


# ---- Node / marked resolution (2026-10-17, OPS-065) ---------------------------------------------
# Order: --flag > environment variable > saved local record (reused only if it still works) > PATH >
# known install locations. The record is environment-specific and untracked; the README describes
# how to check it, not where the binaries are.
TOOLS_RECORD = Path(os.environ.get('REGISTRY_STUDIO_TOOLS', CODE / 'local-tools.json'))  # the override is for isolated runs (OPS-167 K9)
NODE_CANDIDATES = [
    '~/.cache/codex-runtimes/*/dependencies/node/bin/node',
    '/opt/homebrew/bin/node', '/usr/local/bin/node',
    '~/.nvm/versions/node/*/bin/node', '~/.volta/bin/node',
    '/Applications/ChatGPT.app/Contents/Resources/cua_node/bin/node',
]
MARKED_RELATIVE = ['node_modules/marked/lib/marked.esm.js', 'lib/node_modules/marked/lib/marked.esm.js']


def node_works(path):
    try:
        out = subprocess.run([path, '--version'], capture_output=True, text=True, timeout=10)
        return out.stdout.strip() if out.returncode == 0 and out.stdout.startswith('v') else None
    except (OSError, subprocess.SubprocessError):
        return None


def marked_works(path):
    return bool(path) and Path(path).is_file() and Path(path).name == 'marked.esm.js'


def read_tools_record():
    try:
        return json.loads(TOOLS_RECORD.read_text(encoding='utf-8')) if TOOLS_RECORD.exists() else {}
    except (OSError, json.JSONDecodeError):
        return {}


def search_node():
    for pattern in NODE_CANDIDATES:
        full = os.path.expanduser(pattern)
        hits = sorted(Path('/').glob(full.lstrip('/')), reverse=True) if '*' in full else ([Path(full)] if Path(full).exists() else [])
        for hit in hits:
            if node_works(str(hit)):
                return str(hit)
    return None


def search_marked(node):
    if not node:
        return None
    root = Path(node).resolve().parent.parent  # <prefix>/bin/node -> <prefix>
    for rel in MARKED_RELATIVE:
        cand = root / rel
        if marked_works(cand):
            return str(cand)
    return None


def resolve_tools():
    """Return (node, marked, notes). Each value comes with where it came from, for the report."""
    notes, record = [], read_tools_record()
    node = tool('--node', 'REGISTRY_STUDIO_NODE', None)
    if node:
        notes.append(f'node: {node} (flag/env)')
    elif record.get('node') and node_works(record['node']):
        node = record['node']; notes.append(f"node: {node} (saved record, {record.get('nodeVersion', '?')})")
    else:
        if record.get('node'):
            notes.append(f"node: saved record {record['node']} no longer works; searching")
        node = shutil.which('node')
        if node:
            notes.append(f'node: {node} (PATH)')
        else:
            node = search_node()
            notes.append(f'node: {node} (search)' if node else 'node: not found')
    marked = tool('--marked', 'REGISTRY_STUDIO_MARKED', None)
    if marked:
        notes.append(f'marked: {marked} (flag/env)')
    elif record.get('marked') and marked_works(record['marked']):
        marked = record['marked']; notes.append(f'marked: {marked} (saved record)')
    else:
        if record.get('marked'):
            notes.append(f"marked: saved record {record['marked']} no longer exists; searching")
        marked = search_marked(node)
        notes.append(f'marked: {marked} (search)' if marked else "marked: not found; build-documents.mjs will try the environment's marked")
    return node, marked, notes


def save_tools_record(node, marked):
    version = node_works(node)
    if not version:
        return
    record = dict(node=node, nodeVersion=version, marked=marked,
                  verifiedAt=datetime.datetime.now(datetime.timezone(datetime.timedelta(hours=9))).isoformat(timespec='seconds'),
                  note='Environment-specific; untracked. Delete this file to force a fresh search. See RegistryApp/README.md.')
    TOOLS_RECORD.write_text(json.dumps(record, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')


EMPTY = dict(tasks=[], edges=[], source={})
DOC_REF = re.compile(r'(?:Maintanance|Sources|Tests)/[^`\s|]+?\.md')  # the references build-documents.mjs bundles


def main_v3(db):
    """V3 mode (OPS-167 B4), used by serve.py --v3-db: the page data is the read-only export of the V3 DB (tasks, graph,
    versions, cards, focus all come from the DB), so the Markdown Registry and the Milestones folders are not validated
    as structure here. Documents and the pending queue are built as in the legacy mode (build-pending.py,
    build-documents.mjs), and the Registry view itself stays a bundled document. Every document the DB refers to must
    exist (none is silently left out): a missing one fails the run before anything is written. The result is checked
    by v3/verify_v3.cjs; on any failure the previous registry.json and index.html are restored."""
    db = Path(db)
    if not db.is_file():
        print(f'--v3-db {db}: no such file (it is never created)')
        sys.exit(1)
    sys.path.insert(0, str(CODE / 'v3'))
    import sqlite3
    import studio_adapter
    conn = sqlite3.connect(db.resolve().as_uri() + '?mode=ro', uri=True, isolation_level=None, timeout=5.0)
    try:
        data = studio_adapter.export_doc(conn)
    finally:
        conn.close()
    refs = sorted({m for item in data['tasks'] + data['milestones'] for m in DOC_REF.findall(item.get('detail') or '')})
    missing = [r for r in refs if not (ROOT / r).is_file()]
    if missing:
        print('Documents the V3 DB refers to are missing (nothing was written):\n  ' + '\n  '.join(missing))
        sys.exit(1)
    data['extraDocuments'] = [REGISTRY.relative_to(ROOT).as_posix()]  # the Registry view, bundled as the legacy source is
    print(f"V3 DB {db}: generation {data['source']['generation']}, revision {data['source']['revision']}; "
          f"tasks {len(data['tasks'])}, milestones {len(data['milestones'])}, documents referenced {len(refs)}")
    node, marked, tool_notes = resolve_tools()
    print('\n'.join(tool_notes))
    APP.mkdir(parents=True, exist_ok=True)
    child_env = dict(os.environ, REGISTRY_STUDIO_APP=str(APP.resolve()))
    backup = Path(tempfile.mkdtemp(prefix='registry-studio-sync-'))
    saved = [f for f in (JSON, HTML) if f.exists()]
    for f in saved:
        shutil.copy2(f, backup / f.name)
    try:
        HTML.write_text(assemble_template(), encoding='utf-8')
        JSON.write_text(json.dumps(data, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
        embed({k: v for k, v in data.items() if k != 'extraDocuments'})
        subprocess.run([sys.executable, str(CODE / 'build-pending.py')], cwd=ROOT, check=True, env=child_env)
        if not node:
            raise FileNotFoundError('node not found; documents cannot be rebuilt or verified. Pass --node PATH once (it is then saved to local-tools.json), or see RegistryApp/README.md')
        subprocess.run([node, str(CODE / 'build-documents.mjs')] + ([marked] if marked else []), cwd=CODE, check=True, env=child_env)
        subprocess.run([node, str(CODE / 'v3' / 'verify_v3.cjs')], cwd=CODE, check=True, env=child_env)
    except (subprocess.CalledProcessError, OSError, ValueError) as e:
        for f in saved:
            shutil.copy2(backup / f.name, f)
        for f in (JSON, HTML):
            if f not in saved and f.exists():
                f.unlink()
        shutil.rmtree(backup)
        print(f'FAILED ({e}); restored registry.json and index.html to their state before this run')
        sys.exit(1)
    shutil.rmtree(backup)
    save_tools_record(node, marked)
    print('sync complete (V3): registry.json from the DB, HTML seed, pending queue, documents, verify_v3.cjs passed')


def main():
    if '--v3-db' in sys.argv:  # checked before any side effect; unsupported combinations are refused, never ignored
        i = sys.argv.index('--v3-db')
        if i + 1 >= len(sys.argv) or sys.argv[i + 1].startswith('--'):
            print('--v3-db needs the path of an existing V3 DB')
            sys.exit(2)
        clash = [f for f in ('--check', '--show-tools') if f in sys.argv]
        if clash:
            print(f"--v3-db cannot be combined with {', '.join(clash)} (not supported in V3 mode; nothing was done)")
            sys.exit(2)
        return main_v3(sys.argv[i + 1])
    if '--show-tools' in sys.argv:
        node, marked, notes = resolve_tools()
        print('\n'.join(notes))
        print(f'record: {TOOLS_RECORD} ({"present" if TOOLS_RECORD.exists() else "absent"})')
        sys.exit(0 if node else 1)
    new, errors = build()
    if errors:
        print('Source problems (fix them; nothing was written):\n  ' + '\n  '.join(errors))
        sys.exit(1)
    old, note = None, None  # the previous registry.json is for the change report only
    if JSON.exists():
        try:
            old = json.loads(JSON.read_text(encoding='utf-8'))
        except json.JSONDecodeError:
            note = '~ previous registry.json was unreadable; regenerated from the sources'
    try:
        seed = seed_of(HTML.read_text(encoding='utf-8'))
    except (json.JSONDecodeError, FileNotFoundError):
        seed = None
    changes = diff(old or EMPTY, new)
    if old is None:
        changes.insert(0, note or '+ registry.json (generated from nothing)')
    if seed != old:
        changes.append('~ HTML seed differs from registry.json')
    print(f"tasks {len(new['tasks'])}, edges {len(new['edges'])}, milestones {len(new['milestones'])} (from gate files)")
    print('\n'.join(changes) if changes else 'no drift between Task Registry, registry.json, and the HTML seed')
    if '--check' in sys.argv:
        sys.exit(1 if changes else 0)

    node, marked, tool_notes = resolve_tools()
    print('\n'.join(tool_notes))
    if old and same_content(old, new) and seed == old:
        new['source']['generatedAt'] = old['source'].get('generatedAt')  # no meaningless diff on rerun
    APP.mkdir(parents=True, exist_ok=True)
    child_env = dict(os.environ, REGISTRY_STUDIO_APP=str(APP.resolve()))
    backup = Path(tempfile.mkdtemp(prefix='registry-studio-sync-'))
    saved = [f for f in (JSON, HTML) if f.exists()]
    for f in saved:
        shutil.copy2(f, backup / f.name)
    try:
        HTML.write_text(assemble_template(), encoding='utf-8')
        JSON.write_text(json.dumps(new, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
        embed(new)
        subprocess.run([sys.executable, str(CODE / 'build-pending.py')], cwd=ROOT, check=True, env=child_env)
        if not node:
            raise FileNotFoundError('node not found; documents cannot be rebuilt or verified. Pass --node PATH once (it is then saved to local-tools.json), or see RegistryApp/README.md')
        subprocess.run([node, str(CODE / 'build-documents.mjs')] + ([marked] if marked else []), cwd=CODE, check=True, env=child_env)
        subprocess.run([node, str(CODE / 'verify.cjs')], cwd=CODE, check=True, env=child_env)
    except (subprocess.CalledProcessError, OSError, ValueError) as e:
        for f in saved:
            shutil.copy2(backup / f.name, f)
        for f in (JSON, HTML):
            if f not in saved and f.exists():
                f.unlink()
        shutil.rmtree(backup)
        print(f'FAILED ({e}); restored registry.json and index.html to their state before this run')
        sys.exit(1)
    shutil.rmtree(backup)
    save_tools_record(node, marked)
    print('sync complete: registry.json, HTML seed, pending queue, documents, verify.cjs passed')


if __name__ == '__main__':
    main()
