"""Process-local communication notifications, independent of member state."""
import logging
from event_notifications import events
from datetime import datetime, timezone
from threading import RLock


class Signal:
    def __init__(self, name=""):
        self.name = name
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
        if self.name:
            events.send(self.name + ': ' + ', '.join(f'{key}={value}' for key, value in event.items()))
        with self._lock:
            listeners = tuple(self._listeners)
        for listener in listeners:
            try:
                listener(**event)
            except Exception:
                logging.exception("Communication notification failed")


waiting_started = Signal("waiting_started")
waiting_ended = Signal("waiting_ended")
letter_received = Signal("letter_received")

communication_activity = Signal("communication_activity")
