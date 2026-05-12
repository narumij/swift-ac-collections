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

  public struct LazyDetach<Source: IteratorProtocol>:
    _UnsafeNodePtrType,
    IteratorProtocol,
    Sequence
  where
    Source: UnsafeAssosiatedIterator,
    Source.Base: ___TreeBase
  {
    public typealias Base = Source.Base

    @usableFromInline
    var tied: _LazyDetach

    @inlinable
    init(
      start: _SealedPtr,
      end: _SealedPtr,
      tie: _LazyDetach
    ) {
      self.init(
        _source: .init(
          Source.Base.self,
          _start: start,
          _end: end),
        tie: tie)
    }

    @usableFromInline
    var source: Source

    @inlinable
    internal init(_source: Source, tie: _LazyDetach) {
      self.source = _source
      self.tied = tie
    }

    @inlinable
    @inline(__always)
    public mutating func next() -> Source.Element? {
      source.next()
    }
  }
}

extension UnsafeIterator.LazyDetach: Equatable where Source: Equatable {

  @inlinable
  public static func == (
    lhs: UnsafeIterator.LazyDetach<Source>, rhs: UnsafeIterator.LazyDetach<Source>
  ) -> Bool {
    lhs.source == rhs.source
  }
}

extension UnsafeIterator.LazyDetach: Comparable where Source: Equatable, Element: Comparable {

  @inlinable
  public static func < (lhs: Self, rhs: Self) -> Bool {
    lhs.lexicographicallyPrecedes(rhs)
  }
}

extension UnsafeIterator.LazyDetach: @unchecked Sendable where Source: Sendable {}

extension UnsafeIterator.LazyDetach
where
  Source.Base: PairValueTrait,
  Base: ___TreeIndex,
  Self: ReverseIterator
{
  #if !COMPATIBLE_ATCODER_2025
    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public var keys: UnsafeIterator.KeyReverse<Base> {
      .init(start: source._sealed_start, end: source._sealed_end, tie: tied)
    }

    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public var values: UnsafeIterator.MappedValueReverse<Base> {
      .init(start: source._sealed_start, end: source._sealed_end, tie: tied)
    }
  #endif
}

extension UnsafeIterator.LazyDetach: ObverseIterator
where
  Source: ObverseIterator,
  Source.ReversedIterator: UnsafeAssosiatedIterator & Sequence,
  Source.ReversedIterator.Base: ___TreeBase
{
  @inlinable
  public func reversed() -> UnsafeIterator.LazyDetach<Source.ReversedIterator> {
    .init(_source: source.reversed(), tie: tied)
  }
}

extension UnsafeIterator.LazyDetach: ReverseIterator
where Source: ReverseIterator {}
