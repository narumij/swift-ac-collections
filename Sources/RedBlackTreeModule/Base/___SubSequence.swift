//
//  RedBlackTreeSlice+Internal.swift
//  swift-ac-collections
//
//  Created by narumij on 2025/12/24.
//

@usableFromInline
protocol ___SubSequence: ___Base {}

extension ___SubSequence {

  /// - Complexity: O(log *n* + *k*)
  @inlinable
  @inline(__always)
  var _count: Int {
    __tree_.___distance(from: _start, to: _end)
  }
  
  @inlinable
  @inline(__always)
  func ___contains(_ i: _NodePtr) -> Bool {
    !__tree_.___is_subscript_null(i) && __tree_.___ptr_closed_range_contains(_start, _end, i)
  }

  @inlinable
  @inline(__always)
  func ___contains(_ bounds: Range<Index>) -> Bool {
    !__tree_.___is_offset_null(bounds.lowerBound.rawValue)
      && !__tree_.___is_offset_null(bounds.upperBound.rawValue)
      && __tree_.___ptr_range_contains(_start, _end, bounds.lowerBound.rawValue)
      && __tree_.___ptr_range_contains(_start, _end, bounds.upperBound.rawValue)
  }
}
