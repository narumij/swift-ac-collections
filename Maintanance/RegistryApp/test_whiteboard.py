import unittest
from concurrent.futures import ThreadPoolExecutor
from whiteboard import Whiteboard

class BoardTests(unittest.TestCase):
    def test_shared_items_replay_and_restart(self):
        b=Whiteboard();text={'id':'t','kind':'text','x':10,'y':20,'text':'hello <script>'}
        state=b.add(text);self.assertEqual(state['document']['items'],[text])
        self.assertEqual(b.add(text)['revision'],state['revision'])
        with self.assertRaises(ValueError):b.add(dict(text,text='different'))
        stroke={'id':'s','kind':'stroke','points':[[0,0],[1200,700]]}
        b.add(stroke);self.assertEqual(len(b.snapshot()['document']['items']),2)
        state['document']['items'].clear();self.assertEqual(len(b.snapshot()['document']['items']),2)
        self.assertEqual(Whiteboard().snapshot()['document']['items'],[])
    def test_concurrent_additions_and_notification(self):
        b=Whiteboard();old=b.snapshot()['revision']
        with ThreadPoolExecutor(4) as pool:
            list(pool.map(lambda i:b.add({'id':str(i),'kind':'text','text':str(i),'x':i,'y':0}),range(30)))
        self.assertEqual(len(b.wait(old,0)['document']['items']),30)
    def test_clear_notifies_and_allows_drawing_again(self):
        b=Whiteboard();item={'id':'t','kind':'text','text':'hello','x':0,'y':0}
        before=b.add(item)
        cleared=b.clear()
        self.assertEqual(cleared['document']['items'],[])
        self.assertGreater(cleared['revision'],before['revision'])
        self.assertEqual(b.wait(before['revision'],0),cleared)
        self.assertEqual(b.add(item)['document']['items'],[item])

    def test_invalid_input(self):
        b=Whiteboard()
        for value in [None,{}, {'id':'s','kind':'stroke','points':[[float('nan'),0]]}, {'id':'t','kind':'text','text':'','x':0,'y':0}]:
            with self.assertRaises(ValueError):b.add(value)
        self.assertEqual(b.snapshot()['document']['items'],[])
if __name__=='__main__':unittest.main()
