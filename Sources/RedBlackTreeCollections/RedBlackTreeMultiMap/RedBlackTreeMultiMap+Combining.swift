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

// MARK: - Combining MultiMap

extension RedBlackTreeMultiMap {

  /// Inserts every key-value pair from `other`, including duplicate keys.
  ///
  /// - Parameter other: A multimap whose pairs to insert.
  /// - Complexity: O(*n* log(*m + n*)), where *n* is the length of `other`
  ///   and *m* is the size of the current tree.
  ///
  /// - Note: Spare capacity does not make `meld(_:)` preferable; it builds new
  ///   storage. This method inserts into the existing storage, copying it first
  ///   if it is shared.
  @inlinable
  public mutating func insert(contentsOf other: RedBlackTreeMultiMap<Key, Value>) {
    __tree_.ensureUnique()
    __tree_.___insert_range_multi(
      other: other.__tree_,
      other.__tree_.__begin_node_,
      other.__tree_.__end_node)
  }

  /// Inserts every key-value pair produced by `other`, including duplicate keys.
  ///
  /// - Parameter other: A sequence of key-value pairs to insert.
  /// - Complexity: O(*n* log(*m + n*)), where *n* is the length of `other`
  ///   and *m* is the size of the current tree.
  @inlinable
  public mutating func insert<S>(contentsOf other: S) where S: Sequence, S.Element == (Key, Value) {
    __tree_.ensureUnique()
    __tree_.___insert_range_multi(other) { Base.__payload_($0) }
  }

  /// Returns a multimap containing every pair from this multimap and `other`.
  ///
  /// - Parameter other: A multimap whose pairs to insert into the result.
  /// - Returns: The combined multimap without modifying either input.
  /// - Complexity: O(*n* log(*m + n*)), where *n* is the length of `other`
  ///   and *m* is the size of the current tree.
  ///
  /// - Note: Spare capacity does not make `melding(_:)` preferable; it builds
  ///   new storage. This method copies the current storage before inserting.
  @inlinable
  public func inserting(contentsOf other: RedBlackTreeMultiMap<Key, Value>) -> Self {
    var result = self
    result.insert(contentsOf: other)
    return result
  }

  /// Returns a multimap containing this multimap and every pair produced by `other`.
  ///
  /// - Parameter other: A sequence of key-value pairs to insert into the result.
  /// - Returns: The combined multimap without modifying this multimap.
  /// - Complexity: O(*n* log(*m + n*)), where *n* is the length of `other`
  ///   and *m* is the size of the current tree.
  @inlinable
  public func inserting<S>(contentsOf other: __owned S) -> Self
  where S: Sequence, S.Element == (Key, Value) {
    var result = self
    result.insert(contentsOf: other)
    return result
  }
}

extension RedBlackTreeMultiMap {

  /// Combines two multimaps while preserving every key-value pair.
  ///
  /// This operation consumes `other` and replaces this multimap with the result.
  ///
  /// - Parameter other: The multimap to consume and combine.
  /// - Complexity: O(*n* + *m*)
  @inlinable
  public mutating func meld(_ other: __owned RedBlackTreeMultiMap<Key, Value>) {
    __tree_ = __tree_.___meld_multi(other.__tree_)
  }

  /// Returns a multimap containing every pair from both multimaps.
  ///
  /// - Parameter other: The multimap to consume and combine.
  /// - Returns: The combined multimap.
  /// - Complexity: O(*n* + *m*)
  @inlinable
  public func melding(_ other: __owned RedBlackTreeMultiMap<Key, Value>)
    -> RedBlackTreeMultiMap<Key, Value>
  {
    var result = self
    result.meld(other)
    return result
  }
}
