# Cross-tree Index test audit (6-a)

Status: Completed. Claude audit and follow-up tests independently re-checked by Codex on
2026-10-06.

2026-10-05 / Claude Opus 5.5, on `develop/misc/49` at `cfbf8cf8`.

## Why this needs a re-check

The user is not confident they can accept this audit on their own review, because gaps of this
kind can slip through review. Please verify the claims below independently, rather than adopting
them.

## Yardstick

- `Sources/RedBlackTreeCollections/Implements/Index/index_stale_check.md`: the user's resolution
  table.
- `Sources/RedBlackTreeCollections/Documentation/Design/Design-RuntimeChecks.md`, section
  "Indexの解決": the same table for the standard configuration, plus the rule that an Index from an
  unrelated collection is a precondition violation and detection is not guaranteed.

The standard configuration is `ALLOW_CROSS_TREE_INDEX` on and `USE_LAZY_DETACH` off. This audit
covers its columns E (same tree) and F (different tree; a CoW branch counts as a different tree).
Columns A/B (CROSS off) are covered separately below. Columns C/D/G/H (LAZY on) are deprecated
and out of scope.

## 1. Cell-to-test mapping (standard configuration)

All paths are under `Tests/RedBlackTreeTests/`.

| Cell | Expected | Set | MultiSet | Dictionary | MultiMap |
| --- | :---: | --- | --- | --- | --- |
| E1 same tree, healthy | o | many | many | many | many |
| E2 same tree, generation mismatch | x | `_3` `testIsElementAndIsEndRejectStaleIndex`; `_98` `testStaleIndexAfterSlotRecycledWithNewGenerationIsRejected` | same two | same two | same two |
| E3 / E4 same tree, detached | - | not constructible | — | — | — |
| F1 different tree, healthy | o | `_3` `testIsElementAndIsEndResolveIndicesInCopiedTree` | same | same | same |
| F2 different tree, generation mismatch | x | `_3` `testIndexValidityAgainstOriginIsUnaffectedByCopyThenMutateCoW`, `…AfterConsecutiveMutations…`; `_98` RangeView variants | `_98` RangeView variants only | `_98` RangeView variants only | **none** |
| F3 different tree, detached | o | **none** | **none** | **none** | **none** |
| F4 different tree, detached + generation mismatch | x | **none** | **none** | **none** | **none** |

Notes:

1. **F1:** in the chat overview Claude first said this existed for Set only. That was wrong; all
   four `_3_IndexSequenceTests.swift` have it.
2. **F3 / F4:** `RedBlackTreeSet_98_IndexValidityXCTests.swift`
   `testIndexOutlivingItsStorageIsDetachedAndRejectedByAnotherReceiver` is the only detached test.
   - Its receiver is an **empty** tree, so the Index is rejected because its tag is not found in
     the receiver (`tag < initializedCount` fails).
   - It therefore exercises neither F3 nor F4. No test shows that a detached Index still resolves
     in a surviving CoW branch (F3), or that it is rejected there when that node was recycled (F4).
3. **F2 / MultiMap:** no F2 test exists for MultiMap, neither direct nor RangeView.

## 2. Unrelated-tree audit

Rule: tests must not pin down the outcome of using an Index from an unrelated collection.

- Method: a regex scan of the five container/View test directories plus `RedBlackTreeInternal`.
  It looked for lines where one collection's Index (`startIndex`, `endIndex`, `find`,
  `firstIndex`, `lowerBound`, `upperBound`, `index…`) is passed to a *different* named receiver
  (`isElement(at:)`, `isEnd(_:)`, `erase(exactly:)`, `remove(at:)`, index movement, subscript).
- Every hit falls into one of these:
  - CoW copies (`copy`/`source`, `a`/`b`): F1/F2.
  - Views over the same base (`view`/`set`, `view`/`dictionary`).
  - Compatibility-mode slices of the same tree (`sub`/`set`).
  - The same variable under another name.
- The only unrelated-tree test is
  `RedBlackTreeSet_99_AdditionalDeathTests.swift:81` `index from another tree cannot be
  subscripted`. It is under `#if !COMPATIBLE_ATCODER_2025 && !ALLOW_CROSS_TREE_INDEX`, which is
  column B and not compiled in the standard configuration.
- Conclusion: in the standard configuration, no test pins unrelated-tree behavior.
- Limitation: the scan is name-based. Indirect flows, such as an Index stored in a variable or a
  helper, can be missed.

## 3. Counterintuitive expectations

`RedBlackTreeSet_3_IndexSequenceTests.swift` asserts two behaviors with comments that call them
surprising:

- line ~50: `XCTAssertTrue(a.isElement(at: b0), "直感に反するが、発行元では引き続き要素として扱われる")`
- line ~74: `XCTAssertTrue(a.isElement(at: b0), "ソース側世代チェックが省略されているため")`

Both match the design table ("CoWで分岐した相手の変更は、このIndexの有効性に影響しない"): an Index
is judged against the receiving tree's node only. The behavior is consistent with the contract.
The comments do not reference the design document.

## 4. Columns A/B (CROSS off)

- B1 (different tree, healthy → x):
  - `RedBlackTreeInternal/Instance/RedBlackTreeInternal_PurifiedTests.swift` `testExample3`
    (`.crossTree`);
  - the Set Death Test above.
- Both are under `#if !ALLOW_CROSS_TREE_INDEX`, so they are not compiled in CI.

### Smoke test with `ALLOW_CROSS_TREE_INDEX` removed (Ⅶ, 2026-10-05)

`Package.swift` was backed up to a `mktemp -d` directory and the define was commented out.
Afterwards the file was restored (no diff) and the directory removed.

- Build: the tests build cleanly.
- Full `swift test`: fails (exit 1). The column-B Swift Testing Death Test
  `index from another tree cannot be subscripted` passes. The failures are in tests that assume CROSS
  on but are not guarded by `#if ALLOW_CROSS_TREE_INDEX`:
  1. `RedBlackTreeMappedValuesViewTests.test_subrangeValuesSingleIndexOperations_doNotCompareKeys`
     hits `Fatal error: crossTree` (`UnsafeTreeV2+Subscript.swift:42`).
     - Writing through the View CoWs its storage, and the base dictionary's indices then count as
       another tree.
     - The fatal error **kills the RedBlackTreeTests XCTest process**, so later XCTests in that
       bundle did not run. That includes `RedBlackTreeInternal_PurifiedTests.testExample3`, which
       was therefore not confirmed.
  2. `CppBehaviorReferenceTests.DictionaryBehaviorComparisonTests.test_dictionaryHintedInsertionMatchesCpp`
     hits `Fatal error: Attempting to access RedBlackTree elements using an invalid index`
     (`RedBlackTreeDictionary.swift:299`). This also kills that XCTest process.
  3. `RedBlackTreeMultiSet_99_DeathTests.insertWithHintIntoEmptyMultiSet_exitsSuccessfully`
     expects a successful exit but gets a signal. An Index from the empty shared singleton becomes
     "another tree" once the first insertion detaches it.
- Interpretation: every failure is the column-B behavior the table predicts, since a CoW'd or
  detached-from-singleton storage counts as another tree when CROSS is off. These are not
  regressions in the standard configuration. CROSS=OFF is simply not a runnable configuration for
  the current suite.
- User decision (2026-10-05): knowing that the suite fails under CROSS=OFF is enough. The tests
  are not guarded; the premise has been fixed to CROSS on for a long time.

## Proposed changes (not applied)

1. Add F3 and F4 specs: Set first, then the other three types if they pass.
   - F3: create `source`, make a CoW copy, keep only the copy alive, and let `source`'s storage
     be freed, so that an Index taken from `source` is detached. Then expect
     `copy.isElement(at: index)` to be `true`.
   - F4: same setup, but remove and re-insert in the copy so the slot is recycled. Then expect
     `false`.
   - Constructing a truly detached Index while a CoW sibling survives needs care. The Index's tie
     must belong to storage that has actually been freed, not merely one that has been uniquely
     mutated. Please check the construction against how `_LazyTie` detaches.
2. Add an F2 spec for MultiMap.
3. Add a `Design-RuntimeChecks.md` reference to the two comments in section 3.

## Follow-up: specs added (2026-10-05, after the audit)

The user asked Claude to proceed with proposals 1 and 2 before the Codex re-check. Proposal 3
(comment references) was applied afterwards as Ⅱ-α.

- F3 and F4 specs were added to all four `_3_IndexSequenceTests.swift`:
  - `testIndexOutlivingItsOriginResolvesInSurvivingCopy`
  - `testIndexOutlivingItsOriginIsRejectedAfterSurvivingCopyRecyclesItsNode`
- An F2 spec was added to `RedBlackTreeMultiMap_3_IndexSequenceTests.swift`:
  `testIndexValidityAgainstOriginIsUnaffectedByCopyThenMutateCoW`.
- Construction: the source and its copy are built inside an `@inline(never)` helper. The copy is
  mutated first, so CoW gives it its own buffer. The helper returns the copy and an Index taken
  from the source, so the source's buffer is freed when the helper returns.
- Premise check: `RedBlackTreeSet_98_IndexValidityXCTests.swift` has two internal tests. Both
  assert `lazyDetach.isDetached`, which the public specs cannot observe.
  - `testIndexFromFreedOriginIsDetachedWhileCopySurvives` covers the F3 construction. It also
    asserts that the Index is *not* detached while the source is alive.
  - `testIndexFromFreedOriginIsDetachedAndRejectedByGenerationInSurvivingCopy` covers the F4
    construction. It also asserts that the copy still has three elements, so the rejection comes
    from the generation match and not from a missing tag.
- Results:
  - all 12 new tests pass, with no source change;
  - full `swift test` (Debug): exit 0;
  - compatibility-mode test build: succeeds.
- The premise is now checked on all four types (Ⅱ-β, 2026-10-05): the same two internal tests were
  added to the MultiSet, Dictionary, and MultiMap `_98_IndexValidityXCTests.swift`, and all six pass.

The questions below still stand. Question 2 now has evidence, but the construction still deserves
an independent look.

## Questions for Codex

1. Is the cell mapping in section 1 correct? In particular, do the cited tests really exercise
   the cell they are listed under?
2. Do F3 and F4 need tests, and is the proposed construction able to produce a detached Index
   while a CoW branch survives?
3. Is the unrelated-tree audit in section 2 sufficient, or does it need a non-name-based method?
4. Should columns A/B get a build with the trait removed, or is the `#if` coverage enough?

## Codex independent re-check (2026-10-06)

Verdict: accept and close this audit.

1. The cell mapping is correct for the standard configuration. After the follow-up, F2 has direct
   coverage in MultiMap as well as the previously cited coverage, and F3/F4 have public behavior
   specs in all four collection types.
2. F3/F4 deserve tests because detached origin storage selects a distinct resolver path from an
   ordinary live CoW source. The construction is valid: mutation first gives the returned copy its
   own buffer, returning from the `@inline(never)` helper releases the source buffer, and the
   internal tests in all four types directly confirm `lazyDetach.isDetached`. F4 also preserves an
   allocated corresponding slot and changes its generation, so rejection is not merely a missing-tag
   result.
3. The unrelated-tree audit is sufficient for this closure. Its name-based limitation is real, but
   the public contract deliberately leaves unrelated-tree misuse unspecified, and no contrary test
   was found. A more elaborate data-flow audit would not change the acceptance criterion here.
4. No additional columns A/B build is required. The trait-off smoke build already succeeded and
   the test failures matched the predicted cross-tree behavior. The user has classified CROSS=OFF
   as effectively deprecated, so making that full suite green is not a completion requirement.

Codex also re-ran the focused F2/F3/F4 and detached-premise selection with
`swift test --disable-sandbox --filter 'testIndex(OutlivingItsOrigin|FromFreedOrigin|ValidityAgainstOrigin)'`:
18 tests passed with no failures. The first attempt without `--disable-sandbox` was rejected while
initializing SwiftPM's sandbox and did not execute tests.
