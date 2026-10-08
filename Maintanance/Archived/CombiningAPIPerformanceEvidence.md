# Combining API性能根拠調査

> 状態: 完了・追加検証可(2026-10-06)。追加検証は現在の正しさや1.0判断を止めない。

`merge`/`merging`/`insert(contentsOf:)`/`inserting(contentsOf:)`(挿入ループ経路、
O(*n* log(*m + n*)))と、`union`/`formUnion`/`meld`/`melding`(meld経路、O(*n* + *m*))の
既存コメント`- Important: If sufficient space is available, using 〜 is recommended.`
の根拠を実装追跡とベンチマークで検証した結果。調査ではproduction codeを変更せず、
後続作業で根拠のない公開コメント6箇所を削除した。追加の推奨文は設けていない。
容量事前確保PoCは計測後に完全復元した。詳細は§3末尾・§4に記録する。

## 1. 実装経路の追跡

| 型 | 挿入ループ経路 | meld経路 | 内部呼び先 |
| --- | --- | --- | --- |
| Set | `merge`/`merging` | `union`/`formUnion` | `___insert_range_unique` / `___meld_unique` |
| MultiSet | `insert(contentsOf:)`/`inserting(contentsOf:)` | `meld`/`melding` | `___insert_range_multi` / `___meld_multi` |
| MultiMap | `insert(contentsOf:)`/`inserting(contentsOf:)` | `meld`/`melding` | `___insert_range_multi` / `___meld_multi`(MultiSetと構造的に同型) |
| Dictionary | `merge`/`merging` | **存在しない** | `___insert_range_unique` のみ |

(`Sources/RedBlackTreeCollections/Implements/UnsafeTreeV2/UnsafeTreeV2+SetAlgebra.swift`,
`Implements/UnsafeTreeV2/UnsafeTreeV2+InsertRange.swift` を参照)

重要な非対称性を発見した:

- `___meld_unique`(Set の `union`/`formUnion` が呼ぶ)は、結果用バッファを
  `minimumCapacity: 2` で新規作成し、マージ走査中に`unsafeEnsureCapacity()`で
  都度拡張する。**呼び出し元が`reserveCapacity`済みであっても、その容量は一切
  参照されない。**
- `___meld_multi`(MultiSet/MultiMap の `meld` が呼ぶ)は、結果用バッファを
  `minimumCapacity: count + other.count` で最初から確保する。

つまり既存コメントの「十分な空き容量があるなら meld 系を推奨」という条件は、
**実装のどちらの経路にも対応していない**。meld系は呼び出し元の既存容量を見ず、
常に自分で新規バッファを作る(Setはサイズ指定なしで都度拡張、MultiSet/MultiMapは
正確なサイズで一括確保)。挿入ループ経路(`merge`/`insert(contentsOf:)`)は
`ensureUnique()`の後、既存ツリーへ直接挿入するため、呼び出し元の`reserveCapacity`
が効く経路はむしろこちら側である。

## 2. ベンチマーク

### コマンドと環境

- 環境: macOS 27.0 (26A428) / Swift 6.4 (swiftlang-6.4.0.34.1) /
  `arm64-apple-macosx27.0.0` / `swift build -c release`
- パッケージ: `Benchmarks/`(既存の`swift-collections-benchmark`ハーネスを再利用)
- 追加ファイル: `Benchmarks/Sources/Benchmarks/CombiningAPIBenchmarks.swift`
  (Set 14ケース、MultiSet 8ケース。登録は`Benchmarks/Sources/benchmark-tool/main.swift`)
- 実行コマンド(束縛された小規模測定、サイズ3点・cycles 1。`Benchmarks/`で実行):

  ```console
  swift run -c release benchmark run \
    --filter 'RedBlackTreeSet<Int> (merge|formUnion)' \
    --sizes 1k 16k 256k --cycles 1 --mode replace-all \
    Results/CombiningAPI/results-RedBlackTreeSet-combining.json

  swift run -c release benchmark run \
    --filter 'RedBlackTreeMultiSet<Int> (insert\(contentsOf:\)|meld)' \
    --sizes 1k 16k 256k --cycles 1 --mode replace-all \
    Results/CombiningAPI/results-RedBlackTreeMultiSet-combining.json
  ```

- 生データ: `Benchmarks/Results/CombiningAPI/results-RedBlackTreeSet-combining.json`,
  `Benchmarks/Results/CombiningAPI/results-RedBlackTreeMultiSet-combining.json`
  (各タスクの最小サンプル値、単位はアト秒)
- Dictionaryはmeld系の代替APIが存在しないため、比較対象としてのベンチマークは
  追加していない(構造的に比較不能)。MultiMapは`meld`/`insert(contentsOf:)`の
  実装がMultiSetと構造的に同型(いずれも`___meld_multi`/`___insert_range_multi`を
  共有)であるため、MultiSetの測定を代表させ、個別に再実行していない。

### 計測方法の補正(2026-10-03 再計測)

初回計測後のレビューで次の3点を補正し、同じ範囲(同じフィルタ・サイズ・cycles)で
再計測した。

- **ハーネスの意味論**: `swift-collections-benchmark`は外側クロージャをサイズごとに
  1回、内側クロージャをサンプルごとに1回実行し、`timer.measure`内だけを計時する
  (`.build/checkouts/swift-collections-benchmark/.../Task.swift`の
  `_nestedMeasure`ループで確認)。したがって「宛先に既に`other`が入った状態を
  繰り返し計測する」問題は初回から起きていなかった。
- **意図しないCoWの除去**: 初回の「with sorted/shuffled/duplicate-heavy other」系
  ケースは`var a = base`で外側の`base`とstorageを共有しており、挿入ループ経路
  (`merge`/`insert(contentsOf:)`)では計時区間内に`ensureUnique()`のコピーが
  含まれていた(=実質的に「shared storage」ケース)。全ケースを、宛先をサンプル
  ごとに計時区間外で新規構築する形へ変更した。意図的な共有は「shared storage」
  ケースのみ。
- **再現性と結果検証**: shuffled入力を固定シードのSplitMix64による
  `shuffled(using:)`へ変更。各サンプルの計時後に`count`/`first`/`last`を
  `precondition`で検証し、誤った最終状態や無操作を計測できないようにした。

### 結果(最小サンプル値、μs、サイズ1,024 / 16,384 / 262,144)

cycles 1 のため実行間のばらつきがある。Set・MultiSetとも同範囲を2回実行し、
生データファイルには2回目を保存した(表も2回目)。1回目のSet実行では1k列が全ケース
一様に約2倍になっており、実行単位のノイズと判断した。

**RedBlackTreeSet**

| ケース | 1k | 16k | 256k |
| --- | --- | --- | --- |
| merge, unreserved capacity | 21.50 | 222.46 | 3646.00 |
| merge, reserving capacity | 21.58 | 221.25 | 3629.25 |
| formUnion, unreserved capacity | 45.04 | 482.38 | 8047.71 |
| formUnion, reserving capacity | 45.38 | 477.83 | 7917.17 |
| merge with sorted other | 22.17 | 222.96 | 3698.08 |
| merge with shuffled other | 29.96 | 395.29 | 22176.29 |
| formUnion with sorted other | 45.92 | 478.62 | 8171.83 |
| formUnion with shuffled other | 49.79 | 564.71 | 27994.17 |
| merge with duplicate-heavy(90%重複) other | 42.42 | 916.42 | 27168.67 |
| formUnion with duplicate-heavy(90%重複) other | 28.04 | 300.25 | 4869.17 |
| merge, unique storage | 21.62 | 213.71 | 3715.04 |
| merge, shared storage | 24.42 | 266.25 | 4504.04 |
| formUnion, unique storage | 45.21 | 470.29 | 7810.50 |
| formUnion, shared storage | 44.04 | 451.71 | 7509.54 |

(Setのフィルタは既存の`formUnion with Self (N% overlap)`5ケースにも一致するため、
生データにはそれらも含まれる。本調査の対象外。)

**RedBlackTreeMultiSet**

| ケース | 1k | 16k | 256k |
| --- | --- | --- | --- |
| insert(contentsOf:), unreserved capacity | 20.54 | 323.79 | 3421.17 |
| insert(contentsOf:), reserving capacity | 20.88 | 208.46 | 3586.17 |
| meld, unreserved capacity | 43.42 | 470.50 | 7813.46 |
| meld, reserving capacity | 44.08 | 468.46 | 7784.46 |
| insert(contentsOf:) with sorted other | 20.96 | 338.04 | 3512.00 |
| insert(contentsOf:) with shuffled other | 25.92 | 457.92 | 18402.25 |
| meld with sorted other | 43.92 | 689.50 | 7780.88 |
| meld with shuffled other | 49.92 | 866.38 | 21919.25 |

**16kの信頼限界**: `meld with sorted other`と`meld, unreserved capacity`は補正後
まったく同じコードだが、16kでは2回とも約1.5倍の差が出た(689.50 vs 470.50、
1回目 702.33 vs 478.54)。タスク実行順やアロケータ状態に依存する差と考えられ、
16kでの約1.5倍以内の差は本計測では有意と扱わない。

### 読み取れる傾向

1. **容量確保の効果は1k・256kでは見られない**: Set・MultiSetとも「reserving」と
   「unreserved」の差は1k・256kで数%以内。meld系は§1の通り呼び出し元の容量を参照
   しない。唯一、MultiSetの`insert(contentsOf:)`は16kで2回とも約1.6倍
   (208.46 vs 323.79、1回目 217.92 vs 337.83)reservingが速かったが、上記の
   16kの信頼限界と同程度のため、容量の効果とは断定しない(保留事項)。
   → **既存コメントの「十分な空き容量があるなら meld 推奨」という条件は、
   meld経路のコストには対応していない。**
2. **この入力サイズ域(1k〜256k)では、挿入ループ経路がmeld経路より一貫して高速**。
   Setのdisjoint入力でmerge(21.50/222.46/3646.00us)はformUnion
   (45.04/482.38/8047.71us)の約2倍速い。MultiSetでも
   `insert(contentsOf:)`が`meld`の約半分。
3. **`other`の構築経路が大きな差を生む**: sorted構築とshuffled構築(固定シード)の
   256kでの比は、merge約6.0倍、formUnion約3.4倍、`insert(contentsOf:)`約5.2倍、
   meld約2.8倍。初回記録の「5.7倍・3.8倍」は、sorted側に意図しないCoWを含む値と
   非再現なshuffleに基づいていたため、本値で置き換える。結論(2〜6倍の差)は維持。
4. **共有ストレージの感度は経路で非対称**: mergeは共有時に約13-24%遅くなる
   (24.42/266.25/4504.04 vs 21.62/213.71/3715.04)が、formUnionは共有の有無で
   実質差がない。初回計測の「with ... other」系ケースとunreservedケースの差
   (例: merge 256k 5059 vs 3835)は、このCoWコストが混入していたことで説明できる。
5. **重複の多さの影響は経路で逆**: mergeは重複が多いほど遅く、formUnionは出力要素数
   が減るため速くなる(256k: merge 27168.67 vs formUnion 4869.17)。

補正後も§3の結論は変わらない。

## 3. 結論と提案

- **「十分な空き容量があるなら meld/union/formUnion/melding を推奨する」という
  既存の`- Important`文言は、実装のどちらの経路にも対応する根拠がない。** 両経路とも
  1k・256kでは呼び出し元の`reserveCapacity`状態に実測コストが依存しなかった
  (16kのMultiSet挿入ループ経路のみ未判定、保留事項参照)。
- 単純な一行の推奨には置き換えられない。実測で分かった支配的な要因は
  「容量」ではなく、(a) 対象サイズ域(今回計測した256kまではむしろ挿入ループ経路が
  優位)、(b) 入力の重複率、(c) `other`のノード確保順序(構築経路)、(d) 宛先storageの
  共有状態、の4点である。
- 公開コメントの書き換えは本タスクの範囲外(ユーザー判断待ち)。代わりに、次回の
  コメント改訂では次のような条件付き表現を提案する(文言はユーザー確認後に確定):
  - 「`reserveCapacity`の有無はいずれの経路のコストにも影響しない」という事実を
    明記し、「十分な空き容量」という条件そのものを削除する。
  - 代わりに、「`other`が多数の重複を含む場合や宛先が共有storageの場合は
    挿入ループ経路が相対的に不利になりやすい」等、実測で確認できた傾向を条件として
    示す。
  - 入力サイズに関する一般的な閾値(「nが大きいならmeld系」等)は、今回の計測
    (256kまで)ではむしろ逆の結果だったため、現時点では主張しない。より大きな
    サイズでの追加計測を行うか、クロスオーバーが無い可能性を保留事項として残す。
- **別件として報告する疑わしい性能欠陥**: `___meld_unique`(Setの`union`/
  `formUnion`)が結果バッファを`minimumCapacity: 2`からしか確保せず、
  `___meld_multi`(MultiSet/MultiMapの`meld`)のように`count + other.count`を
  事前確保していない非対称性がある。これはTask 2の範囲(production code非変更)
  では修正しないが、`union`/`formUnion`の実測が相対的に遅い一因と考えられるため、
  別タスクとして最適化を検討する価値がある。
  → §4のPoCで検証し、**有意な効果なし**と判定した(この推測は否定された)。
- **公開コメントの訂正(2026-10-03実施)**: Set/MultiSet/MultiMapの
  `merge`/`merging`/`insert(contentsOf:)`/`inserting(contentsOf:)`にあった
  `- Important: If sufficient space (complexity) is available, using 〜 is recommended.`
  計6箇所を削除した。既存の計算量記述と「入力を変更しない」旨の記述が残っており、
  新たな推奨文は追加していない。Dictionaryには該当文言が無く無変更。

## 4. `___meld_unique` 容量事前確保PoC(2026-10-03)

### パッチ形状(計測後に完全復元済み)

`Sources/RedBlackTreeCollections/Implements/UnsafeTreeV2/UnsafeTreeV2+SetAlgebra.swift`
の`___meld_unique(_ other: UnsafeTreeV2)`で、結果バッファの初期容量を
`___meld_multi`と同じ式へ一時的に変更した(1行のみ)。

```swift
// before (production)
var __result_: UnsafeTreeV2 = ._createWithNewBuffer(minimumCapacity: 2, nullptr: nullptr)
// PoC
var __result_: UnsafeTreeV2 = ._createWithNewBuffer(
  minimumCapacity: count + other.count, nullptr: nullptr)
```

計測後に元の1行へ戻し、`git diff`が空であることを確認した。PoC版が実際に計測へ
使われたことは、復元直後の`swift build -c release --product benchmark`が
再コンパイル(12.6秒、無変更時は0.7秒)を伴ったことで確認した。

### コマンド(`Benchmarks/`で実行、前後とも同一)

```console
swift run -c release benchmark run \
  --filter 'RedBlackTreeSet<Int> (merge|formUnion)(,| with (sorted|shuffled|duplicate-heavy))' \
  --sizes 1k 16k 256k --cycles 10 --mode replace-all \
  Results/MeldUniqueCapacityPoC/<before|after>-run<1|2>.json
```

- 対象は§2の決定的なSet 14ケース(`formUnion`7ケース+対照の`merge`7ケース)。
  ハーネス生成入力を使い結果検証の無い既存`with Self (N% overlap)`系は除外した。
- §2のcycles 1は約1秒で終わり1サンプルしか得られないため、cycles 10とした。
  前後各2回実行し、全サンプルで計時後の`precondition`検証が通過した。
- 環境: macOS 27.0 (26A428) / Swift 6.4 (swiftlang-6.4.0.34.1) / arm64。
- 生データ: `Benchmarks/Results/MeldUniqueCapacityPoC/before-run{1,2}.json`,
  `after-run{1,2}.json`(サンプルはアト秒)。

### 結果(2回の最小サンプル値の小さい方、μs、1k / 16k / 256k)

| ケース | before | after | after/before |
| --- | --- | --- | --- |
| formUnion with sorted other | 29.1 / 458.5 / 7631.9 | 28.3 / 453.7 / 7715.8 | 0.97 / 0.99 / 1.01 |
| formUnion with shuffled other | 31.5 / 565.8 / 21578.0 | 31.2 / 572.9 / 22545.6 | 0.99 / 1.01 / 1.04 |
| formUnion with duplicate-heavy other | 17.8 / 283.2 / 4754.5 | 17.3 / 287.7 / 4691.0 | 0.97 / 1.02 / 0.99 |
| formUnion, unreserved capacity | 29.0 / 461.6 / 7699.7 | 28.2 / 460.8 / 7729.8 | 0.97 / 1.00 / 1.00 |
| formUnion, reserving capacity | 28.9 / 474.2 / 7563.4 | 28.5 / 454.9 / 7719.2 | 0.99 / 0.96 / 1.02 |
| formUnion, unique storage | 29.0 / 456.1 / 7618.6 | 28.4 / 464.2 / 7673.4 | 0.98 / 1.02 / 1.01 |
| formUnion, shared storage | 27.9 / 440.7 / 7306.9 | 27.4 / 453.9 / 7293.7 | 0.98 / 1.03 / 1.00 |
| (対照) merge with sorted other | 13.3 / 213.0 / 3432.1 | 13.6 / 217.0 / 3515.5 | 1.02 / 1.02 / 1.02 |
| (対照) merge with duplicate-heavy other | 36.9 / 909.6 / 24403.2 | 35.8 / 901.2 / 25270.7 | 0.97 / 0.99 / 1.04 |
| (対照) merge, unreserved capacity | 13.2 / 211.5 / 3517.8 | 13.3 / 216.8 / 3525.3 | 1.00 / 1.03 / 1.00 |

(対照の残り4ケースも0.99〜1.01。全14ケースの値は生データ参照。)

### ノイズの限界

- 同一コードの2回の実行間で約4%以内のばらつき。PoCが通らない対照`merge`系も
  0.97〜1.04倍の範囲で動いており、`formUnion`系の変化(0.96〜1.04倍)はこの範囲内。
- 単一マシン・単一セッションの計測で、より大きなサイズや他の要素型は未計測。

### 結論と推奨

- **`___meld_unique`への`count + other.count`事前確保は、Set `union`/`formUnion`の
  性能を測定可能な程度には変えない。性能目的での採用は推奨しない。**
- 実装上の整合する説明: 容量拡張は既存ノードを移動せずbucketを末尾へ追加する
  (`Design-NodeStorage.md`)ため、都度拡張でもコピーコストが生じない。
  `formUnion`が`merge`より約2倍遅い要因は容量確保以外にある(未特定、本PoCの範囲外)。
- 加えて、重複が多い入力では`count + other.count`が結果要素数を上回り、
  過剰確保になる。MultiSet側(`___meld_multi`)と揃えること自体を目的とするなら、
  性能ではなくコード整合性の判断としてユーザーが決める事項である。

## 任意の追加検証(非blocking)

以下は追加で掘れる論点であり、本調査の完了条件、現在のAPIの正しさ、1.0のblocking条件には
含めない。具体的な利用上の必要または性能回帰が生じた場合に再開する。

- 256kを超える入力サイズでのクロスオーバーの有無は未計測。
- 16kでは同一コードのケース間で約1.5倍の差が再現する(実行順/アロケータ状態の影響と
  推測、未確認)。MultiSet `insert(contentsOf:)`のreserving 16kでの約1.6倍の高速化が
  容量の効果か、このアーティファクトかは未判定。
- `other`の構築経路(sorted literal vs shuffled insertion)がノード確保順序に
  起因するという説明は実装から合理的に推測したものであり、プロファイラ等による
  直接確認は行っていない。
- Dictionaryにはmeld系の代替が存在しないため、このタスクの対象外(現状の
  `merge`/`merging`のコメントに「十分な容量」文言はもともと無いことを確認済み)。
