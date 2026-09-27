//
//  UnsafeTreeV2+Update.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/09/28.
//

extension UnsafeTreeV2 where Base: _ScalarBaseType {
  
  @inlinable
  internal func swap_key(_ __i: _NodePtr,_ __j: _NodePtr) -> Bool {
    if __i == __j {
        return true
    }
    guard Base.__key_(__i) == Base.__key_(__j) else {
      return false
    }
    Swift.swap(
      &Base.__key_ptr(__i).pointee,
      &Base.__key_ptr(__j).pointee)
    return true
  }
}

extension UnsafeTreeV2 where Base: _PairBaseType {
  
  @inlinable
  internal func swap_mapped_value(_ __i: _NodePtr,_ __j: _NodePtr) {
    if __i == __j {
        return
    }
    Swift.swap(
      &Base.__mapped_value_ptr(__i).pointee,
      &Base.__mapped_value_ptr(__j).pointee)
  }
}
