# Codex-to-Claude Work Request

Status: Completed — SortedCollections benchmark Phase 2 implemented and smoke-checked;
result in `SORTED_COLLECTIONS_BENCHMARK_TASK.md` ("Phase 2 result"), awaiting review

## Active assignment

Immediately perform Phase 2 as authorized in
`Maintanance/SORTED_COLLECTIONS_BENCHMARK_TASK.md`. Do not ask whether to begin, and
do not send the user a session-start summary, repository inventory, stale-document
list, or restatement of the task.

Implement the reviewed Set/Dictionary matrix and its correctness validation only.
Use the new benchmark-local seeded inputs only for the new tasks. Keep capability-
difference rows separate from matched performance charts. Run a small Release smoke
check proving registration and equivalent observable results, then stop before any
publishable or large measurement run.

Write the detailed result into the benchmark task Markdown for Codex, set the status
appropriately, and stop without sending the user a completion report. Directly contact
the user only if work is blocked, a safety issue is found, or a decision that only the
user can make is genuinely required.

## Previous assignment objective (completed)

Complete the four-container curated C++ comparison by adding one final pair:
`RedBlackTreeMultiMap<Int64, Int64>` and `std::multimap<int64_t, int64_t>`.

The primary question is the observable placement of distinct mapped values inside an
equivalent-key group, especially under hinted insertion. Communicate with the user in
Japanese. Do not commit or push.

## Baseline

Read all committed Set/MultiSet/Dictionary comparison code, the MultiMap public
implementation and Test as Specification, and
`Maintanance/CPP_BEHAVIOR_COMPARISON_TASK.md` before editing.

Run:

```sh
swift test --disable-sandbox --filter CppBehaviorReferenceTests
```

Exactly 13 tests must pass. Stop if the baseline differs.

## Authorized Scope

You may edit only:

- `Sources/CppBehaviorReference/`
- `Tests/CppBehaviorReferenceTests/`
- this file for final status/result
- `Maintanance/CPP_BEHAVIOR_COMPARISON_TASK.md` for verified MultiMap results

Do not edit production Swift, `Package.swift`, `Benchmarks/`, existing Set/MultiSet/
Dictionary tests, randomized tests, workflows, dashboard documents, either
`WorldClassAssessment` file, or the queued benchmark task.

## Required MultiMap Comparison

Use `Int64` keys and identity-bearing `Int64` mapped values. Keep a separate
`std::multimap<int64_t, int64_t>` executor/observation path while reusing the existing
trace architecture.

Cover at least:

1. insertion of distinct keys and duplicate keys with distinct mapped values;
2. `lowerBound`, `upperBound`, and `equalRange` at before/at/between/after keys;
3. complete ordered key/value contents after every operation;
4. erase by key, including the number removed;
5. erase by a rank selected from current ordered contents, comparing the erased entry
   and the resulting next position only where both APIs expose equivalent facts;
6. update of the mapped value at a selected rank, if it maps directly to assigning
   through a valid `std::multimap` iterator;
7. hinted insertion with:
   - an empty container (`startIndex == endIndex`);
   - exact hints before and after an equivalent-key group;
   - a hint inside an equivalent-key group;
   - deliberately poor but valid hints before and after the group;
   - `startIndex` and `endIndex`;
   - reinsertion after erasure.

For every hinted insert, compare the returned rank and full ordered key/value contents.
The mapped value is the occurrence identity: use distinct values so placement within
an equal-key group is observable. Do not collapse observations to keys only.

Transport positions only as current zero-based ranks and independently resolve them
to Swift indices and C++ iterators immediately before use.

Add a deliberate mismatch test proving the diagnostic includes the container pair,
operation number, input, and both complete observations.

## Semantic discipline

- Determine the Swift API contract from implementation/tests before selecting a C++
  operation. Do not equate APIs by name alone.
- C++ hint validity and Swift hint validity must both be checked for every trace.
- If equivalent-key placement intentionally differs, preserve the smallest trace and
  report the difference; do not sort mapped values or otherwise normalize it away.
- Do not change production Swift to force agreement in this assignment.

## Stop Conditions

- On any semantic difference or crash, minimize and preserve the trace safely, set
  `Status: Blocked`, and stop before a production fix.
- Stop if a public API or Package change is needed.
- Do not expand into random/fuzz traces, performance work, or benchmark conclusions.

## Validation

1. Run narrow new MultiMap comparison tests during development.
2. Run all `CppBehaviorReferenceTests`.
3. Run `git diff --check`.
4. Confirm the changed-file list stays within the authorized scope.

Do not run the full package suite unless the focused build reveals a wider issue.

## Completion Report

Set `Status: Completed` only if the focused suite and `git diff --check` pass. Write
the exact behaviors compared, final test count/result, changed files, and real
limitations/differences into this file for Codex to review. Do not add an
accountability diary or unrelated findings.

Do not send the user a completion report or detailed handoff. Record it in the assigned
Markdown for Codex and stop. Only surface details directly when work is blocked, a
safety issue was found, or an explicit user decision is required.

### Result (2026-10-04, Claude Opus 5.5)

- **Compared** (`RedBlackTreeMultiMap<Int64, Int64>` / `std::multimap<int64_t, int64_t>`,
  distinct mapped values as occurrence identity, full ordered key/value contents
  after every operation):
  - `insert(key:value:)` ↔ `insert({k, v})`: placement after the equivalent group,
    observed through contents (neither result exposes a rank directly).
  - `insert(_:hint:)` ↔ `insert(hint, {k, v})`: returned entry and rank for an empty
    container, exact hints before/after the group, inside the group, poor hints
    before/after, `startIndex`, `endIndex`, poor hints for existing least/greatest
    keys, reinsertion at a vacated position, and reinsertion after erasing the group.
  - `find(_:)` + `count(forKey:)` ↔ `find` + `count`.
  - `lowerBound`/`upperBound` ↔ `lower_bound`/`upper_bound`: entry and rank at
    before/at/between/after keys.
  - `multimap[equalRange(k)]` ↔ `equal_range(k)`: lower/upper rank and entries in order.
  - `eraseMulti(_:)` ↔ `erase(k)`: removed count.
  - `erase(_:)` ↔ `erase(it)`: rank of the returned next position.
  - `remove(at:)` ↔ copy `*it`, then `erase(it)`: erased entry.
  - `updateValue(_:at:)` ↔ copy `it->second`, then `it->second = v`: previous value.
  - Hint/positional ranks are validated on both sides: C++ by range, Swift by range
    plus `isElement(at:)`/`isEnd(_:)` on the resolved index.
- **Result:** 4 new MultiMap tests passed; all `CppBehaviorReferenceTests` 17
  passed (baseline 13). `git diff --check` clean.
- **Changed files:** `Sources/CppBehaviorReference/include/CppBehaviorReference.h`,
  `Sources/CppBehaviorReference/CppBehaviorReference.cpp`,
  `Tests/CppBehaviorReferenceTests/MultiMapBehaviorComparisonTests.swift` (new),
  this file, `Maintanance/CPP_BEHAVIOR_COMPARISON_TASK.md`.
- **Differences/limitations:** No Swift/C++ difference or crash was found, including
  within-group placement. `remove(at:)` and `erase(_:)` each expose only one of the
  erased entry / next position, so each is compared against its C++ counterpart
  for that fact alone.

## Next assignment — credibility-first peer comparison

The next task is `Maintanance/SORTED_COLLECTIONS_BENCHMARK_TASK.md`. The project is
now prioritizing evidence that helps a user or an AI make a defensible adoption
decision over broad feature expansion.

Start with Phase 1 only: audit the existing benchmark, confirm the resolved upstream
version/trait, run the small harness smoke check, and propose a genuinely matched
Set/Dictionary workload matrix. Stop for review before the large measurement run.

Task decisions in this phase follow this order:

1. preserve or improve reproducibility and semantic comparability;
2. seek evidence capable of disproving a favorable claim;
3. record disadvantages, limitations, instability, and unmeasured axes as first-class results;
4. prefer external baselines and independently reviewable artifacts over self-rating;
5. add implementation or benchmark breadth only when it strengthens one of the above.

Do not change production code to improve a result, silently substitute a merely
similar operation, or update either WorldClassAssessment conclusion from preliminary
measurements. Treat Swift Collections as a respected upstream reference within the
same ecosystem; describe tradeoffs and suitable use cases in neutral language. Frame
this package as a provisional bridge or complement for currently unmet needs, not as
a replacement. Note evidence that would justify narrowing that role in the future.

For this and later assignments, place the detailed completion report in the assigned
Markdown file for Codex and do not send a user-facing completion message. Only a
blocker, safety concern, or decision requiring the user may be surfaced directly.

## History

Earlier assignments and result summaries:
[`CLAUDE_TASK_HISTORY.md`](CLAUDE_TASK_HISTORY.md).
