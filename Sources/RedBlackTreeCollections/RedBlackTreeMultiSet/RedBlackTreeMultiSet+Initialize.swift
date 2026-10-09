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

// MARK: - Creating a MultSet

extension RedBlackTreeMultiSet {

  /// Creates a new, empty multiset.
  ///
  /// - Complexity: O(1).
  @inlinable
  public init() {
    self.init(__tree_: .create())
  }
}

  extension RedBlackTreeMultiSet {

    /// Creates a new multiset containing the elements of the given sequence.
    ///
    /// Duplicate elements are retained and all elements are stored in sorted order.
    ///
    /// - Parameter sequence: A finite sequence of elements for the new multiset.
    /// - Complexity: O(*n* log *n*), where *n* is the length of `sequence`.
    ///   When inserting elements sequentially from an already sorted sequence,
    ///   no search is required, and rebalancing is amortized O(1),
    ///   so the overall construction cost becomes O(*n*).
    @inlinable
    public init<Source>(_ sequence: __owned Source)
    where Element == Source.Element, Source: Sequence {
      var tree = Tree.create()
      tree.___insert_range_multi(sequence) { $0 }
      self.init(__tree_: tree)
    }

    /// Creates a new multiset containing the elements of the given collection.
    ///
    /// Duplicate elements are retained. This overload reserves storage using the collection's
    /// count before inserting its elements.
    ///
    /// - Parameter collection: A finite collection of elements for the new multiset.
    /// - Complexity: O(*n* log *n*), where *n* is `collection.count`.
    ///   When inserting elements sequentially from an already sorted sequence,
    ///   no search is required, and rebalancing is amortized O(1),
    ///   so the overall construction cost becomes O(*n*).
    @inlinable
    public init<Source>(_ collection: __owned Source)
    where Element == Source.Element, Source: Collection {
      if collection.isEmpty {
        self.init()
      } else {
        var tree = Tree.create(minimumCapacity: collection.count)
        tree.___insert_range_multi(collection) { $0 }
        self.init(__tree_: tree)
      }
    }
  }

extension RedBlackTreeMultiSet {

  /// Creates a new multiset from an ascending range of elements.
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
