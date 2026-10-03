# Codex-to-Claude Work Request

Status: Active — Validate and reduce Permutation bounds-check overhead

## Active Follow-up Assignment

Complete these three bounded tasks in order. Communicate with the user in
Japanese. Work only inside the repository. Before completing this assignment,
archive the previous completed result below in `CLAUDE_TASK_HISTORY.md`.

Do not edit the four paused collection outlines,
`Maintanance/REFACTORING_FROM_ATCODER_2025.md`, red-black-tree production code,
the deferred C++ comparison target, or unrelated documentation. Do not begin
strict-memory-safety batch 2. Do not commit or push.

### Task 1 — Audit the subscript microbenchmark result

The initial valid-access benchmark reports roughly 25–70% overhead after adding
the public bounds precondition. Determine whether this is reproducible rather
than accepting or dismissing it as noise.

1. Review the benchmark for equal work, optimizer resistance, deterministic
   input, and correct use of the benchmark timer.
2. Perform a reversible, interleaved A/B/A comparison of the unchecked original
   subscript and the current checked subscript in Release mode. Use identical
   commands, sizes, cycle counts, and a freshly rebuilt product for every code
   state. Restore the checked production implementation afterward.
3. Keep raw results under `Benchmarks/Results/PermutationSubscript/` with names
   that distinguish this validation from the first run.
4. If methodology is flawed, correct the benchmark and repeat both sides. Do not
   tune the benchmark merely to make the overhead smaller.

### Task 2 — Measure practical permutation-workload impact

Add one bounded end-to-end benchmark that generates and consumes permutations
through the public API, validating the result outside the timed region. Measure
the same unchecked/checked A/B/A states used in Task 1.

The purpose is to distinguish the isolated per-access cost from its effect on a
real permutation workload. Do not add another public API, another permutation
implementation, or an unbounded factorial benchmark. Record exact inputs,
commands, and limitations.

### Task 3 — Try a single-comparison bounds check as a reversible PoC

Investigate whether the two comparisons can be replaced by an equivalent
single unsigned-range comparison that rejects negative indices and indices at or
beyond `endIndex`.

1. First prove the candidate expression handles `Int.min`, `-1`, `0`, the last
   valid index, `endIndex`, and `Int.max` correctly without conversion traps.
2. Apply it temporarily, run all existing valid-boundary and exit tests, and
   repeat the Task 1 and Task 2 benchmarks with identical settings.
3. Retain the candidate only if it is equally clear, preserves normal
   precondition failure for every invalid case, and shows a repeatable benefit.
   Otherwise restore the current two-comparison check.
4. Do not remove the bounds check. Do not move it into the internal `Buffer`
   subscript or change permutation-generation algorithms.

Validation and handoff:

- Run focused Permutation tests in Debug and Release, compatibility-mode
  Permutation and AcCollections tests, a normal build, and `git diff --check`.
- Confirm every temporary production/manifest edit is restored except a
  single-comparison check that satisfies all Task 3 retention conditions.
- Update `ProductReadinessAssessment.md` with the reproducible microbenchmark,
  end-to-end result, and final recommendation. Keep raw machine data out of the
  public API documentation.
- Report which bounds-check form remains and why. Do not commit or push.

## Previous Completed Result (archive before completing this assignment)

- Added deterministic sequential and shuffled public-subscript benchmarks with
  raw before/after data.
- Added exit tests for `endIndex`, `-1`, and `endIndex + 1`; before the fix they
  exited successfully with unspecified reads, and after the fix all terminate
  with SIGTRAP.
- Added a two-comparison precondition only to public
  `SubSequenceN.subscript(position:)` and retained a valid-boundary test.
- Initial microbenchmarks reported material overhead; after-runs varied by
  10–15%, so the result requires the validation assigned above.
- Temporary strict checking remained at 14 unique diagnostics in G2–G6 and
  `Package.swift` was restored. Focused normal, Release, and compatibility tests,
  normal build, and `git diff --check` succeeded.

## History

Earlier assignments and result summaries:
[`CLAUDE_TASK_HISTORY.md`](CLAUDE_TASK_HISTORY.md).
