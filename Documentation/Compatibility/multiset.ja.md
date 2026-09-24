<!-- 日本語版が正とします。英語版はこの文書の英訳コピーです。 -->
<!-- 解説を読むために少しだけC++してる人が対象読者だったりする -->
<!-- 正確な互換資料を書いた結果として発生する洗礼程度のニュアンス-->

# `std::multiset` との対応状況

`RedBlackTreeMultiSet` は、C++ の `std::multiset` と同様に、
重複する要素を許容しながら、すべての要素をソート済みの状態で保持します。

以下の表では、典型的な `std::multiset` の機能が
`RedBlackTreeMultiSet` ではどのように対応するかをまとめます。

## 凡例

| 記号 | 意味 |
| --- | --- |
| ✅ | 直接対応する機能、または実質的に同等の操作がある |
| △ | 同様のことはできるが、API や表現方法、意味論が異なる |
| ❌ | 直接対応する機能がない |
| — | Swift では該当しない |

## 概要

| C++ `std::multiset` | Swift / `RedBlackTreeMultiSet` | 対応 | 備考 |
| --- | --- | :---: | --- |
| ソート済みの要素 | `RedBlackTreeMultiSet` | ✅ | 要素は昇順に保持される |
| 重複要素を保持 | 同値な要素を複数保持 | ✅ | 同じ値を複数回格納できる |
| `std::multiset<T>` | `RedBlackTreeMultiSet<T>` | ✅ | `Element` は `Comparable` に準拠する |
| `size()` | `count` | ✅ | O(1) |
| `empty()` | `isEmpty` | ✅ | O(1) |
| `begin()` | `startIndex` / iteration | ✅ | 最初の要素を表す |
| `end()` | `endIndex` | ✅ | 最後の要素の直後を表す |
| 順方向走査 | `for-in`, `Sequence` | ✅ | 要素はソート順で現れる |
| 双方向走査 | index navigation | ✅ | C++ iterator とは API が異なる |
| 逆方向走査 | `reversed()` など | △ | `rbegin()` / `rend()` とは API が異なる |

## 重複要素

`RedBlackTreeMultiSet` は、
順序比較上同一とみなされる要素を複数保持できます。

```swift
let numbers: RedBlackTreeMultiSet = [3, 1, 2, 3, 2, 1]

print(numbers)
// [1, 1, 2, 2, 3, 3]
```

同じ値を複数回挿入すると、
それぞれが独立した要素として保持されます。

この点は、一意な要素だけを保持する
`RedBlackTreeSet` との主要な違いです。

## 検索

| C++ `std::multiset` | Swift / `RedBlackTreeMultiSet` | 対応 | 備考 |
| --- | --- | :---: | --- |
| `find(key)` | 値による検索 | ✅ | O(log `count`) |
| `contains(key)` | 値の存在確認 | ✅ | O(log `count`) |
| `count(key)` | `count(of:)` | ✅ | O(log `count` + `m`)。`m` は一致する要素数 |
| `lower_bound(key)` | lower-bound 検索 | ✅ | O(log `count`) |
| `upper_bound(key)` | upper-bound 検索 | ✅ | O(log `count`) |
| `equal_range(key)` | `equalRange(_:)` | ✅ | O(log `count`)。同値要素の半開区間を返す |
| 順序付き範囲検索 | tree index / range | ✅ | 先頭から線形走査する必要がない |

## `equal_range`

`RedBlackTreeMultiSet` は、
C++ の `std::multiset::equal_range` に直接対応する
`equalRange(_:)` を提供します。

```swift
let range = set.equalRange(value)
```

この range は、指定した値と等価な要素の
lower-bound から upper-bound までの半開区間を表します。

```text
lower-bound
    ↓
[value, value, value]
                     ↑
             upper-bound
```

たとえば、

```text
1
2
2
2
3
4
```

という内容に対して値 `2` の `equalRange(_:)` を取得すると、

```text
    ↓ lower-bound
1 [ 2  2  2 ] 3 4
             ↑ upper-bound
```

の範囲が得られます。

計算量は O(log `count`) です。

## `count(of:)`

`RedBlackTreeMultiSet` は、
指定した値と等価な要素数を返す `count(of:)` を提供します。

```swift
let count = set.count(of: value)
```

これは C++ の `std::multiset::count` に対応します。

たとえば、

```text
[1, 2, 2, 2, 3]
```

に対して、

```swift
set.count(of: 2)
```

は `3` を返します。

計算量は O(log `count` + `m`) です。

ここで `m` は指定した値と一致する要素数です。

## 挿入

| C++ `std::multiset` | Swift / `RedBlackTreeMultiSet` | 対応 | 備考 |
| --- | --- | :---: | --- |
| `insert(value)` | `insert(_:)` | ✅ | 同値な要素が既に存在しても追加される |
| duplicate insertion | `insert(_:)` | ✅ | 重複を許容する |
| `emplace(...)` | 値を構築して `insert(_:)` | △ | C++ の in-place construction に直接対応する API はない |
| `emplace_hint(...)` | — | ❌ | C++ の emplacement / hint API は採用していない |
| `insert(hint, value)` | — | ❌ | hint 付き挿入は採用していない |
| range insertion | `Sequence` ベースの初期化 / 挿入 | △ | Swift では iterator pair より `Sequence` を使う |

`RedBlackTreeSet` と異なり、
同値な要素が既に存在する場合でも新しい要素として挿入されます。

```swift
var numbers: RedBlackTreeMultiSet = [1, 2, 2, 3]

numbers.insert(2)

// [1, 2, 2, 2, 3]
```

## Hint 付き挿入

C++ の `std::multiset::insert` には、
挿入位置の近くを iterator で示す hint 付き overload があります。

正しい hint が与えられた場合には、
root から挿入位置を探索する処理を省略できるため、
挿入を高速化できる場合があります。

`RedBlackTreeMultiSet` では、
C++ と同じ形式の hint 付き挿入 API は提供しません。

## Emplacement

C++ の `emplace` は、
要素をコンテナ外で完成させてから渡すのではなく、
ノード上で直接構築するための API です。

Swift では通常、

```swift
set.insert(Foo(...))
```

のように値を構築してそのまま渡す形が自然です。

C++ の placement construction や move construction と同じコストモデルを
API として露出する必要性は低いため、
C++ と同一の `emplace` semantics は提供しません。

同じ目的の挿入処理自体は可能であるため、
対応状況は △ としています。

## 削除

| C++ `std::multiset` | Swift / `RedBlackTreeMultiSet` | 対応 | 備考 |
| --- | --- | :---: | --- |
| `erase(key)` | 値による削除 | ✅ | 指定した値と等価な要素をすべて削除する |
| `erase(iterator)` | index による削除 | ✅ | 指定した1要素だけを削除する |
| `erase(first, last)` | 範囲削除 | △ | C++ の iterator pair とは API が異なる |
| `clear()` | 全要素削除 | ✅ | |
| `extract()` | — | ❌ | C++ の node ownership model に強く依存する機能 |

`RedBlackTreeMultiSet` では、
値を指定して削除すると、
その値と等価な要素が複数存在する場合、それらは一括してすべて削除されます。

たとえば、

```text
[1, 2, 2, 2, 3]
```

という状態で値 `2` を指定して削除すると、

```text
[1, 3]
```

となります。

複数ある同値要素のうち1つだけを削除したい場合は、
対象となる要素の index を取得し、その index を指定して削除します。

```text
[1, 2, 2, 2, 3]
       ↑
     index
```

この場合は、その index が指している1要素だけが削除されます。

`multiset` では同じ値を複数保持できるため、

- 値による削除 → 同値要素をすべて削除
- index による削除 → 特定の1要素だけを削除

という違いに注意が必要です。

## `extract()`

C++ の `extract()` は、
要素を木から取り除きながら
ノード自体の ownership を `node_handle` として取り出す機能です。

これにより node allocation を維持したまま、
別の container へノードを移動できます。

`RedBlackTreeMultiSet` ではノードを個別 allocation せず、
複数ノードを shared storage 上で管理します。

そのため、1つのノードを独立した ownership unit として外部へ取り出す
C++ の `node_handle` モデルとは相性がよくありません。

## Iterator と Index

| C++ `std::multiset` | Swift / `RedBlackTreeMultiSet` | 対応 | 備考 |
| --- | --- | :---: | --- |
| `iterator` | `Index` | △ | 役割は近いが同一概念ではない |
| `const_iterator` | `Index` | △ | set の要素を index 経由で直接変更しない |
| `++iterator` | `index(after:)` / iterator `next()` | ✅ | |
| `--iterator` | `index(before:)` | ✅ | |
| iterator dereference | subscript / iteration | ✅ | |
| `distance(first, last)` | `distance(from:to:)` | ✅ | |
| `std::next` | `index(_:offsetBy:)` | △ | Swift の index navigation API を使う |
| `std::prev` | backward index navigation | △ | |
| iterator pair `[first, last)` | `Range<Index>` / range | △ | 半開区間という考え方は近い |

同じ値を持つ要素が複数存在する場合でも、
それぞれの要素は異なる index を持ちます。

```text
[2, 2, 2]
 ↑  ↑  ↑
 i1 i2 i3
```

同値な要素であっても、
それぞれ独立した位置として扱えます。

## Index の安定性

`RedBlackTreeMultiSet` の index は、
別の要素を挿入したり削除したりしても、
それまで指していた要素が存在する限り有効です。

その index が指している要素自体を削除した場合にのみ、
その index は無効になります。

| 操作 | `std::multiset` iterator | `RedBlackTreeMultiSet` index |
| --- | --- | --- |
| 別の要素を挿入 | 有効なまま | ✅ 有効なまま |
| 別の要素を削除 | 有効なまま | ✅ 有効なまま |
| 指している要素を削除 | 無効 | 無効 |

この性質により、
mutation をまたいで特定の要素位置を保持できます。

重複要素についても、
それぞれの index は個別の要素位置を表します。

## 順序

| C++ `std::multiset` | Swift / `RedBlackTreeMultiSet` | 対応 | 備考 |
| --- | --- | :---: | --- |
| ソート済み走査 | 標準動作 | ✅ | 要素は常に昇順で走査される |
| `Compare` template parameter | `Element: Comparable` | △ | 順序の与え方が異なる |
| `std::less<T>` | `Comparable` の `<` | ✅ | |
| カスタム comparator | `Comparable` への適合 | △ | 任意の順序は定義できるが、container ごとの差し替え方式ではない |
| `key_comp()` | `Comparable` の `<` | △ | comparator object を保持・公開しない |
| `value_comp()` | `Comparable` の `<` | △ | multiset では key と value は同一要素 |

Swift ではカスタム型自身を `Comparable` に適合させることで、
任意の順序を定義できます。

```swift
struct Foo: Comparable {
  let name: String
  let priority: Int

  static func < (lhs: Foo, rhs: Foo) -> Bool {
    lhs.priority < rhs.priority
  }
}
```

このためカスタム順序そのものは利用できます。

ただし C++ のように、

```cpp
std::multiset<Foo, ByName>
std::multiset<Foo, ByPriority>
```

と、同じ要素型に対して container ごとに
comparator object を差し替える方式ではありません。

複数の順序が必要な場合には、
wrapper 型などによって異なる順序を型として表現できます。

## 同値性と重複

`RedBlackTreeMultiSet` における重複は、
要素の順序比較に基づいて決まります。

順序上同じ位置に属する要素は、
同値な要素として同じ範囲に連続して配置されます。

```text
lower-bound
    ↓
[A, A, A, A]
            ↑
       upper-bound
```

このため、同値な要素群を
1つの連続した範囲として扱えます。

`RedBlackTreeSet` ではこの範囲の要素数は高々1ですが、
`RedBlackTreeMultiSet` では任意個の同値要素を保持できます。

## 比較

| C++ | Swift / `RedBlackTreeMultiSet` | 対応 | 備考 |
| --- | --- | :---: | --- |
| 等価比較 | `==`, `!=` | ✅ | 要素列として比較できる |
| 辞書順比較 | `<`, `<=`, `>`, `>=` | ✅ | ソート済み要素列として辞書順比較できる |

重複要素も比較対象に含まれます。

たとえば、

```text
[1, 2, 2, 3]
```

と、

```text
[1, 2, 3]
```

は異なる multiset です。

## 集合演算

`RedBlackTreeMultiSet` は、
C++ の sorted range algorithms に対応する集合演算を提供します。

| C++ | `RedBlackTreeMultiSet` | 対応 | 備考 |
| --- | --- | :---: | --- |
| `std::set_union` | union 相当の操作 | ✅ | 重複数を考慮する |
| `std::set_intersection` | intersection 相当の操作 | ✅ | 重複数を考慮する |
| `std::set_difference` | difference 相当の操作 | ✅ | 重複数を考慮する |
| `std::set_symmetric_difference` | symmetric difference 相当の操作 | ✅ | 重複数を考慮する |

これらの演算では、
単に要素が存在するかどうかだけではなく、
各要素の重複数も意味を持ちます。

たとえば、

```text
A = [1, 1, 1, 2]
B = [1, 1, 3]
```

の場合、intersection の結果は、

```text
[1, 1]
```

となります。

union、difference、symmetric difference についても、
multiset としての重複数を考慮して処理されます。

### `SetAlgebra`

`RedBlackTreeMultiSet` は、
Swift 標準ライブラリの `SetAlgebra` には適合しません。

`SetAlgebra` は基本的に、
各要素が集合に「含まれるか、含まれないか」を中心とした集合 semantics を表します。

一方、`RedBlackTreeMultiSet` では、

```text
[1]
[1, 1]
[1, 1, 1]
```

はそれぞれ異なる状態です。

同じ値を何個保持しているかという multiplicity 自体が
コレクションの意味の一部であるため、
通常の集合を表す `SetAlgebra` とは semantics が異なります。

そのため、C++ の multiset 向け集合演算は提供しますが、
Swift の `SetAlgebra` protocol には適合しません。

## Sequence

`RedBlackTreeMultiSet` は Swift の `Sequence` として走査できます。

```swift
for element in set {
  print(element)
}
```

要素は昇順に現れ、
重複する要素もそれぞれ独立して走査されます。

```text
1
2
2
2
3
```

`makeIterator()` が赤黒木上の順次走査を提供します。

## Lazy Sequence 操作

Swift 標準ライブラリの lazy sequence adapter もそのまま利用できます。

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
RedBlackTreeMultiSet.Iterator
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

重複要素も通常の sequence element として
そのまま lazy pipeline を通過します。

この機能のために
`RedBlackTreeMultiSet` 専用の lazy implementation を持つ必要はなく、
正しく効率的な `Sequence` と iterator を提供していれば、
Swift 標準ライブラリの lazy adapter を利用できます。

## メモリと所有権

| C++ `std::multiset` | Swift / `RedBlackTreeMultiSet` | 対応 | 備考 |
| --- | --- | :---: | --- |
| node-based tree | 赤黒木ノード | ✅ | |
| node ごとの allocation | shared node storage | △ | 複数ノードをまとめて storage 上に配置する |
| allocator template parameter | — | ❌ | C++ allocator customization の直接対応はない |
| `node_handle` | — | ❌ | shared storage 方式とは ownership model が異なる |
| move construction | Swift の ownership / value semantics | △ | C++ と object model が異なる |
| copy construction | copy-on-write | △ | tree storage 全体を即座に複製するとは限らない |
| `swap()` | Swift `swap` | ✅ | |
| RAII | Swift の自動 lifetime 管理 | △ | 目的は近いが ownership model は異なる |

`RedBlackTreeMultiSet` は、
典型的な STL の node-by-node allocation とは異なり、
複数のノードをまとめた storage 上に配置します。

同じ値を持つ要素も、
それぞれ独立したノードとして管理されます。

この方式により allocation overhead を抑えながら、
赤黒木として必要な node-based structure を維持します。

## `std::multiset` との主な違い

`RedBlackTreeMultiSet` と `std::multiset` は、
基本的なデータ構造と主要な用途はよく似ています。

主な違いは API、ownership model、
および Swift の protocol model にあります。

| 項目 | `std::multiset` | `RedBlackTreeMultiSet` |
| --- | --- | --- |
| 順序 | comparator object | `Comparable` |
| 重複要素 | ✅ | ✅ |
| `count` | ✅ | ✅ `count(of:)` |
| lower-bound | ✅ | ✅ |
| upper-bound | ✅ | ✅ |
| equal-range | ✅ | ✅ `equalRange(_:)` |
| iterator / index 安定性 | 強い | 強い |
| multiset 集合演算 | ✅ | ✅ |
| Swift `SetAlgebra` | — | ❌ |
| lazy sequence | C++ ranges 等を利用 | Swift `Sequence.lazy` |
| node allocation | 一般に node 単位 | shared storage |
| `node_handle` | ✅ | ❌ |
| `extract()` | ✅ | ❌ |
| hint insertion | ✅ | ❌ |
| in-place `emplace` | ✅ | △ |

## C++ に固有性の強い機能

次の機能は C++ の object model、allocator model、
iterator model と強く結びついており、
`RedBlackTreeMultiSet` では直接対応する API を提供しません。

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
`Sequence`、`equalRange(_:)`、`count(of:)`、
および multiset semantics に対応した集合演算を利用して、
Swift に適した形で同等の処理を表現できます。
