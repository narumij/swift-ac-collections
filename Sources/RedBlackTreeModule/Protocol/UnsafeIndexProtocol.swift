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

@usableFromInline
protocol UnsafeIndexProviderProtocol: UnsafeIndexBinding & UnsafeTreeHost {
  func ___index(_ p: _SealedPtr) -> Index
}

@usableFromInline
protocol UnsafeIndexV3ProviderProtocol {
  associatedtype Index = UnsafeIndexV3
  func ___index(_ p: _SealedPtr) -> Index
}

extension UnsafeIndexProviderProtocol {

  @inlinable @inline(__always)
  internal func ___index_or_nil(_ p: _SealedPtr) -> Index? {
    !p.isValid ? nil : ___index(p)
  }

  @inlinable @inline(__always)
  internal func ___index_or_nil(_ p: _SealedPtr?) -> Index? {
    p.flatMap { ___index_or_nil($0) }
  }
}

