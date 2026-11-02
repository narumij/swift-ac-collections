#!/usr/bin/env bash
# Generate the copies, build the reduced placement probe (x86-64 only) and verify
# its layout. Fails if any copy's bytes or placement differ from the reference.
# Usage: ./build.sh OUTDIR    (CC defaults to cc; needs objdump and python3)
set -euo pipefail
if [ $# -ne 1 ]; then
    echo "usage: $0 OUTDIR" >&2
    exit 2
fi
here=$(cd "$(dirname "$0")" && pwd)
out=$1
mkdir -p "$out"
CC=${CC:-cc}

python3 "$here/gen_probe_asm.py" "$here/closure_bytes.inc" "$out/probe_copies.S"
# $CC is intentionally unquoted so that e.g. CC="clang -target ..." works.
$CC -O2 -std=c11 -Wall -Wextra -Werror -I"$here" -o "$out/probe" \
    "$here/driver.c" "$out/probe_copies.S"
objdump -d "$out/probe" > "$out/probe.objdump"
python3 "$here/verify_layout.py" "$out/probe.objdump" "$here/closure_bytes.h" | tee "$out/verify_layout.txt"
