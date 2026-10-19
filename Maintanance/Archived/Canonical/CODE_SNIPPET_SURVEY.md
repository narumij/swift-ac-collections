# コードスニペット候補アンケート

## TL;DR（人間向け）
BareArray、OptionalArray、Permutationの公開APIから、利用者向けスニペットの効果が高いメソッドを選んだ調査記録です。統合TOP10と選定理由を残しています。これは当時の調査結果であり、現在の作業指示ではありません。

## 対象task

`DOC-019` — Survey of the Top 10 candidate methods for code snippets

## 目的

Select, from two AI responses, the symbols for which adding user-facing code snippets would have the greatest benefit across the public APIs of BareArray, OptionalArray, and Permutation. This is a prioritization exercise to help users understand and avoid misuse through examples; it is not an audit of whether existing comments are correct.

## 実施方法

Codex and Claude each rank up to ten methods for which a code snippet would especially help users understand behavior, avoid misuse, or decide whether to adopt the API. Responses are kept in separate files to avoid concurrent editing conflicts.

- Codex writes only to `CODE_SNIPPET_SURVEY_CODEX.md`.
- Claude writes only to `CODE_SNIPPET_SURVEY_CLAUDE.md`.
- Both keep this shared document, source, and tests read-only to avoid write conflicts during concurrent work.

Each response must state the symbol, rank, the user's likely question, the minimum behavior the snippet should demonstrate, and why the existing explanation alone is insufficient. Do not select an item solely because it is a representative API or because a comprehensive tutorial would be useful. Initializers, subscripts, and operators may be candidates; explain when multiple dimensions of the same pattern are listed separately.

After both responses are finalized, Codex will summarize their agreements and differences here, and return an integrated Top 10 plus candidates that fell outside the list but received split opinions.

## 回答状態

- Codex response: finalized 2026-10-10
- Claude response: finalized 2026-10-10
- Integration: completed 2026-10-10

## 統合TOP10

Candidates raised by both responses for the same use case were prioritized. Dimension variants were retained only when a separate example need was explained.

1. `Collection.nextPermutations()` — It returns only permutations at or after the current ordering; sorting first is required to enumerate all permutations.
2. `OptionalArray1D.subscript(_:)` — Initially unset slots, setting a value, and unsetting it with `nil`.
3. `BareArray2D.subscript(_:)` — The axis order in `array[y][x]` and ordinary chained writes.
4. `OptionalArray2D.subscript(_:)` — Reading, writing, and clearing Optional slots through a View.
5. `BareArray.init(count:_:)` — Sequential creation through a closure and the fact that the closure is not called for zero elements.
6. `BareArray4D.init(repeating:size0:size1:size2:size3:)` — How numbered axes correspond to `array[w][z][y][x]`.
7. `OptionalArray1D.removeAll()` — Reusing storage after resetting every slot to unset.
8. `NextPermutationsSequence.Permutation.subscript(_:)` — A zero-based Index independent of the source.
9. `NextPermutationsSequence.Iterator.next()` — Manual iteration, early termination, and stability of already-produced results.
10. `OptionalArray4D.init(size0:size1:size2:size3:)` — The 4D axis order and that every slot starts unset.

## 一致と相違

- Strong agreement: `nextPermutations()`, the OptionalArray1D subscript, chained subscripting for BareArray2D and OptionalArray2D, the closure initializer, BareArray4D, `removeAll()`, and Permutation's zero-based Index.
- For Iterator, Codex chose copy independence at `makeIterator()`, while Claude chose manual iteration and value stability at `next()`. The integration uses `next()` as the direct entry point for a snippet.
- Claude selected the `BareArray` type and `~Copyable` as important, but the user requested a Top 10 of methods, so these were excluded from the integrated ranking. Keep them as candidates for type-page snippets.
- Only Codex selected OptionalArray4D. It remains at rank 10 because one example can demonstrate both initially unset slots and axis order for 4D.

The survey primarily considered public declarations and comments. Use tests only to verify facts when behavior to be shown in a snippet cannot be established as part of the public contract; tests are not a required input to candidate selection.

## 対象外

- Adding snippets to source, public comments, or user-facing documentation
- Final decisions on publication location or wording
- RedBlackTree APIs, compatibility mode, internal APIs, and test-only APIs

Treat snippet selection and placement as a separate task after this survey is accepted.
