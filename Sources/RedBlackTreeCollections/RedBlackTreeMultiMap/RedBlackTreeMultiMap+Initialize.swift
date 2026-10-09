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

// MARK: - Creating a MultiMap

extension RedBlackTreeMultiMap {

  /// Creates a new, empty multi map.
  ///
  /// - Complexity: O(1).
  @inlinable
  public init() {
    self.init(__tree_: .create())
  }
}

  extension RedBlackTreeMultiMap {

    /// Creates a multimap containing every key-value pair in the given sequence.
    ///
    /// Duplicate keys are retained and the resulting multimap stores pairs in key order.
    ///
    /// - Parameter keysAndValues: A finite sequence of key-value pairs for the multimap.
    /// - Complexity: O(*n* log *n*), where *n* is the length of `keysAndValues`.
    ///   When inserting elements sequentially from an already sorted sequence,
    ///   no search is required, and rebalancing is amortized O(1),
    ///   so the overall construction cost becomes O(*n*).
    @inlinable
    public init<S>(keysWithValues keysAndValues: __owned S)
    where S: Sequence, S.Element == (Key, Value) {
      var tree = Tree.create()
      tree.___insert_range_multi(keysAndValues) {
        Base.__payload_($0)
      }
      self.init(__tree_: tree)
    }

    /// Creates a multimap containing every key-value pair in the given collection.
    ///
    /// Duplicate keys are retained. This overload reserves storage using the collection's count
    /// before inserting its pairs.
    ///
    /// - Parameter keysAndValues: A finite collection of key-value pairs for the multimap.
    /// - Complexity: O(*n* log *n*), where *n* is `keysAndValues.count`.
    ///   When inserting elements sequentially from an already sorted sequence,
    ///   no search is required, and rebalancing is amortized O(1),
    ///   so the overall construction cost becomes O(*n*).
    @inlinable
    public init<S>(keysWithValues keysAndValues: __owned S)
    where S: Collection, S.Element == (Key, Value) {
      var tree = Tree.create(minimumCapacity: keysAndValues.count)
      tree.___insert_range_multi(keysAndValues) {
        Base.__payload_($0)
      }
      self.init(__tree_: tree)
    }
  }

extension RedBlackTreeMultiMap {
  // Dictionaryからぱくってきたが、割と様子見

  /// Creates a multimap by assigning a key to every value in the given sequence.
  ///
  /// Unlike the dictionary grouping initializer, this initializer keeps one key-value pair for
  /// every source element. Equal keys are retained rather than combined into arrays.
  ///
  /// - Parameters:
  ///   - values: A finite sequence of values for the multimap.
  ///   - keyForValue: A closure that returns the key for each source value.
  /// - Complexity: O(*n* log *n*), where *n* is the length of `values`.
  @inlinable
  public init<S: Sequence>(
    grouping values: __owned S,
    by keyForValue: (S.Element) throws -> Key
  ) rethrows where Value == S.Element {
    var tree = Tree.create()
    try tree.___insert_range_multi(values) {
      Base.__payload_((try keyForValue($0), $0))
    }
    self.init(__tree_: tree)
  }
}
