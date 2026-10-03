# Codex-to-Claude Work Request History

Completed assignments and result summaries moved verbatim from
`Maintanance/CLAUDE_TASK.md` on 2026-10-03. Entries are kept in their original
order (newest first). Headings such as "Active" or "above" refer to their
position in the original file at the time they were written.

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

## Result Summary (three follow-up investigations)

Completed all three tasks in the user-recommended order: Task 3, Task 1, Task 2.
Did not edit the paused RedBlackTreeSet outline or the RedBlackTreeDictionary
outline Codex was concurrently editing, and did not start the deferred C++
comparison target or the unrelated `erase(where:)` CoW issue.

**Task 3 (stale maintenance status reconciliation):** Removed the
`TreeFoundamentalAllocationTests`のASan調査 and `PermutationModule改修管理`
entries from `MAINTENANCE.md`'s `優先事項` and recorded them as completed in
`完了済みの要望`, with a concise cause/result note for the ASan case (root
cause was test-counter contamination from `AcCollectionsTests` lacking
`RedBlackTreeCollections`の寿命カウンタ discipline after
`TreeFoundamentalAllocationTests`'s macOS-only guard was widened to
`#if DEBUG`, not a real memory-safety bug; fixed in commits `c62a633b`/
`9add0d5d`/`8bc7c3ba`/`60efef09`). Confirmed locally
(`swift test --filter TreeFoundamentalAllocationTests` 5/5,
`AcCollectionsTests` 3/3) since this session has no GitHub Actions access.
Confirmed all four Codable non-sorted/duplicate-input regression tests exist
and pass (`RedBlackTreeDictionaryCodableTests`,`RedBlackTreeSetCodableTests`,
`RedBlackTreeMultiSetCodableTests`,`RedBlackTreeMultiMapCodableTests`; 14
tests, 0 failures) — no stale pending item referenced this as missing.
Confirmed `Tests/TESTING.md` already represents the PermutationModule and
`unranged()` removals as completed.

**Task 1 (strictMemorySafety readiness audit):** Temporarily applied
`.strictMemorySafety()` to `RedBlackTreeCollections`, `AcCollections`,
`RedBlackTreeModule`, `PermutationModule`, `OptionalArrayModule`, and
`BareArrayModule`; collected and classified diagnostics by target/file/category
in `Maintanance/StrictMemorySafetyReadiness.md`. All targets built with 0
errors. `AcCollections`と`RedBlackTreeModule`は警告0件で即時適用可能。
`PermutationModule`(34)/`BareArrayModule`(116)/`OptionalArrayModule`(144)/
`RedBlackTreeCollections`(4,948)はいずれも意図的な生ポインタ・手動メモリ管理
コード由来の警告で、機械的に直せる「ふつうの宣言」由来の警告は見つからなかった。
段階的採用順を提案。Restored `Package.swift` exactly
(`git diff Package.swift` empty). No annotations, concurrency semantics, or
diagnostic suppressions were added.

**Task 2 (Combining API evidence gap):** Traced `merge`/`merging`/
`insert(contentsOf:)`/`inserting(contentsOf:)`(O(*n* log(*m+n*)), via
`___insert_range_unique`/`___insert_range_multi`) against `union`/`formUnion`/
`meld`/`melding`(O(*n*+*m*), via `___meld_unique`/`___meld_multi`) for
Set/MultiSet/MultiMap(Dictionaryにはmeld系の代替が存在しない)。Found that
`___meld_unique`(Setのmeld経路)はcapacity 2から都度拡張するのに対し
`___meld_multi`(MultiSet/MultiMap)は`count+other.count`を事前確保する非対称性
を発見。Added 19 Set + 8 MultiSet benchmark cases to
`Benchmarks/Sources/Benchmarks/CombiningAPIBenchmarks.swift`(reusing the
existing `swift-collections-benchmark`harness)and ran a bounded measurement
(sizes 1k/16k/256k, cycles 1, <4s total)。Raw results saved to
`Benchmarks/Results/CombiningAPI/`。Found: (a) `reserveCapacity`has no measurable
effect on either path(meld系は呼び出し元の容量を参照しないため); (b) at
1k–256k the insertion-loop path was consistently faster than the meld path;
(c) `other`'s construction order(sorted literal vs shuffled insertion)caused a
2–6x difference, larger than anything the capacity axis explains; (d) shared
destination storage costs the insertion-loop path an extra CoW copy but does
not affect the meld path. Recorded full evidence, conclusions, and a proposed
conditional-wording direction (not applied to public docs) in
`Maintanance/CombiningAPIPerformanceEvidence.md`, and flagged the
`___meld_unique`missing-upfront-capacity asymmetry as a separate suspected
performance defect for future consideration (not fixed in this task).

**Validation (all three tasks):**
- `swift test --filter TreeFoundamentalAllocationTests` — 5/5 passed.
- `swift test --filter 'RedBlackTreeDictionaryCodableTests|RedBlackTreeSetCodableTests|RedBlackTreeMultiSetCodableTests|RedBlackTreeMultiMapCodableTests'` — 14/14 passed.
- `swift build --target RedBlackTreeCollections` and `swift build`(全ターゲット)with
  `.strictMemorySafety()`temporarily applied — succeeded, 0 errors.
- `swift build -c release`(Benchmarks package, with the new benchmark file) — succeeded.
- `swift run -c release benchmark run`(bounded, sizes 1k/16k/256k, cycles 1) —
  succeeded for Set and MultiSet combining benchmarks.
- `swift test`(repository root, normal mode) — full suite passed, no failures.
- `git diff --check` — clean.
- `git diff Package.swift` — empty (restored).

Reported to the user in Japanese.

## Previous Active Follow-up Assignment (now completed, see Result Summary above)

Complete these three bounded tasks in order. Communicate with the user in
Japanese. Do not edit the paused RedBlackTreeSet outline. Do not start the C++
behavior-comparison target, which the user explicitly deferred.

### Task 1 — Audit readiness for strict memory safety

The user wants to move toward `.strictMemorySafety()`. Perform a readiness
audit only; do not permanently enable the setting in this task.

1. Confirm the exact SwiftPM setting supported by the repository's current
   tools version and toolchain using authoritative documentation/tool output.
2. Temporarily apply it to the smallest relevant target, then to the package
   targets where practical, and collect every compiler diagnostic by target,
   file, and category.
3. Separate diagnostics caused by intentional low-level pointer/storage code
   from ordinary declarations that can be fixed mechanically.
4. Propose a staged adoption order with small reviewable batches. Identify any
   target that can enable the setting immediately without production changes.
5. Restore `Package.swift` exactly before finishing. Record commands, results,
   and recommendations in a concise maintenance document and update
   `Maintanance/MAINTENANCE.md` without claiming adoption is complete.

Do not add annotations, change concurrency semantics, or suppress diagnostics
as part of this audit.

### Task 2 — Resolve the evidence gap behind Combining API recommendations

Investigate the existing documentation recommendation around incremental
insertion versus `union` / `formUnion` / `merge` / `merging` / `meld` /
`melding`. The current "sufficient capacity" wording lacks evidence.

1. Trace the actual implementation paths and documented complexity for the
   corresponding Set, MultiSet, Dictionary, and MultiMap operations.
2. Reuse the benchmark package and existing benchmark conventions. Add only
   focused benchmark cases needed to compare representative input sizes,
   already-sorted versus shuffled input, unique versus duplicate-heavy input,
   reserved versus unreserved destination capacity, and unique versus shared
   storage where applicable.
3. Run a small, reproducible measurement set sufficient to reveal trends; do
   not launch an unbounded benchmark campaign.
4. Record commands, environment, raw result location, and evidence-backed
   conclusions in a concise maintenance document.
5. Do not rewrite the public recommendation yet. If results do not support one
   simple rule, say so and propose accurate conditional wording for user
   review.

Do not optimize production code during this task. Report any suspected
performance defect separately.

### Task 3 — Reconcile stale maintenance status

Review only the current-state sections of `Maintanance/MAINTENANCE.md` and
`Tests/TESTING.md` against the repository and recent completed work.

- Mark the Linux ASan investigation resolved now that CI passes, preserving a
  concise cause/result record rather than deleting the history.
- Confirm the four Codable non-sorted/duplicate-input regression tests and the
  corresponding implementation fix already exist; remove any current pending
  item that still claims this work is missing.
- Confirm the PermutationModule and `unranged()` removals are represented as
  completed, not pending.
- Preserve user-written future requests, the deferred C++ target, open design
  questions, and historical reference logs.
- Keep `Current handoff` within its documented size limit instead of appending
  another long chronology.

Validation for all three tasks:

- Run the narrow builds/tests needed for factual claims.
- Restore every temporary manifest/configuration edit.
- Run `git diff --check`.
- Change this status to `Completed` only after all three tasks are complete and
  add a concise result summary above the earlier completed assignments.

## Previous Result Summary (completed follow-up)

Completed all three tasks below.

**Task 1:** Removed `Tests/PermutationTests/NextPermutation.swift` (test-only
`NextPermutation` protocol, `Array` conformance, `NextPermutationUnsafeHandle`,
and its duplicate algorithm) and the `testPerformance00` test that was its only
caller, from `Tests/PermutationTests/PermutationTests.swift`. Confirmed via
repository-wide grep that nothing else referenced
`NextPermutationUnsafeHandle`, the test-only `NextPermutation` protocol, or
`forEach_nextPermutation`. Updated `Maintanance/PermutationModule/
ImplementationPlan.md`, `ProductReadinessAssessment.md`,
`Sources/PermutationModule/Documentation/Specification.md`, and
`Tests/TESTING.md` to record this as completed rather than a pending decision.

**Task 2:** Added an English doc comment to `nextPermutations()` documenting
the tested contract (current order first, only lexicographic successors
afterward, no duplicate value orderings for equal elements, single-pass
termination for descending/all-equal/single-element/empty input, stability of
previously yielded results, worst-case O(n) per step), and brief doc comments
to `Permutations.Nexts`, `Permutations.IteratorN`, and `Permutations.SubSequenceN`.
No `ManagedBuffer`/implementation detail was added to the public comments.

**Task 3:** Added two `Removed` entries to `CHANGELOG.md`'s `[Unreleased]`
section: the PermutationModule full-permutation/unsafe API removal (leaving
`nextPermutations()` as the sole entry point) and the Range View `unranged()` /
`ScalarBaseInit` / `KeyValueBaseInit` removal. No other section was changed.

**Validation:**
- `swift test --filter PermutationTests` — 2/2 passed (post-removal).
- `swift build` — succeeded with the new doc comments.
- `swift test` from the repository root (normal mode) — full suite passed,
  0 failures across all suites.
- Temporarily uncommented `.define("COMPATIBLE_ATCODER_2025")`, ran
  `swift build` and `swift test --filter 'AcCollectionsTests|PermutationTests'`
  — both succeeded, then restored `Package.swift` (`git diff Package.swift`
  empty).
- Repository-wide grep for `NextPermutationUnsafeHandle`,
  `forEach_nextPermutation`, `testPerformance00`, and the deleted file path —
  only this task file's description and the maintenance docs' historical
  completion notes remain.
- `git diff --check` — clean.

Reported to the user in Japanese.

## Completed Follow-up Assignment

Complete these three bounded tasks in order. Communicate with the user in
Japanese. Do not edit the paused RedBlackTreeSet outline and do not broaden
this work into new PermutationModule features.

### Task 1 — Remove the remaining test-only permutation implementation

The production module now has one implementation path, but
`Tests/PermutationTests/NextPermutation.swift` still contains a separate older
`NextPermutation` protocol, `Array` conformance, unsafe-buffer handle, and
algorithm implementation. The user wants implementation variants reduced.

1. Confirm with a repository-wide search that this file is used only by
   `testPerformance00` in `PermutationTests.swift` and is not a required oracle
   for another test.
2. Remove `Tests/PermutationTests/NextPermutation.swift` and remove
   `testPerformance00` or rewrite no test to depend on a second implementation.
   Do not move the duplicate algorithm elsewhere.
3. Update the Permutation maintenance documents and `Tests/TESTING.md` so this
   is no longer listed as a pending user decision or surviving implementation.
4. Verify no references to `NextPermutationUnsafeHandle`, the test-only
   `NextPermutation` protocol, `forEach_nextPermutation`, or
   `testPerformance00` remain.

### Task 2 — Finish public documentation for the retained API

Update the English documentation comment for `nextPermutations()` and only the
public return types where needed. Document the current tested contract:

- the current ordering is yielded first;
- only lexicographic successors are then yielded;
- equal elements do not create duplicate value orderings;
- descending, all-equal, single-element, and empty inputs each yield the
  current ordering once;
- previously yielded results remain stable as iteration advances;
- one permutation step is worst-case O(n).

Keep implementation details such as `ManagedBuffer` out of the public
contract. Ensure comments are English, match
`Sources/PermutationModule/Documentation/Specification.md`, and do not mention
removed unsafe/full-permutation APIs as current alternatives.

### Task 3 — Record the breaking removals in CHANGELOG

Update only the current `[Unreleased]` section of `CHANGELOG.md`. Under
`Removed`, concisely record:

- removal of the full-permutation and unsafe PermutationModule public APIs,
  leaving `nextPermutations()` as the supported entry point;
- removal of Range View `unranged()` and its single-purpose support protocols.

Describe these as source-breaking public API removals. Do not rewrite prior
release sections and do not turn the maintenance history into changelog prose.

Validation for this assignment:

- Run the narrow Permutation tests and confirm the intended tests ran.
- Run repository-root `swift test`.
- Run compatibility-mode validation for the affected Permutation facade path.
- Search for all removed declarations and stale pending-decision text.
- Run `git diff --check`.
- Change this status to `Completed` only after all three tasks and validations
  complete, then add a concise result summary above the historical material.

## Completed Assignment (Tasks 1–3)

The assignment below is retained as the completed historical request. Its
three tasks have been implemented and validated. Do not edit
`Sources/RedBlackTreeCollections/Documentation/Head/Outlines/RedBlackTreeSet.outline.md`;
the user has explicitly paused that document.

### Task 1 — Remove redundant and unsafe PermutationModule variants

The previous specification misunderstood the user's goal. The user has now
made the final product decision: do not provide APIs whose behavior duplicates
swift-algorithms' full `permutations()` operation, and do not provide any
`unsafe` permutation API. These APIs and their dedicated implementation paths
are to be removed, not preserved as alternatives or left as open decisions.

Use this product direction:

1. The module's distinct value is the operation that enumerates only the
   lexicographic successors of the current element order (`nextPermutations`).
2. Remove full positional permutation enumeration: `Permutations.All`,
   `IteratorA`, `SubSequenceA`, `unsafePermutations()`, their dedicated support
   code, and tests that exist only for that removed API. Do not replace them
   with a safe `permutations()` convenience API; users who need full
   permutations should use swift-algorithms.
3. Remove `unsafeNextPermutations()` and the public unsafe initialization path.
   Retained-subsequence aliasing must not remain as a user-facing contract.
4. The final public entry point is `nextPermutations()`. Keep only the types and
   implementation required to support that API, and reduce visibility of
   implementation types/initializers when they no longer need to be public.
5. Preserve the observable value semantics of `nextPermutations()`: previously
   yielded results remain stable when the iterator advances.

Required corrections:

#### Phase 1A — swift-algorithms equivalence PoC (deletion gate)

Before deleting the full-permutation path, prove the claimed overlap with
swift-algorithms rather than assuming it.

- Temporarily enable the existing swift-algorithms test dependency only as
  needed for the PoC. Do not add it as a production dependency.
- Compare the immediately materialized values from the current
  `unsafePermutations()` path with `Algorithms.permutations()` for at least:
  empty input, one element, distinct sorted elements, distinct unsorted and
  descending elements, and duplicate values.
- Compare result count, order, and visible duplicate multiplicity. Include at
  least one non-Array `Collection` with `Index == Int` that the current API
  supports.
- Keep the comparison scoped to the public full-permutation behavior that a
  caller can safely consume by materializing each yielded result immediately.
  The unsafe retained-subsequence aliasing is an implementation hazard to be
  removed, not a capability that swift-algorithms must reproduce.
- Record the PoC command, cases, and observed result in the maintenance
  documentation. Temporary PoC code may be removed after it has served as the
  deletion gate, but the evidence must remain reviewable in the document and
  diff/history.
- If ordering, multiplicity, empty-input behavior, or another observable
  result differs, stop before deletion and report the exact counterexample to
  the user in Japanese. Do not redefine the difference away.

#### Phase 1B — Retained API tests and removal

- After Phase 1A passes, first add or identify focused tests for the retained
  `nextPermutations()` contract, including empty, single-element,
  duplicate-value, unsorted, and descending inputs plus stability of retained
  yielded results.
- Implement the removals above in `Sources/PermutationModule` and update or
  remove tests that reference the deleted APIs. Do not retain deprecated
  wrappers unless compilation evidence shows an in-repository migration need;
  the user has explicitly authorized deletion of these public variants.
- Rewrite `Sources/PermutationModule/Documentation/Specification.md`,
  `Maintanance/PermutationModule/ImplementationPlan.md`, and
  `Maintanance/PermutationModule/ProductReadinessAssessment.md` to reflect the
  implemented narrow API. Historical discussion may record what was removed,
  but must not present removed variants as supported strategies.
- Search the entire repository for references to every removed declaration,
  including compatibility documentation and `AcCollections` facade tests.
- Correct the ABC328E plan: constraints are `N <= 8`, `M <= 28`; AtCoder
  validation needs a self-contained pasted Swift file and cannot rely on
  `import AcCollections` being available on the judge.
- Do not add a swift-algorithms product dependency merely to replace the
  deleted API. This task removes redundant functionality; it does not wrap it.
- Do not change unrelated modules, RedBlackTree code, Package.swift, or
  workflows.

Validation for Task 1:

- Run the narrow Permutation tests and confirm the retained cases actually run.
- Run the repository-root `swift test` after the removal.
- Run compatibility-mode validation because `AcCollections` conditionally
  re-exports PermutationModule there.
- Run `git diff --check`.

### Task 2 — Correct and complete the AtCoder 2025 refactoring history

The previous expansion of
`Maintanance/REFACTORING_FROM_ATCODER_2025.md` contains unsupported claims and
does not yet satisfy the requested history audit.

Required corrections and investigation:

1. Do not describe `ecb3085d` as a simple rename of the release-era keystone
   test. Git records deletion/addition with substantial edits, and the
   release-path file was deleted earlier in `1357bd3c`. Trace the intervening
   lineage and describe the current file as a derived/reworked successor unless
   stronger evidence supports another claim.
2. Put stages in chronological order, or explicitly split source and test
   timelines. The current September → May → June order is misleading.
3. Refer to `b2580703` as the tip/commit of the remote
   `release/AtCoder/2025` branch, not as a tag.
4. Do not infer unchanged contracts or author intent from Git similarity
   scores. Separate verified diff facts, user testimony, and interpretation.
5. For each major stage, record the commit, old path, new path, contract moved,
   and surviving or replacement tests. Cover internal-layer separation,
   fixture splitting, raw-tree/Foundamental test extraction, and the expansion
   of Test as Specification across all four public collection types.
6. Clarify `28a1a5fb`: distinguish pre-existing conceptual layers from the
   commit that aggregated/moved them under `Implements/`.
7. Fully describe `29f43bb3` and `60604ff6`, including the actual fixture and
   Foundamental test paths moved into `RedBlackTreeFixture` and
   `RedBlackTreeTreeTests`.
8. Preserve the keystone file unchanged and keep the user's confirmed design
   fact that existing tests were deliberately reused as a bootstrap rather
   than rebuilt from zero.

Task 2 remains documentation-only. Verify every cited commit and path with Git,
run `git diff --check`, and report any lineage that cannot be proven instead of
filling gaps with inference.

### Task 3 — Remove `unranged()` and its single-purpose protocols

After Tasks 1 and 2 are complete, implement the user's existing removal request
for the deprecated Range View `unranged()` API.

User authorization is explicit and final. Do not ask whether to defer this
task, do not merely correct the status, and do not leave it under pending
decisions. Start Task 3 now. The assignment is not complete until Task 3 and
its validation are complete.

Required work:

1. Remove `unranged()` from both `RedBlackTreeKeyOnlyRangeView` and
   `RedBlackTreeKeyValueRangeView`.
2. Confirm that `ScalarBaseInit`, `KeyValueBaseInit`, their `_create(_:)`
   requirements, and the four container conformances exist only to support
   `unranged()`. If the repository-wide search confirms that, remove them too.
   If another real use exists, stop and report it instead of deleting the
   protocol blindly.
3. Remove the four public-type tests dedicated only to `unranged()` while
   preserving the surrounding Range View tests.
4. Update `API-Matrix.md`, `API-Matrix-View.md`, `Tests/TESTING.md`, and any
   other current documentation that still presents `unranged()` or these
   protocols as available or pending removal.
5. Search the entire repository after editing. No source, test, or current-doc
   reference to the removed API should remain; historical reference material
   may retain an explicitly historical note.

Validation for Task 3:

- Run the four affected Range View test suites or the narrowest equivalent
  filters and confirm the intended tests ran.
- Run repository-root `swift test`.
- Run compatibility-mode validation if the removed declarations are compiled
  there.
- Run `git diff --check`.

Do not broaden Task 3 into unrelated Range View redesign or cleanup.

When all three tasks are complete, change this status to `Completed` and
add a new corrected result summary above the previous result summary. Do not
delete the previous record; label it as superseded where necessary.

## Result Summary (this pass)

Completed Task 3 (unranged() removal). Tasks 1 and 2 were already complete
from the previous pass (see "Partial Result Summary" below, now superseded by
this heading rename).

**Task 3 (`unranged()` and single-purpose protocol removal):**

- Removed `public func unranged()` from both
  `RedBlackTreeKeyOnlyRangeView` (`RedBlackTreeRangeView+KeyOnly.swift`) and
  `RedBlackTreeKeyValueRangeView` (`RedBlackTreeRangeView+KeyValue.swift`).
- Repository-wide search confirmed `ScalarBaseInit`/`KeyValueBaseInit`, their
  `_create(_:)` requirements, and the four container conformances
  (`RedBlackTreeSet`, `RedBlackTreeMultiSet`, `RedBlackTreeDictionary`,
  `RedBlackTreeMultiMap`) existed only to support `unranged()`; no other call
  site referenced `_create(_:)` or these protocols. Removed both protocols,
  their conformances, and the `_create(_:)` requirement entirely.
- Removed the four public-type tests dedicated only to `unranged()`:
  `testUnrangedReturnsRemainingBaseRangeAfterDrainingWithPopFirst` (Set),
  `test_unranged_returnsRemainingBaseRangeAfterDrainingPartially` (MultiSet and
  Dictionary), `test_unranged_returnsTheCollectionAfterMutatingTheView`
  (MultiMap). The surrounding Range View test suites were preserved and still
  pass (56/56 in the four affected suites).
- Updated `API-Matrix.md` and `API-Matrix-View.md` (removed the `unranged()`
  row and its now-dangling "実験的API" note), `Tests/TESTING.md` (removed the
  `unranged()` pending-decision entry), and `Maintanance/MAINTENANCE.md`
  (moved the user's removal request from "User requests for the next session"
  to "完了済みの要望"). `Tests/TESTING_REFERENCE.md`'s dated historical log
  entry was left as-is per the historical-note allowance.
- Repository-wide grep for `unranged`, `ScalarBaseInit`, `KeyValueBaseInit`
  after editing found no remaining source, test, or current-doc reference;
  only this task file (describing the removal) and the two historical notes
  above remain.

**Task 3 validation:**

- `swift test --filter 'RedBlackTreeSetRangeViewTests|RedBlackTreeMultiSetRangeViewTests|RedBlackTreeDictionaryRangeViewTests|RedBlackTreeMultiMapRangeViewTests'`
  — 56/56 passed.
- `swift test` from the repository root (normal mode) — full suite passed, no
  failures (`grep -c "Test run with" ` all `0 failures`/`passed`).
- Temporarily uncommented `.define("COMPATIBLE_ATCODER_2025")`, ran `swift
  build` and `swift test` — both succeeded (the removed declarations live
  entirely inside `#if !COMPATIBLE_ATCODER_2025` in both source files, so they
  never compiled in compat mode; this run confirms no regression elsewhere),
  then restored `Package.swift` (`git diff Package.swift` empty).
- `git diff --check` — clean.

Note: during this pass, this file's `Status` and Task 3 instructions were
externally edited (by Codex) to explicitly authorize immediate implementation
while validation of Tasks 1/2 was still running in this session. That edit's
content matched what the user had just separately confirmed when asked
directly, so Task 3 proceeded as authorized by the user.

## Partial Result Summary (Tasks 1 and 2 only; Task 3 remains active)

Completed both Task 1 and Task 2 as specified above.

**Task 1 (PermutationModule removal):**

- Phase 1A (deletion gate): Temporarily enabled the `swift-algorithms` test
  dependency (`Algorithms` product + `USING_ALGORITHMS` define) for the
  `PermutationTests` target and added
  `testPhase1A_unsafePermutationsEquivalentToAlgorithmsPermutations`, comparing
  immediately-materialized `unsafePermutations()` output against
  `Algorithms.permutations()` for empty, single-element, distinct sorted,
  distinct unsorted, descending, duplicate-value inputs, and a non-`Array`
  `Collection` with `Index == Int` (`Range<Int>`). All seven cases matched
  exactly (`swift test --filter PermutationTests`), confirming the deletion
  rationale. Recorded the PoC and result in
  `Maintanance/PermutationModule/ImplementationPlan.md`.
- Phase 1B: Added retained-contract tests for `nextPermutations()` first
  (empty, single-element, non-ascending-start continuation, and CoW stability
  of previously-yielded `SubSequenceN` results via
  `testNextPermutationsRetainedResultsRemainStable`), then removed from
  `Sources/PermutationModule/Permutations.swift`: `unsafePermutations()`,
  `Permutations.All`/`IteratorA`/`SubSequenceA` (and the now-dead
  `Buffer.prepare(count:)`), `unsafeNextPermutations()`, and the public
  `Nexts.init(safe:)`/`init(unsafe:)` (the `_unsafe` aliasing flag was removed
  entirely; `Nexts` now always CoWs via a single internal, non-public `init`
  reachable only through `nextPermutations()`). Removed the now-API-less
  `testUnsafePermutations`, `testUnsafeNextPermutations`, the Phase 1A PoC
  test, and `testPerformance1` from `Tests/PermutationTests/PermutationTests.swift`.
  Reverted the temporary `Package.swift` dependency/define change (`git diff
  Package.swift` is empty after the pass).
- Rewrote `Sources/PermutationModule/Documentation/Specification.md`,
  `Maintanance/PermutationModule/ImplementationPlan.md`, and
  `ProductReadinessAssessment.md` to describe the implemented narrow API
  (`nextPermutations()` only) and record the removed variants as history, not
  open options. No source/test reference to any removed declaration remains
  outside these historical documents and `CLAUDE_TASK.md` itself (repo-wide
  grep checked, including `AcCollections`/`AcCollectionsTests` and
  `Documentation/Compatibility`; no production dependency on
  `swift-algorithms` was added).
- Did not add a swift-algorithms product dependency. Did not touch
  `Sources/RedBlackTreeCollections/Documentation/Head/Outlines/RedBlackTreeSet.outline.md`.

**Task 1 validation:**

- `swift test --filter PermutationTests` — 2/2 passed (post-removal).
- `swift build` and `swift test` from the repository root (normal mode) — all
  existing suites passed, no regressions.
- Temporarily uncommented `.define("COMPATIBLE_ATCODER_2025")`, ran
  `swift test --filter 'AcCollectionsTests|PermutationTests'` (includes
  `AcCollections`'s compat-mode re-export of `PermutationModule`) — passed,
  then restored `Package.swift` (`git diff Package.swift` empty).
- `git diff --check` — clean.

**Task 2 (REFACTORING_FROM_ATCODER_2025.md correction):** Re-verified the
existing corrected document (already reflecting the prior correction pass
below) against the 8 required corrections and against `git` directly in this
pass; made no further edits since every check passed.

- Confirmed every cited commit hash resolves with the exact recorded date and
  subject (`b2580703`, `cc0ca3ad`, `1357bd3c`, `ecb3085d`, `438af006`,
  `0483012f`, `28a1a5fb`, `29f43bb3`, `60604ff6`, `f4e9f69e`, `63b5699a`,
  `0ada7b35`, `e91c01ff`, `76328122`, `64118cd6`).
- Confirmed `b2580703` is both the tip of `remotes/origin/release/AtCoder/2025`
  and the commit tag `0.1.44` points to, and is a linear ancestor of `HEAD`
  (`git merge-base b2580703 HEAD` == `b2580703`) — matches the document's
  "branch tip, not tag" framing.
- Re-ran `git show -M --name-status ecb3085d` and confirmed the exact D/A path
  pair the document cites, and recomputed the content diff with plain `diff`
  (not `git diff`, which inflates the count with patch-header lines): 446
  changed lines between the 350-line original and 347-line result, matching
  the document exactly.
- Confirmed via `git log --follow` that rename tracking naturally stops at
  `ecb3085d`'s `A` line (i.e., git itself does not treat it as a traceable
  rename past that point), corroborating the document's reasoning for why
  `ecb3085d` is documented as delete+rewrite rather than a simple rename.
  Traced the remaining rename chain (`438af006` → `UnsafeTreeV2BootstrapTests.swift`,
  `64118cd6`/`aefc6ab6` content-only edits, `0483012f` renamed back) and found
  it matches T5 exactly.
  - Confirmed via `git ls-tree` that `28a1a5fb`'s parent commit has 13
    top-level directories under `Sources/RedBlackTreeModule` (no `Implements/`)
    and that `28a1a5fb` itself introduces the single `Implements/` directory
    alongside the 4 public-type directories — matches S2's aggregation claim.
- No unsupported claims, broken links, or incorrect commit/path references
  were found. No changes were made to
  `Maintanance/REFACTORING_FROM_ATCODER_2025.md` in this pass.

**Task 2 validation:**

- All cited commits verified with `git show -s`/`git log --follow`/`git
  merge-base`/`git ls-tree` as above.
- `git diff --check` — clean.
- No `swift test` run was needed; this task made no source or test changes.

Reported to the user in Japanese. Open items remaining for the user (recorded
in `Maintanance/PermutationModule/ImplementationPlan.md`'s pending-decisions
list): whether to delete or keep `Tests/PermutationTests/NextPermutation.swift`,
`Sendable` conformance, doc-comment coverage, and the ABC328E live-submission
performance check (external AtCoder submission, to be run by the user).

## Previous Correction Result (superseded by the removal decision above)

Completed both corrected tasks. No production code, tests, or package settings were
changed; documentation and planning only.

**Task 1 (PermutationModule, narrowed to fewer variants):**
- Rewrote `Sources/PermutationModule/Documentation/Specification.md`,
  `Maintanance/PermutationModule/ImplementationPlan.md`, and
  `Maintanance/PermutationModule/ProductReadinessAssessment.md` around the product
  direction: `nextPermutations()` is the module's distinct value; `Permutations.All` /
  `IteratorA` / `SubSequenceA` / `unsafePermutations()` are treated as removal candidates
  that overlap `swift-algorithms`' `permutations()`, not as a feature to complete with a
  new `safe` convenience method.
- Enumerated the complete current public surface (not just the three extension methods):
  `Permutations<C>`, `All`/`Nexts` each with public `init(safe:)`/`init(unsafe:)`,
  `IteratorA`/`IteratorN`, `SubSequenceA`/`SubSequenceN`. This full list is what a staged
  removal must account for.
- Preserved the factual distinction that `All` permutes positions (`n!` positional
  results, duplicates possible) and `Nexts` follows value-based lexicographic successors
  (no duplicate value-orderings, stops early on descending/equal input); the two are not
  described as sharing an ordering, duplicate, or termination contract.
- Added a staged plan in `ImplementationPlan.md`: Stage 0 (regression-locking tests,
  including an equivalence test against `swift-algorithms` as the removal justification)
  → Stage 1 (deprecate the `All` family) → Stage 2 (delete the `All` family and the
  now-dead `Buffer.prepare(count:)` path) → Stage 3 (decide whether
  `unsafeNextPermutations()` / `Nexts.init(safe:)`/`init(unsafe:)` stay public or become
  an internal fast path with the aliasing behavior no longer exposed as a second public
  contract). Each stage requires user sign-off before implementation; nothing was
  implemented.
- Corrected the ABC328E plan: constraints are `N <= 8`, `M <= 28`; the practical
  validation plan explicitly requires a self-contained pasted Swift file for AtCoder
  submission (judge cannot `import AcCollections`), separate from the in-package
  re-export test.

**Task 2 (REFACTORING_FROM_ATCODER_2025.md correction):**
- Re-investigated the keystone test's lineage with `git log --follow`, `git show -M
  --name-status`, and targeted `diff`. Found that the current file is **not** a simple
  rename of the release-era original: `cc0ca3ad` (2026-01-03) forked a copy of
  `tree/___RedBlackTreeContainerTests.swift` into `unsafeTree/old/...`; the two files
  then existed in parallel for ~9 months; the release-era original was deleted in
  `1357bd3c` (2026-09-29); the next day `ecb3085d` (2026-09-30) relocated the forked copy
  to its current directory while also rewriting most of its content (446 diff lines
  against ~350/347 total — git's similarity detector recorded this as delete+add, not a
  rename). Documented this as a derived/reworked successor, not a rename of the original.
- Reorganized the document into an explicit source-timeline section and a separate
  test-timeline section (the prior September → May → June single sequence mixed two
  independent timelines). Within the test timeline, fully traced T1–T6 including the
  `438af006` Bootstrap rename and its reversion back to the current filename in
  `0483012f` (2026-10-03), which the previous version asserted without a traced commit.
- Changed every reference to `b2580703` from "tag-affixed commit" to "the tip commit of
  `release/AtCoder/2025`" (confirmed via `git merge-base` and `git log -1` on the remote
  ref); noted that tag `0.1.44` happens to point to the same commit without using the tag
  as the reference point.
- Added an evidence-labeling convention (`[事実]` / `[証言]` / `[解釈]`) throughout the
  document and reclassified statements that previously presented rename-similarity
  percentages as proof of unchanged intent; those are now scoped to "git's rename
  detector recognized this as the same file," not "the contract didn't change."
- Clarified `28a1a5fb`: confirmed via `git ls-tree` on its parent that `Implements/` did
  not exist before this commit, and via `git show -M --name-status` that it aggregates 14
  pre-existing top-level directories (`__tree`, `UnsafeTreeV2`, `BoundsExpression`,
  `Deprecated`, etc.) under the new `Implements/` parent in one commit. The layers
  pre-existed as top-level directories; the `Implements/` aggregation itself did not
  predate this commit.
- Fully described `29f43bb3` and `60604ff6` with exact `git show -M --name-status` output:
  the `RedBlackTreeFixture` target (`Fixtures.md`, `RedBlackTreeFixture.swift`, removal of
  `RedBlackTreeTestSupport/___Node.swift`) and the `RedBlackTreeTreeTests` ("genboku")
  target (`Tree/Fixture/*` and 10 `Tree/Foundamental/*` files moved, `RedBlackTreeFixture`
  dependency wiring in `Package.swift`).
- Preserved the user's confirmed design fact that tests were reused as a bootstrap rather
  than rebuilt from zero, now backed by the corrected T1–T6 lineage (the fork-and-parallel
  pattern in T1/T3 is itself evidence of this policy, not just an assertion).

**Validation:**
- All cited commit hashes verified to resolve and all cited paths verified against
  current `git show`/`git ls-tree` output during this pass.
- `git diff --check` — clean.
- No `swift test` run was needed; this assignment made no source or test changes.

Reported to the user in Japanese. The PermutationModule removal decisions (deprecate vs.
delete `All` family, fate of `unsafeNextPermutations()`, and `NextPermutation.swift`'s
legacy test) remain open and are recorded in `ImplementationPlan.md`'s pending-decisions
list, awaiting the user's judgment before any implementation proceeds.

## Previous Result Summary (superseded pending correction)

Completed both Task 1 and Task 2 of the PermutationModule/REFACTORING assignment below.
No production code, tests, or package settings were changed; this was a documentation and
planning assignment only.

**Task 1 (PermutationModule phase 1):**
- Added `Sources/PermutationModule/Documentation/Specification.md`: draft specification
  separating observable public contract (enumeration order, termination, duplicate
  handling, CoW-vs-no-CoW behavior) from implementation strategy. Frames `unsafe`-prefixed
  APIs as a deliberate no-CoW strategy, not an inferior/unsafe variant.
- Added `Maintanance/PermutationModule/ImplementationPlan.md`: which existing tests to
  retain (`PermutationTests.swift`) vs. undecided (`NextPermutation.swift`, a dead
  alternate-generation implementation unreferenced by the main module), missing Test as
  Specification cases (cross-API ordering consistency, empty/single-element boundaries,
  `unsafePermutations()` CoW-cancel behavior, `Permutations.All.init(safe:)` coverage),
  a performance-check plan, and a practical plan for ABC328E copy-paste-submission
  validation (baseline before/after comparison, to be executed by the user since it
  requires an external AtCoder submission).
- Updated `Tests/TESTING.md` (current-state + pending-decisions) to reflect this.
- Open decisions for the user (recorded in both new docs): `unsafe` naming, whether to
  wire up `Permutations.All.init(safe:)` as a public "safe full enumeration" API, and
  whether to delete or keep `Tests/PermutationTests/NextPermutation.swift` as reference.

**Task 2 (REFACTORING_FROM_ATCODER_2025.md expansion):**
- Verified `release/AtCoder/2025` is a linear ancestor of the current history
  (`git merge-base` == branch tip, 3416 commits ahead) and traced/confirmed via
  `git show --name-status -M` and `Package.swift` diffs:
  - A fact correcting a possible assumption: the numbered Test as Specification style
    for `RedBlackTreeSet` (11 files) already existed at the 2025-09-03 release point
    (introduced 2025-05-25, commit `f4e9f69e`), and the keystone test predates even that
    (file header dated 2024/09/17). The technique was carried forward, not introduced by
    the migration. `RedBlackTreeMultiSet`/`Dictionary`/`MultiMap` had only 2 files each at
    release time vs. 22-24 now; the commit-by-commit path of that later expansion was not
    traced (documented as a confirmed count-only fact, not a narrated sequence).
  - New stage: internal-layer separation into `Implements/__tree`, `Implements/UnsafeTreeV2`,
    `Implements/Deprecated` already existed by commit `28a1a5fb` (2026-05-04), i.e. before
    the module rename below — recorded as a confirmed lower bound, not a traced origin.
  - New stage: the `RedBlackTreeModule` → `RedBlackTreeCollections` target/directory rename
    happened in three dated commits (`0ada7b35` directory-only rename, `e91c01ff` target
    rename + new thin `@_exported import` compat shim, `76328122` moving that shim's folder
    to `Sources/_RedBlackTreeModule`), confirmed against the current file contents.
  - New stage: `RedBlackTreeFixture` (`29f43bb3`) and `RedBlackTreeTreeTests`/"genboku"
    (`60604ff6`) target extraction, both 2026-10-02, matching the existing `Tests/TESTING.md`
    note.
  - Added a "Test migration" section giving the test-side migration equal weight to the
    source migration, preserving the user's point that existing tests were reused as a
    bootstrap rather than rebuilt from zero.
- Preserved all previously confirmed content; only added new stages and one corrective/
  contextual section. Did not modernize, rename, or alter the keystone test file.

**Validation:**
- All cited commit hashes verified to resolve (`git cat-file -e`) and all cited paths
  verified to exist in the current working tree.
- `git diff --check` — clean.
- No `swift test` run was needed; this assignment made no source or test changes.

Reported to the user in Japanese; the PermutationModule open decisions above are awaiting
the user's judgment before any implementation proceeds.

## Previous Active Assignment (now completed, see Result Summary above)

Work on the following two bounded documentation and planning tasks in order.
Read the repository-level instructions, `Tests/CLAUDE.md`, `Tests/TESTING.md`,
and the relevant user priorities in `Maintanance/MAINTENANCE.md` before
editing. Communicate with the user in Japanese.

### Task 1 — PermutationModule specification, phase 1

Prepare the specification foundation for a future `PermutationModule`
redesign. This phase is investigation and documentation only.

1. Audit the current public API, implementation variants, existing tests,
   package configuration, user-facing documentation, and the historical
   AtCoder-compatible behavior of `PermutationModule`.
2. Recreate `Sources/PermutationModule/Documentation/` if it is absent and
   write a concise specification draft there. Separate observable public
   behavior from implementation strategy. The intended end state should
   expose differences in behavior caused by implementation choice without
   presenting an "unsafe" variant as the user-facing distinction.
3. Produce a test-first implementation plan: identify which existing tests can
   be retained, which Test as Specification cases are missing, and which
   performance checks are needed. Include a practical plan for copy-paste
   submission to AtCoder ABC328E as the performance validation requested by
   the user.
4. Record unclear semantics, API-shape choices, compatibility questions, or
   removal candidates as decisions for the user. Do not guess.

Constraints for Task 1:

- Do not change production Swift code or public API in this phase.
- Do not delete or rewrite existing tests merely to fit the proposed design.
- Do not start implementation until the user has reviewed the specification
  and unresolved decisions.
- Keep new documentation focused; do not copy large source listings.

Validation and handoff for Task 1:

- Verify every named file, API, and test against the current repository.
- Run only documentation/link or existing narrow tests needed to validate
  factual claims; no broad implementation work is authorized.
- Update the relevant current-state maintenance document concisely.
- Report the proposed specification and user decisions needed in Japanese.

### Task 2 — Expand the AtCoder 2025 refactoring record

After Task 1 is complete, extend
`Maintanance/REFACTORING_FROM_ATCODER_2025.md` using repository history as
evidence.

1. Trace the main stages from `release/AtCoder/2025` to the current
   RedBlackTree architecture. For each confirmed stage, record the commit,
   old path, new path, contract moved, and replacement or surviving tests.
2. Give the test migration equal attention to the source migration. Preserve
   the user's important design fact that the existing tests were deliberately
   reused as a bootstrap rather than rebuilt from zero.
3. Cover the progression from container-coupled code through internal-layer
   separation, fixture splitting, raw-tree tests, and the four public
   collection Test as Specification suites.
4. Treat
   `Tests/RedBlackTreeTests/UnsafeTreeV2/Instance/___RedBlackTreeContainerTests_unsafe.swift`
   as the keystone historical artifact. Do not modernize, rename, enable, or
   delete it as part of this task.
5. Clearly distinguish facts proven by commits and diffs from interpretations.
   Label uncertain intent and ask the user instead of presenting it as fact.

Constraints for Task 2:

- Documentation changes only. Do not change source, tests, package settings,
  workflows, or public API.
- Prefer a readable account of methods and stages over an exhaustive file-move
  log.
- Preserve the existing confirmed content unless repository evidence proves it
  wrong.

Validation and handoff for Task 2:

- Check cited commits and paths with Git history.
- Check all current links and paths mentioned in the document.
- Run `git diff --check`.
- Report additions, uncertain points, and evidence used in Japanese.

When both tasks are complete, change this status to `Completed`, add a concise
result summary and validation record above the previous completed assignment,
and do not delete the historical completion record below.

## Previous Completed Assignment

### Result Summary

Confirmed the singleton lifecycle for all four types (Set/MultiSet/Dictionary/
MultiMap) and added
`Tests/RedBlackTreeTests/RedBlackTreeInternal/Base/RedBlackTreeInternal_EmptySingletonTests.swift`
(DEBUG-only, `@testable import`). One shared helper pair
(`assertIsSingleton`/`assertNotSingleton`, generic over `UnsafeTreeV2<Base>`)
plus one test function per type drives: `init()`, `init(minimumCapacity:)` at
0 and >0, `reserveCapacity(0)`, first `insert`, `remove(at:)` on the last
element, and both `removeAll(keepingCapacity:)` modes.

Findings (internal allocation/CoW contract, not public API):

1. Ordinary `init()` and `init(minimumCapacity: 0)` return the exact same
   type-erased global singleton (`_emptyTreeStorage`, capacity 0) for all four
   types, and in fact across every generic instantiation (e.g.
   `RedBlackTreeSet<Int>` and `RedBlackTreeDictionary<String, Int>` share the
   identical object), since the singleton never stores payload.
2. Struct-copying an empty collection preserves that identity (confirmed via
   `isIdentical(to:)`).
3. Detachment happens on: `init(minimumCapacity:)` with a positive value;
   `reserveCapacity(_:)` for any value including 0 (it goes through
   `ensureUniqueAndCapacity`, which treats the singleton as never-unique); and
   the first insertion (needs capacity regardless). Decoding an empty JSON
   array already had prior regression coverage
   (`EtcTests.testDecodeEmptyArrayUsesReadOnlySingleton`) confirming the same
   singleton path.
4. After removing the last element via `remove(at:)`, the collection keeps its
   already-allocated buffer; it does not revert to the singleton (matches the
   "held for now" note already in `AllocationTests.test1`).
5. `removeAll(keepingCapacity: true)` keeps the current buffer (singleton or
   allocated) and is a no-op when already empty; `removeAll(keepingCapacity:
   false)` always reassigns to the singleton via `.create()`.
6. All four types are intentionally identical on points 1-5; the
   implementations are structurally parallel across Set/MultiSet/Dictionary/
   MultiMap.
7. Not configuration-dependent: the singleton/`isReadOnly`/`ensureUnique`
   mechanics in `UnsafeTreeV2+Create.swift`, `+CopyOnWrite.swift`, and
   `UnsafeTreeV2.swift` have no `#if DEBUG` or `#if COMPATIBLE_ATCODER_2025`
   branches; only the `@testable`/`AC_COLLECTIONS_INTERNAL_CHECKS`
   introspection used by tests is DEBUG-only. Verified by running the new
   tests under a temporary `COMPATIBLE_ATCODER_2025` build (then reverted) in
   addition to the normal build.

Unresolved/reported to the user (not fixed; out of scope for this task):
`erase(where:)` on all four types calls bare `ensureUnique()` unconditionally
(no `count > 0` guard), so it detaches an already-empty collection from the
singleton for no reason — the same "wasteful CoW on no-op removal" pattern
that was already fixed for `remove(_:)`, `removeValue(forKey:)`,
`removeAll(keepingCapacity: true)`, and `popFirst`/`popLast` elsewhere. Added
`testEraseWhereOnEmptyCollectionDetachesFromSingleton` as a minimal
reproducer documenting the current (unfixed) behavior; no production code was
changed.

Validation:
- `swift test --filter RedBlackTreeInternal_EmptySingletonTests` — 5/5 passed
  (normal build).
- `swift test` from the repository root — full suite passed (normal build).
- Temporarily uncommented `.define("COMPATIBLE_ATCODER_2025")` in
  `Package.swift`, ran `swift test --filter
  RedBlackTreeInternal_EmptySingletonTests` (4/4 ran; the
  `erase(where:)`-only test correctly skipped, since that API doesn't exist in
  compat mode) and then the full `swift test` (no new failures; one
  pre-existing unrelated skip in
  `RedBlackTreeSetAdditionalAtCoder2025LegacyTests.testSubsequence4`), then
  restored `Package.swift` (`git diff Package.swift` is empty).
- `git diff --check` — clean.

## Objective

Audit the empty-storage behavior of the four public RedBlackTree collection
types and determine exactly when an empty collection uses a shared singleton
buffer. Turn the confirmed behavior into focused tests and concise maintenance
documentation without changing the public API.

The four types are:

- `RedBlackTreeSet`
- `RedBlackTreeMultiSet`
- `RedBlackTreeDictionary`
- `RedBlackTreeMultiMap`

## Start With

1. Read `Tests/CLAUDE.md` and `Tests/TESTING.md` completely.
2. Inspect the empty initializer paths, minimum-capacity initializer paths,
   buffer creation code, copy-on-write code, and `removeAll(keepingCapacity:)`.
3. Search for existing empty-buffer identity tests and internal inspection
   helpers before adding anything.
4. Read only the relevant sections of `Tests/TESTING_REFERENCE.md` if historical
   context is required.

## Questions to Resolve

Establish evidence-backed answers for each public collection type:

1. Does ordinary empty initialization use the same shared storage instance?
2. Does copying an empty collection preserve that shared storage?
3. Which operations detach from the singleton: reserve, first insertion,
   minimum-capacity initialization, or another operation?
4. After removing the final element, does the collection retain its allocated
   buffer or return to the singleton?
5. What are the distinct outcomes of `removeAll(keepingCapacity: false)` and
   `removeAll(keepingCapacity: true)`?
6. Are the answers intentionally identical across all four types?
7. Are any behaviors configuration-dependent, including Debug/Release,
   compatibility mode, or package traits?

Do not treat pointer identity as public API. Classify findings as internal
allocation and copy-on-write contracts unless an observable public guarantee
already exists.

## Required Work

1. Audit implementation and existing tests before editing.
2. Create or reuse the smallest test-only inspection helper needed to observe
   storage identity and capacity. Do not expose new public API.
3. Add focused tests for the confirmed singleton lifecycle. Place them in the
   appropriate internal or value-semantics test layer according to
   `Tests/CLAUDE.md`; do not add them to numbered Test as Specification files if
   they only assert internal storage identity.
4. Cover all four public collection types without duplicating large test bodies
   when a clear shared helper is appropriate.
5. Record the confirmed conditions in the appropriate test/fixture documentation
   and update `Tests/TESTING.md` concisely.
6. If current behavior is inconsistent, unsafe, or unclear, do not normalize it
   speculatively. Preserve a minimal reproducer and report the evidence to the
   user in Japanese.

## Scope and Constraints

- Keep changes limited to tests, test-support code, and test documentation.
- Do not change production code as part of this assignment.
- Do not change public API or promise storage identity as public behavior.
- Preserve unrelated user and Codex changes, including the staged Linux ASan
  diagnostics for `TreeFoundamentalAllocationTests`.
- Do not edit `.github/workflows/swift.yml`,
  `TreeFoundamentalAllocationTests.swift`, or `TreeOwnedNodeFixture.swift`.
- Communicate progress, questions, and results to the user in Japanese.

## Validation

1. Run the narrowest new or affected tests first.
2. Run the complete affected RedBlackTree test target.
3. Run `swift test` from the repository root and confirm the intended tests ran.
4. Add Release or compatibility-mode validation only when the behavior or
   conditional compilation being tested requires it.
5. Run `git diff --check`.

## Completion Criteria

- The singleton lifecycle is explicitly established for all four collection
  types, including initialization, copying, detachment, last-element removal,
  and both `removeAll` capacity modes.
- Internal tests fail if these confirmed storage-sharing conditions regress.
- No production code or public contract is changed.
- `Tests/TESTING.md` records the current result and any unresolved concern.
- This file is changed to `Status: Completed` and receives a concise result
  summary listing changed files and validation commands/results.
- The user receives a Japanese report, and Codex can independently review the
  resulting diff.
