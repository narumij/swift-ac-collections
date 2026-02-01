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
  var ___from: _NodePtr
  var ___to: _NodePtr
  @usableFromInline
  internal init(___from: _NodePtr, ___to: _NodePtr) {
    self.___from = ___from
    self.___to = ___to
  }
}

extension UnsafeTreeSafeRange {

//  func boundsCheckedNext(after __current: inout _NodePtr) -> SafePtr? {
//    guard __current != ___to else { return nil }
//    let __r = __current
//    __current = try? ___tree_next_iter(__current).get()
//    return __r
//  }

//  func boundsCheckedNext(before __current: inout SafePtr) -> _NodePtr? {
//    __current = __current.checked
//    guard __current != ___from.checked else { return nil }
//    __current = __current.flatMap { ___tree_prev_iter($0) }
//    return try? __current.map { $0.checked }.get()
//  }
}
