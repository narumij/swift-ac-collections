<!-- RedBlackTreeMultiSet.ja.md is the canonical source. RedBlackTreeMultiSet.md is its English translation. -->

# RedBlackTreeMultiSet

English | [日本語](RedBlackTreeMultiSet.ja.md)

A red-black-tree-based set that keeps its elements in ascending order and allows duplicate values.

## Declaration

```swift
import RedBlackTreeCollections

struct RedBlackTreeMultiSet<Element: Comparable>
```

## Overview

`RedBlackTreeMultiSet` is a set that can store duplicate elements while always maintaining them in ascending order.

```swift
let numbers: RedBlackTreeMultiSet = [5, 2, 4, 2, 1, 3, 3]

print(numbers)
// [1, 2, 2, 3, 3, 4, 5]
```

Unlike `RedBlackTreeSet`, it can store multiple elements with the same value.

`RedBlackTreeMultiSet` uses a red-black tree, a type of balanced binary search tree.

This allows it to search for, insert, and remove elements in logarithmic time,
while always traversing all elements in sorted order.

`RedBlackTreeMultiSet` is particularly useful when you need to:

- maintain duplicate values while keeping all elements sorted
- dynamically insert and remove elements while preserving their multiplicities
- efficiently find the first element greater than or equal to a specified value, or strictly greater than it
- efficiently find the range of elements with a particular value
- traverse elements in ascending or descending order
- work with an ordered multiset while repeatedly inserting and removing elements

If you do not need to store duplicate elements, use `RedBlackTreeSet` instead.

## Duplicate Elements

`RedBlackTreeMultiSet` can store multiple elements that are considered equivalent by their ordering comparison.

```swift
let numbers: RedBlackTreeMultiSet = [3, 1, 2, 3, 2, 1]

print(numbers)
// [1, 1, 2, 2, 3, 3]
```

When the same value is inserted multiple times, each occurrence is stored as an independent element.

If you do not need to store duplicate elements, use `RedBlackTreeSet` instead.

## Sorted Iteration

When iterating over a `RedBlackTreeMultiSet` in its normal order,
elements always appear in ascending order.

```swift
let numbers: RedBlackTreeMultiSet = [7, 2, 9, 2, 1, 5]

for number in numbers {
  print(number)
}
```

Output:

```text
1
2
2
5
7
9
```

There is no need to first extract the elements into an array and sort them.
The collection's structure always maintains the elements in sorted order.

Elements with the same value appear consecutively in the sorted order.

This is particularly useful when elements are repeatedly inserted and removed
while they need to be processed in sorted order each time.

## Ordered Lookup

Because a red-black tree performs searches using the ordering between elements,
it can efficiently perform not only simple value lookups, but also ordered searches.

For example, you can query:

- whether a specified value exists
- the first element greater than or equal to a specified value
- the first element strictly greater than a specified value
- the range containing all elements equal to a specified value
- the element immediately before or after a specified position

In particular, when working with duplicate elements,
combining lower-bound and upper-bound searches allows you to efficiently find
the range of elements with the same value.

These operations do not need to linearly scan elements from the beginning.

Because the height of a red-black tree is logarithmically bounded with respect to the number of elements,
value-based searches have a worst-case complexity of O(log `count`).

## Indices

A `RedBlackTreeMultiSet` index represents a logical position within the sorted sequence of elements.

Even when multiple elements have the same value,
each element occupies a distinct position.

Using indices, you can move from one element to the next or previous element.

Because elements in a red-black tree are not necessarily stored in a contiguous array,
indices are not integer offsets.

This differs from `Array`.

Operations that modify the set may invalidate existing indices.
An invalidated index must not be reused later.

In particular, after removing an element, an index that referred to the removed element
can no longer be used.

## Multiset Operations

As a set that allows duplicate elements, `RedBlackTreeMultiSet` provides basic operations
such as value lookup, insertion, and removal.

```swift
var numbers: RedBlackTreeMultiSet = [1, 3, 3, 5]

numbers.insert(3)
// [1, 3, 3, 3, 5]

numbers.insert(4)
// [1, 3, 3, 3, 4, 5]
```

Adding an element automatically preserves the collection's sorted order.

Inserting a value that is already present adds another element with the same value.

## Performance

`RedBlackTreeMultiSet` uses a red-black tree,
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

`RedBlackTreeMultiSet` manages each element as a node in a red-black tree.

Elements with the same value are also stored as independent nodes.

Rather than performing an independent heap allocation for every node,
multiple nodes are stored together in shared storage.

Compared with implementations that allocate each node individually,
this reduces per-node allocation overhead.

The node metadata and the stored value are also placed close to each other in memory.

This is designed to improve memory-access efficiency during traversal
while retaining the node-based structure required by the red-black tree.

However, unlike `Array`, the elements are not all stored in a single contiguous buffer.

As a result, `RedBlackTreeMultiSet` has different performance characteristics from contiguous arrays.

## Choosing a Collection

Different collection types are suited to different use cases.

`Set` is suitable when element ordering and duplicate values are not required
and fast membership testing is the primary concern.

`Array` is suitable when you need contiguous storage and fast random access through integer indices.

`RedBlackTreeSet` is suitable when duplicate values are not allowed
and you need to repeatedly insert and remove elements while maintaining sorted order.

`RedBlackTreeMultiSet` is suitable when you need to retain duplicate elements
while maintaining sorted order and performing searches based on value ordering.
