//
//  RedBlackTreeDictionary+.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/05/05.
//

// MARK: - ExpressibleByArrayLiteral

extension RedBlackTreeDictionary: ExpressibleByArrayLiteral {

  /// Creates a dictionary from a literal in the form `[("key", value), ...]`.
  ///
  /// - Important: If duplicate keys are present,
  ///   a **runtime error** occurs, just like `Dictionary(uniqueKeysWithValues:)`.
  ///   (If you want to allow duplicates and merge them, use `merge` / `merging`.)
  ///
  /// Example:
  /// ```swift
  /// let d: RedBlackTreeDictionary = [("a", 1), ("b", 2)]
  /// ```
  @inlinable
  @inline(__always)
  public init(arrayLiteral elements: (Key, Value)...) {
    self.init(uniqueKeysWithValues: elements)
  }
}
