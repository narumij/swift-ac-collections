#!/usr/bin/env python3
"""OPS-167 K9: the hermetic guard itself. Every live path with an override points into the guard's temporary root,
in this process (inbox.INBOX, sync.APP, sync.TOOLS_RECORD, approvals.DATABASE) and in a child process.

Run: python3 -B Maintanance/RegistryApp/v3/test_hermetic.py -v
"""
import json
import subprocess
import sys
import unittest
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
import hermetic  # noqa: E402  (first: temporary roots for every live path, OPS-167 K9)
sys.path.insert(0, str(HERE.parent))
import approvals  # noqa: E402
import inbox  # noqa: E402
import shadow_import as si  # noqa: E402


class Guard(unittest.TestCase):
    def inside(self, path):
        return Path(path).resolve().is_relative_to(hermetic.ROOT_DIR.resolve())

    def test_this_process(self):
        sync = si.load_sync()
        for name, path in (('inbox.INBOX', inbox.INBOX), ('sync.APP', sync.APP), ('sync.TOOLS_RECORD', sync.TOOLS_RECORD), ('approvals.DATABASE', approvals.DATABASE)):
            self.assertTrue(self.inside(path), f'{name} = {path}')

    def test_child_processes_inherit(self):
        code = ('import json, os; print(json.dumps({k: os.environ.get(k) for k in '
                + repr(sorted(hermetic.ENV)) + '}))')
        out = json.loads(subprocess.run([sys.executable, '-c', code], capture_output=True, text=True, timeout=30).stdout)
        self.assertTrue(all(v and self.inside(v) for v in out.values()), out)

    def test_live_paths_are_named(self):
        self.assertEqual(set(hermetic.LIVE), set(hermetic.OVERRIDDEN))
        hermetic.assert_live_unchanged(self)


if __name__ == '__main__':
    sys.exit(0 if unittest.main(exit=False, verbosity=2 if '-v' in sys.argv else 1).result.wasSuccessful() else 1)
