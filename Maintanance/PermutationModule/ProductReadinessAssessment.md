# PermutationModule 製品化判断のための所見(削減実施後版)

この文書は、`PermutationModule`の公開APIを調査した所見の記録である。2026-10-03、
`Maintanance/CLAUDE_TASK.md`のユーザー最終決定に基づき、本書で削除候補として
扱っていた`All`系・`unsafe`系の公開APIは実際に削除済み(実施記録は
`ImplementationPlan.md`、現行APIは
`Tests/PermutationTests/NextPermutationsSequence/`のTest as Specification（2026-10-07に`Specification.md`から切り替え）を参照)。本書は調査結果・判断根拠の記録として残す。

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

## 現在も残る論点

- ABC328Eの実提出による性能検証(ベースライン記録・削除後の再提出比較)は、ユーザーが
  手作業で行う専任項目として凍結する。AIは着手・代行・催促しない。

`Sendable`対応と公開コメントドックは、その後の作業で実施済み。Sendableの安全性根拠は
`Maintanance/StrictMemorySafetyReadiness.md` §9を参照。

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

## 境界チェックのオーバーヘッド検証(2026-10-03、追試)

上記の初回計測について、再現性と実用上の影響を検証した。生データは
`Benchmarks/Results/PermutationSubscript/`の`validation-*`(チェックなし/ありのA/B交互)、
`singlecmp-*`(2比較/単一比較の交互)、`control-*`(コード配置の対照実験)。

### 初回ベンチマークの手法上の問題

- 合計値`sum`が計時クロージャのキャプチャ変数(ヒープbox)で、アクセスごとにstoreが入る。
  このstoreがバッファのヘッダーと別のメモリだとコンパイラが証明できず、`endIndex`を毎回
  再ロードしていた(逆アセンブルで確認)。チェックのコストを実際より大きく見せる。
- 1kケースは1サンプル約375ns(arm64のタイマー刻み41.7nsで約9刻み)しかなく、量子化
  誤差だけで±10%程度揺れる。
- 補正版として`(batched)`の2ケースを追加した。ローカル変数で合計し、1サンプル内で
  同じ走査を繰り返す(約2^20アクセス、走査ごとに`identity(_:)`で最適化による併合を防ぐ)。
  初回の2ケースは比較のためそのまま残した。

### A/B交互計測(チェックなし U / チェックあり C)

U→C→U→C→U→C の6回。状態ごとにReleaseで再ビルドし、全回で同じコマンドを使った:

```console
swift run -c release benchmark run --filter '^Permutations\.SubSequenceN subscript' \
  --sizes 1k 16k 256k --cycles 10 --disable-cutoff true --mode replace-all <out>
swift run -c release benchmark run --filter '^Permutations nextPermutations end-to-end' \
  --sizes 8 9 10 --cycles 10 --disable-cutoff true --mode replace-all <out>
```

前半に計測順による低速化(ドリフト)があったため、後半の3回(U3/C4/U5/C6)の最小値(μs)を示す:

| ケース | U3 | C4 | U5 | C6 |
| --- | --- | --- | --- | --- |
| 順次(batched) 16k | 104.3 | 113.4 | 113.3 | 113.2 |
| シャッフル(batched) 1k | 253.5 | 675.5 | 275.0 | 681.5 |
| シャッフル(batched) 16k | 387.5 | 661.0 | 419.3 | 661.0 |
| シャッフル(batched) 256k | 887.8 | 971.7 | 962.2 | 972.9 |
| end-to-end n=10 | 40873 | 48596 | 42049 | 49304 |

- 逐次アクセス: 補正版では、ループ条件 `i < endIndex` からチェックが自明になり、
  コンパイラが除去する。機械語は両状態で同一で、ドリフト後の値も同等。
- シャッフルアクセス: チェックありでは1アクセスあたり分岐が2つ増え(符号と上限)、
  ループのアンロールも抑止される。キャッシュに収まる1k/16kで約1.6〜2.7倍の差が再現した。
  メモリ律速の256kでは差がほぼ消える。
- end-to-end(`nextPermutations()`でn!通りを生成し、各結果を公開添字で読んで位置重み付き
  チェックサムを作る。件数とチェックサムは計時区間外で閉じた式と照合): 一貫して約17〜20%の
  差が出たが、計時ループの機械語は両状態で**同一**(チェックは除去済み)で、違うのは関数の
  配置アドレスだけだった。`-align-loops=64`を両状態に指定しても差は残った。そこでチェックなしの
  まま無関係な詰め物関数で配置だけをずらすと、詰め物の量によってチェックありと同じ値になった
  (U pad0 30.1ms / C 35.7ms / U pad4 30.3ms / U pad8 36.5ms / U pad16 29.7ms)。
  したがって、この差はコード配置によるもので、チェックのコストではない。

### 単一比較 `UInt(bitPattern: position) < UInt(bitPattern: endIndex)` のPoC

- `Int.min`・`Int.min + 1`・`-1`・`0`・最後の有効添字・`endIndex`・`endIndex &+ 1`・
  `Int.max`を、`endIndex`が0・1・2・7・2^40・`Int.max`の各場合で2比較版と照合し、全件一致。
  変換によるトラップもない(前提は`startIndex == 0`かつ`endIndex >= 0`で、`Buffer`の定義上成立)。
- exit testに`Int.min`/`Int.max`を追加した(計5件)。両方の形で、Debug/Releaseとも全件SIGTRAPで成功。
- 2比較 T / 単一比較 S を交互に6回(同一コマンド):

| ケース | T1 | S2 | T3 | S4 | T5 | S6 |
| --- | --- | --- | --- | --- | --- | --- |
| シャッフル(batched) 1k | 520.5 | 369.9 | 520.7 | 364.8 | 529.9 | 363.0 |
| シャッフル(batched) 16k | 509.8 | 394.3 | 509.8 | 392.1 | 511.0 | 405.8 |
| シャッフル(batched) 256k | 738.3 | 756.6 | 767.6 | 749.8 | 771.0 | 764.2 |
| end-to-end n=10 | 36722 | 30471 | 36776 | 30688 | 36778 | 31654 |

- 単一比較で減るのは、シャッフルアクセスの符号チェック分岐(`tbnz`)1つだけ。キャッシュに
  収まるシャッフル読み取りでは約25〜30%速くなった。end-to-endの機械語は可換な`madd`の
  オペランド順を除いて同一で、差は上記と同じコード配置によるもの。

### 結論

- 2比較の`precondition(position >= startIndex && position < endIndex)`を維持する。
- 実際の利用(順次走査、順列の生成と消費)ではチェックが最適化で消え、実用上のコストは
  観測されなかった。残るコストは、キャッシュに収まる任意順アクセスを単独で測った場合に限られる。
- 単一比較は、等価で失敗時の挙動も同じだが、`startIndex == 0`を暗黙の前提にしていて明快さが
  劣る。効果も単独のマイクロベンチマークに限られ、実用上の効果は確認できないため採用しない。
- 制約: 単一マシン(macOS 27.0 / Swift 6.4 / arm64)、cycles 10。コード配置だけで±20%動く
  ことが分かったので、数%〜20%程度の差は再ビルドをまたいで比較する際に慎重に扱う。
