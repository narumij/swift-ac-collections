"""Isolated tests for the task document observable and its source binding."""
import threading
import time
import unittest

from task_state import TaskState, TaskStateBinding
from work_notifications import Changes


class TaskStateTests(unittest.TestCase):
    def test_update_changes_snapshot_and_wait_wakes(self):
        model = TaskState()
        first = model.snapshot()
        self.assertEqual(first, {'document': None, 'revision': 0, 'error': None})

        changed = threading.Event()
        result = []

        def waiter():
            changed.set()
            result.append(model.wait(0, timeout=1))

        thread = threading.Thread(target=waiter)
        thread.start()
        self.assertTrue(changed.wait(1))
        document = {'tasks': [{'id': 'OPS-1', 'state': 'ACTIVE'}]}
        snapshot = model.update(document)
        thread.join(1)
        self.assertFalse(thread.is_alive())
        self.assertEqual(snapshot['document'], document)
        self.assertEqual(snapshot['revision'], 1)
        self.assertEqual(result, [snapshot])

    def test_same_document_does_not_notify_or_advance_revision(self):
        model = TaskState()
        model.update({'tasks': []})
        snapshot = model.update({'tasks': []})
        self.assertEqual(snapshot['revision'], 1)
        self.assertEqual(model.wait(1, timeout=.01)['revision'], 1)

    def test_update_none_is_rejected_without_erasing_last_good_document(self):
        model = TaskState()
        good = model.update({'tasks': [{'id': 'OPS-6'}]})
        with self.assertRaisesRegex(ValueError, 'object'):
            model.update(None)
        self.assertEqual(model.snapshot(), good)

    def test_failure_keeps_last_good_document_and_recovery_notifies(self):
        model = TaskState()
        document = {'tasks': [{'id': 'OPS-2'}]}
        model.update(document)
        failed = model.failure('read failed')
        self.assertEqual(failed, {'document': document, 'revision': 2, 'error': 'read failed'})
        self.assertEqual(model.failure('read failed')['revision'], 2)
        recovered = model.update(document)
        self.assertEqual(recovered, {'document': document, 'revision': 3, 'error': None})
        self.assertEqual(model.wait(2, timeout=.01), recovered)

    def test_document_and_snapshots_are_copy_isolated(self):
        model = TaskState()
        original = {'tasks': [{'id': 'OPS-3'}]}
        model.update(original)
        original['tasks'][0]['id'] = 'mutated input'
        snapshot = model.snapshot()
        snapshot['document']['tasks'][0]['id'] = 'mutated output'
        self.assertEqual(model.snapshot()['document'], {'tasks': [{'id': 'OPS-3'}]})

    def test_binding_refreshes_on_change_and_close_stops_observer(self):
        changes = Changes()
        document = {'tasks': [{'id': 'OPS-4', 'state': 'ACTIVE'}]}
        reads = []

        def read_document():
            reads.append(None)
            return document.copy()

        binding = TaskStateBinding(changes, read_document)
        try:
            self.assertEqual(binding.model.snapshot()['document'], document)
            time.sleep(.25)
            self.assertEqual(len(reads), 1, 'timeout waits must not poll the document')
            before = binding.model.snapshot()['revision']
            document = {'tasks': [{'id': 'OPS-4', 'state': 'DONE'}]}
            changes.changed()
            updated = binding.model.wait(before, timeout=1)
            self.assertEqual(updated['document'], document)
            self.assertGreater(updated['revision'], before)
            self.assertEqual(len(reads), 2)
        finally:
            thread = binding._thread
            binding.close()
        self.assertFalse(thread.is_alive())

    def test_binding_does_not_lose_change_during_initial_read(self):
        changes = Changes()
        entered = threading.Event()
        release = threading.Event()
        ready = threading.Event()
        current = {'document': {'tasks': [{'id': 'OPS-5', 'state': 'DONE'}]}, 'calls': 0}
        binding_box = []

        def read_document():
            current['calls'] += 1
            if current['calls'] == 1:
                entered.set()
                self.assertTrue(release.wait(1))
                return {'tasks': [{'id': 'OPS-5', 'state': 'ACTIVE'}]}
            return current['document']

        def construct():
            binding_box.append(TaskStateBinding(changes, read_document))
            ready.set()

        initializer = threading.Thread(target=construct)
        initializer.start()
        self.assertTrue(entered.wait(1))
        changes.changed()
        release.set()
        self.assertTrue(ready.wait(1))
        binding = binding_box[0]
        try:
            updated = binding.model.wait(1, timeout=1)
            self.assertEqual(updated['document'], current['document'])
            self.assertEqual(current['calls'], 2)
        finally:
            binding.close()
            initializer.join(1)


if __name__ == '__main__':
    unittest.main()
