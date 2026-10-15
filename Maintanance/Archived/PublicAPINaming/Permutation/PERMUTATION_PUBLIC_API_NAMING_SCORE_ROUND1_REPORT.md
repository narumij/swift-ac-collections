# PermutationModule公開API名称 Round 1統合報告

## 状態

2026-10-15のUser・姫・V3による初回独立採点を統合した判断材料。採用判断ではない。
三者は同じ34候補を採点したが、尺度の使い方が異なるため、合計・平均・多数決ではなく、
各採点者内の相対評価、理由、反証、対立点を読む。

## Score matrix

| 対象 | シンボル | ID | User | 姫 | V3 |
| --- | --- | --- | --- | --- | --- |
| Module | `PermutationModule` | `MN-01` | 4 | 8 | 7 |
| Module | `LexicographicPermutationModule` | `MN-02` | 1 | 3 | 5 |
| Module | `NextPermutationModule` | `MN-03` | 5 | 4 | 8 |
| 通常入口 | `nextPermutations()` | `NE-01` | 5 | 7 | 8 |
| 通常入口 | `lexicographicPermutationSuffix()` | `NE-02` | 1 | 3 | 5 |
| 通常入口 | `remainingPermutations()` | `NE-03` | 1 | 4 | 4 |
| 通常入口 | `lexicographicPermutationCursor()` | `NE-04` | 1 | 3 | 5 |
| 通常入口 | `checkedNextPermutations()` | `NE-05` | 1 | 3 | 4 |
| 通常入口 | `permutationsFromCurrentOrder()` | `NE-06` | 1 | 4 | 6 |
| 通常owner | `NextPermutations` | `NO-01` | 5 | 7 | 6 |
| 通常owner | `LexicographicPermutationSuffix` | `NO-02` | 1 | 3 | 4 |
| 通常owner | `RemainingPermutations` | `NO-03` | 1 | 3 | 4 |
| 通常owner | `LexicographicPermutationCursor` | `NO-04` | 1 | 4 | 7 |
| 通常owner | `CheckedNextPermutations` | `NO-05` | 1 | 3 | 4 |
| 通常owner | `NextPermutationCursor` | `NO-06` | 2 | 5 | 8 |
| 通常view | `Permutation` | `NV-01` | 5 | 6 | 5 |
| 通常view | `View` | `NV-02` | 4 | 6 | 7 |
| 通常view | `CurrentPermutation` | `NV-03` | 4 | 5 | 8 |
| 通常view | `CurrentPermutationView` | `NV-04` | 4 | 4 | 7 |
| 通常view | `EphemeralPermutation` | `NV-05` | 1 | 3 | 5 |
| borrowed入口 | `borrowedNextPermutations()` | `BE-01` | 5 | 6 | 8 |
| borrowed入口 | `borrowedLexicographicPermutationSuffix()` | `BE-02` | 1 | 2 | 4 |
| borrowed入口 | `borrowedRemainingPermutations()` | `BE-03` | 1 | 3 | 4 |
| borrowed入口 | `borrowedLexicographicPermutationCursor()` | `BE-04` | 1 | 2 | 4 |
| borrowed入口 | `nextPermutationSpans()` | `BE-05` | 2 | 4 | 6 |
| borrowed入口 | `lendingNextPermutations()` | `BE-06` | 1 | 5 | 5 |
| borrowed owner | `BorrowedNextPermutations` | `BO-01` | 5 | 6 | 7 |
| borrowed owner | `BorrowedLexicographicPermutationSuffix` | `BO-02` | 1 | 2 | 4 |
| borrowed owner | `BorrowedRemainingPermutations` | `BO-03` | 1 | 3 | 4 |
| borrowed owner | `BorrowedLexicographicPermutationCursor` | `BO-04` | 1 | 3 | 5 |
| borrowed owner | `NextPermutationSpans` | `BO-05` | 2 | 4 | 5 |
| borrowed owner | `BorrowedNextPermutationCursor` | `BO-06` | 1 | 4 | 7 |
| Generic parameter | `Value` | `GP-01` | 4 | 6 | 4 |
| Generic parameter | `Element` | `GP-02` | 5 | 5 | 8 |

## 尺度の違い

- Userは各判断群の有力候補に主に`5`、好みに合わない案に`1`を付け、選好境界を明瞭にした。
- 姫は互換性・family予測性・package内語彙を重く見て、主に`2`〜`8`を使った。
- V3は契約の説明力を重く見て、rename案にも比較的高い点を使った。
- このため、たとえばUserの`5`とV3の`8`を強さの差として直接比較しない。

## 判断群ごとの統合

### Module名

`MN-01 PermutationModule`と`MN-03 NextPermutationModule`が対立する。

- UserとV3は`MN-03`を群内最高とした。C++の`next_permutation`との近さ、検索性、入口との語幹整合を評価した。
- 姫は`MN-01`を最高とした。通常は`AcCollections`からimportされ、module名へ機能の細部を載せる便益より、
  rename費用と将来scopeを重く見た。
- `MN-02`は三者とも第一候補ではなく、長さとscope制限が共通の反証になった。

### 通常版入口

三者とも`NE-01 nextPermutations()`を群内最高とした。短さ、C++由来の理解、現行互換、
`NO-01`・`BE-01`とのfamily整合が支持理由である。初回に現在の並びを返すこと、非`Sequence`、
互換modeで別APIを指すことは残る反証だが、他候補は長さまたは新しい誤読を増やすと評価された。

### 通常版owner

Userと姫は`NO-01 NextPermutations`を群内最高、V3は`NO-06 NextPermutationCursor`を最高とした。

- `NO-01`は入口から予測でき、互換性がある。
- V3は`Cursor`が非`Sequence`の手動状態を表す点を評価した。
- Userは`Cursor`を「Swift側で意味的に凍結されている印象」として明示的に退けた。
- 姫も`NO-06`の役割説明は認めるが、入口との語幹ずれと非標準語を反証にした。

したがって、これは情報不足よりも、既存familyの予測性とowner役割の説明力のどちらを優先するかという
価値判断である。

### 通常版一時view

選好が分かれた。

- Userは`NV-01 Permutation`を最高とし、`NV-02`〜`NV-04`も僅差で残した。
- 姫は`NV-01 Permutation`と`NV-02 View`を同点最高とした。
- V3は`NV-03 CurrentPermutation`を最高とし、一時性と順列性の両立を評価した。

共通の対立は、短く自然な役割名を取るか、一時viewであることを型名へ載せるかである。
どの案も具体的な失効境界は文書を必要とするため、長い名前だけで契約説明を完結できない。

### Borrowed版入口・owner

三者とも入口は`BE-01 borrowedNextPermutations()`、ownerは`BO-01 BorrowedNextPermutations`を群内最高
または同率最高とした。通常版との語幹対応と補完上の予測性が、`borrowed`の係り先の曖昧さを上回った。
`Span`案は結果型を明示するが集合所有に見え、`lending`案は構造的には正確でもSwift語彙として弱い。

### Generic parameter

UserとV3は`GP-02 Element`、姫は`GP-01 Value`を高くした。

- `Element`は両ownerのDocC・診断を統一する。
- `Value`はnested `Permutation.Element`との衝突を避ける現行実績がある。

好みだけでなく、`Element`へ変更した宣言が無理なくcompileしDocC表示も改善するかという実装可能性を
最終判断前に確認できる。

## Round 1から得られた判断候補

点数による自動採用ではないが、次の三項目は三者の理由が同じ方向を向いている。

- 通常版入口: `nextPermutations()`維持
- borrowed版入口: `borrowedNextPermutations()`維持
- borrowed版owner: `BorrowedNextPermutations`維持

次の三項目はユーザー判断または追加確認が有効である。

- Module名: `PermutationModule`対`NextPermutationModule`
- 通常版一時view: `Permutation`対`View`対`CurrentPermutation`
- Generic parameter: `Value`対`Element`。後者はcompile・DocC上の実現性確認が可能

通常版ownerはUserの`Cursor`への反証が明示されているため、再採点より、その反証を踏まえて
`NextPermutations`を維持するかをユーザーが決める段階にある。

## 次工程

Round 2を行うなら、全34候補を再採点せず、上記の対立項目だけを対象にし、Round 1を上書きしない。
追加採点を行わず、技術確認とユーザー最終決定へ進むこともできる。

## ユーザー暫定判断

2026-10-15、ユーザーは「三者の理由が同じ方向を向いている」と整理した次の三項目を暫定確定した。

- `NE-01 nextPermutations()`
- `BE-01 borrowedNextPermutations()`
- `BO-01 BorrowedNextPermutations`

これは残るsurfaceの判断前の暫定記録であり、名称決定正本への正式採用、rename、実装変更ではない。
