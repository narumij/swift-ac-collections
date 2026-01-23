//
//  UnsafeTreeRange.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/19.
//

/// `[__first, __last)`
///
@frozen
@usableFromInline
struct UnsafeTreeRange: _UnsafeNodePtrType, Equatable {

  var ___from: _NodePtr
  var ___to: _NodePtr

  @usableFromInline
  internal init(___from: _NodePtr, ___to: _NodePtr) {
    // 回収済みポインタではないこと
    assert(!___from.pointee.isGarbaged)
    assert(!___to.pointee.isGarbaged)
    // 同一の木のポインタであることを保証すること
    assert(___from.__slow_end() == ___to.__slow_end())

    self.___from = ___from
    self.___to = ___to
  }
}

extension UnsafeTreeRange {

  func next(after __current: inout _NodePtr) -> _NodePtr? {
    guard __current != ___to else { return nil }
    let __r = __current
    __current = __tree_next_iter(__current)
    return __r
  }

  func next(before __current: inout _NodePtr) -> _NodePtr? {
    guard __current != ___from else { return nil }
    __current = __tree_prev_iter(__current)
    return __current
  }
}
