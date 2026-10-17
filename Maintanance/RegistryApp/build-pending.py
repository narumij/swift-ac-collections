"""Build a read-only pending-queue snapshot; never allocate task IDs."""
from pathlib import Path
import re, json, hashlib, datetime
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
data = dict(source=' · '.join(s['path'] for s in sources), sources=sources,
            generatedAt=datetime.datetime.now(datetime.timezone(datetime.timedelta(hours=9))).isoformat(), entries=entries)
html = app / 'index.html'
s = html.read_text()
block = '<script id="pendingSeed" type="application/json">' + json.dumps(data, ensure_ascii=False).replace('<', '\\u003c') + '</script>'
if '<script id="pendingSeed"' in s:
    s = re.sub(r'<script id="pendingSeed".*?</script>', lambda m: block, s, count=1, flags=re.S)
else:
    s = s.replace('<script>', block + '\n<script>', 1)
html.write_text(s)
print('Pending entries: ' + ', '.join(f"{s['owner']} {sum(e['source'] == s['path'] for e in entries)}" for s in sources))
