#!/bin/zsh
# OPS-188 negative controls, inside the scratch clone only. Each breaks one connection, runs the round trip, and restores
# the file with git checkout (scratch clone; nothing else is touched).
S=/var/folders/x9/2p70phpx3_xdvwx9s6gp35rm0000gn/T/OPS-188.fChl4qn4iQ
E=$S/evidence
export TMPDIR=$S
export REGISTRY_STUDIO_MARKED=/Users/narumij/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/marked/lib/marked.esm.js
cd $S/repo || exit 9
run() {  # name file old new
  python3 -c 'import sys;from pathlib import Path
p=Path(sys.argv[1]);s=p.read_text();assert s.count(sys.argv[2])==1,"marker";p.write_text(s.replace(sys.argv[2],sys.argv[3]))' "$2" "$3" "$4" || exit 8
  git diff --stat > $E/negative-$1.txt
  python3 -B Maintanance/RegistryApp/test-approvals-e2e.py >> $E/negative-$1.txt 2>&1
  echo "$1 exit $?" >> $E/negative-summary.txt
  git checkout -q -- "$2"
}
# (a) the page: a card's 承認 sends every displayed pending request instead of that one
: run ui-card-target Maintanance/RegistryApp/index.template.html \
  "approve.onclick=()=>action('approve',[{id:card.row.id,revision:card.row.revision}]);" \
  "approve.onclick=()=>action('approve',rows.filter(r=>r.status==='pending').map(({id,revision})=>({id,revision})));"
# (b) the server: an approval also approves every other pending request, not only the named targets
: run server-targets Maintanance/RegistryApp/approvals.py \
  "                    checked.append((row, card, state))" \
  "                    checked.append((row, card, state))
                if body['action'] == 'approve' and not refused:
                    named = {t['id'] for t in targets}
                    for other in con.execute('SELECT id FROM requests').fetchall():
                        r2, c2, s2 = self._row(con, other[0])
                        if other[0] not in named and s2['status'] == 'pending':
                            checked.append((r2, c2, s2))"
# (c) the server: a bulk approval (more than one target) also approves every other pending request, not only the named targets
run server-bulk Maintanance/RegistryApp/approvals.py \
  "                    checked.append((row, card, state))" \
  "                    checked.append((row, card, state))
                if body['action'] == 'approve' and not refused and len(targets) > 1:
                    named = {t['id'] for t in targets}
                    for other in con.execute('SELECT id FROM requests').fetchall():
                        r2, c2, s2 = self._row(con, other[0])
                        if other[0] not in named and s2['status'] == 'pending':
                            checked.append((r2, c2, s2))"
git status --short >> $E/negative-summary.txt
