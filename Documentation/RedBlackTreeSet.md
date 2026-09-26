<!-- RedBlackTreeSet.ja.md is the canonical source. RedBlackTreeSet.md is its English translation. -->

# RedBlackTreeSet

English | [日本語](RedBlackTreeSet.ja.md)

A red-black-tree-based set that keeps its elements in ascending order.

## Declaration

```swift
import RedBlackTreeCollections

struct RedBlackTreeSet<Element: Comparable>
```

## Overview

`RedBlackTreeSet` is a set that stores at most one instance of each element and always maintains its elements in ascending order.

```swift
let numbers: RedBlackTreeSet = [5, 2, 4, 1, 3]

print(numbers)
// [1, 2, 3, 4, 5]
```

Like the standard library's `Set`, it does not store duplicate values.

However, while `Set` manages its elements using a hash table,
`RedBlackTreeSet` uses a red-black tree, a type of balanced binary search tree.

This allows it to search for, insert, and remove elements in logarithmic time,
while always traversing all elements in sorted order.

`RedBlackTreeSet` is particularly useful when you need to:

- dynamically insert and remove elements while keeping them sorted
- find not only whether a value exists, but also the elements immediately before or after it
- efficiently find the first element greater than or equal to a specified value, or strictly greater than it
- traverse elements in ascending or descending order
- work with an ordered set while repeatedly inserting and removing elements

If you only need membership tests and do not make use of element ordering,
the standard library's `Set` may be a better choice.

Hash-table lookups take constant time on average,
while red-black-tree lookups take logarithmic time.

In exchange, `RedBlackTreeSet` efficiently supports ordered searches and sorted traversal,
which hash tables do not directly provide.

## Unique Elements

`RedBlackTreeSet` does not store multiple elements that are considered equivalent by their ordering comparison.

```swift
let numbers: RedBlackTreeSet = [3, 1, 2, 3, 2, 1]

print(numbers)
// [1, 2, 3]
```

If you need to retain duplicate elements, use `RedBlackTreeMultiSet` instead.

## Sorted Iteration

When iterating over a `RedBlackTreeSet` in its normal order,
elements always appear in ascending order.

```swift
let numbers: RedBlackTreeSet = [7, 2, 9, 1, 5]

for number in numbers {
  print(number)
}
```

Output:

```text
1
2
5
7
9
```

There is no need to first extract the elements into an array and sort them.
The collection's structure always maintains the elements in sorted order.

This is particularly useful when elements are repeatedly inserted and removed
while they need to be processed in sorted order each time.

## Ordered Lookup

Because a red-black tree performs searches using the ordering between elements,
it can efficiently perform not only simple value lookups, but also ordered searches.

For example, you can query:

- whether a specified value exists
- the first element greater than or equal to a specified value
- the first element strictly greater than a specified value
- the element immediately before or after a specified position

These operations do not need to linearly scan elements from the beginning.

Because the height of a red-black tree is bounded logarithmically with respect to the number of elements,
value-based searches run in O(log `count`) time.

## Indices

A `RedBlackTreeSet` index represents a logical position within the sorted sequence of elements.

Using indices, you can move from one element to the next or previous element.

Because elements in a red-black tree are not necessarily stored in a contiguous array,
indices are not integer offsets.

This differs from `Array`.

Operations that modify the set may invalidate existing indices.
An invalidated index must not be reused later.

In particular, after removing an element, an index that referred to the removed element
can no longer be used.

## Set Operations

As a set of unique elements, `RedBlackTreeSet` provides basic set operations
such as value lookup, insertion, and removal.

```swift
var numbers: RedBlackTreeSet = [1, 3, 5]

numbers.insert(4)
// [1, 3, 4, 5]

numbers.remove(3)
// [1, 4, 5]
```

Adding an element automatically preserves the collection's sorted order.

Inserting a value that is already present does not add another copy of that value.

## Performance

`RedBlackTreeSet` uses a red-black tree,
whose height is logarithmically bounded with respect to the number of elements.

The complexities of representative operations are as follows:

| Operation | Complexity |
| --- | ---: |
| `isEmpty` | O(1) |
| `count` | O(1) |
| `startIndex` | O(1) |
| `endIndex` | O(1) |
| Value lookup | O(log `count`) |
| Lower-bound lookup | O(log `count`) |
| Upper-bound lookup | O(log `count`) |
| Element insertion | O(log `count`) |
| Element removal | O(log `count`) |

These complexities follow from the structure of the red-black tree itself.

Actual execution time also depends on factors such as the comparison cost of `Element`
and memory-access characteristics.

In particular, if comparing `Element` values does not take constant time,
the actual cost of comparison is also reflected in search, insertion, and removal operations.

## Red-Black Tree

A red-black tree is a type of self-balancing binary search tree.

Each element is arranged according to binary-search-tree ordering,
and the tree maintains its balance during insertion and removal through node recoloring and rotations.

This prevents the tree from becoming excessively skewed due to a particular insertion order,
keeping the worst-case complexity of search, insertion, and removal at O(log `count`).

The cost of the rebalancing work associated with insertions and removals is amortized O(1).

This distinguishes red-black trees from ordinary binary search trees that do not perform balancing.

## Implementation Details

`RedBlackTreeSet` manages each element as a node in a red-black tree.

Rather than performing an independent heap allocation for every node,
multiple nodes are stored together in shared storage.

Compared with implementations that allocate each node individually,
this reduces per-node allocation overhead.

The node metadata and the stored value are also placed close to each other in memory.

This is designed to improve memory-access efficiency during traversal
while retaining the node-based structure required by the red-black tree.

However, unlike `Array`, the elements are not all stored in a single contiguous buffer.

As a result, `RedBlackTreeSet` has different performance characteristics from contiguous arrays.

## Choosing a Collection

Different collection types are suited to different use cases.

`Set` is suitable when element ordering is not required
and fast membership testing is the primary concern.

`Array` is suitable when you need contiguous storage and fast random access through integer indices.

`RedBlackTreeSet` is suitable when you need to repeatedly insert and remove elements
while maintaining sorted order and performing searches based on value ordering.

If you need to keep duplicate values in sorted order,
use `RedBlackTreeMultiSet` instead.
