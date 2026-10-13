#!/bin/sh

set -eu

script_directory=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
mutable_ref_fixture="$script_directory/CompilerDiagnostics/BareArrayMutableRefLifetime"
mutable_ref_scratch="$script_directory/../../.build/bare-array-mutable-ref-compiler-diagnostics"
mutable_ref_diagnostics=$(mktemp)
trap 'rm -f "$mutable_ref_diagnostics"' EXIT

swift build --disable-sandbox --scratch-path "$mutable_ref_scratch" \
  --package-path "$mutable_ref_fixture" --target BareArrayMutableRefValid

if swift build --disable-sandbox --scratch-path "$mutable_ref_scratch" \
  --package-path "$mutable_ref_fixture" --target BareArrayMutableRefEscape \
  >"$mutable_ref_diagnostics" 2>&1; then
  echo "error: the mutable reference escape compile-fail fixture unexpectedly compiled" >&2
  exit 1
fi

mutable_ref_diagnostic_count=$(grep -Ec "^.*BareArrayMutableRefEscape.swift:[0-9]+:[0-9]+: error: lifetime-dependent value escapes its scope" "$mutable_ref_diagnostics" || true)
if [ "$mutable_ref_diagnostic_count" -ne 4 ]; then
  cat "$mutable_ref_diagnostics" >&2
  echo "error: expected 4 mutable reference lifetime escape diagnostics, found $mutable_ref_diagnostic_count" >&2
  exit 1
fi

echo "verified 1 MutableRef compile-pass and 4 MutableRef escape diagnostics"
