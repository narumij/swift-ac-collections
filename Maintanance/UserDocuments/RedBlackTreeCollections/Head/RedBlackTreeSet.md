# RedBlackTreeSet

## Declaration

Use `RedBlackTreeSet` with `import AcCollections`. Any declaration below illustrates the type signature rather than a complete executable program.

```swift
import AcCollections

struct RedBlackTreeSet<Element: Comparable>
```

## Overview

A red-black-tree set that stores unique elements in ascending order. Insertion and removal preserve order, and inserting a duplicate does not add another copy. Unlike the standard `Set`, it supports ordered searches and traversal; unlike an `Array`, it maintains sorting across updates. Use `RedBlackTreeMultiSet` for duplicates. It suits changing sets that need ordered traversal or bound searches.

Create an empty set, use an array literal, or initialize from an input sequence. Reserve storage with `init(minimumCapacity:)` or `reserveCapacity(_:)`. Normal iteration is ascending; `sorted()` / `reversed()` return ascending / descending arrays.

```swift
let numbers: RedBlackTreeSet = [5, 2, 4, 1, 3]

print(numbers)
// [1, 2, 3, 4, 5]
```

```swift
let numbers: RedBlackTreeSet = [3, 1, 2, 3, 2, 1]

print(numbers)
// [1, 2, 3]
```

```swift
let numbers: RedBlackTreeSet = [7, 2, 9, 1, 5]

for number in numbers {
  print(number)
}
```

```text
1
2
5
7
9
```

```swift
var set: RedBlackTreeSet<Int> = []
set.insert(3) // -> [3]
set.insert(1) // -> [1, 3]
set.insert(4) // -> [1, 3, 4]
set.insert(1) // -> [1, 3, 4]
set.insert(5) // -> [1, 3, 4, 5]
```

## Searching and Accessing Elements

`contains(_:)` checks membership and `count(of:)` returns the number of matches. `first` / `last` and `min()` / `max()` access the endpoints. `firstIndex(of:)` returns `nil` when absent; `find(_:)` returns `endIndex`. `lowerBound(_:)` finds the first value greater than or equal to its argument, and `upperBound(_:)` the first strictly greater value; both return the end if none exists. `equalRange(_:)` returns the half-open range of all equivalent elements. Move forward or backward from search results within the endpoint preconditions; the end cannot be dereferenced as an element.

## Insertion and Removal

`insert(_:)` preserves uniqueness and does not add duplicate elements. `remove(_:)` searches for and removes a value. Range removal and removal at a known index are also supported. Do not advance from a deleted index; use the next index returned by `erase(_:) -> Index` for sequential removal.

```swift
var numbers: RedBlackTreeSet = [1, 3, 5]

numbers.insert(4)
// [1, 3, 4, 5]

numbers.remove(3)
// [1, 4, 5]
```

```swift
var set: RedBlackTreeSet<Int> = [1, 3, 4, 5]
set.remove(3) // -> [1, 4, 5]
```

```swift
var set: RedBlackTreeSet<Int> = [1, 3, 4, 5]
set[.lowerBound(4) ..< .end].erase() // -> [1, 3]
```

```swift
var set: RedBlackTreeSet<Int> = [1, 3, 4, 5]
set.erase(.lowerBound(4) ..< .end) // -> [1, 3]
```

```swift
var set: RedBlackTreeSet<Int> = [1, 3, 4, 5]
var i = set.startIndex
while i != set.endIndex {
  i = set.erase(i)
}
```

## Set Algebra

`union` / `formUnion`, `intersection` / `formIntersection`, `difference` / `formDifference`, and `symmetricDifference` / `formSymmetricDifference` compute the union, intersection, difference, and symmetric difference. The `form` variants mutate this set; their counterparts return results.

## Indices and Bound Expressions

An index represents an element position, not an integer offset. Indices support forward and backward movement within their endpoint preconditions. Inserting or deleting other elements preserves an index while its element exists. Deleting that element invalidates the index; reusing its slot does not revive it. In the normal configuration, corresponding positions can be shared across copy-on-write branches, but validity depends on the target’s generation and deletion state. Using an unrelated tree’s index violates a precondition and is not guaranteed to be detected.

Index-range subscripting returns a view without copying elements into an array. It uses the base’s index type but has its own range and endpoint. A view endpoint can identify an element in the base. Mutation directly through a subscript changes the base; mutation of a view stored separately is isolated through copy-on-write. `containsSubrange(_:)` checks a range, and `distance(from:to:)` accepts indices or bounds.

`Bound` specifies positions without directly manipulating indices. It provides `.start`, `.last`, `.end`, `.lowerBound`, `.upperBound`, `.find`, `.lessThan` / `.lessThanOrEqual`, `.greaterThan` / `.greaterThanOrEqual`, `.before` / `.after`, and `.advanced(by:limit:)`. A single bound that resolves to the end or no position returns `nil` through subscripting. Invalid or reversed bound ranges return empty views.

```swift
var set: RedBlackTreeSet<Int> = [1, 3, 4, 5]
print(set[.start.advanced(by: 1)]) // Optional containing 3
```

```swift
var set: RedBlackTreeSet<Int> = [1, 3, 4, 5]
print(set[.lowerBound(5)]) // Optional containing 5
print(set[.upperBound(5)]) // -> nil (equivalent to end)
print(set[.find(2)]) // -> nil (not found)
```

## Performance

These bounds assume constant-time comparisons and element operations, and exclude copying shared storage for copy-on-write. Copying retains deletion history and is not always bounded by the current count alone. Creating a view does not copy elements into an array, but a later mutation can require copy-on-write.

| Operation | Complexity |
| --- | --- |
| `isEmpty`, `count`, `startIndex`, `endIndex` | O(1) |
| Lookup, lower/upper bound, insertion, lookup and removal of one element | O(log n) |
| Removal at a known index; rebalancing | Amortized O(1) |
| Union, intersection, difference, symmetric difference | O(n+m) |


## Red-Black Tree

A red-black tree is a self-balancing binary search tree that maintains logarithmic height through recoloring and rotations. Logical element order differs from physical memory layout. In duplicate-supporting types, each element still occupies its own node. Nodes are managed in grouped storage rather than requiring a separate allocation for every node.

## Important

This type is not thread-safe and does not protect concurrent access to the same variable. This guide describes the normal configuration.
