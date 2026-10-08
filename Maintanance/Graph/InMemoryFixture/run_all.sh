#!/bin/sh
# GRAPH-009: run GRAPH-007 and the RP fixtures, each in its own empty SQLite :memory: database.
# From the repository root:  sh Maintanance/Graph/InMemoryFixture/run_all.sh
# Exit status is 0 only when every fixture prints its PASS line; a FAIL line, a SQL error, or a missing
# result line makes the whole run fail.

cd "$(dirname "$0")/../../.." || exit 2

failed=0
for entry in \
  "GRAPH-007:run.sql:PASS: " \
  "RP-01:rp01_precedence.sql:RP-01: PASS" \
  "RP-05:rp05_spec_role.sql:RP-05: PASS" \
  "RP-08:rp08_spec_gap.sql:RP-08: PASS" \
  "RP-15:rp15_document_match.sql:RP-15: PASS" \
  "RP-17:rp17_staleness.sql:RP-17: PASS"
do
  name=${entry%%:*}
  rest=${entry#*:}
  file=${rest%%:*}
  pass=${rest#*:}

  output=$(sqlite3 :memory: < "Maintanance/Graph/InMemoryFixture/$file" 2>&1)
  status=$?
  last=$(printf '%s\n' "$output" | tail -n 1)

  case "$last" in
    "$pass"*)
      if [ "$status" -eq 0 ]; then
        printf '%-9s PASS  %s\n' "$name" "$last"
        continue
      fi
      ;;
  esac
  failed=$((failed + 1))
  printf '%-9s FAIL  (sqlite3 exit %s) %s\n' "$name" "$status" "$last"
done

if [ "$failed" -eq 0 ]; then
  echo "ALL PASS: 6 of 6 fixtures"
  exit 0
fi
echo "FAILED: $failed of 6 fixtures"
exit 1
