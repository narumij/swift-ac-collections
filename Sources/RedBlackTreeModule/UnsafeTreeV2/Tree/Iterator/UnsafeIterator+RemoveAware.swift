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

  public struct _RemoveAware<Source: IteratorProtocol>:
    _UnsafeNodePtrType,
    UnsafeIteratorProtocol,
    IteratorProtocol,
    Sequence
  where
    Source.Element == UnsafeMutablePointer<UnsafeNode>,
    Source: UnsafeIteratorProtocol
  {
    public init(_start: _SealedPtr, _end: _SealedPtr) {
      self.init(source: .init(_start: _start, _end: _end))
    }
    
    public var _sealed_start: _SealedPtr {
      source._sealed_start
    }

    public var _sealed_end: _SealedPtr {
      source._sealed_end
    }

    var __current: Source.Element?

    @usableFromInline var source: Source
    @usableFromInline
    internal init(source: Source) {
      var it = source
      self.__current = it.next()
      self.source = it
    }

    public mutating func next() -> _NodePtr? {
      guard let __current else { return nil }
      guard !__current.pointee.isGarbaged else {
        fatalError(.invalidIndex)
      }
      self.__current = source.next()
      return __current
    }
  }
}

extension UnsafeIterator._RemoveAware: ObverseIterator
where
  Source: ObverseIterator,
  Source.ReversedIterator: UnsafeIteratorProtocol
{
  public func reversed() -> UnsafeIterator._RemoveAware<Source.ReversedIterator> {
    .init(source: source.reversed())
  }
  public typealias Reversed = UnsafeIterator._RemoveAware<Source.ReversedIterator>
}

extension UnsafeIterator._RemoveAware: Equatable where Source: Equatable {}

extension UnsafeIterator._RemoveAware: ReverseIterator
where Source: ReverseIterator {}

#if swift(>=5.5)
  extension UnsafeIterator._RemoveAware: @unchecked Sendable
  where Source: Sendable {}
#endif
