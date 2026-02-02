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
struct UnsafeTreeSafeRange: _UnsafeNodePtrType, Equatable {
  var ___from: _SealedPtr
  var ___to: _SealedPtr
  @usableFromInline
  internal init(___from: _SealedPtr, ___to: _SealedPtr) {
    self.___from = ___from
    self.___to = ___to
  }
}

extension UnsafeTreeSafeRange {

  func boundsCheckedNext(after __current: inout _SealedPtr) -> _NodePtr? {
    let __checked_current = __current.purified
    // 範囲終端が壊れてたらオコ！
    guard let _end = try? ___to.purified.get() else {
      fatalError(.invalidIndex)
    }
    // current が壊れてたらオコ！
    guard let _p = try? __checked_current.get() else {
      fatalError(.invalidIndex)
    }
    // 終端に到達
    guard _p != _end else { return nil }
    __current = __checked_current.flatMap { ___tree_next_iter($0.pointer) }.seal
    return _p.pointer
  }

  func boundsCheckedNext(before __current: inout _SealedPtr) -> _NodePtr? {
    let _checked_current = __current.purified
    // 範囲 ___from が壊れてたらオコ！
    guard let start = try? ___from.purified.get() else {
      fatalError(.invalidIndex)
    }
    // __current が壊れてたらオコ！
    guard let cur = try? _checked_current.get() else {
      fatalError(.invalidIndex)
    }
    // ___from に到達（exclusive）なら終了
    guard cur != start else { return nil }
    __current = _checked_current.flatMap { ___tree_prev_iter($0.pointer) }.seal
    // prev の結果が壊れてたらオコ！（end→start の途中で壊れた）
    guard let p = try? __current.get() else {
      fatalError(.invalidIndex)
    }
    return p.pointer
  }
}
