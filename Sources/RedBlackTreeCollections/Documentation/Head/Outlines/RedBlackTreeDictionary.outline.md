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

## Creating a Dictionary
- 空のdictionary
- dictionary literal
- `init(minimumCapacity:)`
- `capacity`
- `reserveCapacity(_:)`
- `init(uniqueKeysWithValues:)`
- `init(_:uniquingKeysWith:)`
- `init(grouping:by:)`
- 重複キーを含む入力の扱い
- コード例必須

## Searching and Accessing Elements
- キーsubscriptによる値の取得
- default値付きsubscript
- `contains(key:)`
- `count(forKey:)`
- `first` / `last`
- `min()` / `max()`
- `firstIndex(of:)` / `index(forKey:)`
- `find(_:)`
- `lowerBound(_:)`
- `upperBound(_:)`
- `equalRange(_:)`
- 検索結果のindexから前後の要素へ移動
- コード例必須

## Insertion, Updating, and Removal
- キーsubscriptによる挿入
- 既存キーへの代入によるmapped valueの更新
- default値付きsubscriptによる挿入・更新
- `updateValue(_:forKey:)`
- 単一要素削除
  - `removeValue(forKey:)`
- 範囲削除
- index を使った削除時の注意
- `erase(Index) -> Index` による逐次削除
- コード例必須

## Transforming and Combining Dictionaries
- `filter(_:)`
- `mapValues(_:)`
- `compactMapValues(_:)`
- `merge(_:uniquingKeysWith:)`
- `merging(_:uniquingKeysWith:)`
- 自身を更新する操作と、新しいdictionaryを返す操作の違い
- 変換後もキー順を維持すること
- 重複キーを解決するクロージャの引数順と結果
- `merge` / `merging`の性能特性はCombining APIの調査結果と照合して確定
- コード例必須

## Iterating over Keys and Values
- 要素は`(key: Key, value: Value)`
- キー順での走査
- `keys` / `values`
- `sorted()`による昇順配列化
- `reversed()`による降順配列化
- range viewでもキーと値を走査できること
- コード例必須

## Indices and Bound Expressions
- index は整数オフセットではなく、キー順に並んだ要素の論理的位置を表す
- 前後の要素へ移動可能
- 他要素の挿入・削除では、指している要素が存在する限り有効
- 指している要素を削除すると無効
- slot 再利用後も古い index は再利用不可
- CoW 分岐後の index の扱いを説明
- 無関係なコレクション由来の index は事前条件違反
- index range subscriptとrange view
- `containsSubrange(_:)`
- index間およびBound間の`distance(from:to:)`
- `RedBlackTreeDictionary.Bound`
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
- 単一Boundが終端または解決不能の場合はsubscriptが`nil`を返す
- 不成立または逆順のBound範囲は空Viewになる
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
- `filter` / `mapValues` / `compactMapValues`
- `merge` / `merging`はCombining APIの調査結果と照合して確定
- `Key` の比較コストの影響

## Red-Black Tree
- 赤黒木
- キーによって木の順序を決定
- 自己平衡によって木の高さを対数的に維持
- 色変更と回転によって平衡を維持
- 要素の論理的な順序とメモリ上の物理配置は異なる

## Important
- thread-safe ではない
