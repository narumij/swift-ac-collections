import io
import threading
import unittest
import urllib.request
from http.server import ThreadingHTTPServer

from event_notifications import events
from serve import Handler
from watch_events import display


class WatchEventsTests(unittest.TestCase):
    def test_text_multiline_and_keepalive(self):
        output = io.StringIO()
        display(io.BytesIO(': connected\n\ndata: 待機開始\ndata: A\n\n: keepalive\n\n'.encode()), output)
        self.assertEqual(output.getvalue(), '待機開始\nA\n')

    def test_overflow_is_not_silently_ignored(self):
        with self.assertRaises(RuntimeError):
            display(io.BytesIO(b'event: overflow\ndata: slow\n\n'), io.StringIO())

    def test_real_http_subscription_receives_notification(self):
        server = ThreadingHTTPServer(('127.0.0.1', 0), Handler)
        worker = threading.Thread(target=server.serve_forever, daemon=True)
        worker.start()
        try:
            url = f'http://127.0.0.1:{server.server_port}/notifications/events'
            with urllib.request.urlopen(url, timeout=3) as stream:
                self.assertEqual(stream.readline(), b': connected\n')
                self.assertEqual(stream.readline(), b'\n')
                events.send('fixture notification')
                self.assertEqual(stream.readline(), b'data: fixture notification\n')
                self.assertEqual(stream.readline(), b'\n')
        finally:
            server.shutdown()
            server.server_close()
            worker.join()


if __name__ == '__main__':
    unittest.main()
