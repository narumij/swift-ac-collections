#!/bin/sh

set -eu

lint_dir=$(CDPATH= cd -- "$(dirname "$0")" && pwd)

healthy_output=$(mktemp "${TMPDIR:-/tmp}/task-graph-lint-healthy.XXXXXX")
invalid_output=$(mktemp "${TMPDIR:-/tmp}/task-graph-lint-invalid.XXXXXX")
trap 'rm -f "$healthy_output" "$invalid_output"' EXIT HUP INT TERM

sh "$lint_dir/run.sh" "$lint_dir/Fixtures/healthy.md" > "$healthy_output"
grep -q 'TASK_GRAPH_LINT: PASS' "$healthy_output"

if sh "$lint_dir/run.sh" "$lint_dir/Fixtures/invalid.md" > "$invalid_output"; then
  echo "FAIL: invalid fixture returned success"
  exit 1
fi

grep -q 'dangling_prerequisite' "$invalid_output"
grep -q 'self_dependency' "$invalid_output"
grep -q 'invalid_barrier' "$invalid_output"
grep -q 'dependency_cycle' "$invalid_output"
grep -q 'TASK_GRAPH_LINT: FAIL' "$invalid_output"

echo "TASK_GRAPH_LINT_FIXTURES: PASS"
