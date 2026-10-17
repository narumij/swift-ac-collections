#!/usr/bin/env python3
"""OPS-074 shallow check v2: reads a fixed commit, not the working tree.

Usage (repository root):  python3 Maintanance/Current/Evidence/OPS-074/shallow_check_v2.py <commit> > out.json
- Documents, reference targets and history are all taken at <commit> (full SHA recorded).
- Existence = `git cat-file -e <commit>:<path>` (file or directory in that tree).
- History = `git log <commit> -- <path>` (only history reachable from <commit>).
- Every occurrence keeps its line number; nothing is collapsed.
Only existence is judged. Whether a reference is semantically right is not.
"""
import hashlib, json, os, re, subprocess, sys

CUR = 'Maintanance/Current'
LINK = re.compile(r'\]\(([^)\s#]+)(?:#[^)]*)?\)')
TICK = re.compile(r'`((?:\.\./|Maintanance/|Sources/|Tests/|Benchmarks/|\.github/|Documentation/)[^`\s]+)`')
HASH = re.compile(r'`([0-9a-f]{7,40})`')

def git(*args):
    return subprocess.run(['git', *args], capture_output=True, text=True).stdout.strip()

rev = git('rev-parse', '--verify', sys.argv[1] + '^{commit}')
if not rev:
    sys.exit('unknown commit')

def exists(path):
    return subprocess.run(['git', 'cat-file', '-e', f'{rev}:{path}'], capture_output=True).returncode == 0

def resolve(kind, ref):
    if kind == 'link' or ref.startswith('../'):
        return [os.path.normpath(os.path.join(CUR, ref))]
    return [os.path.normpath(ref), os.path.normpath(os.path.join('Maintanance', ref)),
            os.path.normpath(os.path.join(CUR, ref))]

docs = sorted(n for n in git('ls-tree', '--name-only', f'{rev}:{CUR}').splitlines() if n.endswith('.md'))
refs, hashes = [], []
for f in docs:
    lines = git('show', f'{rev}:{CUR}/{f}').split('\n')
    for no, line in enumerate(lines, 1):
        for kind, rx in (('link', LINK), ('tick', TICK)):
            for m in rx.finditer(line):
                ref = m.group(1)
                if ref.startswith(('http', 'mailto:')) or any(c in ref for c in '*<…'):
                    continue
                ref = ref.rstrip('.,;:）)')
                bare = re.sub(r':\d+(-\d+)?$', '', ref)
                cands = resolve(kind, bare)
                hit = next((c for c in cands if exists(c)), None)
                rec = {'doc': f, 'line': no, 'kind': kind, 'ref': ref,
                       'claim': 'referenced path exists at commit', 'method': 'git cat-file -e <commit>:<path>'}
                if hit:
                    rec['status'] = 'exists' if hit == cands[0] and bare == ref else (
                        'exists_line_suffix' if hit == cands[0] else 'exists_other_base')
                    rec['path'] = hit
                else:
                    p = cands[0]
                    last = git('log', rev, '--format=%H %ad', '--date=short', '-1', '--', p)
                    deleted = git('log', rev, '--format=%H', '--diff-filter=D', '-1', '--', p)
                    rec.update(path=p, status='missing_in_history' if last else 'missing_no_history',
                               last_commit=last or None, deleted_in=deleted or None)
                refs.append(rec)
        for h in HASH.findall(line):
            if re.search(r'[a-f]', h) and re.search(r'\d', h):
                hashes.append({'doc': f, 'line': no, 'hash': h, 'object_type': git('cat-file', '-t', h) or 'none'})

script = open(__file__, 'rb').read()
summary = {
    'input_commit': rev,
    'read_from': 'git tree at input_commit (working tree not read)',
    'history_range': f'commits reachable from {rev}',
    'script': os.path.relpath(__file__), 'script_sha256': hashlib.sha256(script).hexdigest(),
    'documents': len(docs), 'document_list': docs,
    'reference_occurrences': len(refs),
    'reference_status': {s: sum(r['status'] == s for r in refs) for s in sorted({r['status'] for r in refs})},
    'hash_occurrences': len(hashes),
    'hash_object_type': {t: sum(h['object_type'] == t for h in hashes) for t in sorted({h['object_type'] for h in hashes})},
}
json.dump({'summary': summary, 'references': refs, 'hashes': hashes}, sys.stdout, ensure_ascii=False, indent=1)
