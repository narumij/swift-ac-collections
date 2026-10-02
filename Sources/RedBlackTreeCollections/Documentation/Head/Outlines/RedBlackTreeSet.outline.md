<!--
- Source of Truth: このアウトライン
- Output:
  - RedBlackTreeSet.ja.md
  - RedBlackTreeSet.md（英訳）
  - RedBlackTreeSet.swift の documentation comment（英語）
- Priority: 初心者への配慮より、RedBlackTreeSet について過不足なく伝えることを優先
- Code Examples: 指定された節では必須
-->

# RedBlackTreeSet

## Declaration
- `import AcCollections`
- `struct RedBlackTreeSet<Element: Comparable>`
- コードブロック必須

## Overview
- 要素を昇順に保持する一意集合
- 赤黒木ベース
- 重複要素を保持しない
- 挿入・削除を行ってもソート順を維持
- 昇順・降順の走査
- 順序を利用した検索
  - 存在検索
  - lower bound
  - upper bound
  - 前後の要素
- 標準 `Set` との違い
- `Array` との違い
- 重複が必要な場合は `RedBlackTreeMultiSet`
- 主な用途
- コード例必須

## Set Operations
- 挿入
- 重複挿入時の挙動
- 単一要素削除
- 範囲削除
- index を使った削除時の注意
- `erase(Index) -> Index` による逐次削除
- コード例必須

## Indices and Bound Expressions
- index は整数オフセットではなく、要素の論理的位置を表す
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
- 値の検索: O(log `count`)
- lower bound: O(log `count`)
- upper bound: O(log `count`)
- 挿入: O(log `count`)
- 値を検索して削除: O(log `count`)
- 既知の index から削除: 償却 O(1)
- 再平衡化: 償却 O(1)
- 要素比較コストの影響

## Red-Black Tree
- 赤黒木
- 自己平衡によって木の高さを対数的に維持
- 色変更と回転によって平衡を維持
- 要素の論理的な順序とメモリ上の物理配置は異なる

## Important
- thread-safe ではない
