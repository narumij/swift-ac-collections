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

@inlinable
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
internal func
  ___safe_distance(
    _ __first: UnsafeMutablePointer<UnsafeNode>,
    _ __last: UnsafeMutablePointer<UnsafeNode>
  )
  -> Result<Int, SealError>
{
  var __first: _SafePtr = .success(__first)
  var __r = 0
  while case .success(let ___f) = __first, ___f != __last {
    __first = ___tree_next_iter(___f)
    __r += 1
  }
  return __first.map { _ in __r }
}
