# RedBlackTree以外のコメントドック・セルフレビュー

## TL;DR（人間向け）
2026-10-10にRedBlackTree以外の公開コメントを実装・テストと照合した記録です。未解決のiterator copy事象は未確認のまま保持し、OptionalArrayのsetterは既確認の実装境界として扱っています。これは当時のレビュー記録で、現在の指示や未解決状態を更新するものではありません。

On 2026-10-10, public declarations in `AcCollections`, the regular `PermutationModule`, `OptionalArrayModule`, and `BareArrayModule` were checked against their implementations and corresponding tests. Compatibility mode, RedBlackTree, tests, fixtures, and C helpers were out of scope.

## 結果

- `AcCollections`: re-exports are verified as reachable by dedicated tests; it has no independent public declarations.
- `BareArrayModule`: ownership, View lifetime, axis order, the writeback-only setter, bounds, and complexity matched the implementation and ordinary tests and death tests.
- No comment discrepancy was found that could be corrected without a product decision.

## 製品判断または追加検証が必要な候補

1. `PermutationModule` documents iterator-copy independence as a public contract, and corresponding tests exist. However, a TODO in the source records an unresolved case where, in a Swift 6.4 Release configuration, advancing the original iterator affected its copy. It has not been established whether this comes from the implementation or the compiler, so no comment change is inferred. Keep it unverified until reproduction is checked before 1.0.
2. The setters on multidimensional subscripts and View subscripts in `OptionalArrayModule` silently ignore arbitrary `newValue`. A recheck of `OptionalElementBufferAudit.md` found that the user had confirmed on 2026-10-08 that this is an implementation mechanism for chained-subscript writeback, not a public contract to assign an entire View. Therefore, this is not a new product-decision candidate; retain the current approach of omitting setter implementation details from public comments.

## Claude独立照合の受入

On 2026-10-10, Codex accepted Claude's read-only cross-check as an evidence package, not as a completion verdict. In addition to the two observations above, Codex accepted the following candidate fixes that need no decision:

- `NextPermutationsSequence.makeIterator()` copies the source collection into a buffer and is therefore O(n), but the public comment did not state its complexity.
- The element subscripts of `OptionalArray1D` and `OptionalArray1DView` destroy the old element when a non-`nil` value overwrites an initialized slot, as fixed by tests, but the comments did not say so.
- The axis description for `OptionalArray4D` was written as `array[size3][size2][size1][size0]`, making dimension names look like index values; it could use index symbols instead.
- The 1D `BareArray` description still referred to a “multidimensional array.”

Codex did not accept classifying `next()` termination or OptionalArray bounds as `UNVERIFIED` solely because there were no public specification tests. The implementation and existing tests were enough to confirm consistency with the comments. The fact that `removeAll()` can be called on a `let` owner was also not considered a comment restriction users need. Whether the three modules are ready for an initial public release remains a separate Codex assessment and is not derived from Claude's conclusion.

## 後続対応

On 2026-10-10, the user instructed that track A be carried out.

- For Permutation, complexity was checked across the public entry point, Index, equality comparison, hashing, and description, not only `makeIterator()`, and implementation-based statements were added. OptionalArray and BareArray already documented the public operations for which complexity should be stated; no new discrepancy with the implementation was found.
- For OptionalArray overwrite destruction, separate `_modify` implementations for the owning 1D type and 1DView, together with lifetime tests for both paths, fixed the contract. It was not an unstateable contract; the draft had described only assignment of `nil` and omitted non-`nil` overwrite, a significant coverage gap. Comments were updated on both subscripts to say that the previous element is destroyed and replaced.
- The OptionalArray4D axis wording and the 1D BareArray “multidimensional array” wording received minimal corrections.
- Xcode build succeeded. File diagnostics for OptionalArray and BareArray were zero. The two Permutation file diagnostics were existing unsafe/unused-result warnings unrelated to this comment diff. Documentation builds for all three targets succeeded with `--warnings-as-errors`.

## DOC-018: 公開コメントのparameter欄補完

Add DocC `Parameter`/`Parameters` sections to public API comments for declarations with arguments in BareArray, OptionalArray, and Permutation. Do not change existing public contracts. Confirm the meaning of each argument against the implementation and tests. Acceptance requires checking parameter coverage for the target declarations and successful documentation builds for all three targets.

Completed 2026-10-10. The 29 public declarations with parameters (15 BareArray, 11 OptionalArray, and 3 Permutation) were checked, and their `Parameter`/`Parameters` sections were completed. Axis, position, and closure descriptions were limited to wording established by the existing implementation and tests. All three targets passed documentation builds with `--warnings-as-errors`.
