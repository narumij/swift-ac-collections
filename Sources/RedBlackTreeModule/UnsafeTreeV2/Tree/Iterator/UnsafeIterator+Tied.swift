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

  public struct Tied<Source: IteratorProtocol>:
    _UnsafeNodePtrType,
    UnsafeIndexingProtocol,
    IteratorProtocol,
    Sequence
  where
    Source: UnsafeAssosiatedIterator,
    Source.Base: ___TreeBase & ___TreeIndex
  {
    public typealias Base = Source.Base

    @usableFromInline
    typealias Index = UnsafeIndexV2<Base>

    @usableFromInline
    var tied: _TiedRawBuffer

    @usableFromInline
    init(
      start: _NodePtr,
      end: _NodePtr,
      tie: _TiedRawBuffer
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

    internal init(_source: Source, tie: _TiedRawBuffer) {
      self.source = _source
      self.tied = tie
    }

    public mutating func next() -> Source.Element? {
      source.next()
    }
  }
}

extension UnsafeIterator.Tied: Equatable where Source: Equatable {

  public static func == (
    lhs: UnsafeIterator.Tied<Source>, rhs: UnsafeIterator.Tied<Source>
  ) -> Bool {
    lhs.source == rhs.source
  }
}

extension UnsafeIterator.Tied: Comparable where Source: Equatable, Element: Comparable {

  @inlinable
  @inline(__always)
  public static func < (lhs: Self, rhs: Self) -> Bool {
    lhs.lexicographicallyPrecedes(rhs)
  }
}

#if swift(>=5.5)
  extension UnsafeIterator.Tied: @unchecked Sendable
  where Source: Sendable {}
#endif

#if COMPATIBLE_ATCODER_2025
  extension UnsafeIterator.Tied {

    @available(*, deprecated, message: "性能問題があり廃止")
    @inlinable
    @inline(__always)
    public func forEach(_ body: (UnsafeIndexV2<Base>, Element) throws -> Void) rethrows
    where Source.Source.Element == UnsafeMutablePointer<UnsafeNode> {
      try zip(source._source, makeIterator()).forEach {
        try body(___index($0), $1)
      }
    }
  }
#endif

extension UnsafeIterator.Tied
where
  Source.Source.Element == UnsafeMutablePointer<UnsafeNode>
{

  /// - Complexity: O(1)
  public var indices: UnsafeIterator.TiedIndexing<Source.Base, Source.Source> {
    .init(_source: source._source, tie: tied)
  }

  @available(*, deprecated, message: "危険になった為")
  @inlinable
  @inline(__always)
  package func ___node_positions() -> Source.Source {
    // 多分lifetime延長しないとクラッシュする
    // と思ったけどしなかった。念のためlifetimeとdeprecated
    defer { _fixLifetime(self) }
    return source._source
  }
}

extension UnsafeIterator.Tied
where
  Source.Base: KeyValueComparer,
  Self: ReverseIterator
{
  #if COMPATIBLE_ATCODER_2025
    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public func keys() -> UnsafeIterator.KeyReverse<Base> {
      .init(start: source._start, end: source._end, tie: tied)
    }

    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public func values() -> UnsafeIterator.MappedValueReverse<Base> {
      .init(start: source._start, end: source._end, tie: tied)
    }
  #else
    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public var keys: UnsafeIterator.KeyReverse<Base> {
      .init(start: source._start, end: source._end, tie: tied)
    }

    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public var values: UnsafeIterator.MappedValueReverse<Base> {
      .init(start: source._start, end: source._end, tie: tied)
    }
  #endif
}

extension UnsafeIterator.Tied: ObverseIterator
where
  Source: ObverseIterator,
  Source.ReversedIterator: UnsafeAssosiatedIterator & Sequence,
  Source.ReversedIterator.Base: ___TreeBase & ___TreeIndex
{
  public func reversed() -> UnsafeIterator.Tied<Source.ReversedIterator> {
    .init(_source: source.reversed(), tie: tied)
  }
}

extension UnsafeIterator.Tied: ReverseIterator
where Source: ReverseIterator {}
