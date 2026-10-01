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

    public typealias SubSequence = RedBlackTreeKeyValueRangeView<Self>
  }
#endif

// MARK: - Transformation

extension RedBlackTreeMultiMap {

  /// Returns a new multimap containing the key-value pairs of this multimap that satisfy the given predicate.
  ///
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
  /// - Complexity: O(*n*)
  @inlinable
  public func mapValues<T>(_ transform: (Value) throws -> T) rethrows
    -> RedBlackTreeMultiMap<Key, T>
  {
    .init(__tree_: try __tree_.___mapValues(_start, _end, transform))
  }

  /// Returns a new multi map containing only the key-value pairs that have non-nil values as the result of transformation by the given closure.
  ///
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

      // TODO: valuesはViewにして、swapAt可能にすること
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
