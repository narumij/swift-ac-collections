# 現行View APIマトリクス

この文書は、通常構成の `RedBlackTreeCollections` が提供する現行View APIを、Viewの種類ごとに横断的に確認するための開発者向け一覧である。

- ✅: 利用できる
- —: 利用できない
- △: 同じ目的の型固有APIを利用する
- TODO: 採用済みで未実装
- 検討: 採用するか未決定

`COMPATIBLE_ATCODER_2025`、Deprecated API、旧Slice APIは対象外とする。

同じ意味を持つジェネリック版や類似APIは、原則として1行へまとめる。

## Viewの種類

| View | 対象 | Element | おおよその機能 |
| --- | --- | --- | --- |
| `RedBlackTreeKeyOnlyRangeView` | Set / MultiSet | Key | Keyの範囲をMutable Viewとして扱う |
| `RedBlackTreeKeyValueRangeView` | MultiMap / Dictionary | `(Key, Value)` | Key-Valueの範囲をMutable Viewとして扱う |
| `RedBlackTreeMappedValuesView` | MultiMap / Dictionary / KeyValue Range View | Value | mapped valueをMutable Viewとして扱う。MultiMapの `subscript(key:)`、Map系とKeyValue Range Viewの `values` が返す |

## 基本状態と参照

| API名 | KeyOnly | KeyValue | MappedValues | おおよその機能 |
| --- | :---: | :---: | :---: | --- |
| `startIndex` / `endIndex` | ✅ | ✅ | ✅ | View固有の半開範囲境界を返す |
| `isEmpty` / `count` | ✅ | ✅ | ✅ | Viewの空判定または要素数を返す |
| `first` / `last` | ✅ | ✅ | ✅ | View端の要素を返す |
| `subscript(position:)` | — | — | ✅ | Index位置の要素を参照する |
| `subscript(position:)` setter | — | — | ✅ | Index位置のmapped valueを更新する |
| `keys` | — | ✅ | — | KeyValue Viewのキーを遅延走査する |
| `values` | — | ✅ | — | mapped valueを扱うMappedValues Viewを返す |

## Index

| API名 | KeyOnly | KeyValue | MappedValues | おおよその機能 |
| --- | :---: | :---: | :---: | --- |
| `isElement(at:)` | ✅ | ✅ | ✅ | IndexがView内の要素を指すか判定する |
| `isEnd(_:)` | ✅ | ✅ | ✅ | IndexがView固有の有効な終端か判定する |

`isElement(at:)` はViewの範囲判定を含むため最悪 O(log N)、`isEnd(_:)` は O(1)。

基底コンテナで有効なIndexであることと、View内の要素を指すことは区別する。

## 更新

| API名 | KeyOnly | KeyValue | MappedValues | おおよその機能 |
| --- | :---: | :---: | :---: | --- |
| `swapAt(_:_:)` | — | — | ✅ | 2つのIndex位置のmapped valueを交換する |

MappedValues Viewの `subscript(position:)` と `swapAt(_:_:)` は O(1)。標準
CollectionのIndex操作と同様、渡すIndexがView内の要素を指すことは呼び出し側の
事前条件とし、操作ごとの範囲所属検査は行わない。無効化済み、世代不一致など、
対象のtreeで要素へ安全に解決できないIndexは下層のIndex検証で拒否する。
範囲所属を事前に確認する必要がある場合は `isElement(at:)` を明示的に使用する。

## 削除

| API名 | KeyOnly | KeyValue | MappedValues | おおよその機能 |
| --- | :---: | :---: | :---: | --- |
| `popFirst()` / `popLast()` | ✅ | ✅ | ✅ | View端の要素をOptionalで削除する |
| `removeFirst()` / `removeLast()` | ✅ | ✅ | ✅ | View端の要素を削除する。空の場合は失敗する |
| `erase()` | ✅ | ✅ | ✅ | View全体を削除し、後続Indexを返す |
| `erase(where:)` | ✅ | ✅ | ✅ | View内で条件を満たす要素を削除する |

MappedValues Viewの削除APIは、mapped valueを条件や返却値として扱いながら、対応するnodeをtreeから削除する。

## 走査、変換、比較

| API名 | KeyOnly | KeyValue | MappedValues | おおよその機能 |
| --- | :---: | :---: | :---: | --- |
| `makeIterator()` | ✅ | ✅ | ✅ | View内を昇順に走査するIteratorを生成する |
| `sorted()` | ✅ | ✅ | — | Viewの要素を昇順配列として返す |
| `reversed()` | ✅ | ✅ | — | Viewの要素を逆順配列として返す |
| `elementsEqual(_:)` | ✅ | ✅ | — | 別Sequenceと同じ順序の要素列か比較する |
| `lexicographicallyPrecedes(_:)` | ✅ | ✅ | — | 別Sequenceと辞書式順序を比較する |
| `==` | ✅ | ✅ | — | View同士の内容が等しいか比較する |
| `<` | ✅ | ✅ | — | View同士を辞書式比較する |

## 標準プロトコル適合

| 標準プロトコル | KeyOnly | KeyValue | MappedValues | 適合条件・備考 |
| --- | :---: | :---: | :---: | --- |
| `Sequence` | ✅ | ✅ | ✅ | View内を昇順に走査する |
| `Collection` | — | — | — | 独自Index APIを用いる |
| `BidirectionalCollection` | — | — | — | 同上 |
| `Equatable` | ✅ | ✅ | — | Elementが `Equatable` の場合 |
| `Comparable` | ✅ | ✅ | — | Elementが `Comparable` の場合 |
| `Sendable` | ✅ | ✅ | ✅ | Elementが `Sendable` の場合の `@unchecked Sendable` 適合 |

## 更新ルール

公開View APIを追加、削除、改名した場合は、同じ変更でこの表も更新する。

特に次の変更は意味論の差が見えにくいため、行を統合せず明示する。

- KeyOnly Range ViewとKeyValue Range Viewで異なるAPI
- KeyValue Range ViewとMappedValues Viewで異なるAPI
- 基底コンテナとViewでIndexの有効範囲が異なるAPI
- mapped valueだけを変更するAPIとnodeそのものを削除するAPI
