#!/bin/zsh
# OPS-187 negative controls, run inside the scratch clone only. Each breaks one connection, runs the round trip, and
# restores the file with git checkout (scratch clone; nothing else is touched).
S=/var/folders/x9/2p70phpx3_xdvwx9s6gp35rm0000gn/T/OPS-187.goA6zDDM2P
E=$S/evidence
export TMPDIR=$S
export REGISTRY_STUDIO_MARKED=/Users/narumij/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/marked/lib/marked.esm.js
cd $S/repo || exit 9
run() {  # name file old new
  python3 -c 'import sys;from pathlib import Path
p=Path(sys.argv[1]);s=p.read_text();assert s.count(sys.argv[2])==1,"marker";p.write_text(s.replace(sys.argv[2],sys.argv[3]))' "$2" "$3" "$4" || exit 8
  git diff --stat > $E/negative-$1.txt
  python3 -B Maintanance/RegistryApp/test-letters-e2e.py >> $E/negative-$1.txt 2>&1
  echo "$1 exit $?"
  git checkout -q -- "$2"
}
run ui-receipt Maintanance/RegistryApp/index.template.html "(l.receivedAt?letterTime(l.receivedAt):'未受領')" "('未受領')"
run server-brief Maintanance/RegistryApp/studio_store.py "**_event_times(events, row['received_at']), 'state': current" "**_event_times(events, row['received_at']), 'receivedAt': None, 'state': current"
git status --short
