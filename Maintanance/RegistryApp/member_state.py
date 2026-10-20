"""In-memory member model; changes wake subscribed SSE connections."""
from copy import deepcopy
from threading import Condition, Timer
from zoneinfo import ZoneInfo
import communication_notifications as notifications


class MemberState:
    def __init__(self, members, planned_members=(), grace_seconds=30):
        self._condition = Condition()
        self.grace_seconds = grace_seconds
        self._pending = {}
        self._members = deepcopy(members)
        self._planned_members = list(planned_members)
        self._revision = 0
        self._info = {}
        self._sync_info()

    def connect_notifications(self):
        notifications.waiting_started.connect(self.on_waiting_started)
        notifications.waiting_ended.connect(self.on_waiting_ended)
        notifications.letter_received.connect(self.on_letter_received)

    def on_waiting_started(self, **event):
        if event.get('owner'):
            self.attend(event['owner'])
            self._update_info(event, '待機開始')

    def on_waiting_ended(self, **event):
        if event.get('owner'):
            self.disconnected(event['owner'])
            self._update_info(event, '待機終了')

    def on_letter_received(self, **event):
        if event.get('owner'):
            self.attend(event['owner'])
            self._update_info(event, '受領')

    def _update_info(self, event, label):
        time = event['at'].astimezone(ZoneInfo('Asia/Tokyo')).strftime('%H:%M')
        self.update_info(event['owner'].strip(), f'{label} {time}')

    def _cancel(self, owner):
        timer = self._pending.pop(owner, None)
        if timer is not None:
            timer.cancel()

    def disconnected(self, owner):
        owner = self._name(owner)
        with self._condition:
            if owner in self._pending:
                return

            def expire():
                with self._condition:
                    if self._pending.get(owner) is timer:
                        self._pending.pop(owner)
                        self.leave(owner)

            timer = Timer(self.grace_seconds, expire)
            timer.daemon = True
            self._pending[owner] = timer
            timer.start()

    def _sync_info(self):
        owners = dict.fromkeys(self._planned_members +
                              [m['owner'] for m in self._members if m['attendance'] == 'present'])
        self._info = {owner: self._info.get(owner, '') for owner in owners}

    def update_info(self, owner, text):
        with self._condition:
            if owner not in self._info:
                return
            if not isinstance(text, str):
                raise ValueError('Member information must be a string')
            if self._info[owner] != text:
                self._info[owner] = text
                self._revision += 1
                self._condition.notify_all()

    def snapshot(self):
        with self._condition:
            planned = set(self._planned_members)
            present = {m['owner'] for m in self._members if m['attendance'] == 'present'}
            owners = list(dict.fromkeys(self._planned_members +
                          [m['owner'] for m in self._members if m['owner'] in present]))
            public = [{'owner': owner, 'planned': owner in planned,
                       'attendance': 'present' if owner in present else 'absent'}
                      for owner in owners]
            return {'revision': self._revision, 'members': public,
                    'actualMembers': deepcopy(self._members),
                    'plannedMembers': list(self._planned_members),
                    'memberInfo': dict(self._info)}

    def replace(self, members):
        with self._condition:
            if self._members == members:
                return
            self._members = deepcopy(members)
            self._sync_info()
            self._revision += 1
            self._condition.notify_all()

    def attend(self, owner):
        if not isinstance(owner, str) or not owner.strip() or len(owner) > 100:
            raise ValueError('A member name of 1..100 characters is required')
        owner = owner.strip()
        with self._condition:
            self._cancel(owner)
            updated = deepcopy(self._members)
            existing = next((m for m in updated if m['owner'] == owner), None)
            if existing is None:
                updated.append({'owner': owner, 'attendance': 'present'})
            else:
                existing['attendance'] = 'present'
            self.replace(updated)
            return self.snapshot()

    def leave(self, owner):
        if not isinstance(owner, str) or not owner.strip() or len(owner) > 100:
            raise ValueError('A member name of 1..100 characters is required')
        with self._condition:
            self._cancel(owner.strip())
            self.replace([m for m in self._members if m['owner'] != owner.strip()])
            return self.snapshot()

    def clear(self):
        with self._condition:
            for owner in list(self._pending):
                self._cancel(owner)
            self.replace([])
            return self.snapshot()

    @staticmethod
    def _name(owner):
        if not isinstance(owner, str) or not owner.strip() or len(owner) > 100:
            raise ValueError('A member name of 1..100 characters is required')
        return owner.strip()

    def add_planned(self, owner):
        owner = self._name(owner)
        with self._condition:
            return self.replace_planned(self._planned_members + [owner])

    def remove_planned(self, owner):
        owner = self._name(owner)
        with self._condition:
            return self.replace_planned([name for name in self._planned_members if name != owner])

    def clear_planned(self):
        return self.replace_planned([])

    def replace_planned(self, planned_members):
        if not isinstance(planned_members, list):
            raise ValueError('plannedMembers must be an array of names')
        planned = list(dict.fromkeys(self._name(name) for name in planned_members))
        with self._condition:
            if self._planned_members == planned:
                return self.snapshot()
            self._planned_members = planned
            self._sync_info()
            self._revision += 1
            self._condition.notify_all()
            return self.snapshot()

    def wait(self, after, timeout=15):
        with self._condition:
            self._condition.wait_for(lambda: self._revision != after, timeout)
            return self.snapshot()


members = MemberState([], planned_members=[])
members.connect_notifications()
