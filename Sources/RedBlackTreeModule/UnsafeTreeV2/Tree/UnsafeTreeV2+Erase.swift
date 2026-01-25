//
//  UnsafeTreeV2+Erase.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/23.
//

extension UnsafeTreeV2 {

  @inlinable
  func ___erase(
    _ __first: _NodePtr,
    _ __last: _NodePtr
  ) {
    var __first = __first
    while __first != __last {
      guard !__first.___is_end else {
        fatalError(.outOfBounds)
      }
      __first = erase(__first)
    }
  }

  @inlinable
  func ___erase_if(
    _ __first: _NodePtr,
    _ __last: _NodePtr,
    shouldBeRemoved: (_RawValue) throws -> Bool
  ) rethrows {
    var __first = __first
    while __first != __last {
      guard !__first.___is_end else {
        fatalError(.outOfBounds)
      }
      if try shouldBeRemoved(__value_(__first)) {
        __first = erase(__first)
      } else {
        __first = __tree_next_iter(__first)
      }
    }
  }

  // fault torelantはたまたま動いてるやつを認識できず、Swiftらしくないので、やめることに
  // TODO: 他のfault torelant動作を探し、消す
}
