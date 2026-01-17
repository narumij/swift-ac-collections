//
//  ___UnsafePoolHolder.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/17.
//

extension UnsafeIterator {
  
  public struct Movable<Source: IteratorProtocol>:
    UnsafeTreePointer,
    IteratorProtocol,
    Sequence
  where
  Source.Element == UnsafeMutablePointer<UnsafeNode>,
  Source: UnsafeAssosiatedIterator
  {
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
        source: .init(
          __tree_: __tree_,
          start: start,
          end: end),
        pool: poolLifespan)
    }
    
    var source: Source
    let pool: Deallocator
    
    internal init(source: Source, pool: Deallocator) {
      self.source = source
      self.pool = pool
    }
    
    public mutating func next() -> Source.Base._Value? {
      return source.next().map {
        $0.__value_().pointee
      }
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
