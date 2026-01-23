//
//  UnsafeTreeV2+RawRange.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/23.
//

extension UnsafeTreeV2 {

  @inlinable
  func rawRange(_ range: UnsafeTreeRangeExpression) -> (lower: _NodePtr, upper: _NodePtr) {
    range.rawRange(_begin: __begin_node_, _end: __end_node)
  }
  
  @inlinable
  func isValidRawRange(lower: _NodePtr, upper: _NodePtr) -> Bool {
    // lower <= upper は、upper > lowerなので
    !___ptr_comp(upper, lower)
  }
}
