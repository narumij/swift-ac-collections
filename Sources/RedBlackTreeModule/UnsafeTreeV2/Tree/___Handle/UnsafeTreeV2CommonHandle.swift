// Copyright 2024-2026 narumij
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// This code is based on work originally distributed under the Apache License 2.0 with LLVM Exceptions:
//
// Copyright © 2003-2025 The LLVM Project.
// Licensed under the Apache License, Version 2.0 with LLVM Exceptions.
// The original license can be found at https://llvm.org/LICENSE.txt
//
// This Swift implementation includes modifications and adaptations made by narumij.

extension UnsafeTreeV2 {

  /// 遅い。注意が必要
  @inlinable
  @inline(__always)
  internal func withHeader<R>(
    _ body: (UnsafeTreeV2BufferHeader<_Value>) throws -> R
  )
    rethrows -> R
  {
    // withUnsafeMutablePointerToHeaderだとスタックが一個ふえてみづらいので
    try _buffer.withUnsafeMutablePointers { header, _ in
      return try body(header.pointee)
    }
  }

  @inlinable
  @inline(__always)
  internal func withMutableHeader<R>(
    _ body: (inout UnsafeTreeV2BufferHeader<_Value>) throws -> R
  )
    rethrows -> R
  {
    // withUnsafeMutablePointerToHeaderだとスタックが一個ふえてみづらいので
    try _buffer.withUnsafeMutablePointers { header, _ in
      return try body(&header.pointee)
    }
  }

  @inlinable
  @inline(__always)
  internal func withOrigin<R>(
    _ body: (UnsafeTreeV2Origin) throws -> R
  )
    rethrows -> R
  {
    // withUnsafeMutablePointerToElementsだとスタックが一個ふえてみづらいので
    try _buffer.withUnsafeMutablePointers { _, origin in
      return try body(origin.pointee)
    }
  }

  @inlinable
  @inline(__always)
  internal func withMutableOrigin<R>(
    _ body: (inout UnsafeTreeV2Origin) throws -> R
  )
    rethrows -> R
  {
    // withUnsafeMutablePointerToElementsだとスタックが一個ふえてみづらいので
    try _buffer.withUnsafeMutablePointers { _, origin in
      return try body(&origin.pointee)
    }
  }

  @inlinable
  @inline(__always)
  internal func withImmutables<R>(
    _ body: (
      UnsafeTreeV2BufferHeader<_Value>,
      UnsafeTreeV2Origin
    ) throws -> R
  ) rethrows -> R {
    try _buffer.withUnsafeMutablePointers { header, elements in
      return try body(header.pointee, elements.pointee)
    }
  }

  @inlinable
  @inline(__always)
  internal func withMutables<R>(
    _ body: (
      inout UnsafeTreeV2BufferHeader<_Value>,
      inout UnsafeTreeV2Origin
    ) throws -> R
  ) rethrows -> R {
    try _buffer.withUnsafeMutablePointers { header, elements in
      return try body(&header.pointee, &elements.pointee)
    }
  }
}
