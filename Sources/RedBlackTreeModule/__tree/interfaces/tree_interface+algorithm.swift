//
//  tree_interface+algorithm.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/24.
//

@usableFromInline
package protocol TreeAlgorithmBaseInterface: _NodePtrType {
  func __tree_is_left_child(_ __x: _NodePtr) -> Bool
//  func __tree_sub_invariant(_ __x: _NodePtr) -> UInt
  func __tree_invariant(_ __root: _NodePtr) -> Bool
  func __tree_min(_ __x: _NodePtr) -> _NodePtr
  func __tree_max(_ __x: _NodePtr) -> _NodePtr
  func __tree_next(_ __x: _NodePtr) -> _NodePtr
  func __tree_next_iter(_ __x: _NodePtr) -> _NodePtr
  func __tree_prev_iter(_ __x: _NodePtr) -> _NodePtr
  func __tree_leaf(_ __x: _NodePtr) -> _NodePtr
}

@usableFromInline
protocol TreeAlgorithmInterface: _NodePtrType {
  func __tree_left_rotate(_ __x: _NodePtr)
  func __tree_right_rotate(_ __x: _NodePtr)
  func __tree_balance_after_insert(_ __root: _NodePtr, _ __x: _NodePtr)
  func __tree_remove(_ __root: _NodePtr, _ __z: _NodePtr)
}
