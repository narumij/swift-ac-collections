//
//  RedBlackTreeDictionary+Combining.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/05/05.
//

// MARK: - Combining Dictionary

extension RedBlackTreeDictionary {

  /// - Complexity: O(*n* log(*m + n*)), where *n* is the length of `other`
  ///   and *m* is the size of the current tree.
  @inlinable
  public mutating func merge(
    _ other: RedBlackTreeDictionary<Key, Value>,
    uniquingKeysWith combine: (Value, Value) throws -> Value
  ) rethrows {

    try __tree_.ensureUnique { __tree_ in
      try .___insert_range_unique(
        tree: __tree_,
        other: other.__tree_,
        other.__tree_.__begin_node_,
        other.__tree_.__end_node,
        uniquingKeysWith: combine)
    }
  }

  /// Merges the elements of `other` into the dictionary.
  /// If duplicate keys are encountered, the result of `combine` is used.
  ///
  /// - Complexity: O(*n* log(*m + n*)), where *n* is the length of `other`
  ///   and *m* is the size of the current tree.
  @inlinable
  public mutating func merge<S>(
    _ other: __owned S,
    uniquingKeysWith combine: (Value, Value) throws -> Value
  ) rethrows where S: Sequence, S.Element == (Key, Value) {

    try __tree_.ensureUnique { __tree_ in
      try .___insert_range_unique(
        tree: __tree_,
        other,
        uniquingKeysWith: combine
      ) { Base.__payload_($0) }
    }
  }

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
