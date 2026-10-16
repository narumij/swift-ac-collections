#!/usr/bin/env python3
"""Regenerate the Registry Studio snapshot from the Task Registry in one command.

Usage (from the repository root):
  python3 Maintanance/RegistryApp/sync.py --check   # report drift only; writes nothing
  python3 Maintanance/RegistryApp/sync.py           # regenerate registry.json and the HTML seed

registry.json is built from nothing on every run (2026-10-17): tasks, edges and the milestone connection
table come from the Task Registry; milestone cards from the gate files in Maintanance/Milestones/; the
current position from Milestones/HEAD.md. Nothing is carried over from the previous registry.json. The
existing file is read only to report what changed, and it may be missing.
"""
import datetime, hashlib, json, re, subprocess, sys
from pathlib import Path

import os, shutil, tempfile
ROOT = Path(__file__).resolve().parent.parent.parent
APP = Path(os.environ.get('REGISTRY_STUDIO_APP', Path(__file__).resolve().parent))
REGISTRY = ROOT / 'Maintanance/ProgressV2/TASK_REGISTRY_V2.md'
RULES = ROOT / 'Maintanance/ProgressV2/TASK_RULES_V2.md'
JSON = APP / 'registry.json'
HTML = APP / 'index.html'
JST = datetime.timezone(datetime.timedelta(hours=9))


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
    before HEAD are passed with it; other NN_ gates follow their DONE checkbox."""
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
    def order(p):  # file name order within a folder (NN_* before GATE-*)
        return p.name
    for path in [p for d in version_folders() for p in sorted(d.glob('*.md'), key=order)]:
        if not re.fullmatch(r'\d+_.+\.md|GATE-\d+\.\d+\.\d+\.md', path.name):
            continue  # only NN_*.md and GATE-x.y.z.md are gates; other files (e.g. GOAL.md) are ignored
        rel = path.relative_to(ROOT).as_posix()
        top = sections(path.read_text(encoding='utf-8'), '#')
        card = sections(top.get('カード情報', ''), '##')
        gid = card.get('ID', '').strip('` \n')
        name = card.get('名前', '').split('\n')[0].strip()
        state = card.get('状態', '')
        version_gate = path.name.startswith('GATE-')
        if not gid or not name or (not version_gate and not re.search(r'- \[( |x)\] DONE', state)):
            errors.append(f'{rel}: カード情報 needs ## ID, ## 名前 (and "- [ ] DONE" under ## 状態 for NN_ gates)'); continue
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
        eid = 'END-' + folder_id(name)  # identifier only: no name or condition of its own
        out += mid + [dict(id=eid, kind='milestone', item=eid,
                           state='DONE' if vkey(name) < head_version() else 'ACTIVE', owner='',
                           condition='', raw='', detail='Maintanance/Milestones/README.md',
                           gate=f'Maintanance/Milestones/{name}/', virtual=True)] + rel
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
        if len(c) != 4:
            raise ValueError(f'Registry line {no}: invalid milestone connection row')
        result.append(dict(prerequisite=unquote(c[0]), successor=unquote(c[1]),
                           relation=unquote(c[2]), constraint=c[3].replace(r'\|', '|'),
                           source=dict(path=REGISTRY.relative_to(ROOT).as_posix(), quote=line,
                                       sha256=sha256(REGISTRY), line=no)))
    return result


def registry_gate_relation_types(cards):
    """Incoming chain-edge types keyed by destination ID, independent of placement."""
    result, active = {}, False
    ids = {c['id'] for c in cards}
    for no, line in enumerate(REGISTRY.read_text(encoding='utf-8').splitlines(), 1):
        if line.startswith('## '):
            active = line == '## ゲート経路の関係種類'
        if not active or not line.startswith('| `'):
            continue
        c = cells(line)
        if len(c) != 2:
            raise ValueError(f'Registry line {no}: invalid gate relation row')
        target, relation = map(unquote, c)
        if target not in ids or target in result or relation not in {'stage', 'required', 'material', 'resume', 'after'}:
            raise ValueError(f'Registry line {no}: invalid or duplicate gate relation: {target}, {relation}')
        result[target] = (relation, line, no)
    return result


def chain_relations(cards):
    """Topology comes from placement; relation types come from Registry, never old JSON."""
    types = registry_gate_relation_types(cards)
    chain = []
    for a, b in zip(cards, cards[1:]):
        if b['id'] in types:
            relation, quote, no = types[b['id']]
            path = REGISTRY
        else:
            relation = 'stage'
            path = ROOT / 'Maintanance/Milestones/README.md'
            quote = END_RULE
            no = path.read_text(encoding='utf-8').splitlines().index(next(
                line for line in path.read_text(encoding='utf-8').splitlines() if quote in line)) + 1
        chain.append(dict(prerequisite=a['id'], successor=b['id'], relation=relation,
                          constraint='接続はゲートの配置、線の種類はRegistryの指定（未指定はstage）から生成。',
                          source=dict(path=path.relative_to(ROOT).as_posix(), quote=quote,
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
    rk = lambda r: (r['prerequisite'], r['successor'], r['relation'])
    orr, nrr = {rk(r) for r in old.get('milestoneRelations', [])}, {rk(r) for r in new.get('milestoneRelations', [])}
    out += [f'+ relation {a} -> {b} ({c})' for a, b, c in sorted(nrr - orr)] + [f'- relation {a} -> {b} ({c})' for a, b, c in sorted(orr - nrr)]
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


EMPTY = dict(tasks=[], edges=[], source={})


def main():
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
    except json.JSONDecodeError:
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

    node = tool('--node', 'REGISTRY_STUDIO_NODE', shutil.which('node'))
    marked = tool('--marked', 'REGISTRY_STUDIO_MARKED', None)
    if old and same_content(old, new) and seed == old:
        new['source']['generatedAt'] = old['source'].get('generatedAt')  # no meaningless diff on rerun
    backup = Path(tempfile.mkdtemp(prefix='registry-studio-sync-'))
    saved = [f for f in (JSON, HTML) if f.exists()]
    for f in saved:
        shutil.copy2(f, backup / f.name)
    try:
        JSON.write_text(json.dumps(new, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
        embed(new)
        subprocess.run([sys.executable, str(APP / 'build-pending.py')], cwd=ROOT, check=True)
        if not node:
            raise FileNotFoundError('node not found; documents cannot be rebuilt or verified (use --node PATH)')
        subprocess.run([node, str(APP / 'build-documents.mjs')] + ([marked] if marked else []), cwd=APP, check=True)
        subprocess.run([node, str(APP / 'verify.cjs')], cwd=APP, check=True)
    except (subprocess.CalledProcessError, OSError, ValueError) as e:
        for f in saved:
            shutil.copy2(backup / f.name, f)
        if JSON not in saved and JSON.exists():
            JSON.unlink()
        shutil.rmtree(backup)
        print(f'FAILED ({e}); restored registry.json and index.html to their state before this run')
        sys.exit(1)
    shutil.rmtree(backup)
    print('sync complete: registry.json, HTML seed, pending queue, documents, verify.cjs passed')


if __name__ == '__main__':
    main()
