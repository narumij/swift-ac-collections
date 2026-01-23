//
//  RedBlackTreeMultiSet+RangeExpression.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/23.
//

#if !COMPATIBLE_ATCODER_2025
extension RedBlackTreeMultiSet {
  
  @inlinable
  public func isValid(_ bounds: UnboundedRange) -> Bool {
    _isValid(.unboundedRange) // 常にtrueな気がする
  }
  
  @inlinable
  public func isValid(_ bounds: UnsafeIndexV2RangeExpression<Self>) -> Bool {
    _isValid(bounds.rawRange)
  }
  
  @inlinable
  public subscript(bounds: UnboundedRange) -> SubSequence {
    ___subscript(.unboundedRange)
  }
  
  @inlinable
  public subscript(bounds: UnsafeIndexV2RangeExpression<Self>) -> SubSequence {
    ___subscript(bounds.rawRange)
  }
  
  @inlinable
  public mutating func removeSubrange(_ bounds: UnboundedRange) {
    __tree_._ensureUnique()
    ___remove(.unboundedRange)
  }
  
  @inlinable
  public mutating func removeSubrange(_ bounds: UnsafeIndexV2RangeExpression<Self>) {
    __tree_._ensureUnique()
    ___remove(bounds.rawRange)
  }
}
#endif
