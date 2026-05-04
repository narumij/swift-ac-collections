//
//  RedBlackTreeMultiSet+Combining.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/05/05.
//

// MARK: - Combining MultiSet

extension RedBlackTreeMultiSet {

  /// - Complexity: O(*n* log(*m + n*)), where *n* is the length of `other`
  ///   and *m* is the size of the current tree.
  ///
  /// - Important: If sufficient space is available,
  ///   using `meld` is recommended.
  @inlinable
  public mutating func insert(contentsOf other: RedBlackTreeSet<Element>) {
    __tree_.ensureUnique { __tree_ in
      .___insert_range_multi(
        tree: __tree_,
        other: other.__tree_,
        other.__tree_.__begin_node_,
        other.__tree_.__end_node)
    }
  }

  /// - Complexity: O(*n* log(*m + n*)), where *n* is the length of `other`
  ///   and *m* is the size of the current tree.
  @inlinable
  public mutating func insert(contentsOf other: RedBlackTreeMultiSet<Element>) {
    __tree_.ensureUnique { __tree_ in
      .___insert_range_multi(
        tree: __tree_,
        other: other.__tree_,
        other.__tree_.__begin_node_,
        other.__tree_.__end_node)
    }
  }

  /// - Complexity: O(*n* log(*m + n*)), where *n* is the length of `other`
  ///   and *m* is the size of the current tree.
  @inlinable
  public mutating func insert<S>(contentsOf other: S) where S: Sequence, S.Element == Element {
    __tree_.ensureUnique { __tree_ in
      .___insert_range_multi(tree: __tree_, other)
    }
  }

  /// - Complexity: O(*n* log(*m + n*)), where *n* is the length of `other`
  ///   and *m* is the size of the current tree.
  @inlinable
  public func inserting(contentsOf other: RedBlackTreeSet<Element>) -> Self {
    var result = self
    result.insert(contentsOf: other)
    return result
  }

  /// - Complexity: O(*n* log(*m + n*)), where *n* is the length of `other`
  ///   and *m* is the size of the current tree.
  ///
  /// - Important: If sufficient space is available,
  ///   using `melding` is recommended.
  @inlinable
  public func inserting(contentsOf other: RedBlackTreeMultiSet<Element>) -> Self {
    var result = self
    result.insert(contentsOf: other)
    return result
  }

  /// - Complexity: O(*n* log(*m + n*)), where *n* is the length of `other`
  ///   and *m* is the size of the current tree.
  @inlinable
  public func inserting<S>(contentsOf other: __owned S) -> Self
  where S: Sequence, S.Element == Element {
    var result = self
    result.insert(contentsOf: other)
    return result
  }
}

extension RedBlackTreeMultiSet {

  /// - Complexity: O(*n* + *m*)
  @inlinable
  @inline(__always)
  public mutating func meld(_ other: __owned RedBlackTreeMultiSet<Element>) {
    __tree_ = __tree_.___meld_multi(other.__tree_)
  }

  /// - Complexity: O(*n* + *m*)
  @inlinable
  @inline(__always)
  public func melding(_ other: __owned RedBlackTreeMultiSet<Element>)
    -> RedBlackTreeMultiSet<Element>
  {
    var result = self
    result.meld(other)
    return result
  }
}
