//
//  UnsafeTreeV2+RawRange.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/23.
//

extension UnsafeTreeV2 {

  @inlinable @inline(__always)
  func rawRange(_ range: UnsafeTreeRangeExpression) -> (lower: _NodePtr, upper: _NodePtr) {
    range.rawRange(_begin: __begin_node_, _end: __end_node)
  }
  
  @inlinable
  func isValidRawRange(lower: _NodePtr, upper: _NodePtr) -> Bool {
    // lower <= upper は、upper > lowerなので
    !lower.___is_null && !upper.___is_null && !___ptr_comp(upper, lower)
  }
}
