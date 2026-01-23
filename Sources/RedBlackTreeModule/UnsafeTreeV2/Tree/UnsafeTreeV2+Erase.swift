//
//  UnsafeTreeV2+Erase.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/23.
//

extension UnsafeTreeV2 {

  @inlinable
  func ___erase_if(
    _ __first: _NodePtr,
    _ __last: _NodePtr,
    shouldBeRemoved: (_Key) throws -> Bool
  ) rethrows {
    var __first = __first
    while __first != __last {
      if try shouldBeRemoved(__get_value(__first)) {
        __first = erase(__first)
      } else {
        __first = __tree_next_iter(__first)
      }
    }
  }
}
