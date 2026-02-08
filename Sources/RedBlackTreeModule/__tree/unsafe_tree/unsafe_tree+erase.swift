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

@usableFromInline
protocol EraseProtocol:
  EraseInterface
    & RemoveInteface
    & DellocationInterface
{}

extension EraseProtocol {

  /// - WARNING: メモリ破壊の可能性がある。
  @inlinable
  @inline(__always)
  internal func
    erase(_ __p: _NodePtr) -> _NodePtr
  {
    let __r = __remove_node_pointer(__p)
    destroy(__p)
    return __r
  }

  /// - WARNING: メモリ破壊の可能性がある。範囲検査済みの場合にのみ用いること
  @inlinable
  @inline(__always)
  internal func
    erase(_ __f: _NodePtr, _ __l: _NodePtr) -> _NodePtr
  {
    var __f = __f
    while __f != __l {
      __f = erase(__f)
    }
    return __l
  }
}

@usableFromInline
protocol EraseUniqueProtocol:
  EraseUniqueInteface
    & FindInteface
    & EndInterface
    & EraseInterface
{}

extension EraseUniqueProtocol {

  /// メモリ破壊できない
  @inlinable
  @inline(never)
  internal func ___erase_unique(_ __k: _Key) -> Bool {
    let __i = find(__k)
    if __i == end {
      return false
    }
    _ = erase(__i)
    return true
  }
}

@usableFromInline
protocol EraseMultiProtocol:
  EraseMultiInteface
    & EqualInterface
    & EraseInterface
{}

extension EraseMultiProtocol {

  /// メモリ破壊できない
  @inlinable
  @inline(__always)
  internal func ___erase_multi(_ __k: _Key) -> Int {
    var __p = __equal_range_multi(__k)
    var __r = 0
    while __p.0 != __p.1 {
      defer { __r += 1 }
      __p.0 = erase(__p.0)
    }
    return __r
  }
}
