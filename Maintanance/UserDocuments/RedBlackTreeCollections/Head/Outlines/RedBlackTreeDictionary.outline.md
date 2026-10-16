<!--
- Source of Truth: このアウトライン
- Output:
  - RedBlackTreeDictionary.ja.md
  - RedBlackTreeDictionary.md（英訳）
  - RedBlackTreeDictionary.swift の documentation comment（英語）
- Priority: 初心者への配慮より、RedBlackTreeDictionary について過不足なく伝えることを優先
- Code Examples: 2026-10-16ユーザー決定により既存の構成・掲載数を固定。追加・削除は0.8.0で再検討。
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
- default値付きsubscript：不在キーの読み取りだけでは挿入しない
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
- 結合クロージャは既存値、入力値の順。各戻り値で重複キーの値を更新する
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
- 無関係なコレクション由来の index は事前条件違反。常に検出されるという保証にはしない
- 通常構成のCoWでは対応する位置のindexを共有できるが、有効性は操作先の世代・削除状態で決まる
- Viewの終端は元の木では要素位置である場合があり、View内の範囲を守って使用する
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
- 下記の変更操作の計算量は、CoWによるストレージ複製を別途必要としない場合。比較・要素操作を定数時間とする
- Viewの作成は要素配列をコピーしないが、独立したViewの変更でCoWが発生する場合がある
- 計算量表必須
- `isEmpty` / `count` / `startIndex` / `endIndex`: O(1)
- キー検索、lower bound、upper bound、挿入、キー指定のmapped value更新・削除: O(log `count`)
- 既知のindexから削除・再平衡化: 償却 O(1)
- `filter` / `mapValues` / `compactMapValues`: O(n)、クロージャのコストは別途
- `merge` / `merging`: 入力n件・元m件で O(n log(m + n))、CoW複製とクロージャのコストは別途
- `Key` の比較コストの影響

## Red-Black Tree
- 赤黒木
- キーによって木の順序を決定
- 自己平衡によって木の高さを対数的に維持
- 色変更と回転によって平衡を維持
- 要素の論理的な順序とメモリ上の物理配置は異なる

## Important
- thread-safe ではない
- 本照合は通常構成（COMPATIBLE_ATCODER_2025無効）の公開APIを対象とする
