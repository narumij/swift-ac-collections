# RedBlackTreeMultiMap

## Declaration

Use `RedBlackTreeMultiMap` with `import AcCollections`. Any declaration below illustrates the type signature rather than a complete executable program.

```swift
import AcCollections

struct RedBlackTreeMultiMap<Key: Comparable, Value>
```

## Overview

A red-black-tree multimap that orders pairs by key and retains multiple values for the same key. Each pair is a separate element. Ordinary insertion preserves insertion order within an equivalent-key group; a valid hint satisfying the ordering conditions can insert within that group.

Unlike `Dictionary` or `RedBlackTreeDictionary`, it retains duplicate keys. Unlike `Dictionary<Key, [Value]>`, it represents each pair as an individual tree position. It suits ordered searches, traversal, and removal of groups of values.

```text
("apple", 100)
("apple", 120)
("banana", 80)
("orange", 150)
("orange", 180)
```

```text
1 → "red"
1 → "green"
1 → "blue"
2 → "orange"
3 → "purple"
3 → "yellow"
```

```swift
var map: RedBlackTreeMultiMap<Int, String> = []
map.insert(key: 3, value: "a") // -> [3: "a"]
map.insert(key: 1, value: "b") // -> [1: "b", 3: "a"]
map.insert(key: 4, value: "c") // -> [1: "b", 3: "a", 4: "c"]
map.insert(key: 1, value: "d") // -> [1: "b", 1: "d", 3: "a", 4: "c"]
map.insert(key: 5, value: "e") // -> [1: "b", 1: "d", 3: "a", 4: "c", 5: "e"]
```

## Creating a Multimap

Create an empty instance, use a literal, or initialize from an input sequence. `init(minimumCapacity:)` sets initial capacity and `reserveCapacity(_:)` reserves storage. `capacity` is distinct from the element count. Array literals, dictionary literals, and `init(keysWithValues:)` retain duplicate keys. `init(grouping:by:)` assigns a key to each source value and retains individual pairs rather than grouping values into arrays.

## Searching and Accessing Elements

`contains(key:)` checks membership and `count(forKey:)` returns the number of matches. `first` / `last` and `min()` / `max()` access the endpoints. `firstIndex(of:)` returns `nil` when absent; `find(_:)` returns `endIndex`. `lowerBound(_:)` finds the first key greater than or equal to its argument, and `upperBound(_:)` the first strictly greater key; both return the end if none exists. `equalRange(_:)` returns the half-open range of all matching pairs. Move forward or backward from search results within the endpoint preconditions; the end cannot be dereferenced as an element.

```text
lowerBound(2)
    ↓
[2:A, 2:B, 2:C]
                ↑
           upperBound(2)
```

## Key Access and Views

Key subscripting returns a `RedBlackTreeMappedValuesView`, not a single value or pair view. It represents values for one key without copying them into an array. To traverse pairs, use `map[map.equalRange(key)]`, a `RedBlackTreeKeyValueRangeView`; its `keys` traverses keys lazily and its `values` exposes mapped values.

Keys determine ordering and are not mutable through the view. `Value` need not be Comparable. A mapped view supports value updates, `swapAt(_:_:)`, and removal; removing a value also removes its pair. Supply two element indices within the view to swap. Mutation directly through `map[key]` changes the base; mutation of a separately stored view does not. The existing fragments below illustrate stored pairs, selected values, pair-view traversal, and direct mutation.

```text
(1, "red")
(1, "green")
(1, "blue")
(2, "orange")
```

```swift
map[1]
```

```text
"red"
"green"
"blue"
```

```swift
let elements = map[map.equalRange(key)]

for key in elements.keys {
  // ...
}

for value in elements.values {
  // ...
}
```

```swift
map[key].popFirst()
map[key].erase()
```

```swift
Key: Comparable
```

```swift
map[key].swapAt(i, j)
```

## Insertion, Updating, and Removal

`insert(key:value:)` / `insert(_:)` add a pair even when its key already exists. `insert(_:hint:)` can insert immediately before a valid hint when the ordering conditions fit. A valid hint that does not satisfy those ordering conditions affects only performance; insertion still uses the normal ordered position. An invalid hint violates a precondition. `updateValue(_:at:)` replaces only the mapped value at an index and returns its old value, or `nil` for an invalid index.

`eraseUnique(_:)` removes one matching pair; `eraseMulti(_:)` removes all. `popFirst()` / `popLast()` return `nil` when empty; `removeFirst()` / `removeLast()` require a nonempty map. Predicate removal, range/view removal, and `removeAll(keepingCapacity:)` are supported. For sequential removal use the next index returned by `erase(_:) -> Index`. `index(inserting:)` returns an insertion result and index. `erase(exactly:)` removes the indexed element and returns the next index, or `nil` if the index is not accessible in this map.

```text
1 → "A"
2 → "B"
```

```text
1 → "C"
```

```text
1 → "A"
1 → "C"
2 → "B"
```

```swift
var map: RedBlackTreeMultiMap<Int, String> =
  [1: "b", 1: "d", 3: "a", 4: "c", 5: "e"]
map.eraseUnique(3) // -> [1: "b", 1: "d", 4: "c", 5: "e"]
```

```swift
var map: RedBlackTreeMultiMap<Int, String> =
  [1: "b", 1: "d", 3: "a", 4: "c", 5: "e"]
map[map.lowerBound(4)..<map.endIndex].erase() // -> [1: "b", 1: "d", 3: "a"]
```

```swift
var map: RedBlackTreeMultiMap<Int, String> =
  [1: "b", 1: "d", 3: "a", 4: "c", 5: "e"]
map.erase(map.lowerBound(4)..<map.endIndex) // -> [1: "b", 1: "d", 3: "a"]
```

```swift
var map: RedBlackTreeMultiMap<Int, String> =
  [1: "b", 1: "d", 3: "a", 4: "c", 5: "e"]
var i = map.startIndex
while i != map.endIndex {
  i = map.erase(i)
}
```

## Combining Multimaps

`insert(contentsOf:)` inserts into this value; `inserting(contentsOf:)` returns the result. These operations insert elements into existing storage, copying it first when shared. `meld(_:)` replaces this value with the combined result; `melding(_:)` returns a result. Both traverse two sorted trees and build new storage. Spare capacity alone is not a reason to prefer meld. Inputs can be multimaps or sequences of pairs; every pair is retained, including duplicate keys.

## Transforming and Iterating

Elements are `(key: Key, value: Value)` pairs, iterated in ascending key order. `filter(_:)` retains selected pairs; `mapValues(_:)` transforms their values; `compactMapValues(_:)` omits pairs whose transformed value is `nil`. Retained pairs preserve key order and duplicates. `sorted()` / `reversed()` return ascending / descending arrays.

```text
(3, "C")
(1, "A")
(2, "B")
(1, "D")
```

```text
(1, "A")
(1, "D")
(2, "B")
(3, "C")
```

## Indices and Bound Expressions

An index represents an element position, not an integer offset. Indices support forward and backward movement within their endpoint preconditions. Inserting or deleting other elements preserves an index while its element exists. Deleting that element invalidates the index; reusing its slot does not revive it. In the normal configuration, corresponding positions can be shared across copy-on-write branches, but validity depends on the target’s generation and deletion state. Using an unrelated tree’s index violates a precondition and is not guaranteed to be detected.

Index-range subscripting returns a view without copying elements into an array. It uses the base’s index type but has its own range and endpoint. A view endpoint can identify an element in the base. Mutation directly through a subscript changes the base; mutation of a view stored separately is isolated through copy-on-write. `containsSubrange(_:)` checks a range, and `distance(from:to:)` accepts indices or bounds.

`Bound` specifies positions without directly manipulating indices. It provides `.start`, `.last`, `.end`, `.lowerBound`, `.upperBound`, `.find`, `.lessThan` / `.lessThanOrEqual`, `.greaterThan` / `.greaterThanOrEqual`, `.before` / `.after`, and `.advanced(by:limit:)`. A single bound that resolves to the end or no position returns `nil` through subscripting. Invalid or reversed bound ranges return empty views.

```swift
var map: RedBlackTreeMultiMap<Int, String> =
  [1: "b", 1: "d", 3: "a", 4: "c", 5: "e"]
print(map[.start.advanced(by: 1)]) // Optional containing (1, "d")
```

```swift
var map: RedBlackTreeMultiMap<Int, String> =
  [1: "b", 1: "d", 3: "a", 4: "c", 5: "e"]
print(map[.lowerBound(5)]) // Optional containing (5, "e")
print(map[.upperBound(5)]) // -> nil (equivalent to end)
print(map[.find(2)])       // -> nil (not found)
```

## Performance

These bounds assume constant-time comparisons and element operations, and exclude copying shared storage for copy-on-write. Copying retains deletion history and is not always bounded by the current count alone. Creating a view does not copy elements into an array, but a later mutation can require copy-on-write.

| Operation | Complexity |
| --- | --- |
| `isEmpty`, `count`, `startIndex`, `endIndex` | O(1) |
| Lookup, lower/upper bound, insertion, lookup and removal of one element | O(log n) |
| Removal at a known index; rebalancing | Amortized O(1) |
| Lookup and removal/processing of K matching elements | O(log n + K) |
| `insert(contentsOf:)`, `inserting(contentsOf:)` (n incoming, m existing) | O(n log(m+n)), plus storage-copy costs |
| `meld`, `melding` | O(n+m), new storage |
| `filter`, `mapValues`, `compactMapValues` | O(n), plus closure costs |


## Red-Black Tree

A red-black tree is a self-balancing binary search tree that maintains logarithmic height through recoloring and rotations. Logical element order differs from physical memory layout. In duplicate-supporting types, each element still occupies its own node. Nodes are managed in grouped storage rather than requiring a separate allocation for every node.

## Important

This type is not thread-safe and does not protect concurrent access to the same variable. This guide describes the normal configuration.
