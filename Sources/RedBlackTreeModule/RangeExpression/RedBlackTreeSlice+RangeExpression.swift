//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-ac-collections project
//
// Copyright (c) 2024 - 2026 narumij.
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// This code is based on work originally distributed under the Apache License 2.0 with LLVM Exceptions:
//
// Copyright © 2003-2026 The LLVM Project.
// Licensed under the Apache License, Version 2.0 with LLVM Exceptions.
// The original license can be found at https://llvm.org/LICENSE.txt
//
// This Swift implementation includes modifications and adaptations made by narumij.
//
//===----------------------------------------------------------------------===//

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeSliceV2.KeyOnly {

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
    public subscript(bounds: UnboundedRange) -> RedBlackTreeKeyOnlyRangeView<Base> {
      ___subscript(.unboundedRange)
    }

    @inlinable
    public subscript(bounds: _RangeExpression) -> RedBlackTreeKeyOnlyRangeView<Base> {
      ___subscript(bounds.rawRange)
    }

    @inlinable
    public subscript(bounds: TrackingTagRangeExpression) -> RedBlackTreeKeyOnlyRangeView<Base> {
      let (lower, upper) = bounds.relative(to: __tree_)
      guard __tree_.isValidRawRange(lower: lower.checked, upper: upper.checked) else {
        fatalError(.invalidIndex)
      }
      return .init(__tree_: __tree_, _start: lower, _end: upper)
    }

    /// - Warning: This subscript trades safety for performance. Using an invalid index results in undefined behavior.
    /// - Complexity: O(1)
    @inlinable
    public subscript(unchecked bounds: UnboundedRange) -> RedBlackTreeKeyOnlyRangeView<Base> {
      ___unchecked_subscript(.unboundedRange)
    }

    /// - Warning: This subscript trades safety for performance. Using an invalid index results in undefined behavior.
    /// - Complexity: O(1)
    @inlinable
    public subscript(unchecked bounds: _RangeExpression) -> RedBlackTreeKeyOnlyRangeView<Base> {
      ___unchecked_subscript(bounds.rawRange)
    }
  }
#endif
