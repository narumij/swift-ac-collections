//
//  RedBlackTreeMultiSet+Descriptions.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/05/05.
//

// MARK: - CustomStringConvertible

extension RedBlackTreeMultiSet: CustomStringConvertible {

  @inlinable
  public var description: String {
    _arrayDescription(for: self)
  }
}

// MARK: - CustomDebugStringConvertible

extension RedBlackTreeMultiSet: CustomDebugStringConvertible {

  public var debugDescription: String {
    description
  }
}
