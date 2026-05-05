//
//  RedBlackTreeMultiSet+ReserveCapacity.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/05/05.
//

extension RedBlackTreeMultiSet {

  /// Creates an empty set with preallocated space for at least the specified number of elements.
  @inlinable @inline(__always)
  public init(minimumCapacity: Int) {
    self.init(__tree_: .create(minimumCapacity: minimumCapacity))
  }
}

// MARK: -

extension RedBlackTreeMultiSet {
  
  /// Reserves enough space to store the specified number of elements.
  @inlinable
  public mutating func reserveCapacity(_ minimumCapacity: Int) {
    __tree_.ensureUniqueAndCapacity(to: minimumCapacity)
  }
}
