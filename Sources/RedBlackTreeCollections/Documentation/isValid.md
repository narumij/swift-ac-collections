# `isValid` の現状整理

この文書は、RedBlackTreeCollections 内に存在する `isValid` の場所と、現在の実装が判定している内容を開発者向けに整理する。

## 結論

`isValid` という名前には、現在、次の異なる意味が混在している。

| 判定対象 | 現在の意味 |
|---|---|
| `Index` / `Bound` | 対応する要素へアクセスできるか |
| 範囲式 | 両端を解決でき、下端が上端を越えていないか |
| Range View 内の `Index` | 要素へアクセスでき、かつ View の範囲内にあるか |

特に `isValid(_ index: Index)` は、Swift の Collection における広い意味での「有効な位置」を判定するものではない。`endIndex` は Collection の境界としては有効だが、要素へアクセスできないため、このメソッドは `false` を返す。したがって、実態は「その位置に要素があるか」に近い。

## 現行の公開 API

以下は `COMPATIBLE_ATCODER_2025` が無効な通常構成で、4種類すべてのコレクションに公開される。

対象コレクション:

- `RedBlackTreeSet`
- `RedBlackTreeMultiSet`
- `RedBlackTreeDictionary`
- `RedBlackTreeMultiMap`

| 宣言 | 定義場所 | 判定内容 | `endIndex` / 空範囲 |
|---|---|---|---|
| `isValid(_ index: Index)` | 各型の `+Index.swift` | Indexを対象の木で解決でき、世代が一致し、実体のある要素へアクセスできること | `endIndex` は `false` |
| `isValid(_ bound: Bound)` | 各型の `+BoundsExpression.swift` | DSLの位置式を評価した結果が、実体のある要素を指すこと | `.end` 相当は `false` |
| `isValid(_ bounds: IndexRange)` | 各型の `+RangeExpression.swift` | 両端のIndexを安全な内部範囲へ変換でき、下端が上端以下であること | 正しい空範囲は `true` |
| `isValid(_ bounds: IndexRangeExpression)` | 各型の `+RangeExpression.swift` | 相対範囲を解決でき、解決後の下端が上端以下であること | 正しい空範囲は `true` |
| `isValid(_ bounds: UnboundedRange)` | 各型の `+RangeExpression.swift` | 木全体を表す内部範囲の順序が正しいこと | 通常は `true` |
| `isValid(_ bounds: BoundRangeExpression)` | 各型の `+BoundsExpression.swift` | DSLの両端を評価でき、評価後の下端が上端以下であること | 正しい空範囲は `true` |

### 単一位置の判定

`Index` と `Bound` に対する判定は、「境界として使用可能か」ではなく「要素へアクセス可能か」である。

| 状態 | `isValid(Index)` | `isValid(Bound)` |
|---|---:|---:|
| 現在存在する要素 | `true` | `true` |
| `endIndex` / `.end` | `false` | `false` |
| 削除済み要素を指すIndex | `false` | 該当なし |
| 再利用後に世代が一致しないIndex | `false` | 該当なし |
| 対象の木で解決できないIndex | `false` | 該当なし |

`ALLOW_CROSS_TREE_INDEX` 構成では、Indexのタグから対象の木にある対応ノードを引き直し、保存された世代と対象ノードの世代を照合する。別のCoW分岐での変更だけを理由に無効とはしない。

### 範囲の判定

範囲に対する `isValid` は、範囲内に要素が存在するかを判定しない。判定の中心は次の2点である。

1. 安全な端点を内部ノード範囲へ解決できること。
2. 下端と上端が同じか、木の順序で下端が上端より前にあること。

そのため、`lowerBound == upperBound` の空範囲は有効である。一方、下端が上端より後ろにある逆転範囲は無効である。無効な `BoundRangeExpression` を View APIへ渡した場合は、現在の実装では空範囲へサニタイズされ、クラッシュしない。

## package / internal の `isValid`

| 宣言 | 場所 | 可視性 | 判定内容 |
|---|---|---|---|
| `RedBlackTreeKeyOnlyRangeView.isValid(index:)` | `View/RedBlackTreeRangeView+KeyOnly.swift` | `package` | Indexが要素へアクセス可能で、Viewの内部範囲に含まれること |
| `RedBlackTreeKeyValueRangeView.isValid(index:)` | `View/RedBlackTreeRangeView+KeyValue.swift` | `package` | Indexが要素へアクセス可能で、Viewの内部範囲に含まれること |
| `UnsafeTreeV2.isValid(range: _NodeRange)` | `Implements/UnsafeTreeV2/UnsafeTreeV2+RawRange.swift` | internal | 下端と上端が同じか、下端が上端より前であること |
| `UnsafeTreeV2.isValid(range: _SafeRange)` | 同上 | internal | 端点の検証に成功し、得られた `_NodeRange` の順序が正しいこと |
| `BalancedSequence.isValid(...)` 要求群 | `Implements/Protocol/BalancedSequence.swift` | package側の抽象化 | 現行公開APIのIndex・範囲・Bound判定を共通インターフェースとして要求する |

Range View の判定は、木全体に対する `Index` 判定より条件が一つ多く、「そのViewの範囲に含まれること」まで確認する。`endIndex` は要素へアクセスできないため、ここでも `false` になる。

## AtCoder 2025 互換構成

`COMPATIBLE_ATCODER_2025` が有効な構成では、現行APIの代わりに旧Index系のAPIが使われる。

| 宣言 | 主な場所 | 判定内容 |
|---|---|---|
| `isValid(index: Index)` | 各型の `+Deprecated.swift` | 旧Indexを対象の木で解決でき、対応ノードが存在すること |
| `isValid(_ index: Index)` | `RedBlackTreeSet+Deprecated.swift` | 上記と同じ。Setに残るラベルなし形式 |
| `isValid<R: RangeExpression>(_ bounds: R)` | 各型の `+Deprecated.swift` | 相対化した両端の旧Indexを解決できること |
| `RedBlackTreeSliceV2.*.isValid(index:)` | `Implements/Deprecated/Slice` | 旧Indexを解決でき、Sliceの範囲に含まれること |

旧範囲APIは両端を解決できるかを確認するが、現行の `UnsafeTreeV2.isValid(range:)` のような端点順序の確認までは行わない。この差は互換実装を保守するときに注意が必要である。

## 命名上の論点

現行の `isValid(_ index: Index)` が返すのは、「Collection上の位置として有効か」ではなく、「そのIndexで要素へアクセスできるか」である。この意味を明確にする候補として、`isElement(at:)` が挙がっている。

一方、範囲版の `isValid` は要素の有無ではなく端点と順序を検証しているため、単一Index版だけを改名する場合でも範囲版とは分けて扱う必要がある。

この文書は現状記録であり、APIの改名方針を確定するものではない。
