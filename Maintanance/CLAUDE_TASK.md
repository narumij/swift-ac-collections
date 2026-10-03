# Codex-to-Claude Work Request

Status: Completed — Two small documentation checks

## Result Summary (2026-10-03, Claude Opus 5.5)

- Task 1: Replaced the stale "Sendable 要否" pending item in `Tests/TESTING.md`
  with the settled Swift 6+ decision, the implemented and validated first batch
  (`Permutations`, `Nexts where C: Sendable`, compile-time test), and the
  separate future `IteratorN`/`SubSequenceN` batch. No other dashboard changes.
- Task 2: No correction needed. Against `remotes/origin/release/AtCoder/2025`
  (`b2580703`): the old-only public list matches (the `All` inits are covered by
  `Permutations.All`; the last bullet names `@usableFromInline` internals, not
  public declarations); `NextPermutationProtocol.swift` has no diff; the define
  is still a commented-out entry in the shared `_settings`, is not a trait, and
  is referenced only by `AcCollections`, not `PermutationModule`; no
  `Compatibility/` directory exists, so nothing listed as not done is done.
- Validation: `git diff --check` only.

## Active Assignment

The remaining session budget is small. Complete only these two bounded tasks in
order. Communicate with the user in Japanese. Do not modify production Swift,
tests, `Package.swift`, benchmarks, workflows, or paused documentation outlines.
Do not run a build or test suite. Do not commit or push.

Preserve all unrelated user and Codex changes. Disposable scratch files must use
a uniquely named task-owned system temporary directory outside the repository;
prefer not to create any for this assignment.

### Task 1 — Reconcile the Permutation Sendable dashboard status

Read the current implementation, focused compile-time test, and these documents:

- `Sources/PermutationModule/Permutations.swift`
- `Tests/PermutationTests/PermutationTests.swift`
- `Maintanance/StrictMemorySafetyReadiness.md`
- `Maintanance/PermutationModule/ImplementationPlan.md`
- `Tests/TESTING.md`

Update only stale current-state wording in `Tests/TESTING.md`. The decision to
support Sendable on Swift 6+ is settled, and the mechanical first batch
(`Permutations` and `Nexts where C: Sendable`) plus its compile-time test is
already implemented and validated. `IteratorN` and `SubSequenceN` remain a
separate ownership-sensitive future batch. Do not claim the entire Sendable
effort is complete.

### Task 2 — Fact-check the AtCoder 2025 compatibility plan

Perform a read-only review of
`Maintanance/PermutationModule/AtCoder2025CompatibilityPlan.md` against the
current tree and the locally available `release/AtCoder/2025` ref. Check only:

1. the listed old-only public declarations;
2. the claim that `NextPermutationProtocol.swift` is shared unchanged;
3. the proposed same-module, compile-time switch boundary;
4. whether any statement incorrectly describes already-implemented work.

Correct the plan only when a factual mismatch is directly demonstrated. Do not
implement compatibility mode, add a package trait, restore old source, or expand
the plan with new design alternatives. If no correction is needed, leave it
unchanged and report that result.

## Validation and Handoff

- Run `git diff --check` only.
- Change the status above to `Completed` and add a concise result summary.
- Report changed files and factual findings in Japanese.
- Do not rewrite `Tests/TESTING.md` beyond the stale Sendable status identified
  in Task 1.

## History

Earlier assignments and result summaries:
[`CLAUDE_TASK_HISTORY.md`](CLAUDE_TASK_HISTORY.md).
