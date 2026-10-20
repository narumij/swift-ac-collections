"""Process-local communication notifications, independent of member state."""
import logging
from datetime import datetime, timezone
from threading import RLock


class Signal:
    def __init__(self):
        self._listeners = []
        self._lock = RLock()

    def connect(self, listener):
        with self._lock:
            if listener not in self._listeners:
                self._listeners.append(listener)

    def disconnect(self, listener):
        with self._lock:
            if listener in self._listeners:
                self._listeners.remove(listener)

    def send(self, **event):
        event['at'] = datetime.now(timezone.utc)
        with self._lock:
            listeners = tuple(self._listeners)
        for listener in listeners:
            try:
                listener(**event)
            except Exception:
                logging.exception("Communication notification failed")


waiting_started = Signal()
waiting_ended = Signal()
letter_received = Signal()

communication_activity = Signal()
