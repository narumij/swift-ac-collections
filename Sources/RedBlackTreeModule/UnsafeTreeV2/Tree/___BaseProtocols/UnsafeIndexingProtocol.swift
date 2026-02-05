//
//  UnsafeIndexingProtocol.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/13.
//

/// Indexが何であるかをしり、その生成には何が必要で、どう生成するのかを知っている
@usableFromInline
protocol UnsafeIndexingProtocol: _UnsafeNodePtrType
where Index == UnsafeIndexV2<Base>
{
  associatedtype Base: ___TreeBase & ___TreeIndex
  associatedtype Index
  var tied: _TiedRawBuffer { get }
}

extension UnsafeIndexingProtocol {
  
  @inlinable
  @inline(__always)
  package func ___index(_ p: _SealedPtr) -> Index {
    Index(sealed: p, tie: tied)
  }
}
