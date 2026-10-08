# AtCoder 2025 互換APIマトリクス

`release/AtCoder/2025` ブランチを基準に、RedBlackTreeSet / RedBlackTreeMultiSet /
RedBlackTreeMultiMap / RedBlackTreeDictionary の公開APIを横断的に整理した互換API表。

## 型・生成

| API | Set | MultiSet | MultiMap | Dictionary |
|---|:---:|:---:|:---:|:---:|
| `init()` | ✅ | ✅ | ✅ | ✅ |
| `init(minimumCapacity:)` | ✅ | ✅ | ✅ | ✅ |
| `init(_ sequence:)` | ✅ | ✅ | — | — |
| `init(_ range:)` | ✅ | ✅ | — | — |
| `init(naive:)` | ✅ | ✅ | ✅ | — |
| `init(multiKeysWithValues:)` | — | — | ✅ | — |
| `init(uniqueKeysWithValues:)` | — | — | — | ✅ |
| `init(_:uniquingKeysWith:)` | — | — | — | ✅ |
| `init(grouping:by:)` | — | — | ✅ | ✅ |
| `init(arrayLiteral:)` | ✅ | ✅ | ✅ | ✅ |
| `init(dictionaryLiteral:)` | — | — | ✅ | ✅ |
| `reserveCapacity(_:)` | ✅ | ✅ | ✅ | ✅ |
| `capacity` | ✅ | ✅ | ✅ | ✅ |

## 基本状態・アクセス・探索

| API | Set | MultiSet | MultiMap | Dictionary |
|---|:---:|:---:|:---:|:---:|
| `isEmpty` / `count` | ✅ | ✅ | ✅ | ✅ |
| `count(of:)` | ✅ | ✅ | — | — |
| `count(forKey:)` | — | — | ✅ | ✅ |
| `first` / `last` | ✅ | ✅ | ✅ | ✅ |
| `contains(_:)` | ✅ | ✅ | — | — |
| `contains(key:)` | — | — | ✅ | ✅ |
| `lowerBound(_:)` | ✅ | ✅ | ✅ | ✅ |
| `upperBound(_:)` | ✅ | ✅ | ✅ | ✅ |
| `equalRange(_:) -> (lower:upper:)` | ✅ | ✅ | ✅ | ✅ |
| `min()` / `max()` | ✅ | ✅ | ✅ | ✅ |
| `first(where:)` | ✅ | ✅ | ✅ | ✅ |
| `firstIndex(of:)` | ✅ | ✅ | ✅ | ✅ |
| `firstIndex(where:)` | ✅ | ✅ | ✅ | ✅ |
| `subscript(key:) -> Value?` | — | — | — | ✅ |
| `subscript(key:default:)` | — | — | — | ✅ |
| `values(forKey:)` | — | — | ✅ | — |
| `subscript(key:) -> SubSequence` | — | — | ✅ | — |

## 挿入・更新・結合

| API | Set | MultiSet | MultiMap | Dictionary |
|---|:---:|:---:|:---:|:---:|
| `insert(_:)` | ✅ | ✅ | ✅ | ✅ |
| `insert(key:value:)` | — | — | ✅ | ✅ |
| `update(with:)` | ✅ | — | — | — |
| `updateValue(_:at:)` | — | — | ✅ | — |
| `updateValue(_:forKey:)` | — | — | — | ✅ |
| `insert(contentsOf:)` | — | ✅ | ✅ | — |
| `inserting(contentsOf:)` | — | ✅ | ✅ | — |
| `merge(_:...)` | ✅ | — | — | ✅ |
| `merging(_:...)` | ✅ | — | — | ✅ |
| `meld(_:)` / `melding(_:)` | — | ✅ | ✅ | — |
| `+` / `+=` | — | ✅ | ✅ | — |

## 削除

| API | Set | MultiSet | MultiMap | Dictionary |
|---|:---:|:---:|:---:|:---:|
| `popFirst()` | ✅ | ✅ | ✅ | ✅ |
| `popLast()` | — | — | — | — |
| `remove(_:)` | ✅ | ✅ | — | — |
| `remove(at:)` | ✅ | ✅ | ✅ | ✅ |
| `removeFirst()` / `removeLast()` | ✅ | ✅ | ✅ | ✅ |
| `removeSubrange(_:)` | ✅ | ✅ | ✅ | ✅ |
| `remove(contentsOf: Range/ClosedRange)` | ✅ | ✅ | ✅ | ✅ |
| `removeAll(keepingCapacity:)` | ✅ | ✅ | ✅ | ✅ |
| `removeAll(_ member:)` | — | ✅ | — | — |
| `removeAll(_unsafe member:)` | — | ✅ | — | — |
| `removeFirst(forKey:)` | — | — | ✅ | — |
| `removeFirst(_unsafeForKey:)` | — | — | ✅ | — |
| `removeAll(forKey:)` | — | — | ✅ | — |
| `removeAll(_unsafeForKey:)` | — | — | ✅ | — |
| `removeValue(forKey:)` | — | — | — | ✅ |

## 旧 Range / Slice API

| API | Set | MultiSet | MultiMap | Dictionary |
|---|:---:|:---:|:---:|:---:|
| `subscript(Range<Index>) -> SubSequence` | ✅ | ✅ | ✅ | ✅ |
| `subscript(_unsafe: Range<Index>)` | ✅ | ✅ | ✅ | ✅ |
| `elements(in: Range<Value/Key>)` | ✅ | ✅ | ✅ | ✅ |
| `elements(in: ClosedRange<Value/Key>)` | ✅ | ✅ | ✅ | ✅ |
| `subscript(Range<Value/Key>)` | ⚠️ deprecated | ⚠️ deprecated | ⚠️ deprecated | ✅ |
| `subscript(ClosedRange<Value/Key>)` | ⚠️ deprecated | ⚠️ deprecated | ⚠️ deprecated | ✅ |
| nested `SubSequence` | ✅ | ✅ | ✅ | ✅ |

## 変換・比較・標準プロトコル

| API / Protocol | Set | MultiSet | MultiMap | Dictionary |
|---|:---:|:---:|:---:|:---:|
| `Sequence` | ✅ | ✅ | ✅ | ✅ |
| `Collection` | ✅ | ✅ | ✅ | ✅ |
| `BidirectionalCollection` | ✅ | ✅ | ✅ | ✅ |
| `filter` 同型返却の独自実装 | — | — | ✅ | ✅ |
| `mapValues(_:)` | — | — | ✅ | ✅ |
| `compactMapValues(_:)` | — | — | ✅ | ✅ |
| `elementsEqual(_:)` | ✅ | ✅ | ✅* | ✅* |
| `lexicographicallyPrecedes(_:)` | ✅ | ✅ | ✅* | ✅* |
| `Equatable` | ✅ | ✅ | ✅* | ✅* |
| `Comparable` | ✅ | ✅ | ✅* | ✅* |
| `ExpressibleByArrayLiteral` | ✅ | ✅ | ✅ | ✅ |
| `ExpressibleByDictionaryLiteral` | — | — | ✅ | ✅ |
| `CustomStringConvertible` | ✅ | ✅ | ✅ | ✅ |
| `CustomDebugStringConvertible` | ✅ | ✅ | ✅ | ✅ |
| `CustomReflectable` | ✅ | ✅ | ✅ | ✅ |
| `Sendable` | ✅* | ✅* | ✅* | ✅* |
| `SetAlgebra` | — | — | — | — |
| `Hashable` | — | — | — | — |
| `Codable` | — | — | — | — |

`*` は要素型 / Value 型側の制約付き。

## 備考

- `equalRange(_:)` は現行の独自 `IndexRange` ではなく、`(lower: Index, upper: Index)` のタプル。
- hint 付き挿入はこの版にはまだない。
- 4型すべてが `Collection` / `BidirectionalCollection` に適合。
- 旧 `SubSequence` ベースの Slice API を含む。
- MultiSet / MultiMap には `_unsafe` 系削除APIがある。
