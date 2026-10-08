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
  extension RedBlackTreeSet {
    /// A view over a contiguous range of this set in ascending order.
    public typealias SubSequence = RedBlackTreeKeyOnlyRangeView<Self>
  }
#endif

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeSet {

    /// Returns a new set containing the elements of the set that satisfy the given predicate.
    ///
    /// The returned set preserves the set's sorted order and contains no duplicates.
    ///
    /// - Parameter isIncluded: A closure that returns `true` for an element to include.
    /// - Returns: A new set containing only the included elements.
    /// - Complexity: O(*n*)
    @inlinable
    public func filter(
      _ isIncluded: (Element) throws -> Bool
    ) rethrows -> Self {
      .init(__tree_: try __tree_.___filter(_start, _end, isIncluded))
    }
  }
#endif

// MARK: - Sequence Conformance

extension RedBlackTreeSet: Sequence {}

extension RedBlackTreeSet {

  /// Returns an iterator over the members of the set.
  ///
  /// The iterator visits the elements in sorted order.
  ///
  /// - Returns: An iterator over the set's elements.
  /// - Complexity: O(1)
  @inlinable
  public func makeIterator() -> Tree._PayloadValues {
    #if !COMPATIBLE_ATCODER_2025
      .init(start: _start, end: _end, tree: __tree_)
    #else
      .init(start: _sealed_start, end: _sealed_end, tie: __tree_.tied)
    #endif
  }
}

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeSet {

    /// Returns the elements of the sequence, sorted.
    ///
    /// - Returns: An array containing every element in sorted order.
    /// - Complexity: O(*n*)
    @inlinable
    public func sorted() -> [Element] {
      __tree_.___copy_all_to_array()
    }

    /// Returns an array containing the elements of this sequence in reverse order.
    ///
    /// - Returns: An array containing every element in descending order.
    /// - Complexity: O(`count`)
    @inlinable
    public func reversed() -> [Element] {
      __tree_.___rev_copy_all_to_array()
    }
  }
#endif
