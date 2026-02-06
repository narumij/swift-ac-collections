//
//  UnsafeIndexingProtocol.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/13.
//

public protocol UnsafeIndexBinding: UnsafeTreeBinding
where Index == UnsafeTreeV2<Base>.Index, Base: ___TreeIndex {
  associatedtype Index
}

public protocol UnsafeIndicesBinding: UnsafeTreeBinding
where Indices == UnsafeTreeV2<Base>.Indices, Base: ___TreeIndex {
  associatedtype Indices
}

@usableFromInline
protocol UnsafeIndexProviderProtocol: UnsafeIndexBinding & UnsafeTreeHost {
  func ___index(_ p: _SealedPtr) -> Index
}

extension UnsafeIndexProviderProtocol {

  @inlinable
  @inline(__always)
  internal func ___index_or_nil(_ p: _SealedPtr) -> Index? {
    !p.isValid ? nil : ___index(p)
  }

  @inlinable
  @inline(__always)
  internal func ___index_or_nil(_ p: _SealedPtr?) -> Index? {
    p.flatMap { ___index_or_nil($0) }
  }
}

/// Indexが何であるかをしり、その生成には何が必要で、どう生成するのかを知っている
@usableFromInline
protocol UnsafeIndexProtocol_tie: _UnsafeNodePtrType
where Index == UnsafeIndexV2<Base> {
  associatedtype Base: ___TreeBase & ___TreeIndex
  associatedtype Index
  var tied: _TiedRawBuffer { get }
}

extension UnsafeIndexProtocol_tie {

  @inlinable
  @inline(__always)
  package func ___index(_ p: _SealedPtr) -> Index {
    Index(sealed: p, tie: tied)
  }
}

@usableFromInline
protocol UnsafeIndexProtocol_tree: UnsafeIndexBinding & UnsafeTreeHost {
  func ___index(_ p: _SealedPtr) -> Index
}

extension UnsafeIndexProtocol_tree {

  @inlinable
  @inline(__always)
  internal func ___index(_ p: _SealedPtr) -> Index {
    Index(sealed: p, tie: __tree_.tied)
  }
}

@usableFromInline
protocol UnsafeIndicesProtoocl: UnsafeTreeSealedRangeBaseInterface & UnsafeIndicesBinding {}

extension UnsafeIndicesProtoocl {

  @inlinable
  @inline(__always)
  internal var _indices: Indices {
    .init(start: _sealed_start, end: _sealed_end, tie: __tree_.tied)
  }
}
