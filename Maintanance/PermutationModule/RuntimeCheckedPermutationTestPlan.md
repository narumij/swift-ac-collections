# Runtime-Checked Permutation Test as Specification Plan

## Task

- ID: `PERM-052`
- Type: `DISCOVERY`
- Owner: Codex / Claude
- Proximity to current intermediate goal: `DIRECT`

Current state, ownership, and restart conditions are controlled by the Task Registry.

## Objective

Reconstruct Test as Specification for the current runtime-checked `NextPermutations` contract.
Codex first fixes the contract boundary and successor-test structure. Claude may then perform the
function-level classification and implementation of bounded test groups without deciding product
policy or reviving the retired Copy on Write contract.

## Current implementation boundary

The active implementation in `Sources/PermutationModule/NextPermutations.swift` has this shape:

- `Collection.nextPermutations()` copies the source elements into one owned mutable buffer.
- `NextPermutations<Value>` is `~Copyable`, exposes manual mutating `next()`, and is not a
  `Sequence`.
- Each call returning a value yields a copyable `RandomAccessCollection` view named
  `NextPermutations<Value>.Permutation`.
- A yielded view is valid until the next mutating `next()` call or destruction of its owner.
- `GateKeeper` generation checks reject access through an invalidated view before the element
  pointer is dereferenced.
- Result indices are zero-based `Int` values regardless of the source collection's index type.

The current implementation does not return `Span`. Compile-time lifetime rejection belongs to the
separate borrowed implementation and must not be used as evidence for this runtime-checked type.

## Canonical inconsistency found

`Sources/PermutationModule/Documentation/Quality-Profile.md` correctly describes the active type in
its `対象` section, but later Test as Specification and quality sections still describe the normal
implementation as returning borrowed `Span` values whose invalid uses are rejected by the compiler.
Those statements were inherited from the borrowed experiment and do not match the current source.

Until the profile is corrected, use the active public source, commit `9ff515c9` that adopted
runtime-checked views, the current quality assessment, and the boundaries in this plan to classify
tests. Do not convert the stale `Span` wording into runtime-check product requirements.

## Legacy group disposition

The 38 disabled legacy functions remain historical inputs, not current passing evidence.

| Legacy group | Functions | Disposition for current contract |
| --- | ---: | --- |
| Public surface | 4 | Replace type-name and construction checks for `NextPermutations` and nested `Permutation`; retain negative API checks only where the removed surface is still intentionally absent. Retire old `Sendable` requirements unless a current authoritative contract independently requires them. |
| Enumeration | 11 | Preserve the observable enumeration requirements, but rewrite them around manual `next()` calls rather than `Sequence.map`. |
| Value semantics | 6 | Retire persistent results, iterator copying, COW independence, and cross-task value retention. Replace only where the current contract deliberately requires invalidation instead. |
| Result collection | 6 | Preserve zero-based indices and valid-boundary access. Retire legacy `Equatable`, `Hashable`, and array-like description requirements unless separately adopted for the current view. |
| Coexistence | 2 | Preserve coexistence and semantic distinction from swift-algorithms, using manual iteration for the current API. |
| Internal | 4 | Retire COW copy-count and legacy header details. Replace element initialization/destruction and odd-length reversal coverage with tests of the single owned buffer. |
| Death tests | 5 | Preserve out-of-range rejection and rewrite it for the current nested `Permutation` view. |

The two current runtime death checks and the manual-iteration scratch test in `EtcTests.swift` are
experiments to promote into numbered successor groups. The unrelated `Span` iteration scratch test
does not specify the runtime-checked permutation API.

## Proposed successor test groups

### 0. Public surface and construction

- `nextPermutations()` is available to collections whose elements are `Comparable`.
- Array, Range, Slice, and a non-`Int`-indexed collection can construct the current type.
- The returned owner and nested view have the intended public type names.
- Direct public initialization remains unavailable if that is still an intentional boundary.
- `NextPermutations` remains noncopyable and does not conform to `Sequence`; use compiler-backed
  fixtures where runtime tests cannot express the negative requirement.

Do not infer `Sendable`, `Equatable`, `Hashable`, or presentation guarantees from the retired type.

### 1. Enumeration

- The input itself is returned first.
- Ascending input reaches all lexicographic successors in order.
- A non-first starting order yields only itself and later orders.
- Descending, empty, single-element, and all-equal inputs yield once.
- Equal elements do not create duplicate value orders.
- Array, Range, Slice, and non-`Int`-indexed input preserve the same value rule.
- The source collection is not modified.
- Once finished, repeated `next()` calls consistently return `nil`.

Use a test-only helper that consumes each live view before calling `next()` again. Do not collect
the views themselves for later comparison.

### 2. Runtime view validity

- A current view can be iterated and indexed before the next mutating access.
- Calling `next()` invalidates the previous view, including when the call returns `nil`.
- Destroying the owner invalidates an escaped view without dereferencing freed element storage.
- Invalidation is checked by `startIndex`, `endIndex`, and subscript access, not only by one sample
  subscript.
- Copies of the same current view observe the same invalidation generation.

These are runtime failure contracts. Do not describe them as compiler-enforced borrowing.

### 3. Permutation collection

- `startIndex == 0`, `endIndex == count`, and ordinary iteration expose the current order.
- Source index type and source start index do not affect result indices.
- Valid first and last positions can be read.
- `-1`, `endIndex`, a position beyond `endIndex`, `Int.min`, and `Int.max` are rejected.
- Empty-view indices and iteration are consistent with `RandomAccessCollection`.

### 4. Ownership and destruction

- Source elements are copied into the owned buffer and remain independent of later source changes.
- Partially consumed, fully consumed, empty, and never-started owners destroy each initialized
  element exactly once.
- Odd-length suffix reversal preserves element identity and lifetime.
- Escaped invalid views may retain the gate keeper but do not retain or access deallocated element
  storage.

Implementation probes belong in an internal group and must not become public guarantees merely
because they are observable in a test.

### 5. Coexistence and exposure

- `PermutationModule` and swift-algorithms can be imported together without name-resolution
  conflict.
- `nextPermutations()` retains its successor-only meaning while `permutations()` enumerates every
  positional ordering.
- `AcCollections` reexports the intended public entry point.
- AtCoder 2025 compatibility mode remains a separate surface and evidence path.

## Bounded Claude work

After Codex accepts this structure, Claude can receive separate decision-free assignments:

1. Produce a ledger containing each of the 38 legacy functions exactly once, mapped to a successor
   group or `RETIRED`, without changing tests.
2. Implement groups 1 and 3 from the accepted ledger.
3. Implement runtime validity death tests in group 2.
4. Implement ownership/destruction tests in group 4.
5. Implement public-surface fixtures and coexistence checks in groups 0 and 5.

Each implementation assignment must report the exact tests added and validation run. Passing tests
are returned evidence; Codex performs acceptance and Registry updates.

## Unresolved questions

- The public source currently has only a plain implementation comment rather than complete
  documentation comments for the entry point, owner, view, and invalidation behavior. Test
  reconstruction must not silently make undocumented behavior a new public promise.
- The Quality Profile must be corrected from borrowed-`Span` language to runtime invalidation before
  it can again serve as a consistent specification map.
- Whether direct initialization and specific negative public-surface checks should be permanently
  fixed remains subject to the current public API contract, not merely the old test technique.
- Exact process termination matching for runtime invalidation and bounds failures should follow the
  repository's current Death Test convention rather than the broad `.failure` scratch assertions.

## Discovery completion conditions

- The active runtime-check contract and the separate borrowed contract are no longer mixed.
- All legacy groups have a defined disposition and successor destination.
- Runtime, compiler-surface, ownership/destruction, and coexistence evidence are separated.
- Remaining product ambiguities are visible and are not decided by test implementation.
- Claude assignments contain no product-policy decision.
