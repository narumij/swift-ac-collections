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

  extension UnsafeIterator {

    public struct _Payload<Base: ___TreeBase, Source>:
      _UnsafeNodePtrType,
      UnsafeAssosiatedIterator,
      IteratorProtocol,
      Sequence
    where
      Base: _UnsafeNodePtrType,
      Source.Element == UnsafeMutablePointer<UnsafeNode>,
      Source: IteratorProtocol
    {
      public var _source: Source

      @inlinable
      public init(source: Source) {
        self._source = source
      }

      @inlinable
      @inline(__always)
      public mutating func next() -> Base._PayloadValue? {
        _source.next().map(Base.__payload_)
      }
    }
  }

extension UnsafeIterator._Payload: @unchecked Sendable where Source: Sendable {}
