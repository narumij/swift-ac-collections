# Codex-to-Claude Work Request

Status: Completed — benchmark validation, first strict-memory-safety adoption, and task-file compaction

## Latest Follow-up Assignment (completed)

Complete these three bounded tasks in order. Communicate with the user in
Japanese. Work only inside the repository, as required by the root `CLAUDE.md`.
Do not edit the paused `RedBlackTreeSet` or `RedBlackTreeDictionary` outlines,
do not start the deferred C++ comparison target, and do not optimize production
meld code or the unrelated `erase(where:)` CoW path. Do not commit or push.

### Task 1 — Validate and harden the new Combining benchmarks

Review the benchmark cases added in
`Benchmarks/Sources/Benchmarks/CombiningAPIBenchmarks.swift` before treating the
recorded measurements as durable evidence.

1. Make shuffled inputs deterministic and reproducible. Do not use an
   unseeded `shuffled()` call in evidence-producing benchmarks.
2. Confirm from the benchmark harness semantics that every measured sample
   starts from the intended collection state. In particular, ensure a mutating
   combining operation is not repeatedly measured against a destination that
   already contains `other`. If necessary, restructure setup/reset without
   timing construction that is meant to remain outside the measured operation.
3. Add lightweight result validation outside the timed region so a benchmark
   cannot silently measure an incorrect or no-op final state.
4. Re-run only the same bounded representative measurement set. Replace the raw
   result files and update `Maintanance/CombiningAPIPerformanceEvidence.md` if
   corrected methodology changes any conclusion.
5. Record the exact repository-local commands. Do not access external result or
   cache directories, and do not expand this into a larger benchmark campaign.

### Task 2 — Enable strict memory safety for the two warning-free facades

Permanently add `.strictMemorySafety()` only to the `AcCollections` and
`RedBlackTreeModule` targets identified as warning-free by
`Maintanance/StrictMemorySafetyReadiness.md`.

1. Make the smallest possible `Package.swift` change.
2. Build each affected target and the complete root package. Run the normal root
   test suite if the build succeeds.
3. Confirm these two targets still emit no strict-memory-safety diagnostics.
4. If either target produces a warning or error, revert that target's setting
   rather than changing production declarations or adding suppressions.
5. Update the readiness document and current maintenance status to distinguish
   this completed first adoption stage from the still-deferred low-level targets.

Do not enable the setting for `PermutationModule`, `BareArrayModule`,
`OptionalArrayModule`, or `RedBlackTreeCollections` in this task.

### Task 3 — Compact the Claude task handoff

`Maintanance/CLAUDE_TASK.md` has accumulated nearly one thousand lines of
completed assignments, which makes every session startup unnecessarily costly.

1. Move the completed assignment text and result summaries into
   `Maintanance/CLAUDE_TASK_HISTORY.md`, preserving their order and factual
   content.
2. Keep this file focused on the current status, active assignment, the latest
   concise result summary, and a link to the history file.
3. Do not rewrite or reinterpret historical decisions while moving them.
4. Keep the resulting active handoff short enough to scan at session startup.

Validation for all three tasks:

- Run the narrow benchmark/build/test commands required by the claims above.
- Run `git diff --check`.
- Confirm `Package.swift` contains the setting only for the two authorized
  facade targets.
- Change this status to `Completed` only when all three tasks are complete and
  add a concise result summary above the archived-history link.

## Result Summary

Completed Tasks 1–3 in order. Did not edit the paused outlines, start the C++
comparison target, or touch production meld / `erase(where:)` code. No commit.

**Task 1 (Combining benchmarks):** Confirmed from
`swift-collections-benchmark`'s `Task.measure` / `Timer._nestedMeasure` that the
setup closure runs once per size and the instance closure once per sample, with
only `timer.measure` timed — so no sample re-measured a destination already
containing `other`. Found a different flaw: the "with sorted/shuffled/
duplicate-heavy other" cases used `var a = base`, sharing storage with the
captured `base`, so insertion-loop timings included an unintended CoW copy.
Every case now builds a fresh destination per sample outside the timed region
(only "shared storage" cases share, intentionally). Shuffles use a fixed-seed
SplitMix64 via `shuffled(using:)`. Each sample validates `count`/`first`/`last`
with `precondition` after timing. Re-ran the same bounded set twice (raw files
hold the second run). Conclusions unchanged; updated tables, sorted/shuffled
ratios (merge ~6.0x, formUnion ~3.4x at 256k), and recorded that identical-code
cases differ ~1.5x at 16k, leaving the MultiSet `insert(contentsOf:)` reserve
effect at 16k (~1.6x) undetermined.

**Task 2 (strict memory safety, stage 1):** Added `.strictMemorySafety()` only
to `AcCollections` and `RedBlackTreeModule`. Verified via `-v` that both
modules compile with `-strict-memory-safety` and emit 0 diagnostics. Updated
`StrictMemorySafetyReadiness.md` (adoption-status table) and
`MAINTENANCE.md` (相談事項); the four low-level targets remain deferred.

**Task 3 (handoff compaction):** Moved all completed assignments and result
summaries verbatim, in order, to `Maintanance/CLAUDE_TASK_HISTORY.md`.

**Validation:**
- `swift build -c release` (in `Benchmarks/`) — succeeded.
- In `Benchmarks/`:
  `swift run -c release benchmark run --filter 'RedBlackTreeSet<Int> (merge|formUnion)' --sizes 1k 16k 256k --cycles 1 --mode replace-all Results/CombiningAPI/results-RedBlackTreeSet-combining.json`
  and
  `swift run -c release benchmark run --filter 'RedBlackTreeMultiSet<Int> (insert\(contentsOf:\)|meld)' --sizes 1k 16k 256k --cycles 1 --mode replace-all Results/CombiningAPI/results-RedBlackTreeMultiSet-combining.json`
  — each run twice, all validations passed.
- `swift build --target RedBlackTreeModule`, `swift build --target AcCollections`
  (forced recompile), `swift build` — succeeded, 0 warnings in the two targets.
- `swift test` (repository root) — all passed, 0 failures.
- `Package.swift` contains `.strictMemorySafety()` only for the two facades
  (the commented placeholder in `RedBlackTreeCollections` is unchanged).
- `git diff --check` — clean.

## History

Earlier assignments and result summaries:
[`CLAUDE_TASK_HISTORY.md`](CLAUDE_TASK_HISTORY.md).
