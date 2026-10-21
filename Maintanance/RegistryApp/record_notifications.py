"""Read new committed records from existing sources; no additional storage.

File notifications are hints. Cursors drain every appended row, including writes
from other processes, rather than equating one filesystem event with one record.
"""
import json
import logging
import sqlite3
from pathlib import Path
from threading import RLock
from event_notifications import events
from work_notifications import FileObserver


def readable(value):
    if isinstance(value, str):
        try:
            return readable(json.loads(value))
        except (ValueError, TypeError):
            return value
    if isinstance(value, dict):
        return {k: ('[redacted]' if 'token' in k.lower() or 'secret' in k.lower() else readable(v))
                for k, v in value.items()}
    if isinstance(value, list):
        return [readable(v) for v in value]
    return value


class DatabaseRecords:
    def __init__(self, path, tables, publish=events.send):
        self.path, self.tables, self.publish = Path(path), tables, publish
        self.cursors = {}
        self.identity = None
        self.lock = RLock()
        self._read(initial=True)

    def _read(self, initial=False):
        if not self.path.exists():
            return
        stat = self.path.stat()
        identity = (stat.st_dev, stat.st_ino)
        if self.identity is not None and identity != self.identity:
            self.cursors.clear()
            self.publish(f'notification_source_reset: {self.path.name}; reading replacement from start')
        self.identity = identity
        with sqlite3.connect(self.path.resolve().as_uri() + '?mode=ro', uri=True, timeout=5) as con:
            con.row_factory = sqlite3.Row
            con.execute('BEGIN')
            existing = {r[0] for r in con.execute("SELECT name FROM sqlite_master WHERE type='table'")}
            for table in self.tables:
                if table not in existing:
                    continue
                if initial:
                    self.cursors[table] = con.execute(f'SELECT coalesce(max(rowid),0) FROM {table}').fetchone()[0]
                    continue
                cursor = self.cursors.get(table, 0)
                for row in con.execute(f'SELECT rowid AS _cursor, * FROM {table} WHERE rowid > ? ORDER BY rowid', (cursor,)):
                    data = dict(row)
                    position = data.pop('_cursor')
                    self.publish(f'{self.path.name}/{table}: {readable(data)!r}')
                    self.cursors[table] = position

    def changed(self):
        with self.lock:
            try:
                self._read()
            except Exception:
                logging.exception('Notification database read failed')
                self.publish(f'notification_error: cannot read {self.path.name}; cursor retained')


class ActivityRecords:
    def __init__(self, path, publish=events.send):
        self.path, self.publish = Path(path), publish
        self.lock = RLock()
        self.identity = None
        self.offset = 0
        if self.path.exists():
            stat = self.path.stat()
            self.identity = (stat.st_dev, stat.st_ino)
            self.offset = stat.st_size

    def changed(self):
        with self.lock:
            try:
                with self.path.open('rb') as stream:
                    import os
                    stat = os.fstat(stream.fileno())
                    identity = (stat.st_dev, stat.st_ino)
                    if identity != self.identity or stat.st_size < self.offset:
                        self.offset = 0
                        self.identity = identity
                    stream.seek(self.offset)
                    while True:
                        line = stream.readline()
                        if not line or not line.endswith(b'\n'):
                            break
                        self.publish('activity: ' + line.decode('utf-8').rstrip('\r\n'))
                        self.offset = stream.tell()
            except FileNotFoundError:
                return
            except Exception:
                logging.exception('Notification activity read failed')
                self.publish('notification_error: activity read failed; cursor retained')


_lock = RLock()
_observers = []


def start(database, activity, registry=None):
    with _lock:
        if _observers:
            return
        sources = [DatabaseRecords(database, (
            'operations', 'messages', 'acks', 'meta', 'letters', 'letter_texts', 'letter_events',
            'letter_links', 'letter_doc_records', 'history', 'trial_anchors', 'trial_rounds',
            'trial_turns', 'trial_members', 'trial_next', 'trial_skip_policy')),
            ActivityRecords(activity)]
        if registry:
            sources.append(DatabaseRecords(registry, ('operations', 'revisions')))
        observers = []
        try:
            for source in sources:
                companions = (str(source.path) + '-wal',) if isinstance(source, DatabaseRecords) else ()
                observers.append(FileObserver(source.path, source, companions=companions))
                source.changed()  # Catch writes between initial cursor and observer registration.
        except Exception:
            for observer in observers:
                observer.close()
            raise
        _observers.extend(observers)
