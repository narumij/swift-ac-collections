//
//  UnsafeIndexingProtocol.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/13.
//

public protocol UnsafeIndexBinding: UnsafeTreeBindingV2
where Index == UnsafeTreeV2<Base>.Index, Base: ___TreeIndex {
  associatedtype Index
}

@usableFromInline
protocol UnsafeIndexProviderProtocol: UnsafeIndexBinding & UnsafeTreeHostV2 {
  func ___index(_ p: _SealedPtr) -> Index
}

@usableFromInline
protocol UnsafeIndexV3ProviderProtocol {
  associatedtype Index = UnsafeIndexV3
  func ___index(_ p: _SealedPtr) -> Index
}

