<!-- 日本語版が正とします。英語版はこの文書の英訳コピーです。 -->
<!-- 解説を読むために少しだけC++してる人が対象読者だったりする -->
<!-- 正確な互換資料を書いた結果として発生する洗礼程度のニュアンス -->

# `std::map` との対応状況

`RedBlackTreeDictionary` は、C++ の `std::map` で一般的に利用される多くの機能に対応しています。

以下の表では、典型的な `std::map` の機能が
`RedBlackTreeDictionary` ではどのように対応するかをまとめます。

## 凡例

| 記号 | 意味 |
| --- | --- |
| ✅ | 直接対応する機能、または実質的に同等の操作がある |
| △ | 同様のことはできるが、API や表現方法、意味論が異なる |
| ❌ | 直接対応する機能がない |
| — | Swift では該当しない |

## 概要

| C++ `std::map` | Swift / `RedBlackTreeDictionary` | 対応 | 備考 |
| --- | --- | :---: | --- |
| ソート済みの一意なキー | `RedBlackTreeDictionary` | ✅ | キー順に保持される |
| `std::map<Key, Value>` | `RedBlackTreeDictionary<Key, Value>` | ✅ | `Key` は `Comparable` に準拠する |
| `size()` | `count` | ✅ | O(1) |
| `empty()` | `isEmpty` | ✅ | O(1) |
| `begin()` | `startIndex` / iteration | ✅ | 最初の key-value 要素を表す |
| `end()` | `endIndex` | ✅ | 最後の要素の直後を表す |
| 順方向走査 | `for-in`, `Sequence` | ✅ | key の昇順で現れる |
| 双方向走査 | index navigation | ✅ | C++ iterator とは API が異なる |
| 逆方向走査 | `reversed()` など | △ | `rbegin()` / `rend()` とは API が異なる |

## Swift `Dictionary` との違い

Swift 標準ライブラリの `Dictionary` と `RedBlackTreeDictionary` は、
どちらも一意なキーから値を引く辞書です。

大きな違いは、
`RedBlackTreeDictionary` がキーの順序を常に維持することです。

| 特性 | Swift `Dictionary` | `RedBlackTreeDictionary` |
| --- | --- | --- |
| Key の制約 | `Hashable` | `Comparable` |
| キーの一意性 | ✅ | ✅ |
| キーのソート順 | 保証しない | 常に昇順 |
| キー検索 | 平均 O(1) | O(log `count`) |
| 挿入 | 平均 O(1) | O(log `count`) |
| 削除 | 平均 O(1) | O(log `count`) |
| lower-bound | ❌ | ✅ |
| upper-bound | ❌ | ✅ |
| 順序付き範囲検索 | ❌ | ✅ |
| 昇順走査 | 別途ソートが必要 | そのまま走査可能 |
| mutation をまたぐ index の保持 | 前提にできない | 他要素の変更では維持される |

単純な key-value lookup が中心で、
キーの順序を必要としない場合には
Swift 標準ライブラリの `Dictionary` が適しています。

一方、

- キーを追加・削除しながらソート順を維持したい
- 指定したキー以上の最小キーを探したい
- 指定したキーより大きい最小キーを探したい
- 前後のキーを調べたい
- キー範囲を効率的に扱いたい
- mutation をまたいで特定の要素位置を保持したい

といった場合には、
`RedBlackTreeDictionary` の順序付き構造を利用できます。

## 検索

| C++ `std::map` | Swift / `RedBlackTreeDictionary` | 対応 | 備考 |
| --- | --- | :---: | --- |
| `find(key)` | キーによる検索 | ✅ | O(log `count`) |
| `contains(key)` | キーの存在確認 | ✅ | O(log `count`) |
| `count(key)` | membership test | △ | map なので一致するキーは高々1つ |
| `lower_bound(key)` | lower-bound 検索 | ✅ | O(log `count`) |
| `upper_bound(key)` | upper-bound 検索 | ✅ | O(log `count`) |
| `equal_range(key)` | lower-bound / upper-bound | △ | map では範囲は高々1要素 |
| 順序付き範囲検索 | tree index による範囲 | ✅ | 先頭から線形走査する必要がない |

### Swift `Dictionary` との違い

Swift `Dictionary` でも、
キーが存在するかどうかや、
キーに対応する値を効率的に検索できます。

一方、

```text
key 以上で最小のキー
key より大きい最小のキー
key の直前にあるキー
```

のような順序に基づく検索は、
辞書自体がキーのソート順を持たないため直接は行えません。

`RedBlackTreeDictionary` では、
lower-bound / upper-bound によって
このような検索を O(log `count`) で行えます。

C++ の解説で、

```cpp
auto it = map.lower_bound(key);
```

のようなコードが現れた場合には、
単なる key-value lookup ではなく、
`std::map` の順序付き辞書としての性質が使われています。

### `equal_range`

`std::map::equal_range(key)` が返す範囲は、
キーが一意なので高々1要素です。

`RedBlackTreeDictionary` でも、
lower-bound と upper-bound によって同様の範囲を表現できます。

同一キーを持つ複数要素を範囲として扱う用途では、
`RedBlackTreeMultiMap` の `equalRange(_:)` が対応します。

## Key Subscript

key subscript は、
`std::map` と Swift の辞書 API で semantics が異なる部分です。

| 操作 | `std::map` | Swift `Dictionary` | `RedBlackTreeDictionary` |
| --- | --- | --- | --- |
| 存在する key の読み取り | mapped value | `Value?` | `Value?` |
| 存在しない key の読み取り | default value を挿入 | `nil` | `nil` |
| `dictionary[key] = value` | 更新 / 挿入 | 更新 / 挿入 | 更新 / 挿入 |
| 読み取りだけで mutation | あり得る | なし | なし |

C++ の、

```cpp
map[key]
```

は、キーが存在しない場合に
mapped value を default construction して挿入します。

一方、`RedBlackTreeDictionary` の、

```swift
dictionary[key]
```

は `Value?` を返し、
存在しないキーを読み取っただけでは辞書を変更しません。

この部分では、
`RedBlackTreeDictionary` は Swift 標準 `Dictionary` に近い semantics を持ちます。

## Default Value Subscript

Swift の辞書 API では、

```swift
dictionary[key, default: defaultValue]
```

という形式によって、
不存在時の default value を扱えます。

```swift
counts[key, default: 0] += 1
```

これは C++ の、

```cpp
counts[key]++;
```

に近い用途です。

`RedBlackTreeDictionary` が同様の default subscript を提供する場合には、
同じ Swift の記法で表現できます。

## 挿入と更新

| C++ `std::map` | Swift / `RedBlackTreeDictionary` | 対応 | 備考 |
| --- | --- | :---: | --- |
| `insert(value)` | insert 相当 | ✅ | 新規キーを挿入する |
| `insert_or_assign` | subscript / value 更新 API | △ | API が異なる |
| `try_emplace` | 必要時のみ Value を生成する操作 | △ | Swift では表現方法が異なる |
| `emplace(...)` | 値を構築して挿入 | △ | C++ の construction semantics とは異なる |
| `emplace_hint(...)` | — | ❌ | |
| `insert(hint, value)` | — | ❌ | |
| range insertion | `Sequence` ベース | △ | iterator pair とは API が異なる |

### `insert` と値の更新

`std::map::insert` は、
既に同じキーが存在する場合には
その mapped value を置き換えません。

一方、

```cpp
map.insert_or_assign(key, value);
```

は、キーが存在すれば値を更新し、
存在しなければ新しい要素を挿入します。

Swift では、

```swift
dictionary[key] = value
```

のような API が
後者に近い役割を持ちます。

C++ の解説を読み替える際には、

```text
新規挿入だけなのか
既存値も更新するのか
```

を区別する必要があります。

### `try_emplace`

C++ の `try_emplace` は、
キーが存在しない場合にだけ mapped value を構築します。

このため重要なのは `emplace` という名前よりも、

```text
key が存在する   → Value を作らない
key が存在しない → Value を作って挿入する
```

という semantics です。

Swift では closure や `@autoclosure` など、
異なる API 形式で同じ目的を表現できます。

### Hint 付き挿入

C++ の `std::map` には、
挿入位置の近くを iterator で指定する
hint 付き insertion API があります。

正しい hint が与えられた場合には、
root からの検索を省略して高速化できる場合があります。

`RedBlackTreeDictionary` では、
C++ と同じ形式の hint 付き insertion API は提供しません。

## 削除

| C++ `std::map` | Swift / `RedBlackTreeDictionary` | 対応 | 備考 |
| --- | --- | :---: | --- |
| `erase(key)` | キーによる削除 | ✅ | O(log `count`) |
| `erase(iterator)` | index による削除 | ✅ | 既知の位置にある要素を削除 |
| `erase(first, last)` | 範囲削除 | △ | iterator pair とは API が異なる |
| `clear()` | 全要素削除 | ✅ | |
| `node_handle` | node handle 相当 | ✅ | |
| `extract()` | — | ❌ | 直接対応する公開 API はない |

Swift の辞書 API では、

```swift
dictionary.removeValue(forKey: key)
```

や、

```swift
dictionary[key] = nil
```

のような削除方法もあります。

これらは `std::map::erase(key)` と目的は近いものの、
戻り値や API semantics が異なります。

## `node_handle` / `extract()`

C++ の `std::map` は、
`node_handle` と `extract()` を利用して、
要素をコンテナから切り離して扱うことができます。

```cpp
auto node = map.extract(key);
```

`RedBlackTreeDictionary` にも
node を表現する handle に相当する仕組みがあります。

一方、C++ の `std::map::extract()` と直接対応する
公開 API は提供していません。

ここでの対応は公開 API とその semantics に基づくものであり、
内部の node storage や allocation strategy から
対応可否を推測するものではありません。

## Iterator と Index

| C++ `std::map` | Swift / `RedBlackTreeDictionary` | 対応 | 備考 |
| --- | --- | :---: | --- |
| `iterator` | `Index` | △ | 役割は近いが同一概念ではない |
| `const_iterator` | `Index` | △ | Swift の index model を使用する |
| `++iterator` | `index(after:)` / iterator `next()` | ✅ | |
| `--iterator` | `index(before:)` | ✅ | |
| iterator dereference | subscript / iteration | ✅ | key-value 要素を取得 |
| `distance(first, last)` | `distance(from:to:)` | ✅ | |
| `std::next` | `index(_:offsetBy:)` | △ | Swift の index navigation API を使う |
| `std::prev` | backward index navigation | △ | |
| iterator pair `[first, last)` | `Range<Index>` / range view | △ | 半開区間という考え方は近い |

Swift の `Index` と C++ iterator は
同一の abstraction ではありません。

一方、

- 辞書内の位置を表す
- その位置の要素へアクセスする
- 前後へ移動する
- 範囲の境界として利用する

といった役割には共通点があります。

## Index の安定性

`RedBlackTreeDictionary` の index は、
`std::map` iterator と同様に高い安定性を持ちます。

別の要素を挿入したり削除したりしても、
その index が指している要素が存在する限り、
index は有効なままです。

| 操作 | `std::map` iterator | Swift `Dictionary` index | `RedBlackTreeDictionary` index |
| --- | --- | --- | --- |
| 別の要素を挿入 | 有効なまま | 保証されない | 有効なまま |
| 別の要素を削除 | 有効なまま | 保証されない | 有効なまま |
| 指している要素を削除 | 無効 | 無効になり得る | 無効 |

C++ の `std::map` iterator を保持しながら
辞書を更新するアルゴリズムを Swift へ読み替える場合にも、
この性質を利用できます。

## Key と Value

赤黒木上での位置は `Key` によって決まります。

```text
Key   → tree 上の位置を決定する
Value → tree 上の位置には影響しない
```

そのため、
格納中のキーを任意に変更することはできませんが、
キーを維持したまま `Value` を更新できます。

この性質は `std::map` と同様です。

## `keys` / `values`

`RedBlackTreeDictionary` の `keys` は、
キーの昇順に走査されます。

```swift
for key in dictionary.keys {
  // ascending order
}
```

`values` は、
キー順に並んだ要素に対応する値を同じ順番で走査します。

```text
1 → "C"
2 → "A"
3 → "B"

values
↓
"C", "A", "B"
```

`Value` 自身がソートされているわけではありません。

| 特性 | Swift `Dictionary` | `RedBlackTreeDictionary` |
| --- | --- | --- |
| `keys` | ✅ | ✅ |
| `values` | ✅ | ✅ |
| `keys` の昇順保証 | ❌ | ✅ |
| `values` の順序 | dictionary の走査順 | key の昇順に対応 |

## Sequence

`RedBlackTreeDictionary` は
Swift の `Sequence` として走査できます。

```swift
for element in dictionary {
  // ...
}
```

各要素は key-value pair で、
キーの昇順に現れます。

```text
(key: 1, value: "A")
(key: 2, value: "B")
(key: 3, value: "C")
```

Swift 標準 `Dictionary` も `Sequence` として走査できますが、
キーのソート順は保証されません。

`RedBlackTreeDictionary` では通常の `for-in` が、
そのまま `std::map` と同じキー順走査になります。

## Lazy Sequence

`Sequence` に適合しているため、
Swift 標準ライブラリの lazy sequence adapter を利用できます。

```swift
let result = dictionary.lazy
  .filter { predicate($0) }
  .map { transform($0) }
  .prefix(10)
```

この場合、
各段階で中間コレクションを生成する必要はなく、
iterator を通して必要なところまで遅延評価できます。

```text
RedBlackTreeDictionary.Iterator
              ↓ next()
            filter
              ↓
             map
              ↓
           consumer
```

専用の lazy implementation を持たなくても、
`Sequence` と iterator を通して
Swift 標準の lazy adapter を利用できます。

## 順序

| C++ `std::map` | Swift / `RedBlackTreeDictionary` | 対応 | 備考 |
| --- | --- | :---: | --- |
| `Compare` template parameter | `Key: Comparable` | △ | 順序の与え方が異なる |
| `std::less<Key>` | `Comparable` の `<` | ✅ | |
| カスタム comparator | `Comparable` への適合 | △ | container ごとの差し替え方式ではない |
| `key_comp()` | `Comparable` の `<` | △ | comparator object を保持・公開しない |
| `value_comp()` | Key による key-value 順序 | △ | `Value` は順序に参加しない |

Swift では、
カスタム `Key` 型自身を `Comparable` に適合させることで
独自の順序を定義できます。

```swift
struct Key: Comparable {
  let id: Int

  static func < (lhs: Key, rhs: Key) -> Bool {
    lhs.id < rhs.id
  }
}
```

ただし C++ のように、

```cpp
std::map<Key, Value, CompareA>
std::map<Key, Value, CompareB>
```

と、同じ `Key` 型に対して
container ごとに comparator を差し替えるモデルではありません。

## 比較

| C++ | Swift / `RedBlackTreeDictionary` | 対応 | 備考 |
| --- | --- | :---: | --- |
| 等価比較 | `==`, `!=` | ✅ | key-value 要素列として比較できる |
| 辞書順比較 | `<`, `<=`, `>`, `>=` | ✅ | key 順の要素列として辞書順比較できる |

`RedBlackTreeDictionary` は、
キー順に並んだ key-value 要素列として
辞書全体を比較できます。

## メモリと所有権

`std::map` と `RedBlackTreeDictionary` は、
どちらもコンテナを値としてコピーし、
コピー後に独立して変更できます。

| C++ `std::map` | Swift / `RedBlackTreeDictionary` | 対応 | 備考 |
| --- | --- | :---: | --- |
| 値としてコピー可能 | value semantics | ✅ | コピー後は独立した値として振る舞う |
| copy construction | copy-on-write | △ | コピーを実現する仕組みが異なる |
| move construction | Swift の ownership semantics | △ | object model が異なる |
| allocator customization | — | ❌ | C++ allocator API の直接対応はない |
| `node_handle` | node handle 相当 | ✅ | |
| `swap()` | Swift `swap` | ✅ | |
| RAII | Swift の自動 lifetime 管理 | △ | lifetime / ownership model が異なる |

`RedBlackTreeDictionary` は value semantics を持ち、
コピー後はそれぞれ独立した辞書として振る舞います。

```swift
var a = dictionary
var b = a

b[key] = value
```

`b` を変更しても、
`a` の値は変化しません。

`RedBlackTreeDictionary` では、
この value semantics を効率的に実現するために
copy-on-write を利用します。

### Implementation Details

`RedBlackTreeDictionary` は、
key-value 要素を赤黒木として管理します。

木の平衡性を維持することで、
検索・挿入・削除の最悪計算量を O(log `count`) に保ちます。

ノードは1要素ごとに独立した allocation を行うのではなく、
複数のノードをまとめた storage 上に配置します。

これにより、
赤黒木としての node-based structure を維持しながら、
allocation overhead を抑えるよう設計されています。

また、node の管理情報と key-value data は
互いに近い位置に配置されます。

これらは `RedBlackTreeDictionary` 自身の implementation details です。

Swift 標準ライブラリの `Dictionary` の
storage、layout、allocation strategy などの内部実装については、
ここでは比較しません。

## `std::map` との主な対応

代表的な操作は次のように対応します。

| C++ | `RedBlackTreeDictionary` |
| --- | --- |
| `std::map<Key, Value>` | `RedBlackTreeDictionary<Key, Value>` |
| `map.size()` | `dictionary.count` |
| `map.empty()` | `dictionary.isEmpty` |
| `map.find(key)` | キーによる検索 |
| `map.contains(key)` | キーの存在確認 |
| `map.lower_bound(key)` | lower-bound 検索 |
| `map.upper_bound(key)` | upper-bound 検索 |
| `map[key]` | key subscript ※不存在時の semantics は異なる |
| `map.insert(...)` | insert 相当 |
| `map.erase(key)` | キーによる削除 |
| `map.erase(it)` | index による削除 |
| `map.begin()` | `startIndex` |
| `map.end()` | `endIndex` |
| `++it` | `index(after:)` |
| `--it` | `index(before:)` |
| range-based `for` | `for-in` |

API の名前や型には違いがありますが、

```text
ソート済み辞書
検索
挿入・更新
削除
lower-bound / upper-bound
前後への移動
キー順走査
```

といった、
`std::map` を利用する典型的なアルゴリズムは
対応付けて考えることができます。

## C++ に固有性の強い機能

次の機能は、
C++ の object model、allocator model、
iterator model などと強く結びついており、
`RedBlackTreeDictionary` では同一の API 形式を採用していません。

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
