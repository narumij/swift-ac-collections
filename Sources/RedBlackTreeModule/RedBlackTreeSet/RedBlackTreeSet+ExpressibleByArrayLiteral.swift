//
//  RedBlackTreeSet+ExpressibleByArrayLiteral.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/05/04.
//

// MARK: - ExpressibleByArrayLiteral

extension RedBlackTreeSet: ExpressibleByArrayLiteral {

  /// - Complexity: O(*n* log *n* + *n*)
  @inlinable
  @inline(__always)
  public init(arrayLiteral elements: Element...) {
    self.init(elements)
  }
}
