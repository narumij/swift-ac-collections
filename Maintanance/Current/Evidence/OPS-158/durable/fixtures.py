"""D1-D3 as store operations, derived from the accepted ../result.json at run time (no second copy of the sample).

The adoption records name the accepted trial result as their source of record; they restate an external decision
recorded at the cited canonical line, and they grant nothing. The scope keys and decided_by values are the trial's
reading of those canonical lines, not new policy.
"""
import json
from pathlib import Path

RESULT = Path(__file__).resolve().parent.parent / 'result.json'
ACTOR = 'Claude（姫、OPS-158 durable fixture）'
SCOPES = {'D1': 'registry-v3/version-order', 'D2': 'registry-v3/new-card-formalization', 'D3': 'registry-v3/restore-reopening'}
DECIDED_BY = {'D1': 'user', 'D2': 'user', 'D3': 'user (adopted cutover plan)'}


def operations(result_path=RESULT):
    """[(op_id, request)] registering D1-D3, recording their adoption, and adding the sample references."""
    sample = json.loads(Path(result_path).read_text(encoding='utf-8'))
    ops = []
    for did, source in sorted(sample['decisions'].items()):
        ops.append((f'fixture-register-{did}', {'kind': 'register', 'actor': ACTOR, 'id': did, 'scope': SCOPES[did],
                                                'statement': source['text'], 'source': source}))
        ops.append((f'fixture-adopt-{did}', {'kind': 'record_adoption', 'actor': ACTOR, 'id': did, 'revision': 1, 'replaces': None,
                                             'decided_by': DECIDED_BY[did], 'source': {'record': 'accepted OPS-158 trial result', 'base': sample['base'],
                                                                                       'path': source['path'], 'line': source['line']}}))
    for did, refs in sorted(sample['queries'].items()):
        for ref in refs:
            ops.append((f'fixture-ref-{ref["id"]}', {'kind': 'add_reference', 'actor': ACTOR, 'ref_id': ref['id'], 'decision': did,
                                                     'revision': 1, 'ref_kind': ref['kind'], 'locator': ref['locator']}))
    return ops
