#!/bin/sh

set -eu

script_directory=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
writeback_fixture="$script_directory/CompilerDiagnostics/BareArrayOwnedWriteback"
escape_fixture="$script_directory/CompilerDiagnostics/BareArrayViewEscape"
writeback_scratch="$script_directory/../../.build/bare-array-writeback-compiler-diagnostics"
escape_scratch="$script_directory/../../.build/bare-array-escape-compiler-diagnostics"
writeback_diagnostics=$(mktemp)
escape_diagnostics=$(mktemp)
trap 'rm -f "$writeback_diagnostics" "$escape_diagnostics"' EXIT

if swift test --disable-sandbox --scratch-path "$writeback_scratch" \
  --package-path "$writeback_fixture" >"$writeback_diagnostics" 2>&1; then
  echo "error: the owned writeback compile-fail fixture unexpectedly compiled" >&2
  exit 1
fi

diagnostic_count=$(grep -c "^macro expansion #expect:.*error: overlapping accesses to 'array'" "$writeback_diagnostics" || true)
if [ "$diagnostic_count" -ne 3 ]; then
  cat "$writeback_diagnostics" >&2
  echo "error: expected 3 exclusivity diagnostics, found $diagnostic_count" >&2
  exit 1
fi

if swift build --disable-sandbox --scratch-path "$escape_scratch" \
  --package-path "$escape_fixture" >"$escape_diagnostics" 2>&1; then
  echo "error: the view escape compile-fail fixture unexpectedly compiled" >&2
  exit 1
fi

escape_diagnostic_count=$(grep -Ec "^.*BareArrayViewEscapeCompilerDiagnostic.swift:[0-9]+:[0-9]+: error: lifetime-dependent value escapes its scope" "$escape_diagnostics" || true)
if [ "$escape_diagnostic_count" -ne 3 ]; then
  cat "$escape_diagnostics" >&2
  echo "error: expected 3 lifetime escape diagnostics, found $escape_diagnostic_count" >&2
  exit 1
fi

echo "verified 3 lifetime escape and 3 owned writeback exclusivity diagnostics"
