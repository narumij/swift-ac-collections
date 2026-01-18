//
//  tree_interface+erase.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/18.
//

import Foundation

@usableFromInline
protocol EraseInterface: _NodePtrType {
  func erase(_ __p: _NodePtr) -> _NodePtr
  func erase(_ __f: _NodePtr, _ __l: _NodePtr) -> _NodePtr
}

@usableFromInline
protocol EraseUniqueInteface: _KeyType {
  func ___erase_unique(_ __k: _Key) -> Bool
}

@usableFromInline
protocol EraseMultiInteface: _KeyType {
  func ___erase_multi(_ __k: _Key) -> Int
}
