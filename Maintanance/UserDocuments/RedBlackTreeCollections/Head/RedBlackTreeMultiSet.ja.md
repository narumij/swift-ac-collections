# RedBlackTreeMultiSet

## Declaration

`import AcCollections` で利用する `RedBlackTreeMultiSet`。以下の宣言は型の形を示す断片です。

```swift
import AcCollections

struct RedBlackTreeMultiSet<Element: Comparable>
```

## Overview

要素を昇順に保持する赤黒木ベースの多重集合です。同値要素を何個でも保持し、各要素は異なる位置を持ちます。同値要素は順序上で連続します。`Set` や `RedBlackTreeSet` と異なり重複を除かず、`Array` と異なり更新中も順序を維持します。重複が不要なら `RedBlackTreeSet` を使います。

```swift
let numbers: RedBlackTreeMultiSet = [5, 2, 4, 2, 1, 3, 3]

print(numbers)
// [1, 2, 2, 3, 3, 4, 5]
```

```swift
let numbers: RedBlackTreeMultiSet = [3, 1, 2, 3, 2, 1]

print(numbers)
// [1, 1, 2, 2, 3, 3]
```

```swift
var set: RedBlackTreeMultiSet<Int> = []
set.insert(3) // -> [3]
set.insert(1) // -> [1, 3]
set.insert(4) // -> [1, 3, 4]
set.insert(1) // -> [1, 1, 3, 4]
set.insert(5) // -> [1, 1, 3, 4, 5]
```

## Creating a Multiset

空の初期化とリテラルに加え、入力列から作成できます。`init(minimumCapacity:)` で初期容量を指定し、`reserveCapacity(_:)` で容量を予約できます。`capacity` と要素数 `count` は異なります。 array literal、sequence、collection、rangeから初期化できます。

## Searching and Accessing Elements

`contains(_:)` は存在、`count(of:)` は一致数を返します。`first` / `last`、`min()` / `max()` は順序の両端です。`firstIndex(of:)` は不在なら `nil`、`find(_:)` は `endIndex` を返します。`lowerBound(_:)` は指定値以上、`upperBound(_:)` は指定値より大きい最初の位置で、なければ終端です。`equalRange(_:)` は同値な全要素の半開範囲を返します。検索した位置から前後へ移動できますが、終端は要素として参照できません。

## Insertion and Removal

挿入は同値要素を置換せず追加します。hintは有効な位置を渡し、順序条件に合う場合に挿入位置の探索を助けます。`update(_:at:)` は旧値と新値が `==` の場合だけ置換し、旧値を返します。無効なindexや非同値の値では `nil` を返します。

`eraseUnique(_:)` は一致する1要素、`eraseMulti(_:)` は一致する全要素を削除します。`popFirst()` / `popLast()` は空なら `nil`、`removeFirst()` / `removeLast()` は空でないことが事前条件です。`erase(where:)`、範囲削除、`removeAll(keepingCapacity:)` も使えます。削除済みindexを進めず、逐次削除は `erase(_:) -> Index` の戻り値で継続します。

```swift
var numbers: RedBlackTreeMultiSet = [1, 3, 3, 5]

numbers.insert(3)
// [1, 3, 3, 3, 5]

numbers.insert(4)
// [1, 3, 3, 3, 4, 5]
```

```swift
var set: RedBlackTreeMultiSet<Int> = [1, 1, 3, 4, 5]
set.eraseUnique(3) // -> [1, 1, 4, 5]
```

```swift
var set: RedBlackTreeMultiSet<Int> = [1, 1, 3, 4, 5]
set[set.lowerBound(4)..<set.endIndex].erase() // -> [1, 1, 3]
```

```swift
var set: RedBlackTreeMultiSet<Int> = [1, 1, 3, 4, 5]
set.erase(set.lowerBound(4)..<set.endIndex) // -> [1, 1, 3]
```

```swift
var set: RedBlackTreeMultiSet<Int> = [1, 1, 3, 4, 5]
var i = set.startIndex
while i != set.endIndex {
  i = set.erase(i)
}
```

## Combining Multisets

`insert(contentsOf:)` は自身へ入力を追加し、`inserting(contentsOf:)` は追加後の値を返します。要素ごとに既存storageへ挿入し、共有されている場合はCoW複製が必要です。`meld(_:)` は自身を結合結果へ置き換え、`melding(_:)` は結果を返します。両者はソート済みの二つの木を走査して新しいstorageを構築します。予約済み容量だけを理由にmeldを選ぶものではありません。 insert系はSet、MultiSet、任意のsequenceを入力にできます。

## Multiset Algebra

各値の多重度をa、bとすると、`union` は a+b、`intersection` は min(a,b)、`difference` は max(a-b,0)、`symmetricDifference` は abs(a-b) です。対応する `formUnion`、`formIntersection`、`formDifference`、`formSymmetricDifference` は自身を更新します。これらは一意集合の意味論ではなく、標準 `SetAlgebra` には適合しません。

## Iterating over Elements

通常の走査は昇順です。`sorted()` と `reversed()` は昇順・降順の配列を返します。`filter(_:)` は条件に合う要素を新しいMultiSetへ残し、重複を保持します。範囲Viewでも同じ順序で走査できます。

```swift
let numbers: RedBlackTreeMultiSet = [7, 2, 9, 2, 1, 5]

for number in numbers {
  print(number)
}
```

```text
1
2
2
5
7
9
```

## Indices and Bound Expressions

indexは整数オフセットではなく要素位置を表します。前後へ移動できますが、始端より前・終端より後へ移動してはいけません。他要素の挿入・削除では指す要素が残る限り有効です。指す要素を削除すると無効になり、slotの再利用でも古いindexは復活しません。通常構成のCoWでは対応する位置を共有できますが、有効性は操作先の世代・削除状態で決まります。無関係な木のindexを使うことは事前条件違反であり、常に検出される保証はありません。

index範囲subscriptは対象範囲のViewを返します。要素を別配列へコピーせず、元の木と同じindex型を使いますが、View固有の終端と範囲を守ります。元では要素を指す位置がViewでは終端になることもあります。subscriptへ直接変更すれば元を変更し、独立変数へ取り出したViewの変更はCoWで分離します。`containsSubrange(_:)` は範囲を確認し、`distance(from:to:)` はindexまたはBound間の距離を求めます。

`Bound` はindexを直接扱わず位置を指定する記法です。`.start`、`.last`、`.end`、`.lowerBound`、`.upperBound`、`.find`、`.lessThan` / `.lessThanOrEqual`、`.greaterThan` / `.greaterThanOrEqual`、`.before` / `.after`、`.advanced(by:limit:)` を使えます。単一Boundが終端または解決不能ならsubscriptは `nil`、不成立または逆順のBound範囲は空Viewを返します。

```swift
var set: RedBlackTreeMultiSet<Int> = [1, 1, 3, 4, 5]
print(set[.start.advanced(by: 1)]) // Optional containing 1
```

```swift
var set: RedBlackTreeMultiSet<Int> = [1, 1, 3, 4, 5]
print(set[.lowerBound(5)]) // Optional containing 5
print(set[.upperBound(5)]) // -> nil (equivalent to end)
print(set[.find(2)]) // -> nil (not found)
```

## Performance

比較・要素操作を定数時間とし、CoWのstorage複製を別途必要としない場合の計算量です。複製は削除履歴も保持するため、現在countだけではコストを表せない場合があります。Viewの作成で配列をコピーしなくても、その後の変更にCoWが必要な場合があります。

| Operation | Complexity |
| --- | --- |
| `isEmpty`, `count`, `startIndex`, `endIndex` | O(1) |
| Lookup, lower/upper bound, insertion, lookup and removal of one element | O(log n) |
| Removal at a known index; rebalancing | Amortized O(1) |
| Lookup and removal/processing of K matching elements | O(log n + K) |
| `insert(contentsOf:)`, `inserting(contentsOf:)` (n incoming, m existing) | O(n log(m+n)), plus storage-copy costs |
| `meld`, `melding` | O(n+m), new storage |
| Union, intersection, difference, symmetric difference | O(n+m) |


## Red-Black Tree

赤黒木は、色変更と回転で高さを対数的に維持する自己平衡二分探索木です。要素の論理的な順序とメモリ上の物理配置は異なります。重複を許す型でも各要素は独立したノードを持ちます。ノードをまとめたstorageで管理し、ノードごとの独立allocationを避ける設計です。

## Important

thread-safeではありません。同じ変数への並行アクセスを保護しません。本稿は通常構成のAPIを対象とします。
