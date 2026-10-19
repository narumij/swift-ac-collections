#!/usr/bin/env python3
"""OPS-165 isolated Studio adapter: export the V3 experiment DB as a Studio document, and apply one Studio save back.

Function-level experiment (TASK_REGISTRY_V3_STUDIO_ADAPTER.md「接続契約の受入と実装区切り」), not browser validation and
not production. Production files (template, sync, serve, Inbox) are unchanged; studio_harness.cjs runs the real Studio
functions extracted from a read-only template with the listed compatibility patches.

export_doc(conn) -- scope 'all', focus kept as milestoneHead.
- source = {kind: 'v3-export', path: 'v3-db', generation, revision, generatedAt, payloadHash, payloadHashOf}. There is no
  source.sha256: the old field meant the Registry file and is not filled with a new meaning. payloadHash is a separate,
  named hash of the exported payload.
- raw is '' and sourceLine / relation quote are absent: compatibility values only, not a claim that a source exists
  (v3.absent). Milestone state is derived from the focus for display (v3.derived); cards also carry recordedDone.
  Version paths (milestone.gate) are display-only, built from version and position (v3.displayOnly), never edit evidence.
- Retired tasks are left out of tasks and listed in v3.retired; edges that touch them are listed in v3.hiddenEdges.

plan_save(conn, save) / apply_save(conn, save, actor, evidence) -- one save changes the state and/or owner of exactly ONE
task. Everything else is rejected for the whole save BEFORE any write: an old save (no V3 base), another generation,
more than one task, any other task field, a task set change, any edge, milestone link, milestone/plan or proposal change.
The accepted change is one update_task through registry_v3_write.apply (both fields in one transaction) with the save's
baseline values as the base; the operation ID is derived from the save bytes, so applying the same save again replays.
"""
import copy
import hashlib
import json

import registry_v3_read as r3
import registry_v3_write as w3

EDITABLE = ('state', 'owner')
ABSENT = ['task.raw', 'task.sourceLine', 'edge.raw', 'edge.sourceLine', 'milestoneRelation.source.quote', 'milestoneRelation.source.line', 'milestone.raw']
DERIVED = ['milestone.state (from the focus, display only)', 'skeleton milestoneRelations (from versions, cards and gates)']
DISPLAY_ONLY = ['milestone.gate (version path built from version and position)']


class SaveRejected(ValueError):
    """The save is not applied at all; nothing was written."""


def _canon(x):
    return json.dumps(x, ensure_ascii=False, sort_keys=True, separators=(',', ':'))


def export_doc(conn):
    view = r3.read(conn, 'all')
    gen, rev = w3.generation(conn), w3.revision(conn)
    focus = view['range']['focus']
    retired = {r[0] for r in conn.execute('SELECT id FROM retirements')}
    versions = view['order']['versions']
    fpos = versions.index(focus) if focus in versions else None
    parents = {b: a for a, b in view['relations']['management']}
    tasks = []
    for tid, t in sorted(view['ids']['tasks'].items()):
        if tid in retired:
            continue
        task = {'id': tid, 'state': t['state'], 'owner': t['owner'], 'item': t['item'], 'condition': t['condition'], 'detail': t['detail'],
                'raw': '', 'group': t['group'], 'permanent': t['permanent']}
        if tid in parents and parents[tid] not in retired:
            task['parentTask'] = parents[tid]
        tasks.append(task)
    hidden = [dict(e, graph=g) for g in ('management', 'progress', 'milestone') for e in view['edges'][g] if e['prerequisite'] in retired or e['successor'] in retired]
    edges = [{'successor': e['successor'], 'prerequisite': e['prerequisite'], 'flow': e['flow'], 'constraint': e['constraint']}
             for e in view['edges']['progress'] if e['prerequisite'] not in retired and e['successor'] not in retired]
    milestones, attrs = [], view['ids']['milestones']
    def ms(mid, item, state, gate, detail='', virtual=False, **extra):
        m = {'id': mid, 'kind': 'milestone', 'item': item, 'state': state, 'owner': '', 'condition': '', 'detail': detail, 'raw': '', 'gate': gate}
        if virtual:
            m['virtual'] = True
        m.update(extra)
        return m
    for i, v in enumerate(versions):
        before = fpos is not None and i < fpos
        reached = fpos is not None and i <= fpos
        folder = f'Maintanance/Milestones/{v}/'
        milestones.append(ms('START-' + v, 'START-' + v, 'DONE' if reached else 'ACTIVE', folder, virtual=True))
        for k, cid in enumerate(view['order']['cards'][v]):
            a = attrs[cid]
            milestones.append(ms(cid, a['name'], 'DONE' if before or a['recordedDone'] else 'ACTIVE', f'{folder}{(k + 1) * 10:02d}_{cid}.md', a['detail'], recordedDone=a['recordedDone']))
        milestones.append(ms('END-' + v, 'END-' + v, 'DONE' if before else 'ACTIVE', folder, virtual=True))
        gate = view['order']['gates'].get(v)
        if gate:
            milestones.append(ms(gate, attrs[gate]['name'], 'DONE' if before else 'ACTIVE', f'{folder}{gate}.md', attrs[gate]['detail']))
    relations = [{'prerequisite': e['prerequisite'], 'successor': e['successor'], 'constraint': e['constraint'], 'source': {'path': 'v3-db:milestone', 'quote': ''}}
                 for e in view['edges']['milestone'] if e['prerequisite'] not in retired and e['successor'] not in retired]
    relations += [{'prerequisite': a, 'successor': b, 'constraint': '接続は版・カード・ゲートから導出（V3 export）。', 'source': {'path': 'v3-db:skeleton', 'quote': ''}}
                  for a, b in view['relations']['skeleton']]
    payload = {'tasks': tasks, 'edges': edges, 'milestones': milestones, 'milestoneRelations': relations}
    return {
        'schemaVersion': 1,
        'source': {'kind': 'v3-export', 'path': 'v3-db', 'generation': gen, 'revision': rev, 'generatedAt': '',
                   'payloadHash': hashlib.sha256(_canon(payload).encode('utf-8')).hexdigest(),
                   'payloadHashOf': 'canonical JSON of tasks, edges, milestones and milestoneRelations of this export'},
        **copy.deepcopy(payload),
        'baseline': {'tasks': copy.deepcopy(tasks), 'edges': copy.deepcopy(edges), 'milestoneRelations': copy.deepcopy(relations),
                     'milestones': copy.deepcopy(milestones), 'milestoneHead': focus},  # every compared field has a base (fail closed)
        'milestoneHead': focus,
        'v3': {'generation': gen, 'revision': rev, 'focus': focus, 'scope': 'all', 'absent': ABSENT, 'derived': DERIVED, 'displayOnly': DISPLAY_ONLY,
               'retired': sorted(retired), 'hiddenEdges': hidden},
    }


DATA = ('tasks', 'edges', 'milestoneRelations', 'milestones', 'milestoneHead')
META = ('schemaVersion', 'source', 'v3', 'baseline', 'exportedAt', 'changes', 'studioSave', 'proposals')


def _keyed(xs, key, where):
    """Items by key; a duplicate key is refused, never collapsed."""
    if not isinstance(xs, list):
        raise SaveRejected(f'malformed V3 base: {where} is not a list')
    out = {}
    for x in xs:
        k = key(x)
        if k in out:
            raise SaveRejected(f'duplicate in {where}: ' + (k if isinstance(k, str) else ' -> '.join(k)))
        out[k] = x
    return out


def plan_save(conn, save):
    """The single update_task request of a save, or SaveRejected with the reason. Reads only; writes nothing.
    Fail closed: every compared field must have its base in the save, duplicates are refused, unknown fields are refused."""
    src, v3 = save.get('source') or {}, save.get('v3')
    if src.get('kind') != 'v3-export' or not isinstance(v3, dict) or 'sha256' in src:
        raise SaveRejected('old save: it has no V3 base (generation/revision); migration by manifest is not part of this step')
    if (src.get('generation'), src.get('revision')) != (v3.get('generation'), v3.get('revision')):
        raise SaveRejected('malformed V3 base: source and v3 disagree on generation/revision')
    if not isinstance(v3.get('generation'), str) or type(v3.get('revision')) is not int or v3['revision'] < 0:
        raise SaveRejected(f"malformed V3 base: revision {v3.get('revision')!r} / generation {v3.get('generation')!r}")
    if v3['generation'] != w3.generation(conn):
        raise SaveRejected(f"generation changed: the save was made on {v3['generation']}, the DB is {w3.generation(conn)}; export again")
    if v3['revision'] > w3.revision(conn):
        raise SaveRejected(f"malformed V3 base: revision {v3['revision']} is newer than the DB ({w3.revision(conn)})")
    unknown = sorted(set(save) - set(DATA) - set(META))
    if unknown:
        raise SaveRejected('unknown field: ' + ', '.join(unknown))
    base = save.get('baseline')
    if not isinstance(base, dict):
        raise SaveRejected('malformed V3 base: no baseline')
    for field in DATA:
        if field not in base:
            raise SaveRejected('malformed V3 base: baseline lacks ' + field)
        if field not in save:
            raise SaveRejected('malformed V3 base: the save lacks ' + field)
    rel_key = lambda e: (e['prerequisite'], e['successor'])
    keyed = {}
    for name, key in (('tasks', lambda t: t['id']), ('edges', rel_key), ('milestoneRelations', rel_key), ('milestones', lambda m: m['id'])):
        keyed[name] = (_keyed(save[name], key, name), _keyed(base[name], key, 'baseline.' + name))
    unsupported = []
    for name in ('edges', 'milestoneRelations'):
        now, before = keyed[name]
        if _canon(sorted(now.items())) != _canon(sorted(before.items())):
            unsupported.append(name)
    if _canon(save['milestones']) != _canon(base['milestones']):  # order matters for a plan
        unsupported.append('milestones (plan)')
    if save['milestoneHead'] != base['milestoneHead']:
        unsupported.append('focus (milestoneHead)')
    if save.get('proposals') or base.get('proposals'):
        unsupported.append('proposals')
    now, before = keyed['tasks']
    if set(now) != set(before):
        unsupported.append('task set')
    changed = {}
    for tid in sorted(set(now) & set(before)):
        fields = [k for k in sorted(set(now[tid]) | set(before[tid])) if now[tid].get(k) != before[tid].get(k)]
        if set(fields) - set(EDITABLE):
            unsupported.append(f'{tid}: ' + ', '.join(sorted(set(fields) - set(EDITABLE))))
        if fields:
            changed[tid] = fields
    if unsupported:
        raise SaveRejected('unsupported changes, nothing applied: ' + '; '.join(unsupported))
    if len(changed) != 1:
        raise SaveRejected(f'a save must change exactly one task, it changes {len(changed)}' + (': ' + ', '.join(changed) if changed else ''))
    (tid, fields), = changed.items()
    return {'kind': 'update_task', 'id': tid, 'base': {f: before[tid][f] for f in fields}, 'changes': {f: now[tid][f] for f in fields},
            'generation': v3['generation']}


def operation_id(save):
    return 'studio-save:' + hashlib.sha256(_canon(save).encode('utf-8')).hexdigest()[:32]


def apply_save(conn, save, actor, evidence):
    """Apply one save: plan_save first (rejection writes nothing), then one update_task. Returns (operation ID, result)."""
    request = plan_save(conn, save)
    op = operation_id(save)
    return op, w3.apply(conn, op, dict(request, actor=actor, evidence=evidence))
