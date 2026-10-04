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

Use `find(_:)`, `firstIndex(of:)`, `lowerBound(_:)`, `upperBound(_:)`, or `equalRange(_:)` to locate elements or keys. `equalRange(_:)` is especially useful with ``RedBlackTreeMultiSet`` and ``RedBlackTreeMultiMap`` because it covers every equivalent element or key.

## Inserting and Updating

Set and dictionary collections reject duplicate elements or keys unless an update or merge operation explicitly resolves the existing value. Multiset and multimap collections retain duplicates. Hint-based insertion accepts an existing index as a search hint; it does not change these uniqueness rules.

## Removing Elements

Swift-style `remove` operations return removed elements or values. The library-specific `erase` operations also support index ranges, bound expressions, predicate-based removal, and returning the next index for sequential removal.

For multi collections, `eraseUnique(_:)` removes one equivalent element, while `eraseMulti(_:)` removes every equivalent element and returns the number removed.

## Working with Ranges

Set and multiset ranges produce ``RedBlackTreeKeyOnlyRangeView``. Dictionary and multimap ranges produce ``RedBlackTreeKeyValueRangeView``, whose `values` property provides a mutable ``RedBlackTreeMappedValuesView``.

An index range is already resolved against a particular tree. A bound expression describes a position using an element or key and is resolved when the operation is performed. Prefer bound expressions when an operation does not otherwise need to retain an index.

> Important: A range view has its own `endIndex`. Use the view's `isElement(at:)` and `isEnd(_:)` methods when validating an index for that view.

