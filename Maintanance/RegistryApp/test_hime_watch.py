"""Temporary-file tests for Hime's timed notification log reader."""
import io
import os
import subprocess
import sys
import tempfile
import threading
import time
import unittest
from pathlib import Path

import hime_watch
from event_notifications import events
from notification_log import TextLog


class HimeWatchTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.log = self.root / 'notifications.log'
        self.cursor = self.root / 'hime-read.offset'
        self.log.touch()

    def watch(self, seconds=.03, output=None):
        output = output or io.StringIO()
        hime_watch.watch(self.log, self.cursor, seconds, output)
        return output.getvalue()

    def test_unread_lines_are_all_shown_before_watch_returns(self):
        self.log.write_text('first notice\nsecond notice\n', encoding='utf-8')
        output = self.watch()
        self.assertEqual(output, 'first notice\nsecond notice\n')

    def test_entries_added_while_absent_are_all_shown_next_time(self):
        self.log.write_text('before absence\n', encoding='utf-8')
        self.assertEqual(self.watch(), 'before absence\n')
        with self.log.open('a', encoding='utf-8') as stream:
            stream.write('while absent one\nwhile absent two\n')
        self.assertEqual(self.watch(), 'while absent one\nwhile absent two\n')

    def test_read_entries_are_not_printed_twice(self):
        self.log.write_text('already read\n', encoding='utf-8')
        self.assertEqual(self.watch(), 'already read\n')
        self.assertEqual(self.watch(), '')

    def test_interruption_resumes_after_last_flushed_line(self):
        self.log.write_text('line one\nline two\nline three\n', encoding='utf-8')

        class InterruptAfterFirstLine(io.StringIO):
            def write(inner, value):
                if inner.getvalue():
                    raise KeyboardInterrupt
                return super(InterruptAfterFirstLine, inner).write(value)

        output = InterruptAfterFirstLine()
        with self.assertRaises(KeyboardInterrupt):
            hime_watch.watch(self.log, self.cursor, .03, output)
        self.assertEqual(output.getvalue(), 'line one\n')
        self.assertEqual(self.watch(), 'line two\nline three\n')

    def test_log_replacement_restarts_at_new_file_beginning(self):
        self.log.write_text('old file line\n', encoding='utf-8')
        self.assertEqual(self.watch(), 'old file line\n')
        replacement = self.root / 'replacement.log'
        replacement.write_text('replacement one\nreplacement two\n', encoding='utf-8')
        replacement.replace(self.log)
        self.assertNotEqual(self.cursor.read_text().split()[0], f'{self.log.stat().st_dev}:{self.log.stat().st_ino}')
        self.assertEqual(self.watch(), 'replacement one\nreplacement two\n')

    def test_truncation_below_saved_offset_restarts_at_beginning(self):
        self.log.write_text('a much longer old entry for offset tracking\n', encoding='utf-8')
        self.assertEqual(self.watch(), 'a much longer old entry for offset tracking\n')
        old_stat = self.log.stat()
        with self.log.open('wb') as stream:
            stream.write(b'new\n')
        self.assertEqual(self.log.stat().st_ino, old_stat.st_ino)
        self.assertLess(self.log.stat().st_size, int(self.cursor.read_text().split()[1]))
        self.assertEqual(self.watch(), 'new\n')

    def test_truncate_then_regrow_past_saved_offset_restarts(self):
        self.log.write_text('original row one\noriginal row two\noriginal row three\n', encoding='utf-8')
        self.assertEqual(self.watch(), 'original row one\noriginal row two\noriginal row three\n')
        saved_offset = int(self.cursor.read_text().split()[1])
        replacement_content = 'new row one\nnew row two\nnew row three\nnew row four\nnew row five\n'
        self.assertGreaterEqual(len(replacement_content.encode()), saved_offset)
        old_stat = self.log.stat()
        with self.log.open('wb') as stream:
            stream.write(replacement_content.encode())
        self.assertEqual(self.log.stat().st_ino, old_stat.st_ino)
        self.assertEqual(self.watch(), replacement_content)

    def test_legacy_two_field_cursor_resumes_at_saved_offset(self):
        self.log.write_text('already read\nnew unread\n', encoding='utf-8')
        identity = f'{self.log.stat().st_dev}:{self.log.stat().st_ino}'
        offset = len('already read\n'.encode('utf-8'))
        self.cursor.write_text(f'{identity} {offset}\n')
        self.assertEqual(self.watch(), 'new unread\n')
        self.assertEqual(self.watch(), '')
        with self.log.open('a', encoding='utf-8') as stream:
            stream.write('appended later\n')
        self.assertEqual(self.watch(), 'appended later\n')

    def test_partial_line_waits_for_newline_and_multiple_lines_drain(self):
        self.log.write_bytes(b'complete first\npartial')
        def finish_line():
            time.sleep(.04)
            with self.log.open('ab') as stream:
                stream.write(b'\ncomplete second\ncomplete third\n')
        writer = threading.Thread(target=finish_line)
        writer.start()
        output = self.watch(.25)
        writer.join(timeout=1)
        self.assertEqual(output, 'complete first\npartial\ncomplete second\ncomplete third\n')

    def test_timer_ends_even_when_each_print_causes_more_output(self):
        self.log.write_text('seed\n', encoding='utf-8')

        class AppendingOutput(io.StringIO):
            def write(inner, value):
                count = super(AppendingOutput, inner).write(value)
                with self_outer.log.open('a', encoding='utf-8') as stream:
                    stream.write(f'generated {count}\n')
                return count

        self_outer = self
        output = AppendingOutput()
        started = time.monotonic()
        hime_watch.watch(self.log, self.cursor, .35, output)
        elapsed = time.monotonic() - started
        self.assertGreaterEqual(len(output.getvalue().splitlines()), 3)
        self.assertLess(elapsed, 1.5, f'timer kept running under continuous output: {elapsed:.2f}s')

    def test_simultaneous_cli_invocation_is_rejected(self):
        self.log.write_text('seed the cursor\n', encoding='utf-8')
        script = Path(__file__).with_name('hime_watch.py')
        first = subprocess.Popen([sys.executable, str(script), '--log', str(self.log), '--cursor', str(self.cursor), '--seconds', '1'],
                                 stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        try:
            deadline = time.monotonic() + 2
            while not self.cursor.exists() and time.monotonic() < deadline:
                time.sleep(.01)
            self.assertTrue(self.cursor.exists(), 'first reader did not start')
            second = subprocess.run([sys.executable, str(script), '--log', str(self.log), '--cursor', str(self.cursor), '--seconds', '.05'],
                                    capture_output=True, text=True, timeout=3)
            self.assertEqual(second.returncode, 1)
            self.assertIn('既に実行中', second.stderr)
            first_out, first_err = first.communicate(timeout=3)
            self.assertEqual(first.returncode, 0, first_out + first_err)
        finally:
            if first.poll() is None:
                first.terminate()
                first.wait(timeout=3)
            first.stdout.close()
            first.stderr.close()

    def test_event_bus_text_log_persists_server_notifications(self):
        log = TextLog(self.log)
        events.connect(log.receive)
        try:
            events.send('notice one')
            events.send('notice two\ncontinued text')
        finally:
            events.disconnect(log.receive)
        self.assertEqual(self.log.read_text(encoding='utf-8'), 'notice one\nnotice two\ncontinued text\n')


if __name__ == '__main__':
    unittest.main()
