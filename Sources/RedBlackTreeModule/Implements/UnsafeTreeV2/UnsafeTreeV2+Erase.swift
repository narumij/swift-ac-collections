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

extension UnsafeTreeV2 {

  /// 末尾チェック付きの削除ループ
  ///
  /// 対応する末尾チェック無しは`__tree`のerase(_:_:)となる
  @inlinable
  @discardableResult
  func ___erase(_ __first: _NodePtr, _ __last: _NodePtr) -> _NodePtr {

    var __first = __first
    while __first != __last {
      guard !__first.___is_end else {
        fatalError(.outOfBounds)
      }
      __first = erase(__first)
    }
    return __last
  }

  /// 末尾チェック付きの削除ループ
  @inlinable
  @discardableResult
  func ___erase_if(
    _ __first: _SealedPtr, _ __last: _SealedPtr,
    _ shouldBeRemoved: (_PayloadValue) throws -> Bool
  ) rethrows -> _SealedPtr {

    var __first = __first
    while __first != __last {
      guard __first.exists else {
        return .failure(.upperOutOfBounds)
      }
      if try shouldBeRemoved(__value_(__first.pointer!)) {
        __first = erase(__first.purified.pointer!).sealed
      } else {
        __first = ___tree_next_iter(__first.purified.pointer!).sealed
      }
    }
    return __last
  }
}
