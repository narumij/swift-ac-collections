//
//  Indexing.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/17.
//

//
//  ___UnsafePoolHolder.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/17.
//

extension UnsafeIterator {

  public struct Indexing<Base, Source: IteratorProtocol>:
    _UnsafeNodePtrType,
    UnsafeImmutableIndexingProtocol,
    IteratorProtocol,
    Sequence
  where
    Base: ___TreeBase & ___TreeIndex,
    Source: Sequence,
    Source.Element == UnsafeMutablePointer<UnsafeNode>
  {
    @usableFromInline
    var __tree_: UnsafeImmutableTree<Base>

    @usableFromInline
    typealias Index = UnsafeIndexV2<Base>

    @usableFromInline
    typealias PoolLifespan = Deallocator

    @usableFromInline
    var poolLifespan: _UnsafeNodeFreshPoolV3DeallocatorR2

    @usableFromInline
    init(
      tree: UnsafeTreeV2<Base>,
      start: _NodePtr,
      end: _NodePtr
    ) where Source: UnsafeIteratorProtocol {
      self.init(
        __tree_: .init(__tree_: tree),
        source: .init(
          tree: tree,
          start: start,
          end: end),
        pool: tree.poolLifespan)
    }

    @usableFromInline
    init(
      __tree_: UnsafeImmutableTree<Base>,
      start: _NodePtr,
      end: _NodePtr,
      poolLifespan: Deallocator
    ) where Source: UnsafeIteratorProtocol {
      self.init(
        __tree_: __tree_,
        source: .init(
          __tree_: __tree_,
          start: start,
          end: end),
        pool: poolLifespan)
    }

    @usableFromInline
    var source: Source

    internal init(__tree_: UnsafeImmutableTree<Base>, source: Source, pool: Deallocator) {
      self.source = source
      self.poolLifespan = pool
      self.__tree_ = __tree_
    }

    public mutating func next() -> UnsafeIndexV2<Base>? {
      source.next().map {
        ___index($0)
      }
    }
  }
}

extension UnsafeIterator.Indexing: Equatable where Source: Equatable {

  public static func == (
    lhs: UnsafeIterator.Indexing<Base, Source>, rhs: UnsafeIterator.Indexing<Base, Source>
  ) -> Bool {
    lhs.source == rhs.source
  }
}

#if swift(>=5.5)
  extension UnsafeIterator.Indexing: @unchecked Sendable
  where Source: Sendable {}
#endif

extension UnsafeIterator.Indexing: Comparable where Source: Equatable, Element: Comparable {

  @inlinable
  @inline(__always)
  public static func < (lhs: Self, rhs: Self) -> Bool {
    lhs.lexicographicallyPrecedes(rhs)
  }
}
