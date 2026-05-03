//
//  RedBlackTreeSet+Sequence.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/05/04.
//

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeSet {

    /// - Complexity: O(*n*)
    @inlinable
    public func filter(
      _ isIncluded: (Element) throws -> Bool
    ) rethrows -> Self {
      .init(__tree_: try __tree_.___filter(_start, _end, isIncluded))
    }
  }
#endif

// MARK: - Sequence

extension RedBlackTreeSet: Sequence {}

extension RedBlackTreeSet {

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public func makeIterator() -> Tree._PayloadValues {
    .init(start: _sealed_start, end: _sealed_end, tie: __tree_.tied)
  }
}

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeSet {

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
  extension RedBlackTreeSet {

    public typealias SubSequence = RedBlackTreeKeyOnlyRangeView<Self>
  }
#endif


// MARK: - Removal

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeSet {

    /// - Complexity: Amortized O(1)
    @inlinable
    public mutating func popFirst() -> Element? {
      __tree_.ensureUnique()
      return ___remove_first()?.payload
    }

    /// - Complexity: O(log `count`)
    @inlinable
    public mutating func popLast() -> Element? {
      __tree_.ensureUnique()
      return ___remove_last()?.payload
    }
  }
#endif

extension RedBlackTreeSet {

  /// - Important: Indices that refer to removed members become invalid.
  /// - Complexity: Amortized O(1)
  @inlinable
  @discardableResult
  public mutating func removeFirst() -> Element {
    __tree_.ensureUnique()
    guard let element = ___remove_first() else {
      preconditionFailure(.emptyFirst)
    }
    return element.payload
  }
}

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeSet {

    /// - Complexity: O(log *n*)
    @inlinable
    @discardableResult
    public mutating func removeLast() -> Element {
      __tree_.ensureUnique()
      guard let element = ___remove_last() else {
        preconditionFailure(.emptyFirst)
      }
      return element.payload
    }
  }
#endif
