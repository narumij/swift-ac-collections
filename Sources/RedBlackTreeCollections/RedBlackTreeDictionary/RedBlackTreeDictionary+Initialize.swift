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
  /// - Complexity: O(1).
  @inlinable
  public init() {
    self.init(__tree_: .create())
  }
}

  extension RedBlackTreeDictionary {

    /// Creates a dictionary from a sequence of key-value pairs with unique keys.
    ///
    /// The resulting dictionary stores its keys in sorted order.
    ///
    /// - Parameter keysAndValues: A finite sequence of key-value pairs for the dictionary.
    /// - Precondition: Every key in `keysAndValues` is unique.
    /// - Complexity: O(*n* log *n*), where *n* is the length of `keysAndValues`.
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
    
    /// Creates a dictionary from a collection of key-value pairs with unique keys.
    ///
    /// This overload reserves storage using the collection's count before inserting its pairs.
    ///
    /// - Parameter keysAndValues: A finite collection of key-value pairs for the dictionary.
    /// - Precondition: Every key in `keysAndValues` is unique.
    /// - Complexity: O(*n* log *n*), where *n* is `keysAndValues.count`.
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

extension RedBlackTreeDictionary {

  /// Creates a dictionary from a sequence of key-value pairs, combining values for duplicate keys.
  ///
  /// When the sequence contains duplicate keys, `combine` is called with the value already stored
  /// in the dictionary and the new value from the sequence, in that order.
  ///
  /// - Parameters:
  ///   - keysAndValues: A finite sequence of key-value pairs for the dictionary.
  ///   - combine: A closure that combines an existing value and a new value for the same key.
  /// - Complexity: O(*n* log *n*), where *n* is the length of `keysAndValues`.
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

  /// Creates a dictionary whose keys are the group identifiers returned by the given closure.
  ///
  /// Each value in the resulting dictionary is an array containing the source elements assigned
  /// to that key, in their original sequence order. The dictionary stores its keys in sorted order.
  ///
  /// - Parameters:
  ///   - values: A finite sequence of values to group.
  ///   - keyForValue: A closure that returns the grouping key for a source value.
  /// - Complexity: O(*n* log *n*), where *n* is the length of `values`.
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
