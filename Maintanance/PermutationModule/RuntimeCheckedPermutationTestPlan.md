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

## Quality Profile alignment

`Sources/PermutationModule/Documentation/Quality-Profile.md` correctly describes the active type in
its `対象` section, but later Test as Specification and quality sections still describe the normal
implementation as returning borrowed `Span` values whose invalid uses are rejected by the compiler.
Those statements were inherited from the borrowed experiment and do not match the current source.

Codex aligned those later sections with the already-recorded runtime-check contract: a yielded
`Permutation` View remains readable until the next mutating access or owner destruction, after which
runtime checks reject access. The correction also removes the obsolete Swift 6.2 package-exclusion
plan without asserting that the current Swift 6.4 package supports Swift 6.2.

Use the corrected profile, the active public source, commit `9ff515c9` that adopted runtime-checked
views, the current quality assessment, and the boundaries in this plan to classify tests. The
alignment does not add `Sendable`, value semantics, compiler-enforced View lifetimes, or other new
public guarantees.

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

## Legacy function ledger

Each of the 38 disabled legacy functions appears exactly once below. `G0` through `G5` refer to the
successor groups in this plan. `RETIRED` means that the old assertion is not a contract of the
runtime-checked implementation; an inverse runtime-invalidity test may still exist in `G2` without
reviving the retired value-semantics guarantee.

| Legacy file | Function | Destination | Current disposition |
| --- | --- | --- | --- |
| `_0_PublicSurfaceTests` | `testPublicTypeNames` | `G0` | Replace old sequence/iterator names with `NextPermutations` and nested `Permutation`; use manual `next()` |
| `_0_PublicSurfaceTests` | `testSendableConformances` | `RETIRED` | No current authoritative `Sendable` contract |
| `_0_PublicSurfaceTests` | `testRemovedMethodsAreNotExposed` | `G0` | Preserve absence of retired unsafe entry points with a compiler-backed surface check |
| `_0_PublicSurfaceTests` | `testSequenceIsNotPubliclyInitializable` | `G0` | Preserve the source-established entry boundary: construction through `nextPermutations()` |
| `_1_EnumerationTests` | `testTwoElements` | `G1` | Rewrite with manual `next()` and immediate View consumption |
| `_1_EnumerationTests` | `testFromAscendingOrderEnumeratesAll` | `G1` | Preserve lexicographic successor order |
| `_1_EnumerationTests` | `testStartsFromCurrentOrder` | `G1` | Preserve successor-only enumeration from the current order |
| `_1_EnumerationTests` | `testDescendingYieldsOnce` | `G1` | Preserve terminal input behavior |
| `_1_EnumerationTests` | `testAllEqualYieldsOnce` | `G1` | Preserve equal-element terminal behavior |
| `_1_EnumerationTests` | `testEmptyYieldsOnce` | `G1` | Preserve one empty result |
| `_1_EnumerationTests` | `testSingleElementYieldsOnce` | `G1` | Preserve one single-element result |
| `_1_EnumerationTests` | `testEqualElementsAreNotDuplicated` | `G1` | Preserve value-order deduplication |
| `_1_EnumerationTests` | `testAcceptsNonArrayIntIndexedSources` | `G1` | Preserve Range and nonzero-start Slice inputs |
| `_1_EnumerationTests` | `testAcceptsNonIntIndexedSources` | `G1` | Preserve non-`Int` source indices |
| `_1_EnumerationTests` | `testSourceIsNotModified` | `G1` | Preserve source independence; consume each View before advancing |
| `_2_ValueSemanticsTests` | `testRetainedResultsRemainStable` | `RETIRED` | Persistent results contradict generation invalidation; inverse behavior belongs to `G2` |
| `_2_ValueSemanticsTests` | `testCollectedResultsCanBeReadLater` | `RETIRED` | Views must not be collected for later access |
| `_2_ValueSemanticsTests` | `testIteratorCopiesAdvanceIndependently` | `RETIRED` | Owner is `~Copyable` |
| `_2_ValueSemanticsTests` | `testIteratorCopiesAdvanceIndependentlyWhenAdvancedInsideAssertion` | `RETIRED` | Old copied-iterator regression is inapplicable |
| `_2_ValueSemanticsTests` | `testYieldedValueRemainsStableAcrossTask` | `RETIRED` | No persistent cross-task View or `Sendable` guarantee |
| `_2_ValueSemanticsTests` | `testIteratorCopiesAdvanceIndependentlyAcrossTasks` | `RETIRED` | Owner copying and cross-task independence are not current contracts |
| `_3_PermutationCollectionTests` | `testIndicesStartAtZeroForArraySource` | `G3` | Preserve zero-based `Int` indices for Array input |
| `_3_PermutationCollectionTests` | `testIndicesStartAtZeroForAnySource` | `G3` | Preserve result indices independently of source index type and origin |
| `_3_PermutationCollectionTests` | `testEquatableComparesElementOrder` | `RETIRED` | Current View has no adopted `Equatable` guarantee |
| `_3_PermutationCollectionTests` | `testHashableFollowsElementOrder` | `RETIRED` | Current View has no adopted `Hashable` guarantee |
| `_3_PermutationCollectionTests` | `testDescriptionLooksLikeArray` | `RETIRED` | Presentation is not an adopted contract |
| `_3_PermutationCollectionTests` | `testSubscriptAtValidBoundaries` | `G3` | Preserve valid first and last element access |
| `_4_CoexistenceTests` | `testBothPermutationAPIsResolveWithoutQualification` | `G5` | Rewrite current API side with manual iteration |
| `_4_CoexistenceTests` | `testNextPermutationsYieldsOnlySuccessorsWhileAlgorithmsYieldsEveryOrder` | `G5` | Preserve semantic distinction from swift-algorithms |
| `_98_InternalTests` | `testBufferDestroysHeaderOnce` | `G4` | Replace legacy header probe with current owned-buffer destruction evidence |
| `_98_InternalTests` | `testNoCopyWhenFinishingWhileLastResultIsRetained` | `RETIRED` | Retaining a result across `next()` is invalid; old COW copy count is inapplicable |
| `_98_InternalTests` | `testOddLengthReverseKeepsElementLifetimes` | `G4` | Preserve identity and exactly-once destruction through odd-length reversal |
| `_98_InternalTests` | `testNoCopyWhenResultsAreNotRetained` | `RETIRED` | Legacy `_copyCount` and COW implementation detail no longer exist |
| `_99_DeathTests` | `endIndexRead_traps` | `G3` | Rewrite against current nested `Permutation` and exact trap convention |
| `_99_DeathTests` | `negativeIndexRead_traps` | `G3` | Rewrite against current nested `Permutation` and exact trap convention |
| `_99_DeathTests` | `pastEndIndexRead_traps` | `G3` | Rewrite against current nested `Permutation` and exact trap convention |
| `_99_DeathTests` | `intMinIndexRead_traps` | `G3` | Rewrite against current nested `Permutation` and exact trap convention |
| `_99_DeathTests` | `intMaxIndexRead_traps` | `G3` | Rewrite against current nested `Permutation` and exact trap convention |

Ledger totals: `G0` 3、`G1` 11、`G3` 8、`G4` 2、`G5` 2、`RETIRED` 12、total 38。
`G2` has no legacy positive counterpart because runtime invalidation replaces, rather than preserves,
the old persistent-value contract. Its initial inputs are the two current scratch Death Tests.

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
- The Quality Profile alignment must be reviewed with the successor ledger before accepting the
  discovery result; agreement between the plan and profile alone is not evidence that every required
  test has been identified.
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

## Codex baseline validation（2026-10-13）

- Xcode build-for-testing: success、error 0。
- `swift test --disable-sandbox --filter PermutationTests`: success。
- XCTestは27件成功した。内訳はborrowed版25件と`EtcTests` 2件であり、runtime-check通常版を直接扱う
  通常testは手動列挙1件だけである。
- Swift Testingは`RuntimeCheckedPermutationDeathTests` 2件が成功した。
- user-level SwiftPM cacheがread-onlyというenvironment warningは出たが、buildとtest結果には影響しなかった。

この成功は現行scratch checksの基準点であり、後継Test as Specificationが揃ったことを意味しない。
