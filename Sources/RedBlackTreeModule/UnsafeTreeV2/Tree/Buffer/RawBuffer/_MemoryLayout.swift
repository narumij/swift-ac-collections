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

@frozen
@usableFromInline
package struct _MemoryLayout {

  #if DEBUG
    internal init<T>(_ t: T.Type) {
      self = MemoryLayout<T>._memoryLayout
    }
  #endif

  @inlinable
  internal init<T0, T1>(_ t0: T0.Type, _ t1: T1.Type) {
    self.stride = MemoryLayout<T0>.stride + MemoryLayout<T1>.stride
    self.alignment = max(MemoryLayout<T0>.alignment, MemoryLayout<T1>.alignment)
  }

  @inlinable
  internal init(stride: Int, alignment: Int) {
    self.stride = stride
    self.alignment = alignment
  }

  @usableFromInline package var stride: Int
  @usableFromInline package var alignment: Int
}
