import json
import threading
import unittest
import urllib.request
import urllib.error
from http.server import ThreadingHTTPServer
import member_state
import serve

class MemberOperationsTest(unittest.TestCase):
    def test_seven_operations_and_invalid_replacement(self):
        original = member_state.members
        member_state.members = member_state.MemberState([], [])
        server = ThreadingHTTPServer(('127.0.0.1', 0), serve.Handler)
        threading.Thread(target=server.serve_forever, daemon=True).start()
        base = f'http://127.0.0.1:{server.server_port}'
        def post(path, body):
            request = urllib.request.Request(base + '/members/' + path,
                data=json.dumps(body).encode(), headers={'Origin': base,
                'Content-Type': 'application/json', 'X-Registry-Studio': 'members-' + path.replace('/', '-')})
            with urllib.request.urlopen(request, timeout=3) as response:
                return json.load(response)
        try:
            added = post('attendance', {'owner': 'A'})
            self.assertEqual(post('attendance', {'owner': 'A'}), added)
            self.assertEqual(post('departure', {'owner': 'A'})['members'], [])
            post('attendance', {'owner': 'A'})
            planned = post('planned/add', {'owner': 'A'})
            self.assertEqual(post('planned/add', {'owner': 'A'}), planned)
            self.assertEqual(post('planned/remove', {'owner': 'A'})['plannedMembers'], [])
            before = member_state.members.snapshot()
            replaced = post('planned/replace', {'plannedMembers': ['B', 'C', 'B']})
            self.assertEqual(replaced['plannedMembers'], ['B', 'C'])
            self.assertEqual(replaced['revision'], before['revision'] + 1)
            with self.assertRaises(urllib.error.HTTPError) as error:
                post('planned/replace', {'plannedMembers': ['D', '']})
            self.assertEqual(error.exception.code, 400)
            error.exception.close()
            self.assertEqual(member_state.members.snapshot(), replaced)
            cleared = post('clear', {})
            self.assertEqual(cleared['actualMembers'], [])
            self.assertEqual([m['attendance'] for m in cleared['members']], ['absent', 'absent'])
            self.assertEqual(cleared['plannedMembers'], ['B', 'C'])
            post('attendance', {'owner': 'A'})
            cleared = post('planned/clear', {})
            self.assertEqual(cleared['plannedMembers'], [])
            self.assertEqual(cleared['members'][0]['owner'], 'A')
            self.assertEqual(post('planned/clear', {}), cleared)
        finally:
            server.shutdown(); server.server_close()
            member_state.members = original

if __name__ == '__main__': unittest.main()
