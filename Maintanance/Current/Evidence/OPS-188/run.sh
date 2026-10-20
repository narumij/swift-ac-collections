#!/bin/zsh
# OPS-188: run the approval round trip in the scratch clone; output to $S/evidence/$1.txt
S=/var/folders/x9/2p70phpx3_xdvwx9s6gp35rm0000gn/T/OPS-188.fChl4qn4iQ
mkdir -p $S/evidence
export TMPDIR=$S OPS188_EVIDENCE=$S/evidence
export REGISTRY_STUDIO_MARKED=/Users/narumij/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/marked/lib/marked.esm.js
cd $S/repo || exit 9
python3 -B Maintanance/RegistryApp/test-approvals-e2e.py -v > $S/evidence/$1.txt 2>&1
echo "$1 exit $?" >> $S/evidence/summary.txt
