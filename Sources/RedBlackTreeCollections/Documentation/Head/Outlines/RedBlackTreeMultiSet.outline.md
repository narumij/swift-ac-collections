<!--
- Source of Truth: このアウトライン
- Output:
  - RedBlackTreeMultiSet.ja.md
  - RedBlackTreeMultiSet.md（英訳）
  - RedBlackTreeMultiSet.swift の documentation comment（英語）
- Priority: 初心者への配慮より、RedBlackTreeMultiSet について過不足なく伝えることを優先
- Code Examples: 指定された節では必須
-->

# RedBlackTreeMultiSet

## Declaration
- `import AcCollections`
- `struct RedBlackTreeMultiSet<Element: Comparable>`
- コードブロック必須

## Overview
- 要素を昇順に保持する多重集合
- 赤黒木ベース
- 重複要素を保持できる
- 同じ値を複数回挿入すると、それぞれ独立した要素として保持
- 挿入・削除を行ってもソート順を維持
- 同じ値を持つ要素はソート順上で連続する
- 昇順・降順の走査
- 順序を利用した検索
  - 存在検索
  - lower bound
  - upper bound
  - equal range
  - 前後の要素
- `RedBlackTreeSet` との違い
- 標準 `Set` との違い
- `Array` との違い
- 重複が不要な場合は `RedBlackTreeSet`
- 主な用途
- コード例必須

## Creating a Multiset
- 空のmultiset
- array literal
- sequence / collection / rangeからの初期化
- `init(minimumCapacity:)`
- `capacity`
- `reserveCapacity(_:)`
- コード例必須

## Searching and Accessing Elements
- `contains(_:)`
- `count(of:)`
- `first` / `last`
- `min()` / `max()`
- `firstIndex(of:)`
- `find(_:)`
- `lowerBound(_:)`
- `upperBound(_:)`
- `equalRange(_:)`
- `equalRange(_:)`が同値な全要素を表すこと
- 検索結果のindexから前後の要素へ移動
- コード例必須

## Insertion and Removal
- 挿入
- 重複挿入時の挙動
- hint付き挿入
- `update(_:at:)`
  - 指定indexの要素を更新する
  - 木の順序を維持するため、既存要素と新しい要素が同値である場合だけ置換する
  - 更新時は置換前の要素を返す
  - indexが無効、または要素が同値でない場合は置換せず`nil`を返す
- 単一要素削除
- `popFirst()` / `popLast()`
- `removeFirst()` / `removeLast()`
- 同じ値を持つ複数要素の削除
- `eraseUnique(_:)` / `eraseMulti(_:)`
- `erase(where:)`
- 範囲削除
- `removeAll(keepingCapacity:)`
- index を使った削除時の注意
- `erase(Index) -> Index` による逐次削除
- コード例必須

## Combining Multisets
- `insert(contentsOf:)` / `inserting(contentsOf:)`
- `RedBlackTreeSet`、`RedBlackTreeMultiSet`、任意のsequenceを入力できること
- `meld(_:)` / `melding(_:)`
- 自身を更新する操作と、新しいmultisetを返す操作の違い
- 性能上の使い分けはCombining APIの調査結果と照合して確定
- コード例必須

## Multiset Algebra
- `union(_:)` / `formUnion(_:)`: 多重度の加算 `a + b`
- `intersection(_:)` / `formIntersection(_:)`: 多重度の最小値 `min(a, b)`
- `difference(_:)` / `formDifference(_:)`: 0を下限とする減算 `max(a - b, 0)`
- `symmetricDifference(_:)` / `formSymmetricDifference(_:)`: 多重度の絶対差 `abs(a - b)`
- 標準`SetAlgebra`の一意集合としての意味論とは異なり、同プロトコルには適合しないこと
- 非破壊操作と自身を更新する操作の違い
- コード例必須

## Iterating over Elements
- 昇順走査
- `sorted()`による昇順配列化
- `reversed()`による降順配列化
- `filter(_:)`が`RedBlackTreeMultiSet`を返すこと
- range viewでの走査
- コード例必須

## Indices and Bound Expressions
- index は整数オフセットではなく、要素の論理的位置を表す
- 同じ値を持つ要素でも、それぞれ異なる index を持つ
- 前後の要素へ移動可能
- 他要素の挿入・削除では、指している要素が存在する限り有効
- 指している要素を削除すると無効
- slot 再利用後も古い index は再利用不可
- CoW 分岐後の index の扱い
- 無関係なコレクション由来の index は事前条件違反
- index range subscriptとrange view
- `containsSubrange(_:)`
- index間およびBound間の`distance(from:to:)`
- `RedBlackTreeMultiSet.Bound`
  - index を直接扱わない代替記法
  - `.start`
  - `.last`
  - `.end`
  - `.lowerBound`
  - `.upperBound`
  - `.find`
  - `.lessThan` / `.lessThanOrEqual`
  - `.greaterThan` / `.greaterThanOrEqual`
  - `.before` / `.after`
  - `.advanced(by:limit:)`
- lower bound と upper bound による同値要素範囲の特定
- 単一Boundが終端または解決不能の場合はsubscriptが`nil`を返す
- 不成立または逆順のBound範囲は空Viewになる
- コード例必須

## Performance
- 計算量表必須
- `isEmpty`: O(1)
- `count`: O(1)
- `startIndex`: O(1)
- `endIndex`: O(1)
- 値の検索: O(log `count`)
- lower bound: O(log `count`)
- upper bound: O(log `count`)
- 挿入: O(log `count`)
- 値を検索して1要素を削除: O(log `count`)
- 値を検索して一致する K 要素を削除: O(log `count` + K)
- 既知の index から削除: 償却 O(1)
- 再平衡化: 償却 O(1)
- `union` / `intersection` / `difference` / `symmetricDifference`: O(n + m)
- `insert(contentsOf:)` / `inserting(contentsOf:)` / `meld` / `melding`はCombining APIの調査結果と照合して確定
- 要素比較コストの影響

## Red-Black Tree
- 赤黒木
- 自己平衡によって木の高さを対数的に維持
- 色変更と回転によって平衡を維持
- 同じ値を持つ要素も、それぞれ独立した要素として木に保持
- 要素の論理的な順序とメモリ上の物理配置は異なる

## Important
- thread-safe ではない
