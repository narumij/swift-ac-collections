//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-ac-collections project.
//
// Copyright (c) 2024-2026 narumij.
// Licensed under the Apache License v2.0.
//
// SPDX-License-Identifier: Apache-2.0
//
// This implementation includes code derived from LLVM libc++'s red-black tree
// implementation, originally distributed under the Apache License v2.0 with
// LLVM Exceptions.
//
// Copyright © 2003-2026 The LLVM Project.
// Licensed under the Apache License v2.0 with LLVM Exceptions.
// The original license can be found at https://llvm.org/LICENSE.txt
//
// This Swift implementation includes modifications and adaptations made by
// narumij.
//
//===----------------------------------------------------------------------===//

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiMap {

    /// A view over a contiguous key-value range in ascending key order.
    ///
    /// The view preserves every key-value pair in the selected range, including
    /// pairs whose keys compare equal.
    public typealias SubSequence = RedBlackTreeKeyValueRangeView<Self>
  }
#endif

// MARK: - Transformation

extension RedBlackTreeMultiMap {

  /// Returns a new multimap containing the key-value pairs of this multimap that satisfy the given predicate.
  ///
  /// Every included pair is retained, including pairs with equivalent keys.
  ///
  /// - Parameter isIncluded: A closure that returns `true` for a key-value pair to include.
  /// - Returns: A new multimap containing only the included key-value pairs.
  /// - Complexity: O(*n*)
  @inlinable
  public func filter(
    _ isIncluded: (Element) throws -> Bool
  ) rethrows -> Self {
    .init(
      __tree_: try __tree_.___filter(_start, _end) {
        try isIncluded(Base.__element_($0))
      }
    )
  }
}

extension RedBlackTreeMultiMap {

  /// Returns a new multimap containing the keys of this multimap with the values transformed by the given closure.
  ///
  /// Duplicate keys and their multiplicities are preserved.
  ///
  /// - Parameter transform: A closure that transforms a value.
  /// - Returns: A new multimap with the same keys and transformed values.
  /// - Complexity: O(*n*)
  @inlinable
  public func mapValues<T>(_ transform: (Value) throws -> T) rethrows
    -> RedBlackTreeMultiMap<Key, T>
  {
    .init(__tree_: try __tree_.___mapValues(_start, _end, transform))
  }

  /// Returns a new multimap containing only pairs whose transformed value isn't `nil`.
  ///
  /// This operation doesn't collapse duplicate keys: each input pair is transformed
  /// independently, and every non-`nil` result is retained.
  ///
  /// - Parameter transform: A closure that transforms a value or returns `nil`
  ///   to omit its key-value pair.
  /// - Returns: A new multimap containing the non-`nil` transformed values under
  ///   their original keys.
  /// - Complexity: O(*n*)
  @inlinable
  public func compactMapValues<T>(_ transform: (Value) throws -> T?)
    rethrows -> RedBlackTreeMultiMap<Key, T>
  {
    .init(__tree_: try __tree_.___compactMapValues(_start, _end, transform))
  }
}

// MARK: - Sequence Conformance

extension RedBlackTreeMultiMap: Sequence {}

extension RedBlackTreeMultiMap {

  /// Returns an iterator over the multimap’s key-value pairs.
  ///
  /// The iterator visits every pair in sorted key order.
  ///
  /// - Returns: An iterator over the multimap's key-value pairs.
  /// - Complexity: O(1)
  @inlinable
  public func makeIterator() -> Tree._KeyValues {
    #if !COMPATIBLE_ATCODER_2025
      .init(start: _start, end: _end, tree: __tree_)
    #else
      .init(start: _sealed_start, end: _sealed_end, tie: __tree_.tied)
    #endif
  }
}

extension RedBlackTreeMultiMap {

  /// Returns the elements of the sequence, sorted.
  ///
  /// Pairs with equivalent keys occur in the result with their full multiplicity.
  ///
  /// - Returns: An array containing every pair in sorted key order.
  /// - Complexity: O(`count`)
  @inlinable
  public func sorted() -> [Element] {
    __tree_.___copy_all_to_array { Base.__element_($0) }
  }
}

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiMap {

    /// Returns an array containing the elements of this sequence in reverse order.
    ///
    /// Pairs with equivalent keys occur in the result with their full multiplicity.
    ///
    /// - Returns: An array containing every pair in descending key order.
    /// - Complexity: O(`count`)
    @inlinable
    public func reversed() -> [Element] {
      __tree_.___rev_copy_all_to_array { Base.__element_($0) }
    }
  }
#endif

// MARK: -

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiMap {

    #if false
      // 標準に倣うと、Collections適合が必要なのでこちらになる
      public typealias Keys = [Key]
      public typealias Values = [Value]

      /// A collection containing just the keys of the multimap.
      ///
      /// - Complexity: O(`count`)
      @inlinable
      public var keys: [Key] {
        __tree_.___copy_all_to_array(Base.__key_)
      }

      /// A collection containing just the values of the multimap.
      ///
      /// - Complexity: O(`count`)
      @inlinable
      public var values: [Value] {
        __tree_.___copy_all_to_array(Base.__mapped_value_)
      }
    #else
      // そもそもCollections適合を捨ててるので、こちらで十分だが、迷っている
      public typealias Keys = RedBlackTreeIterator.Keys<Base>
      //      public typealias Values = RedBlackTreeIteratorV2.MappedValues<Base>

      /// A collection containing just the keys of the multimap.
      ///
      /// - Complexity: O(`count`)
      @inlinable
      public var keys: UnsafeIterator.KeyObverse<Base> {
        .init(start: _start, end: _end, tree: __tree_)
      }

      /// A collection containing just the values of the multimap.
      ///
      /// - Complexity: O(`count`)
      //      @inlinable
      //      public var values: UnsafeIterator.MappedValueObverse<Base> {
      //        .init(start: _start, end: _end, tree: __tree_)
      //      }

      public typealias Values = RedBlackTreeMappedValuesView<Self>

      @inlinable
      func makeValuesView(range: _NodeRange) -> Values {
        Values(
          __tree_: __tree_,
          _start: range.lowerBound.uncheckedSeal,
          _end: range.upperBound.uncheckedSeal)
      }

      @inlinable
      public var values: Values {
        @inline(__always) get {
          return makeValuesView(range: ___node_range)
        }

        @inline(__always) _modify {
          var view = makeValuesView(range: ___node_range)
          self = Self()  // yield中のCoWキャンセル。考えた人賢い
          defer { self = Self(__tree_: view.__tree_) }
          yield &view
        }
      }
    #endif
  }
#endif
