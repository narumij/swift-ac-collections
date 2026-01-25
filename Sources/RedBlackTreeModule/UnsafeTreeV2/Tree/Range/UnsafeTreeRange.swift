//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-ac-collections project
//
// Copyright (c) 2024 - 2026 narumij.
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// This code is based on work originally distributed under the Apache License 2.0 with LLVM Exceptions:
//
// Copyright © 2003-2026 The LLVM Project.
// Licensed under the Apache License, Version 2.0 with LLVM Exceptions.
// The original license can be found at https://llvm.org/LICENSE.txt
//
// This Swift implementation includes modifications and adaptations made by narumij.
//
//===----------------------------------------------------------------------===//

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

  /// 最悪でもendで止まる
  func boundsCheckedNext(after __current: inout _NodePtr) -> _NodePtr? {
    guard __current != ___to else { return nil }
    guard !__current.___is_end else {
      fatalError(.outOfBounds)
    }
    let __r = __current
    __current = __tree_next_iter(__current)
    return __r
  }

  /// 最悪でもnullで止まる
  ///
  /// end開始のケースがあるため、endで弾くことはできない
  func boundsCheckedNext(before __current: inout _NodePtr) -> _NodePtr? {
    guard __current != ___from else { return nil }
    guard !__current.___is_null else {
      fatalError(.outOfBounds)
    }
    __current = __tree_prev_iter(__current)
    return __current
  }
}
