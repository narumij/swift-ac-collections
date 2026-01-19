//
//  RedBlackTreeCollection.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/19.
//

public protocol RBTCollection: Collection {
  associatedtype Key
  associatedtype Index
  var startIndex: Index { get }
  var endIndex: Index { get }
  func lowerBound(_: Key) -> Index
  func upperBound(_: Key) -> Index
}
