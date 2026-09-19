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

// MARK: - Creating a Dictionay

extension RedBlackTreeDictionary {

  /// Creates a new, empty dictionary.
  ///
  /// - Complexity: O(1)
  @inlinable
  public init() {
    self.init(__tree_: .create())
  }
}

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeDictionary {

    /// - Complexity: O(*n* log *n*)
    ///   When inserting elements sequentially from an already sorted sequence,
    ///   no search is required, and rebalancing is amortized O(1),
    ///   so the overall construction cost becomes O(*n*).
    @inlinable
    public init<S>(uniqueKeysWithValues keysAndValues: __owned S)
    where S: Sequence, S.Element == (Key, Value) {
      var tree = Tree.create()
      tree.___insert_range_unique(keysAndValues) {
        Base.__payload_($0)
      }
      self.init(__tree_: tree)
    }
    
    /// - Complexity: O(*n* log *n*)
    ///   When inserting elements sequentially from an already sorted sequence,
    ///   no search is required, and rebalancing is amortized O(1),
    ///   so the overall construction cost becomes O(*n*).
    @inlinable
    public init<S>(uniqueKeysWithValues keysAndValues: __owned S)
    where S: Collection, S.Element == (Key, Value) {
      var tree = Tree.create(minimumCapacity: keysAndValues.count)
      tree.___insert_range_unique(keysAndValues) {
        Base.__payload_($0)
      }
      self.init(__tree_: tree)
    }
  }
#endif

extension RedBlackTreeDictionary {

  /// - Complexity: O(*n* log *n* + *n*)
  @inlinable
  public init<S>(
    _ keysAndValues: __owned S,
    uniquingKeysWith combine: (Value, Value) throws -> Value
  ) rethrows where S: Sequence, S.Element == (Key, Value) {
    var tree = Tree.create()
    try tree.___insert_range_unique(keysAndValues, uniquingKeysWith: combine) {
      Base.__payload_($0)
    }
    self.init(__tree_: tree)
  }
}

extension RedBlackTreeDictionary {

  /// - Complexity: O(*n* log *n* + *n*)
  @inlinable
  public init<S: Sequence>(
    grouping values: __owned S,
    by keyForValue: (S.Element) throws -> Key
  ) rethrows where Value == [S.Element] {
    var tree = Tree.create()
    try tree.___insert_range_unique(grouping: values, by: keyForValue)
    self.init(__tree_: tree)
  }
}
