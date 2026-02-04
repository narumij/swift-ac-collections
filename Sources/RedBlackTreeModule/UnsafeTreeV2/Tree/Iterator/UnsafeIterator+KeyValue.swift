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
    Base: ___TreeBase & KeyValueComparer,
    Source: IteratorProtocol & Sequence & UnsafeIteratorProtocol,
    Source.Element == UnsafeMutablePointer<UnsafeNode>
  {
    public init(_ t: Base.Type, _start: _SealedPtr, _end: _SealedPtr) {
      self.init(source: .init(_start: _start, _end: _end))
    }

    public
      var _source: Source

    internal init(source: Source) {
      self._source = source
    }
    
    public var _start: UnsafeMutablePointer<UnsafeNode> {
      _source._start
    }

    public var _end: UnsafeMutablePointer<UnsafeNode> {
      _source._end
    }

    public
      mutating func next() -> (key: Base._Key, value: Base._MappedValue)?
    {
      return _source.next().map {
        (
          Base.__key($0.__value_().pointee),
          Base.___mapped_value($0.__value_().pointee)
        )
      }
    }
  }
}

#if swift(>=5.5)
  extension UnsafeIterator._KeyValue: @unchecked Sendable
  where Source: Sendable {}
#endif

extension UnsafeIterator._KeyValue: ObverseIterator
where
  Source: ObverseIterator,
  Source.ReversedIterator: UnsafeIteratorProtocol & Sequence
{
  public func reversed() -> UnsafeIterator._KeyValue<Base,Source.ReversedIterator> {
    .init(source: _source.reversed())
  }
  public typealias Reversed = UnsafeIterator._KeyValue<Base,Source.ReversedIterator>
}

extension UnsafeIterator._KeyValue: ReverseIterator
where Source: ReverseIterator {}
