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
  extension UnsafeIterator {

    public struct _Key<Base: ___TreeBase, Source: IteratorProtocol & Sequence>:
      _UnsafeNodePtrType,
      UnsafeAssosiatedIterator,
      IteratorProtocol,
      Sequence
    where
      Source.Element == UnsafeMutablePointer<UnsafeNode>,
      Source: UnsafeIteratorProtocol
    {
      public var _source: Source

      @inlinable
      public init(_ t: Base.Type, _start: _SealedPtr, _end: _SealedPtr) {
        self.init(source: .init(_start: _start, _end: _end))
      }

      @inlinable
      internal init(source: Source) {
        self._source = source
      }

      @inlinable
      public var _sealed_start: _SealedPtr {
        _source._sealed_start
      }

      @inlinable
      public var _sealed_end: _SealedPtr {
        _source._sealed_end
      }

      @inlinable
      public mutating func next() -> Base._Key? {
        return _source.next().map {
          Base.__key($0.__value_().pointee)
        }
      }
    }
  }
#else
  extension UnsafeIterator {

    public struct _Key<Base: ___TreeBase, Source>:
      _UnsafeNodePtrType,
      UnsafeAssosiatedIterator,
      IteratorProtocol,
      Sequence
    where
      Base: ___TreeBase & PairValueTrait,
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
      public mutating func next() -> Base._Key? {
        _source.next().map(Base.__key_)
      }
    }
  }
#endif

extension UnsafeIterator._Key: @unchecked Sendable where Source: Sendable {}

extension UnsafeIterator._Key: ObverseIterator
where
  Source: ObverseIterator,
  Source.ReversedIterator: UnsafeIteratorProtocol & Sequence
{
  @inlinable
  public func reversed() -> UnsafeIterator._Key<Base, Source.ReversedIterator> {
    .init(source: _source.reversed())
  }

  public typealias Reversed = UnsafeIterator._Key<Base, Source.ReversedIterator>
}

extension UnsafeIterator._Key: ReverseIterator
where Source: ReverseIterator {}
