//
//  ___UnsafePoolHolder.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/17.
//

extension UnsafeIterator {

  public struct Movable<Source: IteratorProtocol>:
    _UnsafeNodePtrType,
    UnsafeImmutableIndexingProtocol,
    IteratorProtocol,
    Sequence
  where
    Source: UnsafeAssosiatedIterator,
    Source.Base: ___TreeIndex
  {
    @usableFromInline
    var __tree_: UnsafeImmutableTree<Base>?

    public typealias Base = Source.Base

    @usableFromInline
    typealias Index = UnsafeIndexV2<Base>

    @usableFromInline
    var tied: _TiedRawBuffer

    @usableFromInline
    init(
      tree: UnsafeTreeV2<Source.Base>,
      start: _NodePtr,
      end: _NodePtr
    ) {
      self.init(
        source: .init(
          tree: tree,
          start: start,
          end: end),
        tie: tree.tied)
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

extension UnsafeIterator.Movable: Equatable where Source: Equatable {

  public static func == (
    lhs: UnsafeIterator.Movable<Source>, rhs: UnsafeIterator.Movable<Source>
  ) -> Bool {
    lhs.source == rhs.source
  }
}

extension UnsafeIterator.Movable: Comparable where Source: Equatable, Element: Comparable {

  @inlinable
  @inline(__always)
  public static func < (lhs: Self, rhs: Self) -> Bool {
    lhs.lexicographicallyPrecedes(rhs)
  }
}

#if swift(>=5.5)
  extension UnsafeIterator.Movable: @unchecked Sendable
  where Source: Sendable {}
#endif

#if COMPATIBLE_ATCODER_2025
extension UnsafeIterator.Movable {

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

extension UnsafeIterator.Movable
where
  Source.Source.Element == UnsafeMutablePointer<UnsafeNode>
{

  /// - Complexity: O(1)
  public var indices: UnsafeIterator.Indexing<Source.Base, Source.Source> {
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
