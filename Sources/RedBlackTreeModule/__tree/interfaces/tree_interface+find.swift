//
//  tree_interface+find.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/18.
//

import Foundation

@usableFromInline
protocol FindEqualInterface: _NodePtrType & _KeyType {
  func __find_equal(_ __v: _Key) -> (__parent: _NodePtr, __child: _NodeRef)
}

@usableFromInline
protocol FindInteface: _NodePtrType & _KeyType {
  func find(_ __v: _Key) -> _NodePtr
}
