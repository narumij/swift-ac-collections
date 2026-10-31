// Copyright (c) 2026 narumij.
// Licensed under the Apache License v2.0.
// SPDX-License-Identifier: Apache-2.0

// API reference: Swift Collections SortedDictionary, commit
// 7b371ce850bbca30f7dbd05ea1e38897c5e1f0e1.
// https://github.com/apple/swift-collections/tree/7b371ce850bbca30f7dbd05ea1e38897c5e1f0e1/Sources/SortedCollections/SortedDictionary
// These implementations compose this library's operations, not Apple's B-tree.
// Existing updateValue, index(forKey:), filter, mapValues and grouping are reused.

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeDictionary {
    /// Removes the first `k` elements in ascending order.
    ///
    /// - Precondition: `k` is between zero and `count`, inclusive.
    @inlinable
    public mutating func removeFirst(_ k: Int) {
      precondition(k >= 0 && k <= count, "Invalid removal count")
      guard k > 0 else { return }
      let end = index(startIndex, offsetBy: k)
      erase(startIndex..<end)
    }

    /// Removes the last `k` elements in ascending order.
    ///
    /// - Precondition: `k` is between zero and `count`, inclusive.
    @inlinable
    public mutating func removeLast(_ k: Int) {
      precondition(k >= 0 && k <= count, "Invalid removal count")
      guard k > 0 else { return }
      let start = index(endIndex, offsetBy: -k)
      erase(start..<endIndex)
    }


    /// Creates a dictionary, keeping the last value for each equivalent key.
    /// The existing key is retained when an equivalent key occurs again.
    @inlinable
    public init<S: Sequence>(keysWithValues pairs: S) where S.Element == (Key, Value) {
      self.init(pairs, uniquingKeysWith: { _, new in new })
    }

    /// Creates a dictionary, keeping the last key-value pair for each equivalent key.
    /// Matches Apple's labeled-tuple overload, which replaces the key as well.
    @inlinable
    public init<S: Sequence>(keysWithValues pairs: S) where S.Element == (key: Key, value: Value) {
      self.init()
      for pair in pairs {
        update(pair, hint: endIndex)
      }
    }

    /// Creates a dictionary from strictly ascending, unique keys in linear time.
    /// - Precondition: Each key is strictly greater than its predecessor.
    @inlinable
    public init<S: Sequence>(sortedKeysWithValues pairs: S) where S.Element == (Key, Value) {
      var previous: Key?
      self.init(uniqueKeysWithValues: pairs.lazy.map { pair in
        if let previous { precondition(previous < pair.0, "Keys must be strictly ascending") }
        previous = pair.0
        return pair
      })
    }

    /// Creates a dictionary from strictly ascending, unique keys in linear time.
    /// - Precondition: Each key is strictly greater than its predecessor.
    @inlinable
    public init<S: Sequence>(sortedKeysWithValues pairs: S) where S.Element == (key: Key, value: Value) {
      self.init(sortedKeysWithValues: pairs.lazy.map { ($0.key, $0.value) })
    }

    /// Updates a value in place and returns the closure's result.
    /// The default is evaluated only for a missing key. If the closure throws,
    /// a missing key is not inserted; changes to an existing value remain applied.
    @inlinable
    public mutating func modifyValue<R>(
      forKey key: Key,
      default defaultValue: @autoclosure () -> Value,
      _ body: (inout Value) throws -> R
    ) rethrows -> R {
      if index(forKey: key) != nil {
        return try body(&self[key, default: defaultValue()])
      }
      var value = defaultValue()
      let result = try body(&value)
      updateValue(value, forKey: key)
      return result
    }
  }

  // As in SortedSetAPI: Apple's removeSubrange is internal, and it has no
  // removeAll(where:). These public wrappers follow Swift removal naming.
  extension RedBlackTreeDictionary {
    /// Removes the members selected by a valid, ascending index range.
    @inlinable
    public mutating func removeSubrange(_ bounds: IndexRange) {
      erase(bounds)
    }

    /// Removes the members selected by a valid index range expression.
    @inlinable
    public mutating func removeSubrange(_ bounds: IndexRangeExpression) {
      erase(bounds)
    }

    /// Removes all members.
    @inlinable
    public mutating func removeSubrange(_ bounds: UnboundedRange) {
      erase(bounds)
    }

    /// Removes each member for which `shouldBeRemoved` returns `true`.
    /// If the predicate throws, earlier removals remain applied, as with `erase(where:)`.
    @inlinable
    public mutating func removeAll(where shouldBeRemoved: (Element) throws -> Bool) rethrows {
      try erase(where: shouldBeRemoved)
    }
  }
#endif
