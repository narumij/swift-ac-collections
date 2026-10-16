# RedBlackTreeDictionary

## Declaration

Use `RedBlackTreeDictionary<Key: Comparable, Value>` with `import AcCollections`.

## Overview

A red-black-tree dictionary that stores unique keys in ascending order. Assigning to an existing key replaces its mapped value. Insertion, removal, and value updates preserve key order. Unlike the standard `Dictionary`, it supports ordered traversal and lower- and upper-bound searches. Use `RedBlackTreeMultiMap` when a key must retain multiple values.

```swift
var dict: RedBlackTreeDictionary<Int, String> = [:]
dict[3] = "c"   // -> [3: "c"]
dict[1] = "a"   // -> [1: "a", 3: "c"]
dict[4] = "d"   // -> [1: "a", 3: "c", 4: "d"]
dict[1] = "aa"  // -> [1: "aa", 3: "c", 4: "d"] (updated)
```

## Creating a Dictionary

Create an empty dictionary with `init()` or an empty dictionary literal. Supply unique keys to dictionary literals and `init(uniqueKeysWithValues:)`. For duplicate keys, use `init(_:uniquingKeysWith:)`; its closure receives the stored value followed by the incoming value. `init(grouping:by:)` associates each key with an array in source order.

Use `init(minimumCapacity:)` or `reserveCapacity(_:)` to reserve storage. `capacity` describes storage capacity rather than the number of elements.

## Searching and Accessing Elements

Key subscripting returns `nil` when the key is absent. The default-value subscript returns its default without inserting it on a read. `contains(key:)` checks membership; `count(forKey:)` returns zero or one.

`first` / `last` and `min()` / `max()` access the endpoints in key order. `firstIndex(of:)` / `index(forKey:)` return `nil` for an absent key, while `find(_:)` returns `endIndex`. `lowerBound(_:)` finds the first key greater than or equal to its argument; `upperBound(_:)` finds the first strictly greater key. Both return the end when no such key exists. `equalRange(_:)` describes the matching half-open range. When moving with `index(after:)` or `index(before:)`, respect the endpoint preconditions.

## Insertion, Updating, and Removal

Assign a value through key subscripting to insert or update; assign `nil` to remove. Mutation through the default-value subscript inserts the default first when the key is absent. `updateValue(_:forKey:)` returns the previous value, or `nil` for a new key. `removeValue(forKey:)` removes the matching element.

Use range removal for consecutive elements. Do not advance from an index after deleting its element. For sequential removal, use the next index returned by `erase(_:) -> Index`.

```swift
var dict: RedBlackTreeDictionary<Int, String> = [1: "a", 3: "c", 4: "d", 5: "e"]
dict.removeValue(forKey: 3) // -> [1: "a", 4: "d", 5: "e"]
```

```swift
var dict: RedBlackTreeDictionary<Int, String> = [1: "a", 3: "c", 4: "d", 5: "e"]
dict[dict.lowerBound(4)..<dict.endIndex].erase() // -> [1: "a", 3: "c"]
```

```swift
var dict: RedBlackTreeDictionary<Int, String> = [1: "a", 3: "c", 4: "d", 5: "e"]
dict.erase(dict.lowerBound(4)..<dict.endIndex) // -> [1: "a", 3: "c"]
```

```swift
var dict: RedBlackTreeDictionary<Int, String> = [1: "a", 3: "c", 4: "d", 5: "e"]
var i = dict.startIndex
while i != dict.endIndex {
  i = dict.erase(i)
}
```

## Transforming and Combining Dictionaries

`filter(_:)` returns a dictionary containing the selected pairs. `mapValues(_:)` transforms values without changing keys; `compactMapValues(_:)` omits pairs whose transformed value is `nil`. These operations retain key order.

`merge(_:uniquingKeysWith:)` modifies this dictionary; `merging(_:uniquingKeysWith:)` returns a result. For duplicate keys, the closure receives the existing value and then the incoming value; its result becomes the value for that key.

## Iterating over Keys and Values

Elements are `(key: Key, value: Value)` pairs. Normal iteration follows ascending key order. `keys` traverses keys lazily, and `values` is a mapped-values view. `sorted()` returns an ascending array and `reversed()` a descending array. An index-range view also exposes pairs, keys, and values.

## Indices and Bound Expressions

Indices represent element positions, not integer offsets. Inserting or removing other elements preserves them; deleting the indexed element invalidates its index, even if the slot is reused. In the normal configuration, corresponding positions can be shared across copy-on-write branches, but validity depends on the target’s generation and deletion state. Using an unrelated tree’s index violates a precondition and is not guaranteed to be detected.

Index-range subscripting returns a pair view without copying elements into an array. The view has its own endpoint. Mutating directly through the subscript changes the base; mutating a view stored in a separate variable is isolated through copy-on-write. `containsSubrange(_:)` checks a range, and `distance(from:to:)` accepts indices or bounds.

`Bound` provides `.start`, `.last`, `.end`, `.lowerBound`, `.upperBound`, `.find`, `.lessThan`, `.lessThanOrEqual`, `.greaterThan`, `.greaterThanOrEqual`, `.before`, `.after`, and `.advanced(by:limit:)`. A single bound resolving to the end or no position returns `nil` through subscripting. Invalid or reversed bound ranges produce empty views.

```swift
var dict: RedBlackTreeDictionary<Int, String> = [1: "a", 3: "c", 4: "d", 5: "e"]
print(dict[.lowerBound(4)]) // Optional containing (4, "d")
print(dict[.upperBound(5)]) // -> nil (equivalent to end)
print(dict[.find(2)])       // -> nil (not found)
```

## Performance

The following assumes constant-time comparisons and element operations, and excludes copying shared storage for copy-on-write. Copying can retain deletion history, so its cost is not always determined by the current element count.

Creating a view does not copy elements into an array. Mutating a view stored in a separate variable can trigger copy-on-write.

| Operation | Complexity |
| --- | --- |
| `isEmpty`, `count`, `startIndex`, `endIndex` | O(1) |
| Key lookup, lower/upper bound, insertion, key-based update/removal | O(log n) |
| Removal at a known index; rebalancing | Amortized O(1) |
| `filter`, `mapValues`, `compactMapValues` | O(n), plus closure costs |
| `merge`, `merging` with m existing and n incoming pairs | O(n log(m+n)), plus closure and storage-copy costs |


## Red-Black Tree

The red-black tree orders elements by key and maintains logarithmic height through recoloring and rotations. Logical key order is distinct from physical memory layout.

## Important

This type is not thread-safe and does not protect concurrent access to the same variable. This guide describes the normal configuration.
