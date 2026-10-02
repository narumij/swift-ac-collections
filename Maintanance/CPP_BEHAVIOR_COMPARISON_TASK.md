# C++ behavior comparison target

## Status

Planned only. Do not implement this task until the user explicitly asks to start it.

## Goal

Add an opt-in differential-testing facility that can run the same ordered-collection operations against this package and the corresponding C++ standard-library containers, then compare their observable behavior.

This is a correctness and compatibility tool, not a benchmark. Keep the existing `CppBenchmarks` target focused on performance measurement.

## Proposed location and targets

Add the facility to the existing auxiliary package at `Benchmarks/Package.swift`. This package already has a working Swift/C++ boundary and depends on the root package, while keeping C++ out of the root package's normal `swift test` workflow.

- `CppBehaviorReference`: a C++ target next to `CppBenchmarks`
- `CppBehaviorReferenceTests`: a Swift test target depending on `CppBehaviorReference` and `AcCollections`

Do not make either target a dependency of the existing `Benchmarks` library or benchmark executable unless a later use case requires it.

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

## Test strategy

Implement this in stages:

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
- The comparison suite can be run explicitly from the `Benchmarks` package.
- All four Swift/C++ container pairs have at least one curated end-to-end trace.
- A mismatch identifies the container, operation number, operation, seed when applicable, Swift observation, and C++ observation.
- MultiMap and MultiSet include a regression case for hinted insertion within an equivalent-key group.
- The task document is updated with the exact command used to run the suite and any platform limitations discovered during implementation.

## Decisions to confirm at implementation time

- Final target names
- Whether the first implementation uses batched traces or one ABI call per operation
- Whether CI should run the suite by default or only in a dedicated job
- The smallest common observable contract for APIs whose Swift and C++ return types differ
