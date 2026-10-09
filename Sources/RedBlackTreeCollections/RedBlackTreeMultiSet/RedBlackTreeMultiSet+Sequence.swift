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

  extension RedBlackTreeMultiSet {
    /// A view over a contiguous range of this multiset in ascending order.
    ///
    /// The view preserves every occurrence in the selected range.
    public typealias SubSequence = RedBlackTreeKeyOnlyRangeView<Self>
  }

// MARK: -

  extension RedBlackTreeMultiSet {

    /// Returns a new multiset containing the elements that satisfy the given predicate.
    ///
    /// Every included occurrence is retained, including equivalent elements.
    ///
    /// - Parameter isIncluded: A closure that returns `true` for an occurrence to include.
    /// - Returns: A new multiset containing only the included occurrences.
    /// - Complexity: O(*n*)
    @inlinable
    public func filter(
      _ isIncluded: (Element) throws -> Bool
    ) rethrows -> Self {
      .init(__tree_: try __tree_.___filter(_start, _end, isIncluded))
    }
  }

// MARK: - Sequence Conformance

extension RedBlackTreeMultiSet: Sequence {}

extension RedBlackTreeMultiSet {

  /// Returns an iterator over the members of the multiset.
  ///
  /// The iterator visits every occurrence in sorted order.
  ///
  /// - Returns: An iterator over the multiset's elements.
  /// - Complexity: O(1)
  @inlinable
  public func makeIterator() -> Tree._PayloadValues {
      .init(start: _start, end: _end, tree: __tree_)
  }
}

  extension RedBlackTreeMultiSet {

    /// Returns the elements of the sequence, sorted.
    ///
    /// Equivalent elements occur in the result with their full multiplicity.
    ///
    /// - Returns: An array containing every occurrence in sorted order.
    /// - Complexity: O(*n*)
    @inlinable
    public func sorted() -> [Element] {
      __tree_.___copy_all_to_array()
    }

    /// Returns an array containing the elements of this sequence in reverse order.
    ///
    /// Equivalent elements occur in the result with their full multiplicity.
    ///
    /// - Returns: An array containing every occurrence in descending order.
    /// - Complexity: O(`count`)
    @inlinable
    public func reversed() -> [Element] {
      __tree_.___rev_copy_all_to_array()
    }
  }
