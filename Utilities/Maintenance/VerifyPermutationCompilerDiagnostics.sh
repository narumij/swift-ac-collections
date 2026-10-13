#!/bin/sh

# runtime-check版`NextPermutations`の公開表面をcompile結果で検証する（PERM-056 G0）。
# - PermutationSurfaceValid: buildが通る
# - PermutationDirectInit: 公開initializerがないためcompile error
# - PermutationCopy: ownerが`~Copyable`のためcompile error
# - PermutationSequence: `Sequence`に適合しないためcompile error

set -eu

script_directory=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
fixture="$script_directory/CompilerDiagnostics/PermutationPublicSurface"
scratch="$script_directory/../../.build/permutation-surface-compiler-diagnostics"
diagnostics=$(mktemp)
trap 'rm -f "$diagnostics"' EXIT

swift build --disable-sandbox --scratch-path "$scratch" --package-path "$fixture" \
  --target PermutationSurfaceValid

expect_failure() {
  target=$1
  pattern=$2
  if swift build --disable-sandbox --scratch-path "$scratch" --package-path "$fixture" \
    --target "$target" >"$diagnostics" 2>&1; then
    echo "error: the $target compile-fail fixture unexpectedly compiled" >&2
    exit 1
  fi
  count=$(perl -pe 's/\e\[[0-9;]*m//g' "$diagnostics" | grep -Ec "$pattern" || true)
  if [ "$count" -lt 1 ]; then
    cat "$diagnostics" >&2
    echo "error: $target failed without the expected diagnostic" >&2
    exit 1
  fi
}

expect_failure PermutationDirectInit \
  "PermutationDirectInit.swift:[0-9]+:[0-9]+: error: 'NextPermutations<Value>' initializer is inaccessible due to 'internal' protection level"
expect_failure PermutationCopy \
  "PermutationCopy.swift:[0-9]+:[0-9]+: error: 'original' used after consume"
expect_failure PermutationSequence \
  "PermutationSequence.swift:[0-9]+:[0-9]+: error: for-in loop requires 'NextPermutations<Int>' to conform to 'Sequence'"

echo "verified 1 NextPermutations compile-pass and 3 compile-fail diagnostics (direct init, copy, Sequence)"
