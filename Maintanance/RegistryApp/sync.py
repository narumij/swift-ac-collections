#!/usr/bin/env python3
"""Regenerate the Registry Studio snapshot from the Task Registry in one command.

Usage (from the repository root):
  python3 Maintanance/RegistryApp/sync.py --check   # report drift only; writes nothing
  python3 Maintanance/RegistryApp/sync.py           # regenerate registry.json and the HTML seed

What is derived (never edit by hand): tasks and edges, source hashes, baseline, the HTML seed.
Milestone cards are read from the gate files in Maintanance/Milestones/<version>/ (カード情報;
the 記録 part is never read). What is carried over from the current registry.json (not derivable from
the Registry): milestoneRelations, milestoneSnapshot, and per-task displayInterest. Relation quotes are
checked against their source files and reported when stale.
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
    tasks, edges, section, group, parents = [], [], None, None, {}
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
        elif section == 'Task precedence' and len(c) == 4 and group is None:
            edges.append(dict(successor=unquote(c[0]), prerequisite=unquote(c[1]), flow=unquote(c[2]),
                              constraint=c[3], raw=line, sourceLine=no))
    for t in tasks:
        if t['id'] in parents:
            t['parentTask'] = parents[t['id']]
    return tasks, edges


def git(*args):
    return subprocess.run(['git', *args], cwd=ROOT, capture_output=True, text=True).stdout.strip()


def milestone_sources(old):
    """Carried-over milestone data: whole quote must still exist; a changed file hash is reported for review."""
    stale, changed = [], []
    ms = {c['id'] for c in read_gates()[0]} | {m['id'] for m in old.get('milestones', [])}
    items = [(m['id'], m.get('source')) for m in old.get('milestones', []) if m.get('source')]
    items += [(f"{r['prerequisite']}->{r['successor']}", r.get('source')) for r in old.get('milestoneRelations', [])
              if not (r['prerequisite'] in ms and r['successor'] in ms)]  # chain is rebuilt from gates
    for name, src in items:
        if not src or not src.get('path') or not src.get('quote'):
            continue
        p = ROOT / src['path']
        if not p.exists() or src['quote'] not in p.read_text(encoding='utf-8'):
            stale.append(f"{name}: {src['path']}")
        elif src.get('sha256') and src['sha256'] != sha256(p):
            changed.append(f"{name}: {src['path']}")
    return stale, changed


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


def head_version():
    """Current position from Milestones/HEAD.md ('# x.y.z'). Version gates up to it are passed."""
    m = re.search(r'^# (\d+\.\d+\.\d+)', (MILESTONES / 'HEAD.md').read_text(encoding='utf-8'), re.M)
    return vkey(m.group(1)) if m else (0, 0, 0)


def relocate_sources(old):
    """A relation source whose file moved or no longer holds the quote is searched for in
    Maintanance/Milestones/ and Maintanance/MILESTONES.md; repointed only when exactly one file has it."""
    pool = sorted(MILESTONES.glob('**/*.md')) + [ROOT / 'Maintanance/MILESTONES.md']
    done = []
    ms = {c['id'] for c in read_gates()[0]} | {m['id'] for m in old.get('milestones', [])}
    for r in old.get('milestoneRelations', []):
        if r['prerequisite'] in ms and r['successor'] in ms:
            continue  # chain is rebuilt from gates
        src = r.get('source') or {}
        q, p = src.get('quote'), ROOT / src.get('path', '')
        if not q or (p.exists() and q in p.read_text(encoding='utf-8')):
            continue
        hits = [f for f in pool if q in f.read_text(encoding='utf-8')]
        same_name = [f for f in hits if f.name == p.name]
        if len(same_name) == 1:  # the same file, moved
            hits = same_name
        if len(hits) == 1:
            src['path'] = hits[0].relative_to(ROOT).as_posix()
            done.append(f"{r['prerequisite']}->{r['successor']}: {src['path']}")
    return done


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
    def order(p):  # file name order within a folder (NN_* before GATE_*)
        return p.name
    for path in [p for d in version_folders() for p in sorted(d.glob('*.md'), key=order)]:
        if not re.fullmatch(r'\d+_.+\.md|GATE_\d+_\d+_\d+\.md', path.name):
            continue  # only NN_*.md and GATE_x_y_z.md are gates; other files (e.g. GOAL.md) are ignored
        rel = path.relative_to(ROOT).as_posix()
        top = sections(path.read_text(encoding='utf-8'), '#')
        card = sections(top.get('カード情報', ''), '##')
        gid = card.get('ID', '').strip('` \n')
        name = card.get('名前', '').split('\n')[0].strip()
        state = card.get('状態', '')
        version_gate = path.name.startswith('GATE_')
        if not gid or not name or (not version_gate and not re.search(r'- \[( |x)\] DONE', state)):
            errors.append(f'{rel}: カード情報 needs ## ID, ## 名前 (and "- [ ] DONE" under ## 状態 for NN_ gates)'); continue
        vm = re.fullmatch(r'GATE_(\d+)_(\d+)_(\d+)\.md', path.name)
        if vm and (gid != 'GATE-' + '.'.join(vm.groups()) or not name.startswith('.'.join(vm.groups()) + ' ')):
            errors.append(f"{rel}: version gate needs ## ID `GATE-{'.'.join(vm.groups())}` and ## 名前 "
                          f"'{'.'.join(vm.groups())} リリース'"); continue
        if gid == 'なし' or gid in task_ids:
            continue
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
    cards = add_ends(cards)
    for gid in sorted({c['id'] for c in cards}):
        files = [c['gate'] for c in cards if c['id'] == gid]
        if len(files) > 1:
            errors.append(f'duplicate ID {gid}: ' + ', '.join(files))
    return cards, errors


END_RULE = 'END-x.y.z は版フォルダごとの集合点で、実ファイルを置かない'


def add_ends(cards):
    """Each version folder gets a virtual END-xyz just before its release gate (no file)."""
    folders = [d.name for d in version_folders()]
    out = []
    for name in folders:
        mine = [c for c in cards if Path(c['gate']).parent.name == name]
        mid = [c for c in mine if not Path(c['gate']).name.startswith('GATE_')]
        rel = [c for c in mine if Path(c['gate']).name.startswith('GATE_')]
        eid = 'END-' + folder_id(name)  # identifier only: no name or condition of its own
        out += mid + [dict(id=eid, kind='milestone', item=eid,
                           state='DONE' if vkey(name) < head_version() else 'ACTIVE', owner='',
                           condition='', raw='', detail='Maintanance/Milestones/README.md',
                           gate=f'Maintanance/Milestones/{name}/', virtual=True)] + rel
    return out


def chain_relations(cards, carried, old_milestones=()):
    """Milestone-to-milestone relations follow the gate order (sequential restriction). Relations that
    touch a task are carried over unchanged."""
    ids = {c['id'] for c in cards}
    known = ids | {m['id'] for m in old_milestones}
    # drop old chain links and anything touching a milestone whose gate is gone
    keep = [r for r in carried if not (r['prerequisite'] in known and r['successor'] in known)
            and not ({r['prerequisite'], r['successor']} & (known - ids))]
    # Only END -> GATE may enter a version gate, and tasks hang on ENDs (2026-10-17 user decision):
    #   task -> GATE-xyz  becomes  task -> END of the folder holding GATE-xyz
    #   GATE-xyz -> task  becomes  task -> END-xyz (work done while at version xyz)
    end_before = {c['id']: p['id'] for p, c in zip(cards, cards[1:])
                  if c['id'].startswith('GATE-') and p['id'].startswith('END-')}
    end_ids = {c['id'] for c in cards if c['id'].startswith('END-')}
    moved = []
    for r in keep:
        a, b = r['prerequisite'], r['successor']
        if b in end_before and a not in ids:
            r = dict(r, successor=end_before[b])
        elif a.startswith('GATE-') and b not in ids and 'END-' + a[5:] in end_ids:
            r = dict(r, prerequisite=b, successor='END-' + a[5:])
        moved.append(r)
    keep = moved
    same = {(r['prerequisite'], r['successor']): r for r in carried
            if r['prerequisite'] in ids and r['successor'] in ids}
    chain = []
    for a, b in zip(cards, cards[1:]):
        r = same.get((a['id'], b['id']))
        if r:  # existing pair keeps its relation type; evidence is kept while the quote still holds
            src = r.get('source') or {}
            sp = ROOT / src.get('path', '')
            if src.get('quote') and sp.exists() and src['quote'] in sp.read_text(encoding='utf-8'):
                chain.append(r); continue
            r = dict(r, source=None)
        if b.get('virtual'):
            nxt = cards[cards.index(b) + 1] if cards.index(b) + 1 < len(cards) else None
            inherit = same.get((a['id'], nxt['id'])) if nxt else None
            if inherit and not r:  # the old a->gate relation now lands on the folder's END
                chain.append(dict(inherit, successor=b['id'])); continue
            path, quote = ROOT / 'Maintanance/Milestones/README.md', END_RULE
        else:
            path, quote = ROOT / b['gate'], f"`{b['id']}`"
        text = path.read_text(encoding='utf-8')
        chain.append(dict(prerequisite=a['id'], successor=b['id'], relation=(r or {}).get('relation', 'stage'),
                          constraint='ゲートの列（フォルダとファイル名の順）から導いた。',
                          source=dict(path=path.relative_to(ROOT).as_posix(), quote=quote, sha256=sha256(path),
                                      line=text[:text.find(quote)].count('\n') + 1)))
    return keep + chain


def build(old):
    tasks, edges = parse_registry()
    interest = {t['id']: t['displayInterest'] for t in old.get('tasks', []) if 'displayInterest' in t}
    for t in tasks:
        if t['id'] in interest:
            t['displayInterest'] = interest[t['id']]
    data = dict(old)
    data['source'] = dict(path='Maintanance/ProgressV2/TASK_REGISTRY_V2.md', head=git('rev-parse', '--short=8', 'HEAD'),
                          sha256=sha256(REGISTRY), dirty=bool(git('status', '--porcelain', '--', str(REGISTRY))),
                          generatedAt=datetime.datetime.now(JST).isoformat(), generator='sync.py',
                          rulesSha256=sha256(RULES))
    data['tasks'], data['edges'] = tasks, edges
    data['milestones'] = read_gates()[0]
    data['milestoneHead'] = '.'.join(str(x[1]) for x in head_version())  # current position for the Studio picker
    data['milestoneRelations'] = chain_relations(data['milestones'], old.get('milestoneRelations', []),
                                                 old.get('milestones', []))
    data['baseline'] = dict(tasks=json.loads(json.dumps(tasks)), edges=json.loads(json.dumps(edges)),
                            milestoneRelations=json.loads(json.dumps(data['milestoneRelations'])))
    return data


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


def main():
    old = json.loads(JSON.read_text(encoding='utf-8'))
    new = build(old)
    changes = diff(old, new)
    seed = seed_of(HTML.read_text(encoding='utf-8'))
    if seed != old:
        changes.append('~ HTML seed differs from registry.json')
    relocated = relocate_sources(old)
    if relocated:
        print('relocated relation sources (quote found in exactly one file):\n  ' + '\n  '.join(relocated))
    stale, moved = milestone_sources(old)
    gate_errors = read_gates()[1]
    if gate_errors:
        print('GATE file problems (fix the file under Maintanance/Milestones/):\n  ' + '\n  '.join(gate_errors))
    print(f"tasks {len(new['tasks'])}, edges {len(new['edges'])}, milestones {len(new.get('milestones', []))} (from gate files)")
    print('\n'.join(changes) if changes else 'no drift between Task Registry, registry.json, and the HTML seed')
    if moved:
        print('milestone sources changed since snapshot (quote still present; review):\n  ' + '\n  '.join(moved))
    if stale:
        print('STALE milestone quotes (not auto-fixed; edit registry.json by hand):\n  ' + '\n  '.join(stale))
    if '--check' in sys.argv:
        sys.exit(1 if changes or stale or moved or gate_errors else 0)

    if gate_errors:
        sys.exit('Gate files need fixing before synchronization; no files written')
    if stale:
        sys.exit('Milestone sources need review before synchronization; no files written')
    if moved:
        # Quote still present: the file only changed elsewhere. Refresh hash and line, then continue.
        for r in new.get('milestoneRelations', []):
            src = r.get('source') or {}
            p = ROOT / src.get('path', '')
            if src.get('quote') and p.exists():
                text = p.read_text(encoding='utf-8')
                src['sha256'] = sha256(p)
                src['line'] = text[:text.find(src['quote'])].count('\n') + 1
        new['baseline']['milestoneRelations'] = json.loads(json.dumps(new.get('milestoneRelations', [])))
        print('refreshed hash/line for sources whose quote is still present')

    node = tool('--node', 'REGISTRY_STUDIO_NODE', shutil.which('node'))
    marked = tool('--marked', 'REGISTRY_STUDIO_MARKED', None)
    if same_content(old, new) and seed == old:
        new['source']['generatedAt'] = old['source'].get('generatedAt')  # no meaningless diff on rerun
    backup = Path(tempfile.mkdtemp(prefix='registry-studio-sync-'))
    for f in (JSON, HTML):
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
        for f in (JSON, HTML):
            shutil.copy2(backup / f.name, f)
        shutil.rmtree(backup)
        print(f'FAILED ({e}); restored registry.json and index.html to their state before this run')
        sys.exit(1)
    shutil.rmtree(backup)
    print('sync complete: registry.json, HTML seed, pending queue, documents, verify.cjs passed')


if __name__ == '__main__':
    main()
