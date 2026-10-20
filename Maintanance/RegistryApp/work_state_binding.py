"""Connect committed source changes to the work-page ViewModel."""
import logging
import threading

from work_state import WorkState


class WorkStateBinding:
    def __init__(self, activity_changes, approval_changes, read_activity, read_approvals, registry_state, letter_changes=None, read_letters=None):
        self.model = WorkState(registry_state=registry_state)
        self._sources = [(activity_changes, read_activity, self.model.update_activity, 'activity'),
                         (approval_changes, read_approvals, self.model.update_approvals, 'approvals')]
        if letter_changes is not None:
            self._sources.append((letter_changes, read_letters, self.model.update_letters, 'letters'))
        for changes, read, update, source in self._sources:
            revision = changes.wait(None, 0)
            self._refresh(read, update, source)
            threading.Thread(target=self._observe, args=(changes, revision, read, update, source), daemon=True).start()

    def _refresh(self, read, update, source):
        try:
            update(read())
        except Exception:
            logging.exception('Cannot update work view: %s', source)
            self.model.failure(source)

    def _observe(self, changes, revision, read, update, source):
        while True:
            revision = changes.wait(revision, timeout=None)
            self._refresh(read, update, source)
