//
//  UnsafeIndexingProtocol.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/13.
//

@usableFromInline
protocol UnsafeIndexingProtocol: _UnsafeNodePtrType
where
  Index == UnsafeIndexV2<Base>
{
  associatedtype Base: ___TreeBase & ___TreeIndex
  associatedtype Index
  var tied: _TiedRawBuffer { get }
}

extension UnsafeIndexingProtocol {
  @inlinable
  @inline(__always)
  package func ___index(_ p: _NodePtr) -> Index {
    Index(rawValue: p, tie: tied)
  }
}
