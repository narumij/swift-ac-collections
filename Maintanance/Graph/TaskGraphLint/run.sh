#!/bin/sh

# Read-only structural lint for the Task Registry in PROGRESS_OVERVIEW.md.
# Usage from the repository root:
#   sh Maintanance/Graph/TaskGraphLint/run.sh

set -eu

repo_root=$(CDPATH= cd -- "$(dirname "$0")/../../.." && pwd)
registry=${1:-"$repo_root/Maintanance/PROGRESS_OVERVIEW.md"}
if [ ! -f "$registry" ]; then
  echo "Task Registry not found: $registry" >&2
  exit 2
fi
work_dir=$(mktemp -d "${TMPDIR:-/tmp}/task-graph-lint.XXXXXX")
trap 'rm -rf "$work_dir"' EXIT HUP INT TERM

awk -F '|' '
  function clean(value) {
    gsub(/^[[:space:]]+|[[:space:]]+$/, "", value)
    gsub(/`/, "", value)
    return value
  }
  /^## Task Registry$/ { in_registry = 1; next }
  /^## Task precedence$/ { in_registry = 0; next }
  in_registry && /^\| `/ {
    print clean($2) "\t" clean($3) "\t" clean($4) "\t" clean($5) "\t" clean($6)
  }
' "$registry" > "$work_dir/tasks.tsv"

awk -F '|' '
  function clean(value) {
    gsub(/^[[:space:]]+|[[:space:]]+$/, "", value)
    gsub(/`/, "", value)
    return value
  }
  /^## Task precedence$/ { in_precedence = 1; next }
  /^## Registry rules$/ { in_precedence = 0; next }
  in_precedence && /^\| `/ {
    print clean($2) "\t" clean($3) "\t" clean($4) "\t" clean($5)
  }
' "$registry" > "$work_dir/precedence.tsv"

sqlite3 :memory: <<SQL
.bail on
.headers on
.mode column

CREATE TABLE task (
  id TEXT PRIMARY KEY,
  state TEXT NOT NULL,
  owner TEXT NOT NULL,
  item TEXT NOT NULL,
  restart_condition TEXT NOT NULL
);

CREATE TABLE precedence (
  successor TEXT NOT NULL,
  prerequisite TEXT NOT NULL,
  flow TEXT NOT NULL,
  constraint_text TEXT NOT NULL
);

.mode tabs
.import '$work_dir/tasks.tsv' task
.import '$work_dir/precedence.tsv' precedence
.mode column

CREATE TEMP VIEW finding AS
SELECT 'ERROR' AS severity, 'dangling_successor' AS rule,
       p.successor || ' -> ' || p.prerequisite AS subject
FROM precedence p LEFT JOIN task t ON t.id = p.successor
WHERE t.id IS NULL
UNION ALL
SELECT 'ERROR', 'dangling_prerequisite',
       p.successor || ' -> ' || p.prerequisite
FROM precedence p LEFT JOIN task t ON t.id = p.prerequisite
WHERE t.id IS NULL
UNION ALL
SELECT 'ERROR', 'self_dependency', successor
FROM precedence
WHERE successor = prerequisite
UNION ALL
SELECT 'ERROR', 'duplicate_edge',
       successor || ' -> ' || prerequisite || ' (' || COUNT(*) || ')'
FROM precedence
GROUP BY successor, prerequisite
HAVING COUNT(*) > 1
UNION ALL
SELECT 'ERROR', 'invalid_flow',
       successor || ' -> ' || prerequisite || ': ' || flow
FROM precedence
WHERE flow NOT IN ('SEQUENCE', 'PARALLEL_JOIN', 'UNCLASSIFIED')
UNION ALL
SELECT 'WARNING', 'unclassified_flow',
       successor || ' -> ' || prerequisite
FROM precedence
WHERE flow = 'UNCLASSIFIED'
UNION ALL
SELECT 'WARNING', 'conditional_prerequisite',
       p.successor || ' -> ' || p.prerequisite
FROM precedence p JOIN task prerequisite ON prerequisite.id = p.prerequisite
WHERE prerequisite.restart_condition LIKE '%場合だけ%'
   OR prerequisite.restart_condition LIKE '%場合に限り%';

CREATE TEMP VIEW cycle_start AS
WITH RECURSIVE walk(start, current, path, cycle) AS (
  SELECT successor,
         prerequisite,
         '|' || successor || '|' || prerequisite || '|',
         successor = prerequisite
  FROM precedence
  UNION ALL
  SELECT walk.start,
         p.prerequisite,
         walk.path || p.prerequisite || '|',
         instr(walk.path, '|' || p.prerequisite || '|') > 0
  FROM walk
  JOIN precedence p ON p.successor = walk.current
  WHERE walk.cycle = 0
)
SELECT DISTINCT start
FROM walk
WHERE cycle = 1;

SELECT severity, rule, subject FROM finding
UNION ALL
SELECT 'ERROR', 'dependency_cycle', start FROM cycle_start
ORDER BY severity, rule, subject;

SELECT
  (SELECT COUNT(*) FROM task) AS tasks,
  (SELECT COUNT(*) FROM precedence) AS edges,
  (SELECT COUNT(*) FROM finding WHERE severity = 'WARNING') AS warnings,
  ((SELECT COUNT(*) FROM finding WHERE severity = 'ERROR') +
   (SELECT COUNT(*) FROM cycle_start)) AS errors;

SELECT CASE
  WHEN (SELECT COUNT(*) FROM finding WHERE severity = 'ERROR') = 0
   AND (SELECT COUNT(*) FROM cycle_start) = 0
  THEN 'TASK_GRAPH_LINT: PASS'
  ELSE 'TASK_GRAPH_LINT: FAIL'
END AS result;
SQL

error_count=$(sqlite3 :memory: <<SQL
CREATE TABLE task (id TEXT PRIMARY KEY, state TEXT, owner TEXT, item TEXT, restart_condition TEXT);
CREATE TABLE precedence (successor TEXT, prerequisite TEXT, flow TEXT, constraint_text TEXT);
.mode tabs
.import '$work_dir/tasks.tsv' task
.import '$work_dir/precedence.tsv' precedence
WITH RECURSIVE
direct_error(value) AS (
  SELECT 1 FROM precedence p LEFT JOIN task t ON t.id = p.successor WHERE t.id IS NULL
  UNION ALL SELECT 1 FROM precedence p LEFT JOIN task t ON t.id = p.prerequisite WHERE t.id IS NULL
  UNION ALL SELECT 1 FROM precedence WHERE successor = prerequisite
  UNION ALL SELECT 1 FROM precedence GROUP BY successor, prerequisite HAVING COUNT(*) > 1
  UNION ALL SELECT 1 FROM precedence WHERE flow NOT IN ('SEQUENCE', 'PARALLEL_JOIN', 'UNCLASSIFIED')
),
walk(start, current, path, cycle) AS (
  SELECT successor, prerequisite, '|' || successor || '|' || prerequisite || '|', successor = prerequisite
  FROM precedence
  UNION ALL
  SELECT walk.start, p.prerequisite, walk.path || p.prerequisite || '|',
         instr(walk.path, '|' || p.prerequisite || '|') > 0
  FROM walk JOIN precedence p ON p.successor = walk.current
  WHERE walk.cycle = 0
)
SELECT (SELECT COUNT(*) FROM direct_error) +
       (SELECT COUNT(DISTINCT start) FROM walk WHERE cycle = 1);
SQL
)

test "$error_count" -eq 0
