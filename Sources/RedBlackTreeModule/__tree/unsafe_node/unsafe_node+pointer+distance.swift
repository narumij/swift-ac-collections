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

// ノードの高さを数える
@inlinable
@inline(__always)
internal func ___ptr_height(_ __p: UnsafeMutablePointer<UnsafeNode>) -> Int {
  assert(!__p.___is_null, "Node shouldn't be null")
  var __h = 0
  var __p = __p
  while !__p.___is_root {
    __p = __p.__parent_
    __h += 1
  }
  return __h
}

// 遅い
@inlinable
@inline(__always)
internal func
  ___dual_distance(
    _ __first: UnsafeMutablePointer<UnsafeNode>,
    _ __last: UnsafeMutablePointer<UnsafeNode>
  )
  -> Int
{
  var __next = __first
  var __prev = __first
  var __r = 0
  while __next != __last, __prev != __last {
    __next = __next.___is_null ? __next : __tree_next(__next)
    __prev = __prev.___is_null ? __prev : __tree_prev_iter(__prev)
    __r += 1
  }
  return __next == __last ? __r : -__r
}

@inlinable
@inline(__always)
internal func
  __distance(
    _ __first: UnsafeMutablePointer<UnsafeNode>,
    _ __last: UnsafeMutablePointer<UnsafeNode>
  )
  -> Int
{
  var __first = __first
  var __r = 0
  while __first != __last {
    __first = __tree_next(__first)
    __r += 1
  }
  return __r
}

@inlinable
@inline(__always)
internal func
  ___safe_distance(
    _ __first: UnsafeMutablePointer<UnsafeNode>,
    _ __last: UnsafeMutablePointer<UnsafeNode>
  )
  -> Result<Int, SafePtrError>
{
  var __first = _SafePtr.success(__first)
  var __r = 0
  while case .success(let ___f) = __first, ___f != __last {
    __first = ___tree_next_iter(___f)
    __r += 1
  }
  return __first.map { _ in __r }
}
