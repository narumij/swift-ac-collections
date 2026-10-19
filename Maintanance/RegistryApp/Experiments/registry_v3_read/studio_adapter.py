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

OPS-168 change groups: plan_groups / apply_groups split a stored save into one group per changed task (its state/owner
changes, atomic), apply only the selected groups as separate operations save:<saveId>:<groupId>, and report applied,
already reflected, replayed, conflict, refused, changed content and unselected groups apart. Whole-save rejections stay.

plan_save(conn, save) / apply_save(conn, save, actor, evidence) -- one save changes the state and/or owner of exactly ONE
task. Everything else is rejected for the whole save BEFORE any write: an old save (no V3 base), another generation,
more than one task, any other task field, a task set change, any edge, milestone link, milestone/plan or proposal change.
The accepted change is one update_task through registry_v3_write.apply (both fields in one transaction) with the save's
baseline values as the base; the operation ID is derived from the save bytes, so applying the same save again replays.
"""
import copy
import hashlib
import json
import re
import urllib.parse

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


def _task_changes(conn, save):
    changed, now, before, v3, _ = _validate(conn, save, structural=False)
    return changed, now, before, v3


def _structural_diff(name, now, before, unsupported, expected_skeleton=None):
    """Removed and added keys of edges or (non-skeleton) milestone links; anything else that differs is unsupported.
    Only lines marked v3-db:skeleton are known derived lines. They are not diffed as links, but their key set must equal
    the skeleton implied by the save's own plan (expected_skeleton) or by the baseline; anything else is unsupported, so
    no line disappears silently. Lines with any other source are ordinary links."""
    skeleton = name == 'milestoneRelations'
    is_sk = lambda e: (e.get('source') or {}).get('path') == 'v3-db:skeleton'
    if skeleton:
        sk_now, sk_before = {k: v for k, v in now.items() if is_sk(v)}, {k: v for k, v in before.items() if is_sk(v)}
        want = set(sk_before) if expected_skeleton is None else expected_skeleton
        if set(sk_now) != want:
            unsupported.append('skeleton relations differ from the structure the save implies (derived lines are not edited)')
        now, before = {k: v for k, v in now.items() if not is_sk(v)}, {k: v for k, v in before.items() if not is_sk(v)}
    for k in sorted(set(now) & set(before)):
        if _canon(now[k]) != _canon(before[k]):
            unsupported.append(f'{name} {k[0]} -> {k[1]}: attributes changed in place')
    return sorted(set(before) - set(now)), sorted(set(now) - set(before)), now, before


DRAFT_ID = re.compile(r'draft-[1-9]\d*')
CARD_PATH = re.compile(r'Maintanance/Milestones/([^/]+)/([^/]+\.md)')


def _plan_diff(now, before):
    """OPS-172: the existing-card plan a save proposes. The display paths are read as a proposal only (confirmed by an
    explicit resolution). Cards are the baseline entries with recordedDone. Anything else that differs (a new or removed
    node, a gate or a virtual node, planCondition, recordedDone or other fields) makes the plan unit unsupported."""
    b, n = {m['id']: m for m in before}, {m['id']: m for m in now}
    versions = [m['id'][6:] for m in before if m.get('virtual') and m['id'].startswith('START-')]
    folder = lambda m: m['gate'].split('/')[2]
    out = {'unsupported': [], 'cardsBase': {}, 'cards': {}, 'renames': {}, 'skeleton': set()}
    if set(b) != set(n):
        out['unsupported'].append('new or removed milestones (new versions or cards are not part of this slice)')
    lists_before, lists_now = {v: [] for v in versions}, {v: [] for v in versions}
    for mid in sorted(set(b) & set(n)):
        old, new = b[mid], n[mid]
        if 'recordedDone' not in old:  # a gate or a virtual START/END: fixed
            if _canon(old) != _canon(new):
                out['unsupported'].append(f'{mid}: gates, versions and focus are fixed in this slice')
            continue
        changed = {k for k in set(old) | set(new) if old.get(k) != new.get(k)}
        if changed - {'gate', 'item'}:
            out['unsupported'].append(f'{mid}: ' + ', '.join(sorted(changed - {'gate', 'item'})) + ' cannot change here (planCondition is not adopted)')
        m_old, m_new = CARD_PATH.fullmatch(old.get('gate', '')), CARD_PATH.fullmatch(new.get('gate', ''))
        if not m_new or m_new.group(1) not in lists_now:
            out['unsupported'].append(f'{mid}: its path names no existing version')
            continue
        lists_before[m_old.group(1)].append((m_old.group(2), mid))
        lists_now[m_new.group(1)].append((m_new.group(2), mid))
        if 'item' in changed:
            if not isinstance(new.get('item'), str) or not new['item'].strip():
                out['unsupported'].append(f'{mid}: an empty name')
            out['renames'][mid] = {'base': old['item'], 'name': new.get('item')}
    for v in versions:
        before_ids, now_ids = [x for _, x in sorted(lists_before[v])], [x for _, x in sorted(lists_now[v])]
        if before_ids != now_ids:
            out['cardsBase'][v], out['cards'][v] = before_ids, now_ids
    gates = {folder(m): m['id'] for m in before if not m.get('virtual') and 'recordedDone' not in m}
    targets = {v: [x for _, x in sorted(lists_now[v])] for v in versions}
    for i, v in enumerate(versions):  # the skeleton the proposed plan implies (as registry_v3_read.skeleton derives it)
        chain = ['START-' + v] + targets[v] + ['END-' + v]
        out['skeleton'] |= set(zip(chain, chain[1:]))
        if v in gates:
            out['skeleton'].add(('END-' + v, gates[v]))
            if i + 1 < len(versions):
                out['skeleton'].add((gates[v], 'START-' + versions[i + 1]))
    return out


def _proposals(items, unsupported):
    if not isinstance(items, list):
        unsupported.append('proposals is not a list')
        return []
    ids = [p.get('id') if isinstance(p, dict) else None for p in items]
    for p in items:
        if not isinstance(p, dict) or not isinstance(p.get('id'), str) or not DRAFT_ID.fullmatch(p['id']) or not isinstance(p.get('title'), str) \
                or not p['title'].strip() or not isinstance(p.get('memo', ''), str) or set(p) - {'id', 'title', 'memo'}:
            unsupported.append(f'proposal {p!r}: needs id draft-N, a title and an optional memo only')
    if len(set(ids)) != len(ids):
        raise SaveRejected('duplicate in proposals')
    return [p for p in items if isinstance(p, dict)]


def _validate(conn, save, structural):
    """Whole-save validation shared by the single-task and the change-group paths; returns the changed fields per task.
    Fail closed: every compared field must have its base in the save, duplicates are refused, unknown fields are refused,
    and any unsupported (structural, plan, focus, proposal, other task field) change rejects the whole save."""
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
    unsupported, diffs = [], {}
    expected = None
    if structural and _canon(save['milestones']) != _canon(base['milestones']):
        diffs['plan'] = _plan_diff(save['milestones'], base['milestones'])
        expected = diffs['plan']['skeleton']
    for name in ('edges', 'milestoneRelations'):
        now, before = keyed[name]
        if structural:
            diffs[name] = _structural_diff(name, now, before, unsupported, expected if name == 'milestoneRelations' else None)
        elif _canon(sorted(now.items())) != _canon(sorted(before.items())):
            unsupported.append(name)
    if not structural and _canon(save['milestones']) != _canon(base['milestones']):  # order matters for a plan
        unsupported.append('milestones (plan)')
    if save['milestoneHead'] != base['milestoneHead']:
        unsupported.append('focus (milestoneHead)')
    if base.get('proposals'):
        unsupported.append('baseline proposals')
    if save.get('proposals'):
        if not structural:
            unsupported.append('proposals')
        else:
            diffs['proposals'] = _proposals(save['proposals'], unsupported)
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
    return changed, now, before, v3, diffs


def _request(tid, fields, now, before, v3):
    return {'kind': 'update_task', 'id': tid, 'base': {f: before[tid][f] for f in fields}, 'changes': {f: now[tid][f] for f in fields},
            'generation': v3['generation']}


def plan_save(conn, save):
    """The single update_task request of a save (OPS-165 single-task path), or SaveRejected. Reads only."""
    changed, now, before, v3 = _task_changes(conn, save)
    if len(changed) != 1:
        raise SaveRejected(f'a save must change exactly one task, it changes {len(changed)}' + (': ' + ', '.join(changed) if changed else ''))
    (tid, fields), = changed.items()
    return _request(tid, fields, now, before, v3)


GRAPHS = (('edges', 'edge', 'progress'), ('milestoneRelations', 'link', 'milestone'))


def plan_groups(conn, save):
    """Change groups of a save (OPS-168 task groups, OPS-170 structural groups). Reads only.
    - task:<ID>: all state/owner changes of one task, atomic, ready.
    - edge-remove / link-remove:<a>-><b>: ready, unless the same graph also has an addition (then pending: pairing).
    - edge-add / link-add:<a>-><b>: always pending: consultation (conditionReview from the UI is never cleared by a save),
      and also pending: pairing when the same graph has a removal.
    A rewire is never inferred from the diff; it exists only as an explicit pair resolution (apply_groups)."""
    changed, now, before, v3, diffs = _validate(conn, save, structural=True)
    groups = [{'groupId': 'task:' + tid, 'kind': 'task', 'status': 'ready', 'request': _request(tid, fields, now, before, v3)} for tid, fields in sorted(changed.items())]
    drafts = {p['id']: {'groupId': 'proposal:' + p['id'], 'kind': 'proposal', 'draft': p, 'edges': [], 'links': [], 'consumes': [],
                        'status': 'pending', 'pending': ['registration'], 'unsupported': []} for p in diffs.get('proposals', [])}
    for name, short, graph in GRAPHS:
        removed, added, cur, old = diffs[name]
        ambiguous = bool(removed and added)  # an addition that references a draft still makes a removal ambiguous
        for k in removed:
            groups.append({'groupId': f'{short}-remove:{k[0]}->{k[1]}', 'kind': 'remove', 'graph': graph, 'key': list(k), 'old': old[k],
                           'status': 'pending' if ambiguous else 'ready', 'pending': ['pairing'] if ambiguous else []})
        for k in added:
            ends = [x for x in k if DRAFT_ID.fullmatch(x)]
            if not ends:
                groups.append({'groupId': f'{short}-add:{k[0]}->{k[1]}', 'kind': 'add', 'graph': graph, 'key': list(k), 'new': cur[k],
                               'status': 'pending', 'pending': ['consultation'] + (['pairing'] if ambiguous else [])})
                continue
            for d in ends:  # an incident connection belongs to its draft's proposal group only, never to a structural group
                if d not in drafts:
                    raise SaveRejected(f'{name} {k[0]} -> {k[1]} references {d}, which is not a proposal of this save')
                g = drafts[d]
                g['edges' if graph == 'progress' else 'links'].append({'prerequisite': k[0], 'successor': k[1], **({'flow': cur[k].get('flow')} if graph == 'progress' else {})})
                g['consumes'].append(f'{short}-add:{k[0]}->{k[1]}')
                if len(ends) > 1:
                    g['status'], g['unsupported'] = 'unsupported', g['unsupported'] + [f'experiment-unsupported: draft-to-draft connection {k[0]} -> {k[1]}']
    groups += [drafts[d] for d in sorted(drafts)]
    plan = diffs.get('plan')
    if plan and (plan['cards'] or plan['renames'] or plan['unsupported']):
        groups.append({'groupId': 'plan:milestones', 'kind': 'plan', 'status': 'unsupported' if plan['unsupported'] else 'pending',
                       'pending': ['plan-confirmation'], 'unsupported': plan['unsupported'], 'cardsBase': plan['cardsBase'], 'cards': plan['cards'],
                       'renames': plan['renames']})
    if not groups:
        raise SaveRejected('the save changes nothing')
    return groups


def save_identity(save):
    """The stable identity of a save: the saveId given when it was stored. Without one, groups cannot be identified."""
    sid = (save.get('studioSave') or {}).get('saveId')
    if not isinstance(sid, str) or not sid:
        raise SaveRejected('the save has no saveId; store it first so its groups have a stable identity')
    return sid


def _base_of(graph, old):
    return {'flow': old['flow'], 'constraint': old['constraint']} if graph == 'progress' else {'constraint': old['constraint']}


def _units(groups, resolutions):
    """Validate the resolutions and build the applicable units (before any write). Returns (units by id, pair id per
    constituent). A unit is a ready group, a resolved standalone group, or one pair of a removal and an addition."""
    by_id = {g['groupId']: g for g in groups}
    res = resolutions or {}
    if not isinstance(res, dict) or set(res) - {'standalone', 'pairs', 'proposals', 'plan'}:
        raise SaveRejected('resolutions are {"standalone": {groupId: {...}}, "pairs": [...], "proposals": {groupId: {...}}}')
    standalone, pairs = res.get('standalone', {}), res.get('pairs', [])
    if not isinstance(standalone, dict) or not isinstance(pairs, list):
        raise SaveRejected('malformed resolutions')
    used = {}
    def consult(r, what):
        if not isinstance(r, dict) or not isinstance(r.get('constraint'), str) or not r['constraint'].strip() or not isinstance(r.get('evidence'), list) or not r['evidence']:
            raise SaveRejected(f'{what}: a consulted constraint (non-empty) and evidence (non-empty list) are required')
    def take(gid, by):
        if gid not in by_id or by_id[gid]['kind'] in ('task', 'proposal'):
            raise SaveRejected(f'resolution names no structural group of this save: {gid}')
        if gid in used:
            raise SaveRejected(f'{gid} is used by more than one resolution ({used[gid]}, {by})')
        used[gid] = by
    units, pair_of = {}, {}
    for gid, r in sorted(standalone.items()):
        take(gid, 'standalone')
        g = by_id[gid]
        if g['kind'] == 'add':
            consult(r, gid)
        elif r not in ({}, {'standalone': True}):
            raise SaveRejected(f'{gid}: a standalone removal takes no constraint or evidence')
        units[gid] = {'group': g, 'resolution': r, 'consumes': [gid]}
    for i, p in enumerate(pairs):
        if not isinstance(p, dict) or set(p) != {'remove', 'add', 'constraint', 'evidence'}:
            raise SaveRejected(f'pairs[{i}] needs exactly remove, add, constraint and evidence')
        rid, aid = p['remove'], p['add']
        take(rid, f'pairs[{i}]')
        take(aid, f'pairs[{i}]')
        r, a = by_id[rid], by_id[aid]
        if r['kind'] != 'remove' or a['kind'] != 'add' or r['graph'] != a['graph']:
            raise SaveRejected(f'pairs[{i}] must pair one removal with one addition of the same graph')
        if 'pairing' not in r['pending']:
            raise SaveRejected(f'pairs[{i}]: {rid} is not held for pairing')
        consult(p, f'pairs[{i}]')
        uid = f"rewire:{r['graph']}:{r['key'][0]}->{r['key'][1]}=>{a['key'][0]}->{a['key'][1]}"
        units[uid] = {'pair': (r, a), 'resolution': p, 'consumes': [rid, aid]}
        pair_of[rid] = pair_of[aid] = uid
    proposals = res.get('proposals', {})
    if not isinstance(proposals, dict):
        raise SaveRejected('malformed proposal resolutions')
    for gid, r in sorted(proposals.items()):
        g = by_id.get(gid)
        if not g or g['kind'] != 'proposal':
            raise SaveRejected(f'resolution names no proposal of this save: {gid}')
        if not isinstance(r, dict) or set(r) != {'prefix', 'fields', 'constraints', 'evidence'}:
            raise SaveRejected(f'{gid}: a proposal resolution needs exactly prefix, fields, constraints and evidence')
        if not isinstance(r['prefix'], str) or not re.fullmatch(r'[A-Z]+', r['prefix']) or not isinstance(r['fields'], dict):
            raise SaveRejected(f'{gid}: prefix (A-Z) and fields are required')
        wanted = {f"edge:{e['prerequisite']}->{e['successor']}" for e in g['edges']} | {f"link:{e['prerequisite']}->{e['successor']}" for e in g['links']}
        if not isinstance(r['constraints'], dict) or set(r['constraints']) != wanted or not all(isinstance(v, str) and v.strip() for v in r['constraints'].values()):
            raise SaveRejected(f'{gid}: a consulted constraint is required for exactly these connections: {sorted(wanted)}')
        if not isinstance(r['evidence'], list) or not r['evidence']:
            raise SaveRejected(f'{gid}: evidence (non-empty list) is required')
        units[gid] = {'group': g, 'resolution': r, 'consumes': [gid] + g['consumes']}
    if 'plan' in res:
        g, r = by_id.get('plan:milestones'), res['plan']
        if not g:
            raise SaveRejected('resolution names a plan, but the save proposes none')
        if not isinstance(r, dict) or set(r) != {'cards', 'renames', 'evidence'} or not isinstance(r['evidence'], list) or not r['evidence']:
            raise SaveRejected('plan:milestones: the resolution restates cards and renames and gives evidence (non-empty list)')
        if r['cards'] != g['cards'] or r['renames'] != {k: v['name'] for k, v in g['renames'].items()}:
            raise SaveRejected('plan:milestones: the confirmation does not match the plan the save proposes')
        if g['status'] != 'unsupported':
            units['plan:milestones'] = {'group': g, 'resolution': r, 'consumes': ['plan:milestones']}
    return units, pair_of


def _plan_request(unit, v3):
    g = unit['group']
    return {'kind': 'apply_plan', 'cardsBase': g['cardsBase'], 'cards': g['cards'], 'renames': g['renames'], 'generation': v3['generation']}


def _proposal_request(unit, sid, v3, ancestry):
    g, r = unit['group'], unit['resolution']
    fields = dict({'item': g['draft']['title']}, **r['fields'])
    c = r['constraints']
    return {'kind': 'register_proposal', 'prefix': r['prefix'], 'fields': fields, 'proposal': {'saveId': sid, 'draftId': g['draft']['id']},
            'edges': [dict(e, constraint=c[f"edge:{e['prerequisite']}->{e['successor']}"]) for e in g['edges']],
            'links': [dict(e, constraint=c[f"link:{e['prerequisite']}->{e['successor']}"]) for e in g['links']],
            'ancestry': ancestry, 'generation': v3['generation']}


def _identity(conn, groups, ancestry):
    """Explicit ancestry only: {'independent': True} or {'ancestors': [saveId, ...]}. Anything else keeps every proposal
    pending on identity; an ancestor that already registered the same draftId keeps that proposal pending."""
    valid = ancestry == {'independent': True} or (isinstance(ancestry, dict) and set(ancestry) == {'ancestors'} and isinstance(ancestry['ancestors'], list)
                                                  and ancestry['ancestors'] and all(isinstance(a, str) and a for a in ancestry['ancestors']))
    for g in groups:
        if g['kind'] != 'proposal':
            continue
        if not valid:
            g['pending'] = g['pending'] + ['identity: ancestry not stated (state independent or the known ancestor saves)']
            continue
        for anc in ancestry.get('ancestors', []):
            row = conn.execute('SELECT formal_id FROM proposal_map WHERE save_id = ? AND draft_id = ?', (anc, g['draft']['id'])).fetchone()
            if row:
                g['pending'] = g['pending'] + [f"identity: ancestor save {anc} registered {g['draft']['id']} as {row[0]}"]


def _unit_request(unit, v3, save):
    r = unit['resolution']
    if 'pair' in unit:
        rem, add = unit['pair']
        kind = 'rewire_edge' if rem['graph'] == 'progress' else 'rewire_milestone_link'
        req = {'kind': kind, 'from': {'prerequisite': rem['key'][0], 'successor': rem['key'][1]}, 'to': {'prerequisite': add['key'][0], 'successor': add['key'][1]},
               'base': _base_of(rem['graph'], rem['old']), 'constraint': r['constraint']}
        if rem['graph'] == 'progress':
            req.update(graph='progress', flow=add['new'].get('flow'))
    else:
        g = unit['group']
        a, b = g['key']
        if g['kind'] == 'remove':
            req = ({'kind': 'remove_edge', 'graph': 'progress'} if g['graph'] == 'progress' else {'kind': 'remove_milestone_link'})
            req.update(prerequisite=a, successor=b, base=_base_of(g['graph'], g['old']))
        else:
            req = ({'kind': 'add_edge', 'graph': 'progress', 'flow': g['new'].get('flow')} if g['graph'] == 'progress' else {'kind': 'add_milestone_link'})
            req.update(prerequisite=a, successor=b, constraint=r['constraint'])
    return dict(req, generation=v3['generation'], consumes=unit['consumes'], resolutionEvidence=r.get('evidence', []))


def unit_operation_id(sid, uid):
    """save:<escaped saveId>:<unitId>. The saveId is percent-escaped (no ':' left), so distinct saves never share an ID."""
    return 'save:' + urllib.parse.quote(sid, safe='') + ':' + uid


def _consumed(conn, sid):
    """Preflight only (for a clear early message): constituent -> claiming operation, by the exact save identity.
    The enforcing check runs inside registry_v3_write.apply under the write transaction."""
    return dict(conn.execute('SELECT constituent, operation_id FROM consumption_claims WHERE scope = ?', (sid,)).fetchall())


def gid_resolved(resolutions, gid):
    return isinstance(resolutions, dict) and isinstance(resolutions.get('proposals'), dict) and gid in resolutions['proposals']


def apply_groups(conn, save, selected, actor, evidence, resolutions=None, ancestry=None, _after_preflight=None):
    """Apply only the selected groups of a stored save, each as its own operation (ID = save:<saveId>:<unitId>).
    Selectable units: ready groups, resolved standalone groups, and pairs (rewire:...), which consume both sides.
    Returns every unit in exactly one of applied, alreadyReflected, replayed, conflict, refused, changedContent, pending,
    unselected. Units are applied one by one (removals, rewires, additions, tasks); this is a fixed order, not an
    independence guarantee: cross-group atomicity is unsupported and partial results are reported as they are."""
    sid = save_identity(save)
    groups = plan_groups(conn, save)
    v3 = save['v3']
    _identity(conn, groups, ancestry)
    units, pair_of = _units(groups, resolutions)
    for gid, u in list(units.items()):  # a resolved proposal still waits when identity is unclear or it is unsupported
        g = u.get('group', {})
        if g.get('kind') == 'proposal' and (g['status'] == 'unsupported' or any(p.startswith('identity') for p in g['pending'])):
            del units[gid]
    for g in groups:
        gid = g['groupId']
        if g['status'] == 'ready' and gid not in units and gid not in pair_of:
            units[gid] = {'group': g, 'resolution': {}, 'consumes': [gid]}
    pending = {g['groupId']: [p for p in g['pending'] if not (g['kind'] == 'proposal' and p == 'registration' and gid_resolved(resolutions, g['groupId']))]
               for g in groups if g['groupId'] not in units and g['groupId'] not in pair_of and g['status'] != 'unsupported'}
    unsupported = {g['groupId']: g['unsupported'] for g in groups if g['status'] == 'unsupported'}
    if not isinstance(selected, list) or len(set(selected)) != len(selected):
        raise SaveRejected('the selection must be a list without duplicates')
    for x in selected:
        if x in pair_of:
            raise SaveRejected(f'{x} is part of {pair_of[x]}; select the pair, not one side')
        if x not in units and x not in pending and x not in unsupported:
            raise SaveRejected(f'the selection names no unit of this save: {x}')
    consumed = _consumed(conn, sid)
    for uid in selected:
        if uid in units:
            for c in units[uid]['consumes']:
                op = unit_operation_id(sid, uid)
                if c in consumed and consumed[c] != op:
                    raise SaveRejected(f'{c} was already consumed by {consumed[c]}; it cannot be applied again in another form (fail closed)')
    if _after_preflight:
        _after_preflight()  # test-only interleaving point: after the preflight, before any write
    order = {'remove': 0, 'pair': 1, 'add': 2, 'proposal': 3, 'plan': 4, 'task': 5}
    rank = lambda uid: (order['pair'] if 'pair' in units[uid] else order[units[uid]['group']['kind']], uid)
    out = {k: [] for k in ('applied', 'alreadyReflected', 'replayed', 'conflict', 'refused', 'changedContent', 'pending', 'unselected')}
    for uid in sorted((u for u in selected if u in pending), key=str):
        out['pending'].append({'groupId': uid, 'needs': pending[uid]})
    for uid in sorted((u for u in selected if u in unsupported), key=str):
        out['refused'].append({'groupId': uid, 'error': '; '.join(unsupported[uid])})
    for uid in sorted((u for u in selected if u in units), key=rank):
        unit = units[uid]
        kind = unit.get('group', {}).get('kind')
        request = (unit['group']['request'] if kind == 'task' else _proposal_request(unit, sid, v3, ancestry) if kind == 'proposal'
                   else _plan_request(unit, v3) if kind == 'plan' else _unit_request(unit, v3, save))
        request = dict(request, consumes=unit['consumes'], consumerScope=sid)
        op = unit_operation_id(sid, uid)
        known = w3.operation(conn, op)
        try:
            result = w3.apply(conn, op, dict(request, actor=actor, evidence=evidence + unit['resolution'].get('evidence', [])))
        except w3.OperationMismatch as error:
            out['changedContent'].append({'groupId': uid, 'operationId': op, 'error': str(error)})
            continue
        except w3.IdentityHeld as error:  # decided under the write transaction: still pending, nothing recorded
            out['pending'].append({'groupId': uid, 'needs': [str(error)]})
            continue
        except w3.Refused as error:
            entry = {'groupId': uid, 'operationId': op, 'error': str(error), **({'replayed': True} if known else {})}
            out['conflict' if str(error).startswith('conflict on') else 'refused'].append(entry)
            continue
        entry = {'groupId': uid, 'operationId': op, 'result': result}
        if known:
            out['replayed'].append(entry)
        elif result.get('applied') == [] and result.get('kind') == 'update_task':
            out['alreadyReflected'].append(entry)
        else:
            out['applied'].append(entry)
    chosen = set(selected)
    for uid in sorted(set(units) | set(pending) | set(unsupported)):
        if uid not in chosen:
            out['unselected'].append(uid)
    out['complete'] = not any(out[k] for k in ('conflict', 'refused', 'changedContent', 'pending', 'unselected'))
    out['saveId'], out['groups'] = sid, [g['groupId'] for g in groups]
    return out


def operation_id(save):
    return 'studio-save:' + hashlib.sha256(_canon(save).encode('utf-8')).hexdigest()[:32]


def apply_save(conn, save, actor, evidence):
    """Apply one save: plan_save first (rejection writes nothing), then one update_task. Returns (operation ID, result)."""
    request = plan_save(conn, save)
    op = operation_id(save)
    return op, w3.apply(conn, op, dict(request, actor=actor, evidence=evidence))
