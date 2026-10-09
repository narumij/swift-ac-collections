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

    public struct _KeyValue<Base, Source>:
      _UnsafeNodePtrType,
      UnsafeAssosiatedIterator,
      IteratorProtocol,
      Sequence
    where
      Base: ___TreeBase & PairValueTrait,
      Source: IteratorProtocol,
      Source.Element == UnsafeMutablePointer<UnsafeNode>
    {
      public
        var _source: Source

      @inlinable
      public init(source: Source) {
        self._source = source
      }

      @inlinable
      @inline(__always)
      public mutating func next() -> (key: Base._Key, value: Base._MappedValue)? {
        _source.next().map(Base.__element_)
      }
    }
  }

extension UnsafeIterator._KeyValue: @unchecked Sendable where Source: Sendable {}

extension UnsafeIterator._KeyValue {
  /// - Complexity: O(1)
  @inlinable
  public func keys() -> UnsafeIterator._Key<Base, Source> {
    .init(source: _source)
  }

  /// - Complexity: O(1)
  @inlinable
  public func values() -> UnsafeIterator._MappedValue<Base, Source> {
    .init(source: _source)
  }
}
