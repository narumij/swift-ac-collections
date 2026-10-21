"""Temporary-directory coverage for the canonical document observable."""
import os
from pathlib import Path
import threading
import tempfile
import time
import unittest

from document_state import DocumentStateBinding


class DocumentStateTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.root = Path(self.temp.name)
        self.doc = self.root / 'task.md'
        self.doc.write_text('# initial', encoding='utf-8')
        self.renders = []

    def tearDown(self):
        self.temp.cleanup()

    def bind(self, path='task.md', render=None):
        return DocumentStateBinding(self.root, path, render or self.render)

    def render(self, text):
        self.renders.append(text)
        return '<p>' + text + '</p>'

    def wait_for(self, binding, predicate, timeout=2):
        deadline = time.monotonic() + timeout
        while time.monotonic() < deadline:
            snapshot = binding.model.snapshot()
            if predicate(snapshot):
                return snapshot
            binding.model.wait(snapshot['revision'], timeout=.05)
        self.fail('document state did not reach expected value; got %r' % binding.model.snapshot())

    def test_initial_document_and_same_content_mtime_change_are_silent(self):
        with self.bind() as binding:
            first = binding.model.snapshot()
            self.assertEqual(first['document']['path'], 'task.md')
            self.assertEqual(first['document']['html'], '<p># initial</p>')
            self.assertEqual(first['document']['status'], 'ready')
            self.assertEqual(self.renders, ['# initial'])
            os.utime(self.doc, (time.time() + 3, time.time() + 3))
            time.sleep(.2)
            self.assertEqual(binding.model.snapshot(), first)
            self.assertEqual(self.renders, ['# initial'])

    def test_write_and_atomic_replace_render_new_content(self):
        with self.bind() as binding:
            before = binding.model.snapshot()['revision']
            self.doc.write_text('# updated', encoding='utf-8')
            changed = self.wait_for(binding, lambda s: s['document'] and s['document']['html'] == '<p># updated</p>')
            self.assertGreater(changed['revision'], before)
            replacement = self.root / 'replacement.md'
            replacement.write_text('# replaced', encoding='utf-8')
            replacement.replace(self.doc)
            replaced = self.wait_for(binding, lambda s: s['document'] and s['document']['html'] == '<p># replaced</p>')
            self.assertEqual(replaced['document']['status'], 'ready')
            self.assertEqual(self.renders, ['# initial', '# updated', '# replaced'])

    def test_delete_clears_body_and_recreate_renders_again(self):
        with self.bind() as binding:
            self.doc.unlink()
            missing = self.wait_for(binding, lambda s: s['document'] and s['document']['status'] == 'missing')
            self.assertEqual(missing['document']['html'], '')
            self.assertEqual(missing['document']['stamp'], '')
            self.assertEqual(missing['document']['message'], '正本が見つかりません。再作成されると自動で表示します。')
            self.doc.write_text('# returned', encoding='utf-8')
            returned = self.wait_for(binding, lambda s: s['document'] and s['document']['html'] == '<p># returned</p>')
            self.assertEqual(returned['document']['status'], 'ready')
            self.assertEqual(self.renders, ['# initial', '# returned'])

    def test_path_policy_rejects_absolute_hidden_non_markdown_and_escape(self):
        outside = self.root.parent / (self.root.name + '-outside.md')
        outside.write_text('private', encoding='utf-8')
        try:
            for path in (str(self.doc), '../' + outside.name, '.hidden.md', 'sub/.hidden.md', 'task.txt'):
                with self.subTest(path=path), self.assertRaises(ValueError):
                    self.bind(path)
            (self.root / 'link.md').symlink_to(outside)
            with self.assertRaises(ValueError):
                self.bind('link.md')
        finally:
            outside.unlink(missing_ok=True)

    def test_external_symlink_retarget_is_never_rendered(self):
        outside = self.root.parent / (self.root.name + '-outside.md')
        outside.write_text('DO NOT READ', encoding='utf-8')
        try:
            with self.bind() as binding:
                before = binding.model.snapshot()
                link = self.root / 'task.md'
                link.unlink()
                link.symlink_to(outside)
                self.wait_for(binding, lambda s: s['error'] is not None)
                self.assertNotIn('DO NOT READ', self.renders)
                self.assertEqual(binding.model.snapshot()['document'], before['document'])
        finally:
            outside.unlink(missing_ok=True)

    def test_internal_symlink_retarget_tracks_new_document(self):
        first = self.root / 'first.md'
        second = self.root / 'second.md'
        link = self.root / 'task.md'
        first.write_text('# first target', encoding='utf-8')
        second.write_text('# second target', encoding='utf-8')
        self.doc.unlink()
        link.symlink_to(first.name)
        with self.bind() as binding:
            before = binding.model.snapshot()['document']
            self.assertEqual(before['html'], '<p># first target</p>')
            link.unlink()
            link.symlink_to(second.name)
            changed = self.wait_for(binding, lambda s: s['document'] and s['document']['html'] == '<p># second target</p>')
            self.assertEqual(changed['document']['status'], 'ready')

    def test_renderer_failure_keeps_last_good_document_and_recovers(self):
        failed = {'enabled': False}

        def renderer(text):
            if failed['enabled']:
                raise RuntimeError('renderer failed')
            return '[' + text + ']'

        with self.bind(render=renderer) as binding:
            good = binding.model.snapshot()['document']
            failed['enabled'] = True
            self.doc.write_text('# broken render', encoding='utf-8')
            error = self.wait_for(binding, lambda s: s['error'] == 'renderer failed')
            self.assertEqual(error['document'], good)
            failed['enabled'] = False
            self.doc.write_text('# recovered', encoding='utf-8')
            recovered = self.wait_for(binding, lambda s: s['document'] and s['document']['html'] == '[# recovered]')
            self.assertIsNone(recovered['error'])

    def test_close_stops_binding_and_observer(self):
        binding = self.bind()
        binding.close()
        self.doc.write_text('# after close', encoding='utf-8')
        time.sleep(.15)
        self.assertEqual(binding.model.snapshot()['document']['html'], '<p># initial</p>')
        self.assertFalse(binding._binding._thread.is_alive())
        self.assertFalse(binding._observer._thread.is_alive())

    def test_change_during_initial_render_is_not_lost(self):
        entered, release = threading.Event(), threading.Event()
        calls = []

        def renderer(text):
            calls.append(text)
            if len(calls) == 1:
                entered.set()
                self.assertTrue(release.wait(2))
            return '<p>' + text + '</p>'

        bindings = []
        initializer = threading.Thread(target=lambda: bindings.append(self.bind(render=renderer)))
        initializer.start()
        try:
            self.assertTrue(entered.wait(2))
            self.doc.write_text('# raced', encoding='utf-8')
            time.sleep(.1)
            release.set()
            initializer.join(2)
            self.assertFalse(initializer.is_alive())
            binding = bindings[0]
            final = self.wait_for(binding, lambda s: s['document'] and s['document']['html'] == '<p># raced</p>')
            self.assertGreaterEqual(final['revision'], 2)
            self.assertEqual(calls, ['# initial', '# raced'])
        finally:
            release.set()
            initializer.join(2)
            if bindings:
                bindings[0].close()


if __name__ == '__main__':
    unittest.main()
