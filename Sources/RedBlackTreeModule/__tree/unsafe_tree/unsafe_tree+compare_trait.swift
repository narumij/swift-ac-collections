//
//  unsafe_tree+compare_trait.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/25.
//

public protocol CompareTrait: _Tree_IsMultiTraitInterface {
  static var isMulti: Bool { get }
}

extension CompareTrait {
  @inlinable @inline(__always)
  public var isMulti: Bool { Self.isMulti }
}

public protocol CompareUniqueTrait: CompareTrait & _Tree_IsMultiTraitInterface {}

extension CompareUniqueTrait {
  @inlinable @inline(__always)
  public static var isMulti: Bool { false }
}

public protocol CompareMultiTrait: CompareTrait & _Tree_IsMultiTraitInterface {}

extension CompareMultiTrait {
  @inlinable @inline(__always)
  public static var isMulti: Bool { true }
}
