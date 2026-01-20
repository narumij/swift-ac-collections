//
//  tree_interface+compare.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/19.
//

@usableFromInline
protocol PointerCompareInterface: _NodePtrType {
  func ___ptr_comp(_ l: _NodePtr, _ r: _NodePtr) -> Bool
}

public protocol IsMultiTraitInterface {
  var isMulti: Bool { get }
}

@usableFromInline
protocol CompareMultiInterface: _NodePtrType {
  func ___ptr_comp_multi(_ __l: _NodePtr, _ __r: _NodePtr) -> Bool
}
