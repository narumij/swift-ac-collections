# Codex-to-Claude Work Request

Status: Active — Permutation boundary fix with measured overhead

## Active Follow-up Assignment

Complete these three bounded tasks in order. Communicate with the user in
Japanese. Work only inside the repository. Before starting, archive the previous
completed assignment and result summary below in `CLAUDE_TASK_HISTORY.md`.

Do not edit the four paused collection outlines,
`Maintanance/REFACTORING_FROM_ATCODER_2025.md`, red-black-tree production code,
the deferred C++ comparison target, or unrelated documentation. Do not commit or
push.

### Task 1 — Add a bounded Permutation element-access benchmark

Create the smallest benchmark coverage needed to measure the cost of public
`SubSequenceN.subscript(position:)` element access before changing it.

1. Follow the existing benchmark package and naming conventions. Do not create a
   second benchmark harness or a new implementation variant.
2. Measure repeated valid indexed access through the public API in Release mode.
   Keep inputs and iteration counts bounded and deterministic, and consume or
   validate the result so the optimizer cannot remove the work.
3. Record the exact command and baseline result in the existing Permutation
   readiness or implementation-plan document. Do not generalize from a single
   machine measurement.
4. Do not benchmark undefined out-of-range access.

### Task 2 — Make the public permutation subscript trap on invalid indices

Implement the smallest fix proposed by the completed investigation.

1. Add subprocess/exit tests first for `endIndex`, `-1`, and `endIndex + 1`.
   Confirm the tests fail against the unmodified implementation because those
   accesses currently return unspecified memory rather than terminate.
2. Add a precondition only to public `SubSequenceN.subscript(position:)`:
   `position >= startIndex && position < endIndex`. Do not add checks to the
   internal `Buffer` subscript or alter permutation generation algorithms.
3. Confirm all three exit tests then terminate through a normal precondition
   failure, not SIGSEGV. Also retain a focused valid-boundary test.
4. Re-run the Task 1 Release benchmark with the identical command and inputs.
   Report the before/after values and noise limitation; do not remove the safety
   check solely because of a small measured overhead.
5. Update the specification/readiness text so invalid collection indices are
   documented as a precondition violation, without presenting the old undefined
   behavior as a supported contract.

### Task 3 — Re-audit strict-memory-safety diagnostics after the fix

Temporarily enable `.strictMemorySafety()` for `PermutationModule`, reproduce the
remaining unique diagnostics, and restore `Package.swift` afterward.

1. Verify whether the count remains 14 and whether categories G2–G6 are
   unchanged after Tasks 1–2.
2. Update `StrictMemorySafetyReadiness.md` with only the observed result and the
   completed boundary fix.
3. Do not implement strict-memory-safety batch 2, change `__header_ptr` or
   `__storage_ptr`, add Sendable conformances, make `Buffer` final, or change
   `copy(newCapacity:)` in this assignment.

Validation and handoff:

- Run the focused Permutation tests in normal and Release configurations, the
  relevant `COMPATIBLE_ATCODER_2025` validation, a normal `swift build`, and
  `git diff --check`.
- Confirm all temporary manifest edits are restored.
- Keep the final result summary concise and include changed files, test counts,
  benchmark before/after values, and the strict diagnostic count.
- Do not commit or push.

## Previous Completed Result (archive before completing this assignment)

- Reconciled `API-Matrix.md` and `API-Matrix-View.md` with current production
  APIs, including MultiMap mapped-values versus key-value range views.
- Added scoped `unsafe` only to the three expressions in
  `Permutations.Buffer.deinit`; temporary strict checking reduced unique
  diagnostics from 17 to 14, with `Package.swift` restored.
- Characterized public `SubSequenceN` invalid index access in child processes:
  nearby invalid indices returned configuration-dependent garbage and a distant
  index caused SIGSEGV. No misleading death test was retained.
- Normal build, focused normal/compatibility tests, and `git diff --check`
  succeeded. No commit or push was performed.

## History

Earlier assignments and result summaries:
[`CLAUDE_TASK_HISTORY.md`](CLAUDE_TASK_HISTORY.md).
