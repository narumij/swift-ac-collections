#!/usr/bin/env python3
"""OPS-074 shallow check: path references and commit hashes in Maintanance/Current/*.md.

Run from the repository root:  python3 Maintanance/Current/Evidence/OPS-074/shallow_check.py > out.json
Only existence is checked. Whether a reference is semantically right is not judged here.
"""
import json, os, re, subprocess, sys

CUR = 'Maintanance/Current'
LINK = re.compile(r'\]\(([^)\s#]+)(?:#[^)]*)?\)')
TICK = re.compile(r'`((?:\.\./|Maintanance/|Sources/|Tests/|Benchmarks/|\.github/|Documentation/)[^`\s]+)`')
HASH = re.compile(r'`([0-9a-f]{7,40})`')

def git(*args):
    return subprocess.run(['git', *args], capture_output=True, text=True).stdout.strip()

def resolve(doc_dir, kind, ref):
    """Candidate paths. Links resolve against the document directory only.
    Backticked paths: '../' against the document directory, otherwise the repository root,
    then Maintanance/ and the document directory as alternative bases."""
    if kind == 'link' or ref.startswith('../'):
        return [os.path.normpath(os.path.join(doc_dir, ref))]
    return [os.path.normpath(ref), os.path.normpath(os.path.join('Maintanance', ref)),
            os.path.normpath(os.path.join(doc_dir, ref))]

docs = sorted(f for f in os.listdir(CUR) if f.endswith('.md'))
refs, hashes = [], []
for f in docs:
    text = open(os.path.join(CUR, f), encoding='utf-8').read()
    seen = set()
    for kind, rx in (('link', LINK), ('tick', TICK)):
        for m in rx.finditer(text):
            ref = m.group(1)
            if ref.startswith(('http', 'mailto:')) or any(c in ref for c in '*<…'):  # skip URLs, globs, placeholders
                continue
            ref = ref.rstrip('.,;:）)')
            if (kind, ref) in seen:
                continue
            seen.add((kind, ref))
            bare = re.sub(r':\d+(-\d+)?$', '', ref)          # strip file:line suffix
            cands = resolve(CUR, kind, bare)
            hit = next((c for c in cands if os.path.exists(c)), None)
            rec = {'doc': f, 'kind': kind, 'ref': ref}
            if hit:
                rec['status'] = 'exists' if hit == cands[0] and bare == ref else (
                    'exists_line_suffix' if hit == cands[0] else 'exists_other_base')
                rec['path'] = hit
            else:
                p = cands[0]
                last = git('log', '--all', '--format=%h %ad', '--date=short', '-1', '--', p)
                deleted = git('log', '--all', '--format=%h', '--diff-filter=D', '-1', '--', p)
                rec.update(path=p, status='missing_in_history' if last else 'missing_no_history',
                           last_commit=last or None, deleted_in=deleted or None)
            refs.append(rec)
    for h in sorted(set(HASH.findall(text))):
        if not (re.search(r'[a-f]', h) and re.search(r'\d', h)):
            continue
        t = git('cat-file', '-t', h) or 'none'
        hashes.append({'doc': f, 'hash': h, 'object_type': t})

summary = {
    'input_commit': git('rev-parse', '--short', 'HEAD'),
    'documents': len(docs),
    'references': len(refs),
    'reference_status': {s: sum(r['status'] == s for r in refs) for s in sorted({r['status'] for r in refs})},
    'hashes': len(hashes),
    'hash_object_type': {t: sum(h['object_type'] == t for h in hashes) for t in sorted({h['object_type'] for h in hashes})},
}
json.dump({'summary': summary, 'references': refs, 'hashes': hashes}, sys.stdout, ensure_ascii=False, indent=1)
