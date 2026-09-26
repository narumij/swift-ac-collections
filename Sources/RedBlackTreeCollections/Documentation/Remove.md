Iterator を介した削除と相性が悪いため、範囲削除には View を介した変更を採用した。

View による削除では、削除中の走査位置管理を利用者側に露出させず、
範囲の指定と削除処理を分離できる。

また、範囲の指定にインデックス指定の他に位置指定 DSL も利用できる。

値指定

| 削除対象 | 無条件 | 条件付き |
|---|---|---|
| **単一** | `.remove(_:)` | - |
| **範囲** | - | - |
| **全体** | - | - |

- MultiSetの場合、複数を同時に削除する

インデックス指定または無指定

| 削除対象 | 無条件 | 条件付き |
|---|---|---|
| **単一** | `.remove(at:)`, `.erase(_:)` | - |
| **範囲** | `[Range].erase()` | `[Range].erase(where:)` |
| **全体** | `.removeAll(keepingCapacity:)` | `.erase(where:)` |

位置指定 DSL

| 削除対象 | 無条件 | 条件付き |
|---|---|---|
| **単一** | `.erase(_:)` | - |
| **範囲** | `[BoundsRange].erase()` | `[BoundsRange].erase(where:)` |
| **全体** | - | - |

ループ削除

```swift
var numbers = RedBlackTreeSet<Int>(0..<10)
var it = numbers.startIndex
let end = numbers.find(5)
while it != end {
  it = numbers.erase(it)
}
print(numbers) // -> [5,6,7,8,9]
```

インデックス指定

```swift
var numbers = RedBlackTreeSet<Int>(0..<10)
numbers[numbers.startIndex..<numbers.find(5)].erase()
print(numbers) // -> [5,6,7,8,9]
```

位置指定 DSL

```swift
var numbers = RedBlackTreeSet<Int>(0..<10)
numbers[.startIndex..<.find(5)].erase()
print(numbers) // -> [5,6,7,8,9]
```

