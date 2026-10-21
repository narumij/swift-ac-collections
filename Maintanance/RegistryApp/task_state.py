"""Observable snapshot of the canonical task document."""
from copy import deepcopy
from threading import Condition, Event, Thread


class TaskState:
    """Hold the last readable document and publish only meaningful changes."""

    def __init__(self):
        self._condition = Condition()
        self._document = None
        self._revision = 0
        self._error = None

    def snapshot(self):
        with self._condition:
            return {'document': deepcopy(self._document), 'revision': self._revision, 'error': self._error}

    def update(self, document):
        if not isinstance(document, dict):
            raise ValueError('Task document must be an object')
        document = deepcopy(document)
        with self._condition:
            if document == self._document and self._error is None:
                return self._snapshot_locked()
            self._document = document
            self._error = None
            self._revision += 1
            self._condition.notify_all()
            return self._snapshot_locked()

    def failure(self, error='Task document is unavailable'):
        if isinstance(error, BaseException):
            error = str(error)
        if not isinstance(error, str):
            error = 'Task document is unavailable'
        error = error.strip() or 'Task document is unavailable'
        with self._condition:
            if error == self._error:
                return self._snapshot_locked()
            self._error = error
            self._revision += 1
            self._condition.notify_all()
            return self._snapshot_locked()

    def wait(self, after, timeout=15):
        with self._condition:
            self._condition.wait_for(lambda: self._revision != after, timeout)
            return self._snapshot_locked()

    def _snapshot_locked(self):
        return {'document': deepcopy(self._document), 'revision': self._revision, 'error': self._error}


class TaskStateBinding:
    """Refresh TaskState on source changes without polling the document."""

    def __init__(self, changes, read_document):
        self.model = TaskState()
        self._changes = changes
        self._read_document = read_document
        self._stop = Event()
        self._thread = None
        # Capture the revision before the first read. A change during that read is
        # then visible to the observer instead of being lost between read and wait.
        revision = changes.wait(None, 0)
        self._refresh()
        self._thread = Thread(target=self._observe, args=(revision,), daemon=True)
        self._thread.start()

    def _refresh(self):
        try:
            self.model.update(self._read_document())
        except Exception as error:
            self.model.failure(error)

    def _observe(self, revision):
        while not self._stop.is_set():
            changed = self._changes.wait(revision, timeout=.1)
            if self._stop.is_set():
                return
            if changed == revision:
                continue
            revision = changed
            self._refresh()

    def close(self):
        self._stop.set()
        if self._thread is not None:
            self._thread.join(timeout=1)

    def __enter__(self):
        return self

    def __exit__(self, *_):
        self.close()
