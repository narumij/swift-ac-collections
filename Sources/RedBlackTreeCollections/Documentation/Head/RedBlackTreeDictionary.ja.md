<!-- 編集用原稿: 日本語利用者向け文書と現行Swiftソース先頭コメントの和集合。 -->
<!-- 重複を整理してから RedBlackTreeDictionary.swift のコメントドックへ反映する。 -->

<!-- 現在、単独の Documentation/RedBlackTreeDictionary.ja.md は存在しない。 -->

---

## Current Source Type Documentation

<!-- 以下は現行 RedBlackTreeDictionary.swift の型コメント。上記にない内容を取りこぼさないための編集素材。 -->

# RedBlackTreeDictionary

`RedBlackTreeDictionary` is a **sorted dictionary (unique keys)**
implemented using a red-black tree.
Keys are always kept in sorted order.

```swift
var dict: RedBlackTreeDictionary<Int, String> = [:]
dict[3] = "c"   // -> [3: "c"]
dict[1] = "a"   // -> [1: "a", 3: "c"]
dict[4] = "d"   // -> [1: "a", 3: "c", 4: "d"]
dict[1] = "aa"  // -> [1: "aa", 3: "c", 4: "d"] (updated)
```

## Removal

Both single-element removal and range removal are supported.

```swift
var dict: RedBlackTreeDictionary<Int, String> = [1: "a", 3: "c", 4: "d", 5: "e"]
dict.removeValue(forKey: 3) // -> [1: "a", 4: "d", 5: "e"]
```

Avoid performing repeated removals via indices in a `for` loop.
Since indices are tightly coupled with tree nodes, removing an element
invalidates the operation that retrieves the next index.
Use the range-removal APIs for consecutive deletions instead.

```swift
var dict: RedBlackTreeDictionary<Int, String> = [1: "a", 3: "c", 4: "d", 5: "e"]
dict[dict.lowerBound(4)..<dict.endIndex].erase() // -> [1: "a", 3: "c"]
```

```swift
var dict: RedBlackTreeDictionary<Int, String> = [1: "a", 3: "c", 4: "d", 5: "e"]
dict.erase(dict.lowerBound(4)..<dict.endIndex) // -> [1: "a", 3: "c"]
```

As in C++, sequential removal using `erase(_:) -> Index` is also supported.
You can remove elements while receiving the next index.

```swift
var dict: RedBlackTreeDictionary<Int, String> = [1: "a", 3: "c", 4: "d", 5: "e"]
var i = dict.startIndex
while i != dict.endIndex {
  i = dict.erase(i)
}
```

## Index Alternative Syntax

`BoundExpression` is designed as a **safe alternative** to direct index usage.
It allows specifying elements or boundaries without handling indices directly.

```swift
var dict: RedBlackTreeDictionary<Int, String> = [1: "a", 3: "c", 4: "d", 5: "e"]
print(dict[.lowerBound(4)]) // -> (4, "d")
print(dict[.upperBound(5)]) // -> nil (equivalent to end)
print(dict[.find(2)])       // -> nil (not found)
```

- Important: `RedBlackTreeDictionary` is not thread-safe.
