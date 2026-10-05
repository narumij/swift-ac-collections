# C++ behavior comparison target

## Status

**Four-container expansion complete and accepted (2026-10-04) — Set, MultiSet,
Dictionary, and MultiMap seeded traces pass in Debug and Release.**
The user raised this work's priority on 2026-10-04 because agreement with the C++
standard-library containers is important evidence for completing the red-black-tree
implementation. Set, MultiSet, Dictionary, and MultiMap now have 17 passing comparison
tests; the next bounded step is to audit and close deterministic boundary gaps before
any randomized expansion.

### Curated-boundary audit authorization (2026-10-04)

1. Inventory the existing 17 tests by container pair, operation, and boundary before
   editing. Distinguish directly observed behavior from facts not exposed by both APIs.
2. Run all `CppBehaviorReferenceTests` in Debug and Release.
3. Add only missing deterministic coverage for valid hinted insertion at empty,
   `startIndex`, `endIndex`, exact and deliberately poor hints; equivalent-key group
   boundaries for multi containers; and erase followed by reinsertion at boundaries.
4. For each mutation, compare the meaningful returned facts and the complete ordered
   contents. Continue transporting positions only as current zero-based ranks.
5. On any difference or crash, minimize the trace, record build mode and observation,
   mark the task blocked, and stop before a production fix.

Do not add randomized/fuzz traces, performance measurements, CI changes, public API,
or production Swift changes in this audit. Record the final coverage matrix, exact
commands, test counts, and remaining genuine gaps here for Codex review.

### MultiSet positional-erase follow-up authorization (2026-10-04)

Close the only concrete curated gap reported by the boundary audit before considering
randomized traces:

1. Extend only the MultiSet C++ executor/Swift adapter as needed to erase a valid
   position resolved independently from a current zero-based rank.
2. Compare first, last, and interior duplicate-occurrence erasure. Compare the next
   rank and erased value only where both APIs expose the same fact, and always compare
   complete ordered contents after mutation.
3. Cover hinted reinsertion at the erased boundary and erase-to-empty followed by
   insertion into the empty container.
4. Preserve current diagnostics and add a deliberate mismatch only if the new
   observation shape is not already exercised by the existing mismatch test.
5. Run the full `CppBehaviorReferenceTests` suite in Debug and Release and run
   `git diff --check`.

Do not add randomized traces, broaden another container, change production Swift, or
alter public API. On any difference or crash, minimize and record the trace and stop.

### Set seeded-randomized PoC authorization (2026-10-04)

Curated deterministic gaps are closed. Validate the stage-2 approach on Set alone
before any four-container expansion:

1. Generate stateful traces from a repository-local deterministic PRNG with a small,
   fixed seed list and bounded operation count. Record the PRNG algorithm, seeds, and
   operation count in the test/task document.
2. Select only valid operations from current model state: insert, hinted insert with a
   valid current rank, lookup/count, lower/upper bounds, erase by key, and erase by
   current rank if it maps to the existing common contract. Include empty/non-empty,
   duplicates, boundary keys, and start/end/poor hints through generation policy.
3. Resolve all transported positions independently from current zero-based ranks.
   Compare common returned facts and complete ordered contents after every mutation.
4. A failure diagnostic must contain container pair, seed, operation number, operation,
   the complete generated trace through failure, and both observations. Add one
   deliberate mismatch proving these fields without introducing a real defect.
5. Run all C++ comparison tests in Debug and Release and `git diff --check`.

Keep the test runtime bounded and stable. Do not add time-based fuzzing, automated
shrinking, CI, other container pairs, production changes, or public API. Any real
difference/crash is a stop condition: preserve the trace and do not fix it in this task.

### MultiSet seeded-randomized expansion authorization (2026-10-04)

The Set PoC is accepted. Apply the same evidence standard to MultiSet only:

1. Reuse or minimally extract the deterministic SplitMix64 and diagnostic helpers;
   keep Set seeds, traces, and observed behavior unchanged.
2. Generate from an independent sorted-array multiset model with a small key domain:
   ordinary/hinted insertion, find/count, lower/upper/equal range, erase by key,
   `erase` by rank, and `remove` by rank.
3. Require duplicate-heavy coverage and valid ranks for hints/positions, including
   empty, start/end, exact/poor hints, hints before/inside/after an equivalent group,
   first/last/interior erasure, erase-to-empty, and reinsertion.
4. Compare equivalent returned facts and complete ordered contents after every
   mutation. Preserve seed, operation number, complete trace, and both observations in
   mismatch diagnostics; add a deliberate mismatch only if existing generic coverage
   does not exercise the MultiSet observation shape.
5. Use the same fixed seeds and bounded operation count unless a documented coverage
   requirement cannot be met. Run the full suite in Debug and Release plus
   `git diff --check`.

Do not expand to Dictionary/MultiMap, automate shrinking, alter CI, or change
production Swift. A real mismatch or crash is a stop condition.

### Dictionary seeded-randomized expansion authorization (2026-10-04)

The MultiSet expansion is accepted. Apply the shared seeded infrastructure to
Dictionary/std::map only:

1. Maintain an independent sorted key/value model with a small key domain and evolving
   distinct values.
2. Generate and distinguish preserve-existing `insert` (ordinary and hinted),
   replacing `updateValue` (ordinary and hinted), subscript assignment,
   defaulted-subscript mutation, lookup/count, lower/upper/equal range, and removal by
   key. Do not collapse insert and update semantics merely because both may add a key.
3. Require generated coverage of empty/non-empty state, new/existing keys,
   start/end/exact/poor valid hints, returned old/preserved values, present/absent
   lookup and removal, boundary keys, erase-to-empty, and reinsertion.
4. Compare every common returned fact and complete ordered key/value contents after
   every mutation. Preserve the fixed seeds, 300-operation bound, deterministic
   regeneration check, and full mismatch context. Add a Dictionary-shaped deliberate
   mismatch check if the generic diagnostic has not yet exercised key/value contents.
5. Run the complete C++ comparison suite in Debug and Release and `git diff --check`.

Do not expand to MultiMap, add unbounded fuzzing/shrinking or CI, or change production
Swift/public API. Preserve and stop on any real mismatch or crash.

### XCTest lifecycle migration authorization (2026-10-04)

The Dictionary expansion is accepted. Before adding more Swift Testing cases, address
the Debug lifetime-counter risk in full-suite and Linux CI execution:

1. Convert all `CppBehaviorReferenceTests` declarations from Swift Testing to XCTest.
   Preserve the semantic inventory, not merely a nominal test count.
2. Add a target-local `XCTestCase` base that faithfully copies the relevant Debug
   discipline from `RedBlackTreeTestCase`: pre-test singleton initialization and
   allocation/node/payload counter reset; post-test singleton integrity checks,
   initialized/deinitialized and allocated/deallocated balance assertions; final reset.
   Do not share source from another test target.
3. Add a direct `RedBlackTreeCollections` test dependency and conditional
   `@testable import` if required for the internal counters. Do not expose counters in
   production API.
4. Convert parameterized seed tests to explicit loops over the unchanged seed list.
   Each seed must execute in its own nested scope/helper so all tree values are released
   before the next seed and before teardown. Every assertion/mismatch must retain the
   seed in its failure message.
5. Preserve curated traces, deliberate mismatch checks, SplitMix64 known answers,
   deterministic regeneration, coverage requirements, and Debug/Release comparisons.
6. Validate the focused target in Debug and Release, then run the full root Debug suite
   to catch counter contamination of later XCTest cases. Run `git diff --check`.

Do not change production implementation, skip Linux, edit workflows, weaken counter
assertions, add MultiMap seeded traces, or broaden test semantics in this migration.
If Swift Testing and XCTest cannot be made behaviorally equivalent, record the exact
missing assertion or lifecycle failure and stop for review.

The migration was completed in the working tree before the later tracking-session PoC
instruction was observed. Preserve it for Codex review; the tracking-session approach
remains an unimplemented alternative. Neither approach is accepted until the Linux
Death Test gate below is satisfied.

### Linux Death Test gate for any lifecycle-strategy change

Changing the comparison suite from Swift Testing to XCTest changes test-runner and
process-lifecycle assumptions. Before accepting that migration or connecting it to CI:

1. Run on the same Ubuntu environment used by GitHub Actions.
2. Determine exactly which Death Test sources/cases are compiled, discovered, and
   executed; do not infer coverage from a green aggregate `swift test` result.
3. Account for `Package.swift` currently defining `DEATH_TEST` only on macOS.
4. Exercise representative precondition/abnormal-termination cases and verify child-
   process isolation, signals/exit statuses, and that the parent test process continues.
5. Preserve memory-counter balance checks before and after the Death Test slice.

If Linux cannot provide equivalent Death Test semantics, document and review that
limitation explicitly. Do not silently skip the cases or call the lifecycle migration
accepted based only on macOS results.

#### XCTest migration result — uncommitted, awaiting review (2026-10-04, Claude Opus 5.5)

The migration was completed in the working tree under the previous assignment before
the supersession above was noticed. Per the user's decision, the diff is kept
uncommitted for Codex review and the tracking-session PoC has **not** been started.
Revert the files listed below if the PoC route is chosen instead.

- **Changed files:** `Package.swift` (adds `RedBlackTreeCollections` to the
  `CppBehaviorReferenceTests` dependencies only);
  `Tests/CppBehaviorReferenceTests/CppBehaviorReferenceTestCase.swift` (new, staged by
  the tooling); the four `*BehaviorComparisonTests.swift` files. No production code,
  C++ source, workflow, or `SeededTraceSupport.swift` change.
- **Base class:** `CppBehaviorReferenceTestCase: XCTestCase` copies
  `RedBlackTreeTestCase`'s setUp (zero `deallocated`/`nodeDeinitialized`/
  `payloadDeinitialized` assertions, singleton initialization, counter reset) and
  tearDown (singleton capacity check and `fatalError`, `_tied`/fresh-pool checks,
  allocation/node/payload balance `XCTAssertEqual` plus `assert`, reset,
  `UnsafeNode.nullptr` integrity asserts) verbatim in semantics; Debug-only
  `@testable import`, plain import in Release.
- **Conversion:** each file declares `final class <File>: CppBehaviorReferenceTestCase {}`
  and each former `@Test` function becomes `test_<originalName>` in its own extension
  at its original position; the display name is kept as the first doc line, and
  existing doc comments are preserved. Assertion mapping: `#expect(x == nil)` →
  `XCTAssertNil`, `#expect(a == b)` → `XCTAssertEqual`, `#expect(!x)` →
  `XCTAssertFalse`, `#expect(x)` → `XCTAssertTrue`, `try #require` → `try XCTUnwrap`,
  `Issue.record` → `XCTFail`, seeded `#expect(mismatch == nil, ...)` →
  `if let mismatch { XCTFail(mismatch) }` (message already contains the seed and trace).
- **Seeds:** the six `@Test(arguments:)` cases loop over the unchanged seed lists and
  call a `private func <originalName>(seed:)` per seed, so each seed's collections
  are released before the next seed and before teardown. Deterministic-regeneration
  equality assertions now append `"seed=\(seed)"`; coverage and executor-error
  messages already contained it.
- **Inventory:** 32 → 32 test methods (Set 8, MultiSet 11, Dictionary 8, MultiMap 5);
  curated, mismatch, SplitMix64 known-answer, coverage, and seeded assertions are
  unchanged in content. One Dictionary line ending in `")}` was split before
  conversion (formatting only).
- **Commands/results:**
  - Baseline `swift test --disable-sandbox --filter CppBehaviorReferenceTests`:
    Swift Testing, 32 tests passed.
  - Same filter after migration (Debug): XCTest, 32 executed, 0 failures; 0 Swift
    Testing tests remain.
  - `swift test --disable-sandbox -c release --filter CppBehaviorReferenceTests`:
    32 executed, 0 failures.
  - `swift test --disable-sandbox -c debug` (full root, run twice): exit 0, no
    `error:`/failure lines; `CppBehaviorReferenceTests.xctest` 32 passed. No
    order-dependent counter failure was observed in this environment.
  - `git diff --check`: clean.
- **Not done:** Linux execution, compatibility-mode run (behavior is not
  compatibility-dependent), and a negative check that the base class detects an
  injected leak (it uses the same assertions as `RedBlackTreeTestCase`).

### Debug lifetime-counter tracking-session PoC authorization (2026-10-04)

The user proposed separating unmanaged test activity from an XCTest-managed lifetime
interval instead of immediately rewriting all Swift Testing cases:

1. Add one Debug-only tracking-session flag/state alongside the existing global
   allocation/node/payload counters.
2. On `RedBlackTreeTestCase.setUpWithError`, if tracking is off, unconditionally reset
   stale counters, establish the existing empty-singleton baseline, then mark the
   interval active. Do not require unmanaged prior counter values to be zero.
3. Treat a begin while already active as a test-harness error; do not silently reset an
   interval that another test owns.
4. During `tearDownWithError`, retain every existing singleton and counter-balance
   assertion. Reset counters and mark tracking inactive only after those checks.
5. Do not suppress counter increments/decrements merely because tracking is off in this
   PoC. Explicitly investigate whether an object created while inactive can be destroyed
   after an active interval begins; if demonstrated, stop because a simple flag is not
   sufficient.
6. Characterize the pre-change failure if reproducible, then run the focused C++ tests,
   the full root Debug suite at least twice, the normal Release suite, and
   `git diff --check`.

Do not migrate the comparison tests, edit workflows, skip Linux, weaken teardown
assertions, expand MultiMap seeded traces, or make unrelated production changes. The
PoC is accepted only if managed XCTest intervals still detect their own imbalances and
full-suite order pollution is eliminated without masking late destruction.

### Final MultiMap seeded-randomized expansion authorization (2026-10-04)

The XCTest migration and its CI run are accepted. Complete stage 2 with MultiMap only:

1. Reuse the accepted SplitMix64 seeds `[1, 2, 3, 0x5EED, 0xC0FFEE]`, 300-operation
   bound, XCTest lifetime base, deterministic regeneration, and full trace diagnostic.
2. Maintain an independent ordered `(key, mappedValue)` model. Mapped values must be
   distinct evolving occurrence identities so ordering within equal-key groups remains
   observable.
3. Generate ordinary/hinted insertion; find/count; lower/upper/equal range; erase by
   key and rank; remove by rank; and mapped-value update by rank. Use only valid current
   ranks, independently resolved on Swift and C++ sides.
4. Require empty/non-empty states, duplicate-heavy groups, hints before/inside/after a
   group plus start/end/exact/poor hints, first/last/interior erasure, erase-to-empty,
   mapped update, and reinsertion.
5. Compare every common return fact and complete ordered key/value contents after every
   mutation. Preserve seed-scoped destruction and all allocation/node/payload balance
   checks.
6. Run focused Debug and Release suites, the full root Debug suite, and
   `git diff --check`. Record the GitHub Actions result if available.

Do not add shrinking, additional benchmarks, history-document work, public API,
production fixes, or unrelated cleanup. A mismatch, crash, or lifetime imbalance is a
stop condition. When this passes, mark the four-container C++ comparison expansion
complete and leave further breadth as optional future work.

## Goal

Add an opt-in differential-testing facility that can run the same ordered-collection operations against this package and the corresponding C++ standard-library containers, then compare their observable behavior.

This is a correctness and compatibility tool, not a benchmark. Keep the existing `CppBenchmarks` target focused on performance measurement.

## Location and targets

Keep correctness comparison in the root `swift-ac-collections` package. The user
explicitly selected the root package on 2026-10-04 so the comparison evidence stays
with the red-black-tree implementation rather than with performance benchmarks.

- `CppBehaviorReference`: a C++ reference target in the root package
- `CppBehaviorReferenceTests`: a Swift test target depending on `CppBehaviorReference` and `AcCollections`

The existing `Benchmarks` library and `CppBenchmarks` target remain unchanged. Move
only facilities needed by correctness comparison into the root package; do not move
or duplicate performance-measurement code.

## Initial scope

Use fixed-width integer keys and values at the C boundary. Cover these pairs first:

- `RedBlackTreeSet` and `std::set`
- `RedBlackTreeMultiSet` and `std::multiset`
- `RedBlackTreeDictionary` and `std::map`
- `RedBlackTreeMultiMap` and `std::multimap`

Run a deterministic operation trace against both sides and compare normalized observations after each operation. The first version should cover:

- insertion, including duplicate insertion
- hinted insertion where the Swift API has a corresponding contract
- lookup, `count`, `lower_bound`, `upper_bound`, and `equal_range`
- erasure by key and by a position selected from the current ordered contents
- complete ordered contents after every mutation
- returned insertion/erasure facts that have a meaningful equivalent on both sides

For multi-containers, preserve and compare the order within an equivalent-key group where the library intentionally follows the C++ behavior.

## Boundary design

Expose a small C ABI from the C++ target. Do not expose C++ containers, iterators, references, or standard-library types directly to Swift.

Prefer a trace executor that accepts plain operation records and returns plain observation records or caller-owned buffers. Every opaque allocation must have an explicit destroy function. Report errors as data; do not use `abort()` for comparison failures.

Do not transport iterators across the language boundary. Represent a position by its current zero-based rank in the normalized ordered output, and resolve it independently on each side immediately before the operation.

## Responsibilities

Keep these pieces separate so each can be reviewed and replaced independently:

- **C++ reference executor** (`CppBehaviorReference`): applies a trace to one
  `std::` container and returns observations through the C ABI. It does not know
  about Swift types.
- **Swift adapters** (in `CppBehaviorReferenceTests`): apply the same trace to an
  `AcCollections` type and produce observations in the normalized form.
- **Traces and fixtures**: plain operation records plus an optional seed, with no
  dependency on either implementation.
- **Mismatch reporting**: compares observation streams and formats the diagnostic;
  it does not execute operations.

## First proof of concept

Before broad API coverage, validate the wiring with one small end-to-end case:

1. Compare only `RedBlackTreeSet` and `std::set`.
2. Run one curated trace containing insertion, duplicate insertion, `lower_bound`,
   and erasure by key; compare complete ordered contents after each mutation.
3. Add one deliberate-mismatch test to confirm that the diagnostic identifies the
   container, operation number, operation, and both observations.
4. Record the exact command used to run it from the root package.

Stop after this PoC and report the result before adding the other container pairs,
hinted insertion, or randomized traces. Also stop if the PoC would require changing
`CppBenchmarks` or the public API of `AcCollections`.

### PoC result (2026-10-04)

- Added an independent `CppBehaviorReference` C++ target and
  `CppBehaviorReferenceTests` Swift test target. They were initially proven in the
  auxiliary package, then moved to the root package at the user's request.
- Compared `RedBlackTreeSet<Int64>` with `std::set<int64_t>` for insertion,
  duplicate insertion, lower bounds before/at/between/after elements, and erasing
  present and absent keys. Complete ordered contents matched after every operation.
- Hinted insertion also matched for an exact hint, a deliberately poor hint,
  `endIndex`, and a duplicate element. Hints cross the C boundary as a zero-based
  rank and are resolved to an index/iterator independently immediately before use.
- Confirmed with a deliberate mismatch that the report contains the container,
  operation number, input operation, and both observations.
- Changed neither `CppBenchmarks` nor public `AcCollections` API.
- Exact command:
  `swift test --disable-sandbox --filter CppBehaviorReferenceTests`
- Result: 3 tests passed. `--disable-sandbox` is required in the current local
  environment because manifest compilation otherwise fails at `sandbox-exec`.

### MultiSet result (2026-10-04)

- Added `cpp_multiset_execute_trace` for `std::multiset<int64_t>` and
  `MultiSetBehaviorComparisonTests.swift`; the Set executor is unchanged.
- Matching: insertion and duplicates, `lowerBound`/`upperBound` value and rank,
  `equalRange` contents, erasure by key with removed count, and hinted insertion
  at, inside, after, and (poorly) before an equivalent-key group. Within-group
  placement is observed through the rank of the returned index/iterator.
- **Repaired (2026-10-04):** `insert(_:hint:)` with `endIndex` on a non-empty
  multiset crashed in Debug (`__tree_left_rotate`, "node shouldn't be null");
  `std::multiset` inserts normally (minimal trace `insert(10)`,
  `insertHint(20, at: 1)`). Cause: the multi hinted `__find_leaf(_:_:_:)` checked
  `__hint == end` where libc++ (and the unique hinted `__find_equal`) checks
  `__prior == begin()`, so an `endIndex` hint returned `end.__right_` as the leaf.
  The condition now reads `__prior == __begin_node_`. The fix also covers
  `RedBlackTreeMultiMap.insert(_:hint:)`, which shares the path.
- Command: `swift test --disable-sandbox --filter CppBehaviorReferenceTests`
  (9 tests passed, none skipped).

### Dictionary result (2026-10-04)

- Added `cpp_map_execute_trace` for `std::map<int64_t, int64_t>` and
  `DictionaryBehaviorComparisonTests.swift`; the Set and MultiSet executors are unchanged.
- Matching: `insert(key:value:)` ↔ `insert` (existing value preserved),
  `insert(key:value:hint:)` ↔ hinted `insert` (exact, poor, `startIndex`,
  `endIndex`, empty, and existing-key hints; inserted flag, entry, rank),
  `updateValue(_:forKey:[hint:])` ↔ the effect of `insert_or_assign` (previous
  value and replacement), `dictionary[k] = v` ↔ `map[k] = v`,
  `dictionary[k, default: 0] += v` ↔ `map[k] += v`, lookup/`count(forKey:)` ↔
  `find`/`count`, `lowerBound`/`upperBound`/`equalRange` entry and rank at
  before/at/between/after positions, and `removeValue(forKey:)` ↔ `erase(k)` by
  removed count. Complete ordered key/value contents matched after every operation.
- Limitations: the package compiles C++ below C++17, so `insert_or_assign` is
  spelled out as `find`, then assign or (hinted) `insert`. The value returned by
  `removeValue(forKey:)` has no `erase(k)` equivalent and is compared only through
  the count and resulting contents.
- Command: `swift test --disable-sandbox --filter CppBehaviorReferenceTests`
  (13 tests passed).

### MultiMap result (2026-10-04)

- Added `cpp_multimap_execute_trace` for `std::multimap<int64_t, int64_t>` and
  `MultiMapBehaviorComparisonTests.swift`; the other executors are unchanged.
- Mapped values are distinct occurrence identities, so within-group placement is
  compared through the complete ordered key/value contents, never keys alone.
- Matching: `insert(key:value:)` (appended after the equivalent group), hinted
  `insert(_:hint:)` ↔ `insert(hint, …)` returned rank/entry for an empty container,
  exact hints before/after the group, inside the group, poor hints before/after,
  `startIndex`, `endIndex`, and reinsertion after erasure; `find`/`count`;
  `lowerBound`/`upperBound`/`equalRange` entry and rank at before/at/between/after
  keys; `eraseMulti` ↔ `erase(k)` count; `erase(_:)` ↔ `erase(it)` next rank;
  `remove(at:)` erased entry; `updateValue(_:at:)` ↔ assigning `it->second`
  (previous value).
- No difference or crash was found. This completes one curated trace for each of
  the four container pairs.
- Command: `swift test --disable-sandbox --filter CppBehaviorReferenceTests`
  (17 tests passed).

### Curated-boundary audit result (2026-10-04, Claude Opus 5.5)

Pre-audit inventory (17 tests; Debug and Release both passed 17/17 before editing):

| Pair | Tests | Covered before audit | Boundary gaps found |
| --- | --- | --- | --- |
| Set | 3 (curated, hinted, mismatch) | insert/duplicate, `lowerBound` before/at/between/after, erase present/absent; hints exact at start, poor at start, `endIndex`, duplicate inside | empty-container hint; existing least/greatest key at `startIndex`/`endIndex`; erase-then-reinsert at either end; reinsert into an emptied set |
| MultiSet | 6 (curated, two hinted, mismatch, two minimal `endIndex`) | bounds/equal ranges/`eraseMulti`; hints at/inside/after/poor-before the group, `endIndex` for least/greatest keys, reinsertion in the middle | empty-container hint; hints at both edges of least/greatest groups; erase of a boundary group then reinsert at either end; reinsert into an emptied multiset |
| Dictionary | 4 (curated, update, hinted, mismatch) | empty, `startIndex`, `endIndex`, exact/poor hints for new and existing keys, hinted update, reinsertion in the middle | erase least/greatest then hinted insert/update at either end; reinsert into an emptied dictionary |
| MultiMap | 4 (curated, positional, hinted, mismatch) | empty, `startIndex`, `endIndex`, exact before/after group, inside, poor before/after, reinsertion inside and after group erase (middle) | positional erase of first/last then reinsert at that end; erase boundary group then reinsert at either end; reinsert into an emptied multimap |

Facts not exposed by both APIs (unchanged, not gaps): Set returns no rank, but for a
unique set the returned value plus contents fixes it; Dictionary `removeValue(forKey:)`
value and MultiMap `insert(key:value:)` rank have no C++ counterpart (compared through
count/contents).

Added one deterministic boundary test per pair (no executor, C ABI, or production
change):

- `setBoundaryHintsAndReinsertionMatchCpp`
- `multiSetBoundaryHintsAndReinsertionMatchCpp`
- `dictionaryBoundaryReinsertionMatchesCpp`
- `multiMapBoundaryReinsertionMatchesCpp`

Each compares the returned facts and complete ordered contents after every operation.
No difference or crash was found in either build mode.

Commands and results:

- `swift test --disable-sandbox --filter CppBehaviorReferenceTests` — 21 passed (Debug).
- `swift test --disable-sandbox -c release --filter CppBehaviorReferenceTests` — 21 passed.
- `git diff --check` — clean. Changed files: the four files in
  `Tests/CppBehaviorReferenceTests/` and this file.

Remaining genuine gaps: MultiSet has no positional erase in its executor, so
position-based erase-then-reinsert is covered only for MultiMap. Seeded randomized
traces (strategy stage 2) are still not implemented, by design of this audit.
(The MultiSet gap is closed by the follow-up below.)

### MultiSet positional-erase result (2026-10-04, Claude Opus 5.5)

- Added `CPP_MULTISET_OPERATION_ERASE_AT` (`erase(it)`, reports the next rank) and
  `CPP_MULTISET_OPERATION_REMOVE_AT` (copy `*it`, then `erase(it)`, reports the
  erased value) to `cpp_multiset_execute_trace`; a rank outside `0..<size()` returns
  `CPP_MULTISET_TRACE_INVALID_POSITION`. No other executor changed.
- Swift adapter: `.eraseAt` ↔ `erase(_:)` returned-index rank, `.removeAt` ↔
  `remove(at:)` returned element. The rank is resolved independently and validated
  by range plus `isElement(at:)`. `erase(_:)` exposes no erased value and
  `remove(at:)` no next position, so each is compared only for its own fact.
- New test `multiSetPositionalEraseMatchesCpp`: erase of an interior and the last
  occurrence of a duplicate group, first/last elements of the whole multiset, first
  occurrences of the least/greatest groups; hinted reinsertion at `startIndex`,
  `endIndex`, exact before the last occurrence, and on both sides of the affected
  groups; erase to empty (next rank = `endIndex` of an empty multiset), then
  hinted insertion into the empty multiset and at `endIndex`. Complete ordered
  contents are compared after every operation.
- No difference or crash in either build mode. No new mismatch test: the
  observation shape (value/rank) is already exercised by the existing one.
- Commands and results:
  - `swift test --disable-sandbox --filter CppBehaviorReferenceTests` — 22 passed (Debug).
  - `swift test --disable-sandbox -c release --filter CppBehaviorReferenceTests` — 22 passed.
  - `git diff --check` — clean.
- Changed files: `Sources/CppBehaviorReference/include/CppBehaviorReference.h`,
  `Sources/CppBehaviorReference/CppBehaviorReference.cpp`,
  `Tests/CppBehaviorReferenceTests/MultiSetBehaviorComparisonTests.swift`, this file,
  `Maintanance/CLAUDE_TASK.md`.
- Remaining gaps: none among the curated deterministic traces; seeded randomized
  traces (strategy stage 2) remain unimplemented by design.

### Set seeded-randomized PoC result (2026-10-04, Claude Opus 5.5)

- **PRNG:** repository-local SplitMix64 (Steele, Lea, and Flood 2014), pinned by a
  known-answer test for seed 0 (`0xE220A8397B1DCDAF`, `0x6E789E6AA1B965F4`,
  `0x06C45D188009454F`). Seeds `[1, 2, 3, 0x5EED, 0xC0FFEE]`, 300 operations each.
- **Generator** (`generateSetTrace`, `SetBehaviorComparisonTests.swift`): stateful,
  driven by an independent sorted-array model. Alternating 40-operation growing and
  shrinking phases; keys from `0...15` plus 1/16 `Int64.min`/`Int64.max`; lookups,
  bounds, and erasures pick a present key with a phase-dependent probability. Hints are
  current ranks in `0...count`: exact insertion rank, `startIndex`, `endIndex`, one past
  exact, or random. A coverage test requires, per seed, at least one each of: hint on
  empty, hint at start/end of a non-empty set, exact/poor hint, duplicate insert,
  extreme key, present/absent lookup, present/absent erase, erase to empty. It also
  checks that each seed regenerates an identical trace.
- **Compared per operation** (returned facts plus complete ordered contents):
  `insert(_:)` ↔ `insert` (inserted, member); `insert(_:hint:)` ↔ `insert(hint, v)`
  (inserted, member at returned index); `contains` + `count(of:)` ↔ `find != end` +
  `count`; `lowerBound`/`upperBound` ↔ `lower_bound`/`upper_bound` (element or end);
  `remove(_:)` ↔ `erase(k)` (whether removed). Hint ranks are validated by range on
  both sides and resolved independently.
- **C ABI change:** added `CPP_SET_OPERATION_UPPER_BOUND`, `CPP_SET_OPERATION_FIND`, and
  `CppSetObservation.count` (-1 when not reported). Existing Set operations unchanged.
- **Diagnostic:** `firstRandomizedMismatch` reports container pair, seed, operation
  number, operation, both observations, and the numbered trace through the failure.
  `setRandomizedMismatchReportContainsRequiredContext` proves every field by tampering
  with one copied observation (no library defect involved), including that the trace
  stops at the failing operation.
- **Result:** no difference or crash.
  - `swift test --disable-sandbox --filter CppBehaviorReferenceTests` — 26 passed (Debug;
    the two parameterized tests ran 5 cases each).
  - `swift test --disable-sandbox -c release --filter CppBehaviorReferenceTests` — 26 passed.
  - `git diff --check` — clean.
- **Changed files:** `Sources/CppBehaviorReference/include/CppBehaviorReference.h`,
  `Sources/CppBehaviorReference/CppBehaviorReference.cpp`,
  `Tests/CppBehaviorReferenceTests/SetBehaviorComparisonTests.swift`, this file,
  `Maintanance/CLAUDE_TASK.md`.
- **Remaining gaps:** erase by current rank is not part of the Set comparison contract
  (the Set executor has no positional erase), so it is not generated. A rank-only
  `lowerBound`/`upperBound` result is not transported; for a unique set the element plus
  contents fix it. A Swift-side crash would identify the seed only through the
  parameterized test case argument, not the formatted diagnostic. No shrinking by design.

### MultiSet seeded-randomized result (2026-10-04, Claude Opus 5.5)

- **Shared helpers:** `SplitMix64`, `firstRandomizedMismatch` (now generic over the
  operation/observation types), and a Mirror-based `missingCoverage` moved unchanged
  into the new `Tests/CppBehaviorReferenceTests/SeededTraceSupport.swift`. The Set
  generator, seeds, count, phase length, and tests are otherwise unchanged; Set still
  passes its known-answer, coverage/determinism, matching, and mismatch tests.
- **Seeds/count:** same as Set — `[1, 2, 3, 0x5EED, 0xC0FFEE]`, 300 operations,
  40-operation growing/shrinking phases. No change was needed to meet coverage.
- **Generator** (`generateMultiSetTrace`, `MultiSetBehaviorComparisonTests.swift`):
  independent sorted-array model, keys `0...7` plus 1/16 `Int64.min`/`Int64.max`;
  insert/hinted insert pick a present key 50% of the time. Hint ranks in `0...count`:
  group start (`lower`), group end (`upper`), inside the group, `startIndex`,
  `endIndex`, a poor rank before or after the group, or random. Positional ranks in
  `0..<count`: first, last, random, or an occurrence inside a present key's group.
  Positional operations on an empty model become an ordinary insert.
- **Coverage test** requires, per seed, at least one of each: insert into empty /
  non-empty, duplicate insert, insert into a group of ≥2, hint on empty, hint at
  start/end of a non-empty multiset, exact (`lower...upper`) / poor hint, hint before
  / at start of / inside / at end of / after an existing group, extreme key,
  present/absent lookup, present/absent/≥2-occurrence erase by key, `erase` and
  `remove` at first/last/interior, positional erase inside a group of ≥2, erase to
  empty, insertion after being emptied, and reinsertion of a previously erased key.
  The rarest per-seed counts observed were 3 inside-group hints and 1 interior
  `erase(_:)` (seed 2); erase to empty occurred 24–33 times per seed. It also checks
  that each seed regenerates an identical trace and coverage.
- **Compared per operation** (returned facts plus complete ordered contents):
  `insert(_:)` ↔ `insert` (member); `insert(_:hint:)` ↔ `insert(hint, v)` (member and
  returned rank, i.e. within-group placement); `contains` + `count(of:)` ↔
  `find != end` + `count`; `lowerBound`/`upperBound` (element or end, and rank);
  `self[equalRange(k)]` ↔ `equal_range` elements; `eraseMulti` ↔ `erase(k)` count;
  `erase(_:)` ↔ `erase(it)` next rank; `remove(at:)` ↔ copy `*it` then `erase(it)`
  (erased value). Ranks are validated on both sides (range; Swift also
  `isElement(at:)` for positional) and resolved independently.
- **C ABI change:** added `CPP_MULTISET_OPERATION_FIND` and `CppMultiSetObservation`
  fields `found` and `count` (-1 when not reported). Existing operations unchanged.
- **Diagnostic:** `multiSetRandomizedMismatchReportContainsRequiredContext` proves
  container pair, seed, operation number, input, both observations, and the trace
  through (and not beyond) the failure by tampering with a copied rank. Added because
  the shared seeded formatter had been exercised only with the Set observation shape.
- **Result:** no difference or crash.
  - `swift test --disable-sandbox --filter CppBehaviorReferenceTests` — 29 passed (Debug;
    the four parameterized tests ran 5 cases each).
  - `swift test --disable-sandbox -c release --filter CppBehaviorReferenceTests` — 29 passed.
  - `git diff --check` — clean.
- **Changed files:** `Sources/CppBehaviorReference/include/CppBehaviorReference.h`,
  `Sources/CppBehaviorReference/CppBehaviorReference.cpp`,
  `Tests/CppBehaviorReferenceTests/SeededTraceSupport.swift` (new),
  `Tests/CppBehaviorReferenceTests/SetBehaviorComparisonTests.swift` (helper extraction
  only), `Tests/CppBehaviorReferenceTests/MultiSetBehaviorComparisonTests.swift`, this
  file, `Maintanance/CLAUDE_TASK.md`.
- **Remaining gaps:** the `find` rank is not compared (the standard does not fix which
  equivalent occurrence `std::multiset::find` returns); `equalRange` is compared by
  its elements, not its bound ranks (bounds are compared separately). Dictionary and
  MultiMap have no seeded traces. A Swift-side crash still identifies the seed only
  through the parameterized test argument. No shrinking by design.

### Dictionary seeded-randomized result (2026-10-04, Claude Opus 5.5)

- **Seeds/count:** shared `SplitMix64`, seeds `[1, 2, 3, 0x5EED, 0xC0FFEE]`, 300
  operations, 40-operation growing/shrinking phases (unchanged from Set/MultiSet).
- **Generator** (`generateDictionaryTrace`, `DictionaryBehaviorComparisonTests.swift`):
  independent sorted key/value model, keys `0...15` plus 1/16 `Int64.min`/`Int64.max`.
  Every value-bearing operation uses the distinct value `1_000 + operation number`.
  Generates `insert`, `insertHint`, `updateValue`, `updateValueHint`, `subscriptAssign`,
  `subscriptDefaultAdd`, `find`, `lowerBound`, `upperBound`, `equalRange`, `eraseKey`
  as separate cases; the model applies preserve (insert), replace (update/assign), and
  accumulate (defaulted subscript) semantics separately. Hint ranks in `0...count`:
  exact (lower-bound rank, the only exact rank for a unique key), one past exact,
  `startIndex`, `endIndex`, poor before/after exact, or random.
- **Coverage test** requires, per seed, at least one of each: insert into empty /
  non-empty; new and existing key for each of the six adding operations; hint on
  empty, at start/end of a non-empty dictionary; exact/poor hint separately for
  `insertHint` and `updateValueHint`; extreme key; new least/greatest key; present/
  absent `find` and bound/range; present/absent erase; erase of the least/greatest key
  with ≥3 entries; erase to empty; insertion after being emptied; reinsertion of an
  erased key. Rarest per-seed count was 3 (existing-key subscript assign/add, seeds 1
  and 0x5EED; exact `updateValueHint`, seed 0x5EED); erase to empty occurred 11–19 times
  per seed. Also checks that each seed regenerates an identical trace and coverage.
- **Compared per operation:** the existing Dictionary adapter's facts — inserted flag,
  returned entry, and rank for `insert`/`insertHint`; previous value (or absent) for
  `updateValue[Hint]`; entry, rank, count for `find`; entry and rank for bounds; lower/
  upper rank and entries for `equalRange`; removed count for `eraseKey` — plus complete
  ordered key/value contents after every operation. Hints validated by range on both
  sides and resolved independently.
- **C ABI / executor change:** none; the existing `cpp_map_execute_trace` already
  supported every operation.
- **Diagnostic:** `dictionaryRandomizedMismatchReportContainsRequiredContext` tampers
  with a copied returned previous value and proves container pair, seed, operation
  number, input, both observations, `key:value` contents, and the trace through (not
  beyond) the failure. Added because the seeded formatter had not been exercised with
  key/value contents.
- **Result:** no difference or crash.
  - `swift test --disable-sandbox --filter CppBehaviorReferenceTests` — 32 passed (Debug;
    the six parameterized tests ran 5 cases each).
  - `swift test --disable-sandbox -c release --filter CppBehaviorReferenceTests` — 32 passed.
  - `git diff --check` — clean.
- **Changed files:** `Tests/CppBehaviorReferenceTests/DictionaryBehaviorComparisonTests.swift`,
  this file, `Maintanance/CLAUDE_TASK.md`.
- **Remaining gaps:** the value returned by `removeValue(forKey:)` is still compared only
  through count and contents (`erase(k)` has no equivalent); subscript assignment and
  defaulted-subscript mutation have no returned fact and are compared through contents.
  MultiMap has no seeded trace. A Swift-side crash identifies the seed only through the
  parameterized test argument. No shrinking by design.

### MultiMap seeded-randomized result (2026-10-04, Claude Opus 5.5)

Four-container C++ comparison expansion is complete; further breadth is optional.

- **Seeds/count:** shared `SplitMix64`, seeds `[1, 2, 3, 0x5EED, 0xC0FFEE]`, 300
  operations, 40-operation growing/shrinking phases; XCTest base
  `CppBehaviorReferenceTestCase` and per-seed `private func …(seed:)` scopes, as in
  the other three pairs.
- **Generator** (`generateMultiMapTrace`, `MultiMapBehaviorComparisonTests.swift`):
  independent ordered `(key, mappedValue)` model, keys `0...7` plus 1/16
  `Int64.min`/`Int64.max`; every value-bearing operation uses the distinct mapped value
  `1_000 + operation number` (occurrence identity). Generates `insert`, `insertHint`,
  `find`, `lowerBound`, `upperBound`, `equalRange`, `eraseKey`, `eraseAt`, `removeAt`,
  `assignAt`; positional operations on an empty model become an ordinary insert.
  Hint and positional rank policies are the MultiSet ones. The model places hinted
  insertion at `clamp(hint, lower...upper)` ("as close as possible before the hint");
  it feeds only counts/keys to later generation and is not compared against.
- **Coverage test** (`test_multiMapRandomizedTraceIsDeterministicAndCovered`) requires,
  per seed, at least one of each MultiSet event (insert into empty/non-empty,
  duplicate and ≥2-group insert, hint on empty, at start/end, exact/poor,
  before/at start of/inside/at end of/after a group, extreme key, present/absent
  lookup, present/absent/≥2 erase by key, `erase`/`remove` at first/last/interior,
  positional erase inside a ≥2 group, erase to empty, insert after emptied,
  reinsertion of an erased key) plus `assignAt` at first/last/interior and inside a ≥2
  group. All five seeds met it without changing seeds, count, or phase length. It also
  checks identical regeneration of trace and coverage per seed. Per-seed counts were
  not printed (no counter is zero).
- **Compared per operation:** the existing MultiMap adapter's facts — entry and rank
  for `insertHint`; entry, rank, count for `find`; entry and rank for bounds; lower/
  upper rank and entries for `equalRange`; removed count for `eraseKey`; next rank for
  `eraseAt`; erased entry for `removeAt`; previous mapped value for `assignAt` — plus
  complete ordered key/value contents after every operation. Ranks validated on both
  sides (range; Swift also `isElement(at:)`/`isEnd(_:)`) and resolved independently.
- **C ABI / executor change:** none.
- **Diagnostic:** `test_multiMapRandomizedMismatchReportContainsRequiredContext`
  tampers with a copied `assignAt` previous value and proves container pair, seed,
  operation number, input, both observations, `key:value` contents, and the trace
  through (not beyond) the failure.
- **Result:** no difference, crash, or lifetime imbalance.
  - `swift test --disable-sandbox --filter CppBehaviorReferenceTests` — 35 XCTest
    executed, 0 failures (MultiMap 8, MultiSet 11, Dictionary 8, Set 8).
  - `swift test --disable-sandbox -c release --filter CppBehaviorReferenceTests` — 35
    executed, 0 failures.
  - `swift test --disable-sandbox -c debug` (full root, run twice) — exit 0; every
    XCTest bundle reported 0 failures (`CppBehaviorReferenceTests.xctest` 35,
    `RedBlackTreeTests.xctest` 865, …) and every Swift Testing run passed.
  - `git diff --check` — clean.
- **CI:** not checked; `gh` is unavailable locally and the change is uncommitted.
- **Changed files:** `Tests/CppBehaviorReferenceTests/MultiMapBehaviorComparisonTests.swift`,
  this file, `Maintanance/CLAUDE_TASK.md`. (`Maintanance/MAINTENANCE.md` was already
  modified by someone else and was not touched.)
- **Remaining gaps:** `insert(key:value:)` rank has no common return fact (compared via
  contents); Linux was not run locally. No shrinking by design.
- **Linux portability correction:** the first libstdc++ run showed that
  `std::multimap::find` and Swift selected different occurrences from an otherwise
  identical equivalent-key group. Because the C++ standard does not specify which
  equivalent occurrence `find` returns, MultiMap `find` now compares only presence,
  returned key, count, and complete contents; mapped occurrence identity and rank are
  deliberately excluded. Bounds, equal ranges, hinted insertion, and every ordered
  content snapshot remain strict comparisons.

## Test strategy

After the PoC is accepted, implement this in stages:

1. Curated traces for empty, single-element, duplicate-heavy, boundary, and erase/reinsert cases.
2. Seeded randomized traces with the seed and complete trace printed on failure.
3. Regression traces reduced from any randomized failure.
4. Optional CI execution after local stability is established.

The first implementation must be deterministic. Avoid wall-clock measurements and unseeded randomness.

## Non-goals

- Comparing internal tree shape, allocation strategy, node addresses, or iterator representation
- Treating undefined behavior, invalid iterators, or failed preconditions as a parity requirement
- Replacing the existing Swift Test as Specification suite
- Expanding the public API of `AcCollections`
- Reworking `CppBenchmarks`

## Acceptance criteria

- `CppBenchmarks` remains behaviorally and structurally independent.
- The comparison suite runs from the root package.
- All four Swift/C++ container pairs have at least one curated end-to-end trace.
- A mismatch identifies the container, operation number, operation, seed when applicable, Swift observation, and C++ observation.
- MultiMap and MultiSet include a regression case for hinted insertion within an equivalent-key group.
- The task document is updated with the exact command used to run the suite and any platform limitations discovered during implementation.

## Decisions to confirm at implementation time

- Final target names
- Whether the first implementation uses batched traces or one ABI call per operation
- Whether CI should run the suite by default or only in a dedicated job
- The smallest common observable contract for APIs whose Swift and C++ return types differ
