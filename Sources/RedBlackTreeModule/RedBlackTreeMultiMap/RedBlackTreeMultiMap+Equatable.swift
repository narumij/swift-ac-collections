//
//  RedBlackTreeMultiMap+Equatable.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/05/05.
//

// MARK: - Equatable

extension RedBlackTreeMultiMap: Equatable where Value: Equatable {

  /// - Complexity: O(*m*), where *m* is the lesser of the length of `lhs` and `rhs`.
  @inlinable
  @inline(__always)
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.__tree_ == rhs.__tree_
  }
}
