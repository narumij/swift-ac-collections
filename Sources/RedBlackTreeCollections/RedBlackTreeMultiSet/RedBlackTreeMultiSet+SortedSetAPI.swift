// Copyright (c) 2026 narumij.
// Licensed under the Apache License v2.0.
// SPDX-License-Identifier: Apache-2.0

// API naming reference: Swift Collections SortedSet, commit
// 7b371ce850bbca30f7dbd05ea1e38897c5e1f0e1, Sources/SortedCollections/SortedSet.
// https://github.com/apple/swift-collections/tree/7b371ce850bbca30f7dbd05ea1e38897c5e1f0e1/Sources/SortedCollections/SortedSet
// Implementations below compose this library's existing operations; they do not
// copy Apple's B-tree implementation or its index invalidation rules.

// MultiSet adaptation of RedBlackTreeSet+SortedSetAPI.swift.
// Ranges include all duplicates at included endpoints. Strict before/after
// searches skip all elements equal to the supplied value.
#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiSet {

    // Value endpoints need not be present in the set. Resolve them through the
    // existing bound expressions. These subscripts expose read-only views.

    /// Returns the members greater than or equal to the lower bound and less than the upper bound.
    @inlinable
    public subscript(bounds: Range<Element>) -> View {
      self[.lowerBound(bounds.lowerBound) ..< .lowerBound(bounds.upperBound)]
    }

    /// Returns the members between the bounds, including both endpoint values.
    @inlinable
    public subscript(bounds: ClosedRange<Element>) -> View {
      self[.lowerBound(bounds.lowerBound) ..< .upperBound(bounds.upperBound)]
    }

    /// Returns the members greater than or equal to the lower bound.
    @inlinable
    public subscript(bounds: PartialRangeFrom<Element>) -> View {
      self[Bound.lowerBound(bounds.lowerBound)...]
    }

    /// Returns the members strictly less than the upper bound.
    @inlinable
    public subscript(bounds: PartialRangeUpTo<Element>) -> View {
      self[..<Bound.lowerBound(bounds.upperBound)]
    }

    /// Returns the members less than or equal to the upper bound.
    @inlinable
    public subscript(bounds: PartialRangeThrough<Element>) -> View {
      self[..<Bound.upperBound(bounds.upperBound)]
    }
  }

  extension RedBlackTreeMultiSet {

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

    /// Returns the position of the smallest member strictly greater than `element`.
    /// Returns `nil` if no such member exists. The supplied value need not be a member.
    @inlinable
    public func firstIndex(after element: Element) -> Index? {
      let result = upperBound(element)
      return result == endIndex ? nil : result
    }

    /// Returns the position of the largest member strictly less than `element`.
    /// Returns `nil` if no such member exists. The supplied value need not be a member.
    @inlinable
    public func lastIndex(before element: Element) -> Index? {
      let result = lowerBound(element)
      return result == startIndex ? nil : index(before: result)
    }
  }

  // Swift-style removal names over the existing erase operations.
  // Apple's compared SortedSet has internal removeSubrange, but no
  // removeAll(where:). These are adaptations, not copies of public Apple APIs.
  extension RedBlackTreeMultiSet {

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
