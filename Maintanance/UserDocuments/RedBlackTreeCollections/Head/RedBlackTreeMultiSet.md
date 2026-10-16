# RedBlackTreeMultiSet

## Declaration

Use `RedBlackTreeMultiSet` with `import AcCollections`. Any declaration below illustrates the type signature rather than a complete executable program.

```swift
import AcCollections

struct RedBlackTreeMultiSet<Element: Comparable>
```

## Overview

A red-black-tree multiset that stores elements in ascending order and retains duplicates. Equivalent elements have distinct positions and appear consecutively. Unlike `Set` or `RedBlackTreeSet`, it retains multiplicities; unlike an `Array`, it maintains order across updates. Use `RedBlackTreeSet` when duplicates are not needed.

```swift
let numbers: RedBlackTreeMultiSet = [5, 2, 4, 2, 1, 3, 3]

print(numbers)
// [1, 2, 2, 3, 3, 4, 5]
```

```swift
let numbers: RedBlackTreeMultiSet = [3, 1, 2, 3, 2, 1]

print(numbers)
// [1, 1, 2, 2, 3, 3]
```

```swift
var set: RedBlackTreeMultiSet<Int> = []
set.insert(3) // -> [3]
set.insert(1) // -> [1, 3]
set.insert(4) // -> [1, 3, 4]
set.insert(1) // -> [1, 1, 3, 4]
set.insert(5) // -> [1, 1, 3, 4, 5]
```

## Creating a Multiset

Create an empty instance, use a literal, or initialize from an input sequence. `init(minimumCapacity:)` sets initial capacity and `reserveCapacity(_:)` reserves storage. `capacity` is distinct from the element count. Array literals, sequences, collections, and ranges can supply the elements.

## Searching and Accessing Elements

`contains(_:)` checks membership and `count(of:)` returns the number of matches. `first` / `last` and `min()` / `max()` access the endpoints. `firstIndex(of:)` returns `nil` when absent; `find(_:)` returns `endIndex`. `lowerBound(_:)` finds the first value greater than or equal to its argument, and `upperBound(_:)` the first strictly greater value; both return the end if none exists. `equalRange(_:)` returns the half-open range of all equivalent elements. Move forward or backward from search results within the endpoint preconditions; the end cannot be dereferenced as an element.

## Insertion and Removal

Insertion adds an element without replacing equivalent elements. A hint must be a valid position and helps locate insertion when its ordering conditions fit. `update(_:at:)` replaces an element only when old and new values compare equal with `==`, returning the old value. Invalid indices or unequal replacements return `nil`.

`eraseUnique(_:)` removes one match; `eraseMulti(_:)` removes all matches. `popFirst()` / `popLast()` return `nil` when empty; `removeFirst()` / `removeLast()` require a nonempty multiset. Predicate removal with `erase(where:)`, range removal, and `removeAll(keepingCapacity:)` are also available. For sequential removal, continue with the index returned by `erase(_:) -> Index`, not a deleted index.

```swift
var numbers: RedBlackTreeMultiSet = [1, 3, 3, 5]

numbers.insert(3)
// [1, 3, 3, 3, 5]

numbers.insert(4)
// [1, 3, 3, 3, 4, 5]
```

```swift
var set: RedBlackTreeMultiSet<Int> = [1, 1, 3, 4, 5]
set.eraseUnique(3) // -> [1, 1, 4, 5]
```

```swift
var set: RedBlackTreeMultiSet<Int> = [1, 1, 3, 4, 5]
set[set.lowerBound(4)..<set.endIndex].erase() // -> [1, 1, 3]
```

```swift
var set: RedBlackTreeMultiSet<Int> = [1, 1, 3, 4, 5]
set.erase(set.lowerBound(4)..<set.endIndex) // -> [1, 1, 3]
```

```swift
var set: RedBlackTreeMultiSet<Int> = [1, 1, 3, 4, 5]
var i = set.startIndex
while i != set.endIndex {
  i = set.erase(i)
}
```

## Combining Multisets

`insert(contentsOf:)` inserts into this value; `inserting(contentsOf:)` returns the result. These operations insert elements into existing storage, copying it first when shared. `meld(_:)` replaces this value with the combined result; `melding(_:)` returns a result. Both traverse two sorted trees and build new storage. Spare capacity alone is not a reason to prefer meld. The insertion APIs accept a set, multiset, or arbitrary sequence.

## Multiset Algebra

For multiplicities a and b, `union` yields a+b, `intersection` min(a,b), `difference` max(a-b,0), and `symmetricDifference` abs(a-b). The corresponding `formUnion`, `formIntersection`, `formDifference`, and `formSymmetricDifference` methods mutate this value. These are multiset semantics; the type does not conform to the standard `SetAlgebra` protocol.

## Iterating over Elements

Normal iteration is ascending. `sorted()` and `reversed()` return ascending and descending arrays. `filter(_:)` returns a new multiset, retaining selected duplicates. Range views traverse in the same order.

```swift
let numbers: RedBlackTreeMultiSet = [7, 2, 9, 2, 1, 5]

for number in numbers {
  print(number)
}
```

```text
1
2
2
5
7
9
```

## Indices and Bound Expressions

An index represents an element position, not an integer offset. Indices support forward and backward movement within their endpoint preconditions. Inserting or deleting other elements preserves an index while its element exists. Deleting that element invalidates the index; reusing its slot does not revive it. In the normal configuration, corresponding positions can be shared across copy-on-write branches, but validity depends on the target’s generation and deletion state. Using an unrelated tree’s index violates a precondition and is not guaranteed to be detected.

Index-range subscripting returns a view without copying elements into an array. It uses the base’s index type but has its own range and endpoint. A view endpoint can identify an element in the base. Mutation directly through a subscript changes the base; mutation of a view stored separately is isolated through copy-on-write. `containsSubrange(_:)` checks a range, and `distance(from:to:)` accepts indices or bounds.

`Bound` specifies positions without directly manipulating indices. It provides `.start`, `.last`, `.end`, `.lowerBound`, `.upperBound`, `.find`, `.lessThan` / `.lessThanOrEqual`, `.greaterThan` / `.greaterThanOrEqual`, `.before` / `.after`, and `.advanced(by:limit:)`. A single bound that resolves to the end or no position returns `nil` through subscripting. Invalid or reversed bound ranges return empty views.

```swift
var set: RedBlackTreeMultiSet<Int> = [1, 1, 3, 4, 5]
print(set[.start.advanced(by: 1)]) // Optional containing 1
```

```swift
var set: RedBlackTreeMultiSet<Int> = [1, 1, 3, 4, 5]
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
| Lookup and removal/processing of K matching elements | O(log n + K) |
| `insert(contentsOf:)`, `inserting(contentsOf:)` (n incoming, m existing) | O(n log(m+n)), plus storage-copy costs |
| `meld`, `melding` | O(n+m), new storage |
| Union, intersection, difference, symmetric difference | O(n+m) |


## Red-Black Tree

A red-black tree is a self-balancing binary search tree that maintains logarithmic height through recoloring and rotations. Logical element order differs from physical memory layout. In duplicate-supporting types, each element still occupies its own node. Nodes are managed in grouped storage rather than requiring a separate allocation for every node.

## Important

This type is not thread-safe and does not protect concurrent access to the same variable. This guide describes the normal configuration.
