// Copyright (c) 2026 narumij.
// Licensed under the Apache License v2.0.
// SPDX-License-Identifier: Apache-2.0


#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiMap {


    /// Returns the pairs greater than or equal to the lower bound and less than the upper bound.
    @inlinable
    public subscript(bounds: Range<Key>) -> View {
      self[.lowerBound(bounds.lowerBound) ..< .lowerBound(bounds.upperBound)]
    }

    /// Returns the pairs between the bounds, including both endpoint keys.
    @inlinable
    public subscript(bounds: ClosedRange<Key>) -> View {
      self[.lowerBound(bounds.lowerBound) ..< .upperBound(bounds.upperBound)]
    }

    /// Returns the pairs greater than or equal to the lower bound.
    @inlinable
    public subscript(bounds: PartialRangeFrom<Key>) -> View {
      self[Bound.lowerBound(bounds.lowerBound)...]
    }

    /// Returns the pairs strictly less than the upper bound.
    @inlinable
    public subscript(bounds: PartialRangeUpTo<Key>) -> View {
      self[..<Bound.lowerBound(bounds.upperBound)]
    }

    /// Returns the pairs less than or equal to the upper bound.
    @inlinable
    public subscript(bounds: PartialRangeThrough<Key>) -> View {
      self[..<Bound.upperBound(bounds.upperBound)]
    }
  }

  extension RedBlackTreeMultiMap {

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

    /// Returns the position of the first pair whose key is strictly greater than `key`.
    /// Returns `nil` if no such member exists. The supplied value need not be a member.
    @inlinable
    public func firstIndex(after key: Key) -> Index? {
      let result = upperBound(key)
      return result == endIndex ? nil : result
    }

    /// Returns the position of the last pair whose key is strictly less than `key`.
    /// Returns `nil` if no such member exists. The supplied value need not be a member.
    @inlinable
    public func lastIndex(before key: Key) -> Index? {
      let result = lowerBound(key)
      return result == startIndex ? nil : index(before: result)
    }
  }

  extension RedBlackTreeMultiMap {

    /// Removes the pairs selected by a valid, ascending index range.
    @inlinable
    public mutating func removeSubrange(_ bounds: IndexRange) {
      erase(bounds)
    }

    /// Removes the pairs selected by a valid index range expression.
    @inlinable
    public mutating func removeSubrange(_ bounds: IndexRangeExpression) {
      erase(bounds)
    }

    /// Removes all pairs.
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
  extension RedBlackTreeMultiMap {

    /// Creates a multimap retaining every labeled key-value pair, including duplicate keys.
    @inlinable
    public init<S: Sequence>(keysWithValues pairs: S) where S.Element == (key: Key, value: Value) {
      self.init(keysWithValues: pairs.lazy.map { ($0.key, $0.value) })
    }

    /// Creates a multimap from nondecreasing keys in linear time, retaining duplicates.
    /// - Precondition: No key compares less than its predecessor.
    @inlinable
    public init<S: Sequence>(sortedKeysWithValues pairs: S) where S.Element == (Key, Value) {
      var previous: Key?
      let checked: LazyMapSequence<S, (Key, Value)> = pairs.lazy.map { pair in
        if let previous { precondition(!(pair.0 < previous), "Keys must be nondecreasing") }
        previous = pair.0
        return pair
      }
      self.init(keysWithValues: checked)
    }

    /// Creates a multimap from nondecreasing keys, retaining every labeled pair.
    /// - Precondition: No key compares less than its predecessor.
    @inlinable
    public init<S: Sequence>(sortedKeysWithValues pairs: S) where S.Element == (key: Key, value: Value) {
      self.init(sortedKeysWithValues: pairs.lazy.map { ($0.key, $0.value) })
    }
  }

#endif
