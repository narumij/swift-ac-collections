//
//  UnsafeIndexV2RangeExpression.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/20.
//

@frozen
public struct UnsafeIndexV2RangeExpression<Base>: UnsafeTreeProtocol, UnsafeImmutableIndexingProtocol
where Base: ___TreeBase & ___TreeIndex {

  public typealias Tree = UnsafeTreeV2<Base>
  public typealias Pointee = Tree.Pointee

  @usableFromInline
  typealias _Value = Tree._Value

  @usableFromInline
  internal let __tree_: ImmutableTree

  @usableFromInline
  internal var rawValue: UnsafeTreeRangeExpression

  @usableFromInline
  internal var poolLifespan: PoolLifespan

  // MARK: -

  @inlinable
  @inline(__always)
  internal init(tree: Tree, rawValue: UnsafeTreeRangeExpression) {
    self.rawValue = rawValue
    self.poolLifespan = tree.poolLifespan
    self.__tree_ = .init(__tree_: tree)
  }

  @inlinable
  @inline(__always)
  internal init(
    __tree_: ImmutableTree,
    rawValue: UnsafeTreeRangeExpression,
    poolLifespan: PoolLifespan
  ) {
    self.__tree_ = __tree_
    self.rawValue = rawValue
    self.poolLifespan = poolLifespan
  }
}

extension UnsafeIndexV2RangeExpression: Sequence {
  
  public func makeIterator() -> UnsafeIterator.IndexObverse<Base> {
    let (l,u) = rawValue.pair(_begin: __tree_.__begin_node_, _end: __tree_.__end_node)
    return UnsafeIterator.IndexObverse<Base>(__tree_: __tree_, start: l, end: u, poolLifespan: poolLifespan)
  }
}
