<!-- 日本語版が正とします。英語版はこの文書の英訳コピーです。 -->
<!-- 解説を読むために少しだけC++してる人が対象読者だったりする -->
<!-- 正確な互換資料を書いた結果として発生する洗礼程度のニュアンス -->

# `std::set` との対応状況

`RedBlackTreeSet` は、C++ の `std::set` で一般的に利用される多くの機能に対応しています。

以下の表では、典型的な `std::set` の機能が
`RedBlackTreeSet` ではどのように対応するかをまとめます。

## 凡例

| 記号 | 意味 |
| --- | --- |
| ✅ | 直接対応する機能、または実質的に同等の操作がある |
| △ | 同様のことはできるが、API や表現方法、意味論が異なる |
| ❌ | 直接対応する機能がない |
| — | Swift では該当しない |

## 概要

| C++ `std::set` | Swift / `RedBlackTreeSet` | 対応 | 備考 |
| --- | --- | :---: | --- |
| ソート済みの一意な要素 | `RedBlackTreeSet` | ✅ | 要素は昇順に保持され、重複は格納されない |
| `std::set<T>` | `RedBlackTreeSet<T>` | ✅ | `Element` は `Comparable` に準拠する |
| `size()` | `count` | ✅ | O(1) |
| `empty()` | `isEmpty` | ✅ | O(1) |
| `begin()` | `startIndex` / iteration | ✅ | 最初の要素を表す |
| `end()` | `endIndex` | ✅ | 最後の要素の直後を表す |
| 順方向走査 | `for-in`, `Sequence` | ✅ | 要素はソート順で現れる |
| 双方向走査 | index navigation | ✅ | C++ iterator とは API が異なる |
| 逆方向走査 | `reversed()` など | △ | `rbegin()` / `rend()` とは API が異なる |

## Swift `Set` との違い

Swift 標準ライブラリの `Set` と `RedBlackTreeSet` は、
どちらも重複しない要素を保持する集合です。

大きな違いは、
`RedBlackTreeSet` が要素の順序を常に維持することです。

| 特性 | Swift `Set` | `RedBlackTreeSet` |
| --- | --- | --- |
| 要素の制約 | `Hashable` | `Comparable` |
| 重複要素 | 保持しない | 保持しない |
| 要素のソート順 | 保証しない | 常に昇順 |
| membership test | 平均 O(1) | O(log `count`) |
| 挿入 | 平均 O(1) | O(log `count`) |
| 削除 | 平均 O(1) | O(log `count`) |
| lower-bound | ❌ | ✅ |
| upper-bound | ❌ | ✅ |
| 順序に基づく検索 | ❌ | ✅ |
| 昇順走査 | 別途ソートが必要 | そのまま走査可能 |
| mutation をまたぐ index の保持 | 前提にできない | 他要素の変更では維持される |
| `SetAlgebra` | ✅ | ✅ |

単純な membership test が中心で、
要素の順序を必要としない場合には
Swift 標準ライブラリの `Set` が適しています。

一方、

- 要素を追加・削除しながらソート順を維持したい
- 指定した値以上の最小要素を探したい
- 指定した値より大きい最小要素を探したい
- ある要素の前後にある要素を調べたい
- mutation をまたいで特定の要素位置を保持したい

といった場合には、
`RedBlackTreeSet` の順序付き構造を利用できます。

## 検索

| C++ `std::set` | Swift / `RedBlackTreeSet` | 対応 | 備考 |
| --- | --- | :---: | --- |
| `find(key)` | 値による検索 | ✅ | O(log `count`) |
| `contains(key)` | `contains` または同等の検索 | ✅ | O(log `count`) |
| `count(key)` | membership test | △ | set なので一致する要素は高々1つ |
| `lower_bound(key)` | lower-bound 検索 | ✅ | O(log `count`) |
| `upper_bound(key)` | upper-bound 検索 | ✅ | O(log `count`) |
| `equal_range(key)` | lower-bound / upper-bound | △ | set では範囲は高々1要素 |
| 順序付き範囲検索 | tree index による範囲 | ✅ | 先頭から線形走査する必要がない |

### Swift `Set` との違い

Swift `Set` でも、
ある値が集合に含まれているかどうかは効率的に調べられます。

一方、

```text
x 以上で最小の要素
x より大きい最小の要素
x の直前にある要素
```

のような順序に基づく検索は、
集合自体がソート順を持たないため直接は行えません。

`RedBlackTreeSet` では、
lower-bound / upper-bound によって
このような検索を O(log `count`) で行えます。

C++ の解説で、

```cpp
auto it = set.lower_bound(x);
```

のようなコードが現れた場合には、
単純な membership test ではなく、
`std::set` の順序付き集合としての性質が使われています。

### `equal_range`

`std::set::equal_range(key)` は、
指定した値と等価な要素の範囲を返します。

`std::set` は重複を保持しないため、その範囲は、

```text
値が存在する   → 1要素
値が存在しない → 空
```

のどちらかになります。

`RedBlackTreeSet` では、
lower-bound と upper-bound を使って同様の範囲を表現できます。

`equal_range` に相当する操作は、
重複を保持する `RedBlackTreeMultiSet` や
`RedBlackTreeMultiMap` で特に有用です。

## 挿入

| C++ `std::set` | Swift / `RedBlackTreeSet` | 対応 | 備考 |
| --- | --- | :---: | --- |
| `insert(value)` | `insert(_:)` | ✅ | ソート順を維持する |
| 重複要素の挿入を拒否 | `insert(_:)` | ✅ | 同値な要素は重複して追加されない |
| `emplace(...)` | 値を構築して `insert(_:)` | △ | C++ の in-place construction に直接対応する API はない |
| `emplace_hint(...)` | — | ❌ | C++ の emplacement / hint API は採用していない |
| `insert(hint, value)` | — | ❌ | hint 付き挿入は既存 API と semantics が異なる |
| range insertion | `Sequence` ベースの初期化 / 挿入 | △ | Swift では iterator pair より `Sequence` を使う |

Swift 標準 `Set` と `RedBlackTreeSet` はどちらも、
既に同値な要素が存在する場合には
集合内の要素数を増やしません。

`RedBlackTreeSet` では、
挿入後も木によって要素のソート順が維持されます。

### Hint 付き挿入

C++ の `std::set::insert` には、
挿入位置の近くを iterator で指定する hint 付き overload があります。

正しい hint が与えられた場合には、
root から挿入位置を探索する処理を省略できるため、
挿入を高速化できる場合があります。

ただし、hint 付き `insert` は通常の `insert` と
戻り値や API semantics が異なります。

`RedBlackTreeSet` では、
C++ と同じ形式の hint 付き挿入 API は提供しません。

### Emplacement

C++ の `emplace` は、
挿入する値をコンテナ外で構築してから渡すのではなく、
コンテナが保持する要素として直接構築するための API です。

Swift では通常、

```swift
set.insert(Foo(...))
```

のように値を構築してそのまま渡す形が自然です。

C++ の placement construction や move construction と
同一の構築 semantics を API として露出する必要性は低いため、
C++ と同じ `emplace` API は提供しません。

機能的には `insert(_:)` で同じ用途を表現できますが、
構築 semantics が異なるため △ としています。

## 削除

| C++ `std::set` | Swift / `RedBlackTreeSet` | 対応 | 備考 |
| --- | --- | :---: | --- |
| `erase(key)` | 値による削除 | ✅ | O(log `count`) |
| `erase(iterator)` | index による削除 | ✅ | 既知の位置にある要素を削除 |
| `erase(first, last)` | 範囲削除 | △ | C++ の iterator pair とは API が異なる |
| `clear()` | 全要素削除 | ✅ | |
| `node_handle` | node handle 相当 | ✅ | node を表す handle |
| `extract()` | — | ❌ | 直接対応する公開 API はない |

### `node_handle` / `extract()`

C++ の `std::set` は、
`node_handle` と `extract()` を利用して、
要素をコンテナから切り離して扱うことができます。

```cpp
auto node = set.extract(value);
```

`extract()` で取り出した node は、
値を保持したまま別のコンテナへ再挿入するなどの用途に利用できます。

`RedBlackTreeSet` にも、
node を表現する handle に相当する仕組みがあります。

一方、
C++ の `std::set::extract()` と直接対応する
公開 API は提供していません。

`node_handle` や `extract()` の対応状況は、
公開 API とその semantics に基づいて比較します。

## Iterator と Index

| C++ `std::set` | Swift / `RedBlackTreeSet` | 対応 | 備考 |
| --- | --- | :---: | --- |
| `iterator` | `Index` | △ | 役割は近いが、Swift の index と C++ iterator は同一概念ではない |
| `const_iterator` | `Index` | △ | set の要素を index 経由で直接変更しない |
| `++iterator` | `index(after:)` / iterator `next()` | ✅ | |
| `--iterator` | `index(before:)` | ✅ | |
| iterator dereference | subscript / iteration | ✅ | |
| `distance(first, last)` | `distance(from:to:)` | ✅ | |
| `std::next` | `index(_:offsetBy:)` | △ | Swift の index navigation API を使う |
| `std::prev` | backward index navigation | △ | |
| iterator pair `[first, last)` | `Range<Index>` / range view | △ | 半開区間という考え方は近い |

Swift の `Index` と C++ の iterator は
同一の abstraction ではありません。

一方で、

- 集合内の位置を表す
- その位置の要素へアクセスする
- 前後の位置へ移動する
- 範囲の境界として利用する

といった役割には共通点があります。

たとえば C++ の、

```cpp
auto it = set.lower_bound(x);

if (it != set.end()) {
    ++it;
}
```

は概念的には、

```text
lower-bound で Index を取得
        ↓
endIndex でないことを確認
        ↓
index(after:) で次の位置へ移動
```

と読み替えられます。

## Index の安定性

`RedBlackTreeSet` の index は、
`std::set` iterator と同様に高い安定性を持ちます。

別の要素を挿入したり削除したりしても、
それまで指していた要素が存在する限り、
その index は有効なままです。

その index が指している要素自体を削除した場合にのみ、
その index は無効になります。

| 操作 | `std::set` iterator | Swift `Set` index | `RedBlackTreeSet` index |
| --- | --- | --- | --- |
| 別の要素を挿入 | 有効なまま | 保証されない | 有効なまま |
| 別の要素を削除 | 有効なまま | 保証されない | 有効なまま |
| 指している要素を削除 | 無効 | 無効になり得る | 無効 |

この性質により、
mutation をまたいで特定の要素位置を保持するアルゴリズムも構築できます。

C++ の `std::set` iterator を保持しながら
集合を更新するアルゴリズムを Swift へ読み替える場合にも、
この性質を利用できます。

## 順序

| C++ `std::set` | Swift / `RedBlackTreeSet` | 対応 | 備考 |
| --- | --- | :---: | --- |
| ソート済み走査 | 標準動作 | ✅ | 要素は常に昇順で走査される |
| `Compare` template parameter | `Element: Comparable` | △ | 順序の与え方が異なる |
| `std::less<T>` | `Comparable` の `<` | ✅ | |
| カスタム comparator | `Comparable` への適合 | △ | 任意の順序は定義できるが、container ごとの差し替え方式ではない |
| `key_comp()` | `Comparable` の `<` | △ | comparator object を保持・公開しない |
| `value_comp()` | `Comparable` の `<` | △ | set では key と value は同一要素 |

Swift ではカスタム型自身を `Comparable` に適合させることで、
独自の順序を定義できます。

```swift
struct Foo: Comparable {
  let name: String
  let age: Int

  static func < (lhs: Foo, rhs: Foo) -> Bool {
    lhs.name < rhs.name
  }
}
```

このため、
カスタム順序そのものは利用できます。

ただし C++ のように、

```cpp
std::set<Foo, ByName>
std::set<Foo, ByAge>
```

と同じ型に対して
container ごとに comparator object を差し替える方式ではありません。

複数の順序が必要な場合には、
異なる wrapper 型などによって
順序を型として表現できます。

### Swift `Set` との違い

Swift `Set` の要素には `Hashable` が要求されます。

一方、`RedBlackTreeSet` では
要素間の順序を利用して木を構成するため、
`Comparable` が要求されます。

```text
Swift Set
    ↓
hash / equality

RedBlackTreeSet
    ↓
ordering
```

この違いが、
membership test の特性だけでなく、
lower-bound、upper-bound、昇順走査などの
利用可能な操作の違いにもつながります。

## 比較

| C++ | Swift / `RedBlackTreeSet` | 対応 | 備考 |
| --- | --- | :---: | --- |
| 等価比較 | `==`, `!=` | ✅ | 要素列として比較できる |
| 辞書順比較 | `<`, `<=`, `>`, `>=` | ✅ | ソート済み要素列として辞書順比較できる |

`RedBlackTreeSet` は、
要素の比較能力に基づいて
集合全体の等価比較および順序比較を行えます。

## 集合演算

`RedBlackTreeSet` は Swift の `SetAlgebra` に準拠しており、
標準的な集合演算を利用できます。

| C++ | Swift / `RedBlackTreeSet` | 対応 | 備考 |
| --- | --- | :---: | --- |
| `std::set_union` | `union(_:)` / `formUnion(_:)` | ✅ | 和集合 |
| `std::set_intersection` | `intersection(_:)` / `formIntersection(_:)` | ✅ | 積集合 |
| `std::set_difference` | `subtracting(_:)` / `subtract(_:)` | ✅ | 差集合 |
| `std::set_symmetric_difference` | `symmetricDifference(_:)` / `formSymmetricDifference(_:)` | ✅ | 対称差 |

C++ では `<algorithm>` の iterator-pair ベースの関数として提供されますが、
`RedBlackTreeSet` では Swift の `SetAlgebra` API として利用します。

たとえば、

```cpp
std::set_union(
    a.begin(), a.end(),
    b.begin(), b.end(),
    std::back_inserter(result)
);
```

に対応する処理は、Swift では、

```swift
let result = a.union(b)
```

のように表現できます。

`SetAlgebra` への準拠により、集合演算だけでなく、

- `isSubset(of:)`
- `isSuperset(of:)`
- `isStrictSubset(of:)`
- `isStrictSuperset(of:)`
- `isDisjoint(with:)`

などの集合関係を表す API も利用できます。

### Swift `Set` との共通点

Swift 標準 `Set` と `RedBlackTreeSet` は、
どちらも `SetAlgebra` に準拠しているため、
集合演算については同じ API を利用できます。

```swift
a.union(b)
a.intersection(b)
a.subtracting(b)
a.symmetricDifference(b)
```

一方、`RedBlackTreeSet` は集合演算の結果についても
要素のソート順を維持し、
lower-bound / upper-bound などの
順序付き集合としての操作を引き続き利用できます。

## Sequence

`RedBlackTreeSet` は Swift の `Sequence` として走査できます。

```swift
for element in set {
  print(element)
}
```

`makeIterator()` が赤黒木上の順次走査を提供し、
要素は昇順に現れます。

`Sequence` に適合しているため、
Swift 標準ライブラリの各種 sequence algorithm も利用できます。

### Swift `Set` との違い

Swift `Set` も `Sequence` として走査できますが、
その走査順は要素のソート順を意味しません。

`RedBlackTreeSet` では、

```swift
for element in set {
  // ascending order
}
```

という通常の `for-in` 自体が
要素の昇順走査になります。

これは C++ の、

```cpp
for (const auto& value : set) {
    // ascending order
}
```

と同じように利用できます。

## Lazy Sequence 操作

Swift 標準ライブラリの lazy sequence adapter も
そのまま利用できます。

```swift
let result = set.lazy
  .filter { $0.isMultiple(of: 2) }
  .map { $0 * 10 }
```

`lazy` を利用すると、
`filter` や `map` の各段階で中間コレクションを生成せず、
iterator を通して要素ごとに遅延評価できます。

概念的には、

```text
RedBlackTreeSet.Iterator
        ↓ next()
      filter
        ↓
       map
        ↓
     consumer
```

のように処理されます。

| 操作 | 対応 |
| --- | :---: |
| `set.lazy` | ✅ |
| lazy `map` | ✅ |
| lazy `filter` | ✅ |
| lazy pipeline | ✅ |
| `prefix` などによる途中打ち切り | ✅ |

たとえば、

```swift
let result = set.lazy
  .filter { predicate($0) }
  .map { transform($0) }
  .prefix(10)
```

では、
全要素を `filter` してから全要素を `map` する必要はなく、
必要な結果が得られるところまでだけ処理できます。

この機能のために
`RedBlackTreeSet` 専用の lazy implementation を持つ必要はなく、
正しく効率的な `Sequence` と iterator を提供することで、
Swift 標準ライブラリの公開 lazy adapter を利用できます。

## メモリと所有権

`std::set` と `RedBlackTreeSet` は、
どちらもコンテナを値としてコピーし、
コピー後に独立して変更できます。

| C++ `std::set` | Swift / `RedBlackTreeSet` | 対応 | 備考 |
| --- | --- | :---: | --- |
| 値としてコピー可能 | value semantics | ✅ | コピー後は独立した値として振る舞う |
| copy construction | copy-on-write | △ | コピーを実現する仕組みが異なる |
| move construction | Swift の ownership semantics | △ | object model が異なる |
| allocator customization | — | ❌ | C++ allocator API の直接対応はない |
| `node_handle` | node handle 相当 | ✅ | |
| `swap()` | Swift `swap` | ✅ | |
| RAII | Swift の自動 lifetime 管理 | △ | lifetime / ownership model が異なる |

`RedBlackTreeSet` は value semantics を持ち、
値をコピーした後はそれぞれを独立して変更できます。

```swift
var a = set
var b = a

b.insert(value)
```

`b` を変更しても、
`a` の集合としての値は変化しません。

`RedBlackTreeSet` では、
この value semantics を効率的に実現するために
copy-on-write を利用します。

### Implementation Details

`RedBlackTreeSet` は赤黒木として要素を管理します。

ノードは1要素ごとに独立した allocation を行うのではなく、
複数のノードをまとめた storage 上に配置します。

これにより、
赤黒木としての node-based structure を維持しながら、
allocation overhead を抑えるよう設計されています。

これらは `RedBlackTreeSet` 自身の implementation details です。

Swift 標準ライブラリの `Set` が内部でどのような
storage、layout、allocation strategy を採用しているかについては、
ここでは比較しません。

## `std::set` との主な対応

代表的な操作は次のように対応します。

| C++ | `RedBlackTreeSet` |
| --- | --- |
| `std::set<T>` | `RedBlackTreeSet<T>` |
| `set.size()` | `set.count` |
| `set.empty()` | `set.isEmpty` |
| `set.find(x)` | 値による検索 |
| `set.contains(x)` | `contains` 相当 |
| `set.lower_bound(x)` | lower-bound 検索 |
| `set.upper_bound(x)` | upper-bound 検索 |
| `set.insert(x)` | `insert(x)` |
| `set.erase(x)` | 値による削除 |
| `set.erase(it)` | index による削除 |
| `set.begin()` | `startIndex` |
| `set.end()` | `endIndex` |
| `++it` | `index(after:)` |
| `--it` | `index(before:)` |
| range-based `for` | `for-in` |

API の名前や型は異なりますが、

```text
ソート済み集合
検索
挿入
削除
lower-bound / upper-bound
前後への移動
昇順走査
```

といった、
`std::set` を利用する典型的なアルゴリズムは
対応付けて考えることができます。

## C++ に固有性の強い機能

次の機能は、
C++ の object model、allocator model、
iterator model などと強く結びついており、
`RedBlackTreeSet` では同一の API 形式を採用していません。

- allocator customization
- `extract()` による node の切り離し
- node transfer を利用した `merge()`
- `emplace()` / `emplace_hint()` の C++ と同一の construction semantics
- hint 付き `insert`
- container ごとに保持する comparator object

一方、
`node_handle` に相当する仕組みは提供されています。

C++ と直接同じ API がない場合でも、
その操作が目的としている処理を
Swift の別の API や semantics で表現できる場合があります。
