//
//  RedBlackTreeSeet+ReserveCapacity.swift.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/05/04.
//

// MARK: -

extension RedBlackTreeSet {

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public init(minimumCapacity: Int) {
    self.init(__tree_: .create(minimumCapacity: minimumCapacity))
  }
}

extension RedBlackTreeSet {

  @inlinable
  public mutating func reserveCapacity(_ minimumCapacity: Int) {
    __tree_.ensureUniqueAndCapacity(to: minimumCapacity)
  }
}
