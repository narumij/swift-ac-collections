//
//  RedBlackTreeMultiMap+Description.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/05/05.
//

// MARK: - CustomStringConvertible

extension RedBlackTreeMultiMap: CustomStringConvertible {

  @inlinable
  public var description: String {
    _dictionaryDescription(for: self)
  }
}

// MARK: - CustomDebugStringConvertible

extension RedBlackTreeMultiMap: CustomDebugStringConvertible {

  public var debugDescription: String {
    description
  }
}
