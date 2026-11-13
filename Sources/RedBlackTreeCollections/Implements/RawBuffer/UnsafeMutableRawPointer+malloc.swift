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

#if USE_C_MALLOC
  // ジャッジ搭載時に再検討したいので残ってる
  import _malloc_free
  extension UnsafeMutableRawPointer {
    @inlinable
    static var MALLOC_ALIGN_MASK: Int {
      Int.bitWidth == 64 ? 15 : 7
    }
    static func _unsafe_malloc(byteCount: Int, alignment: Int) -> UnsafeMutableRawPointer {
      guard alignment <= MALLOC_ALIGN_MASK else {
        fatalError(.alignnment)
      }
      return malloc(byteCount)
    }
    func _unsafe_free() {
      free(self)
    }
    @inlinable
    static func _allocate(byteCount: Int, alignment: Int) -> UnsafeMutableRawPointer {
      guard alignment <= MALLOC_ALIGN_MASK else {
        fatalError(.alignnment)
      }
      return malloc(byteCount)
    }
    @inlinable
    func _deallocate() {
      free(self)
    }
  }
#else
  extension UnsafeMutableRawPointer {
    @inlinable
    static func _allocate(byteCount: Int, alignment: Int) -> UnsafeMutableRawPointer {
      #if _TREE_ALLOCATION_COUNTER
      allocatedCount += 1
      #endif
      return self.allocate(byteCount: byteCount, alignment: alignment)
    }
    @inlinable
    func _deallocate() {
      #if _TREE_ALLOCATION_COUNTER
      deallocatedCount += 1
      #endif
      self.deallocate()
    }
  }
#endif
