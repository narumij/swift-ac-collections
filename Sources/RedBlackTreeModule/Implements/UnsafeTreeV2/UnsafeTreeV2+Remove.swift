//
//  UnsafeTreeV2+Remove.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/02/17.
//

extension UnsafeTreeV2 {
  
  @inlinable
  @inline(__always)
  @discardableResult
  package mutating func _unchecked_remove(at ptr: _NodePtr) -> (
    __r: _NodePtr, payload: _PayloadValue
  ) {
    let ___e = self[_unsafe_raw: ptr]
    let __r = erase(ptr)
    return (__r, ___e)
  }
}
