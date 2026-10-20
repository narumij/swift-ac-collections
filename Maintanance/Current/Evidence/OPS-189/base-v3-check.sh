#!/bin/zsh
# OPS-189: does v3 test_isolated_launch also fail at the base in this clone? Save the fix, restore base serve.py, run the
# one test, put the fix back. Scratch clone only.
S=/var/folders/x9/2p70phpx3_xdvwx9s6gp35rm0000gn/T/OPS-189.UZC2VcgDnC
cd $S/repo || exit 9
git diff -- Maintanance/RegistryApp/serve.py > $S/fix-serve.diff
git checkout -q -- Maintanance/RegistryApp/serve.py
TMPDIR=$S REGISTRY_STUDIO_MARKED=/Users/narumij/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/marked/lib/marked.esm.js \
  python3 -B Maintanance/RegistryApp/v3/test_serve_v3_mode.py RealProcess.test_isolated_launch > $S/evidence/base-v3-isolated-launch.txt 2>&1
echo "base exit $?" >> $S/evidence/base-v3-isolated-launch.txt
patch -p1 -s < $S/fix-serve.diff
git diff --stat >> $S/evidence/base-v3-isolated-launch.txt
