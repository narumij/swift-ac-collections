# C++ behavior comparison target

## Status

**High priority — Set PoC complete; review checkpoint before expansion.** The user
raised this work's priority on 2026-10-04 because agreement with the C++
standard-library containers is important evidence for completing the red-black-tree
implementation.

Start with the bounded Set PoC below. Do not broaden the first implementation to
all four container pairs until the PoC result has been reviewed.

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
