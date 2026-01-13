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
  Deallocator == _UnsafeNodeFreshPoolDeallocator
{
  associatedtype Base: ___TreeBase & ___TreeIndex
  associatedtype Index
  associatedtype Deallocator
  var __tree_: UnsafeImmutableTree<Base> { get }
  var deallocator: Deallocator { get }
}

extension UnsafeImmutableIndexingProtocol {
  @inlinable
  @inline(__always)
  package func ___index(_ p: _NodePtr) -> Index {
    .init(
      __tree_: __tree_,
      rawValue: p,
      deallocator: deallocator)
  }
}
