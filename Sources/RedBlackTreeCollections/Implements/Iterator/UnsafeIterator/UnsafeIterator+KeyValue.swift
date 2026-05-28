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

extension UnsafeIterator._KeyValue: ObverseIterator
where
  Source: ObverseIterator,
  Source.ReversedIterator: UnsafeIteratorProtocol & Sequence
{
  @inlinable
  public func reversed() -> UnsafeIterator._KeyValue<Base, Source.ReversedIterator> {
    .init(source: _source.reversed())
  }
  public typealias Reversed = UnsafeIterator._KeyValue<Base, Source.ReversedIterator>
}

extension UnsafeIterator._KeyValue: ReverseIterator
where Source: ReverseIterator {}

#if COMPATIBLE_ATCODER_2025
  extension UnsafeIterator._KeyValue {

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
  }
#endif
