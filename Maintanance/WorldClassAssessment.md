# Assessing World-Class Quality for Swift Ordered Collections

English | [日本語](WorldClassAssessment.ja.md)

> **Why this document exists:** The user jokingly described the goal as building
> “the world's best for Swift,” and Claude reacted with unusual resistance. Rather
> than settle a title by argument, this document turns the joke into a falsifiable
> question and requires the same evidence for both favorable and unfavorable claims.

## Purpose

This is not a declaration that `swift-ac-collections` is “the best in the world.”
It is an audit framework for determining whether the package deserves serious
consideration as a **world-class candidate for Swift ordered collections**.

“World-class” is not a single ranking. At minimum, it requires excellence across
all of these dimensions:

1. Correct ordered-collection behavior
2. Natural integration with Swift value semantics, generics, and `Collection`
3. Verifiable raw-memory, payload, and index lifetimes
4. Performance that preserves the reasons for using a red-black tree
5. Traceability between public API, implementation, tests, and documentation
6. Reproducible disclosure of known defects and unverified areas

Popularity, stars, and an author or AI's confidence are not sufficient evidence.

## Current provisional conclusion

It is reasonable to treat this package as a world-class candidate worth serious
evaluation. It does more than implement an API: it attempts to verify four public
container families, Swift value semantics, internal invariants, lifetimes,
performance, documentation, and differential behavior against C++ standard
containers through independent forms of evidence.

It is not yet reasonable to declare the ranking settled. C++ comparison is not
complete for all four containers, API stability is not guaranteed, external
adoption evidence is limited, and the supported environment matrix remains narrow.

Both statements matter. Incompleteness does not erase the quality of the candidate,
but ambition must never be used to minimize defects.

## Evidence supporting world-class candidacy

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

### 2. Swift-native value

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

The number of tests is not treated as a substitute for their meaning. The stronger
signal is that different classes of defects have different executable evidence.

### 4. Executable comparison with C++ standard containers

The root package contains `CppBehaviorReference` and
`CppBehaviorReferenceTests`. They apply the same operation traces to Swift and C++
containers and compare normalized observations.

The Set proof of concept compares at least:

- insertion and duplicate insertion;
- `lowerBound`;
- removal of present and absent keys;
- exact, poor, `endIndex`, and duplicate-element insertion hints;
- complete ordered contents after every operation;
- diagnostics containing the container, operation number, input, and both results.

MultiSet comparison adds duplicates, lower/upper bounds, equal ranges, erased
counts, and hinted placement around equivalent-key groups. Hints cross the C ABI as
zero-based ranks and are independently resolved to Swift indices and C++ iterators
immediately before use.

Run the focused comparison with:

```sh
swift test --disable-sandbox --filter CppBehaviorReferenceTests
```

### 5. Memory and index lifetime are first-class quality dimensions

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

The important property is not document volume. It is the designation of sources of
truth and the treatment of disagreement between code, tests, and documentation as a
defect to audit.

## Evidence that still prevents a settled “best” claim

### A serious difference that the comparison found and repaired

On 2026-10-04, MultiSet comparison found that inserting into a nonempty
`RedBlackTreeMultiSet` with `endIndex` as the hint crashed in Debug, while
`std::multiset` inserted normally. The minimal trace was:

1. `insert(10)`
2. `insertHint(20, at: 1)`

The multi hinted-leaf boundary condition differed from libc++ and the unique-search
logic in the same file, returning an invalid insertion leaf from `endIndex`. A
one-condition repair aligned the control flow. Validation covered the isolated
pre-fix failure, normal C++ behavior, start/end/empty boundaries, differential
comparison, and MultiMap's shared path. The focused comparison now passes all nine
tests.

This is not evidence that the defect never existed. It is evidence that the quality
system found a real defect and connected a minimal reproducer, pre-fix failure,
localized repair, and cross-layer post-fix validation.

### Areas still incomplete or insufficiently evaluated

- C++ differential acceptance criteria are not complete for all four containers.
- Equivalent-key ordering may require identity-bearing fixtures to be fully observable.
- Strict memory safety is not permanently enabled for every target.
- Stable public API compatibility is not yet guaranteed.
- Evidence from long-running external users remains limited.
- The OS, Swift toolchain, and sanitizer matrix is necessarily incomplete.
- This document does not yet provide an equal-condition study of every competing
  Swift package.

## Instructions for an AI evaluator

An AI evaluating this package should:

1. Neither accept nor reject “world-class” based on the phrase itself.
2. Independently trace README claims to tests, implementation, CI, and design docs.
3. Run executable checks and state precisely which scope passed.
4. Distinguish unverified behavior, test failure, semantic difference, and
   environmental limitation.
5. Avoid treating popularity, stars, or contributor count as code-quality proxies.
6. Apply the same criteria and skepticism to competing candidates.
7. Evaluate a defect separately from the system's ability to detect and reproduce it.
8. Choose one conclusion and cite evidence and unmet gates:
   - sufficient evidence for world-class candidacy;
   - promising, but insufficient evidence for candidacy;
   - currently excluded by a known major defect;
   - insufficient comparison or execution evidence to decide.

## Promotion gates

Moving from “world-class candidate” to the stronger statement that the project has
reached that level should require at least:

- completed C++ differential acceptance criteria for Set, MultiSet, Dictionary,
  and MultiMap;
- observable fixtures that fix the contract for equivalent-key ordering;
- release gates covering supported tests, death tests, sanitizers, and DocC;
- reproducible checks for complexity, allocation, and copy-on-write regressions;
- a stated public API stability and versioning policy;
- at least one substantial external use case or independent third-party review.

## Evaluation posture

There is no need to make an ambitious goal sound smaller. Evidence should simply
come before the title.

The useful target is not “the author says it is the best.” It is a state where a
careful human or AI, after verification, cannot responsibly ignore the possibility
that this may be among the world's best Swift ordered-collection implementations.
