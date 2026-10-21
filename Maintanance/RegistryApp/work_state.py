"""Observable, in-memory view models for the work page.

The caller supplies already-read activity and approval records.  This module does
no file or database I/O; a failed read retains the last good display snapshot.
"""
from copy import deepcopy
from datetime import datetime
from threading import Condition
from zoneinfo import ZoneInfo
import re
import hashlib

import activity


JST = ZoneInfo('Asia/Tokyo')
LABELS = {'request': '依頼', 'work': '作業', 'verification': '確認',
          'acceptance': '受入', 'return': '返却', 'recheck': '再確認',
          'complete': '完了', 'awaiting-commit': 'コミット待ち', 'commit': 'コミット'}
STAGES = {'request': '依頼済み', 'work': '作業中', 'verification': '確認中',
          'return': '返却・受入待ち', 'recheck': '再確認中', 'acceptance': '受入済み',
          'complete': '作業区切り', 'awaiting-commit': 'コミット待ち',
          'commit': '記録コミット済み'}
APPROVAL_LABELS = {'pending': '承認待ち', 'approved': '承認済み',
                   'claimed': '実行直前に確保済み・取消不可', 'consumed': '使用済み',
                   'cancelled': '取消済み'}
PROBE = re.compile(r'(?:^|[\s\u3000])(?:PING|WAKE)-\d{8}-[A-Z0-9]+[：:]|^ACK (?:PING|WAKE)-\d{8}-[A-Z0-9]+(?![A-Za-z0-9])')
REQUEST = re.compile(r'^([A-Z][A-Z0-9]*-\d{8}-[A-Z0-9]+)(?![A-Za-z0-9])')
WAKE = re.compile(r'^(WAKE-\d{8}-[A-Z0-9]+)：')


def _date(value):
    return datetime.fromisoformat(value.replace('Z', '+00:00')).astimezone(JST)


def _row(raw):
    v = activity.validate_event(raw)
    dt = _date(v['timestamp'])
    short = dt.strftime('%m/%d %H:%M:%S')
    local = dt.strftime('%Y/%m/%d %H:%M:%S JST')
    event, owner, reason, task = (v[k] for k in ('event', 'owner', 'reason', 'taskId'))
    sha, nxt, presence = v['commitSha'], v.get('next', ''), v.get('presence', '')
    label = '検討中' if event == 'work' and re.match(r'^検討中[:：]', reason) else LABELS[event]
    who = owner + ' → ' + nxt if event == 'request' and nxt and nxt not in ('none', 'unknown') else owner
    return {'id': v['id'], 'event': event,
            'raw': {'taskId': task, 'owner': owner, 'reason': reason, 'at': v['timestamp'],
                    'shortTime': short, 'next': nxt, 'presence': presence},
            'heading': f'{task} · {who} · {label}',
            'detail': owner + ' · ' + short + (' · ' + reason if reason else '') + (' · ' + sha[:8] if sha else ''),
            'title': task + ' · ' + label + ' · ' + owner + ' · ' + local +
                     (' · ' + reason if reason else '') + (' · commit ' + sha if sha else '')}


def _request_id(reason):
    match = REQUEST.match(reason or '')
    if match and not match[1].startswith(('PING-', 'WAKE-', 'UPDATE-')):
        return match[1]
    return ''


def _starts(rows):
    asked, starts = set(), set()
    for row in rows:
        raw = row['raw']
        request_id = _request_id(raw['reason'])
        if not request_id:
            continue
        if row['event'] == 'request' and raw['next']:
            asked.add((request_id, raw['taskId'], raw['next']))
        elif (row['event'] == 'work' and raw['presence'] == 'working'
              and (request_id, raw['taskId'], raw['owner']) in asked):
            starts.add(row['id'])
    return starts


def _notice(row, starts):
    return bool(row['raw']['presence'] and row['event'] == 'work' and row['id'] not in starts)


def _probe(reason):
    return bool(PROBE.search(reason or ''))


def _timeline(rows):
    starts = _starts(rows)
    latest = next((r for r in reversed(rows) if not _probe(r['raw']['reason']) and not _notice(r, starts)), None)
    current = ({'heading': '最新の活動：' + latest['heading'], 'detail': latest['detail'], 'title': latest['title']}
               if latest else {'heading': '最新の活動：未登録', 'detail': '担当が更新する進行記録です。', 'title': ''})
    cards = [{'id': row['id'], 'heading': row['heading'], 'title': row['title'],
              'event': row['event'], 'age': 'latest' if i == len(rows) - 1 else 'older'}
             for i, row in enumerate(rows)]
    return {'cards': cards, 'current': current, 'status': '' if rows else '記録なし'}


def _lane(rows, approvals, registry_state, first_starts):
    starts, by_task = _starts(rows), {}

    def item(task):
        if task not in by_task:
            state = registry_state(task) if callable(registry_state) else registry_state.get(task, '')
            by_task[task] = {'taskId': task, 'last': None, 'start': None,
                             'approvals': {'pending': 0, 'approved': 0, 'claimed': 0},
                             'registryState': state or '', 'approvalEntries': []}
        return by_task[task]

    for row in rows:
        raw = row['raw']
        if _probe(raw['reason']) or _notice(row, starts):
            continue
        it = item(raw['taskId'])
        if not it['last'] or _date(raw['at']) >= _date(it['last']['at']):
            it['last'] = {'event': row['event'], **raw, 'start': row['id'] in starts}
    # Keep the earliest observed start for this server's life, even if a later
    # source window no longer contains it. No persistent start dates are invented.
    for row in rows:
        raw = row['raw']
        if _probe(raw['reason']) or _notice(row, starts):
            continue
        actual = row['event'] == 'work' and (row['id'] in starts or bool(re.match(
            r'^(?:[A-Z][A-Z0-9]*-\d{8}-[A-Z0-9]+[：:]?)?着手(?:[（:：\s]|$)', raw['reason'])))
        if not actual and row['event'] != 'request':
            continue
        candidate = {**raw, 'source': 'started' if actual else 'request'}
        previous = first_starts.get(raw['taskId'])
        if (previous is None or (actual and previous['source'] == 'request') or
                (candidate['source'] == previous['source'] and _date(candidate['at']) < _date(previous['at']))):
            first_starts[raw['taskId']] = candidate
    for row in approvals:
        if row['status'] in ('pending', 'approved', 'claimed'):
            it = item(row['taskId'])
            it['approvals'][row['status']] += 1
            it['approvalEntries'].append(deepcopy(row))
    for it in by_task.values():
        it['start'] = first_starts.get(it['taskId'])

    def sort_key(it):
        return (not bool(it['approvals']['pending']), it['start'] is None,
                _date(it['start']['at']).timestamp() if it['start'] else 0, it['taskId'])

    cards = []
    for it in sorted(by_task.values(), key=sort_key):
        last, start, counts = it['last'], it['start'], it['approvals']
        if not last and not sum(counts.values()):
            continue
        if last:
            event, reason = last['event'], last['reason']
            stage = ('着手' if last['start'] else '相談待ち' if event == 'work' and re.match(r'^相談待ち[:：]', reason)
                     else last['owner'] + '検討中' if event == 'work' and re.match(r'^検討中[:：]', reason)
                     else STAGES[event])
        else:
            stage = '活動情報なし'
        nxt = last['next'] if last else ''
        next_text = ('次：ユーザー（承認待ち）' if counts['pending'] else 'この仕事は終了' if nxt == 'none'
                     else '次：ユーザー' if nxt == 'user' else '次：' + nxt if nxt else '次：不明')
        next_kind = ('approval' if counts['pending'] else 'ended' if nxt == 'none'
                     else 'known' if nxt else 'unknown')
        badge = ('承認 待ち' + str(counts['pending']) + ' · 済み' + str(counts['approved']) +
                 (' · 確保' + str(counts['claimed']) if counts['claimed'] else '')
                 if sum(counts.values()) else '承認なし')
        owner, time, reason = (last['owner'], last['shortTime'], last['reason']) if last else ('', '', '')
        start_text = (('着手 ' if start['source'] == 'started' else '開始：依頼時刻を代用 ') + start['shortTime']
                      if start else '開始：不明')
        start_note = '' if start or not last else '開始：不明（記録範囲外または未記録）'
        lines = [it['taskId'] + ' · ' + stage, next_text,
                 ' · '.join(x for x in (owner, time) if x) + (' · ' + reason if reason else ''),
                 'Registry：' + (it['registryState'] or '不明') + ' · ' + badge, start_text]
        cards.append({'taskId': it['taskId'], 'lines': lines,
                      'title': '\n'.join(x for x in lines[:4] + [start_note or start_text] if x),
                      'stage': stage, 'next': next_kind, 'approvalEntries': it['approvalEntries'],
                      'approvalState': 'pending' if counts['pending'] else 'approved' if counts['approved'] or counts['claimed'] else 'none',
                      'startAt': start['at'] if start else None, 'startSource': start['source'] if start else 'unknown'})
    return cards


def _approvals(value):
    requests = value['requests']
    entries = []
    for row in requests:
        entry = deepcopy(row)
        entry['heading'] = row['taskId'] + ' · ' + row['title']
        entry['stateText'] = APPROVAL_LABELS[row['status']]
        entry['detailText'] = '\n\n'.join([
            '依頼：' + row['id'] + ' / revision ' + str(row['revision']),
            'タスク：' + row['taskId'] + ' · ' + row['title'],
            '状態：' + APPROVAL_LABELS[row['status']],
            '目的・範囲：\n' + row['scope'],
            '対象ファイル：\n' + '\n'.join(row['paths']),
            '受入条件：\n' + row['condition'],
            'branch：' + row['branch'],
            '登録：' + row['createdAt'],
            '更新：' + row['updatedAt'],
            '承認：' + (row.get('approvedAt') or '未承認'),
            '実コミット：' + (row.get('commitSha') or '未記録')])
        entries.append(entry)
    visible = [entry for entry in entries if entry['status'] not in ('consumed', 'cancelled')]
    counts = {key: sum(row['status'] == key for row in requests) for key in ('pending', 'approved', 'claimed')}
    signals = [f"🔴 承認待ち {counts['pending']}件" if counts['pending'] else '',
               f"🟢 承認済み・Astra未処理 {counts['approved']}件" if counts['approved'] else '',
               f"🟡 Astra処理中 {counts['claimed']}件" if counts['claimed'] else '']
    return {'requests': deepcopy(requests), 'entries': entries, 'visible': visible,
            'policyNotice': value['policyNotice'], 'counts': counts,
            'status': ' · '.join(s for s in signals if s) or '⚪ 未処理なし'}


def _wake(rows):
    owners = []
    for row in reversed(rows):
        owner = row['raw']['owner']
        if owner and owner != 'ユーザー' and owner not in owners:
            owners.append(owner)
    statuses = {}
    for owner in owners:
        state = {'kind': 'none'}
        for index in range(len(rows) - 1, -1, -1):
            row, raw = rows[index], rows[index]['raw']
            match = WAKE.match(raw['reason'])
            if raw['owner'] == 'ユーザー' and raw['next'] == owner and row['event'] == 'request' and match:
                wake_id = match[1]
                ack = re.compile(r'^ACK ' + re.escape(wake_id) + r'(?![A-Za-z0-9])')
                answer = next((later for later in rows[index + 1:] if later['raw']['owner'] == owner
                               and ack.match(later['raw']['reason'])), None)
                state = {'kind': 'acked', 'id': wake_id, 'at': answer['raw']['at']} if answer else {
                    'kind': 'pending', 'id': wake_id, 'at': raw['at']}
                break
        statuses[owner] = state
    return {'owners': owners, 'statuses': statuses}


def recent_task_work(events):
    """Recipient-confirmed starts/returns supplied by the communication DB only."""
    latest = {}
    for event in events:
        task = event['task_id'] or ''
        if event['event'] not in ('started', 'returned') or not re.fullmatch(r'[A-Z][A-Z0-9]*-[0-9]+', task):
            continue
        value = {'taskId': task, 'workedAt': event['received_at'], 'owner': event['actor'],
                 'eventId': 'letter-event:' + str(event['sequence']), 'letterId': event['letter_id']}
        if task not in latest or _date(value['workedAt']) > _date(latest[task]['workedAt']):
            latest[task] = value
    return sorted(latest.values(), key=lambda value: (-_date(value['workedAt']).timestamp(), value['taskId']))


class WorkState:
    """Atomic revisions of activity, approval, timeline, and recent-work views."""

    def __init__(self, registry_state=None, policy_notice=''):
        self._condition = Condition()
        self._revision = 0
        self._registry_state = registry_state or {}
        self._activity = []
        self._letters = []
        self._recent_tasks = []
        self._first_starts = {}
        self._approvals = {'requests': [], 'policyNotice': policy_notice}
        self._failed = {'activity': False, 'approvals': False, 'letters': False, 'registry': False}
        self._model = self._build()

    def _build(self):
        rows = [_row(raw) for raw in self._activity]
        recent = sorted(rows + [_row(raw) for raw in self._letters], key=lambda row: _date(row['raw']['at']))
        approval_model = _approvals(self._approvals)
        cards = _lane(recent, approval_model['visible'], self._registry_state, self._first_starts)
        trouble = ' · '.join(label for key, label in (('activity', '活動の取得不調'), ('approvals', '承認の取得不調'), ('letters', '連絡の取得不調'), ('registry', 'Registryの取得不調')) if self._failed[key])
        return {'revision': self._revision, 'activity': rows,
                'timeline': _timeline(recent),
                'recentTasks': deepcopy(self._recent_tasks),
                'wake': _wake(rows),
                'cards': {'cards': cards, 'status': (str(len(cards)) + '件' if cards else '記録なし') +
                          (' · ' + trouble + ' · 最終情報を保持' if trouble else ''), 'stale': bool(trouble)},
                'approvals': approval_model, 'failed': dict(self._failed)}

    def _publish(self):
        self._revision += 1
        self._model = self._build()
        self._condition.notify_all()
        return deepcopy(self._model)

    def update_activity(self, raw):
        if not isinstance(raw, list) or len(raw) > 200:
            raise ValueError('Expected at most 200 activity events')
        copied = deepcopy(raw)
        rows = [_row(row) for row in copied]
        if len({row['id'] for row in rows}) != len(rows):
            raise ValueError('Duplicate activity identity')
        with self._condition:
            if copied == self._activity and not self._failed['activity']:
                return deepcopy(self._model)
            self._activity = copied
            self._failed['activity'] = False
            return self._publish()

    def update_registry(self, states):
        if not isinstance(states, dict) or any(not isinstance(k, str) or not isinstance(v, str) for k, v in states.items()):
            raise ValueError('Expected Registry task states')
        with self._condition:
            if states == self._registry_state and not self._failed['registry']:
                return deepcopy(self._model)
            self._registry_state = dict(states)
            self._failed['registry'] = False
            return self._publish()

    def update_letters(self, events):
        latest_work = events.get('latestWork', []) if isinstance(events, dict) else events
        events = events['events'] if isinstance(events, dict) else events
        recent_tasks = recent_task_work(latest_work)
        rows = []
        for event in events:
            if not re.fullmatch(r'[A-Z][A-Z0-9]*-[0-9]+', event['task_id'] or ''):
                continue
            returned, sent = event['event'] == 'returned', event['event'] == 'sent'
            rows.append(dict(schemaVersion=1,
                id=hashlib.md5(('letter-event:' + str(event['sequence'])).encode()).hexdigest(),
                taskId=event['task_id'], event='return' if returned else 'request' if sent else 'work', owner=event['actor'],
                timestamp=_date(event['received_at']).isoformat(timespec='milliseconds'),
                reason=('返却' if returned else '依頼' if sent else '着手') + '（連絡DB：' + event['letter_id'] + '）',
                next=event['sender'] if returned else event['recipient']))
        for row in rows:
            _row(row)
        with self._condition:
            if rows == self._letters and recent_tasks == self._recent_tasks and not self._failed['letters']:
                return deepcopy(self._model)
            self._letters = rows
            self._recent_tasks = recent_tasks
            self._failed['letters'] = False
            return self._publish()

    def update_approvals(self, value):
        if isinstance(value, list):
            value = {'requests': value, 'policyNotice': self._approvals['policyNotice']}
        if not isinstance(value, dict) or not isinstance(value.get('requests'), list) or not isinstance(value.get('policyNotice'), str):
            raise ValueError('Invalid approval list')
        if any(not isinstance(row, dict) or row.get('status') not in ('pending', 'approved', 'claimed', 'consumed', 'cancelled')
               or not isinstance(row.get('taskId'), str) for row in value['requests']):
            raise ValueError('Invalid approval row')
        copied = deepcopy(value)
        with self._condition:
            if copied == self._approvals and not self._failed['approvals']:
                return deepcopy(self._model)
            self._approvals = copied
            self._failed['approvals'] = False
            return self._publish()

    def failure(self, source):
        if source not in self._failed:
            raise ValueError('Unknown work source')
        with self._condition:
            if self._failed[source]:
                return deepcopy(self._model)
            self._failed[source] = True
            return self._publish()

    def snapshot(self):
        with self._condition:
            return deepcopy(self._model)

    def wait(self, after, timeout=15):
        with self._condition:
            self._condition.wait_for(lambda: self._revision != after, timeout)
            return deepcopy(self._model)
