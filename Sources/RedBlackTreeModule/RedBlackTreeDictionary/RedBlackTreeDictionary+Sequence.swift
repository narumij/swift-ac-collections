//
//  RedBlackTreeDictionary+Sequence.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/05/05.
//

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeDictionary {
    public typealias SubSequence = RedBlackTreeKeyValueRangeView<Self>
  }
#endif

// MARK: - Transformation

extension RedBlackTreeDictionary {

  /// - Complexity: O(*n*)
  @inlinable
  public func filter(
    _ isIncluded: (Element) throws -> Bool
  ) rethrows -> Self {
    .init(
      __tree_: try __tree_.___filter(_start, _end) {
        try isIncluded(Base.__element_($0))
      })
  }
}

extension RedBlackTreeDictionary {

  /// - Complexity: O(*n*)
  @inlinable
  public func mapValues<T>(_ transform: (Value) throws -> T) rethrows
    -> RedBlackTreeDictionary<Key, T>
  {
    .init(__tree_: try __tree_.___mapValues(_start, _end, transform))
  }

  /// - Complexity: O(*n*)
  @inlinable
  public func compactMapValues<T>(_ transform: (Value) throws -> T?)
    rethrows -> RedBlackTreeDictionary<Key, T>
  {
    .init(__tree_: try __tree_.___compactMapValues(_start, _end, transform))
  }
}

// MARK: - Sequence Conformance

extension RedBlackTreeDictionary: Sequence {}

extension RedBlackTreeDictionary {

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public func makeIterator() -> Tree._KeyValues {
    .init(start: _sealed_start, end: _sealed_end, tie: __tree_.tied)
  }
}

#if !COMPATIBLE_ATCODER_2025

  extension RedBlackTreeDictionary {

    /// - Complexity: O(`count`)
    @inlinable
    @inline(__always)
    public func sorted() -> [Element] {
      __tree_.___copy_all_to_array(transform: Base.__element_)
    }

    /// - Complexity: O(`count`)
    @inlinable
    @inline(__always)
    public func reversed() -> [Element] {
      __tree_.___rev_copy_all_to_array(transform: Base.__element_)
    }
  }
#endif

// MARK: -

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeDictionary {

    /// - Complexity: O(`count`)
    @inlinable
    @inline(__always)
    public var keys: [Key] {
      __tree_.___copy_all_to_array(transform: Base.__key)
    }

    /// - Complexity: O(`count`)
    @inlinable
    @inline(__always)
    public var values: [Value] {
      __tree_.___copy_all_to_array(transform: Base.___mapped_value)
    }
  }
#endif
