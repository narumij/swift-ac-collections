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
  extension RedBlackTreeDictionary {

    public typealias _RangeExpression = UnsafeIndexV2RangeExpression<Self>

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

    @inlinable
    public subscript(unchecked bounds: UnboundedRange) -> SubSequence {
      ___unchecked_subscript(.unboundedRange)
    }

    @inlinable
    public subscript(unchecked bounds: _RangeExpression) -> SubSequence {
      ___unchecked_subscript(bounds.rawRange)
    }

    @inlinable
    public mutating func removeSubrange(_ bounds: UnboundedRange) {
      __tree_._ensureUnique()
      ___remove(.unboundedRange)
    }

    @inlinable
    public mutating func removeSubrange(_ bounds: _RangeExpression) {
      __tree_._ensureUnique()
      ___remove(bounds.rawRange)
    }

    @inlinable
    public mutating func removeSubrange(
      _ bounds: _RangeExpression,
      where shouldBeRemoved: (Element) throws -> Bool
    ) rethrows {

      __tree_._ensureUnique()
      let (lower, upper) = __tree_.rawRange(bounds.rawRange)
      guard __tree_.isValidRawRange(lower: lower, upper: upper) else {
        fatalError(.invalidIndex)
      }
      try __tree_.___erase_if(
        lower, upper,
        shouldBeRemoved: { try shouldBeRemoved($0.tuple) })
    }
  }
#endif
