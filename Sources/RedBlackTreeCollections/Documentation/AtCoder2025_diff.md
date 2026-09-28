| 領域 | AtCoder 2025 | 現行 |
|---|---|---|
| 走査の基盤 | 4型すべて `Collection` / `BidirectionalCollection` | `Sequence` のみ。独自Index操作へ |
| Index | 標準 `Collection.Index` 中心 | `isElement` / `isEnd` / 双方向Index操作を明示 |
| Range | `Range<Index>` + `SubSequence` | `IndexRange` / `IndexRangeExpression` |
| 値による範囲 | `elements(in:)`、値Range subscript | `Bound` / `BoundRangeExpression` |
| 部分ビュー | nested `SubSequence` | 専用 `RangeView` |
| `equalRange` | `(lower, upper)` タプル | 解決済み `IndexRange` |
| 削除 | `removeSubrange`、`remove(contentsOf:)`、unsafe系 | `erase` 系を充実、Index / Range / Bound / `where` を網羅 |
| Multi削除 | `removeAll(member)` 等 | `eraseUnique` / `eraseMulti` |
| hint | ほぼ無し | 4型 `insert(_:hint:)`、Set update、Dictionary `updateValue` hint |
| 更新 | 少なめ | `update(_:at:)`、`updateValue(_:at:)` などを型ごとに整理 |
| Map View | `values(forKey:)` など | `keys` / `values` View、MultiMap key subscript |
| 集合演算 | 標準適合中心 | Setは `SetAlgebra`、MultiSetにも重複数を考慮した集合演算 |
| 汎用適合 | 比較・表示中心 | `Hashable` / `Codable` まで追加 |

https://github.com/narumij/swift-ac-collections
https://github.com/narumij/swift-ac-collections/tree/release/AtCoder/2025
