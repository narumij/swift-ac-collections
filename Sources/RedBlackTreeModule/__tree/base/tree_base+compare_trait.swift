//
//  tree_base+compare_trait.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/25.
//

// TODO: ちぐはぐってるので、あらためて整理すること

// _Tree_IsMultiTraitProtocolはBaseでは機能してないはず

public protocol CompareUniqueTrait: _Tree_IsMultiTraitProtocol & _Base_IsMultiTraitInterface {}

extension CompareUniqueTrait {
  @inlinable @inline(__always)
  public static var isMulti: Bool { false }
}

public protocol CompareMultiTrait: _Tree_IsMultiTraitProtocol & _Base_IsMultiTraitInterface {}

extension CompareMultiTrait {
  @inlinable @inline(__always)
  public static var isMulti: Bool { true }
}
