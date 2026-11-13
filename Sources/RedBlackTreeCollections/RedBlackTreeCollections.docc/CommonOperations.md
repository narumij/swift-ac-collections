# Common Operations

Find the operation you need across the four sorted collection types and their range views.

## Overview

All four collections keep their elements in sorted order. Set and dictionary variants require unique elements or keys, while multiset and multimap variants preserve duplicates.

| Requirement | Collection |
| --- | --- |
| Unique elements | ``RedBlackTreeSet`` |
| Duplicate elements | ``RedBlackTreeMultiSet`` |
| Unique keys and associated values | ``RedBlackTreeDictionary`` |
| Duplicate keys and associated values | ``RedBlackTreeMultiMap`` |

## Finding Elements

Choose a lookup according to the position you need. For dictionaries and multimaps, the lookup argument is a key.

| Operation | Matching position | If no match exists |
| --- | --- | --- |
| `firstIndex(of:)` | First equivalent element or key | `nil` |
| `find(_:)` | An equivalent element or key; not necessarily the first in a multi collection | `endIndex` |
| `lowerBound(_:)` | First element or key not less than the argument | `endIndex` |
| `upperBound(_:)` | First element or key greater than the argument | `endIndex` |
| `equalRange(_:)` | Half-open range containing all equivalent elements or keys | Empty range at the insertion position |

Bound expressions describe these searches without retaining an index. `.first(value)` selects the first equivalent element or key, while `.find(value)` may select another equivalent occurrence in a multi collection.

## Inserting and Updating

Set and dictionary collections reject duplicate elements or keys unless an update or merge operation explicitly resolves the existing value. Multiset and multimap collections retain duplicates. Hint-based insertion accepts an existing index as a search hint; it does not change these uniqueness rules.

## Removing Elements

Swift-style `remove` operations return removed elements or values. The library-specific `erase` operations also support index ranges, bound expressions, predicate-based removal, and returning the next index for sequential removal.

For multi collections, `eraseUnique(_:)` removes one equivalent element, while `eraseMulti(_:)` removes every equivalent element and returns the number removed.

## Working with Ranges

Set and multiset ranges produce ``RedBlackTreeKeyOnlyRangeView``. Dictionary and multimap ranges produce ``RedBlackTreeKeyValueRangeView``, whose `values` property provides a mutable ``RedBlackTreeMappedValuesView``.

An index range is already resolved against a particular tree. A bound expression describes a position using an element or key and is resolved when the operation is performed. Prefer bound expressions when an operation does not otherwise need to retain an index.

> Important: A range view has its own `endIndex`. Use the view's `isElement(at:)` and `isEnd(_:)` methods when validating an index for that view.

## Mutating Through a View

Mutating through a collection's range subscript updates that collection. Storing the view in a separate variable gives it independent value semantics: mutating the stored view leaves the original collection unchanged.

```swift
var set: RedBlackTreeSet<Int> = [1, 3, 5, 7]
var view = set[.lowerBound(3) ..< .lowerBound(7)]
view.erase()
// view is empty; set still contains [1, 3, 5, 7].

set[.lowerBound(3) ..< .lowerBound(7)].erase()
// set now contains [1, 7].
```

The same distinction applies to `values`. For example, `dictionary.values[i] = value` updates the dictionary, whereas mutating `var values = dictionary.values` updates only that stored view. When `values` belongs to a range view, a mutation through the property updates that range view.
