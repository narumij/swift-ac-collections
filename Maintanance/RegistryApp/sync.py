#!/usr/bin/env python3
"""Regenerate the Registry Studio snapshot from the Task Registry in one command.

Usage (from the repository root):
  python3 Maintanance/RegistryApp/sync.py --check   # report drift only; writes nothing
  python3 Maintanance/RegistryApp/sync.py           # regenerate registry.json and the HTML seed

What is derived (never edit by hand): tasks and edges, source hashes, baseline, the HTML seed.
What is carried over from the current registry.json (not derivable from the Registry): milestones,
milestoneRelations, milestoneSnapshot, and per-task displayInterest. Milestone quotes are checked
against their source files and reported when stale.
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
    items = [(m['id'], m.get('source')) for m in old.get('milestones', [])]
    items += [(f"{r['prerequisite']}->{r['successor']}", r.get('source')) for r in old.get('milestoneRelations', [])]
    for name, src in items:
        if not src or not src.get('path') or not src.get('quote'):
            continue
        p = ROOT / src['path']
        if not p.exists() or src['quote'] not in p.read_text(encoding='utf-8'):
            stale.append(f"{name}: {src['path']}")
        elif src.get('sha256') and src['sha256'] != sha256(p):
            changed.append(f"{name}: {src['path']}")
    return stale, changed


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
    data['baseline'] = dict(tasks=json.loads(json.dumps(tasks)), edges=json.loads(json.dumps(edges)),
                            milestoneRelations=json.loads(json.dumps(old.get('milestoneRelations', []))))
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
            changed = [k for k in n[i] if o[i].get(k) != n[i].get(k) and k != 'sourceLine']
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
        sys.exit('seed block not found in index.html')
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
    stale, moved = milestone_sources(old)
    print(f"tasks {len(new['tasks'])}, edges {len(new['edges'])}, milestones {len(new.get('milestones', []))} (carried over)")
    print('\n'.join(changes) if changes else 'no drift between Task Registry, registry.json, and the HTML seed')
    if moved:
        print('milestone sources changed since snapshot (quote still present; review):\n  ' + '\n  '.join(moved))
    if stale:
        print('STALE milestone quotes (not auto-fixed; edit registry.json by hand):\n  ' + '\n  '.join(stale))
    if '--check' in sys.argv:
        sys.exit(1 if changes or stale else 0)

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
    except (subprocess.CalledProcessError, OSError) as e:
        for f in (JSON, HTML):
            shutil.copy2(backup / f.name, f)
        shutil.rmtree(backup)
        print(f'FAILED ({e}); restored registry.json and index.html to their state before this run')
        sys.exit(1)
    shutil.rmtree(backup)
    print('sync complete: registry.json, HTML seed, pending queue, documents, verify.cjs passed')


if __name__ == '__main__':
    main()
