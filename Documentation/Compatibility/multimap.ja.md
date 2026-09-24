<!-- 日本語版が正とします。英語版はこの文書の英訳コピーです。 -->
<!-- 解説を読むために少しだけC++してる人が対象読者だったりする -->
<!-- 正確な互換資料を書いた結果として発生する洗礼程度のニュアンス-->

# `std::multimap` との対応状況

`RedBlackTreeMultiMap` は、C++ の `std::multimap` と同様に、
同じキーを持つ複数の key-value 要素をソート済みの状態で保持します。

以下の表では、典型的な `std::multimap` の機能が
`RedBlackTreeMultiMap` ではどのように対応するかをまとめます。

## 凡例

| 記号 | 意味 |
| --- | --- |
| ✅ | 直接対応する機能、または実質的に同等の操作がある |
| △ | 同様のことはできるが、API や表現方法、意味論が異なる |
| ❌ | 直接対応する機能がない |
| — | Swift では該当しない |

## 概要

| C++ `std::multimap` | Swift / `RedBlackTreeMultiMap` | 対応 | 備考 |
| --- | --- | :---: | --- |
| ソート済み key-value 要素 | `RedBlackTreeMultiMap` | ✅ | 要素はキーの昇順に保持される |
| 同じキーを複数保持 | 同一キーの複数要素 | ✅ | 各 key-value 要素は独立して保持される |
| 同一キー内の挿入順保持 | 同一キー内の挿入順保持 | ✅ | 同じキーを持つ要素は挿入順を維持する |
| `std::multimap<Key, T>` | `RedBlackTreeMultiMap<Key, Value>` | ✅ | `Key` は `Comparable` に準拠する |
| `size()` | `count` | ✅ | O(1) |
| `empty()` | `isEmpty` | ✅ | O(1) |
| `begin()` | `startIndex` / iteration | ✅ | 最初の要素を表す |
| `end()` | `endIndex` | ✅ | 最後の要素の直後を表す |
| 順方向走査 | `for-in`, `Sequence` | ✅ | 要素はキー順で現れる |
| 双方向走査 | index navigation | ✅ | C++ iterator とは API が異なる |
| 逆方向走査 | `reversed()` など | △ | `rbegin()` / `rend()` とは API が異なる |

## 同じキーを持つ複数の要素

`RedBlackTreeMultiMap` では、
順序比較上同一とみなされるキーを持つ要素を複数保持できます。

概念的には、

```text
(1, "red")
(1, "green")
(1, "blue")
(2, "orange")
```

のような内容を保持できます。

赤黒木上の順序はキーによって決まり、
同じキーを持つ要素はソート順の中で連続した範囲を形成します。

`Value` は木の順序付けには使用されないため、
`Comparable` に準拠する必要はありません。

## 同一キー内の順序

`RedBlackTreeMultiMap` では、
同じキーを持つ要素の相対的な順序として挿入順を保持します。

たとえば、

```swift
map.insert((1, "red"))
map.insert((1, "green"))
map.insert((1, "blue"))
```

の順に挿入した場合、
キー `1` に属する要素は、

```text
(1, "red")
(1, "green")
(1, "blue")
```

の順序で走査されます。

これは `Value` によるソートではありません。

```text
Key による順序
    ↓
1 → "red"
1 → "green"
1 → "blue"
2 → "orange"
```

同一キーの範囲では、
そのキーを持つ要素の挿入時の相対順序が維持されます。

この性質は C++ の `std::multimap` と同様です。

## 検索

| C++ `std::multimap` | Swift / `RedBlackTreeMultiMap` | 対応 | 備考 |
| --- | --- | :---: | --- |
| `find(key)` | キーによる検索 | ✅ | O(log `count`) |
| `contains(key)` | キーの存在確認 | ✅ | O(log `count`) |
| `count(key)` | キー範囲の `count` | △ | 同一キーの range view を通して要素数を取得できる |
| `lower_bound(key)` | lower-bound 検索 | ✅ | O(log `count`) |
| `upper_bound(key)` | upper-bound 検索 | ✅ | O(log `count`) |
| `equal_range(key)` | `equalRange(_:)` | ✅ | 同じキーを持つ要素の半開区間を返す |
| キー範囲検索 | tree index / range | ✅ | 先頭から線形走査する必要がない |

## `equal_range`

`RedBlackTreeMultiMap` は、
C++ の `std::multimap::equal_range` に直接対応する
`equalRange(_:)` を提供します。

```swift
let range = map.equalRange(key)
```

この range は、指定したキーと等価な要素の
lower-bound から upper-bound までの半開区間を表します。

```text
lower-bound
    ↓
[(key, A), (key, B), (key, C)]
                              ↑
                      upper-bound
```

したがって、

```cpp
auto [first, last] = map.equal_range(key);
```

を利用する C++ のアルゴリズムと同様に、
同一キーを持つ要素の範囲を直接扱えます。

## キー Subscript

`RedBlackTreeMultiMap` ではさらに、
キーを指定した subscript が単一の値ではなく、
そのキーを持つすべての key-value 要素を表す
`RedBlackTreeKeyValueRangeView` を返します。

```swift
let elements = map[key]
```

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

`equalRange(_:)` が同一キー範囲を index range として取得するのに対して、
キー subscript はその範囲を直接操作できる view として表現します。

## Range View

キー subscript が返す `RedBlackTreeKeyValueRangeView` は、
同じキーを持つ key-value 要素の論理的な範囲を表します。

この view は対象要素を別の配列へコピーするのではなく、
元の赤黒木と、その範囲の開始位置・終了位置を保持します。

```swift
let elements = map[key]

for element in elements {
  // ...
}
```

view の要素は key-value の組です。

また、キーだけ、または値だけを走査できます。

```swift
for key in elements.keys {
  // ...
}

for value in elements.values {
  // ...
}
```

`keys` と `values` も対象要素を配列へコピーするのではなく、
対応する範囲を走査する view を返します。

range view は読み取り専用ではありません。

変更可能な値として保持している場合には、
範囲内の要素を直接削除できます。

```swift
var elements = map[key]

elements.popFirst()
elements.popLast()
```

範囲全体や、条件に一致する要素を削除することもできます。

このため、同一キー検索の結果を単なる iterator pair として扱うだけでなく、
1つの部分コレクションとして直接操作できます。

## Element Access

C++ の `std::map` には、

```cpp
map[key]
```

という subscript がありますが、
`std::multimap` には単一 mapped value を返す `operator[]` はありません。

1つのキーに複数の値を持てるため、
どの mapped value を返すべきか一意に決められないためです。

`RedBlackTreeMultiMap` では、
単一の `Value` を返す代わりに、
そのキーに対応するすべての key-value 要素を range view として返します。

| 操作 | `std::multimap` | `RedBlackTreeMultiMap` |
| --- | :---: | :---: |
| `map[key]` | ❌ | ✅ range view |
| 単一 mapped value の取得 | — | — |
| 同一キー範囲 | `equal_range(key)` | `equalRange(_:)` |
| 同一キー範囲を view として取得 | — | `map[key]` |

これは `RedBlackTreeMultiMap` の API 上の大きな特徴です。

## 挿入

| C++ `std::multimap` | Swift / `RedBlackTreeMultiMap` | 対応 | 備考 |
| --- | --- | :---: | --- |
| `insert(value)` | 要素の挿入 | ✅ | 同じキーでも新しい要素として追加される |
| duplicate key insertion | 同一キーの挿入 | ✅ | 重複キーを許容する |
| 同値キー範囲の末尾への挿入 | 挿入順を保持 | ✅ | 同一キー内の相対順序を維持する |
| `emplace(...)` | 値を構築して挿入 | △ | C++ の in-place construction に直接対応する API はない |
| `emplace_hint(...)` | — | ❌ | C++ の emplacement / hint API は採用していない |
| `insert(hint, value)` | — | ❌ | hint 付き挿入は採用していない |
| range insertion | `Sequence` ベースの初期化 / 挿入 | △ | Swift では iterator pair より `Sequence` を使う |

同じキーを持つ要素を追加しても、
既存の mapped value を置き換えることはありません。

```text
1 → "red"
1 → "green"
```

という状態へ、

```text
1 → "blue"
```

を追加すると、

```text
1 → "red"
1 → "green"
1 → "blue"
```

となります。

## Hint 付き挿入

C++ の `std::multimap::insert` には、
挿入位置の近くを iterator で示す hint 付き overload があります。

正しい hint が与えられた場合には、
root から挿入位置を探索する処理を省略できるため、
挿入を高速化できる場合があります。

`RedBlackTreeMultiMap` では、
C++ と同じ形式の hint 付き挿入 API は提供しません。

## Emplacement

C++ の `emplace` は、
key-value オブジェクトをコンテナ外で完成させてから渡すのではなく、
コンテナ内部のノード上で直接構築するための API です。

Swift では通常、
Swift の値として key-value 要素を構築してから挿入する形が自然です。

C++ の placement construction や move construction と同じコストモデルを
API として露出する必要性は低いため、
C++ と同一の `emplace` semantics は提供しません。

同じ目的の挿入処理自体は可能であるため、
対応状況は △ としています。

## 削除

| C++ `std::multimap` | Swift / `RedBlackTreeMultiMap` | 対応 | 備考 |
| --- | --- | :---: | --- |
| `erase(key)` | キーに対応する要素群の削除 | ✅ | 同じキーを持つ要素群をまとめて削除できる |
| `erase(iterator)` | index による削除 | ✅ | 指定した1要素だけを削除する |
| `erase(first, last)` | range view / 範囲削除 | ✅ | 表現方法は C++ と異なる |
| `clear()` | 全要素削除 | ✅ | |
| `extract()` | — | ❌ | C++ の node ownership model に強く依存する機能 |

キー subscript が返す range view 自体から、
そのキーに対応する要素群をまとめて削除できます。

```swift
var elements = map[key]
elements.erase()
```

また、複数ある同一キー要素のうち一部だけを削除できます。

```swift
elements.popFirst()
elements.popLast()

elements.erase { element in
  // ...
}
```

同一キー内の一部の要素を削除しても、
残された要素同士の相対的な挿入順は維持されます。

## `extract()`

C++ の `extract()` は、
要素を木から取り除きながら、
ノード自体の ownership を `node_handle` として取り出す機能です。

これにより、node allocation を保持したまま、
別の container へ移動できます。

`RedBlackTreeMultiMap` ではノードを個別 allocation せず、
複数ノードを shared storage 上で管理します。

そのため、1つのノードを独立した ownership unit として安全に外部へ取り出す
C++ の `node_handle` モデルとは相性がよくありません。

## Iterator と Index

| C++ `std::multimap` | Swift / `RedBlackTreeMultiMap` | 対応 | 備考 |
| --- | --- | :---: | --- |
| `iterator` | `Index` | △ | 役割は近いが同一概念ではない |
| `const_iterator` | `Index` | △ | Swift の index model を使用する |
| `++iterator` | `index(after:)` / iterator `next()` | ✅ | |
| `--iterator` | `index(before:)` | ✅ | |
| iterator dereference | subscript / iteration | ✅ | |
| `distance(first, last)` | `distance(from:to:)` | ✅ | |
| `std::next` | `index(_:offsetBy:)` | △ | Swift の index navigation API を使う |
| `std::prev` | backward index navigation | △ | |
| iterator pair `[first, last)` | `Range<Index>` / range view | △ | Swift では範囲自体を型として扱える |

キー subscript が返す `RedBlackTreeKeyValueRangeView` も
元の multimap と同じ index 型を使用します。

そのため、元のコレクションと view の間で
同じ要素位置を表現できます。

## Index の安定性

`RedBlackTreeMultiMap` の index は、
別の要素を挿入したり削除したりしても、
それまで指していた要素が存在する限り有効です。

その index が指している要素自体を削除した場合には、
その index は無効になります。

| 操作 | `std::multimap` iterator | `RedBlackTreeMultiMap` index |
| --- | --- | --- |
| 別の要素を挿入 | 有効なまま | ✅ 有効なまま |
| 別の要素を削除 | 有効なまま | ✅ 有効なまま |
| 指している要素を削除 | 無効 | 無効 |

この性質により、
mutation をまたいで特定の要素位置を保持できます。

同じキーを持つ複数の要素についても、
それぞれが個別の index を持ちます。

## 順序

| C++ `std::multimap` | Swift / `RedBlackTreeMultiMap` | 対応 | 備考 |
| --- | --- | :---: | --- |
| キー順による走査 | 標準動作 | ✅ | key-value 要素はキーの昇順で走査される |
| 同値キー内の挿入順 | 挿入順を維持 | ✅ | 同じキーを持つ要素の相対順序を保持する |
| `Compare` template parameter | `Key: Comparable` | △ | 順序の与え方が異なる |
| `std::less<Key>` | `Comparable` の `<` | ✅ | |
| カスタム comparator | `Comparable` への適合 | △ | 任意の順序は定義できるが container ごとの差し替え方式ではない |
| `key_comp()` | `Comparable` の `<` | △ | comparator object を保持・公開しない |
| `value_comp()` | キーによる要素順序 | △ | mapped value は木の順序に参加しない |

Swift ではカスタムキー型自身を `Comparable` に適合させることで、
任意のキー順を定義できます。

```swift
struct Key: Comparable {
  let value: String

  static func < (lhs: Key, rhs: Key) -> Bool {
    lhs.value < rhs.value
  }
}
```

C++ のように、

```cpp
std::multimap<Key, Value, CompareA>
std::multimap<Key, Value, CompareB>
```

と container ごとに comparator object を差し替える方式ではありません。

複数の順序が必要な場合には、
wrapper 型などによって異なる順序を型として表現できます。

## Key と Value の順序

`RedBlackTreeMultiMap` の木構造上の順序は
`Key` の比較によって決定されます。

`Value` は木のソート条件には参加しません。

一方で、同じキーを持つ複数の要素については、
その相対順序として挿入順が保持されます。

たとえば、

```text
insert (1, "red")
insert (1, "green")
insert (1, "blue")
```

とした場合、

```text
(1, "red")
(1, "green")
(1, "blue")
```

の順になります。

これは、

```text
"blue" < "green" < "red"
```

のような `Value` の比較結果によって並べ替えられているわけではありません。

つまり順序は、

```text
まず Key でソート
    ↓
同じ Key の中では挿入順を保持
```

という形になります。

これは `std::multimap` と同じ性質です。

## 比較

`RedBlackTreeMultiMap` 全体の比較については、
提供されている conditional conformance に応じて利用できます。

また、キー subscript が返す
`RedBlackTreeKeyValueRangeView` は、
要素型が対応している場合には
等価比較および辞書順比較を行えます。

| 操作 | 対応 |
| --- | :---: |
| range view の `==` | ✅ |
| range view の辞書順比較 | ✅ |

## Sequence

`RedBlackTreeMultiMap` は Swift の `Sequence` として走査できます。

```swift
for element in map {
  print(element)
}
```

要素はキーの昇順で現れ、
同じキーを持つ要素は挿入順を維持したまま連続して走査されます。

キー subscript が返す range view も `Sequence` として走査できます。

```swift
for element in map[key] {
  // ...
}
```

## Lazy Sequence 操作

Swift 標準ライブラリの lazy sequence adapter も利用できます。

```swift
let result = map.lazy
  .filter { element in
    // ...
  }
  .map { element in
    // ...
  }
```

`lazy` を利用すると、
各処理段階で中間コレクションを生成せず、
iterator を通して要素ごとに遅延評価できます。

概念的には、

```text
RedBlackTreeMultiMap.Iterator
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
| `map.lazy` | ✅ |
| lazy `map` | ✅ |
| lazy `filter` | ✅ |
| lazy pipeline | ✅ |
| `prefix` などによる途中打ち切り | ✅ |

正しく効率的な `Sequence` と iterator を提供することで、
Swift 標準ライブラリの lazy adapter をそのまま利用できます。

## メモリと所有権

| C++ `std::multimap` | Swift / `RedBlackTreeMultiMap` | 対応 | 備考 |
| --- | --- | :---: | --- |
| node-based tree | 赤黒木ノード | ✅ | |
| node ごとの allocation | shared node storage | △ | 複数ノードをまとめて storage 上に配置する |
| allocator template parameter | — | ❌ | C++ allocator customization の直接対応はない |
| `node_handle` | — | ❌ | shared storage 方式とは ownership model が異なる |
| move construction | Swift の ownership / value semantics | △ | C++ と object model が異なる |
| copy construction | copy-on-write | △ | tree storage 全体を即座に複製するとは限らない |
| `swap()` | Swift `swap` | ✅ | |
| RAII | Swift の自動 lifetime 管理 | △ | 目的は近いが ownership model は異なる |

`RedBlackTreeMultiMap` は、
典型的な STL の node-by-node allocation とは異なり、
複数のノードをまとめた storage 上に配置します。

キー subscript が返す range view も、
その storage 上の要素範囲を直接表現し、
対象要素を別の配列へコピーしません。

range view を変更する際に storage が共有されている場合には、
copy-on-write によって一意な storage が確保され、
view が表す開始位置と終了位置もコピー後の木へ引き継がれます。

## `std::multimap` との主な違い

`RedBlackTreeMultiMap` と `std::multimap` は、
基本的なデータ構造と主要な semantics がよく似ています。

| 項目 | `std::multimap` | `RedBlackTreeMultiMap` |
| --- | --- | --- |
| キー順 | comparator object | `Comparable` |
| 重複キー | ✅ | ✅ |
| 同一キー内の挿入順 | ✅ | ✅ |
| lower-bound | ✅ | ✅ |
| upper-bound | ✅ | ✅ |
| equal-range | ✅ | ✅ `equalRange(_:)` |
| キー subscript | ❌ | ✅ range view |
| iterator / index 安定性 | 強い | 強い |
| lazy sequence | C++ ranges 等を利用 | Swift `Sequence.lazy` |
| node allocation | 一般に node 単位 | shared storage |
| `node_handle` | ✅ | ❌ |
| `extract()` | ✅ | ❌ |
| hint insertion | ✅ | ❌ |
| in-place `emplace` | ✅ | △ |

特に、

```swift
map[key]
```

によって同一キー範囲を
`RedBlackTreeKeyValueRangeView` として直接扱える点は、
`std::multimap` にはない `RedBlackTreeMultiMap` の特徴です。

## `std::multimap` にない特徴

### キー Subscript

```swift
map[key]
```

によって、
そのキーに対応する key-value 要素群を
range view として取得できます。

### Range View の `keys` / `values`

```swift
map[key].keys
map[key].values
```

によって、
対象範囲のキーまたは値だけを直接走査できます。

### Range View の変更操作

range view 自体から、

```swift
popFirst()
popLast()
removeFirst()
removeLast()
erase()
erase(where:)
```

などを利用して、
対象範囲を直接変更できます。

このため `RedBlackTreeMultiMap` では、
`equalRange(_:)` による index range に加えて、
同一キー要素群を操作可能な部分コレクションとして扱えます。

## C++ に固有性の強い機能

次の機能は C++ の object model、allocator model、
iterator model と強く結びついており、
`RedBlackTreeMultiMap` では直接対応する API を提供しません。

- allocator customization
- `node_type`
- `node_handle`
- `extract()`
- node transfer を利用した `merge()`
- `emplace()` / `emplace_hint()` の C++ と同一の構築 semantics
- hint 付き `insert`
- container ごとに保持する comparator object

これらに直接対応する API がないことは、
必ずしも同じ目的を Swift で実現できないことを意味しません。

Swift の value semantics、copy-on-write、`Comparable`、
`Sequence`、`equalRange(_:)`、range view などを利用して、
Swift に適した形で同等の処理を表現できます。
