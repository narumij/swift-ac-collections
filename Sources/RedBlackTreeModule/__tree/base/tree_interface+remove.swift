//
//  tree_interface+remove.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/18.
//

import Foundation

@usableFromInline
protocol RemoveInteface: _nullptr_interface
{
  func __remove_node_pointer(_ __ptr: _NodePtr) -> _NodePtr
}
