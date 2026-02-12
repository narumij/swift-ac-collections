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

  extension RedBlackTreeMultiMap {

    public typealias _RangeExpression = UnsafeIndexV2RangeExpression<Self>

    @inlinable
    public func isValid(_ bounds: UnboundedRange) -> Bool {
      true
    }

    @inlinable
    public func isValid(_ bounds: _RangeExpression) -> Bool {
      let (l, u) = bounds.relative(to: __tree_)
      return l.isValid && u.isValid
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
    public mutating func removeSubrange(_ bounds: UnboundedRange) {
      __tree_.ensureUnique()
      _ = ___remove(from: _start, to: _end)
    }

    @inlinable
    public mutating func removeSubrange(_ bounds: _RangeExpression) {
      __tree_.ensureUnique()
      let (lower, upper) = unwrapLowerUpperOrFatal(bounds.relative(to: __tree_))
      _ = ___remove(from: lower, to: upper)
    }

    @inlinable
    public mutating func removeSubrange(
      _ bounds: _RangeExpression,
      where shouldBeRemoved: (Element) throws -> Bool
    ) rethrows {

      __tree_.ensureUnique()
      let (lower, upper) = bounds.relative(to: __tree_)
      guard __tree_.isValidSealedRange(lower: lower, upper: upper) else {
        fatalError(.invalidIndex)
      }
      try __tree_.___erase_if(
        lower, upper, shouldBeRemoved: { try shouldBeRemoved($0.tuple) })
    }
  }
#endif

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiMap {
    /// キーレンジ `[start, upper)` に含まれる要素のスライス
    /// - Complexity: O(log *n*)
    @inlinable
    public func sequence(from start: Key, to end: Key) -> SubSequence {
      .init(
        tree: __tree_,
        start: __tree_.lower_bound(start).sealed,
        end: __tree_.lower_bound(end).sealed)
    }

    /// キーレンジ `[start, upper]` に含まれる要素のスライス
    /// - Complexity: O(log *n*)
    @inlinable
    public func sequence(from start: Key, through end: Key) -> SubSequence {
      .init(
        tree: __tree_,
        start: __tree_.lower_bound(start).sealed,
        end: __tree_.upper_bound(end).sealed)
    }
  }
#endif
