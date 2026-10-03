# PermutationModule 製品化判断のための所見(削減実施後版)

この文書は、`PermutationModule`の公開APIを調査した所見の記録である。2026-10-03、
`Maintanance/CLAUDE_TASK.md`のユーザー最終決定に基づき、本書で削除候補として
扱っていた`All`系・`unsafe`系の公開APIは実際に削除済み(実施記録は
`ImplementationPlan.md`、現行APIは`Sources/PermutationModule/Documentation/Specification.md`
を参照)。本書は調査結果・判断根拠の記録として残す。

## 存在理由(`release/AtCoder/2025`ブランチのREADME.mdより)

現在作業中のブランチの`README.md`/`README.ja.md`には`PermutationModule`の記載が無いが、
`remotes/origin/release/AtCoder/2025`の`README.md`には由来が明記されている。

- ABC328Eという問題(制約`N <= 8`, `M <= 28`)で、C++の解説コードが全探索的に見えたため
  「組み合わせを力尽くで計算できる」と誤解していた期間があった。実際は辞書順の変化だけを
  行う`next_permutation`の挙動により組み合わせ数が減っていたために計算可能だった、
  という誤解だった。
- この誤解を追いかける過程で「オーバーヘッドが少ない実装」を追求し、結果として軽量な実装が
  生まれた。
- `unsafePermutations`/`unsafeNextPermutations`は「おまけ」として位置付けられ、
  「コピーオンライトをキャンセルして行わない動作」であることが明記されていた
  (CoWを省く設計は不備ではなく、AtCoder提出コードのような使い捨てコンテキストでの
  オーバーヘッド最小化という明確な狙いに基づく)。

つまりこのモジュールは「漫然とした実験」ではなく、特定の問題(ABC328E)から生まれた
具体的な存在理由を持つ。この存在理由の中心は「辞書順で次を1つ求める」操作
(`next_permutation`相当、`nextPermutations()`)であり、「全順列を列挙する」操作
(旧`All`系)は、その過程で派生的に実装されたものであって、モジュールの中心的な
価値ではなかった。この判断に基づき`All`系は削除した。

## 削除根拠となった所見

- `Permutations.All`にはpublicな`init(safe:)`と、それに対応する`IteratorA.ensureUnique()`が
  実装されていたが、これを呼び出すCollection拡張(「安全な全列挙」の便利メソッド)は
  存在しなかった。`swift test --enable-code-coverage --filter PermutationTests`で
  確認したところ、`Permutations.All.init(safe:)`・`IteratorA.ensureUnique()`は実行回数0
  (カバレッジ上も未到達)であり、本リポジトリ内にこれらを使う既存コードが無いことも
  削除の障害が少ないことを示していた。
- `All`系統は`swift-algorithms`の`permutations()`と機能的に重複していた。この重複は
  `ImplementationPlan.md`のPhase 1A PoC(空/単一要素/昇順/非昇順/降順/重複値/
  `Array`以外のCollectionの7ケース)で、即時`Array`化した結果が完全一致することを
  確認し、削除根拠として確定させた。
- ファイル先頭(`Permutations.swift:1`、削除前)に「模索の痕跡がのこっていて散らかって
  いるので、要点に沿って整理しなおすか、廃止するか、いずれかを次回ジャッジ更新までに
  行うこと」というTODOが存在し、作者自身も状態を把握していた。

## 現在も残る論点(所見・未着手)

- `Sendable`適合の要否。`BareArray`/`OptionalArray`と異なり、`Permutations`関連の型に
  `Sendable`適合の宣言が無い。
- 公開メソッドに対して、計算量・CoW契約・事前条件(空コレクション等)を説明する
  コメントドック(`///`)が無い。
- ABC328Eの実提出による性能検証(ベースライン記録・削除後の再提出比較)は、外部サービス
  (AtCoder)への投稿を伴うためユーザー自身が行う前提。

この文書はコード変更を含まない調査結果の記録。残る論点への対応方針はユーザーの判断を待つ。

## 公開添字の境界チェックと計測(2026-10-03)

公開`SubSequenceN.subscript(position:)`は範囲チェックを持たず、範囲外の添字で不定値を
返す、またはSIGSEGVになっていた。公開添字だけに
`precondition(position >= startIndex && position < endIndex)`を追加した(内部`Buffer`の
添字と順列生成アルゴリズムは変更なし)。範囲外アクセスは事前条件違反であり、従来の
不定な挙動は契約ではない。

- 先行テスト: `Tests/PermutationTests/PermutationDeathTests.swift`(`endIndex`・`-1`・
  `endIndex + 1`、`processExitsWith: .signal(SIGTRAP)`)。修正前はDebug/Releaseとも
  3件が`EXIT_SUCCESS`(不定値を返して正常終了)で失敗し、修正後は3件ともSIGTRAPで
  停止して成功する。有効範囲の両端は`testSubSequenceSubscriptValidBoundaries`で確認。
- ベンチマーク: `Benchmarks/Sources/Benchmarks/PermutationBenchmarks.swift`
  (有効な添字だけを公開APIで読み、合計を計時区間外で検証する。順次アクセスと、
  固定シードでシャッフルした添字列によるアクセスの2ケース)。`Benchmarks/`で次を
  修正前後に各2回実行した:

  ```console
  swift run -c release benchmark run \
    --filter 'Permutations.SubSequenceN subscript' \
    --sizes 1k 16k 256k --cycles 10 --mode replace-all \
    Results/PermutationSubscript/<before|after>-run<1|2>.json
  ```

- 環境: macOS 27.0 / Swift 6.4 / arm64、Release。生データは
  `Benchmarks/Results/PermutationSubscript/`。

結果(最小サンプル値、μs、要素数 1,024 / 16,384 / 262,144):

| ケース | 1k | 16k | 256k |
| --- | --- | --- | --- |
| 順次 修正前 run1 / run2 | 0.38 / 0.38 | 5.75 / 5.75 | 87.42 / 87.29 |
| 順次 修正後 run1 / run2 | 0.54 / 0.46 | 8.04 / 7.00 | 127.08 / 110.12 |
| シャッフル 修正前 run1 / run2 | 0.38 / 0.38 | 7.21 / 7.08 | 184.92 / 184.25 |
| シャッフル 修正後 run1 / run2 | 0.62 / 0.54 | 12.92 / 11.25 | 261.75 / 242.67 |

修正後は順次で約1.2〜1.5倍、シャッフルで約1.3〜1.8倍になった。修正後の2回の間でも
10〜15%程度ばらつき、単一マシン・cycles 10の計測であるため、倍率は目安にとどまり
一般化はしない。添字1回あたりの絶対差は1ナノ秒未満であり、安全性の確保を優先して
検査を維持する。
