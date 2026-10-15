#!/bin/sh

set -eu

script_directory=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
mutable_ref_fixture="$script_directory/CompilerDiagnostics/BareArrayMutableRefLifetime"
mutable_ref_scratch="$script_directory/../../.build/bare-array-mutable-ref-compiler-diagnostics"
mutable_ref_diagnostics=$(mktemp)
trap 'rm -f "$mutable_ref_diagnostics"' EXIT

# The compiler may emit colored diagnostics even when its output is redirected.
# Strip ANSI color codes and terminal hyperlinks before matching diagnostic text.
strip_terminal_codes() {
  sed 's/\x1b\[[0-9;]*m//g; s/\x1b\]8;;[^\x1b]*\x1b\\//g' "$1"
}

# Builds a compile-fail target and checks that it fails with exactly the expected number of
# errors, all carrying the expected message. Any other error means the fixture failed for an
# unintended reason and is reported as a verification failure.
expect_compile_failure() {
  target=$1
  source_file=$2
  expected_message=$3
  expected_count=$4

  if swift build --disable-sandbox --scratch-path "$mutable_ref_scratch" \
    --package-path "$mutable_ref_fixture" --target "$target" \
    >"$mutable_ref_diagnostics" 2>&1; then
    echo "error: the $target compile-fail fixture unexpectedly compiled" >&2
    exit 1
  fi

  all_errors=$(strip_terminal_codes "$mutable_ref_diagnostics" \
    | grep -Ec "^.*$source_file:[0-9]+:[0-9]+: error: " || true)
  expected_errors=$(strip_terminal_codes "$mutable_ref_diagnostics" \
    | grep -Ec "^.*$source_file:[0-9]+:[0-9]+: error: $expected_message" || true)
  if [ "$expected_errors" -ne "$expected_count" ] || [ "$all_errors" -ne "$expected_count" ]; then
    strip_terminal_codes "$mutable_ref_diagnostics" >&2
    echo "error: $target expected $expected_count '$expected_message' errors and no others," \
      "found $expected_errors of $all_errors" >&2
    exit 1
  fi
}

swift build --disable-sandbox --scratch-path "$mutable_ref_scratch" \
  --package-path "$mutable_ref_fixture" --target BareArrayMutableRefValid

expect_compile_failure BareArrayMutableRefEscape BareArrayMutableRefEscape.swift \
  "lifetime-dependent value escapes its scope" 4

expect_compile_failure BareArrayMutableRefConflict BareArrayMutableRefConflict.swift \
  "overlapping accesses to 'array', but modification requires exclusive access" 20

echo "verified 1 MutableRef compile-pass target (21 functions), 4 MutableRef escape diagnostics," \
  "and 20 MutableRef borrow-conflict diagnostics"
