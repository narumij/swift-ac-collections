#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK_DIR="$(mktemp -d "${TMPDIR:-/tmp}/materialize-normal-release.XXXXXX")"
trap 'rm -rf "$WORK_DIR"' EXIT

cp "$SCRIPT_DIR/Fixtures/conditional-input.swift" "$WORK_DIR/actual.swift"
python3 "$SCRIPT_DIR/materialize_normal_release.py" "$WORK_DIR/actual.swift"
diff -u "$SCRIPT_DIR/Fixtures/conditional-expected.swift" "$WORK_DIR/actual.swift"

if grep -Eq '^[[:space:]]*#(if|elseif).*COMPATIBLE_ATCODER_2025' "$WORK_DIR/actual.swift"; then
  echo "compatibility condition remains in transformed fixture" >&2
  exit 1
fi

echo "materialize_normal_release fixture passed"
