#!/bin/zsh
# OPS-191: run the three new suites and the focused regression set on base + three patches; output to $S/evidence
S=/var/folders/x9/2p70phpx3_xdvwx9s6gp35rm0000gn/T/OPS-191.ChRKgTrqRk
E=$S/evidence; mkdir -p $E
export TMPDIR=$S
export REGISTRY_STUDIO_MARKED=/Users/narumij/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/marked/lib/marked.esm.js
cd $S/repo || exit 9
t() {  # name command...
  local name=$1; shift
  "$@" > $E/$name.txt 2>&1
  echo "$name exit $?" >> $E/summary.txt
}
t letters-e2e python3 -B Maintanance/RegistryApp/test-letters-e2e.py -v
t approvals-e2e python3 -B Maintanance/RegistryApp/test-approvals-e2e.py -v
t startup-safety python3 -B Maintanance/RegistryApp/test-startup-safety.py -v
cd Maintanance/RegistryApp
t test-serve python3 -B test-serve.py -v
t test-studio-letters python3 -B test-studio-letters.py -v
t test-view-model-letters node test-view-model-letters.cjs
t test-approvals-py python3 -B test-approvals.py -v
t test-approvals-cjs node test-approvals.cjs
echo done >> $E/summary.txt
