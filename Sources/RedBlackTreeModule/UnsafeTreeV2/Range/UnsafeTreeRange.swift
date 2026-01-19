//
//  UnsafeTreeRange.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/19.
//

/// `[__first, __last)`
///
@frozen
public struct UnsafeTreeRange: _UnsafeNodePtrType, Equatable {

  var __first: _NodePtr
  var __last: _NodePtr

  @usableFromInline
  internal init(__first: _NodePtr, __last: _NodePtr) {
    // 回収済みポインタではないこと
    assert(!__first.pointee.isGarbaged)
    assert(!__last.pointee.isGarbaged)
    // 同一の木のポインタであることを保証すること
    assert(__first.__slow_end() == __last.__slow_end())

    self.__first = __first
    self.__last = __last
  }
}

extension UnsafeTreeRange {

  func next(after __current: inout _NodePtr) -> _NodePtr? {
    guard __current != __last else { return nil }
    let __r = __current
    __current = __tree_next_iter(__current)
    return __r
  }

  func next(before __current: inout _NodePtr) -> _NodePtr? {
    guard __current != __first else { return nil }
    __current = __tree_prev_iter(__current)
    return __current
  }
}
