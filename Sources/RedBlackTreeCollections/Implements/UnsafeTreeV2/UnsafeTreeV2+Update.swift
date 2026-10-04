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

extension UnsafeTreeV2 where Base: _ScalarBaseType {
  
  @inlinable
  internal func swap_key(_ __i: _NodePtr,_ __j: _NodePtr) -> Bool {
    if __i == __j {
        return true
    }
    guard Base.__key_(__i) == Base.__key_(__j) else {
      return false
    }
    Swift.swap(
      &Base.__key_ptr(__i).pointee,
      &Base.__key_ptr(__j).pointee)
    return true
  }
}

extension UnsafeTreeV2 where Base: _PairBaseType {
  
  @inlinable
  internal func swap_mapped_value(_ __i: _NodePtr,_ __j: _NodePtr) {
    if __i == __j {
        return
    }
    Swift.swap(
      &Base.__mapped_value_ptr(__i).pointee,
      &Base.__mapped_value_ptr(__j).pointee)
  }
}
