"""Build a read-only pending-queue snapshot; never allocate task IDs."""
from pathlib import Path
import re, json, hashlib, datetime, os
app = Path(__file__).resolve().parent
# Each agent keeps its own queue with its own temporary-ID prefix. Add a row here to show another queue.
queues = [
    dict(path='Maintanance/CLAUDE_PENDING_TASKS.md', owner='Claude（姫）', prefix='CP'),
    dict(path='Maintanance/FABLE_PENDING_TASKS.md', owner='Fable', prefix='FP'),
]
entries, sources = [], []
for queue in queues:
    source = app.parent.parent / queue['path']
    if not source.exists():
        continue
    text = source.read_text()
    body = text.split('## 採番待ち', 1)[1].split('過去のreconciliation済みentry', 1)[0]
    pattern = r'^### `(?P<id>' + queue['prefix'] + r'-\d{8}-\d+)` — (?P<title>[^\n]+)\n(?P<body>.*?)(?=^### |\Z)'
    for match in re.finditer(pattern, body, re.M | re.S):
        raw = match.group(0).strip()
        state = re.search(r'queue状態: `([^`]+)`', raw)
        if state and state[1] == 'RECONCILED':
            continue
        entries.append(dict(id=match['id'], title=match['title'], state=state[1] if state else '未確認',
                            source=queue['path'], owner=queue['owner'], raw=raw))
    sources.append(dict(path=queue['path'], owner=queue['owner'], sha256=hashlib.sha256(source.read_bytes()).hexdigest()))
# Open requests: sections "## <TASK-ID> — title" in each request sheet whose task is not finished in the Registry.
# Read-only; the Registry row stays the state of record (2026-10-17, user request "依頼状態もスタジオでみたい").
sheets = [
    dict(path='Maintanance/CLAUDE_TASK.md', owner='Claude（姫）'),
    dict(path='Maintanance/FABLE_TASK.md', owner='Fable'),
]
registry = (app.parent.parent / 'Maintanance/ProgressV2/TASK_REGISTRY_V2.md').read_text()
rows = {m[1]: (m[2], m[3].strip()) for m in re.finditer(r'^\| `([A-Z]+-\d+)` \| `([A-Z_]+)` \|([^|]*)\|', registry, re.M)}
requests = []
for sheet in sheets:
    source = app.parent.parent / sheet['path']
    if not source.exists():
        continue
    text = source.read_text()
    found = {}
    for m in re.finditer(r'^## (?P<id>[A-Z]+-\d+)(?:-[A-Z0-9-]+)? — (?P<title>[^\n]+)\n(?P<body>.*?)(?=^## |\Z)', text, re.M | re.S):
        found.setdefault(m['id'], []).append(m)
    for task_id, ms in found.items():
        if task_id not in rows:  # compressed out of the Registry: the section is history, not an open request
            continue
        state, assignee = rows[task_id]
        if state in ('DONE', 'EXCLUDED', 'ARCHIVED'):
            continue
        requests.append(dict(id=task_id, title=ms[-1]['title'], state=state, assignee=assignee,
                             sheet=sheet['path'], owner=sheet['owner'],
                             raw='\n\n'.join(m.group(0).strip() for m in ms)))
data = dict(source=' · '.join(s['path'] for s in sources), sources=sources,
            generatedAt=datetime.datetime.now(datetime.timezone(datetime.timedelta(hours=9))).isoformat(), entries=entries,
            requests=requests)
html = Path(os.environ.get('REGISTRY_STUDIO_APP', app.parent / 'Cache/RegistryStudio')) / 'index.html'
s = html.read_text()
block = '<script id="pendingSeed" type="application/json">' + json.dumps(data, ensure_ascii=False).replace('<', '\\u003c') + '</script>'
if '<script id="pendingSeed"' in s:
    s = re.sub(r'<script id="pendingSeed".*?</script>', lambda m: block, s, count=1, flags=re.S)
else:
    s = s.replace('<script>', block + '\n<script>', 1)
html.write_text(s)
print('Pending entries: ' + ', '.join(f"{s['owner']} {sum(e['source'] == s['path'] for e in entries)}" for s in sources)
      + ' · open requests: ' + (', '.join(r['id'] for r in requests) or 'none'))
