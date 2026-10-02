<!--
- Source of Truth: このアウトライン
- Output:
  - RedBlackTreeDictionary.ja.md
  - RedBlackTreeDictionary.md（英訳）
  - RedBlackTreeDictionary.swift の documentation comment（英語）
- Priority: 初心者への配慮より、RedBlackTreeDictionary について過不足なく伝えることを優先
- Code Examples: 指定された節では必須
-->

# RedBlackTreeDictionary

## Declaration
- `import AcCollections`
- `struct RedBlackTreeDictionary<Key: Comparable, Value>`
- コードブロック必須

## Overview
- キーを昇順に保持する dictionary
- 赤黒木ベース
- 各キーは一意
- 1つのキーに1つの mapped value を保持
- 同じキーへ代入すると既存の値を更新
- 挿入・削除・更新を行ってもキーのソート順を維持
- キー順で昇順・降順に走査
- 順序を利用した検索
  - キー検索
  - lower bound
  - upper bound
  - 前後の要素
- 標準 `Dictionary` との違い
- 複数の値を同じキーに関連付ける場合は `RedBlackTreeMultiMap`
- 主な用途
- コード例必須

## Dictionary Operations
- subscript による挿入
- 既存キーへの代入による mapped value の更新
- 単一要素削除
  - `removeValue(forKey:)`
- 範囲削除
- index を使った削除時の注意
- `erase(Index) -> Index` による逐次削除
- コード例必須

## Indices and Bound Expressions
- index は整数オフセットではなく、キー順に並んだ要素の論理的位置を表す
- index の有効性と無効化について説明
- CoW 分岐後の index の扱いを説明
- 無関係なコレクション由来の index の扱いを説明
- `BoundExpression`
  - index を直接扱わない代替記法
  - `.lowerBound`
  - `.upperBound`
  - `.find`
- コード例必須

## Performance
- 計算量表必須
- 以下は実装・設計資料と照合して確定
  - `isEmpty`
  - `count`
  - `startIndex`
  - `endIndex`
  - キーによる検索
  - lower bound
  - upper bound
  - 挿入
  - mapped value の更新
  - キーを検索して削除
  - 既知の index から削除
  - 再平衡化
- `Key` の比較コストの影響

## Red-Black Tree
- 赤黒木
- キーによって木の順序を決定
- 自己平衡によって木の高さを対数的に維持
- 色変更と回転によって平衡を維持
- 要素の論理的な順序とメモリ上の物理配置は異なる

## Important
- thread-safe ではない
