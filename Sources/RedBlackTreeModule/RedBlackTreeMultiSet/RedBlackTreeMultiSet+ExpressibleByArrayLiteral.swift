//
//  RedBlackTreeMultiSet+ExpressibleByArrayLiteral.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/05/05.
//

// MARK: - ExpressibleByArrayLiteral

extension RedBlackTreeMultiSet: ExpressibleByArrayLiteral {

  /// - Complexity: O(*n* log *n*)
  @inlinable
  @inline(__always)
  public init(arrayLiteral elements: Element...) {
    self.init(elements)
  }
}
