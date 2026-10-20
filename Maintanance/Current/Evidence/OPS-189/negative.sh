#!/bin/zsh
# OPS-189 negative controls on the fixed serve.py, inside the scratch clone only. Each removes one added protection, runs
# the tests, and puts the fixed file back from a saved copy.
S=/var/folders/x9/2p70phpx3_xdvwx9s6gp35rm0000gn/T/OPS-189.UZC2VcgDnC
E=$S/evidence
export TMPDIR=$S
export REGISTRY_STUDIO_MARKED=/Users/narumij/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/marked/lib/marked.esm.js
cd $S/repo || exit 9
F=Maintanance/RegistryApp/serve.py
cp $F $S/serve.fixed.py
run() {  # name old new
  python3 -c 'import sys;from pathlib import Path
p=Path(sys.argv[1]);s=p.read_text();assert s.count(sys.argv[2])==1,"marker";p.write_text(s.replace(sys.argv[2],sys.argv[3]))' $F "$2" "$3" || exit 8
  python3 -B Maintanance/RegistryApp/test-startup-safety.py -v > $E/negative-$1.txt 2>&1
  echo "$1 exit $?" >> $E/negative-summary.txt
  cp $S/serve.fixed.py $F
}
# (a) generate before taking the port again (the base order)
run sync-before-bind "    try:
        server = ThreadingHTTPServer(('127.0.0.1', args.port), Handler)
    except OSError as error:
        parser.exit(1, f'Port {args.port} cannot be used ({error}); nothing was generated\n')
    try:
        subprocess.run(" "    subprocess.run([sys.executable, str(APP / 'sync.py'), *sync_args()], cwd=ROOT, check=True, **({'env': SYNC_ENV} if SYNC_ENV else {}))
    try:
        server = ThreadingHTTPServer(('127.0.0.1', args.port), Handler)
    except OSError as error:
        parser.exit(1, f'Port {args.port} cannot be used ({error}); nothing was generated\n')
    try:
        (lambda *a, **k: None)("
# (b) studio_store.py no longer watched
run unwatched-studio-store "'continuity.py', 'studio_store.py')" "'continuity.py')"
cmp $F $S/serve.fixed.py && echo "restored" >> $E/negative-summary.txt
