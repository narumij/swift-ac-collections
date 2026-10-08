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

extension UnsafeTreeV2 where Base: ScalarValueTrait {

  @usableFromInline
  typealias Handle = UnsafeTreeV2KeyOnlyHandle<UnsafeTreeV2<Base>._PayloadValue>

  #if false
    @inlinable
    @inline(__always)
    internal func read<R>(_ body: (Handle) throws -> R) rethrows -> R {
      try _buffer.withUnsafeMutablePointers { header, elements in
        let handle = Handle(
          header: header, isMulti: isMulti)
        return try body(handle)
      }
    }
  #endif

  @inlinable
  @inline(__always)
  internal func update<R>(_ body: (Handle) throws -> R) rethrows -> R {
    try _buffer.withUnsafeMutablePointers { header, elements in
      let handle = Handle(
        header: header, isMulti: isMulti)
      return try body(handle)
    }
  }
}

extension UnsafeTreeV2 where Base: PairValueTrait {

  @usableFromInline
  typealias KeyValueHandle = UnsafeTreeV2KeyValueHandle<_Key, Base._MappedValue>

  #if false
    @inlinable
    @inline(__always)
    internal func read<R>(_ body: (KeyValueHandle) throws -> R) rethrows -> R {
      try _buffer.withUnsafeMutablePointers { header, elements in
        let handle = KeyValueHandle(header: header, isMulti: isMulti)
        return try body(handle)
      }
    }
  #endif

  @inlinable
  @inline(__always)
  internal func update<R>(_ body: (KeyValueHandle) throws -> R) rethrows -> R {
    try _buffer.withUnsafeMutablePointers { header, elements in
      let handle = KeyValueHandle(header: header, isMulti: isMulti)
      return try body(handle)
    }
  }
}
