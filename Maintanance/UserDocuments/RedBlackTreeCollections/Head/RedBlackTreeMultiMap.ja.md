# RedBlackTreeMultiMap

## Declaration

`import AcCollections` で利用する `RedBlackTreeMultiMap`。以下の宣言は型の形を示す断片です。

```swift
import AcCollections

struct RedBlackTreeMultiMap<Key: Comparable, Value>
```

## Overview

キーを昇順に保持し、同じキーに複数の値を関連づける赤黒木ベースのmultimapです。各pairは独立した要素です。通常の挿入では同一キー内は挿入順で、順序条件に合うhintを使うとグループ途中にも挿入できます。

一意キーの `Dictionary` / `RedBlackTreeDictionary` と異なり重複キーを残します。`Dictionary<Key, [Value]>` と異なり各pairを木の独立した位置として扱います。キー順で複数値を検索・走査・削除する用途に適します。

```text
("apple", 100)
("apple", 120)
("banana", 80)
("orange", 150)
("orange", 180)
```

```text
1 → "red"
1 → "green"
1 → "blue"
2 → "orange"
3 → "purple"
3 → "yellow"
```

```swift
var map: RedBlackTreeMultiMap<Int, String> = []
map.insert(key: 3, value: "a") // -> [3: "a"]
map.insert(key: 1, value: "b") // -> [1: "b", 3: "a"]
map.insert(key: 4, value: "c") // -> [1: "b", 3: "a", 4: "c"]
map.insert(key: 1, value: "d") // -> [1: "b", 1: "d", 3: "a", 4: "c"]
map.insert(key: 5, value: "e") // -> [1: "b", 1: "d", 3: "a", 4: "c", 5: "e"]
```

## Creating a Multimap

空の初期化とリテラルに加え、入力列から作成できます。`init(minimumCapacity:)` で初期容量を指定し、`reserveCapacity(_:)` で容量を予約できます。`capacity` と要素数 `count` は異なります。配列リテラル、辞書リテラル、`init(keysWithValues:)` は重複キーを保持します。`init(grouping:by:)` は入力値ごとにキーを割り当て、値を配列へまとめずpairとして保持します。

## Searching and Accessing Elements

`contains(key:)` は存在、`count(forKey:)` は一致数を返します。`first` / `last`、`min()` / `max()` は順序の両端です。`firstIndex(of:)` は不在なら `nil`、`find(_:)` は `endIndex` を返します。`lowerBound(_:)` は指定キー以上、`upperBound(_:)` は指定キーより大きい最初の位置で、なければ終端です。`equalRange(_:)` は同値な全要素の半開範囲を返します。検索した位置から前後へ移動できますが、終端は要素として参照できません。

```text
lowerBound(2)
    ↓
[2:A, 2:B, 2:C]
                ↑
           upperBound(2)
```

## Key Access and Views

キーsubscriptは単一値やpair Viewではなく `RedBlackTreeMappedValuesView` を返します。同じキーの値の範囲を、配列コピーせず表します。pairを走査する場合は `map[map.equalRange(key)]` を使います。こちらは `RedBlackTreeKeyValueRangeView` で、`keys` はキーの遅延走査、`values` はmapped valueのViewです。

キーは順序を決めるため変更しません。`Value` にComparable制約はありません。mapped Viewでは値の更新・`swapAt(_:_:)`・削除ができ、削除は対応するpairも取り除きます。swapにはView内の2つの要素indexを指定します。`map[key]` に直接変更操作を呼べば元を変更し、独立変数へ取得したViewの変更は元へ反映されません。以下の既存例には、格納pair、キーで選んだ値、pair Viewでの走査、直接変更を示す断片が含まれます。

```text
(1, "red")
(1, "green")
(1, "blue")
(2, "orange")
```

```swift
map[1]
```

```text
"red"
"green"
"blue"
```

```swift
let elements = map[map.equalRange(key)]

for key in elements.keys {
  // ...
}

for value in elements.values {
  // ...
}
```

```swift
map[key].popFirst()
map[key].erase()
```

```swift
Key: Comparable
```

```swift
map[key].swapAt(i, j)
```

## Insertion, Updating, and Removal

`insert(key:value:)` / `insert(_:)` は同じキーがあってもpairを追加します。`insert(_:hint:)` は有効かつ順序条件に合うhintの直前へ挿入できます。有効でも順序条件に合わないhintは性能にのみ影響し、通常の順序位置へ挿入します。無効なhintは事前条件違反です。`updateValue(_:at:)` はキーを変えず指定位置の値だけを更新し、旧値を返します。無効なindexなら `nil` です。

`eraseUnique(_:)` は一致する1要素、`eraseMulti(_:)` は全要素を削除します。`popFirst()` / `popLast()` は空なら `nil`、`removeFirst()` / `removeLast()` は空でないことが事前条件です。`erase(where:)`、範囲・View経由の削除、`removeAll(keepingCapacity:)` も使えます。逐次削除には `erase(_:) -> Index` が返す次の位置を使います。`index(inserting:)` は挿入結果とindexを返します。`erase(exactly:)` は指定indexの要素を削除して次のindexを返し、操作先でアクセスできないindexなら `nil` を返します。

```text
1 → "A"
2 → "B"
```

```text
1 → "C"
```

```text
1 → "A"
1 → "C"
2 → "B"
```

```swift
var map: RedBlackTreeMultiMap<Int, String> =
  [1: "b", 1: "d", 3: "a", 4: "c", 5: "e"]
map.eraseUnique(3) // -> [1: "b", 1: "d", 4: "c", 5: "e"]
```

```swift
var map: RedBlackTreeMultiMap<Int, String> =
  [1: "b", 1: "d", 3: "a", 4: "c", 5: "e"]
map[map.lowerBound(4)..<map.endIndex].erase() // -> [1: "b", 1: "d", 3: "a"]
```

```swift
var map: RedBlackTreeMultiMap<Int, String> =
  [1: "b", 1: "d", 3: "a", 4: "c", 5: "e"]
map.erase(map.lowerBound(4)..<map.endIndex) // -> [1: "b", 1: "d", 3: "a"]
```

```swift
var map: RedBlackTreeMultiMap<Int, String> =
  [1: "b", 1: "d", 3: "a", 4: "c", 5: "e"]
var i = map.startIndex
while i != map.endIndex {
  i = map.erase(i)
}
```

## Combining Multimaps

`insert(contentsOf:)` は自身へ入力を追加し、`inserting(contentsOf:)` は追加後の値を返します。要素ごとに既存storageへ挿入し、共有されている場合はCoW複製が必要です。`meld(_:)` は自身を結合結果へ置き換え、`melding(_:)` は結果を返します。両者はソート済みの二つの木を走査して新しいstorageを構築します。予約済み容量だけを理由にmeldを選ぶものではありません。 入力はmultimapまたはpairのsequenceで、同一キーの全pairを保持します。

## Transforming and Iterating

要素は `(key: Key, value: Value)` で、通常の走査はキーの昇順です。`filter(_:)` は条件に合うpairを残し、`mapValues(_:)` は値を変換し、`compactMapValues(_:)` は変換結果が `nil` のpairを除きます。残るpairのキー順と重複を維持します。`sorted()` / `reversed()` は昇順 / 降順の配列を返します。

```text
(3, "C")
(1, "A")
(2, "B")
(1, "D")
```

```text
(1, "A")
(1, "D")
(2, "B")
(3, "C")
```

## Indices and Bound Expressions

indexは整数オフセットではなく要素位置を表します。前後へ移動できますが、始端より前・終端より後へ移動してはいけません。他要素の挿入・削除では指す要素が残る限り有効です。指す要素を削除すると無効になり、slotの再利用でも古いindexは復活しません。通常構成のCoWでは対応する位置を共有できますが、有効性は操作先の世代・削除状態で決まります。無関係な木のindexを使うことは事前条件違反であり、常に検出される保証はありません。

index範囲subscriptは対象範囲のViewを返します。要素を別配列へコピーせず、元の木と同じindex型を使いますが、View固有の終端と範囲を守ります。元では要素を指す位置がViewでは終端になることもあります。subscriptへ直接変更すれば元を変更し、独立変数へ取り出したViewの変更はCoWで分離します。`containsSubrange(_:)` は範囲を確認し、`distance(from:to:)` はindexまたはBound間の距離を求めます。

`Bound` はindexを直接扱わず位置を指定する記法です。`.start`、`.last`、`.end`、`.lowerBound`、`.upperBound`、`.find`、`.lessThan` / `.lessThanOrEqual`、`.greaterThan` / `.greaterThanOrEqual`、`.before` / `.after`、`.advanced(by:limit:)` を使えます。単一Boundが終端または解決不能ならsubscriptは `nil`、不成立または逆順のBound範囲は空Viewを返します。

```swift
var map: RedBlackTreeMultiMap<Int, String> =
  [1: "b", 1: "d", 3: "a", 4: "c", 5: "e"]
print(map[.start.advanced(by: 1)]) // Optional containing (1, "d")
```

```swift
var map: RedBlackTreeMultiMap<Int, String> =
  [1: "b", 1: "d", 3: "a", 4: "c", 5: "e"]
print(map[.lowerBound(5)]) // Optional containing (5, "e")
print(map[.upperBound(5)]) // -> nil (equivalent to end)
print(map[.find(2)])       // -> nil (not found)
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
| `filter`, `mapValues`, `compactMapValues` | O(n), plus closure costs |


## Red-Black Tree

赤黒木は、色変更と回転で高さを対数的に維持する自己平衡二分探索木です。要素の論理的な順序とメモリ上の物理配置は異なります。重複を許す型でも各要素は独立したノードを持ちます。ノードをまとめたstorageで管理し、ノードごとの独立allocationを避ける設計です。

## Important

thread-safeではありません。同じ変数への並行アクセスを保護しません。本稿は通常構成のAPIを対象とします。
