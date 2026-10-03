# Codex-to-Claude Work Request

Status: Active — API-matrix reconciliation and two small Permutation safety steps

## Active Follow-up Assignment

Complete these three bounded tasks in order. Communicate with the user in
Japanese. Work only inside the repository. Do not edit any of the four paused
type outlines, start the deferred C++ comparison target, change red-black-tree
production algorithms, commit, or push.

### Task 1 — Reconcile the current API matrices with production source

Recent outline review found stale MultiMap facts in the API reference material:
the current key subscript returns `RedBlackTreeMappedValuesView`, the current
initializer is `init(keysWithValues:)`, and the current hint API is
`insert(_:hint:)`; older alternatives survive only as commented or deprecated
code.

1. Review `Sources/RedBlackTreeCollections/Documentation/API-Matrix.md` and
   `API-Matrix-View.md` against the current non-compatibility production source
   for Set, Dictionary, MultiSet, and MultiMap.
2. Correct stale names, return types, availability, and brief semantics. Pay
   special attention to key subscripts, range subscripts, initializers, hint
   APIs, `update` APIs, and the distinction between mapped-values views and
   key-value range views.
3. Keep `AtCoder2025_compatibility_api_matrix.md` historical unless a statement
   about the current API is demonstrably wrong; do not erase compatibility
   history.
4. Do not add aspirational APIs or copy deprecated aliases into the current API
   columns. Do not edit the paused outlines.
5. Record a concise list of corrected stale entries in the result summary.

### Task 2 — Implement only Permutation strict-memory-safety batch 1

Apply the smallest planned experiment from
`Maintanance/StrictMemorySafetyReadiness.md` §8: add the scoped `unsafe`
marking required by `Permutations.Buffer.deinit` only.

1. Temporarily enable `.strictMemorySafety()` for `PermutationModule` and
   verify that the unique diagnostics decrease from 17 to 14, with no new
   category of warning or error.
2. Restore `Package.swift` afterward; do not permanently enable the setting.
3. Keep the production change limited to `deinit`. Do not proceed to G2–G6,
   redesign pointer helpers, change Sendable conformances, or add suppressions.
4. Run `PermutationTests`, the relevant compatibility-mode validation, and a
   normal build. Update the readiness document with the observed result.
5. If the toolchain syntax does not work exactly as planned, revert the
   production edit and report the blocker instead of broadening the change.

### Task 3 — Characterize the public permutation subscript boundary safely

Investigate the concern that public `SubSequenceN.subscript(position:)` reaches
an unchecked pointer subscript.

1. Confirm the applicable Collection index contract and existing repository
   death-test conventions.
2. In a subprocess only, characterize access at `endIndex`, a negative-equivalent
   index if constructible through public API, and an index beyond `endIndex`.
   Never perform potentially undefined access in the test runner process.
3. If current behavior reliably terminates without SIGSEGV, add a focused death
   test that preserves that contract. If it succeeds, is nondeterministic, or
   terminates through memory corruption/SIGSEGV, do not add a misleading passing
   test; record the evidence and propose the smallest fix for user review.
4. Do not implement the subscript fix in this assignment.

Validation and handoff:

- Run `git diff --check` and the narrow builds/tests required above.
- Confirm every temporary manifest edit is restored to the stage-1 strict-
  memory-safety state.
- Before marking this assignment completed, archive the preceding completed
  assignment and summary in `CLAUDE_TASK_HISTORY.md`, keeping this file concise.
- Do not commit or push.

## Latest Follow-up Assignment (completed)

Complete these three bounded tasks in order. Communicate with the user in
Japanese. Work only inside the repository. Do not edit the paused Set,
Dictionary, or MultiSet outlines. Do not start the deferred C++ comparison
target, change `erase(where:)`, commit, or push.

### Task 1 — Remove the unsupported capacity recommendation

The evidence in `Maintanance/CombiningAPIPerformanceEvidence.md` shows that the
existing “If sufficient space is available” recommendation does not describe
the implementation and is not supported by the measurements.

1. Locate every current public documentation comment that makes this
   recommendation for `union` / `formUnion`, `meld` / `melding`, or the related
   insertion-loop APIs in Set, MultiSet, and MultiMap.
2. Remove the unsupported capacity-based recommendation everywhere it appears.
3. Replace it only with concise, stable facts already guaranteed by the API and
   implementation, such as the documented complexity and whether the operation
   mutates the receiver or returns a new collection. Do not put benchmark
   thresholds, machine-specific timing, speculative allocator explanations, or
   a new universal recommendation into public API comments.
4. Keep Dictionary comments unchanged unless the unsupported sentence actually
   exists there. Do not edit the paused outlines or generated Head drafts.
5. Add or adjust documentation tests only if the repository already has a
   suitable mechanism; do not create a new documentation-test framework.

### Task 2 — Measure the `___meld_unique` capacity asymmetry as a reversible PoC

Determine whether preallocating `count + other.count` in `___meld_unique`, as
`___meld_multi` already does, materially changes Set `union` / `formUnion`
performance.

1. Identify the smallest production-code change needed for a PoC.
2. Run the existing bounded deterministic Set combining benchmarks before and
   after that temporary change, using identical commands and inputs.
3. Validate results and record raw PoC data under a clearly named repository-
   local benchmark results directory.
4. Restore the production source exactly after measuring. This task is evidence
   gathering only; do not leave the optimization applied.
5. Record the patch shape, commands, results, noise limitations, and a clear
   recommendation in `Maintanance/CombiningAPIPerformanceEvidence.md` or a
   concise linked companion note.

Do not broaden the PoC into allocator, tree-layout, or insertion-algorithm
changes.

### Task 3 — Produce an actionable strict-memory-safety plan for PermutationModule

Use the existing 34-diagnostic audit as the starting point. Do not enable
`.strictMemorySafety()` for `PermutationModule` and do not change production
code in this task.

1. Reproduce the diagnostics for `PermutationModule` with a temporary manifest
   edit, then restore `Package.swift` to the stage-1 adopted state.
2. Group diagnostics by declaration and ownership boundary rather than merely
   by compiler message text.
3. For each group, identify the smallest likely remediation (`unsafe`
   declaration/conformance, scoped unsafe use, API redesign, or no safe local
   fix) and explain why.
4. Propose small reviewable implementation batches, with the first batch no
   larger than necessary to validate the approach.
5. Update `Maintanance/StrictMemorySafetyReadiness.md` with the plan, but do not
   add annotations, suppressions, or concurrency changes yet.

Validation and handoff:

- Run only the builds, tests, and bounded benchmarks required for factual
  claims.
- Run `git diff --check` and confirm temporary source/manifest edits are fully
  restored.
- Before marking this assignment completed, move the current completed
  assignment and its result summary into `CLAUDE_TASK_HISTORY.md`. Keep this
  file limited to the newest assignment, newest concise result summary, and the
  history link.
- Do not commit or push.

## Result Summary

Completed Tasks 1–3 in order. Did not edit any outline, start the C++
comparison target, touch `erase(where:)`, or address the other pending
decisions. No commit or push.

**Task 1 (documentation):** Removed all six unsupported
`- Important: If sufficient space (complexity) is available, using … is
recommended.` notes: Set `merge(_: RedBlackTreeSet)` / `merging(_:
RedBlackTreeSet)`, MultiSet `insert(contentsOf: RedBlackTreeSet)` /
`inserting(contentsOf: RedBlackTreeMultiSet)`, MultiMap `insert(contentsOf:)` /
`inserting(contentsOf:)` (`*+Combining.swift`). The remaining comments already
state complexity and non-mutation, so no replacement sentence was added.
Dictionary had no such sentence. No documentation-test mechanism exists, so no
test was added.

**Task 2 (`___meld_unique` PoC):** Temporarily changed the result buffer from
`minimumCapacity: 2` to `count + other.count` (one line), measured the 14
deterministic Set combining cases (7 `formUnion` + 7 `merge` controls) before
and after, twice each with `--cycles 10`, then restored the source exactly
(`git diff` empty; the post-restore release rebuild confirmed the PoC had been
compiled). `formUnion` after/before ratios were 0.96–1.04, inside the
0.97–1.04 range of the unaffected `merge` controls. Recommendation: do not adopt
it for performance; growth appends buckets without moving nodes
(`Design-NodeStorage.md`). Raw data: `Benchmarks/Results/MeldUniqueCapacityPoC/`;
write-up: `CombiningAPIPerformanceEvidence.md` §4.

**Task 3 (PermutationModule plan):** Reproduced the diagnostics with a
temporary manifest edit and then restored the manifest (`git diff Package.swift`
empty). Found 34 warning lines, which are 17 unique diagnostics printed twice;
all are `Buffer`-internal expression warnings, with no conformance, storage, or
public-signature diagnostics. Grouped them into G1–G6 by declaration and
ownership boundary, proposed four batches (batch 1: scoped `unsafe` in `deinit`
only), and recorded the plan in `StrictMemorySafetyReadiness.md` §8. Concerns
for the user: the public `SubSequenceN[position]` reaches an unchecked pointer
subscript (code reading), `copy(newCapacity:)` does not check
`newCapacity >= count`, and `unsafeDowncast` is used on a non-final class.

**Validation:** `swift build` succeeded. In `Benchmarks/`, the run command was
`swift run -c release benchmark run --filter 'RedBlackTreeSet<Int>
(merge|formUnion)(,| with (sorted|shuffled|duplicate-heavy))' --sizes 1k 16k
256k --cycles 10 --mode replace-all Results/MeldUniqueCapacityPoC/<before|after>-run<1|2>.json`;
all post-timing validations passed. `swift build --target PermutationModule` was
run with the temporary setting. `git diff --check` is clean. Only comment
lines changed in Sources, so `swift test` was not run.

## History

Earlier assignments and result summaries:
[`CLAUDE_TASK_HISTORY.md`](CLAUDE_TASK_HISTORY.md).
