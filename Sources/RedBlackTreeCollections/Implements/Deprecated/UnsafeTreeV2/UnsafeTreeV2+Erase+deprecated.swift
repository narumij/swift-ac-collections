//
//  UnsafeTreeV2+Erase+deprecated.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/11/16.
//


#if COMPATIBLE_ATCODER_2025
  extension UnsafeTreeV2 {

    @inlinable
    @discardableResult
    mutating func ___erase_range(_ __first: _NodePtr, _ __last: _NodePtr) -> _NodePtr {

      var __first = __first
      while __first != __last {
        guard __first.___has_payload_content else {
          fatalError(.outOfBounds)  // エラー種別がしっくりこない
        }
        __first = erase(__first)
      }
      return __last
    }
  }
#endif
