//
//  IteratableProtocol.swift
//  swift-ac-collections
//
//  Created by narumij on 2025/05/28.
//

public protocol IteratableProtocol {
  associatedtype Element
  func __tree_next(_ __x: _NodePtr) -> _NodePtr
  subscript(_ pointer: _NodePtr) -> Element { get }
}

public protocol CollectionableProtocol {
  // この実装がないと、迷子になる
  func distance(from start: _NodePtr, to end: _NodePtr) -> Int
  func index(after i: _NodePtr) -> _NodePtr
  func index(before i: _NodePtr) -> _NodePtr
}
