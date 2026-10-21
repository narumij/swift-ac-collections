"""Append shared notifications to plain text while the server is running."""
from collections import deque
import os
from pathlib import Path
from threading import RLock
from event_notifications import events


class TextLog:
    def __init__(self, path):
        self.path = Path(path)
        self.path.parent.mkdir(parents=True, exist_ok=True)
        self.path.touch(exist_ok=True)
        self.lock = RLock()
        self.listeners = []

    def receive(self, text):
        with self.lock, self.path.open('a', encoding='utf-8') as stream:
            stream.write(text + '\n')
            stream.flush()
            stat = os.fstat(stream.fileno())
            cursor = f'{stat.st_dev}:{stat.st_ino}:{stream.tell()}'
            for listener in tuple(self.listeners):
                listener(cursor, text)


    def follow(self, listener, after=''):
        """Subscribe atomically with history; cursors identify positions in the text file."""
        with self.lock, self.path.open('rb') as stream:
            stat = os.fstat(stream.fileno())
            identity = f'{stat.st_dev}:{stat.st_ino}:'
            offset = None
            if after.startswith(identity):
                try:
                    candidate = int(after[len(identity):])
                    if 0 <= candidate <= stat.st_size:
                        offset = candidate
                except ValueError:
                    pass
            reset = offset is None
            stream.seek(offset or 0)
            lines = deque(maxlen=100 if reset else 500)
            for line in stream:
                lines.append(line.decode('utf-8', errors='replace').removesuffix('\n'))
            cursor = identity + str(stream.tell())
            self.listeners.append(listener)
            return {'reset': reset, 'entries': list(lines), 'cursor': cursor}

    def unfollow(self, listener):
        with self.lock:
            if listener in self.listeners:
                self.listeners.remove(listener)


_log = None


def start(path):
    global _log
    if _log is None:
        _log = TextLog(path)
        events.connect(_log.receive)
    return _log
