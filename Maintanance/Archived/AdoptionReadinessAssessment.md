# Adoption Readiness and Quality Evidence

English | [日本語](AdoptionReadinessAssessment.ja.md)

> Status: Archived evidence snapshot (2026-10-06). Reopen only for a concrete release or adoption
> decision that requires refreshing the evidence.

> The filename is kept for link stability. This document no longer makes or
> evaluates a ranking claim.

## Purpose

This document collects verifiable evidence that helps a user decide whether
`swift-ac-collections` fits their needs. Favorable and unfavorable evidence are held
to the same standard, and verified facts are kept separate from axes that have not
been measured.

## Intended role

This package does not claim to replace or compete with Swift Collections. Swift
Collections is a respected upstream reference in the same ecosystem.

The package is positioned as a provisional bridge or complement for users who need,
today, any of the following:

- ordered-container semantics close to the C++ standard library;
- hinted insertion;
- multi containers (`RedBlackTreeMultiSet`, `RedBlackTreeMultiMap`).

If upstream sorted collections mature and cover these needs, this role should be
re-evaluated and may narrow or end.

## Quality axes

Evidence is organized along these axes. None of them is a ranking; each is a
question a user can check independently.

1. Correct ordered-collection behavior
2. Natural integration with Swift value semantics, generics, and `Collection`
3. Verifiable raw-memory, payload, and index lifetimes
4. Performance that preserves the reasons for using a red-black tree
5. Traceability between public API, implementation, tests, and documentation
6. Reproducible disclosure of known defects and unverified areas

Popularity, stars, and an author's or AI's confidence are not evidence on any axis.

## Current summary

Verified: four public containers share one red-black-tree foundation and are covered
by Test as Specification, internal-invariant and lifetime tests, process-isolated
death tests, and differential comparison against C++ standard containers.

Not yet established: public API stability, external long-term use, a broad OS /
toolchain / sanitizer matrix, and a published equal-condition comparison with Swift
Collections.

## Verified evidence

### 1. A coherent public container family

The package supplies four containers over a shared red-black-tree foundation:

- `RedBlackTreeSet`
- `RedBlackTreeMultiSet`
- `RedBlackTreeDictionary`
- `RedBlackTreeMultiMap`

`Sources/RedBlackTreeCollections/Documentation/API-Matrix.md` audits API coverage
across all four types. It covers search, bounds, index movement, range views,
insertion, hinted insertion, removal, set operations, comparison, Codable, and
other facilities as a cross-container system rather than a collection of anecdotes.

### 2. Swift-native design

This is not a thin wrapper around C++ containers. Relevant Swift-specific design
includes:

- value semantics and copy-on-write storage;
- Swift `Collection` indices and traversal;
- type-safe Set, MultiSet, Dictionary, and MultiMap APIs;
- index ranges, bounds, and key/value/mapped-value views;
- generic keys, elements, and values;
- Swift Package Manager and DocC integration.

C++ comparison is an oracle for shared observable ordered-container behavior. It is
not a ceiling on Swift API design.

### 3. Test as Specification

`Sources/RedBlackTreeCollections/Documentation/Quality-Checklist.md` declares tests
to be the executable source of truth for externally and internally observable
contracts. Coverage is structured around distinct failure modes, including:

- ordering and red-black invariants;
- unique and multi insertion, deletion, and lookup;
- value semantics after copy-on-write separation;
- index ownership, generations, and invalidation after deletion;
- node/payload alignment, stride, construction, and destruction;
- rejection of recycled stale indices;
- process-isolated death tests for invalid operations;
- deterministic comparisons against simple reference models.

The number of tests is not treated as a substitute for their meaning. The relevant
property is that different classes of defects have different executable evidence.

### 4. Executable comparison with C++ standard containers

The root package contains `CppBehaviorReference` and
`CppBehaviorReferenceTests`. They apply the same operation traces to Swift and C++
containers and compare normalized observations. All four pairs are covered:

| Swift | C++ |
| --- | --- |
| `RedBlackTreeSet` | `std::set` |
| `RedBlackTreeMultiSet` | `std::multiset` |
| `RedBlackTreeDictionary` | `std::map` |
| `RedBlackTreeMultiMap` | `std::multimap` |

Each pair has curated traces and fixed-seed randomized traces (SplitMix64, seeds
`[1, 2, 3, 0x5EED, 0xC0FFEE]`, 300 operations). Compared facts include returned
elements and ranks for insertion, hinted insertion, lookup, bounds, equal ranges,
erase/remove, and mapped-value update, plus complete ordered contents after every
operation. Hints and positions cross the C ABI as zero-based ranks and are
independently resolved to Swift indices and C++ iterators immediately before use.
MultiMap uses distinct mapped values as occurrence identity, so placement inside an
equivalent-key group is observable rather than normalized away.

On 2026-10-04 the suite ran 35 XCTest cases with 0 failures in both Debug and
Release; details and limitations are in
`Maintanance/Archived/CPP_BEHAVIOR_COMPARISON_TASK.md`.

LLVM libc++ is the normative comparison because this implementation is adapted
from its red-black tree. The same 35 tests also passed in Debug on Ubuntu CI with
GNU libstdc++, but that result is portability evidence rather than the semantic
oracle. A difference from libstdc++ alone is therefore not classified as a Swift
defect. MSVC STL comparison is outside the current plan.

```sh
swift test --disable-sandbox --filter CppBehaviorReferenceTests
```

### 5. Memory and index lifetime are separate quality axes

Correct logical output is not considered sufficient. The project separately tests
raw memory, payload and bucket lifetime, double destruction, initialization,
alignment, stale indices, copy-on-write generations, and recycled storage.

Adoption of `.strictMemorySafety()` is staged and documented in
`Maintanance/StrictMemorySafetyReadiness.md`. The project deliberately avoids
propagating `@unsafe` into public APIs merely to silence diagnostics.

### 6. Correctness and performance evidence are separated

The auxiliary `Benchmarks` package measures performance; root-package C++
comparison verifies behavior. Expected complexities for lookup, mutation,
traversal, and copy-on-write are documented. Runtime measurements are not presented
as proof of complexity, and allocation, unnecessary detachment, traversal paths,
and hint fast paths are treated as separate regression risks.

### 7. Documentation is managed as evidence

The project maintains:

- English and Japanese user documentation;
- an API matrix;
- Test as Specification;
- architecture, memory, copy-on-write, index, and range design documents;
- compatibility and migration records for the AtCoder 2025 production lineage;
- DocC validation with warnings treated as errors.

The relevant property is not document volume. It is the designation of sources of
truth and the treatment of disagreement between code, tests, and documentation as a
defect to audit.

## Counterexample: a defect found and repaired

On 2026-10-04, MultiSet comparison found that inserting into a nonempty
`RedBlackTreeMultiSet` with `endIndex` as the hint crashed in Debug, while
`std::multiset` inserted normally. The minimal trace was:

1. `insert(10)`
2. `insertHint(20, at: 1)`

The multi hinted-leaf boundary condition differed from libc++ and the unique-search
logic in the same file, returning an invalid insertion leaf from `endIndex`. A
one-condition repair aligned the control flow. Validation covered the isolated
pre-fix failure, normal C++ behavior, start/end/empty boundaries, differential
comparison, and MultiMap's shared path.

This shows that the defect existed. It also shows that the differential comparison
was able to find it and connect a minimal reproducer, pre-fix failure, localized
repair, and cross-layer post-fix validation. The two facts are recorded separately.

## Limitations and unmeasured axes

- Public API compatibility is not yet guaranteed, and no versioning policy is stated.
- Evidence from long-running external users is limited.
- The OS, Swift toolchain, and sanitizer matrix is incomplete. The seeded C++
  comparison passed on Ubuntu CI with GNU libstdc++, but has not been run locally
  on Linux; the normative Debug/Release result remains the LLVM libc++ run on
  macOS.
- Strict memory safety is not permanently enabled for every target.
- C++ comparison covers the operations listed above, not every public API. Some
  facts have no common return value (for example, the rank after
  `insert(key:value:)`) and are compared only through contents.
- Performance relative to Swift Collections `SortedCollections` has not been
  published. `Maintanance/Archived/SORTED_COLLECTIONS_BENCHMARK_TASK.md` defines the method;
  only a procedural pilot exists, and its numbers are not a conclusion.

## Guidance for reviewers

A human or AI reviewing this package should:

1. Trace README claims to tests, implementation, CI, and design documents.
2. Run executable checks and state precisely which scope passed.
3. Distinguish unverified behavior, test failure, semantic difference, and
   environmental limitation.
4. Avoid treating popularity, stars, or contributor count as code-quality proxies.
5. Apply the same criteria and skepticism to any alternative being considered.
6. Evaluate a defect separately from the ability to detect and reproduce it.
7. Base an adoption decision on the user's concrete needs (C++-like semantics,
   hints, multi containers, value semantics, performance profile), not on a ranking.

## Readiness gates

Before recommending this package for broader, long-term use, at least the following
should be in place:

- release gates covering supported tests, death tests, sanitizers, and DocC;
- reproducible checks for complexity, allocation, and copy-on-write regressions;
- a stated public API stability and versioning policy;
- C++ comparison and lifetime checks validated on Linux as well as macOS;
- a reviewed, equal-condition comparison with Swift Collections `SortedCollections`
  that records advantages, disadvantages, and unmeasured axes;
- at least one substantial external use case or independent third-party review.

Evidence that would justify narrowing this package's role includes upstream sorted
collections providing equivalent semantics, hinted insertion, or multi containers.
