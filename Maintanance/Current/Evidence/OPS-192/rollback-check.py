#!/usr/bin/env python3
"""OPS-192 第2区切り 切戻し確認: a DB extended by the new code (letter_links, a thread) is read and used by the code of
BASE (approvals.py and studio_store.py from git): it lists and shows the letters, sends, receives, returns and closes.
Then the new code reads the thread again. Temporary directory only (removed at exit); no server, no live DB.
Usage: python3 rollback-check.py [BASE]   (default HEAD)"""
import subprocess, sys, tempfile, textwrap, uuid
from pathlib import Path

APP = Path(__file__).resolve().parents[3] / 'RegistryApp'
base = sys.argv[1] if len(sys.argv) > 1 else 'HEAD'
with tempfile.TemporaryDirectory() as tmp:
    tmp = Path(tmp)
    old = tmp / 'old'
    old.mkdir()
    for name in ('approvals.py', 'studio_store.py'):
        (old / name).write_bytes(subprocess.run(['git', 'show', f'{base}:Maintanance/RegistryApp/{name}'], cwd=APP, check=True, capture_output=True).stdout)
    db = tmp / 'letters.sqlite3'
    common = f"""
import sys, uuid, json; sys.path[:0] = [{{path!r}}, {str(APP)!r}]
import studio_store
s = studio_store.Store({str(db)!r}, {str(tmp)!r}); op = lambda: uuid.uuid4().hex
"""
    def run(path, code):
        r = subprocess.run([sys.executable, '-B', '-c', common.format(path=str(path)) + textwrap.dedent(code)], capture_output=True, text=True)
        print(r.stdout, end=''); print(r.stderr, end='', file=sys.stderr)
        if r.returncode:
            sys.exit(f'FAILED ({path.name})')
    run(APP, """
s.set_senders(['Astra'], 'ユーザー')
a = s.send(op(), 'Astra', '姫', 'OPS-192', '一'); s.event(op(), a['id'], 'received', '姫', revision=1)
b = s.send(op(), 'Astra', '姫', 'OPS-192', '二', follows=a['id'])
print('new: thread', [x['id'][-4:] for x in s.thread(b['id'])['letters']])
open({0!r}, 'w').write(json.dumps([a['id'], b['id']]))
""".replace('{0!r}', repr(str(tmp / 'ids.json'))))
    run(old, f"""
a, b = json.load(open({str(tmp / 'ids.json')!r}))
assert {{x['id'] for x in s.letters()['letters']}} == {{a, b}} and s.letter(b)['state'] == 'sent'
c = s.send(op(), 'Astra', '姫', 'OPS-192', '三')
for e, who, kw in (('received', '姫', dict(revision=1)), ('started', '姫', {{}}), ('returned', '姫', dict(body='返')), ('closed', 'Astra', {{}})):
    s.event(op(), c['id'], e, who, **kw)
s.event(op(), b, 'received', '姫', revision=1)
print('old: list', len(s.letters()['letters']), 'brief', len(s.letters_brief()['letters']), 'closed', s.letter(c['id'])['state'], 'inbox', len(s.inbox('姫')['letters']))
""")
    run(APP, f"""
a, b = json.load(open({str(tmp / 'ids.json')!r}))
t = s.thread(b)
assert [x['id'] for x in t['letters']] == [a, b] and t['delta']['request']['basis'] == 'receipt'
print('new again: thread', len(t['letters']), 'events', len(t['events']))
""")
print('OK: the base code reads and uses the extended DB; the new code still reads the thread')
