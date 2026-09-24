<!-- RedBlackTreeMultiMap.ja.md is the canonical source. RedBlackTreeMultiMap.md is its English translation. -->

# RedBlackTreeMultiMap

English | [日本語](RedBlackTreeMultiMap.ja.md)

A red-black-tree-based dictionary that keeps its keys in ascending order and allows multiple values to be associated with the same key.

## Declaration

```swift
import RedBlackTreeCollections

struct RedBlackTreeMultiMap<Key: Comparable, Value>
```

## Overview

`RedBlackTreeMultiMap` is a collection that can associate multiple values with a single key,
while always maintaining all elements in ascending key order.

Conceptually, it can store elements such as:

```text
("apple", 100)
("apple", 120)
("banana", 80)
("orange", 150)
("orange", 180)
```

Unlike `RedBlackTreeDictionary`,
it can store multiple elements with the same key at the same time.

`RedBlackTreeMultiMap` uses a red-black tree, a type of balanced binary search tree.

This allows it to search for, insert, and remove elements by key in logarithmic time,
while traversing all elements in sorted key order.

`RedBlackTreeMultiMap` is particularly useful when you need to:

- associate multiple values with a single key
- efficiently find all elements with the same key
- dynamically insert and remove elements while maintaining key order
- efficiently find the first element whose key is greater than or equal to a specified key, or strictly greater than it
- process elements whose keys fall within a specified range
- traverse elements in ascending or descending key order

If each key only needs to be associated with a single value,
use `RedBlackTreeDictionary` instead.

## Multiple Values for a Key

`RedBlackTreeMultiMap` can store multiple elements whose keys are considered equivalent by their ordering comparison.

For example, a single collection can conceptually store:

```text
1 → "red"
1 → "green"
1 → "blue"
2 → "orange"
3 → "purple"
3 → "yellow"
```

Elements with the same key are stored as independent elements.

The ordering comparison of the keys does not define any ordering between their associated values.

`Value` does not need to conform to `Comparable`,
and the placement of elements in the red-black tree is determined by key order.

If each key only needs to store a single value,
use `RedBlackTreeDictionary` instead.

## Sorted Iteration

When iterating over a `RedBlackTreeMultiMap` in its normal order,
elements appear in ascending key order.

Conceptually, if the collection contains elements such as:

```text
(3, "C")
(1, "A")
(2, "B")
(1, "D")
```

iteration visits them in key order:

```text
(1, "A")
(1, "D")
(2, "B")
(3, "C")
```

Elements do not need to be extracted into an array and sorted beforehand.
The collection's structure always maintains key ordering.

Elements with the same key appear consecutively in the sorted sequence.

This is particularly useful when elements are repeatedly inserted and removed
while they need to be processed in key order.

## Ordered Lookup

Because a red-black tree performs searches using key ordering,
it can efficiently perform not only simple key lookups, but also ordered searches.

For example, you can query:

- whether an element with a specified key exists
- the first element with a specified key
- the range containing all elements with a specified key
- the first element whose key is greater than or equal to a specified key
- the first element whose key is strictly greater than a specified key
- the elements whose keys fall within a specified range
- the element immediately before or after a specified position

In particular, when working with multiple elements that share the same key,
combining lower-bound and upper-bound searches allows you to efficiently find
the range containing all elements for that key.

Conceptually, for key `2`:

```text
lowerBound(2)
    ↓
[2:A, 2:B, 2:C]
                ↑
           upperBound(2)
```

These searches do not need to linearly scan elements from the beginning.

Because the height of a red-black tree is logarithmically bounded with respect to the number of elements,
key-based searches have a worst-case complexity of O(log `count`).

## Keys and Values

An element of `RedBlackTreeMultiMap` is treated as a key-value pair.

The key determines the element's position in the red-black tree
and defines the ordering between elements.

The value is data associated with the key
and does not participate in tree ordering.

Therefore,

```swift
Key: Comparable
```

is required, while `Value` does not have a corresponding ordering constraint.

This is an important distinction from a simple
`RedBlackTreeSet<(Key, Value)>`,
where both the key and value could participate in ordering.

## Indices

A `RedBlackTreeMultiMap` index represents a logical position
within the sequence of elements ordered by key.

Even when multiple elements have the same key,
each element occupies a distinct position.

Using indices, you can move from one element to the next or previous element.

Because elements in a red-black tree are not necessarily stored in a contiguous array,
indices are not integer offsets.

This differs from `Array`.

Operations that modify the collection may invalidate existing indices.
An invalidated index must not be reused later.

In particular, after removing an element, an index that referred to the removed element
can no longer be used.

## Multimap Operations

As a dictionary that allows duplicate keys,
`RedBlackTreeMultiMap` provides basic operations such as key lookup, insertion, and removal.

Adding an element with a key that is already present does not replace an existing value.
Instead, it can be stored as a new independent element.

For example, conceptually, starting with:

```text
1 → "A"
2 → "B"
```

and adding:

```text
1 → "C"
```

results in:

```text
1 → "A"
1 → "C"
2 → "B"
```

Adding elements automatically preserves key order.

## Performance

`RedBlackTreeMultiMap` uses a red-black tree,
whose height is logarithmically bounded with respect to the number of elements.

The complexities of representative operations are as follows:

| Operation | Complexity |
| --- | ---: |
| `isEmpty` | O(1) |
| `count` | O(1) |
| `startIndex` | O(1) |
| `endIndex` | O(1) |
| Key lookup | O(log `count`) |
| Lower-bound lookup | O(log `count`) |
| Upper-bound lookup | O(log `count`) |
| Element insertion | O(log `count`) |
| Element removal | O(log `count`) |

These complexities follow from the structure of the red-black tree itself.

Processing all elements with the same key additionally requires time proportional
to the number of elements associated with that key.

For example, if a key is associated with `m` values,
finding its range and processing all of its elements takes
O(log `count` + `m`) time.

Actual execution time also depends on factors such as the comparison cost of `Key`
and memory-access characteristics.

In particular, if comparing `Key` values does not take constant time,
the actual cost of comparison is also reflected in search, insertion, and removal operations.

## Red-Black Tree

A red-black tree is a type of self-balancing binary search tree.

Each element is arranged according to key ordering,
and the tree maintains its balance during insertion and removal through node recoloring and rotations.

This prevents the tree from becoming excessively skewed due to a particular insertion order,
keeping the worst-case complexity of search, insertion, and removal at O(log `count`).

The cost of the rebalancing work associated with insertions and removals is amortized O(1).

This distinguishes red-black trees from ordinary binary search trees that do not perform balancing.

## Implementation Details

`RedBlackTreeMultiMap` manages each key-value pair as a node in a red-black tree.

Elements with the same key are also stored as independent nodes.

Because ordering in the red-black tree is determined by keys,
all elements with the same key form a contiguous range in sorted order.

Rather than performing an independent heap allocation for every node,
multiple nodes are stored together in shared storage.

Compared with implementations that allocate each node individually,
this reduces per-node allocation overhead.

The node metadata and the stored key-value pair are also placed close to each other in memory.

This is designed to improve memory-access efficiency during traversal
while retaining the node-based structure required by the red-black tree.

However, unlike `Array`, the elements are not all stored in a single contiguous buffer.

As a result, `RedBlackTreeMultiMap` has different performance characteristics from contiguous arrays.

## Choosing a Collection

Different dictionary types are suited to different use cases.

The standard library's `Dictionary` is suitable when each key is associated with a single value
and fast key lookup is the primary concern.

`RedBlackTreeDictionary` is suitable when each key is associated with a single value
while key ordering needs to be maintained and ordered searches are required.

`RedBlackTreeMultiMap` is suitable when multiple values need to be associated with the same key
while maintaining key order and supporting key-range searches.

If you only need to group multiple values by key,
and do not need each key-value pair to behave as an independent sorted element,
a representation such as `Dictionary<Key, [Value]>` may be more appropriate.
