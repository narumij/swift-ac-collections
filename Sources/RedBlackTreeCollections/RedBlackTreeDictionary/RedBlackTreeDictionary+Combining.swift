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

// MARK: - Combining Dictionary

extension RedBlackTreeDictionary {

  /// Merges the key-value pairs of `other` into this dictionary.
  ///
  /// For duplicate keys, `combine` receives the current value followed by the
  /// value from `other`, and its result becomes the stored value.
  ///
  /// - Parameters:
  ///   - other: A dictionary whose key-value pairs to merge.
  ///   - combine: A closure that resolves duplicate keys.
  /// - Complexity: O(*n* log(*m + n*)), where *n* is the length of `other`
  ///   and *m* is the size of the current tree.
  @inlinable
  public mutating func merge(
    _ other: RedBlackTreeDictionary<Key, Value>,
    uniquingKeysWith combine: (Value, Value) throws -> Value
  ) rethrows {

    __tree_.ensureUnique()
    try __tree_.___insert_range_unique(
      other: other.__tree_,
      other.__tree_.__begin_node_,
      other.__tree_.__end_node,
      uniquingKeysWith: combine)
  }

  /// Merges the elements of `other` into the dictionary.
  /// If duplicate keys are encountered, the result of `combine` is used.
  ///
  /// `combine` receives the current value followed by the value from `other`.
  ///
  /// - Parameters:
  ///   - other: A sequence of key-value pairs to merge.
  ///   - combine: A closure that resolves duplicate keys.
  /// - Complexity: O(*n* log(*m + n*)), where *n* is the length of `other`
  ///   and *m* is the size of the current tree.
  @inlinable
  public mutating func merge<S>(
    _ other: __owned S,
    uniquingKeysWith combine: (Value, Value) throws -> Value
  ) rethrows where S: Sequence, S.Element == (Key, Value) {

    __tree_.ensureUnique()
    try __tree_.___insert_range_unique(
      other,
      uniquingKeysWith: combine
    ) { Base.__payload_($0) }
  }

  /// Returns a new dictionary by merging this dictionary with `other`.
  ///
  /// - Parameters:
  ///   - other: A dictionary whose key-value pairs to merge.
  ///   - combine: A closure that resolves duplicate keys, receiving the current value first.
  /// - Returns: The merged dictionary without modifying either input.
  /// - Complexity: O(*n* log(*m + n*)), where *n* is the length of `other`
  ///   and *m* is the size of the current tree.
  @inlinable
  public func merging(
    _ other: RedBlackTreeDictionary<Key, Value>,
    uniquingKeysWith combine: (Value, Value) throws -> Value
  ) rethrows -> Self {
    var result = self
    try result.merge(other, uniquingKeysWith: combine)
    return result
  }

  /// Returns a new dictionary by merging `self` and `other`.
  ///
  /// - Parameters:
  ///   - other: A sequence of key-value pairs to merge.
  ///   - combine: A closure that resolves duplicate keys, receiving the current value first.
  /// - Returns: The merged dictionary without modifying this dictionary.
  /// - Complexity: O(*n* log(*m + n*)), where *n* is the length of `other`
  ///   and *m* is the size of the current tree.
  @inlinable
  public func merging<S>(
    _ other: __owned S,
    uniquingKeysWith combine: (Value, Value) throws -> Value
  ) rethrows -> Self where S: Sequence, S.Element == (Key, Value) {
    var result = self
    try result.merge(other, uniquingKeysWith: combine)
    return result
  }
}
