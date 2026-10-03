# Codex-to-Claude Work Request

Status: Completed — Small cleanup and Sendable handoff only

## Active Follow-up Assignment

The remaining session budget is about 10%. Complete only these two small tasks.
Communicate with the user in Japanese. Work only inside the repository. Do not
start another benchmark run, production implementation, broad test run, strict-
memory-safety batch, or unrelated cleanup. Do not commit or push.

Before completing, archive the preceding completed result below in
`CLAUDE_TASK_HISTORY.md`.

### Task 1 — Audit scratch-file hygiene

1. Follow the corrected root `CLAUDE.md` rule: disposable scratch files must use
   a uniquely named, task-owned system temporary directory and must not be placed
   anywhere inside the repository. Remove the task-owned directory before
   reporting.
2. Inspect only the repository's current Git status. Distinguish intentional
   retained benchmark evidence/source from disposable files created during your
   experiments.
3. Remove only disposable scratch files that you created and can identify with
   certainty. Do not delete or move user files, benchmark evidence, test
   fixtures, or any ambiguous untracked file.
4. Report the exact repository paths removed, or state that none remain. Do not
   inspect unrelated external paths or neighboring system-temporary contents.

### Task 2 — Prepare the next Permutation `Sendable` task

The user has decided that Swift 6+ `Sendable` support is required; this is no
longer a question of whether to support it. Perform a small read-only source
audit and write a concise implementation handoff in
`Maintanance/StrictMemorySafetyReadiness.md`.

1. List the public Permutation types and conformances that need `Sendable`
   consideration, including generic constraints and stored reference types.
2. Separate conformances that appear mechanically safe from those requiring an
   ownership or mutation decision. Do not add `@unchecked Sendable` merely to
   silence diagnostics.
3. Propose the smallest ordered implementation batches and focused tests for a
   future session. Do not change production Swift code, `Package.swift`, or tests
   in this assignment.
4. Keep the addition concise. If existing documentation already answers a point,
   link to it rather than repeating it.

Validation and handoff:

- Run `git diff --check` only; no build or test run is required for this
  documentation-only follow-up.
- Confirm no disposable files from this assignment remain inside the repository
  or in its task-owned system temporary directory.
- Mark the assignment completed and summarize the Sendable batches and scratch
  cleanup in Japanese. Do not commit or push.

## Completed Result (2026-10-03, Claude Opus 5.5)

- Task 1: `git status` was clean; no disposable files remained and nothing was
  removed. No temporary directory was created.
- Task 2: Added a read-only Sendable handoff as §9 of
  `StrictMemorySafetyReadiness.md`. `Nexts` (and the uninhabited
  `Permutations`) are mechanical; `IteratorN`/`SubSequenceN` share a mutable
  `Buffer` via CoW and need an ownership decision before
  `@unchecked Sendable where C.Element: Sendable`. Proposed batches: Nexts →
  `final Buffer` → iterator/subsequence with a cross-task test.
- Only `git diff --check` was run. Previous result archived in
  `CLAUDE_TASK_HISTORY.md`. No commit or push.

## History

Earlier assignments and result summaries:
[`CLAUDE_TASK_HISTORY.md`](CLAUDE_TASK_HISTORY.md).
