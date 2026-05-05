//
//  RedBlackTreeMultiMap+.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/05/05.
//

// MARK: - ExpressibleByArrayLiteral

extension RedBlackTreeMultiMap: ExpressibleByArrayLiteral {

  /// - Complexity: O(*n* log *n*)
  @inlinable
  @inline(__always)
  public init(arrayLiteral elements: (Key, Value)...) {
    self.init(multiKeysWithValues: elements)
  }
}
