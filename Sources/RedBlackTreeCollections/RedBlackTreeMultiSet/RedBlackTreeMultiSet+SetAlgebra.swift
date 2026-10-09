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

/*
  __algorithm/set_union.h
  __algorithm/set_difference.h
  __algorithm/set_intersect.h
  __algorithm/set_symmetric_difference.h
  に準じた動作となっている。
  SwiftのSetAlgebraプロトコルがmulti_setを想定しているか不明なので、プロトコル適合はしていない。
 (swift-collectionsのissuesに対応してないと明言されていた)
*/

extension RedBlackTreeMultiSet {

  /// Returns a multiset formed by adding the multiplicities in two multisets.
  ///
  /// If an element occurs *a* times in this multiset and *b* times in `other`,
  /// it occurs *a + b* times in the result.
  ///
  /// - Parameter other: The multiset to combine with this multiset.
  /// - Returns: A new multiset containing all occurrences from both operands.
  /// - Complexity: O(*n* + *m*)
  @inlinable
  public func union(_ other: __owned RedBlackTreeMultiSet<Element>)
    -> RedBlackTreeMultiSet<Element>
  {
    .init(__tree_: __tree_.___meld_multi(other.__tree_))
  }

  /// Adds every occurrence from another multiset to this multiset.
  ///
  /// Multiplicities from the two operands are added.
  ///
  /// - Parameter other: The multiset whose occurrences are added.
  /// - Complexity: O(*n* + *m*)
  @inlinable
  public mutating func formUnion(_ other: __owned RedBlackTreeMultiSet<Element>) {
    __tree_ = __tree_.___meld_multi(other.__tree_)
  }
}

extension RedBlackTreeMultiSet {

  /// Returns the symmetric difference of two multisets.
  ///
  /// For each element, the result keeps the absolute difference between the
  /// two multiplicities.
  ///
  /// - Parameter other: The multiset to compare with this multiset.
  /// - Returns: A new multiset containing the unmatched occurrences.
  /// - Complexity: O(*n* + *m*)
  @inlinable
  public func symmetricDifference(_ other: __owned RedBlackTreeMultiSet<Element>)
    -> RedBlackTreeMultiSet<Element>
  {
    .init(__tree_: __tree_.___symmetric_difference(other.__tree_))
  }

  /// Replaces this multiset with its symmetric difference with another multiset.
  ///
  /// For each element, the result keeps the absolute difference between the
  /// two multiplicities.
  ///
  /// - Parameter other: The multiset with which to form the symmetric difference.
  /// - Complexity: O(*n* + *m*)
  @inlinable
  public mutating func formSymmetricDifference(_ other: __owned RedBlackTreeMultiSet<Element>) {
    __tree_ = __tree_.___symmetric_difference(other.__tree_)
  }
}

extension RedBlackTreeMultiSet {

  /// Returns the intersection of two multisets.
  ///
  /// For each element, the result keeps the lesser of the two multiplicities.
  ///
  /// - Parameter other: The multiset to intersect with this multiset.
  /// - Returns: A new multiset containing the common occurrences.
  /// - Complexity: O(*n* + *m*)
  @inlinable
  public func intersection(_ other: RedBlackTreeMultiSet<Element>)
    -> RedBlackTreeMultiSet<Element>
  {
    .init(__tree_: __tree_.___intersection(other.__tree_))
  }

  /// Replaces this multiset with its intersection with another multiset.
  ///
  /// For each element, the result keeps the lesser of the two multiplicities.
  ///
  /// - Parameter other: The multiset whose occurrences are retained.
  /// - Complexity: O(*n* + *m*)
  @inlinable
  public mutating func formIntersection(_ other: RedBlackTreeMultiSet<Element>) {
    __tree_ = __tree_.___intersection(other.__tree_)
  }
}

  extension RedBlackTreeMultiSet {

    /// Returns the difference of two multisets.
    ///
    /// For each element, `other`'s multiplicity is subtracted from this
    /// multiset's multiplicity without going below zero.
    ///
    /// - Parameter other: The multiset whose occurrences are subtracted.
    /// - Returns: A new multiset containing the remaining occurrences.
    /// - Complexity: O(*n* + *m*)
    @inlinable
    public func difference(_ other: __owned RedBlackTreeMultiSet<Element>)
      -> RedBlackTreeMultiSet<Element>
    {
      .init(__tree_: __tree_.___difference(other.__tree_))
    }

    /// Subtracts the occurrences in another multiset from this multiset.
    ///
    /// Multiplicities don't go below zero.
    ///
    /// - Parameter other: The multiset whose occurrences are subtracted.
    /// - Complexity: O(*n* + *m*)
    @inlinable
    public mutating func formDifference(_ other: __owned RedBlackTreeMultiSet<Element>) {
      __tree_ = __tree_.___difference(other.__tree_)
    }
  }
