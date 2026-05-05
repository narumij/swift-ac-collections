//
//  RedBlackTreeMultiMap+.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/05/05.
//

// MARK: - ExpressibleByDictionaryLiteral

extension RedBlackTreeMultiMap: ExpressibleByDictionaryLiteral {

  /// - Complexity: O(*n* log *n*)
  @inlinable
  @inline(__always)
  public init(dictionaryLiteral elements: (Key, Value)...) {
    self.init(multiKeysWithValues: elements)
  }
}
