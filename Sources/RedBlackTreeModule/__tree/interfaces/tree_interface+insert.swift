//
//  tree_interface+insert.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/18.
//

import Foundation

@usableFromInline
protocol InsertNodeAtInterface: _NodePtrType {
  func __insert_node_at(
    _ __parent: _NodePtr,
    _ __child: _NodeRef,
    _ __new_node: _NodePtr
  )
}

@usableFromInline
protocol InsertUniqueInterface: _NodePtrType & _RawValueType {
  func __insert_unique(_ x: _Value) -> (__r: _NodePtr, __inserted: Bool)
  func __emplace_unique_key_args(_ __k: _Value) -> (__r: _NodePtr, __inserted: Bool)
}
