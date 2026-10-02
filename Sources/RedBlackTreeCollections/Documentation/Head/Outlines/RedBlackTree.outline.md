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

- 一文で型を説明する
- 要素を昇順に保持する赤黒木ベースの一意集合であること

## Declaration

- `import AcCollections`
- `struct RedBlackTreeSet<Element: Comparable>`
- コードブロック必須

## Overview

- 各要素を高々1つ保持する
- 要素は常に昇順
- 挿入後もソート順を自動的に維持する
- `Set` と同様に重複を保持しない
- `Set` はハッシュテーブル、`RedBlackTreeSet` は赤黒木
- 検索・挿入・削除は対数時間
- ソート済み順序で走査可能
- 主な用途
  - 動的な追加・削除とソート順維持
  - 前後の要素の検索
  - lower-bound / upper-bound 相当の検索
  - 昇順・降順走査
  - 順序付き集合
- 単純な membership test だけなら `Set` が適する場合がある
- ハッシュ検索の平均 O(1) と赤黒木の O(log `count`) の違い
- 順序付き検索・ソート済み走査が強み
- コード例必須
  - 初期化時に自動的にソートされる例
  - 複数回の `insert` と重複挿入の例

## Unique Elements

- 順序比較上同じ位置に属する値を複数保持しない
- 重複を含む入力から一意集合になること
- 重複が必要なら `RedBlackTreeMultiSet`
- コード例必須

## Sorted Iteration

- 通常の走査では常に昇順
- 配列化して事前にソートする必要がない
- ソート順はコレクション自身の構造で維持される
- 動的な追加・削除を行いながらソート済み走査できる
- コード例必須
  - `for-in`
  - 出力順

## Ordered Lookup

- 順序比較を利用した検索が可能
- 扱う問い合わせ
  - 値の存在確認
  - 指定値以上の最初の要素
  - 指定値より大きい最初の要素
  - 指定位置の直前・直後
- 線形走査が不要
- 値に基づく検索は worst-case O(log `count`)

## Set Operations

- 基本的な集合操作
  - 検索
  - 挿入
  - 削除
- 挿入してもソート順を維持
- 既存値を再挿入してもコピーを追加しない
- コード例必須
  - `insert`
  - `remove`

## Removal

- 単一要素削除
- 範囲削除
- index を使った削除を `for` ループで繰り返すべきでない理由
  - index とノードの関係
  - 削除後にその index から次の index を取得できない
- 連続削除には範囲削除 API を使う
- `erase(_:) -> Index` による逐次削除
  - 削除後の次の index を受け取れる
  - C++ コンテナとの類似
- コード例必須
  - `remove`
  - View に対する範囲 `erase`
  - Collection に対する範囲 `erase`
  - `while` + `erase(Index) -> Index`

## Indices

- index はソート済み要素列の論理的位置
- 前後の要素へ移動可能
- 整数オフセットではない
- `Array` との違い
- 他要素の挿入・削除では、指している要素が存在する限り有効
- 指している要素を削除すると無効
- slot が再利用されても古い index は再利用不可
- CoW で分岐したコレクション
  - 対応要素が存在すること
  - 世代が一致すること
  - 条件を満たせば位置を特定可能
- 無関係なコレクション由来の index
  - 使用は事前条件違反
  - 違反の検出は保証しない

## Index Alternative Syntax

- `BoundExpression`
- direct index usage の safe alternative
- index を直接扱わず要素・境界を指定できる
- 値に基づく検索にも利用可能
- コード例必須
  - `.start.advance(by:)`
  - `.lowerBound`
  - `.upperBound`
  - `.find`
  - end / not-found の `nil`

## Performance

- 赤黒木により木の高さは対数的に制限される
- 計算量表必須
  - `isEmpty`: O(1)
  - `count`: O(1)
  - `startIndex`: O(1)
  - `endIndex`: O(1)
  - 値の検索: O(log `count`)
  - lower-bound: O(log `count`)
  - upper-bound: O(log `count`)
  - 挿入: O(log `count`)
  - 値を検索して削除: O(log `count`)
  - 既知の index から削除: 償却 O(1)
- 実時間は `Element` の比較コストやメモリアクセス特性にも依存
- 比較が O(1) でなければ、その比較コストも加わる

## Red-Black Tree

- 自己平衡二分探索木
- 二分探索木の順序
- 挿入・削除時の色変更と回転
- 木の極端な偏りを防ぐ
- 検索・挿入・削除の worst-case O(log `count`)
- 再平衡化コストは償却 O(1)
- 非平衡な単純二分探索木との違い

## Implementation Details

- 各要素を赤黒木ノードとして管理
- ノードごとの独立した heap allocation は行わない
- 複数ノードをまとめた storage
- allocation overhead の削減
- ノード管理情報と値を近い位置に配置
- 走査時のメモリアクセス効率
- 論理的には常に昇順
- メモリ上の物理配置はソート順ではない
- `Array` のような連続配列とは異なる
- 連続配列とは異なるメモリアクセス・性能特性

## Choosing a Collection

- `Set`
  - 順序不要
  - membership test 中心
- `Array`
  - contiguous storage
  - 整数 index
  - random access
- `RedBlackTreeSet`
  - 動的な追加・削除
  - ソート順維持
  - 順序に基づく検索
- 重複値を保持する場合は `RedBlackTreeMultiSet`

## Important

- `RedBlackTreeSet` is not thread-safe.
