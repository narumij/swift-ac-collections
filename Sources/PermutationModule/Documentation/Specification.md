# PermutationModule 仕様ドラフト(フェーズ1)

本書は `PermutationModule` の再設計に向けた**仕様の土台**で、調査結果に基づく
ドラフトである。コード・テストへの変更は伴わない。公開APIの最終形はユーザーの
判断を待つ。既知の調査所見は
`Maintanance/PermutationModule/ProductReadinessAssessment.md` に、テスト観点の
計画は `Maintanance/PermutationModule/ImplementationPlan.md` にある。

## 由来(観測可能な背景として記録)

`remotes/origin/release/AtCoder/2025` の `README.md` に由来の記述がある。
ABC328Eの解説コードを読んだ際、「全探索で間に合っている」ように見えたが、
実際は `next_permutation` が辞書順の変化だけを行うために列挙数が抑えられていた、
という誤解を追いかける過程で生まれたモジュールである。この経緯から、
「辞書順で次を1つ求める」操作(`next_permutation`系)と「全順列を列挙する」操作
(`permutations`系)という2系統の操作が存在する。

## 公開APIの現状(事実)

`Collection where Index == Int` への3つの拡張メソッドのみが公開APIである。

| API | 戻り値の型 | 下位イテレータ | CoW |
| --- | --- | --- | --- |
| `nextPermutations()` | `Permutations<Self>.Nexts` | `IteratorN(_unsafe: false)` | あり |
| `unsafeNextPermutations()` | `Permutations<Self>.Nexts` | `IteratorN(_unsafe: true)` | なし |
| `unsafePermutations()` | `Permutations<Self>.All` | `IteratorA(_unsafe: true)` | なし |

`nextPermutations()` に対応する「全順列を安全に(CoWありで)列挙する」API
(`permutations()` に相当するもの)は現状存在しない。実装(`Permutations.All.init(safe:)`、
`IteratorA.ensureUnique()`)は既にあるが、これを呼び出す公開APIが無く、非対称な状態にある
(`ProductReadinessAssessment.md` 参照)。

## 観測可能な公開契約(ユーザー向けの振る舞い)

この節は「何が保証されるか」であり、実装の都合(`ManagedBuffer`か否か等)は含めない。

1. **列挙順序**: 3つのAPIとも、現在の要素並びを起点として辞書順で次の並びへ進む。
   起点より辞書順で前の並びは列挙されない(「残りの辞書順」を列挙する)。
2. **終了条件**: 現在の並びが辞書順で最後(降順)に達すると、その回を最後に列挙が終わる。
   そのため「変化のしようがない」入力(全要素が同値など)や「既に最後の並び」の入力は、
   1回だけ値を返して終了する。
3. **要素の重複**: 要素が比較で等しい場合、見た目が同一の並びが複数回現れうる
   (`[0, 0, 1]` の例で `[0, 0, 1]` が2回現れるなど)。これは入力のインデックス列に対する
   辞書順操作の結果であり、要素値だけを見た重複排除は行わない。
4. **CoWの有無による違い(実装選択であり優劣ではない)**:
   - `nextPermutations()` は、列挙で返される各 `SubSequence` が呼び出し時点の値を
     保持する。後から元のシーケンスを変更しても、既に取り出した結果には影響しない。
   - `unsafeNextPermutations()` / `unsafePermutations()` は、内部バッファへの参照を
     共有したまま返す。列挙結果を**即座に消費せず保持・再利用**すると、全ての結果が
     列挙完了時点(または直近の状態)の値に収束して見える、という非直感的な挙動が生じる。
     この挙動は不具合ではなく、使い捨てコンテキスト(1回走査してすぐ使う、AtCoder提出コードのような
     用途)でのオーバーヘッド最小化という設計判断に基づく。利用者が結果を保持・再利用したい場合は
     `map { Array($0) }` 等で即座に値へ変換する必要がある。
5. **計算量**: `next_permutation` 相当の1ステップは要素数に対して償却定数〜線形
   (reverseの分だけ)。全順列の列挙は `O(n!)` 回のステップ。

## 命名についての論点(決定はユーザー待ち)

`unsafe` という接頭辞は、Swift標準の `unsafe` 系API(メモリ安全性に関わるもの)と
同じ語を使っているが、本モジュールの `unsafe` はメモリ安全性ではなく「CoWをしない
(エイリアシングが生じる)」という意味である。本書の立場は、これを「安全版の手抜き」
ではなく「2つの正当な戦略」として並記することだが、命名がその意図を利用者に正しく
伝えるかは未解決の論点である(`ProductReadinessAssessment.md` の検討項目4)。

## この文書がまだ扱っていないもの

- `Permutations.All.init(safe:)` を公開APIとして結線するかどうかの決定。
- `Sendable` 適合の要否。
- 計算量・CoW契約・事前条件を説明する `///` コメントドックの文面。
- `Tests/PermutationTests/NextPermutation.swift` にある別世代の実装の扱い。

これらは `Maintanance/PermutationModule/ProductReadinessAssessment.md` の
「製品化にあたって要ると思われる検討項目」としてユーザー判断待ちのまま残っている。
