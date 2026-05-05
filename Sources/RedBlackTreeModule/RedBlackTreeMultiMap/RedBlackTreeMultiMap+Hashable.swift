//
//  RedBlackTreeMultiMap+Hashable.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/05/05.
//

// MARK: - Hashable

extension RedBlackTreeMultiMap: Hashable where Key: Hashable, Value: Hashable {

  /// Hashes the essential components of this value by feeding them into the given hasher.
  @inlinable
  @inline(__always)
  public func hash(into hasher: inout Hasher) {
    hasher.combine(__tree_)
  }
}
