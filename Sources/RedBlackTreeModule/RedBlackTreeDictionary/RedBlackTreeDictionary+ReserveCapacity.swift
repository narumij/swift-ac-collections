//
//  RedBlackTreeDictionary+ReserveCapacity.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/05/05.
//

extension RedBlackTreeDictionary {

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public init(minimumCapacity: Int) {
    self.init(__tree_: .create(minimumCapacity: minimumCapacity))
  }
}

// MARK: -

extension RedBlackTreeDictionary {

  @inlinable
  public mutating func reserveCapacity(_ minimumCapacity: Int) {
    __tree_.ensureUniqueAndCapacity(to: minimumCapacity)
  }
}
