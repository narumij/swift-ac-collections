# PermutationModule 仕様

本書は `PermutationModule` の現行の公開APIを記述する。2026-10-03、
`Maintanance/CLAUDE_TASK.md` のユーザー最終決定に基づき、`swift-algorithms` の
`permutations()` と重複する全順列列挙APIと、`unsafe`系の公開APIを削除した。
削除の経緯・削除根拠(PoC)・段階的な実施記録は
`Maintanance/PermutationModule/ImplementationPlan.md` を参照。

## モジュールの存在理由(観測可能な背景として記録)

`remotes/origin/release/AtCoder/2025` の `README.md` に由来の記述がある。
ABC328Eの解説コードを読んだ際、「全探索で間に合っている」ように見えたが、
実際は `next_permutation` が辞書順の変化だけを行うために列挙数が抑えられていた、
という誤解を追いかける過程で生まれたモジュールである。モジュールの価値は
「辞書順で次を1つ求める」操作であり、「全順列を列挙する」操作はその過程で
派生的に実装されたに過ぎない。

## 公開API(現行)

入口は `Collection where Index == Int` への唯一の拡張メソッドである。

| API | 戻り値の型 | CoW | 役割 |
| --- | --- | --- | --- |
| `nextPermutations()` | `Permutations<Self>.Nexts` | あり | C++の`next_permutation`相当。現在の並びから辞書順で後続する並びだけを1つずつ求める |

`Permutations<C>` 列挙体の下のネスト型で公開されているのは次の3つのみ。いずれも
`nextPermutations()` の戻り値型を構成するために必要であり、利用者が直接初期化する
入口ではない(初期化子は`internal`)。

| 型 | 公開範囲 | 役割 |
| --- | --- | --- |
| `Permutations.Nexts` | public struct(`Sequence`) | `nextPermutations()`の戻り値型 |
| `Permutations.IteratorN` | public struct(`IteratorProtocol`) | `Nexts`のイテレータ |
| `Permutations.SubSequenceN` | public struct(`RandomAccessCollection`) | `Nexts`がyieldする要素 |

`Permutations.Buffer`(`ManagedBuffer`継承)と`Permutations.Header`は
`@usableFromInline`止まりで非公開。

## 削除された公開API(2026-10-03、ソース破壊的変更)

以下は `swift-algorithms` の `permutations()` と重複する全順列列挙、または
`unsafe`系の公開初期化経路として削除された。全順列が必要な利用者は
`swift-algorithms` の `permutations()` を使用する。

- `unsafePermutations()`(Collection拡張メソッド)
- `Permutations.All`、`Permutations.All.init(safe:)` / `init(unsafe:)`
- `Permutations.IteratorA`
- `Permutations.SubSequenceA`
- `unsafeNextPermutations()`(Collection拡張メソッド)
- `Permutations.Nexts.init(safe:)` / `init(unsafe:)` の**公開**初期化子
  (`Nexts`型自体と`init`は内部実装として残り、`nextPermutations()`経由でのみ
  到達できる)

削除前、`All`系が無CoW(`unsafe`)で内部バッファへの参照を共有したまま結果を返す
挙動(結果を即座に消費せず保持・再利用すると全てが同じ内部状態に収束して見える
非直感的な挙動)は、利用者向けの公開契約としては提示しない方針とした。この
エイリアシング挙動自体は削除対象であり、代替APIとして残す設計にはしていない。

## 観測可能な公開契約(ユーザー向けの振る舞い)

1. `nextPermutations()` は、現在の要素並びを最初に返し、要素値の比較に基づいて
   辞書順で後続する並びだけを列挙する。既に降順の場合や全要素が比較上等しい場合は、
   現在の並びを1回返して終了する。比較上等しい要素は`next_permutation`と同様に
   扱われるため、同じ値並びを位置の違いだけで重複列挙しない。
2. イテレータを先へ進めた後も、それ以前に取り出した各`SubSequenceN`の値はCoWにより
   保持され、書き換わらない(`Tests/PermutationTests/PermutationTests.swift` の
   `testNextPermutationsRetainedResultsRemainStable` で固定)。
3. **計算量**: 1ステップは最悪O(n)。
4. **添字の事前条件**: `SubSequenceN[position]` の `position` は
   `startIndex..<endIndex` の範囲内でなければならない。範囲外の添字は事前条件違反で
   あり、`precondition` により実行時に停止する(Debug/Releaseとも。
   `Tests/PermutationTests/PermutationDeathTests.swift` で `endIndex`・`-1`・
   `endIndex + 1`・`Int.min`・`Int.max`を固定)。`-Ounchecked` ビルドではこの検査が
   省略されうる。

## `Sendable`

Swift 6以降への対応として、値を持たない`Permutations`と、保持する`C`が`Sendable`の
場合の`Nexts`は`Sendable`へ適合する。共有CoW bufferを持つ`IteratorN`と
`SubSequenceN`は、所有権と変更経路の監査を終えてから別段階で対応する。

## ABC328E 性能検証についての注意

`release/AtCoder/2025`の存在理由となったABC328Eの制約は `N <= 8`, `M <= 28` である。
AtCoderの実行環境は本パッケージの`import AcCollections`に依存できないため、
性能検証はpackage内のテストに加えて、**外部依存のない単一のSwiftファイルへ解法を
まとめてコピー&ペースト提出する**ことで検証する必要がある。この実務計画は
`ImplementationPlan.md`の「ABC328E 実提出による性能検証の実務計画」に記載している。
