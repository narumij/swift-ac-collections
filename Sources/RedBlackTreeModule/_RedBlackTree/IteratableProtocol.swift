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

