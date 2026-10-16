# RedBlackTreeDictionary

## Declaration

`import AcCollections` で利用する `RedBlackTreeDictionary<Key: Comparable, Value>`。

## Overview

キーを昇順に保持する赤黒木ベースの辞書です。各キーに1つの値を保持し、同じキーへの代入は値を更新します。挿入・削除・更新後もキー順を維持します。標準の `Dictionary` と異なり、キー順の走査や上下限検索を必要とする場合に使います。同じキーに複数の値を保持する場合は `RedBlackTreeMultiMap` を使います。

```swift
var dict: RedBlackTreeDictionary<Int, String> = [:]
dict[3] = "c"   // -> [3: "c"]
dict[1] = "a"   // -> [1: "a", 3: "c"]
dict[4] = "d"   // -> [1: "a", 3: "c", 4: "d"]
dict[1] = "aa"  // -> [1: "aa", 3: "c", 4: "d"] (updated)
```

## Creating a Dictionary

`init()` と空の辞書リテラルで空の辞書を作れます。辞書リテラルまたは `init(uniqueKeysWithValues:)` に渡すキーは一意にしてください。重複を含む入力には `init(_:uniquingKeysWith:)` を使い、既存値、入力値の順に渡されるクロージャで結果を決めます。`init(grouping:by:)` は各キーに入力順の配列を対応づけます。

`init(minimumCapacity:)` と `reserveCapacity(_:)` は容量を確保します。`capacity` は要素数ではなく容量です。

## Searching and Accessing Elements

キーsubscriptは不在なら `nil` を返します。default付きsubscriptは不在時に既定値を返しますが、読み取るだけでは挿入しません。`contains(key:)` と `count(forKey:)` は存在を確認し、後者は0または1です。

`first` / `last` と `min()` / `max()` はキー順の両端です。`firstIndex(of:)` / `index(forKey:)` は見つからなければ `nil`、`find(_:)` は `endIndex` を返します。`lowerBound(_:)` は指定キー以上、`upperBound(_:)` は指定キーより大きい最初の位置を返し、該当がなければ終端です。`equalRange(_:)` は一致する要素の半開範囲を表します。要素indexから `index(after:)` / `index(before:)` で移動するときは両端の事前条件を守ります。

## Insertion, Updating, and Removal

キーsubscriptへの値の代入は挿入または更新、`nil` の代入は削除です。default付きsubscriptを通じて値を変更すると、不在時は既定値を挿入してから変更します。`updateValue(_:forKey:)` は置換前の値、または新規挿入時に `nil` を返します。`removeValue(forKey:)` は該当する1要素を削除します。

連続した削除には範囲削除を使えます。削除した位置から次のindexを求めるループは避けます。逐次削除では `erase(_:) -> Index` が返す次の位置を使用してください。

```swift
var dict: RedBlackTreeDictionary<Int, String> = [1: "a", 3: "c", 4: "d", 5: "e"]
dict.removeValue(forKey: 3) // -> [1: "a", 4: "d", 5: "e"]
```

```swift
var dict: RedBlackTreeDictionary<Int, String> = [1: "a", 3: "c", 4: "d", 5: "e"]
dict[dict.lowerBound(4)..<dict.endIndex].erase() // -> [1: "a", 3: "c"]
```

```swift
var dict: RedBlackTreeDictionary<Int, String> = [1: "a", 3: "c", 4: "d", 5: "e"]
dict.erase(dict.lowerBound(4)..<dict.endIndex) // -> [1: "a", 3: "c"]
```

```swift
var dict: RedBlackTreeDictionary<Int, String> = [1: "a", 3: "c", 4: "d", 5: "e"]
var i = dict.startIndex
while i != dict.endIndex {
  i = dict.erase(i)
}
```

## Transforming and Combining Dictionaries

`filter(_:)` は条件に合う組を新しい辞書へ残します。`mapValues(_:)` はキーを保って値を変換し、`compactMapValues(_:)` は変換結果が `nil` の組を除きます。いずれもキー順を維持します。

`merge(_:uniquingKeysWith:)` は自身を更新し、`merging(_:uniquingKeysWith:)` は結果の辞書を返します。重複時のクロージャには既存値、入力値の順に渡し、戻り値をそのキーの値にします。

## Iterating over Keys and Values

要素は `(key: Key, value: Value)` です。通常の走査はキーの昇順です。`keys` はキーを遅延走査し、`values` はmapped valueのViewです。`sorted()` は昇順、`reversed()` は降順の配列を返します。index範囲のViewでも組・キー・値を走査できます。

## Indices and Bound Expressions

indexは整数オフセットではなく要素位置を表します。他の要素を挿入・削除しても有効ですが、指す要素を削除すると無効です。slotを再利用しても古いindexは復活しません。通常構成のCoWでは対応する位置を共有できますが、有効性は操作先の世代・削除状態で決まります。無関係な木のindexを渡すことは事前条件違反で、検出は保証しません。

index範囲subscriptはpairのViewを返します。Viewは要素配列をコピーせず、固有の終端を持ちます。subscriptへ直接変更すれば元を変更し、独立変数へ取得したViewの変更はCoWで分離します。`containsSubrange(_:)` は範囲を確認し、`distance(from:to:)` はindexまたはBound間の距離を求めます。

`Bound` は `.start`、`.last`、`.end`、`.lowerBound`、`.upperBound`、`.find`、`.lessThan`、`.lessThanOrEqual`、`.greaterThan`、`.greaterThanOrEqual`、`.before`、`.after`、`.advanced(by:limit:)` で位置を表現します。単一Boundが終端または解決不能ならsubscriptは `nil`、不成立・逆順のBound範囲は空Viewになります。

```swift
var dict: RedBlackTreeDictionary<Int, String> = [1: "a", 3: "c", 4: "d", 5: "e"]
print(dict[.lowerBound(4)]) // Optional containing (4, "d")
print(dict[.upperBound(5)]) // -> nil (equivalent to end)
print(dict[.find(2)])       // -> nil (not found)
```

## Performance

以下は比較・要素操作を定数時間とし、CoWによるストレージ複製を別途必要としない場合です。複製は削除履歴を保持するため、現在の要素数だけではコストを表せない場合があります。

Viewの作成では要素を配列へコピーしません。独立した変数に保持したViewを変更すると、CoWによる複製が発生する場合があります。

| Operation | Complexity |
| --- | --- |
| `isEmpty`, `count`, `startIndex`, `endIndex` | O(1) |
| Key lookup, lower/upper bound, insertion, key-based update/removal | O(log n) |
| Removal at a known index; rebalancing | Amortized O(1) |
| `filter`, `mapValues`, `compactMapValues` | O(n), plus closure costs |
| `merge`, `merging` with m existing and n incoming pairs | O(n log(m+n)), plus closure and storage-copy costs |


## Red-Black Tree

キーを使って順序を決める自己平衡二分探索木です。色変更と回転により高さを対数的に保ちます。論理的なキー順とメモリ上の物理配置は異なります。

## Important

thread-safeではありません。同じ変数への並行アクセスを保護するものではありません。本稿は通常構成のAPIを対象とします。
