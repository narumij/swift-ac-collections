# `isValid` の現状整理

この文書は、RedBlackTreeCollections 内に存在する `isValid` の場所と、現在の実装が判定している内容を開発者向けに整理する。

## 結論

`isValid` という名前には、現在、次の異なる意味が混在している。

| 判定対象 | 現在の意味 |
|---|---|
| `Index` | 対応する要素へアクセスできるか |
| Index範囲式 | 両端を解決でき、下端が上端を越えていないか |
| `Bound` / Bound範囲式 | 安全に評価できるため、事前の妥当性判定は不要 |
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
| `isElement(at: Index)` | 各型の `+Index.swift` | Indexを対象の木で解決でき、世代が一致し、実体のある要素へアクセスできること | `endIndex` は `false` |
| `isEnd(_ index: Index)` | 各型の `+Index.swift` | Indexを対象の木で解決でき、有効な終端を指すこと | `endIndex` は `true` |
| `containsSubrange(_ bounds: IndexRange)` | 各型の `+RangeExpression.swift` | 両端のIndexを安全な内部範囲へ変換でき、下端が上端以下であること | 正しい空範囲は `true` |
| `containsSubrange(_ bounds: IndexRangeExpression)` | 各型の `+RangeExpression.swift` | 相対範囲を解決でき、解決後の下端が上端以下であること | 正しい空範囲は `true` |
| `containsSubrange(_ bounds: UnboundedRange)` | 各型の `+RangeExpression.swift` | 木全体を表す内部範囲の順序が正しいこと | 通常は `true` |

### 単一位置の判定

`Index` と `Bound` に対する旧判定は、「境界として使用可能か」ではなく「要素へアクセス可能か」である。ただし、`Bound` のsubscriptは解決不能時に `nil` を返すため、事前判定は不要である。

| 状態 | `isValid(Index)` | `isValid(Bound)` |
|---|---:|---:|
| 現在存在する要素 | `true` | `true` |
| `endIndex` / `.end` | `false` | `false` |
| 削除済み要素を指すIndex | `false` | 該当なし |
| 再利用後に世代が一致しないIndex | `false` | 該当なし |
| 対象の木で解決できないIndex | `false` | 該当なし |

`ALLOW_CROSS_TREE_INDEX` 構成では、Indexのタグから対象の木にある対応ノードを引き直し、保存された世代と対象ノードの世代を照合する。別のCoW分岐での変更だけを理由に無効とはしない。

### 範囲の判定

Index範囲に対する `containsSubrange` は、範囲内に要素が存在するかを判定しない。判定の中心は次の2点である。

1. 安全な端点を内部ノード範囲へ解決できること。
2. 下端と上端が同じか、木の順序で下端が上端より前にあること。

そのため、`lowerBound == upperBound` の空範囲は有効である。一方、下端が上端より後ろにある逆転したIndex範囲は無効である。

`BoundRangeExpression` は異なる意味論を持つ。逆転した式をView APIへ渡しても空範囲へサニタイズされ、クラッシュしない。したがって事前の妥当性判定は不要であり、結果を確認したい場合は `collection[bounds].isEmpty` を使用する。

## package / internal の `isValid`

| 宣言 | 場所 | 可視性 | 判定内容 |
|---|---|---|---|
| `RedBlackTreeKeyOnlyRangeView.isValid(index:)` | `View/RedBlackTreeRangeView+KeyOnly.swift` | `package` | Indexが要素へアクセス可能で、Viewの内部範囲に含まれること |
| `RedBlackTreeKeyValueRangeView.isValid(index:)` | `View/RedBlackTreeRangeView+KeyValue.swift` | `package` | Indexが要素へアクセス可能で、Viewの内部範囲に含まれること |
| Range Viewの `isEnd(_:)` | `View/RedBlackTreeRangeView+KeyOnly.swift` / `KeyValue.swift` | `public` | Indexを安全に解決でき、View固有の `endIndex` と一致すること |
| `UnsafeTreeV2.isValid(range: _NodeRange)` | `Implements/UnsafeTreeV2/UnsafeTreeV2+RawRange.swift` | internal | 下端と上端が同じか、下端が上端より前であること |
| `UnsafeTreeV2.isValid(range: _SafeRange)` | 同上 | internal | 端点の検証に成功し、得られた `_NodeRange` の順序が正しいこと |
| `BalancedSequence.isValid(...)` 要求群 | `Implements/Protocol/BalancedSequence.swift` | package側の抽象化 | 単一Index、Index範囲、Bounds系の旧要求はコメントアウト中 |
| 公開APIから削除した `isValid(...)` | `Tests/RedBlackTreeTests/fixture` | テストターゲット内 | Index範囲は `containsSubrange` へ転送し、Bounds系はsubscriptの結果を確認する互換ヘルパー |

Range View の要素判定は、木全体に対する `Index` 判定より条件が一つ多く、「そのViewの範囲に含まれること」まで確認する。`endIndex` は要素へアクセスできないため、ここでも `false` になる。Viewの `isEnd` は基底コンテナの終端ではなくViewの上端を判定するため、その位置が基底コンテナ内の要素を指す場合もある。

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

4種類すべてのコレクションで、旧 `isValid(_ index: Index)` の実際の意味を `isElement(at:)` として公開し、`isEnd(_:)` と分離している。共通テストの移行用に限り、テストターゲット内の `isValid(_:)` を `isElement(at:)` へのエイリアスとして残している。

Index Range判定はreceiverとの包含関係を表すため、4種類すべてのコレクションで `containsSubrange` を使用する。従来のIndex Range版 `isValid` は公開APIから削除し、既存テスト向けのforwarding helperだけをテストターゲット内に残す。

Bounds系は失敗を値として表現する。単数のsubscriptは解決不能時に `nil`、範囲subscriptは成立しない式に対して空Viewを返す。このため単数・範囲とも公開 `isValid` を削除した。既存テストについては、subscriptの結果を同じ綴りで確認するテストターゲット内の互換ヘルパーを使用する。

## 推奨方針

`isValid` を一つの概念として統一するのではなく、利用者が確認したい事実ごとにAPIを分けることを推奨する。

| 判定したい事実 | 推奨するAPI | `true` の意味 |
|---|---|---|
| Indexが有効な位置か | `isValid(_ index: Index)` | 対象の木で要素または `endIndex` として利用できる |
| 単一のIndexが要素を指すか | `isElement(at: Index)` | subscriptや削除の対象になる要素が現在存在する |
| Indexが終端を指すか | `isEnd(_ index: Index)` | 対象の木の有効な `endIndex` である |
| Boundが要素へ解決されるか | `collection[bound] != nil` | subscriptが要素を返す |
| Bound範囲の評価結果が空か | `collection[bounds].isEmpty` | subscriptが空Viewを返す |
| Rangeがreceiver内で利用可能か | `containsSubrange(_:)` | 両端を解決でき、順序が正しく、receiverの範囲内に収まる |

### 単一位置

旧 `isValid(_ index: Index)` は実質的に要素アクセス可能性を判定していたため、その役割を `isElement(at:)` へ移した。一方、`Bound` はsubscriptがOptionalを返すため、別の事前判定APIへ置き換えず、評価結果を直接確認する。

この名前なら、`endIndex` がCollectionの位置としては有効であっても、要素ではないため `false` になることを自然に表現できる。Indexの世代不一致、削除済みノード、対象の木で解決できないIndexも同様に `false` とする。

一方、Collectionにおける `endIndex` は常に有効な境界である。このため、単一Indexの状態は次の3種類として扱う。

| 状態 | `isValid(_:)` | `isElement(at:)` | `isEnd(_:)` |
|---|---:|---:|---:|
| 現在存在する要素 | `true` | `true` | `false` |
| 対象の木の `endIndex` | `true` | `false` | `true` |
| staleまたは解決不能 | `false` | `false` | `false` |

現在の `isValid(_ index:)` は `endIndex` に `false` を返すため、Swiftの一般的な「有効なIndex」という意味とは一致しない。将来この名前を残す場合は、要素と `endIndex` の両方を `true` とする意味へ揃える。ただし既存挙動の変更になるため、移行時には互換性へ注意する。

### ノンクロスツリーインデクシングでの `isElement(at:)`

`ALLOW_CROSS_TREE_INDEX` が無効な構成では、Indexは生成元の木のストレージに結び付く。`target.isElement(at: index)` は、Indexが対象の木と同じストレージへ結び付いており、保存されたpointerと世代が現在も要素アクセスに利用できるかを判定する。

判定条件は次のとおりとする。

1. Indexと対象の木が同じストレージに結び付いている。
2. Indexに保存された世代と、pointerが指すノードの現在世代が一致する。
3. 対象ノードにPayloadが存在する。
4. 対象ノードが `endIndex` ではない。

| 状況 | `target.isElement(at: index)` |
|---|---:|
| Index生成後も対象の木が同じストレージを使用し、要素が残っている | `true` |
| 対象要素を削除した | `false` |
| 削除後、同じスロットが別要素へ再利用された | `false` |
| 別の独立した木で使用した | `false` |
| CoWによって対象の木がIndexの結び付くストレージから分離した | `false` |
| CoW後も古いストレージを保持する側の木で使用した | `true` |
| 対象の木の `endIndex` | `false` |

ノンクロスツリー構成では、キーやノード番号が一致していても別ストレージのIndexは利用できない。CoW後の新しいストレージへ論理ノードを追跡することも行わない。

`isEnd(_:)` についても同じストレージへの結び付きが必要である。対象の木から現在取得できる `endIndex` は常に有効だが、別の木の終端や、Indexを無効化する変更前に取得した古い終端まで有効とする意味ではない。

### クロスツリーインデクシングでの `isElement(at:)`

`ALLOW_CROSS_TREE_INDEX` 構成におけるIndexは、値を検索する条件ではなく、論理ノードを追跡するハンドルとして扱う。

このとき `target.isElement(at: index)` が判定するのは、Indexの生成元と対象の木が同一インスタンスかではない。Indexが表す論理ノードを対象の木で引き直し、現在も要素アクセスへ利用できるかを判定する。

判定条件は次のとおりとする。

1. Indexのタグに対応するノードを対象の木で解決できる。
2. Indexに保存された世代と、対象ノードの現在世代が一致する。
3. 対象ノードにPayloadが存在する。
4. 対象ノードが `endIndex` ではない。

| 状況 | `target.isElement(at: index)` |
|---|---:|
| CoW前から共有していた論理ノードが対象の木に残っている | `true` |
| 別のCoW分岐だけが無関係な要素を変更した | `true` |
| 対象の木ではその論理ノードを削除した | `false` |
| 削除後、同じスロットが別要素へ再利用された | `false` |
| 同じキーの要素を新しく挿入し直した | `false` |
| 別のCoW分岐だけで新規挿入された | `false` |
| 対象の木の `endIndex` | `false` |

したがって、キーが等しいだけでは同じ要素とはみなさない。物理pointerがCoWによって変わっていても、対象の木でタグと世代が一致する論理ノードを解決できれば要素として扱う。

`isEnd(_:)` はこの要素判定と対になり、対象の木で有効な終端として解決できる場合だけ `true` を返す。単に要素ではないIndexを終端とみなしてはならない。

### Range

Rangeについては、単なる端点順序だけでなく、「そのreceiverがそのsubrangeを包含するか」を公開APIの意味とする。

```swift
outerFirst <= innerFirst <= innerLast <= outerLast
```

木全体では `outerFirst...outerLast` が全範囲となり、Range ViewではView自身の範囲となる。これにより、同じ `containsSubrange(_:)` で次を一貫して判定できる。

| Rangeの状態 | 結果 |
|---|---:|
| receiver全体と同じRange | `true` |
| receiver内に収まるRange | `true` |
| 正しい位置にある空Range | `true` |
| 端点が逆転しているRange | `false` |
| receiverの外へはみ出すRange | `false` |
| 解決不能または世代不一致の端点を含むRange | `false` |

内部実装では、`_NodeKey` がキー比較、同一キー時のpath bitmap比較、bitmapの遅延生成と再利用を担当する。公開APIおよびViewは、これらの実装事情を露出せず、Range包含という仕様だけを扱う。

### 移行

通常構成では、次の順序で段階的に移行するのが安全である。

1. `isElement(at:)`、`isEnd(_:)`、`containsSubrange(_:)` を追加し、期待する意味をテストで固定する。
2. 内部およびドキュメントの利用箇所を新APIへ移す。
3. 現行の要素判定としての `isValid` を、`isElement(at:)` へのdeprecated aliasにする。
4. API互換性を破壊できる時点で、`isValid(_ index:)` を要素または `endIndex` を表す有効位置の判定へ変更する。名前を再利用しない方針なら削除する。

`COMPATIBLE_ATCODER_2025` の旧APIは互換性維持を優先し、この整理の対象外として残す。

### Test as Specification

最低限、次の性質をテスト名とassertionから読み取れる状態にする。

- `isElement(at:)` は存在する要素に対して `true`、`endIndex` に対して `false` を返す。
- `isEnd(_:)` は対象の木の `endIndex` に対してだけ `true` を返す。
- `isValid(_:)` を残す場合、存在する要素と `endIndex` の両方を有効なIndexとして扱う。
- ノンクロスツリー構成では、別ストレージのIndexとCoW分離後のIndexを要素として扱わない。
- 削除またはノード再利用によって世代が一致しないIndexは要素として扱わない。
- CoW分岐後も、対象の木で世代が一致するIndexは要素として扱う。
- 同じキーを再挿入しても、タグまたは世代が異なる論理ノードは元のIndexの要素として扱わない。
- 空Range、同一Range、内包Rangeを有効なsubrangeとして扱う。
- 逆転Range、receiver外のRange、staleな端点を含むRangeを無効として扱う。
- 同一キーを複数持つ木でも、path bitmapによって端点の順序と包含を正しく判定する。

以上を、この文書における推奨案とする。実際の改名および公開API変更は、テストを先に追加したうえで段階的に行う。
