//
//  UnsafeIndexProtocol+deprecated.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/04/23.
//

#if COMPATIBLE_ATCODER_2025
  public protocol UnsafeIndicesBinding: UnsafeTreeBinding
  where Indices == UnsafeTreeV2<Base>.Indices, Base: ___TreeIndex {
    associatedtype Indices
  }
#endif

/// Indexが何であるかをしり、その生成には何が必要で、どう生成するのかを知っている
@usableFromInline
protocol UnsafeIndexProtocol_tie: _UnsafeNodePtrType
where Index == UnsafeIndexV2<Base> {
  associatedtype Base: ___TreeBase & ___TreeIndex
  associatedtype Index
  var tied: _TiedRawBuffer { get }
}

extension UnsafeIndexProtocol_tie {

  @inlinable @inline(__always)
  package func ___index(_ p: _SealedPtr) -> Index {
    Index(sealed: p, tie: tied)
  }
}

#if COMPATIBLE_ATCODER_2025
  @usableFromInline
  protocol UnsafeIndexProtocol_tree: UnsafeIndexBinding & UnsafeTreeHost {
    func ___index(_ p: _SealedPtr) -> Index
  }

  extension UnsafeIndexProtocol_tree {

    @inlinable @inline(__always)
    internal func ___index(_ p: _SealedPtr) -> Index {
      Index(sealed: p, tie: __tree_.tied)
    }
  }
#endif

#if COMPATIBLE_ATCODER_2025
  @usableFromInline
  protocol UnsafeIndicesProtoocl: UnsafeTreeSealedRangeBaseInterface & UnsafeIndicesBinding {}

  extension UnsafeIndicesProtoocl {

    @inlinable @inline(__always)
    internal var _indices: Indices {
      .init(start: _sealed_start, end: _sealed_end, tie: __tree_.tied)
    }
  }
#endif
