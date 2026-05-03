//
//  RedBlackTreeSet+Hashable.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/05/04.
//

// MARK: - Hashable

extension RedBlackTreeSet: Hashable where Element: Hashable {

  @inlinable
  @inline(__always)
  public func hash(into hasher: inout Hasher) {
    hasher.combine(__tree_)
  }
}
