"""Member model contracts; no HTTP server, ViewModel or browser."""
import unittest

from member_state import MemberState


class MemberStateTest(unittest.TestCase):
    def test_initially_empty(self):
        model = MemberState([])
        self.assertEqual(model.snapshot()['members'], [])
        self.assertEqual(model.snapshot()['memberInfo'], {})

    def test_planned_and_present_union(self):
        model = MemberState([], ['planned', 'both'])
        model.attend('both')
        model.attend('unexpected')
        self.assertEqual(model.snapshot()['members'], [
            {'owner': 'planned', 'planned': True, 'attendance': 'absent'},
            {'owner': 'both', 'planned': True, 'attendance': 'present'},
            {'owner': 'unexpected', 'planned': False, 'attendance': 'present'},
        ])
        self.assertEqual(model.snapshot()['memberInfo'],
                         {'planned': '', 'both': '', 'unexpected': ''})

    def test_information_updates_only_existing_keys(self):
        model = MemberState([], ['A'])
        model.update_info('A', '受領 01:23')
        self.assertEqual(model.snapshot()['memberInfo'], {'A': '受領 01:23'})
        before = model.snapshot()
        model.update_info('unknown', '待機開始 01:24')
        self.assertEqual(model.snapshot(), before)
        model.update_info('A', '')
        self.assertEqual(model.snapshot()['memberInfo'], {'A': ''})

    def test_information_survives_while_either_membership_remains(self):
        for remove_first in ('leave', 'remove_planned'):
            with self.subTest(remove_first=remove_first):
                model = MemberState([], ['A'])
                model.attend('A')
                model.update_info('A', '保持する情報')
                getattr(model, remove_first)('A')
                self.assertEqual(model.snapshot()['memberInfo'], {'A': '保持する情報'})
                remove_last = 'remove_planned' if remove_first == 'leave' else 'leave'
                getattr(model, remove_last)('A')
                self.assertEqual(model.snapshot()['memberInfo'], {})
                self.assertEqual(model.snapshot()['members'], [])
                model.attend('A')
                self.assertEqual(model.snapshot()['memberInfo'], {'A': ''})

    def test_bulk_changes_synchronize_keys_and_preserve_survivors(self):
        model = MemberState([], ['A', 'B'])
        model.attend('C')
        model.update_info('B', 'Bの情報')
        model.update_info('C', 'Cの情報')
        model.replace_planned(['B', 'D'])
        self.assertEqual(model.snapshot()['memberInfo'], {'B': 'Bの情報', 'D': '', 'C': 'Cの情報'})
        model.replace([{'owner': 'E', 'attendance': 'present'}])
        self.assertEqual(model.snapshot()['memberInfo'], {'B': 'Bの情報', 'D': '', 'E': ''})
        model.clear_planned()
        self.assertEqual(model.snapshot()['memberInfo'], {'E': ''})
        model.add_planned('D')
        model.clear()
        self.assertEqual(model.snapshot()['memberInfo'], {'D': ''})
        model.clear_planned()
        self.assertEqual(model.snapshot()['memberInfo'], {})

    def test_repeated_attendance_and_plan_do_not_duplicate_or_erase_information(self):
        model = MemberState([])
        model.attend('A')
        model.add_planned('A')
        model.update_info('A', '保持')
        before = model.snapshot()
        model.attend('A')
        model.add_planned('A')
        self.assertEqual(model.snapshot(), before)

    def test_information_change_advances_observable_revision(self):
        model = MemberState([], ['A'])
        revision = model.snapshot()['revision']
        model.update_info('A', '更新')
        changed = model.wait(revision, timeout=0)
        self.assertGreater(changed['revision'], revision)
        self.assertEqual(changed['memberInfo'], {'A': '更新'})
        model.update_info('A', '更新')
        self.assertEqual(model.snapshot(), changed)

    def test_snapshot_information_cannot_mutate_model(self):
        model = MemberState([], ['A'])
        snapshot = model.snapshot()
        snapshot['memberInfo']['A'] = '外部変更'
        snapshot['memberInfo']['B'] = '追加'
        self.assertEqual(model.snapshot()['memberInfo'], {'A': ''})


if __name__ == '__main__':
    unittest.main()
