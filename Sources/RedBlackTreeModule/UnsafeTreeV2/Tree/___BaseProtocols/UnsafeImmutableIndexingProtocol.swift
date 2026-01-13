//
//  UnsafeIndexingProtocol.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/13.
//

@usableFromInline
protocol UnsafeImmutableIndexingProtocol: UnsafeTreePointer
where
  Index == UnsafeIndexV2<Base>,
  PoolLifespan == _UnsafeNodeFreshPoolDeallocator
{
  associatedtype Base: ___TreeBase & ___TreeIndex
  associatedtype Index
  // TODO: 寿命延長を表す名前を検討する
  associatedtype PoolLifespan
  var __tree_: UnsafeImmutableTree<Base> { get }
  // TODO: 寿命延長を表す名前を検討する
  var poolLifespan: PoolLifespan { get }
}

extension UnsafeImmutableIndexingProtocol {
  @inlinable
  @inline(__always)
  package func ___index(_ p: _NodePtr) -> Index {
    .init(
      __tree_: __tree_,
      rawValue: p,
      poolLifespan: poolLifespan)
  }
}
