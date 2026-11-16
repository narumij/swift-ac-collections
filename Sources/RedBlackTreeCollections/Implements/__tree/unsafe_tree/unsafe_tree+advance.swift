//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-ac-collections project.
//
// Copyright (c) 2024-2026 narumij.
// Licensed under the Apache License v2.0.
//
// SPDX-License-Identifier: Apache-2.0
//
// This implementation includes code derived from LLVM libc++'s red-black tree
// implementation, originally distributed under the Apache License v2.0 with
// LLVM Exceptions.
//
// Copyright © 2003-2026 The LLVM Project.
// Licensed under the Apache License v2.0 with LLVM Exceptions.
// The original license can be found at https://llvm.org/LICENSE.txt
//
// This Swift implementation includes modifications and adaptations made by
// narumij.
//
//===----------------------------------------------------------------------===//

@usableFromInline
protocol TreeAdvanceProtocol_ptr:
  ~Copyable,
  _UnsafeNodePtrType
    & NullPtrInterface
    & EndNodeInterface
{}

extension TreeAdvanceProtocol_ptr where Self: ~Copyable {

  @inlinable
  func
    ___tree_next_iter(_ __x: UnsafeMutablePointer<UnsafeNode>) -> _SafePtr
  {
    if __x == __end_node {
      // endへの操作は失敗
      return .failure(.upperOutOfBounds)
    }
    let __x = __tree_next_iter(__x)
    // nullptrの発生は失敗
    return __x == nullptr
      ? .failure(.upperOutOfBounds)
      : .success(__x)
  }

  /// Returns:  pointer to the previous in-order node before `__x`.
  /// Note: `__x` may be the end node.
  @inlinable
  func
    ___tree_prev_iter(_ __x: _NodePtr) -> _SafePtr
  {
    let __x = __tree_prev_iter(__x)
    // nullptrの発生は失敗
    return __x == nullptr
      ? .failure(.lowerOutOfBounds)
      : .success(__x)
  }

  @inlinable
  func
    ___tree_adv_iter(
      _ __x: _NodePtr,
      _ __n: Int
    )
    -> _SafePtr
  {
    var __x: _SafePtr = .success(__x)

    var __n = __n
    if __n < 0 {
      while __n != 0 {
        __x = __x.flatMap { ___tree_prev_iter($0) }
        if case .failure = __x { return __x }
        __n &+= 1
      }
    } else {
      while __n != 0 {
        __x = __x.flatMap { ___tree_next_iter($0) }
        if case .failure = __x { return __x }
        __n &-= 1
      }
    }

    return __x
  }

  @inlinable
  func
    ___tree_adv_iter(
      _ __x: _NodePtr,
      _ __n: Int,
      _ __l: _SafePtr
    )
    -> _SafePtr
  {
    var __x: _SafePtr = .success(__x)

    var __n = __n
    if __n < 0 {
      while __n != 0 {
        guard __x != __l else { return .failure(.limit) }
        __x = __x.flatMap { ___tree_prev_iter($0) }
        if case .failure = __x { return __x }
        __n &+= 1
      }
    } else {
      while __n != 0 {
        guard __x != __l else { return .failure(.limit) }
        __x = __x.flatMap { ___tree_next_iter($0) }
        if case .failure = __x { return __x }
        __n &-= 1
      }
    }

    return __x
  }
}
