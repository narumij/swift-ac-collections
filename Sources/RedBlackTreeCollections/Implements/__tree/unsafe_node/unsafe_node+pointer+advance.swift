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

@inlinable
@inline(__always)
internal func
  ___tree_next_iter(_ __x: UnsafeMutablePointer<UnsafeNode>) -> _SafePtr
{
  __x.___is_end
    // endへの操作は失敗
    ? .failure(.upperOutOfBounds)
    : .success(__tree_next_iter(__x))
}

/// Returns:  pointer to the previous in-order node before `__x`.
/// Note: `__x` may be the end node.
@inlinable
@inline(__always)
internal func
  ___tree_prev_iter(_ __x: UnsafeMutablePointer<UnsafeNode>) -> _SafePtr
{
  let __x = __tree_prev_iter(__x)
  // nullptrの発生は失敗
  return __x.___is_null
    ? .failure(.lowerOutOfBounds)
    : .success(__x)
}

@inlinable
@inline(__always)
internal func
  ___tree_adv_iter(_ __x: UnsafeMutablePointer<UnsafeNode>, _ __n: Int)
  -> _SafePtr
{
  var __x: _SafePtr = .success(__x)

  var __n = __n
  if __n < 0 {
    while __n != 0 {
      __x = __x.flatMap { ___tree_prev_iter($0) }
      __n += 1
    }
  } else {
    while __n != 0 {
      __x = __x.flatMap { ___tree_next_iter($0) }
      __n -= 1
    }
  }

  return __x
}

@inlinable
@inline(__always)
internal func
  ___tree_adv_iter(_ __x: UnsafeMutablePointer<UnsafeNode>, _ __n: Int, _ __l: _SafePtr)
  -> _SafePtr
{
  var __x: _SafePtr = .success(__x)

  var __n = __n
  if __n < 0 {
    while __n != 0 {
      guard __x != __l else { return .failure(.limit) }
      __x = __x.flatMap { ___tree_prev_iter($0) }
      __n += 1
    }
  } else {
    while __n != 0 {
      guard __x != __l else { return .failure(.limit) }
      __x = __x.flatMap { ___tree_next_iter($0) }
      __n -= 1
    }
  }

  return __x
}
