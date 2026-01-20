//
//  three_way_comparator.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/20.
//

@inlinable
@inline(__always)
package func __default_three_way_comparator<T: Comparable>(_ __lhs: T, _ __rhs: T) -> Int {
  if __lhs < __rhs {
    -1
  } else if __lhs > __rhs {
    1
  } else {
    0
  }
}

@inlinable
@inline(__always)
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
