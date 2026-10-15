# PermutationModule公開API名称 Round 2統合報告

## 状態

2026-10-15のUser・姫・V3によるRound 2再採点を統合した判断材料。採用判断ではない。
Round 1後に残った4判断・9候補だけを対象とし、初回票は保持した。

## Score matrix

| 対象 | シンボル | ID | User R1→R2 | 姫 R1→R2 | V3 R1→R2 |
| --- | --- | --- | --- | --- | --- |
| Module | `PermutationModule` | `MN-01` | 4→3 | 8→6 | 7→8 |
| Module | `NextPermutationModule` | `MN-03` | 5→5 | 4→7 | 8→7 |
| 通常owner | `NextPermutations` | `NO-01` | 5→5 | 7→8 | 6→8 |
| 通常owner | `NextPermutationCursor` | `NO-06` | 2→3 | 5→3 | 8→5 |
| 通常view | `Permutation` | `NV-01` | 5→5 | 6→6 | 5→6 |
| 通常view | `View` | `NV-02` | 4→5 | 6→5 | 7→7 |
| 通常view | `CurrentPermutation` | `NV-03` | 4→5 | 5→6 | 8→8 |
| Generic parameter | `Value` | `GP-01` | 4→5 | 6→5 | 4→6 |
| Generic parameter | `Element` | `GP-02` | 5→5 | 5→7 | 8→7 |

点数は尺度内の動きを見るために併記し、三者間で合計・平均しない。

## Module名

Userは`NextPermutationModule`を維持し、姫は`PermutationModule`優位から`NextPermutationModule`優位へ
移った。入口`nextPermutations()`の暫定確定により語幹整合が具体化し、swift-algorithmsの全列挙との
区別も理由になった。

V3は逆に`PermutationModule`を僅差で上へ移した。通常は`AcCollections`経由で利用され、module renameの
便益が入口ほど大きくないこと、将来scopeと互換性を重く見た。

これは事実不足ではなく、module名を現在の中心機能へ寄せるか、将来の総称として保つかのユーザー判断である。
Round 2上のUser選好は`NextPermutationModule`。

## 通常版owner

三者とも`NextPermutations`を明確に上位とした。

- 暫定確定した入口`nextPermutations()`とborrowed owner`BorrowedNextPermutations`の両方に語幹がそろう。
- `NextPermutationCursor`は非`Sequence`の状態機械を説明するが、通常版だけ`Cursor`にするとfamily対応が崩れる。
- Userの`Cursor`に対するSwift語彙上の違和感も残った。

Round 2で最も収束した未決項目であり、`NextPermutations`維持をユーザー判断へ渡せる。

## 通常版一時view

Userは3候補をすべて`5`とし「どれでもいい」とした。姫は`Permutation`と`CurrentPermutation`を同点、
V3は`CurrentPermutation`を最高とした。

- `Permutation`: 最短でcall siteが自然。独立所有値に見える問題は文書で補う。
- `View`: 一時参照性を示すが、`NextPermutations.View`では順列一件という意味が薄い。
- `CurrentPermutation`: 順列性と現在bufferとの関係を両立するが、失効条件はやはり文書が要る。

三者の理由を合わせると`Permutation`または`CurrentPermutation`が残る。Userは委ねており、短さ・互換性を
取るなら前者、型名にも現在性を載せるなら後者である。

## Generic parameter

Userは`Value`と`Element`を同点とした。姫とV3は`Element`を上位とした。

姫は一時directoryのSwift 6.4最小codeで、外側generic parameterを`Element`にし、nested
`RandomAccessCollection`で明示typealiasを書かずに`Permutation.Element`が解決することを確認した。
これは実sourceの`@inlinable`等を含む検証ではないが、Round 1の「名前衝突で成立しないかもしれない」という
懸念を弱める。

両ownerの宣言・DocC・診断を揃える`Element`が判断候補となる。実sourceでのcompile確認はrename実装時の
受入条件として残す。

## 最終判断へ渡す整理

### 暫定確定済み

- 通常入口: `nextPermutations()`
- borrowed入口: `borrowedNextPermutations()`
- borrowed owner: `BorrowedNextPermutations`
- 通常owner: `NextPermutations`
- Generic parameter: `Element`。実sourceのcompile・DocC確認はrename実装時の受入条件

### Round 2後の判断候補

- Module: User選好は`NextPermutationModule`。`PermutationModule`維持との価値判断が残る。
- 通常owner: 2026-10-15にユーザーが`NextPermutations`を暫定確定。
- 通常view: `Permutation`または`CurrentPermutation`。Userはいずれでもよい。
- Generic parameter: 2026-10-15にユーザーが`Element`を暫定確定。最小compile証拠あり。

ここから先は再採点より、ユーザーが残る4項目を明示する段階である。
