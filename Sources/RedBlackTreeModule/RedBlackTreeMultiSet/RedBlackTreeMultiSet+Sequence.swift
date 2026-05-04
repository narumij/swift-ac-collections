//
//  RedBlackTreeMultiSet+Sequence.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/05/05.
//

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiSet {

    /// - Complexity: O(*n*)
    @inlinable
    public func filter(
      _ isIncluded: (Element) throws -> Bool
    ) rethrows -> Self {
      .init(__tree_: try __tree_.___filter(_start, _end, isIncluded))
    }
  }
#endif

// MARK: - Collection Conformance
// MARK: - Sequence
// MARK: - Collection
// MARK: - BidirectionalCollection

extension RedBlackTreeMultiSet: Sequence {}

extension RedBlackTreeMultiSet {

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public func makeIterator() -> Tree._PayloadValues {
    .init(start: _sealed_start, end: _sealed_end, tie: __tree_.tied)
  }
}

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiSet {

    /// - Complexity: O(*n*)
    @inlinable
    @inline(__always)
    public func sorted() -> [Element] {
      __tree_.___copy_all_to_array()
    }

    /// - Complexity: O(`count`)
    @inlinable
    @inline(__always)
    public func reversed() -> [Element] {
      __tree_.___rev_copy_all_to_array()
    }
  }
#endif

// MARK: -

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiSet {
    public typealias SubSequence = RedBlackTreeKeyOnlyRangeView<Self>
  }
#endif
