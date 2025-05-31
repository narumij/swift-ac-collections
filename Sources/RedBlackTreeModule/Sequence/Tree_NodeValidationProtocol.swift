//
//  Tree_NodeValidationProtocol.swift
//  swift-ac-collections
//
//  Created by narumij on 2025/05/31.
//

@usableFromInline
protocol Tree_NodeValidationProtocol {
  func ___is_valid(_ p: _NodePtr) -> Bool
  func ___is_valid_index(_ i: _NodePtr) -> Bool
}
