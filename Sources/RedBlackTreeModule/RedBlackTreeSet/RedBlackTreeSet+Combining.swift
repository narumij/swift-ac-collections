//
//  RedBlackTreeSet+Combining.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/05/04.
//

// MARK: - Combining Set

extension RedBlackTreeSet {

  /// - Complexity: O(*n* log(*m + n*)), where *n* is the length of `other`
  ///   and *m* is the size of the current tree.
  ///
  /// - Important: If sufficient space is available,
  ///   using `formUnion` is recommended.
  @inlinable
  public mutating func merge(_ other: RedBlackTreeSet<Element>) {
    __tree_.ensureUnique { __tree_ in
      .___insert_range_unique(
        tree: __tree_,
        other: other.__tree_,
        other.__tree_.__begin_node_,
        other.__tree_.__end_node)
    }
  }

  /// - Complexity: O(*n* log(*m + n*)), where *n* is the length of `other`
  ///   and *m* is the size of the current tree.
  @inlinable
  public mutating func merge(_ other: RedBlackTreeMultiSet<Element>) {
    __tree_.ensureUnique { __tree_ in
      .___insert_range_unique(
        tree: __tree_,
        other: other.__tree_,
        other.__tree_.__begin_node_,
        other.__tree_.__end_node)
    }
  }

  /// - Complexity: O(*n* log(*m + n*)), where *n* is the length of `other`
  ///   and *m* is the size of the current tree.
  @inlinable
  public mutating func merge<S>(_ other: S) where S: Sequence, S.Element == Element {
    __tree_.ensureUnique { __tree_ in
      .___insert_range_unique(tree: __tree_, other)
    }
  }

  /// - Complexity: O(*n* log(*m + n*)), where *n* is the length of `other`
  ///   and *m* is the size of the current tree.
  ///
  /// - Important: If sufficient space complexity is available,
  ///   using `union` is recommended.
  @inlinable
  public func merging(_ other: RedBlackTreeSet<Element>) -> Self {
    var result: Self = self
    result.merge(other)
    return result
  }

  /// - Complexity: O(*n* log(*m + n*)), where *n* is the length of `other`
  ///   and *m* is the size of the current tree.
  @inlinable
  public func merging(_ other: RedBlackTreeMultiSet<Element>) -> Self {
    var result = self
    result.merge(other)
    return result
  }

  /// - Complexity: O(*n* log(*m + n*)), where *n* is the length of `other`
  ///   and *m* is the size of the current tree.
  @inlinable
  public func merging<S>(_ other: __owned S) -> Self where S: Sequence, S.Element == Element {
    var result = self
    result.merge(other)
    return result
  }
}
