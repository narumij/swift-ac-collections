#!/usr/bin/env python3
"""OPS-153/154: build the two task-screen fixtures used by the map view-model baseline.

A (layout): the existing completed-document-layout-fixture.json, converted to the current format only by removing the
retired `relation` key from milestone relations (no text changed).
B (anonymized): the structure of the generated Registry (ids, states, edges, milestones, gates, parents, permanence) with
every free text replaced by neutral placeholders of similar length, plus one task proposal. Document paths in `detail`
are kept so that document links still appear.
B is retained as task-view-model-fixture-b.json (the baseline was captured with it); rebuild B only when re-capturing.
Usage: python3 task-view-model-fixtures.py <output dir>   (reads ../Cache/RegistryStudio/registry.json for B)
"""
import json, re, sys, pathlib
here = pathlib.Path(__file__).resolve().parent
out = pathlib.Path(sys.argv[1]); out.mkdir(parents=True, exist_ok=True)
a = json.loads((here / 'completed-document-layout-fixture.json').read_text())
for rel in a.get('milestoneRelations', []) + a.get('baseline', {}).get('milestoneRelations', []):
    rel.pop('relation', None)
(out / 'fixture-a.json').write_text(json.dumps(a, ensure_ascii=False))
b = json.loads((here.parent / 'Cache/RegistryStudio/registry.json').read_text())
owners = {}
def owner(o):
    if not o: return o
    owners.setdefault(o, 'メンバー' + str(len(owners) + 1)); return owners[o]
def filler(text, word):
    n = len(text or '')
    return (word * (n // len(word) + 1))[:max(n, 1)] if text else text
def paths(detail):
    return ' '.join('`' + p + '`' for p in re.findall(r'(?:Maintanance|Sources|Tests)/[^`\s|]+?\.md', detail or ''))
def scrub(t):
    prefix = re.match(r'^\[(EXECUTION|DISCOVERY|DECISION)\]\s*', t.get('item', '') or '')
    body = (t.get('item') or '')[prefix.end() if prefix else 0:]
    t['item'] = (prefix.group(0) if prefix else '') + filler(body, '作業項目')
    t['owner'] = owner(t.get('owner'))
    for k in ('condition', 'raw'):
        if k in t and t[k]: t[k] = '条件 ' + t['id']
    if 'detail' in t: t['detail'] = paths(t['detail']) or t['detail'] if t.get('kind') == 'milestone' else paths(t['detail'])
    for k in ('group',):
        if t.get(k): t[k] = '分類'
for t in b['tasks'] + b['baseline']['tasks'] + b['milestones']: scrub(t)
for e in b['edges'] + b['baseline']['edges'] + b['milestoneRelations'] + b['baseline'].get('milestoneRelations', []):
    e['constraint'] = '制約 ' + e['prerequisite'] + '→' + e['successor']
    if 'raw' in e: e['raw'] = ''
    if isinstance(e.get('source'), dict): e['source'] = {**e['source'], 'quote': '引用'}
b['proposals'] = [{'id': 'draft-1', 'title': '追加案の作業項目', 'memo': 'メモ', 'state': 'PROPOSED'}]
(out / 'fixture-b.json').write_text(json.dumps(b, ensure_ascii=False))
print('fixtures written:', out)
