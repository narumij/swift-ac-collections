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
protocol InsertUniqueInterface: InsertNodeAtInterface & _KeyType {
  func __find_equal(_ __v: _Key) -> (__parent: _NodePtr, __child: _NodeRef)
  func
    __insert_node_at(
      _ __parent: _NodePtr, _ __child: _NodeRef,
      _ __new_node: _NodePtr)
}
