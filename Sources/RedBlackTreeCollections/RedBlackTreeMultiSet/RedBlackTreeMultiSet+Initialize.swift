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

// MARK: - Creating a MultSet

extension RedBlackTreeMultiSet {

  /// Creates a new, empty multi set.
  ///
  /// - Complexity: O(1)
  @inlinable
  public init() {
    self.init(__tree_: .create())
  }
}

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiSet {

    /// Creates a new set from a finite sequence of items.
    ///
    /// - Complexity: O(*n* log *n*)
    ///   When inserting elements sequentially from an already sorted sequence,
    ///   no search is required, and rebalancing is amortized O(1),
    ///   so the overall construction cost becomes O(*n*).
    @inlinable
    public init<Source>(_ sequence: __owned Source)
    where Element == Source.Element, Source: Sequence {
      self.init(
        __tree_:
          .___insert_range_multi(
            tree: .create(),
            sequence))
    }

    /// Creates a new set from a finite sequence of items.
    ///
    /// - Complexity: O(*n* log *n*)
    ///   When inserting elements sequentially from an already sorted sequence,
    ///   no search is required, and rebalancing is amortized O(1),
    ///   so the overall construction cost becomes O(*n*).
    @inlinable
    public init<Source>(_ collection: __owned Source)
    where Element == Source.Element, Source: Collection {
      self.init(
        __tree_:
          .___insert_range_multi(
            tree: .create(minimumCapacity: collection.count),
            collection))
    }
  }
#endif

extension RedBlackTreeMultiSet {

  /// Creates a new set from a finite sequence of items.
  ///
  /// - Important: This implementation assumes ascending order and omits certain checks.
  ///   Using it with descending order results in undefined behavior.
  /// - Complexity: Amortized O(*n*).
  @inlinable
  public init<R>(_ range: __owned R)
  where R: RangeExpression, R: Collection, R.Element == Element {
    precondition(range is Range<Element> || range is ClosedRange<Element>)
    self.init(__tree_: .create(range: range))
  }
}
