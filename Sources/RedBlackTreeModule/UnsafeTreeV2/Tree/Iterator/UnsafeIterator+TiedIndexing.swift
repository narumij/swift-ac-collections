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

  public struct TiedIndexing<Base, Source: IteratorProtocol>:
    _UnsafeNodePtrType,
    UnsafeIndexingProtocol_tie,
    IteratorProtocol,
    Sequence
  where
    Base: ___TreeBase & ___TreeIndex,
    Source: Sequence,
    Source.Element == UnsafeMutablePointer<UnsafeNode>
  {
    @usableFromInline
    typealias Index = UnsafeIndexV2<Base>

    @usableFromInline
    var tied: _TiedRawBuffer
    
    @usableFromInline
    init(
      start: _SealedPtr,
      end: _SealedPtr,
      tie: _TiedRawBuffer
    ) where Source: UnsafeIteratorProtocol {
      self.init(
        _source: .init(
          _start: start,
          _end: end),
        tie: tie)
    }

    @usableFromInline
    var source: Source

    internal init(_source: Source, tie: _TiedRawBuffer) {
      self.source = _source
      self.tied = tie
    }

    public mutating func next() -> UnsafeIndexV2<Base>? {
      source.next().map {
        ___index($0.sealed)
      }
    }
  }
}

extension UnsafeIterator.TiedIndexing: Equatable where Source: Equatable {

  public static func == (
    lhs: UnsafeIterator.TiedIndexing<Base, Source>, rhs: UnsafeIterator.TiedIndexing<Base, Source>
  ) -> Bool {
    lhs.source == rhs.source
  }
}

#if swift(>=5.5)
  extension UnsafeIterator.TiedIndexing: @unchecked Sendable
  where Source: Sendable {}
#endif

#if COMPATIBLE_ATCODER_2025
extension UnsafeIterator.TiedIndexing: Comparable where Source: Equatable, Element: Comparable {

  @inlinable
  @inline(__always)
  public static func < (lhs: Self, rhs: Self) -> Bool {
    lhs.lexicographicallyPrecedes(rhs)
  }
}
#endif

extension UnsafeIterator.TiedIndexing: ObverseIterator
where
  Source: ObverseIterator,
  Source.ReversedIterator: UnsafeIteratorProtocol & Sequence
{
  public func reversed() -> UnsafeIterator.TiedIndexing<Base,Source.ReversedIterator> {
    .init(_source: source.reversed(), tie: tied)
  }
  public typealias Reversed = UnsafeIterator.TiedIndexing<Base,Source.ReversedIterator>
}

extension UnsafeIterator.TiedIndexing: ReverseIterator
where Source: ReverseIterator {}
