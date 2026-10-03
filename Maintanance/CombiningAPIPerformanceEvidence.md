<!-- Codex/Claude作業メモ -->

# Combining API性能根拠調査 (CLAUDE_TASK.md Task 2)

`merge`/`merging`/`insert(contentsOf:)`/`inserting(contentsOf:)`(挿入ループ経路、
O(*n* log(*m + n*)))と、`union`/`formUnion`/`meld`/`melding`(meld経路、O(*n* + *m*))の
既存コメント`- Important: If sufficient space is available, using 〜 is recommended.`
の根拠を実装追跡とベンチマークで検証した結果。**本調査は証拠収集のみで、production
codeも公開コメントも変更していない。**

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
  (Set 19ケース、MultiSet 8ケース。登録は`Benchmarks/Sources/benchmark-tool/main.swift`)
- 実行コマンド(束縛された小規模測定、サイズ3点・cycles 1):

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

### 結果(最小サンプル値、μs、サイズ1,024 / 16,384 / 262,144)

**RedBlackTreeSet**

| ケース | 1k | 16k | 256k |
| --- | --- | --- | --- |
| merge, unreserved capacity | 20.92 | 215.00 | 3835.38 |
| merge, reserving capacity | 21.83 | 216.92 | 3744.96 |
| formUnion, unreserved capacity | 44.83 | 475.92 | 8193.29 |
| formUnion, reserving capacity | 43.62 | 462.46 | 8235.38 |
| merge with sorted other | 24.83 | 283.67 | 5059.25 |
| merge with shuffled other | 30.21 | 391.83 | 28888.38 |
| formUnion with sorted other | 44.04 | 445.21 | 7971.63 |
| formUnion with shuffled other | 49.46 | 565.42 | 30268.13 |
| merge with duplicate-heavy(90%重複) other | 47.50 | 975.42 | 28876.58 |
| formUnion with duplicate-heavy(90%重複) other | 26.25 | 270.96 | 4760.33 |
| merge, unique storage | 21.04 | 225.96 | 3588.12 |
| merge, shared storage | 23.96 | 274.79 | 4642.46 |
| formUnion, unique storage | 45.00 | 470.21 | 7989.00 |
| formUnion, shared storage | 43.71 | 448.67 | 7866.67 |

**RedBlackTreeMultiSet**

| ケース | 1k | 16k | 256k |
| --- | --- | --- | --- |
| insert(contentsOf:), unreserved capacity | 21.13 | 333.25 | 3580.96 |
| insert(contentsOf:), reserving capacity | 20.96 | 324.21 | 3618.96 |
| meld, unreserved capacity | 44.21 | 470.33 | 8159.17 |
| meld, reserving capacity | 44.62 | 464.21 | 7932.62 |
| insert(contentsOf:) with sorted other | 23.83 | 384.54 | 4428.54 |
| insert(contentsOf:) with shuffled other | 29.29 | 511.17 | 18616.42 |
| meld with sorted other | 43.38 | 676.58 | 7552.17 |
| meld with shuffled other | 49.67 | 804.96 | 20931.83 |

### 読み取れる傾向

1. **容量確保は両経路とも無意味**: Set・MultiSetいずれも「reserving capacity」と
   「unreserved capacity」の差は測定誤差程度(どちらの経路でも数%以内)。
   meld系は§1で確認した通り呼び出し元の容量を参照しないため当然の結果。挿入ループ
   経路側も今回のテスト(末尾方向への追記的な挿入)ではこの差が出なかった。
   → **既存コメントの「十分な空き容量があるなら meld 推奨」という条件は、
   どちらの経路の実測コストにも対応していない。**
2. **この入力サイズ域(1k〜256k)では、挿入ループ経路がmeld経路より一貫して高速**。
   Setの disjoint 入力で比較すると、merge(20.92/215.00/3835.38us)は
   formUnion(44.83/475.92/8193.29us)の約2倍速い。MultiSetでも同様の傾向
   (insert(contentsOf:)がmeldの半分程度)。O(*n* + *m*)の方が漸近的に有利な
   はずだが、Setのmeld経路は§1の通り容量を都度拡張するコストを負っており、
   その定数項が対象サイズ域でO(log(*m*+*n*))の優位性を相殺している。
3. **他方(`other`)の構築経路が2〜6倍の差を生む**: 「sorted other」(範囲リテラルや
   ソート済み配列から構築)と「shuffled other」(乱順配列から逐次挿入で構築)の差は、
   merge/formUnionどちらでも256kサイズで約5.7倍・3.8倍に達する。これは`other`
   自身の値の集合ではなく、ノードのメモリ確保順序(走査順と一致しているか)に
   起因すると考えられ、現在の文書が言及していない変数である。
4. **共有ストレージの感度は経路で非対称**: mergeは共有時に`ensureUnique()`の
   コピーコストが乗り約14-29%遅くなるが、formUnionは共有の有無で実質差がない
   (常に新規ツリーを構築し直すため)。
5. **重複の多さの影響は経路で逆**: mergeは重複(オーバーラップ)が多いほど遅くなる
   (ヒントに基づく追記的挿入が崩れ、二分探索挿入に近づくため)。formUnionは
   重複が多いほど出力要素数自体が減るため速くなる。

## 3. 結論と提案

- **「十分な空き容量があるなら meld/union/formUnion/melding を推奨する」という
  既存の`- Important`文言は、実装のどちらの経路にも対応する根拠がない。** 両経路とも
  呼び出し元の`reserveCapacity`状態に実測コストが依存しなかった。
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

## 保留事項

- 256kを超える入力サイズでのクロスオーバーの有無は未計測。
- `other`の構築経路(sorted literal vs shuffled insertion)がノード確保順序に
  起因するという説明は実装から合理的に推測したものであり、プロファイラ等による
  直接確認は行っていない。
- Dictionaryにはmeld系の代替が存在しないため、このタスクの対象外(現状の
  `merge`/`merging`のコメントに「十分な容量」文言はもともと無いことを確認済み)。
