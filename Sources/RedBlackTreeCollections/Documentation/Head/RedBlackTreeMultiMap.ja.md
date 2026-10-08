<!-- 編集用原稿: 日本語利用者向け文書と現行Swiftソース先頭コメントの和集合。 -->
<!-- 重複を整理してから RedBlackTreeMultiMap.swift のコメントドックへ反映する。 -->

<!-- このRedBlackTreeMultiMap.ja.mdを正本とします。RedBlackTreeMultiMap.mdは、この文書の英訳コピーです。 -->
<!-- 人間向け、割と初心者向け -->

# RedBlackTreeMultiMap

[English](RedBlackTreeMultiMap.md) | 日本語

キーを昇順に保持し、同じキーに複数の値を関連付けられる赤黒木ベースの辞書です。

## Declaration

```swift
import AcCollections

struct RedBlackTreeMultiMap<Key: Comparable, Value>
```

## Overview

`RedBlackTreeMultiMap` は、1つのキーに複数の値を関連付けることができ、
すべての要素をキーの昇順に並べて管理するコレクションです。

概念的には、次のような要素を保持できます。

```text
("apple", 100)
("apple", 120)
("banana", 80)
("orange", 150)
("orange", 180)
```

`RedBlackTreeDictionary` とは異なり、
同じキーを持つ複数の要素を同時に格納できます。

`RedBlackTreeMultiMap` は、平衡二分探索木の一種である赤黒木を使用します。

このため、キーによる検索・挿入・削除を対数時間で行いながら、
すべての要素をキーのソート順で走査できます。

また、キーを指定した subscript は単一の値ではなく、
そのキーを持つすべての key-value 要素を表す range view を返します。

`RedBlackTreeMultiMap` は、特に次のような用途に適しています。

- 1つのキーに複数の値を関連付けたい場合
- 同じキーを持つすべての要素をまとめて扱いたい場合
- 要素を動的に追加・削除しながら、キー順を維持したい場合
- 指定したキー以上、または指定したキーより大きい最初の要素を効率よく検索したい場合
- キーの範囲に含まれる要素を順番に処理したい場合
- 要素をキーの昇順または降順に走査したい場合

各キーに値を1つだけ関連付ける場合は、
`RedBlackTreeDictionary` を使用します。

## Multiple Values for a Key

`RedBlackTreeMultiMap` は、順序比較上同一とみなされるキーを持つ要素を
複数保持できます。

たとえば、次のようなデータを1つのコレクションに格納できます。

```text
1 → "red"
1 → "green"
1 → "blue"
2 → "orange"
3 → "purple"
3 → "yellow"
```

同じキーを持つ要素も、それぞれ独立した要素として保持されます。

一方、キーの順序比較だけでは、それぞれの値の大小関係は定義されません。

`Value` は `Comparable` に準拠する必要がなく、
赤黒木上の配置はキーの順序によって決まります。

各キーに値を1つだけ保持する必要がある場合は、
`RedBlackTreeDictionary` を使用します。

## Accessing Elements by Key

`RedBlackTreeMultiMap` では、キーを指定した subscript は単一の値ではなく、
そのキーを持つすべての key-value 要素を表す
`RedBlackTreeKeyValueRangeView` を返します。

概念的に、

```text
(1, "red")
(1, "green")
(1, "blue")
(2, "orange")
```

という内容に対して、

```swift
map[1]
```

は、

```text
(1, "red")
(1, "green")
(1, "blue")
```

に対応する range view を返します。

この view は、同じキーを持つ要素を新しい配列へコピーしたものではなく、
元の赤黒木上の論理的な範囲を表します。

view の要素は key-value の組であり、
元の multimap と同じ index 型を使用します。

そのため、同じキーを持つ要素を新しい配列へコピーすることなく、
直接順番に走査できます。

また、view からキーだけ、または値だけを走査できます。

```swift
let elements = map[key]

for key in elements.keys {
  // ...
}

for value in elements.values {
  // ...
}
```

`keys` はキーを遅延走査するための Sequence を返します。

`values` は値を走査するだけでなく、
mapped valueを変更できる `RedBlackTreeMappedValuesView` を返します。

range view 自体も読み取り専用ではありません。
元の multimap の subscript に対して変更操作を直接呼び出すと、
その範囲の先頭または末尾の要素を取り除いたり、
範囲全体または条件に一致する要素を削除したりできます。

```swift
map[key].popFirst()
map[key].erase()
```

`var elements = map[key]` のように range view を独立した変数へ取り出した場合、
その後の変更は `elements` 側へ適用され、元の `map` には反映されません。

これにより、キーに対応する要素群を検索結果として参照するだけでなく、
1つの部分コレクションとして直接操作できます。

## Sorted Iteration

`RedBlackTreeMultiMap` を通常の順序で走査すると、
要素はキーの昇順で現れます。

概念的に、

```text
(3, "C")
(1, "A")
(2, "B")
(1, "D")
```

のような要素を格納した場合、走査時にはキーの順序に従って、

```text
(1, "A")
(1, "D")
(2, "B")
(3, "C")
```

のように、同じキーを持つ要素が連続して現れます。

要素をあらかじめ配列へ取り出してソートする必要はありません。
キーのソート順はコレクション自身の構造によって常に維持されます。

この性質は、要素の追加や削除を繰り返しながら、
キー順で処理したい場合に特に有用です。

## Ordered Lookup

赤黒木はキー間の順序を利用して検索を行うため、
単純なキー検索だけでなく、順序に基づく検索も効率よく実行できます。

たとえば、次のような問い合わせを行えます。

- 指定したキーを持つ要素が存在するか
- 指定したキーを持つ最初の要素はどれか
- 指定したキーを持つすべての要素はどの範囲にあるか
- 指定したキー以上の最初の要素はどれか
- 指定したキーより大きい最初の要素はどれか
- 指定したキー範囲に含まれる要素はどれか
- 指定した位置の直前または直後の要素はどれか

特に、同じキーを持つ複数の要素を扱う場合には、
lower-bound と upper-bound によって、
そのキーに対応する要素の範囲を効率よく求められます。

概念的には、キー `2` に対して、

```text
lowerBound(2)
    ↓
[2:A, 2:B, 2:C]
                ↑
           upperBound(2)
```

という範囲が得られます。

キーによる subscript が返す range view は、
このような同一キーの要素範囲を直接扱える形にしたものです。

これらの検索では、先頭から要素を線形に走査する必要はありません。

赤黒木の高さは要素数に対して対数的に抑えられるため、
キーに基づく検索は最悪 O(log `count`) の計算量で実行されます。

## Keys and Values

`RedBlackTreeMultiMap` の要素は、キーと値の組として扱われます。

キーは要素の赤黒木上での位置を決定し、
要素間のソート順を定義します。

一方、値はキーに関連付けられたデータであり、
木の順序付けには使用されません。

このため、

```swift
Key: Comparable
```

である必要がありますが、`Value` には同様の順序制約はありません。

これは、キーと値の両方を比較して並べる
単純な `RedBlackTreeSet<(Key, Value)>` とは異なる重要な性質です。

### Swapping Values

`RedBlackTreeMultiMap` では、キーを変更せずに、
異なる要素の値だけを交換できます。

KeyValue Range View の `values` から得られる
`RedBlackTreeMappedValuesView` は変更可能で、
`swapAt(_:_:)` を使って2つの index が指す mapped value を交換できます。

```swift
map[key].values.swapAt(i, j)
```

この操作で交換されるのは値だけです。

キーは変更されないため、
赤黒木上の要素の位置やキーのソート順には影響しません。

これは、キーが木の順序を決定する一方で、
mapped value は木の順序付けに使用されないという
`RedBlackTreeMultiMap` の性質を利用した操作です。

## Indices

`RedBlackTreeMultiMap` の index は、
キー順に並んだ要素列の中の論理的な位置を表します。

同じキーを持つ要素が複数存在する場合でも、
それぞれの要素は異なる位置を持ちます。

index を使うことで、ある要素から次の要素、または前の要素へ移動できます。

キーによる subscript が返す range view も元の multimap と同じ index 型を使用するため、
view と元のコレクションの間で同じ位置表現を利用できます。

赤黒木では要素が連続した配列上に配置されているとは限らないため、
index は整数オフセットではありません。

この点は `Array` とは異なります。

別の要素を挿入または削除しても、指している要素が存在する限り、
その index は有効なままです。指している要素自体を削除すると無効になり、
同じslotが再利用されても、そのindexを後から再利用することはできません。

CoWで分岐したコレクションでも、対応する要素が存在し世代が一致する限り、
indexからその位置を特定できます。無関係なコレクションから取得したindexを
使用することは事前条件違反であり、その検出は保証しません。

## Multimap Operations

`RedBlackTreeMultiMap` は、同じキーを複数保持できる辞書として、
キーによる検索、要素の挿入、削除といった基本的な操作を提供します。

同じキーを持つ要素を追加した場合でも、
既存の値を置き換えるのではなく、新しい要素として保持できます。

たとえば、概念的に、

```text
1 → "A"
2 → "B"
```

という状態へ、

```text
1 → "C"
```

を追加すると、

```text
1 → "A"
1 → "C"
2 → "B"
```

のように、キー `1` を持つ複数の要素を保持できます。

要素を追加しても、キーのソート順は自動的に維持されます。

また、キーによって取得した range view を通して、そのキーに対応する要素群を
まとめて走査できます。元の multimap から削除する場合は、
`map[key].erase()` のように subscript へ変更操作を直接呼び出します。

## Performance

`RedBlackTreeMultiMap` は赤黒木を使用しており、
木の高さは要素数に対して対数的に制限されます。

代表的な操作の計算量は次のようになります。

| 操作 | 計算量 |
| --- | ---: |
| `isEmpty` | O(1) |
| `count` | O(1) |
| `startIndex` | O(1) |
| `endIndex` | O(1) |
| キーによる検索 | O(log `count`) |
| lower-bound 検索 | O(log `count`) |
| upper-bound 検索 | O(log `count`) |
| 要素の挿入 | O(log `count`) |
| キーを検索して1要素を削除 | O(log `count`) |
| キーを検索して一致するK要素を削除 | O(log `count` + K) |
| 既知のindexから削除 | 償却 O(1) |

同じキーを持つ要素をすべて処理する場合には、
キーの検索に加えて、そのキーに対応する要素数に比例した時間が必要です。

たとえば、あるキーに `m` 個の値が関連付けられている場合、
その範囲を検索してすべての要素を処理するコストは
O(log `count` + `m`) となります。

range view 自体は対象要素を新しい配列へコピーせず、
赤黒木上の範囲を直接表現します。

実際の実行時間は、`Key` の比較コストやメモリアクセスの特性によっても変化します。

特に `Key` の比較が一定時間ではない場合、
検索・挿入・削除の実際のコストには比較処理のコストも加わります。

## Red-Black Tree

赤黒木は自己平衡二分探索木の一種です。

各要素はキーの順序に従って配置され、
挿入や削除の際にはノードの色変更や回転操作によって木のバランスが維持されます。

この仕組みにより、特定の挿入順序によって木が極端に片寄ることを防ぎ、
検索・挿入・削除の最悪計算量を O(log `count`) に保ちます。

また、挿入や削除に伴う再平衡化処理のコストは、償却 O(1) となります。

この点は、平衡処理を行わない単純な二分探索木とは異なります。

## Implementation Details

`RedBlackTreeMultiMap` は、各キーと値の組を赤黒木のノードとして管理します。

同じキーを持つ要素も、それぞれ独立したノードとして保持されます。

赤黒木上の順序はキーによって決定されるため、
同じキーを持つすべての要素は論理的なソート順の中で連続した範囲を形成します。

キーによる subscript が返す `RedBlackTreeKeyValueRangeView` は、
この論理的な範囲を表します。

そのため、対象要素を別の配列へコピーすることなく、
範囲内の要素を直接走査できます。

ノードは個別に独立したヒープ allocation を行うのではなく、
複数のノードをまとめた storage 上に配置されます。

この方式により、ノードごとに個別 allocation を行う実装と比較して、
allocation overhead を削減できます。

また、ノードの管理情報と格納されるキー・値は互いに近い位置に配置されます。

これにより、赤黒木として必要なノードベースの構造を維持しながら、
走査時のメモリアクセス効率を改善できるよう設計されています。

`RedBlackTreeMultiMap` の要素は論理的には常にキー順に並んでいますが、
メモリ上でもその順序どおりに配置されているわけではありません。

つまり、論理的にはソート済みですが、`Array` のように
物理的な配置までソート順になっているデータ構造ではありません。

そのため、`RedBlackTreeMultiMap` は連続配列とは異なる
メモリアクセス特性や性能特性を持ちます。

## Choosing a Collection

用途によって、適した辞書型は異なります。

標準ライブラリの `Dictionary` は、
各キーに値を1つだけ関連付け、
主に高速なキー検索を行いたい場合に適しています。

`RedBlackTreeDictionary` は、
各キーに値を1つだけ関連付けながら、
キーのソート順を維持し、順序に基づく検索を行いたい場合に適しています。

`RedBlackTreeMultiMap` は、
同じキーに複数の値を関連付けながら、
キーのソート順を維持し、
キーに対応する要素群を range view として直接扱いたい場合に適しています。

単にキーごとに複数の値をまとめて保持するだけでよく、
個々の key-value 要素を独立したソート済み要素として扱う必要がない場合は、
`Dictionary<Key, [Value]>` などの構成が適していることもあります。

---

## Current Source Type Documentation

<!-- 以下は現行 RedBlackTreeMultiMap.swift の型コメント。上記にない内容を取りこぼさないための編集素材。 -->

# RedBlackTreeMultiMap

`RedBlackTreeMultiMap` is a **sorted multimap (allowing duplicate keys)**
implemented using a red-black tree.
Keys are always kept in sorted order.
The order of elements with the same key is the insertion order.

```swift
var map: RedBlackTreeMultiMap<Int, String> = []
map.insert(key: 3, value: "a") // -> [3: "a"]
map.insert(key: 1, value: "b") // -> [1: "b", 3: "a"]
map.insert(key: 4, value: "c") // -> [1: "b", 3: "a", 4: "c"]
map.insert(key: 1, value: "d") // -> [1: "b", 1: "d", 3: "a", 4: "c"]
map.insert(key: 5, value: "e") // -> [1: "b", 1: "d", 3: "a", 4: "c", 5: "e"]
```

## Removal

Both single-element removal and range removal are supported.

```swift
var map: RedBlackTreeMultiMap<Int, String> =
  [1: "b", 1: "d", 3: "a", 4: "c", 5: "e"]
map.eraseUnique(3) // -> [1: "b", 1: "d", 4: "c", 5: "e"]
```

Avoid performing repeated removals via indices in a `for` loop.
Since indices are tightly coupled with tree nodes, removing an element
invalidates the operation that retrieves the next index.
Use the range-removal APIs for consecutive deletions instead.

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

As in C++, sequential removal using `erase(_:) -> Index` is also supported.
You can remove elements while receiving the next index.

```swift
var map: RedBlackTreeMultiMap<Int, String> =
  [1: "b", 1: "d", 3: "a", 4: "c", 5: "e"]
var i = map.startIndex
while i != map.endIndex {
  i = map.erase(i)
}
```

## Index Alternative Syntax

`BoundExpression` is designed as a **safe alternative** to direct index usage.
It allows specifying elements or boundaries without handling indices directly.

```swift
var map: RedBlackTreeMultiMap<Int, String> =
  [1: "b", 1: "d", 3: "a", 4: "c", 5: "e"]
print(map[.start.advance(by: 1)]) // -> (1, "d")
```

```swift
var map: RedBlackTreeMultiMap<Int, String> =
  [1: "b", 1: "d", 3: "a", 4: "c", 5: "e"]
print(map[.lowerBound(5)]) // -> (5, "e")
print(map[.upperBound(5)]) // -> nil (equivalent to end)
print(map[.find(2)])       // -> nil (not found)
```

- Important: `RedBlackTreeMultiMap` is not thread-safe.

