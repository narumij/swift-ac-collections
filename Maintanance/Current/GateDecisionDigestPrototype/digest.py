#!/usr/bin/env python3
"""OPS-056 prototype: list decisions and waiting conditions that apply to a gate or task.

Usage (from the repository root):
  python3 Maintanance/Current/GateDecisionDigestPrototype/digest.py MS-060
  python3 Maintanance/Current/GateDecisionDigestPrototype/digest.py DOC-034 --test

The output is a generated copy. The canonical text of each decision stays in its source document.
"""
import collections, hashlib, json, os, sys

HERE = os.path.dirname(os.path.abspath(__file__))
REG = 'Maintanance/RegistryApp/registry.json'


def load(path):
    with open(path, encoding='utf-8') as f:
        return json.load(f)


def sha(path):
    with open(path, 'rb') as f:
        return hashlib.sha256(f.read()).hexdigest()[:12]


def graph(d):
    nodes = {t['id']: t for t in d['tasks']} | {m['id']: m for m in d['milestones']}
    edges = [(e['prerequisite'], e['successor'], e.get('flow') or 'SEQUENCE', e.get('constraint', '')) for e in d['edges']]
    edges += [(e['prerequisite'], e['successor'], e['relation'], e.get('constraint', '')) for e in d['milestoneRelations']]
    into, out = collections.defaultdict(list), collections.defaultdict(list)
    for a, b, k, c in edges:
        into[b].append((a, k, c))
        out[a].append((b, k, c))
    return nodes, into, out


def upstream(gate, into):
    """Breadth-first walk toward prerequisites. Keeps the first edge kind seen on the path to the gate."""
    seen, q = {}, [gate]
    while q:
        n = q.pop(0)
        for a, k, c in into[n]:
            if a not in seen:
                seen[a] = (n, k, c)
                q.append(a)
    return seen


def downstream(node, out):
    seen, q = set(), [node]
    while q:
        n = q.pop(0)
        for b, _, _ in out[n]:
            if b not in seen:
                seen.add(b)
                q.append(b)
    return seen


def classify(t, via_kind):
    """Classify a Registry node without inferring decisions from state alone."""
    state, item, owner = t.get('state', ''), t.get('item', ''), str(t.get('owner', ''))
    is_decision = item.startswith('[DECISION]')
    if state == 'DONE':
        return '完了（判断の中身は原文で確認。DONEから肯定を推測しない）'
    if is_decision and state in ('USER_ONLY', 'WAITING_USER'):
        return '判断待ち'
    if 'User' in owner and not is_decision and state in ('USER_ONLY', 'WAITING_USER'):
        return 'ユーザー実作業待ち'
    if via_kind == 'material':
        return '材料待ち'
    if state in ('ACTIVE', 'PROPOSED', 'WAITING_EXTERNAL', 'FROZEN') or t.get('kind') == 'milestone':
        return f'作業・到達待ち（{state}）'
    return '未確認'


def verify(source):
    path = source['path']
    if path.startswith('(') or not os.path.exists(path):
        return '試験用（原文なし）' if path.startswith('(') else '原文なし（要確認）'
    with open(path, encoding='utf-8') as f:
        lines = f.read().split('\n')
    hits = [i + 1 for i, l in enumerate(lines) if source['quote'] and source['quote'] in l]
    if not hits:
        return f'引用不一致（要確認、{sha(path)}）'
    return f'{path}:{hits[0]}（{sha(path)}）'


def effective(marks):
    """Apply explicit clause-level replacement only. Unlinked newer marks on the same topic become conflict candidates."""
    by_id = {m['id']: m for m in marks}
    replaced = collections.defaultdict(dict)  # mark id -> clause key -> replacing mark id
    for m in marks:
        for s in m.get('supersedes', []):
            for key in s['clauses']:
                replaced[s['mark']][key] = m['id']
    conflicts = []
    by_topic = collections.defaultdict(list)
    for m in marks:
        by_topic[m.get('topic')].append(m)
    for topic, ms in by_topic.items():
        ms = sorted(ms, key=lambda m: m['date'])
        for later in ms[1:]:
            linked = {s['mark'] for s in later.get('supersedes', [])}
            for earlier in ms:
                if earlier['date'] < later['date'] and earlier['id'] not in linked and later['id'] not in {s['mark'] for s in earlier.get('supersedes', [])}:
                    conflicts.append((later['id'], earlier['id'], topic))
    return replaced, conflicts, by_id


def main():
    args = [a for a in sys.argv[1:] if not a.startswith('--')]
    target = args[0]
    d = load(REG)
    nodes, into, out = graph(d)
    marks = load(os.path.join(HERE, 'marks.json'))['marks']
    if '--test' in sys.argv:
        marks += load(os.path.join(HERE, 'test_marks.json'))['marks']
    replaced, conflicts, by_id = effective(marks)

    src = d['source']
    print(f'# {target} に効く判断と待ち条件（生成した写し）\n')
    print(f'入力：`{REG}`（Registry SHA-256先頭 `{src["sha256"][:12]}`、HEAD `{src["head"][:8]}`）、印 `marks.json`' + ('＋試験用 `test_marks.json`' if '--test' in sys.argv else '') + '\n')

    t = nodes.get(target, {})
    if t.get('kind') == 'milestone':
        scope = upstream(target, into)
        related = set(scope) | {target}
        print(f'範囲：ゲート`{target}`の上流 {len(scope)}件（辺の意味を残す）\n')
    else:
        down = downstream(target, out)
        ups = {a: (target, k, c) for a, k, c in into[target]}
        scope = ups
        related = {target} | down | set(ups)
        print(f'範囲：`{target}`自身、直接の前提 {len(ups)}件、下流のゲート・task {len(down)}件（下流のゲートに付いた判断もこのtaskへ効く）\n')

    print('## 1. 判断（印から）\n')
    hit = [m for m in marks if set(m['targets']) & related]
    if not hit:
        print('該当なし。\n')
    for m in hit:
        tag = '（試験用の仮想例）' if m['id'].startswith('TEST') else ''
        print(f'### {m["id"]}{tag}\n')
        print(f'- 判断者 {m["decider"]}、日付 {m["date"]}、対象 {", ".join(m["targets"])}')
        for c in m['clauses']:
            r = replaced.get(m['id'], {}).get(c['key'])
            print(f'- [{c["key"]}] {c["text"]}' + (f' → **置き換え済み（{r}）**' if r else ' — 有効'))
        for s in m['sources']:
            print(f'- 原文：{s["section"]} — {verify(s)}')
        print()

    if conflicts:
        print('## 2. 矛盾候補（置き換え関係の記載がない、同じ話題の新旧）\n')
        for later, earlier, topic in conflicts:
            print(f'- {later} と {earlier}（話題：{topic}）。新しい日付だけで旧判断を失効させない。原文で関係を確かめる')
        print()

    print('## 3. 待ち条件（Registryから。判断の有無は推測しない）\n')
    buckets = collections.defaultdict(list)
    for n, (to, k, c) in sorted(scope.items()):
        nt = nodes.get(n, {'state': '?', 'item': '?', 'owner': '?'})
        buckets[classify(nt, k)].append(f'- {n} [{nt.get("state")}] {nt.get("item", "")[:40]} — 辺 `{n} → {to}`（{k}）')
    order = ['判断待ち', 'ユーザー実作業待ち', '材料待ち']
    for key in order + sorted(k for k in buckets if k not in order):
        if key in buckets:
            print(f'**{key}**\n')
            print('\n'.join(buckets[key]) + '\n')


if __name__ == '__main__':
    main()
