#!/bin/sh
# OPS-082 trial: edit versions in an isolated Inbox (never the real one). Run from the repository root.
# Starts serve.py on port 18892 with REGISTRY_STUDIO_INBOX in a mktemp folder, checks save/resume/branch/restart/import
# records, then removes the folder. Prints one line per check.
set -eu
T=$(mktemp -d); INB="$T/inbox"; PORT=18892; O="http://127.0.0.1:$PORT"; export REGISTRY_STUDIO_INBOX="$INB"
echo "temp: $T"
start() { python3 Maintanance/RegistryApp/serve.py --port $PORT > "$T/server.log" 2>&1 & SP=$!; i=0; until curl -s -o /dev/null "$O/"; do i=$((i+1)); [ $i -gt 90 ] && exit 1; sleep 1; done; }
stop() { kill $SP; wait $SP 2>/dev/null || true; }
save() { curl -s -X POST "$O/save" -H "Origin: $O" -H 'X-Registry-Studio: save' -H 'Content-Type: application/json' --data-binary @"$1"; }
field() { python3 -c "import json,sys;d=json.load(sys.stdin);print(eval(sys.argv[1]))" "$1"; }
mk() {  # mk OUT PARENT TITLE BASE_SHA: an edit version with one proposal, claiming PARENT, on base BASE_SHA ('' = current)
  python3 - "$1" "$2" "$3" "$4" <<'EOF'
import json,sys
out,parent,title,base=sys.argv[1:]
d=json.load(open('Maintanance/Cache/RegistryStudio/registry.json'))
if base: d['source']['sha256']=base
d['proposals']=[{'id':'draft-1','title':title,'memo':''}]
d['studioSave']={'parent':parent or None}
json.dump(d,open(out,'w'),ensure_ascii=False)
EOF
}
start
echo "1 workspace before any save: $(curl -s "$O/workspace")"
mk "$T/a.json" '' 'A: first' 'oldbase000000000000'
A=$(save "$T/a.json" | field "d['save']['saveId']"); echo "2 save A (no parent, older base): $A"
mk "$T/b.json" "$A" 'B: after A' 'oldbase000000000000'
B=$(save "$T/b.json" | field "(d['save']['saveId'],d['save']['series'],d['save']['branched'])"); echo "3 save B (parent A): $B"
mk "$T/c.json" "$A" 'C: old tab still on A' 'oldbase000000000000'
C=$(save "$T/c.json" | field "(d['save']['saveId'],d['save']['series'],d['save']['branched'])"); echo "4 save C (parent A again = old tab): $C"
mk "$T/x.json" 'no-such-save' 'X' ''
echo "5 unknown parent: $(curl -s -o /dev/null -w '%{http_code}' -X POST "$O/save" -H "Origin: $O" -H 'X-Registry-Studio: save' --data-binary @"$T/x.json")"
echo "6 workspace now: $(curl -s "$O/workspace" | field "(d['save']['proposals'][0]['title'],d['save']['source']['sha256'],d['heads'],d['saves'])")"
curl -s -o /dev/null -X POST "$O/sync" -H "Origin: $O" -H 'X-Registry-Studio: sync'
echo "7 after /sync (canonical regenerated): workspace base $(curl -s "$O/workspace" | field "d['save']['source']['sha256']"), canonical $(field "d['source']['sha256'][:12]" < Maintanance/Cache/RegistryStudio/registry.json)"
stop; start
echo "8 after restart: files $(ls "$INB" | grep -c json), workspace $(curl -s "$O/workspace" | field "d['save']['proposals'][0]['title']")"
stop
AID=$(echo "$B" | python3 -c "import sys,ast;print(ast.literal_eval(sys.stdin.read())[0])")
echo "9 record import of B: $(python3 Maintanance/RegistryApp/inbox.py record "$AID" --note 'trial: draft-1 → (no formal ID in trial)' | head -c 80)"
echo "10 record B again: $(python3 Maintanance/RegistryApp/inbox.py record "$AID" --note again 2>&1 || true)"
echo "11 list:"; python3 Maintanance/RegistryApp/inbox.py list | sed 's/^/   /'
echo "12 original history intact: $(for f in "$INB"/registry-edited-*.json; do python3 -c "import json,sys;d=json.load(open(sys.argv[1]));print(d['proposals'][0]['title'])" "$f"; done | sort | tr '\n' ';')"
rm -rf "$T"; echo "cleaned: $T"
