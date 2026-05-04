//
//  RedBlackTreeDictionary+Descriptions.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/05/05.
//

// MARK: - CustomStringConvertible

extension RedBlackTreeDictionary: CustomStringConvertible {

  @inlinable
  public var description: String {
    _dictionaryDescription(for: self)
  }
}

// MARK: - CustomDebugStringConvertible

extension RedBlackTreeDictionary: CustomDebugStringConvertible {

  public var debugDescription: String {
    description
  }
}
