# リポジトリ公開APIコードスニペット候補アンケート第2弾

## TL;DR（人間向け）
公開API全体のコメントドックに加える短い利用例の候補をCodexとClaudeの回答から統合した記録です。スニペット実装や掲載場所の決定は対象外です。これは当時の調査・受入記録であり、現在の作業指示ではありません。

## 対象task

`DOC-020` — Round 2 survey of the Top 10 candidate methods for public API code snippets

## 目的と対象

Select, from the repository's public API, the places where adding a short usage example to the API's comment documentation would be most valuable. Do not exclude any particular module. Internal and test-only APIs are out of scope because they are not public APIs.

## 実施方法

- Codex responds in `PUBLIC_API_CODE_SNIPPET_SURVEY_2_CODEX.md`.
- Claude responds in `PUBLIC_API_CODE_SNIPPET_SURVEY_2_CLAUDE.md`.
- Separate response files avoid concurrent editing conflicts.
- Base judgments primarily on public declarations and their current comment documentation; use tests to confirm only unclear behavior.
- For each candidate, state the symbol, rank, likely user question, minimum behavior to demonstrate, and why the current explanation is insufficient.

After both responses are finalized, Codex summarizes their agreements and differences here.

## 回答状態

- Codex response: complete
- Claude response: complete and accepted by Codex
- Summary: complete

## 両回答のまとめ

Both responses prioritized cases where a short example of calling the API and its result communicates a distinctive contract more quickly than adding more prose. Five shared high-priority areas were:

1. Point and range access on RedBlackTree using boundary expressions
2. The mutable Values View returned by `RedBlackTreeMultiMap.subscript(key:)`
3. The starting position and enumeration range of `Collection.nextPermutations()`
4. Unset, set, and `nil`-clearing behavior of `OptionalArray1D.subscript(_:)`
5. Axis order and chained subscripting with a non-symmetric BareArray shape

For RedBlackTree, Codex also proposed Dictionary's default subscript, the insert-only contract, the MultiSet values View, and melding. Claude proposed neighbor search, `eraseUnique`/`eraseMulti`, relative movement of boundary expressions, and removal using a retained Index. Keep all as candidates; decide actual publication ranking and create snippets in a follow-up task.

Claude found that existing snippets for the RedBlackTree types still used `.advance(by:)` and `.endIndex`, which do not match current public names `.advanced(by:)` and `.end`. It also found an example of `RedBlackTreeSet.upperBound(_:)` that included duplicate values in a Set. Record these as existing-comment correction candidates, separate from new snippet candidates.

The API-name mismatch was corrected under `DOC-021` in three type-comment files and six Head documents. On 2026-10-11, Codex accepted Claude's successful compile and execution of nine examples using a temporary client, the absence of old spellings in the target scope, and a successful Xcode build of current HEAD. Output-comment wording and the `upperBound(_:)` example remained out of scope.

## 受入

On 2026-10-10, Codex confirmed that both responses covered the repository's public API and recorded each candidate's symbol, user question, minimum behavior, and gap in the existing explanation. Separate response files were treated as a way to avoid concurrent editing conflicts; unread responses or independence were not acceptance criteria. The second survey was marked complete.

## 対象外

Implementing snippets, deciding where to publish them, and changing public comments or user-facing documentation are separate tasks.
