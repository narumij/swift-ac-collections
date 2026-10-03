# Codex-to-Claude Work Request

Status: Active — MultiSet C++ behavior-comparison expansion

## Objective

Extend the committed root-package C++ comparison foundation from
`RedBlackTreeSet`/`std::set` to one additional pair only:
`RedBlackTreeMultiSet<Int64>`/`std::multiset<int64_t>`.

The primary purpose is to establish whether hinted insertion, especially insertion
inside an equivalent-key group, has the same observable behavior. Communicate with
the user in Japanese.

## Baseline You Must Preserve

Before editing, read and understand these committed files completely:

- `Package.swift`
- `Sources/CppBehaviorReference/include/CppBehaviorReference.h`
- `Sources/CppBehaviorReference/CppBehaviorReference.cpp`
- `Tests/CppBehaviorReferenceTests/SetBehaviorComparisonTests.swift`
- `Maintanance/CPP_BEHAVIOR_COMPARISON_TASK.md`

Run the existing `CppBehaviorReferenceTests` first. If the three committed Set tests
do not pass, stop and report the baseline failure; do not work around it.

## Authorized Changes

You may edit only:

- `Sources/CppBehaviorReference/`
- `Tests/CppBehaviorReferenceTests/`
- this file, for the final status and a concise result summary
- `Maintanance/CPP_BEHAVIOR_COMPARISON_TASK.md`, but only to record verified
  MultiSet results or a discovered semantic difference

Do not edit `Package.swift` unless the existing targets genuinely cannot contain the
MultiSet work. If that happens, stop and ask the user instead of changing it.

## Required Comparison

Reuse the established trace/observation architecture. Add a separate MultiSet
executor or a clearly separated container mode; do not weaken or rewrite the working
Set comparison merely to share code.

The curated MultiSet trace must cover:

1. insertion of distinct and duplicate values;
2. `lowerBound`, `upperBound`, and the observable contents of `equalRange`;
3. erasing by key, including the number of equivalent elements removed;
4. hinted insertion with:
   - an exact hint;
   - a deliberately poor but valid hint;
   - `endIndex`;
   - a hint before, within, and after an existing equivalent-key group.

Transport a hint across the C ABI only as its current zero-based rank. Resolve that
rank independently to a Swift `Index` and C++ iterator immediately before the
operation. Never transport iterators, pointers, or Swift indices across the boundary.

After every operation, compare the complete ordered contents. Compare returned facts
only where both APIs expose a meaningful equivalent. A test must also prove that a
MultiSet mismatch report includes the container pair, operation number, input,
Swift observation, and C++ observation.

## Critical Stop Conditions

- If equivalent elements carry no identity and the claimed within-group ordering
  cannot be observed with `Int64` values, do not claim that ordering was verified.
  Report the limitation and propose the smallest value representation that would make
  it observable; do not introduce that representation without user approval.
- If Swift and C++ differ, preserve the smallest deterministic failing trace and stop.
  Do not modify `RedBlackTreeMultiSet` production code, public API, or documentation
  to force agreement.
- Do not expand to Dictionary, MultiMap, randomized traces, fuzzing, benchmarks, CI,
  workflows, compatibility mode, or performance measurements.
- Do not touch `Benchmarks/`, `CppBenchmarks`, unrelated tests, `TESTING.md`, or
  `MAINTENANCE.md`.
- Do not create scratch files in the repository. Do not commit or push.

## Validation

Run exactly the focused root-package suite first:

```sh
swift test --disable-sandbox --filter CppBehaviorReferenceTests
```

If it passes, run `git diff --check`. Do not run the full 1,400+ test suite unless the
focused build reveals a cross-target problem requiring it.

Inspect the final diff and verify that no file outside the authorized list changed.
Do not substitute prose about residual risk for a required check that is available.

## Completion Report

Change the status to `Completed` only if the focused suite and `git diff --check`
both pass. Add no chronological diary or accountability section. The result summary
must contain only:

- behaviors actually compared;
- test count and result;
- changed files;
- any real semantic difference or explicitly unobservable claim.

If a stop condition is reached, change the status to `Blocked` and report the exact
minimal trace and evidence without editing production code.

## History

Earlier assignments and result summaries:
[`CLAUDE_TASK_HISTORY.md`](CLAUDE_TASK_HISTORY.md).
