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

extension UnsafeTreeV2 {

  @inlinable
  @inline(__always)
  internal func withMutableHeader<R>(
    _ body: (inout UnsafeTreeV2BufferHeader) throws -> R
  )
    rethrows -> R
  {
    // withUnsafeMutablePointerToHeaderだとスタックが一個ふえてみづらいので
    try _buffer.withUnsafeMutablePointers { header, _ in
      return try body(&header.pointee)
    }
  }
}
