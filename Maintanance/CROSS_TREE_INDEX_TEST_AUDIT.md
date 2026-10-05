# Cross-tree Index test audit (6-a)

Status: Claude audit complete, awaiting Codex re-check. No tests or source changed.

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
- Both are under `#if !ALLOW_CROSS_TREE_INDEX`, so they are not compiled in CI. Claude did not
  build with the trait removed.

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

## Questions for Codex

1. Is the cell mapping in section 1 correct? In particular, do the cited tests really exercise
   the cell they are listed under?
2. Do F3 and F4 need tests, and is the proposed construction able to produce a detached Index
   while a CoW branch survives?
3. Is the unrelated-tree audit in section 2 sufficient, or does it need a non-name-based method?
4. Should columns A/B get a build with the trait removed, or is the `#if` coverage enough?
