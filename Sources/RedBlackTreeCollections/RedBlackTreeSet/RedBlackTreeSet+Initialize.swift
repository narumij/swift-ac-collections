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

// MARK: - Creating a Set

extension RedBlackTreeSet {

  /// Creates a new, empty set.
  ///
  /// - Complexity: O(1).
  @inlinable
  public init() {
    self.init(__tree_: .create())
  }
}

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeSet {

    /// Creates a new set containing the unique elements of the given sequence.
    ///
    /// The set discards duplicate elements and stores the remaining elements in sorted order.
    ///
    /// - Parameter sequence: A finite sequence of elements for the new set.
    /// - Complexity: O(*n* log *n*), where *n* is the length of `sequence`.
    ///   When inserting elements sequentially from an already sorted sequence,
    ///   no search is required, and rebalancing is amortized O(1),
    ///   so the overall construction cost becomes O(*n*).
    @inlinable
    public init<Source>(_ sequence: __owned Source)
    where Element == Source.Element, Source: Sequence {
      var tree = Tree.create()
      tree.___insert_range_unique(sequence)
      self.init(__tree_: tree)
    }
  }
#endif

extension RedBlackTreeSet {

  /// Creates a new set from an ascending range of elements.
  ///
  /// This overload is a specialized linear-time path for `Range` and `ClosedRange` values.
  /// Other finite sequences, including descending strides, use the sequence initializer.
  ///
  /// - Parameter range: An ascending `Range` or `ClosedRange` containing the elements.
  /// - Precondition: `range` is a `Range<Element>` or `ClosedRange<Element>`.
  /// - Complexity: O(*n*), where *n* is the number of elements in `range`.
  @inlinable
  public init<R>(_ range: __owned R)
  where R: RangeExpression, R: Collection, R.Element == Element {
    precondition(range is Range<Element> || range is ClosedRange<Element>)
    self.init(__tree_: .create(range: range))
  }
}
