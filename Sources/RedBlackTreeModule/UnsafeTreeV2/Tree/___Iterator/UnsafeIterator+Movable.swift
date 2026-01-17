//
//  ___UnsafePoolHolder.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/17.
//

extension UnsafeIterator {
  
  public struct Movable<Source: IteratorProtocol>:
    UnsafeTreePointer,
    UnsafeImmutableIndexingProtocol,
    IteratorProtocol,
    Sequence
  where
  Source: UnsafeAssosiatedIterator,
  Source.Base: ___TreeIndex
  {
    @usableFromInline
    var __tree_: UnsafeImmutableTree<Base>
    
    public typealias Base = Source.Base
    
    @usableFromInline
    typealias Index = UnsafeIndexV2<Base>
    
    @usableFromInline
    typealias PoolLifespan = Deallocator
    
    @usableFromInline
    var poolLifespan: _UnsafeNodeFreshPoolV3DeallocatorR2
    
    @usableFromInline
    init(
      tree: UnsafeTreeV2<Source.Base>,
      start: _NodePtr,
      end: _NodePtr
    ) {
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
      __tree_: UnsafeImmutableTree<Source.Base>,
      start: _NodePtr,
      end: _NodePtr,
      poolLifespan: Deallocator
    ) {
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

#if swift(>=5.5)
extension UnsafeIterator.Movable: @unchecked Sendable
  where Source: Sendable {}
#endif

extension UnsafeIterator.Movable: Comparable where Source: Equatable, Element: Comparable {

  @inlinable
  @inline(__always)
  public static func < (lhs: Self, rhs: Self) -> Bool {
    lhs.lexicographicallyPrecedes(rhs)
  }
}
