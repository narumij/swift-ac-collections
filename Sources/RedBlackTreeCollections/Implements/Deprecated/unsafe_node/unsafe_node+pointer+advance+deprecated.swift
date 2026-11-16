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


#if COMPATIBLE_ATCODER_2025
  @inlinable
  internal func ___form_index(
    _ i: UnsafeMutablePointer<UnsafeNode>, offsetBy distance: Int, limitedBy limit: _SafePtr,
    _ body: (_SafePtr) -> Void
  )
    -> Bool
  {
    let advanced = ___tree_adv_iter(i, distance, limit)
    switch advanced {
    case .success:
      body(advanced)
      return true
    case .failure(.limit):
      body(limit)
      return false
    default:
      return false
    }
  }
#endif
