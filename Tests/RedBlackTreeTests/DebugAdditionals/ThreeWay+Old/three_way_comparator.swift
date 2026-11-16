//
//  three_way_comparator.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/06/01.
//
#if DEBUG
  @testable import RedBlackTreeCollections

  @inlinable
  package func ___default_three_way_comparator<T: Comparable>(_ __lhs: T, _ __rhs: T)
    -> ___enum_compare_result
  {
    if __lhs < __rhs {
      .less
    } else if __lhs > __rhs {
      .greater
    } else {
      .equal
    }
  }
#endif
