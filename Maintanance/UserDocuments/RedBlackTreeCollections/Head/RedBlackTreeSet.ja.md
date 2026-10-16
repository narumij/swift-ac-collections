# RedBlackTreeSet

## Declaration

`import AcCollections` で利用する `RedBlackTreeSet`。以下の宣言は型の形を示す断片です。

```swift
import AcCollections

struct RedBlackTreeSet<Element: Comparable>
```

## Overview

要素を昇順に保持する赤黒木ベースの一意集合です。同じ要素は高々1つ保持し、挿入・削除後も順序を維持します。標準 `Set` と異なり順序に基づく検索・走査ができ、`Array` と異なり更新のたびに全体をソートし直す必要がありません。重複が必要なら `RedBlackTreeMultiSet` を使います。昇順・降順の処理や上下限検索を伴う動的な集合に適します。

空・リテラル・入力列から作成でき、容量は `init(minimumCapacity:)` と `reserveCapacity(_:)` で指定できます。通常の走査は昇順で、`sorted()` / `reversed()` は昇順 / 降順の配列を返します。

```swift
let numbers: RedBlackTreeSet = [5, 2, 4, 1, 3]

print(numbers)
// [1, 2, 3, 4, 5]
```

```swift
var set: RedBlackTreeSet<Int> = []

set.insert(3) // -> [3]
set.insert(1) // -> [1, 3]
set.insert(4) // -> [1, 3, 4]
set.insert(1) // -> [1, 3, 4]
set.insert(5) // -> [1, 3, 4, 5]
```

```swift
let numbers: RedBlackTreeSet = [3, 1, 2, 3, 2, 1]

print(numbers)
// [1, 2, 3]
```

```swift
let numbers: RedBlackTreeSet = [7, 2, 9, 1, 5]

for number in numbers {
  print(number)
}
```

```text
1
2
5
7
9
```

## Searching and Accessing Elements

`contains(_:)` は存在、`count(of:)` は一致数を返します。`first` / `last`、`min()` / `max()` は順序の両端です。`firstIndex(of:)` は不在なら `nil`、`find(_:)` は `endIndex` を返します。`lowerBound(_:)` は指定値以上、`upperBound(_:)` は指定値より大きい最初の位置で、なければ終端です。`equalRange(_:)` は同値な全要素の半開範囲を返します。検索した位置から前後へ移動できますが、終端は要素として参照できません。

## Insertion and Removal

`insert(_:)` は一意性を保ち、重複挿入では要素を増やしません。`remove(_:)` は値を検索して削除します。範囲削除や既知のindexからの削除も可能です。削除したindexから次の位置を求めず、逐次削除には `erase(_:) -> Index` が返す次の位置を使います。

```swift
var numbers: RedBlackTreeSet = [1, 3, 5]

numbers.insert(4)
// [1, 3, 4, 5]

numbers.remove(3)
// [1, 4, 5]
```

```swift
var set: RedBlackTreeSet<Int> = [1, 3, 4, 5]

set.remove(3)
// [1, 4, 5]
```

```swift
var set: RedBlackTreeSet<Int> = [1, 3, 4, 5]

set[.lowerBound(4) ..< .end].erase()
// [1, 3]
```

```swift
var set: RedBlackTreeSet<Int> = [1, 3, 4, 5]

set.erase(.lowerBound(4) ..< .end)
// [1, 3]
```

```swift
var set: RedBlackTreeSet<Int> = [1, 3, 4, 5]

var i = set.startIndex
while i != set.endIndex {
  i = set.erase(i)
}
```

## Set Algebra

`union` / `formUnion`、`intersection` / `formIntersection`、`difference` / `formDifference`、`symmetricDifference` / `formSymmetricDifference` は、それぞれ和・積・差・対称差です。`form` 付きは自身を更新し、付かない操作は結果を返します。

## Indices and Bound Expressions

indexは整数オフセットではなく要素位置を表します。前後へ移動できますが、始端より前・終端より後へ移動してはいけません。他要素の挿入・削除では指す要素が残る限り有効です。指す要素を削除すると無効になり、slotの再利用でも古いindexは復活しません。通常構成のCoWでは対応する位置を共有できますが、有効性は操作先の世代・削除状態で決まります。無関係な木のindexを使うことは事前条件違反であり、常に検出される保証はありません。

index範囲subscriptは対象範囲のViewを返します。要素を別配列へコピーせず、元の木と同じindex型を使いますが、View固有の終端と範囲を守ります。元では要素を指す位置がViewでは終端になることもあります。subscriptへ直接変更すれば元を変更し、独立変数へ取り出したViewの変更はCoWで分離します。`containsSubrange(_:)` は範囲を確認し、`distance(from:to:)` はindexまたはBound間の距離を求めます。

`Bound` はindexを直接扱わず位置を指定する記法です。`.start`、`.last`、`.end`、`.lowerBound`、`.upperBound`、`.find`、`.lessThan` / `.lessThanOrEqual`、`.greaterThan` / `.greaterThanOrEqual`、`.before` / `.after`、`.advanced(by:limit:)` を使えます。単一Boundが終端または解決不能ならsubscriptは `nil`、不成立または逆順のBound範囲は空Viewを返します。

```swift
var set: RedBlackTreeSet<Int> = [1, 3, 4, 5]

print(set[.start.advanced(by: 1)])
// Optional(3)
```

```swift
var set: RedBlackTreeSet<Int> = [1, 3, 4, 5]

print(set[.lowerBound(5)])
// Optional(5)

print(set[.upperBound(5)])
// nil (equivalent to end)

print(set[.find(2)])
// nil (not found)
```

## Performance

比較・要素操作を定数時間とし、CoWのstorage複製を別途必要としない場合の計算量です。複製は削除履歴も保持するため、現在countだけではコストを表せない場合があります。Viewの作成で配列をコピーしなくても、その後の変更にCoWが必要な場合があります。

| Operation | Complexity |
| --- | --- |
| `isEmpty`, `count`, `startIndex`, `endIndex` | O(1) |
| Lookup, lower/upper bound, insertion, lookup and removal of one element | O(log n) |
| Removal at a known index; rebalancing | Amortized O(1) |
| Union, intersection, difference, symmetric difference | O(n+m) |


## Red-Black Tree

赤黒木は、色変更と回転で高さを対数的に維持する自己平衡二分探索木です。要素の論理的な順序とメモリ上の物理配置は異なります。重複を許す型でも各要素は独立したノードを持ちます。ノードをまとめたstorageで管理し、ノードごとの独立allocationを避ける設計です。

## Important

thread-safeではありません。同じ変数への並行アクセスを保護しません。本稿は通常構成のAPIを対象とします。
