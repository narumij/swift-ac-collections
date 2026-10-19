"""Read-only reuse of the accepted three-decision sample, not a policy authority."""
import argparse
import hashlib
import json
from pathlib import Path
import sqlite3

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
QUESTIONS = {'D1': '版の順序は何を正とするか',
             'D2': '正本文書なしで新規カードを正式登録できるか',
             'D3': '古いbackupを復元したら採番を再開してよいか'}

def inspect_span(locator, root=ROOT):
    try:
        lines = (root / locator['path']).read_text().splitlines()
    except FileNotFoundError:
        return 'source-missing'
    n = locator['line'] - 1
    if n >= len(lines):
        return 'needs-review'
    return ('same-cited-line' if hashlib.sha256(lines[n].encode()).hexdigest()
            == locator['sha256'] else 'needs-review')

def lookup(selected):
    sample = json.loads((HERE / 'result.json').read_text())
    with sqlite3.connect(':memory:') as db:
        db.execute('CREATE TABLE sample(id TEXT PRIMARY KEY, source TEXT, refs TEXT)')
        for did, source in sample['decisions'].items():
            db.execute('INSERT INTO sample VALUES(?,?,?)',
                       (did, json.dumps(source), json.dumps(sample['queries'][did])))
        results = []
        for did in selected:
            source_text, refs_text = db.execute('SELECT source,refs FROM sample WHERE id=?', (did,)).fetchone()
            source, refs = json.loads(source_text), json.loads(refs_text)
            results.append({'id': did, 'question': QUESTIONS[did],
                            'recorded_answer': source['text'], 'source': source,
                            'source_check': inspect_span(source),
                            'references': [dict(r, source_check=inspect_span(r['locator'])) for r in refs],
                            'caution': 'Same text is not proof of current authority or complete dependencies. No automatic permission.'})
    return results

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('decision', nargs='?', choices=QUESTIONS)
    args = parser.parse_args()
    print(json.dumps(lookup([args.decision] if args.decision else QUESTIONS), ensure_ascii=False, indent=2))
