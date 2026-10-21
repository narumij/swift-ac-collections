"""Revision notifications for work views; no periodic data reads."""
from event_notifications import events

import os
import select
import socket
import threading
from pathlib import Path


class Changes:
    def __init__(self, name=""):
        self.name = name
        self._condition = threading.Condition()
        self._revision = 0

    def changed(self):
        with self._condition:
            self._revision += 1
            self._condition.notify_all()
        if self.name:
            events.send(self.name)

    def wait(self, after, timeout=15):
        with self._condition:
            self._condition.wait_for(lambda: self._revision != after, timeout)
            return self._revision


class FileObserver:
    """macOS/BSD vnode events cover CLI writes, creation and file replacement."""
    def __init__(self, path, changes, companions=()):
        self.path, self.changes = Path(path), changes
        self.companions = tuple(Path(p) for p in companions)
        self._queue = select.kqueue()
        self._stop_read, self._stop_write = socket.socketpair()
        self._queue.control([select.kevent(self._stop_read.fileno(), filter=select.KQ_FILTER_READ,
                                          flags=select.KQ_EV_ADD)], 0)
        self._files = {}
        self._bind()
        self._thread = threading.Thread(target=self._run, daemon=True)
        self._thread.start()

    def _bind(self):
        parent = self.path.parent
        while not parent.exists():
            parent = parent.parent
        wanted = {parent, self.path, *self.companions}
        for path, (fd, identity) in list(self._files.items()):
            try:
                stat = path.stat()
                keep = path in wanted and identity == (stat.st_dev, stat.st_ino)
            except FileNotFoundError:
                keep = False
            if not keep:
                os.close(fd)
                del self._files[path]
        for path in wanted - self._files.keys():
            try:
                fd = os.open(path, os.O_RDONLY)
            except FileNotFoundError:
                continue
            stat = os.fstat(fd)
            self._queue.control([select.kevent(fd, filter=select.KQ_FILTER_VNODE,
                flags=select.KQ_EV_ADD | select.KQ_EV_CLEAR,
                fflags=select.KQ_NOTE_WRITE | select.KQ_NOTE_DELETE | select.KQ_NOTE_RENAME)], 0)
            self._files[path] = (fd, (stat.st_dev, stat.st_ino))

    def _run(self):
        while True:
            events = self._queue.control(None, 8, None)
            if any(event.ident == self._stop_read.fileno() for event in events):
                return
            self._bind()
            self.changes.changed()

    def close(self):
        self._stop_write.send(b'x')
        self._thread.join()
        for fd, _ in self._files.values():
            os.close(fd)
        self._queue.close()
        self._stop_read.close()
        self._stop_write.close()


activity_changes = Changes("activity_changes")
approval_changes = Changes("approval_changes")
letter_changes = Changes("letter_changes")
_activity_observer = None
_observer_lock = threading.Lock()


def observe_activity(path):
    global _activity_observer
    with _observer_lock:
        if _activity_observer is None:
            _activity_observer = FileObserver(path, activity_changes)
    return activity_changes


registry_changes = Changes("registry_changes")
_registry_observer = None


def observe_registry(path):
    """Use the same vnode observer for DB commits/replacement, including WAL writes."""
    global _registry_observer
    with _observer_lock:
        if _registry_observer is None:
            _registry_observer = FileObserver(path, registry_changes, companions=(str(path) + '-wal',))
    return registry_changes
