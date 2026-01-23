//
//  RedBlackTreeSlice.KeyValue+RangeExpression.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/24.
//

#if !COMPATIBLE_ATCODER_2025
extension RedBlackTreeSliceV2.KeyValue {

    public typealias _RangeExpression = UnsafeIndexV2RangeExpression<Base>

    @inlinable
    public func isValid(_ bounds: UnboundedRange) -> Bool {
      _isValid(.unboundedRange)  // 常にtrueな気がする
    }

    @inlinable
    public func isValid(_ bounds: _RangeExpression) -> Bool {
      _isValid(bounds.rawRange)
    }

    @inlinable
    public subscript(bounds: UnboundedRange) -> SubSequence {
      ___subscript(.unboundedRange)
    }

    @inlinable
    public subscript(bounds: _RangeExpression) -> SubSequence {
      ___subscript(bounds.rawRange)
    }

    /// - Warning: This subscript trades safety for performance. Using an invalid index results in undefined behavior.
    /// - Complexity: O(1)
    @inlinable
    public subscript(unchecked bounds: UnboundedRange) -> SubSequence {
      ___unchecked_subscript(.unboundedRange)
    }

    /// - Warning: This subscript trades safety for performance. Using an invalid index results in undefined behavior.
    /// - Complexity: O(1)
    @inlinable
    public subscript(unchecked bounds: _RangeExpression) -> SubSequence {
      ___unchecked_subscript(bounds.rawRange)
    }
  }
#endif
