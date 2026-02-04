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

    public init(_ t: Base.Type, _start: _SealedPtr, _end: _SealedPtr) {
      self.init(source: .init(_start: _start, _end: _end))
    }

    public init(tree: UnsafeTreeV2<Base>, start __first: _NodePtr, end __last: _NodePtr) {
      self.init(source: .init(_start: __first, _end: __last))
    }

    public init(_ t: Base.Type, _start: _NodePtr, _end: _NodePtr) {
      self.init(source: .init(_start: _start, _end: _end))
    }

    internal init(source: Source) {
      self._source = source
    }

    public var _start: UnsafeMutablePointer<UnsafeNode> {
      _source._start
    }

    public var _end: UnsafeMutablePointer<UnsafeNode> {
      _source._end
    }
    
    public mutating func next() -> Base._Key? {
      return _source.next().map {
        Base.__key($0.__value_().pointee)
      }
    }
  }
}

#if swift(>=5.5)
  extension UnsafeIterator._Key: @unchecked Sendable
  where Source: Sendable {}
#endif

extension UnsafeIterator._Key: ObverseIterator
where
  Source: ObverseIterator,
  Source.ReversedIterator: UnsafeIteratorProtocol & Sequence
{
  public func reversed() -> UnsafeIterator._Key<Base,Source.ReversedIterator> {
    .init(source: _source.reversed())
  }
  
  public typealias Reversed = UnsafeIterator._Key<Base,Source.ReversedIterator>
}

extension UnsafeIterator._Key: ReverseIterator
where Source: ReverseIterator {}
