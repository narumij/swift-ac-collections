"""OPS-158 isolated research fixture; no production DB or source writes.
Run from any directory: python3 path/to/trial.py
Output is reproducible evidence, not a current-policy authority.
"""
import hashlib
import json
from pathlib import Path
import sqlite3
import subprocess

ROOT = Path(__file__).resolve().parents[4]
BASE = 'e558380d3'
BASE = subprocess.check_output(['git', 'rev-parse', BASE], cwd=ROOT, text=True).strip()

def span(path, needle):
    text = subprocess.check_output(['git', 'show', f'{BASE}:{path}'], cwd=ROOT, text=True)
    matches = [(n, line) for n, line in enumerate(text.splitlines(), 1) if needle in line]
    if len(matches) != 1:
        raise ValueError((path, needle, len(matches)))
    n, line = matches[0]
    return {'commit': BASE, 'path': path, 'line': n, 'text': line,
            'sha256': hashlib.sha256(line.encode()).hexdigest()}

p = 'Maintanance/Current/'
cutover = p + 'TASK_REGISTRY_V3_CUTOVER_REHEARSAL.md'
sources = {
    'D1': span(cutover, '1. 本番切替後の版順はDBを正とする。'),
    'D2': span(cutover, '2. 新規カードは正本文書を用意してから正式登録する。'),
    'D3': span(cutover, '- backup復元：新しいDBと世代へ復元し、'),
}
old = span(p + 'TASK_REGISTRY_V3_DESIGN.md', '- 明示的な版順をDB正本にすることと、')
rejected = span(cutover, '未採用：観測できた最大番号へ50などの余白を足して再開する案。')
copy = span(cutover, '版の順はDBが正（決定済み）')

c = sqlite3.connect(':memory:')
c.executescript('''
PRAGMA foreign_keys=ON;
CREATE TABLE decision(id TEXT, revision INTEGER, statement TEXT, status TEXT,
    source TEXT, PRIMARY KEY(id, revision));
CREATE TABLE reference(id TEXT PRIMARY KEY, decision TEXT, revision INTEGER,
    kind TEXT, locator TEXT, FOREIGN KEY(decision,revision) REFERENCES decision(id,revision));
''')
for did, src in sources.items():
    c.execute('INSERT INTO decision VALUES(?,1,?, ?, ?)',
              (did, src['text'], 'recorded-adopted', json.dumps(src, ensure_ascii=False)))
# Explicitly curated relations: no claim of discovering all dependencies.
refs = [
    ('R1', 'D1', 'copy', copy),
    ('R2', 'D1', 'historical-open', old),
    ('R3', 'D2', 'source', sources['D2']),
    ('R4', 'D3', 'rejected-alternative', rejected),
]
for rid, did, kind, locator in refs:
    c.execute('INSERT INTO reference VALUES(?,?,1,?,?)',
              (rid, did, kind, json.dumps(locator, ensure_ascii=False)))

def query(did):
    return [{'id': r[0], 'kind': r[1], 'locator': json.loads(r[2])}
            for r in c.execute('SELECT id,kind,locator FROM reference WHERE decision=? ORDER BY id', (did,))]

def review(did, revision):
    # A revision change does not rewrite old records or decide validity.
    return [r[0] for r in c.execute(
        "SELECT id FROM reference WHERE decision=? AND revision=? AND kind='copy' ORDER BY id",
        (did, revision))]

before = c.serialize()
assert [x['kind'] for x in query('D1')] == ['copy', 'historical-open']
assert query('D2')[0]['locator'] == sources['D2']
assert '余白' in query('D3')[0]['locator']['text']
assert review('D1', 1) == ['R1']  # historical proposal is not a stale copy
assert review('D2', 1) == []      # no registered copies is NOT no existing copies
assert review('D1', 2) == []      # exact revision, no broad invalidation
assert c.serialize() == before
# An independent fixture reader feeds drift detection. Not a live file watcher.
def detect_drift(did, revision, read_line):
    stored = json.loads(c.execute(
        'SELECT source FROM decision WHERE id=? AND revision=?',
        (did, revision)).fetchone()[0])
    current = read_line(stored['path'], stored['line'])
    digest = hashlib.sha256(current.encode()).hexdigest()
    return review(did, revision) if digest != stored['sha256'] else []

fixture = {(src['path'], src['line']): src['text'] for src in sources.values()}
reader = lambda path, line: fixture[(path, line)]
assert detect_drift('D1', 1, reader) == []
fixture[('unrelated.md', 1)] = 'unrelated edit'
assert detect_drift('D1', 1, reader) == []
key = (sources['D1']['path'], sources['D1']['line'])
fixture[key] += ' simulated change'
assert detect_drift('D1', 1, reader) == ['R1']
assert detect_drift('D2', 1, reader) == []
assert detect_drift('D3', 1, reader) == []
assert c.serialize() == before
fixture[key] = sources['D1']['text']
assert detect_drift('D1', 1, reader) == []
changed = dict(sources['D1'], text='simulation only')
# A new revision is a proposal; old adopted record remains untouched.
c.execute('INSERT INTO decision VALUES(?,2,?,?,?)', ('D1','simulation only','proposed',json.dumps(changed)))
assert c.execute("SELECT status FROM decision WHERE id='D1' AND revision=1").fetchone()[0] == 'recorded-adopted'
try:
    c.execute('INSERT INTO reference VALUES(?,?,?,?,?)', ('bad','missing',1,'copy','{}'))
except sqlite3.IntegrityError:
    pass
else:
    raise AssertionError('dangling reference accepted')
print(json.dumps({'base': BASE, 'database': ':memory:', 'checks': 'passed',
    'decisions': sources, 'queries': {d: query(d) for d in sources},
    'simulated_D1_review': review('D1',1),
    'limits': ['curated sample only', 'no live enforcement verification',
               'no automatic status change', 'no task or production DB writes',
               'single-line fixed-location fixture; moved/multiline sources not handled',
               'D2 has no registered copies, not proof none exist',
               'historical-open classification manually curated']}, ensure_ascii=False, indent=2))
c.close()
