//
//  ___UnsafePoolHolder.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/17.
//

extension UnsafeIterator {

  public struct Tied<Source: IteratorProtocol>:
    _UnsafeNodePtrType,
    UnsafeImmutableIndexingProtocol,
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
        source: .init(
          Source.Base.self,
          start: start,
          end: end),
        tie: tie)
    }

    @usableFromInline
    var source: Source

    internal init(source: Source, tie: _TiedRawBuffer) {
      self.source = source
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
      try zip(source.source, makeIterator()).forEach {
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
    .init(source: source.source, tie: tied)
  }

  @available(*, deprecated, message: "危険になった為")
  @inlinable
  @inline(__always)
  package func ___node_positions() -> Source.Source {
    // 多分lifetime延長しないとクラッシュする
    // と思ったけどしなかった。念のためlifetimeとdeprecated
    defer { _fixLifetime(self) }
    return source.source
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
    public func keys() -> RedBlackTreeIteratorV2<Base>.Keys.Reversed {
      .init(start: source._start, end: source._end, tie: tied)
    }

    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public func values() -> RedBlackTreeIteratorV2<Base>.MappedValues.Reversed {
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
    .init(source: source.reversed(), tie: tied)
  }
}

extension UnsafeIterator.Tied: ReverseIterator
where Source: ReverseIterator {}
