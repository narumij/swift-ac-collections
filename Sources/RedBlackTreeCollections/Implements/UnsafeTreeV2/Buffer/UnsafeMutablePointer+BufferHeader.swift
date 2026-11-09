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

import Synchronization

#if ENABLE_EXPERIMENTAL_TSAN_SAFE

extension UnsafeMutablePointer where Pointee == UnsafeTreeV2BufferHeader {
  
  @inlinable
  func index(_ p: UnsafeMutablePointer<UnsafeNode>) -> _LazyTiedPtrV2 {
    assert(p != .nullptr)
    let tie = UnsafeTreeV2BufferHeader._loadLazyDetach(at: pointer(to: \._lazyDetach)!)
    return .unchecked(p, end_ptr: pointee.end_ptr, lazyDetach: tie)
  }
  
  @inlinable
  func index_or_nil(_ p: UnsafeMutablePointer<UnsafeNode>) -> _LazyTiedPtrV2? {
    p.___has_payload_content ? .some(index(p)) : .none
  }
}

#endif
