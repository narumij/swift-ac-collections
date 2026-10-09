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

  extension RedBlackTreeDictionary {
    /// A view over a contiguous key-value range in ascending key order.
    public typealias SubSequence = RedBlackTreeKeyValueRangeView<Self>
  }

// MARK: - Transformation

extension RedBlackTreeDictionary {

  /// Returns a new dictionary containing the key-value pairs of the dictionary that satisfy the given predicate.
  ///
  /// - Parameter isIncluded: A closure that returns `true` for a key-value pair to include.
  /// - Returns: A new dictionary containing only the included key-value pairs.
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

  /// Returns a new dictionary containing the keys of this dictionary with the values transformed by the given closure.
  ///
  /// - Parameter transform: A closure that transforms a value.
  /// - Returns: A new dictionary with the same keys and transformed values.
  /// - Complexity: O(*n*)
  @inlinable
  public func mapValues<T>(_ transform: (Value) throws -> T) rethrows
    -> RedBlackTreeDictionary<Key, T>
  {
    .init(__tree_: try __tree_.___mapValues(_start, _end, transform))
  }

  /// Returns a new dictionary containing only the key-value pairs that have non-nil values as the result of transformation by the given closure.
  ///
  /// - Parameter transform: A closure that transforms a value or returns `nil`
  ///   to omit its key-value pair.
  /// - Returns: A new dictionary containing the non-`nil` transformed values
  ///   under their original keys.
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

  /// Returns an iterator over the dictionary’s key-value pairs.
  ///
  /// The iterator visits key-value pairs in sorted key order.
  ///
  /// - Returns: An iterator over the dictionary's key-value pairs.
  /// - Complexity: O(1)
  @inlinable
  public func makeIterator() -> Tree._KeyValues {
      .init(start: _start, end: _end, tree: __tree_)
  }
}


  extension RedBlackTreeDictionary {

    /// Returns the elements of the sequence, sorted.
    ///
    /// - Returns: An array containing every key-value pair in sorted key order.
    /// - Complexity: O(`count`)
    @inlinable
    public func sorted() -> [Element] {
      __tree_.___copy_all_to_array { Base.__element_($0) }
    }

    /// Returns an array containing the elements of this sequence in reverse order.
    ///
    /// - Returns: An array containing every key-value pair in descending key order.
    /// - Complexity: O(`count`)
    @inlinable
    public func reversed() -> [Element] {
      __tree_.___rev_copy_all_to_array { Base.__element_($0) }
    }
  }

// MARK: -

  extension RedBlackTreeDictionary {

      // そもそもCollections適合を捨ててるので、こちらで十分だが、迷っている
      public typealias Keys = RedBlackTreeIterator.Keys<Base>
      //      public typealias Values = RedBlackTreeIteratorV2.MappedValues<Base>

      /// A collection containing just the keys of the dictionary.
      ///
      /// - Complexity: O(`count`)
      @inlinable
      public var keys: Keys {
        .init(start: _start, end: _end, tree: __tree_)
      }

      /// A collection containing just the values of the dictionary.
      ///
      /// - Complexity: O(`count`)
      //      @inlinable
      //      public var values: Values {
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
          self = Self()
          defer { self = Self(__tree_: view.__tree_) }
          yield &view
        }
      }
  }
