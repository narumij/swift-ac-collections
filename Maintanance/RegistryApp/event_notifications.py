"""Shared process-local text notifications. No storage or event schema."""
import logging
from threading import RLock


class Notifications:
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

    def send(self, text):
        with self._lock:
            listeners = tuple(self._listeners)
        for listener in listeners:
            try:
                listener(text)
            except Exception:
                logging.exception("Event notification listener failed")


events = Notifications()
