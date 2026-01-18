//
//  tree_interface+bounds.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/18.
//


@usableFromInline
protocol BoundInteface: _NodePtrType, _KeyType {
  func lower_bound(_ __v: _Key) -> _NodePtr
  func upper_bound(_ __v: _Key) -> _NodePtr
}
