//
//  RedBlackTreeSet+Descriptions.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/05/04.
//

// MARK: - CustomStringConvertible

extension RedBlackTreeSet: CustomStringConvertible {

  @inlinable
  public var description: String {
    _arrayDescription(for: self)
  }
}

// MARK: - CustomDebugStringConvertible

extension RedBlackTreeSet: CustomDebugStringConvertible {

  public var debugDescription: String {
    description
  }
}
