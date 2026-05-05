//
//  RedBlackTreeDictionary+Descriptions.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/05/05.
//

// MARK: - CustomStringConvertible

extension RedBlackTreeDictionary: CustomStringConvertible {

  /// A string that represents the contents of the set.
  @inlinable
  public var description: String {
    _dictionaryDescription(for: self)
  }
}

// MARK: - CustomDebugStringConvertible

extension RedBlackTreeDictionary: CustomDebugStringConvertible {

  /// A string that represents the contents of the set, suitable for debugging.
  public var debugDescription: String {
    description
  }
}
