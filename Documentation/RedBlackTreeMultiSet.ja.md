<!-- このRedBlackTreeMultiSet.ja.mdを正本とします。RedBlackTreeMultiSet.mdは、この文書の英訳コピーです。 -->

# RedBlackTreeMultiSet

[English](RedBlackTreeMultiSet.md) | 日本語

要素を昇順に保持し、重複を許容する赤黒木ベースの集合です。

## Declaration

```swift
import RedBlackTreeCollections

struct RedBlackTreeMultiSet<Element: Comparable>
```

## Overview

`RedBlackTreeMultiSet` は、重複する要素を保持でき、それらを常に昇順に並べて管理する集合です。

```swift
let numbers: RedBlackTreeMultiSet = [5, 2, 4, 2, 1, 3, 3]

print(numbers)
// [1, 2, 2, 3, 3, 4, 5]
```

`RedBlackTreeSet` とは異なり、同じ値を複数格納できます。

`RedBlackTreeMultiSet` は、平衡二分探索木の一種である赤黒木を使用します。

このため、要素の検索・挿入・削除を対数時間で行いながら、
すべての要素を常にソート済みの順序で走査できます。

`RedBlackTreeMultiSet` は、特に次のような用途に適しています。

- 重複する値を保持しながら、常にソート済みの状態を維持したい場合
- 要素を動的に追加・削除しながら、その出現回数も保持したい場合
- 指定した値以上、または指定した値より大きい最初の要素を効率よく検索したい場合
- 同じ値を持つ要素の範囲を効率よく調べたい場合
- 要素を昇順または降順に走査したい場合
- 挿入や削除を繰り返しながら順序付きの多重集合を扱いたい場合

重複する要素を保持する必要がない場合は、`RedBlackTreeSet` を使用します。

## Duplicate Elements

`RedBlackTreeMultiSet` は、順序比較上同一とみなされる要素を複数保持できます。

```swift
let numbers: RedBlackTreeMultiSet = [3, 1, 2, 3, 2, 1]

print(numbers)
// [1, 1, 2, 2, 3, 3]
```

同じ値を複数回挿入すると、それぞれが独立した要素として保持されます。

重複する要素を保持する必要がない場合は、`RedBlackTreeSet` を使用します。

## Sorted Iteration

`RedBlackTreeMultiSet` を通常の順序で走査すると、
要素は常に昇順で現れます。

```swift
let numbers: RedBlackTreeMultiSet = [7, 2, 9, 2, 1, 5]

for number in numbers {
  print(number)
}
```

出力:

```text
1
2
2
5
7
9
```

要素をあらかじめ配列へ取り出してソートする必要はありません。
ソート順はコレクション自身の構造によって常に維持されます。

同じ値を持つ要素は、ソート順の中で連続して現れます。

この性質は、要素の追加や削除を繰り返しながら、
その都度ソート済みの順序で処理したい場合に特に有用です。

## Ordered Lookup

赤黒木は要素間の順序を利用して検索を行うため、
単純な値の検索だけでなく、順序に基づく検索も効率よく実行できます。

たとえば、次のような問い合わせを行えます。

- 指定した値が存在するか
- 指定した値以上の最初の要素はどれか
- 指定した値より大きい最初の要素はどれか
- 指定した値と等しい要素が存在する範囲はどこか
- 指定した位置の直前または直後の要素はどれか

特に、重複する要素を扱う場合には lower-bound と upper-bound を組み合わせることで、
同じ値を持つ要素の範囲を効率よく求められます。

これらの操作では、先頭から要素を線形に走査する必要はありません。

赤黒木の高さは要素数に対して対数的に抑えられるため、
値に基づく検索は最悪 O(log `count`) の計算量で実行されます。

## Indices

`RedBlackTreeMultiSet` の index は、ソートされた要素列の中の論理的な位置を表します。

同じ値を持つ要素が複数存在する場合でも、
それぞれの要素は異なる位置を持ちます。

index を使うことで、ある要素から次の要素、または前の要素へ移動できます。

赤黒木では要素が連続した配列上に配置されているとは限らないため、
index は整数オフセットではありません。

この点は `Array` とは異なります。

また、集合を変更する操作によって既存の index が無効になる場合があります。
無効になった index を後から再利用してはいけません。

特に、要素を削除した後は、その削除された要素を指していた index を
使用することはできません。

## Multiset Operations

`RedBlackTreeMultiSet` は、重複を許容する集合として、
値の検索、挿入、削除といった基本的な操作を提供します。

```swift
var numbers: RedBlackTreeMultiSet = [1, 3, 3, 5]

numbers.insert(3)
// [1, 3, 3, 3, 5]

numbers.insert(4)
// [1, 3, 3, 3, 4, 5]
```

要素を追加しても、コレクションのソート順は自動的に維持されます。

既に格納されている値を再度挿入した場合も、
新しい要素として追加されます。

## Performance

`RedBlackTreeMultiSet` は赤黒木を使用しており、
木の高さは要素数に対して対数的に制限されます。

代表的な操作の計算量は次のようになります。

| 操作 | 計算量 |
| --- | ---: |
| `isEmpty` | O(1) |
| `count` | O(1) |
| `startIndex` | O(1) |
| `endIndex` | O(1) |
| 値の検索 | O(log `count`) |
| lower-bound 検索 | O(log `count`) |
| upper-bound 検索 | O(log `count`) |
| 要素の挿入 | O(log `count`) |
| 要素の削除 | O(log `count`) |

これらは赤黒木そのものの構造に基づく計算量です。

実際の実行時間は、`Element` の比較コストやメモリアクセスの特性によっても変化します。

特に `Element` の比較が一定時間ではない場合、
検索・挿入・削除の実際のコストには比較処理のコストも加わります。

## Red-Black Tree

赤黒木は自己平衡二分探索木の一種です。

各要素は二分探索木の順序に従って配置され、
挿入や削除の際にはノードの色変更や回転操作によって木のバランスが維持されます。

この仕組みにより、特定の挿入順序によって木が極端に片寄ることを防ぎ、
検索・挿入・削除の最悪計算量 を O(log `count`) に保ちます。

また、挿入や削除に伴う再平衡化処理のコストは、償却 O(1) となります。

この点は、平衡処理を行わない単純な二分探索木とは異なります。

## Implementation Details

`RedBlackTreeMultiSet` は、各要素を赤黒木のノードとして管理します。

同じ値を持つ要素も、それぞれ独立したノードとして保持されます。

ノードは個別に独立したヒープ allocation を行うのではなく、
複数のノードをまとめた storage 上に配置されます。

この方式により、ノードごとに個別 allocation を行う実装と比較して、
allocation overhead を削減できます。

また、ノードの管理情報と格納される値は互いに近い位置に配置されます。

これにより、赤黒木として必要なノードベースの構造を維持しながら、
走査時のメモリアクセス効率を改善できるよう設計されています。

ただし、`Array` のようにすべての要素が1つの連続したバッファに
格納されているわけではありません。

そのため、`RedBlackTreeMultiSet` は連続配列とは異なる
性能特性を持ちます。

## Choosing a Collection

用途によって、適した集合型は異なります。

`Set` は、要素の順序や重複を必要とせず、
主に高速な membership test を行いたい場合に適しています。

`Array` は、連続したストレージと整数 index による高速な
random access が必要な場合に適しています。

`RedBlackTreeSet` は、重複を許さず、
要素の追加・削除を繰り返しながらソート順を維持したい場合に適しています。

`RedBlackTreeMultiSet` は、重複する要素を保持しながら、
ソート順を維持し、値の順序に基づく検索を行いたい場合に適しています。
