//
//  ___ForEachProtocol.swift
//  swift-ac-collections
//
//  Created by narumij on 2025/05/29.
//

@usableFromInline
protocol ___ForEachProtocol {
  
  associatedtype Element
  
  func ___for_each(__p: _NodePtr, __l: _NodePtr, body: (_NodePtr, inout Bool) throws -> Void) rethrows
  
  func ___for_each_(_ body: (Element) throws -> Void) rethrows

  func ___for_each_(__p: _NodePtr, __l: _NodePtr, body: (Element) throws -> Void) rethrows
}
