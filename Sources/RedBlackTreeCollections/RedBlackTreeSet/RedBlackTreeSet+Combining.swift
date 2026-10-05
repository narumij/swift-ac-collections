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

// MARK: - Combining Set

extension RedBlackTreeSet {

  /// Inserts the elements of `other`, ignoring values equivalent to existing elements.
  ///
  /// - Parameter other: A set whose elements to insert.
  /// - Complexity: O(*n* log(*m + n*)), where *n* is the length of `other`
  ///   and *m* is the size of the current tree.
  ///
  /// - Note: Spare capacity does not make `formUnion(_:)` preferable; it
  ///   builds new storage. In measurements through 256K elements, this method
  ///   was faster for disjoint input, while `formUnion(_:)`
  ///   was faster when 90% of `other` duplicated existing elements.
  @inlinable
  public mutating func merge(_ other: RedBlackTreeSet<Element>) {
    __tree_.ensureUnique()
    __tree_.___insert_range_unique(
      other: other.__tree_,
      other.__tree_.__begin_node_,
      other.__tree_.__end_node)
  }

  /// Inserts the elements of `other`, discarding duplicate occurrences.
  ///
  /// - Parameter other: A multiset whose distinct elements to insert.
  /// - Complexity: O(*n* log(*m + n*)), where *n* is the length of `other`
  ///   and *m* is the size of the current tree.
  @inlinable
  public mutating func merge(_ other: RedBlackTreeMultiSet<Element>) {
    __tree_.ensureUnique()
    __tree_.___insert_range_unique(
      other: other.__tree_,
      other.__tree_.__begin_node_,
      other.__tree_.__end_node)
  }

  /// Inserts the elements of `other`, ignoring values equivalent to existing elements.
  ///
  /// - Parameter other: A sequence whose elements to insert.
  /// - Complexity: O(*n* log(*m + n*)), where *n* is the length of `other`
  ///   and *m* is the size of the current tree.
  @inlinable
  public mutating func merge<S>(_ other: S) where S: Sequence, S.Element == Element {
    __tree_.ensureUnique()
    __tree_.___insert_range_unique(other)
  }

  /// Returns a set containing the elements of this set and `other`.
  ///
  /// Duplicate elements are represented once. Neither input is modified.
  ///
  /// - Parameter other: A set whose elements to merge.
  /// - Returns: The merged set.
  /// - Complexity: O(*n* log(*m + n*)), where *n* is the length of `other`
  ///   and *m* is the size of the current tree.
  ///
  /// - Note: Spare capacity does not make `union(_:)` preferable; it builds
  ///   new storage. This method copies the current storage before inserting.
  ///   In measurements of the mutating forms through 256K elements,
  ///   `merge(_:)` was faster for disjoint input, even when it first copied
  ///   shared storage, while `formUnion(_:)` was faster when 90% of `other`
  ///   duplicated existing elements.
  @inlinable
  public func merging(_ other: RedBlackTreeSet<Element>) -> Self {
    var result: Self = self
    result.merge(other)
    return result
  }

  /// Returns a set containing this set's elements and the distinct elements of `other`.
  ///
  /// - Parameter other: A multiset whose elements to merge.
  /// - Returns: The merged set, with duplicate occurrences represented once.
  /// - Complexity: O(*n* log(*m + n*)), where *n* is the length of `other`
  ///   and *m* is the size of the current tree.
  @inlinable
  public func merging(_ other: RedBlackTreeMultiSet<Element>) -> Self {
    var result = self
    result.merge(other)
    return result
  }

  /// Returns a set containing this set's elements and the elements of `other`.
  ///
  /// - Parameter other: A sequence whose elements to merge.
  /// - Returns: The merged set, with equivalent elements represented once.
  /// - Complexity: O(*n* log(*m + n*)), where *n* is the length of `other`
  ///   and *m* is the size of the current tree.
  @inlinable
  public func merging<S>(_ other: __owned S) -> Self where S: Sequence, S.Element == Element {
    var result = self
    result.merge(other)
    return result
  }
}
