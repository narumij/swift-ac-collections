//
//  UnsafeTreeProtocol.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/13.
//



@usableFromInline
package protocol UnsafeTreeProtocol
where
  Tree == UnsafeTreeV2<Base>,
  ImmutableTree == UnsafeImmutableTree<Base>
{
  associatedtype Base: ___TreeBase
  associatedtype Tree
  associatedtype ImmutableTree
}
