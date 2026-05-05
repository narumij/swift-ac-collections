//
//  RedBlackTreeDictionary+Hashable.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/05/05.
//

// MARK: - Hashable

extension RedBlackTreeDictionary: Hashable where Key: Hashable, Value: Hashable {

  @inlinable
  @inline(__always)
  public func hash(into hasher: inout Hasher) {
    hasher.combine(__tree_)
  }
}
