"""OPS-167 K9: the hermetic guard of the V3 tests, imported first by every test module (before serve, sync or inbox).

It points every live path that has an environment override at a temporary root for the whole test process, so the
process and every child it starts (serve.py, sync.py, the CLI) default to temporary roots, even if the code under test
regressed and dropped its own explicit path (the K9 local-tools.json lesson). The overrides are forced, not defaulted.

Live paths without an override are kept out differently: the test servers do not serve the routes that open them
(probe.sqlite3, Activity/), and browser runs abort those paths before sending. The live template, Registry, Rules,
Milestones and documents are only read. live_state() fingerprints the live files so a test can assert they did not
change (assert_live_unchanged).
"""
import atexit
import hashlib
import os
import shutil
import tempfile
from pathlib import Path

APP = Path(__file__).resolve().parent.parent
ROOT = APP.parent.parent
ROOT_DIR = Path(tempfile.mkdtemp(prefix='v3-tests-hermetic-'))
atexit.register(shutil.rmtree, ROOT_DIR, True)
for name in ('app', 'inbox'):
    (ROOT_DIR / name).mkdir()
ENV = {'REGISTRY_STUDIO_APP': str(ROOT_DIR / 'app'), 'REGISTRY_STUDIO_TOOLS': str(ROOT_DIR / 'app' / 'local-tools.json'),
       'REGISTRY_STUDIO_INBOX': str(ROOT_DIR / 'inbox'), 'REGISTRY_STUDIO_APPROVALS_DB': str(ROOT_DIR / 'approvals.sqlite3')}
os.environ.update(ENV)

LIVE = {'Cache/RegistryStudio': ROOT / 'Maintanance' / 'Cache' / 'RegistryStudio', 'local-tools.json': APP / 'local-tools.json',
        'Inbox': APP / 'Inbox', 'Approvals': APP / 'Approvals', 'Activity': APP / 'Activity'}
OVERRIDDEN = {'Cache/RegistryStudio': 'REGISTRY_STUDIO_APP', 'local-tools.json': 'REGISTRY_STUDIO_TOOLS', 'Inbox': 'REGISTRY_STUDIO_INBOX',
              'Approvals': 'REGISTRY_STUDIO_APPROVALS_DB (approvals.sqlite3 only; probe.sqlite3 by not serving /approval-probe)',
              'Activity': 'none (by not serving /activity-*, /continuity)'}


def live_state():
    files = []
    for base in LIVE.values():
        files += [base] if base.is_file() else sorted(p for p in base.rglob('*') if p.is_file()) if base.is_dir() else []
    return {str(p): (p.stat().st_mtime_ns, hashlib.sha256(p.read_bytes()).hexdigest()) for p in files}


BEFORE = live_state()


def assert_live_unchanged(case):
    case.assertEqual(live_state(), BEFORE, 'a live file changed during the tests')
