"""Append shared notifications to plain text while the server is running."""
from pathlib import Path
from threading import RLock
from event_notifications import events


class TextLog:
    def __init__(self, path):
        self.path = Path(path)
        self.path.parent.mkdir(parents=True, exist_ok=True)
        self.path.touch(exist_ok=True)
        self.lock = RLock()

    def receive(self, text):
        with self.lock, self.path.open('a', encoding='utf-8') as stream:
            stream.write(text + '\n')
            stream.flush()


_log = None


def start(path):
    global _log
    if _log is None:
        _log = TextLog(path)
        events.connect(_log.receive)
    return _log
