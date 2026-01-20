//
//  tree_interface+equal.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/18.
//

@usableFromInline
protocol EqualInterface: _NodePtrType & _KeyType {
  func __equal_range_unique(_ __k: _Key) -> (_NodePtr, _NodePtr)
  func __equal_range_multi(_ __k: _Key) -> (_NodePtr, _NodePtr)
}
