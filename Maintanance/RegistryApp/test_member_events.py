import json
import threading
import unittest
import urllib.request
from http.server import ThreadingHTTPServer
import member_state
import serve

class MemberEventsTest(unittest.TestCase):
    def test_initial_change_and_reconnect(self):
        original = member_state.members
        member_state.members = member_state.MemberState([{'owner': 'A', 'attendance': 'present'}])
        server = ThreadingHTTPServer(('127.0.0.1', 0), serve.Handler)
        threading.Thread(target=server.serve_forever, daemon=True).start()
        url = f'http://127.0.0.1:{server.server_port}/members/events'
        def read(response):
            while True:
                line = response.readline().decode()
                if line.startswith('data: '): return json.loads(line[6:])
                if not line: raise AssertionError('SSE closed')
        try:
            with urllib.request.urlopen(url, timeout=3) as response:
                first = read(response)
                self.assertEqual(len(first['members']), 1)
                request = urllib.request.Request(url.replace('/events', '/attendance'),
                    data=json.dumps({'owner': 'B'}).encode(),
                    headers={'Origin': f'http://127.0.0.1:{server.server_port}',
                             'X-Registry-Studio': 'members-attendance', 'Content-Type': 'application/json'})
                with urllib.request.urlopen(request, timeout=3) as added:
                    self.assertEqual(json.load(added)['members'][-1]['owner'], 'B')
                changed = read(response)
                self.assertEqual(changed['members'][-1]['owner'], 'B')
                self.assertGreater(changed['revision'], first['revision'])
                member_state.members.replace(changed['actualMembers'])
                self.assertEqual(member_state.members.snapshot()['revision'], changed['revision'])
            with urllib.request.urlopen(url, timeout=3) as response:
                self.assertEqual(read(response), changed)
                request = urllib.request.Request(url.replace('/events', '/departure'),
                    data=json.dumps({'owner': 'B'}).encode(),
                    headers={'Origin': f'http://127.0.0.1:{server.server_port}',
                             'X-Registry-Studio': 'members-departure', 'Content-Type': 'application/json'})
                with urllib.request.urlopen(request, timeout=3) as removed:
                    self.assertEqual(len(json.load(removed)['members']), 1)
                self.assertEqual([m['owner'] for m in read(response)['members']], ['A'])
        finally:
            server.shutdown()
            server.server_close()
            member_state.members = original

if __name__ == '__main__': unittest.main()
