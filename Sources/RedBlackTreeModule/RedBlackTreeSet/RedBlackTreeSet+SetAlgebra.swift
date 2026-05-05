//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-ac-collections project
//
// Copyright (c) 2024 - 2026 narumij.
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// This code is based on work originally distributed under the Apache License 2.0 with LLVM Exceptions:
//
// Copyright © 2003-2026 The LLVM Project.
// Licensed under the Apache License, Version 2.0 with LLVM Exceptions.
// The original license can be found at https://llvm.org/LICENSE.txt
//
// This Swift implementation includes modifications and adaptations made by narumij.
//
//===----------------------------------------------------------------------===//

import Foundation

extension RedBlackTreeSet: SetAlgebra {

  /// Returns a new set with the elements of both this and the given set.
  @inlinable
  @inline(__always)
  public func union(_ other: __owned RedBlackTreeSet<Element>)
    -> RedBlackTreeSet<Element>
  {
    var result = self
    result.formUnion(other)
    return result
  }

  /// Returns a new set with the elements that are common to both this set and the given set.
  @inlinable
  @inline(__always)
  public func intersection(_ other: RedBlackTreeSet<Element>)
    -> RedBlackTreeSet<Element>
  {
    var result = self
    result.formIntersection(other)
    return result
  }

  /// Returns a new set with the elements that are either in this set or in the given set, but not in both.
  @inlinable
  @inline(__always)
  public func symmetricDifference(_ other: __owned RedBlackTreeSet<Element>)
    -> RedBlackTreeSet<Element>
  {
    var result = self
    result.formSymmetricDifference(other)
    return result
  }

  /// Adds the elements of the given set to the set.
  ///
  /// - Complexity: O(*n* + *m*)
  @inlinable
  //  @inline(__always)
  public mutating func formUnion(_ other: __owned RedBlackTreeSet<Element>) {
    __tree_ = __tree_.___meld_unique(other.__tree_)
  }

  /// Removes the elements of this set that aren’t also in the given set.
  ///
  /// - Complexity: O(*n* + *m*)
  @inlinable
  //  @inline(__always)
  public mutating func formIntersection(_ other: RedBlackTreeSet<Element>) {
    __tree_ = __tree_.___intersection(other.__tree_)
  }

  /// Removes the elements of the set that are also in the given set and adds the members of the given set that are not already in the set.
  ///
  /// - Complexity: O(*n* + *m*)
  @inlinable
  //  @inline(__always)
  public mutating func formSymmetricDifference(_ other: __owned RedBlackTreeSet<Element>) {
    __tree_ = __tree_.___symmetric_difference(other.__tree_)
  }
}

/*
  __algorithm/set_difference.h に準じた動作となっている。
*/
extension RedBlackTreeSet {

  @inlinable
  @inline(__always)
  public func difference(_ other: __owned RedBlackTreeSet<Element>)
    -> RedBlackTreeSet<Element>
  {
    var result = self
    result.formDifference(other)
    return result
  }

  /// - Complexity: O(*n* + *m*)
  @inlinable
  //  @inline(__always)
  public mutating func formDifference(_ other: __owned RedBlackTreeSet<Element>) {
    __tree_ = __tree_.___difference(other.__tree_)
  }
}
