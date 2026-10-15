#!/bin/sh

# Verifies the noncopyable ownership contract of OptionalElementBuffer 1D–4D by compile results (OPT-074 E).
# - OptionalSurfaceValid: borrowing and consuming transfers build (normal control)
# - OptionalCopyableRequirement: 4 errors, a Copyable generic requirement is rejected for each dimension
# - OptionalUseAfterConsume: 4 errors, assignment moves the buffer so the original cannot be used
# A compile-fail target passes only when it reports exactly the expected diagnostics and no other error.
# Builds use a temporary scratch directory that is removed on exit.

set -eu

fixture=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
scratch="$work/scratch"
diagnostics="$work/diagnostics.txt"

build() {
  swift build --disable-sandbox --scratch-path "$scratch" --package-path "$fixture" --target "$1"
}

# Removes ANSI colors and terminal hyperlinks so the diagnostic text can be matched.
plain() {
  perl -pe 's/\e\[[0-9;]*m//g; s/\e\]8;;[^\e]*\e\\//g' "$diagnostics"
}

expect_failure() {
  target=$1
  pattern=$2
  expected=$3
  if build "$target" >"$diagnostics" 2>&1; then
    echo "error: the $target compile-fail fixture unexpectedly compiled" >&2
    exit 1
  fi
  matched=$(plain | grep -Ec "^[^ ]*$target\.swift:[0-9]+:[0-9]+: error: $pattern" || true)
  total=$(plain | grep -Ec '^[^ ]*\.swift:[0-9]+:[0-9]+: error: ' || true)
  if [ "$matched" -ne "$expected" ] || [ "$total" -ne "$expected" ]; then
    plain >&2
    echo "error: $target expected $expected matching errors and no others; found $matched of $total" >&2
    exit 1
  fi
}

build OptionalSurfaceValid

expect_failure OptionalCopyableRequirement \
  "global function 'requiresCopyable' requires that 'OptionalElementBuffer(2D|3D|4D)?<Int>' conform to 'Copyable'" 4
expect_failure OptionalUseAfterConsume \
  "'original' used after consume" 4

echo "verified 1 OptionalElementBuffer compile-pass target (1D-4D transfers), 4 Copyable-requirement and 4 use-after-consume diagnostics"
