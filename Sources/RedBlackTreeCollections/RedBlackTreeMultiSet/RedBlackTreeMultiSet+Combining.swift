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

// MARK: - Combining MultiSet

extension RedBlackTreeMultiSet {

  /// Inserts every element of `other`, preserving this multiset's existing multiplicities.
  ///
  /// - Parameter other: A set whose elements to insert once each.
  /// - Complexity: O(*n* log(*m + n*)), where *n* is the length of `other`
  ///   and *m* is the size of the current tree.
  @inlinable
  public mutating func insert(contentsOf other: RedBlackTreeSet<Element>) {
    __tree_.ensureUnique()
    __tree_.___insert_range_multi(
      other: other.__tree_,
      other.__tree_.__begin_node_,
      other.__tree_.__end_node)
  }

  /// Inserts every occurrence from `other` into this multiset.
  ///
  /// - Parameter other: A multiset whose occurrences to insert.
  /// - Complexity: O(*n* log(*m + n*)), where *n* is the length of `other`
  ///   and *m* is the size of the current tree.
  ///
  /// - Note: Spare capacity does not make `meld(_:)` preferable; it builds new
  ///   storage. In measurements through 256K elements with disjoint, sorted,
  ///   and shuffled `other`, this method was faster in each case, although the
  ///   construction order of `other` materially affected both operations.
  @inlinable
  public mutating func insert(contentsOf other: RedBlackTreeMultiSet<Element>) {
    __tree_.ensureUnique()
    __tree_.___insert_range_multi(
      other: other.__tree_,
      other.__tree_.__begin_node_,
      other.__tree_.__end_node)
  }

  /// Inserts every element produced by `other`, including duplicate occurrences.
  ///
  /// - Parameter other: A sequence whose elements to insert.
  /// - Complexity: O(*n* log(*m + n*)), where *n* is the length of `other`
  ///   and *m* is the size of the current tree.
  @inlinable
  public mutating func insert<S>(contentsOf other: S) where S: Sequence, S.Element == Element {
    __tree_.ensureUnique()
    __tree_.___insert_range_multi(other) { $0 }
  }

  /// Returns a multiset containing this multiset plus each element of `other` once.
  ///
  /// - Parameter other: A set whose elements to insert into the result.
  /// - Returns: The combined multiset without modifying either input.
  /// - Complexity: O(*n* log(*m + n*)), where *n* is the length of `other`
  ///   and *m* is the size of the current tree.
  @inlinable
  public func inserting(contentsOf other: RedBlackTreeSet<Element>) -> Self {
    var result = self
    result.insert(contentsOf: other)
    return result
  }

  /// Returns a multiset containing every occurrence from both multisets.
  ///
  /// - Parameter other: A multiset whose occurrences to insert into the result.
  /// - Returns: The combined multiset without modifying either input.
  /// - Complexity: O(*n* log(*m + n*)), where *n* is the length of `other`
  ///   and *m* is the size of the current tree.
  ///
  /// - Note: Spare capacity does not make `melding(_:)` preferable; it builds
  ///   new storage. This method copies the current storage before inserting.
  ///   Only the mutating forms were measured: through 256K elements with
  ///   disjoint, sorted, and shuffled `other`, `insert(contentsOf:)` was faster
  ///   than `meld(_:)` in each case.
  @inlinable
  public func inserting(contentsOf other: RedBlackTreeMultiSet<Element>) -> Self {
    var result = self
    result.insert(contentsOf: other)
    return result
  }

  /// Returns a multiset containing this multiset and every element produced by `other`.
  ///
  /// - Parameter other: A sequence whose elements to insert into the result.
  /// - Returns: The combined multiset without modifying this multiset.
  /// - Complexity: O(*n* log(*m + n*)), where *n* is the length of `other`
  ///   and *m* is the size of the current tree.
  @inlinable
  public func inserting<S>(contentsOf other: __owned S) -> Self
  where S: Sequence, S.Element == Element {
    var result = self
    result.insert(contentsOf: other)
    return result
  }
}

extension RedBlackTreeMultiSet {

  /// Combines two multisets while preserving every occurrence.
  ///
  /// This operation consumes `other` and replaces this multiset with the result.
  ///
  /// - Parameter other: The multiset to consume and combine.
  /// - Complexity: O(*n* + *m*)
  @inlinable
  public mutating func meld(_ other: __owned RedBlackTreeMultiSet<Element>) {
    __tree_ = __tree_.___meld_multi(other.__tree_)
  }

  /// Returns a multiset containing every occurrence from both multisets.
  ///
  /// - Parameter other: The multiset to consume and combine.
  /// - Returns: The combined multiset.
  /// - Complexity: O(*n* + *m*)
  @inlinable
  public func melding(_ other: __owned RedBlackTreeMultiSet<Element>)
    -> RedBlackTreeMultiSet<Element>
  {
    .init(__tree_: __tree_.___meld_multi(other.__tree_))
  }
}
