<!--
- Source of Truth: このアウトライン
- Output:
  - RedBlackTreeMultiMap.ja.md
  - RedBlackTreeMultiMap.md（英訳）
  - RedBlackTreeMultiMap.swift の documentation comment（英語）
- Priority: 初心者への配慮より、RedBlackTreeMultiMap について過不足なく伝えることを優先
- Code Examples: 指定された節では必須
-->

# RedBlackTreeMultiMap

## Declaration
- `import AcCollections`
- `struct RedBlackTreeMultiMap<Key: Comparable, Value>`
- コードブロック必須

## Overview
- キーを昇順に保持する multimap
- 赤黒木ベース
- 同じキーに複数の値を関連付けられる
- 同じキーを持つ要素も、それぞれ独立した要素として保持
- 同一キー内の要素順は挿入順
- 挿入・削除を行ってもキーのソート順を維持
- キー順で昇順・降順に走査
- 順序を利用した検索
  - キー検索
  - lower bound
  - upper bound
  - 同一キーの範囲
  - キー範囲
  - 前後の要素
- `RedBlackTreeDictionary` との違い
- 標準 `Dictionary` との違い
- `Dictionary<Key, [Value]>` との違い
- 主な用途
- コード例必須

## Key Access and Views
- キー subscript は単一値ではなく `RedBlackTreeKeyValueRangeView` を返す
- 同じキーを持つ要素の論理的な範囲を表す
- 要素を別配列へコピーしない
- 元の multimap と同じ index 型を使用
- `keys`
  - キーの遅延走査
- `values`
  - mapped value の走査
  - `RedBlackTreeMappedValuesView`
  - mapped value の変更
  - `swapAt(_:_:)`
- キーは木の順序を決定するため変更しない
- `Value` は `Comparable` を必要としない
- subscript に直接変更操作を行う場合は元の multimap を変更
- range view を独立した変数へ取り出した場合の値 semantics
- コード例必須

## Multimap Operations
- 挿入
- 同一キー挿入時の挙動
- 単一要素削除
- 同じキーを持つ複数要素の削除
- range view を使った削除
- 範囲削除
- index を使った削除時の注意
- `erase(Index) -> Index` による逐次削除
- コード例必須

## Indices and Bound Expressions
- index は整数オフセットではなく、キー順に並んだ要素の論理的位置を表す
- 同じキーを持つ要素でも、それぞれ異なる index を持つ
- range view と元の multimap で同じ index 型を使用
- 前後の要素へ移動可能
- 他要素の挿入・削除では、指している要素が存在する限り有効
- 指している要素を削除すると無効
- slot 再利用後も古い index は再利用不可
- CoW 分岐後の index の扱い
- 無関係なコレクション由来の index は事前条件違反
- `BoundExpression`
  - index を直接扱わない代替記法
  - `.start`
  - `.lowerBound`
  - `.upperBound`
  - `.find`
- コード例必須

## Performance
- 計算量表必須
- `isEmpty`: O(1)
- `count`: O(1)
- `startIndex`: O(1)
- `endIndex`: O(1)
- キーによる検索: O(log `count`)
- lower bound: O(log `count`)
- upper bound: O(log `count`)
- 挿入: O(log `count`)
- キーを検索して1要素を削除: O(log `count`)
- キーを検索して一致する K 要素を削除: O(log `count` + K)
- 既知の index から削除: 償却 O(1)
- 同一キーの m 要素を検索して処理: O(log `count` + m)
- range view は対象要素をコピーしない
- 再平衡化: 償却 O(1)
- `Key` の比較コストの影響

## Red-Black Tree
- 赤黒木
- キーによって木の順序を決定
- 自己平衡によって木の高さを対数的に維持
- 色変更と回転によって平衡を維持
- 同じキーを持つ要素は論理順序上で連続する
- 要素の論理的な順序とメモリ上の物理配置は異なる

## Important
- thread-safe ではない
