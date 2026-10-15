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
- 通常の挿入では同一キー内の要素順は挿入順
- hint付き挿入では同一キーのグループ内で挿入位置を指定できる
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

## Creating a Multimap
- 空のmultimap
- array literal / dictionary literal
- `init(keysWithValues:)`
- `init(grouping:by:)`
- 重複キーを保持すること
- `init(minimumCapacity:)`
- `capacity`
- `reserveCapacity(_:)`
- コード例必須

## Searching and Accessing Elements
- `contains(key:)`
- `count(forKey:)`
- `first` / `last`
- `min()` / `max()`
- `firstIndex(of:)`
- `find(_:)`
- `lowerBound(_:)`
- `upperBound(_:)`
- `equalRange(_:)`
- `equalRange(_:)`が同一キーの全要素を表すこと
- 検索結果のindexから前後の要素へ移動
- コード例必須

## Key Access and Views
- キーsubscriptは単一値ではなく`RedBlackTreeMappedValuesView`を返す
- 同じキーに関連付けられたmapped valueの論理的な範囲を表す
- 要素を別配列へコピーしない
- 元の multimap と同じ index 型を使用
- `keys`
  - キーの遅延走査
- `values`
  - mapped value の走査
  - `RedBlackTreeMappedValuesView`
  - mapped value の変更
  - `swapAt(_:_:)`
- key subscriptのViewから値を削除すると、対応するkey-value pairも削除される
- キーは木の順序を決定するため変更しない
- `Value` は `Comparable` を必要としない
- subscript に直接変更操作を行う場合は元の multimap を変更
- mapped values viewを独立した変数へ取り出した場合のvalue semantics
- コード例必須

## Insertion, Updating, and Removal
- 挿入
- 同一キー挿入時の挙動
- `insert(key:value:)` / `insert(_:)`
- `insert(_:hint:)`と、同一キーグループ内の挿入位置
- `updateValue(_:at:)`
  - keyを変更せず、指定indexのmapped valueだけを置換する
  - 成功時は置換前のvalueを返す
  - indexが無効な場合は置換せず`nil`を返す
- 単一要素削除
- `popFirst()` / `popLast()`
- `removeFirst()` / `removeLast()`
- 同じキーを持つ複数要素の削除
- `eraseUnique(_:)` / `eraseMulti(_:)`
- `erase(where:)`
- range view を使った削除
- 範囲削除
- `removeAll(keepingCapacity:)`
- index を使った削除時の注意
- `erase(Index) -> Index` による逐次削除
- `index(inserting:)` / `erase(exactly:)`の用途とindexの扱い
- コード例必須

## Combining Multimaps
- `insert(contentsOf:)` / `inserting(contentsOf:)`
- multimapまたはkey-value pairのsequenceを入力できること
- 同一キーの全pairを保持すること
- `meld(_:)` / `melding(_:)`
- 自身を更新する操作と、新しいmultimapを返す操作の違い
- 性能上の使い分けはCombining APIの調査結果と照合して確定
- コード例必須

## Transforming and Iterating
- 要素は`(key: Key, value: Value)`
- `filter(_:)`
- `mapValues(_:)`
- `compactMapValues(_:)`
- 変換後もキー順と重複キーを維持すること
- `sorted()`による昇順配列化
- `reversed()`による降順配列化
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
- index range subscriptと`RedBlackTreeKeyValueRangeView`
- key-value pairの位置範囲を扱い、キーsubscriptのmapped values viewとは異なること
- `containsSubrange(_:)`
- index間およびBound間の`distance(from:to:)`
- `RedBlackTreeMultiMap.Bound`
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
- `filter` / `mapValues` / `compactMapValues`
- `insert(contentsOf:)` / `inserting(contentsOf:)` / `meld` / `melding`はCombining APIの調査結果と照合して確定
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
