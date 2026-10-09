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

extension RedBlackTreeSet: SetAlgebra {

  /// Returns a new set with the elements of both this and the given set.
  ///
  /// - Parameter other: The set to combine with this set.
  /// - Returns: A new set containing the elements from both sets.
  /// - Complexity: O(*n* + *m*), where *n* and *m* are the numbers of elements
  ///   in the two sets.
  @inlinable
  public func union(_ other: __owned RedBlackTreeSet<Element>)
    -> RedBlackTreeSet<Element>
  {
    .init(__tree_: __tree_.___meld_unique(other.__tree_))
  }

  /// Returns a new set with the elements that are common to both this set and the given set.
  ///
  /// - Parameter other: The set to compare with this set.
  /// - Returns: A new set containing the elements present in both sets.
  /// - Complexity: O(*n* + *m*), where *n* and *m* are the numbers of elements
  ///   in the two sets.
  @inlinable
  public func intersection(_ other: RedBlackTreeSet<Element>)
    -> RedBlackTreeSet<Element>
  {
    .init(__tree_: __tree_.___intersection(other.__tree_))
  }

  /// Returns a new set with the elements that are either in this set or in the given set, but not in both.
  ///
  /// - Parameter other: The set to compare with this set.
  /// - Returns: A new set containing the elements present in exactly one set.
  /// - Complexity: O(*n* + *m*), where *n* and *m* are the numbers of elements
  ///   in the two sets.
  @inlinable
  public func symmetricDifference(_ other: __owned RedBlackTreeSet<Element>)
    -> RedBlackTreeSet<Element>
  {
    .init(__tree_: __tree_.___symmetric_difference(other.__tree_))
  }

  /// Adds the elements of the given set to the set.
  ///
  /// - Parameter other: The set whose elements are added.
  /// - Complexity: O(*n* + *m*)
  @inlinable
  public mutating func formUnion(_ other: __owned RedBlackTreeSet<Element>) {
    __tree_ = __tree_.___meld_unique(other.__tree_)
  }

  /// Removes the elements of this set that aren’t also in the given set.
  ///
  /// - Parameter other: The set whose elements are retained.
  /// - Complexity: O(*n* + *m*)
  @inlinable
  public mutating func formIntersection(_ other: RedBlackTreeSet<Element>) {
    __tree_ = __tree_.___intersection(other.__tree_)
  }

  /// Removes the elements of the set that are also in the given set and adds the members of the given set that are not already in the set.
  ///
  /// - Parameter other: The set with which to form the symmetric difference.
  /// - Complexity: O(*n* + *m*)
  @inlinable
  public mutating func formSymmetricDifference(_ other: __owned RedBlackTreeSet<Element>) {
    __tree_ = __tree_.___symmetric_difference(other.__tree_)
  }
}

/*
  __algorithm/set_difference.h に準じた動作となっている。
*/
  extension RedBlackTreeSet {

    /// Returns a new set containing the elements of this set that aren't in another set.
    ///
    /// - Parameter other: The set whose elements are excluded.
    /// - Returns: A new set containing only elements unique to this set.
    /// - Complexity: O(*n* + *m*), where *n* and *m* are the numbers of elements
    ///   in the two sets.
    @inlinable
    public func difference(_ other: __owned RedBlackTreeSet<Element>)
      -> RedBlackTreeSet<Element>
    {
      .init(__tree_: __tree_.___difference(other.__tree_))
    }

    /// Removes from this set every element that also occurs in another set.
    ///
    /// - Parameter other: The set whose elements are removed.
    /// - Complexity: O(*n* + *m*)
    @inlinable
    public mutating func formDifference(_ other: __owned RedBlackTreeSet<Element>) {
      __tree_ = __tree_.___difference(other.__tree_)
    }
  }
