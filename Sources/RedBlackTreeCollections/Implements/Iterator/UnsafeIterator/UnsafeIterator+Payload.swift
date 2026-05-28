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

extension UnsafeIterator {

  public struct _Payload<Base: ___TreeBase, Source: IteratorProtocol & Sequence>:
    _UnsafeNodePtrType,
    UnsafeAssosiatedIterator,
    IteratorProtocol,
    Sequence
  where
    Base: _UnsafeNodePtrType,
    Source.Element == UnsafeMutablePointer<UnsafeNode>,
    Source: UnsafeIteratorProtocol
  {
    public var _source: Source

    @inlinable
    public init(source: Source) {
      self._source = source
    }

    #if COMPATIBLE_ATCODER_2025
      @inlinable
      public init(_ t: Base.Type, _start: _SealedPtr, _end: _SealedPtr) {
        self.init(source: .init(_start: _start, _end: _end))
      }

      @inlinable
      public var _sealed_start: _SealedPtr {
        _source._sealed_start
      }

      @inlinable
      public var _sealed_end: _SealedPtr {
        _source._sealed_end
      }
    #endif

    @inlinable
    public mutating func next() -> Base._PayloadValue? {
      guard let p = _source.next() else {
        return nil
      }
      return Base.__payload_(p)
    }
  }
}

extension UnsafeIterator._Payload: @unchecked Sendable where Source: Sendable {}

extension UnsafeIterator._Payload: ObverseIterator
where
  Source: ObverseIterator,
  Source.ReversedIterator: UnsafeIteratorProtocol & Sequence
{
  @inlinable
  public func reversed() -> UnsafeIterator._Payload<Base, Source.ReversedIterator> {
    .init(source: _source.reversed())
  }
  public typealias Reversed = UnsafeIterator._Payload<Base, Source.ReversedIterator>
}

extension UnsafeIterator._Payload: ReverseIterator
where Source: ReverseIterator {}
