# PermutationModule公開API名称採点 — User Round 1

## 状態

Round 1初回採点用。採点者: ユーザー。候補集合と意味・懸念は
`PERMUTATION_PUBLIC_API_NAMING_BALLOT.md`を正本とする。

他者のRound 1採点を読む前に記入する。各判断群の候補を同じ尺度で比較し、全行へ`1`〜`9`の
総合点と短い理由を記録する。点数は採用判断ではなく、合計・平均・多数一致で自動決定しない。
再評価はこの表を上書きせず、次roundへ分ける。

## Round 1採点表

| 対象surface | 候補シンボル | Candidate ID | Score（1〜9） | 支持理由 | 反証・懸念 | 他candidateとの関係 |
| --- | --- | --- | --- | --- | --- | --- |
| Module名 | `PermutationModule` | `MN-01` | 4 | とくなし | swift-algorithmとのかぶり | わからない |
| Module名 | `LexicographicPermutationModule` | `MN-02` | 1 |  | 趣味じゃない | わからない |
| Module名 | `NextPermutationModule` | `MN-03` | 5 |  |  | わからない |
| 通常版入口 | `nextPermutations()` | `NE-01` | 5 |  |  | わからない |
| 通常版入口 | `lexicographicPermutationSuffix()` | `NE-02` | 1 |  | 趣味じゃない | わからない |
| 通常版入口 | `remainingPermutations()` | `NE-03` | 1 |  | 趣味じゃない | わからない |
| 通常版入口 | `lexicographicPermutationCursor()` | `NE-04` |  1|  | 趣味じゃない | わからない |
| 通常版入口 | `checkedNextPermutations()` | `NE-05` | 1 |  | 趣味じゃない | わからない |
| 通常版入口 | `permutationsFromCurrentOrder()` | `NE-06` | 1 |  | 長すぎる | わからない |
| 通常版owner | `NextPermutations` | `NO-01` | 5 |  |  | わからない |
| 通常版owner | `LexicographicPermutationSuffix` | `NO-02` | 1 |  | 趣味じゃない | わからない |
| 通常版owner | `RemainingPermutations` | `NO-03` | 1 |  | 趣味じゃない | わからない |
| 通常版owner | `LexicographicPermutationCursor` | `NO-04` | 1 |  | 趣味じゃない | わからない |
| 通常版owner | `CheckedNextPermutations` | `NO-05` | 1 |  | 趣味じゃない | わからない |
| 通常版owner | `NextPermutationCursor` | `NO-06` | 2 |  | Cursorは意味的にSwift側で凍結されている印象だから | わからない |
| 通常版一時view | `Permutation` | `NV-01` | 5 |  |  | わからない |
| 通常版一時view | `View` | `NV-02` | 4 |  |  | わからない |
| 通常版一時view | `CurrentPermutation` | `NV-03` | 4 |  |  | わからない |
| 通常版一時view | `CurrentPermutationView` | `NV-04` |  4|  |  | わからない |
| 通常版一時view | `EphemeralPermutation` | `NV-05` |  1|  | 趣味じゃない | わからない |
| borrowed版入口 | `borrowedNextPermutations()` | `BE-01` | 5 |  |  | わからない |
| borrowed版入口 | `borrowedLexicographicPermutationSuffix()` | `BE-02` | 1 |  | 趣味じゃない | わからない |
| borrowed版入口 | `borrowedRemainingPermutations()` | `BE-03` | 1 |  | 趣味じゃない | わからない |
| borrowed版入口 | `borrowedLexicographicPermutationCursor()` | `BE-04` | 1 |  | 趣味じゃない | わからない |
| borrowed版入口 | `nextPermutationSpans()` | `BE-05` | 2 |  |  | わからない |
| borrowed版入口 | `lendingNextPermutations()` | `BE-06` | 1 |  | 趣味じゃない | わからない |
| borrowed版owner | `BorrowedNextPermutations` | `BO-01` | 5 |  |  | わからない |
| borrowed版owner | `BorrowedLexicographicPermutationSuffix` | `BO-02` | 1 |  | 趣味じゃない | わからない |
| borrowed版owner | `BorrowedRemainingPermutations` | `BO-03` | 1 |  | 趣味じゃない | わからない |
| borrowed版owner | `BorrowedLexicographicPermutationCursor` | `BO-04` | 1 |  | 趣味じゃない | わからない |
| borrowed版owner | `NextPermutationSpans` | `BO-05` | 2 |  |  | わからない |
| borrowed版owner | `BorrowedNextPermutationCursor` | `BO-06` | 1 |  | ursorは意味的にSwift側で凍結されている印象だから  | わからない |
| 補助宣言名 | `Value` | `GP-01` | 4 |  | どっちでもいい |  |
| 補助宣言名 | `Element` | `GP-02` | 5 |  | どっちでもいい |  |

## 採点完了確認

- 全候補を同じ`1`〜`9`尺度で採点した。
- シンボル名だけでなく、ballotの意図、誤読、互換コストを確認した。
- familyの整合に影響する場合は「他candidateとの関係」へ記録した。
- 他者のRound 1採点を読む前に完了した。
