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

// TODO: 範囲不正がfatalになるかどうかのテストを追加すること

// 新形式
#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeSet {

    @inlinable
    public func isValid(_ bounds: UnboundedRange) -> Bool {
      true
    }

    @inlinable
    public func isValid(_ bounds: TrackingTagRangeExpression) -> Bool {
      let (l, u) = bounds._relative(to: __tree_)
      return l.isValid && u.isValid
    }

    @inlinable
    public subscript(bounds: UnboundedRange) -> RedBlackTreeKeyOnlyRangeView<Base> {
      .init(__tree_: __tree_, _start: _sealed_start, _end: _sealed_end)
    }
    
    @inlinable
    public subscript(bounds: TrackingTagRangeExpression) -> RedBlackTreeKeyOnlyRangeView<Base> {
      let (lower, upper) = bounds._relative(to: __tree_)
      guard __tree_.isValidRawRange(lower: lower, upper: upper) else {
        fatalError(.invalidIndex)
      }
      return .init(__tree_: __tree_, _start: lower, _end: upper)
    }

    @inlinable
    public mutating func removeAll(in bounds: UnboundedRange) {
      __tree_.ensureUnique()
      _ = ___remove(from: _start, to: _end)
    }
    
    @inlinable
    public mutating func removeAll(in bounds: TrackingTagRangeExpression) {
      __tree_.ensureUnique()
      let (lower, upper) = bounds._relative(to: __tree_)
      _ = ___remove(from: lower.pointer!, to: upper.pointer!)
    }

    @inlinable
    public mutating func removeAll(
      in bounds: TrackingTagRangeExpression,
      where shouldBeRemoved: (Element) throws -> Bool
    ) rethrows {

      __tree_.ensureUnique()
      let (lower, upper) = bounds._relative(to: __tree_)
      guard __tree_.isValidRawRange(lower: lower, upper: upper) else {
        fatalError(.invalidIndex)
      }
      try __tree_.___erase_if(
        lower.pointer!, upper.pointer!,
        shouldBeRemoved: shouldBeRemoved)
    }
  }
#endif

// 旧形式
#if !COMPATIBLE_ATCODER_2025
  // BoundExpressionにより不要になった
  extension RedBlackTreeSet {
    /// 値レンジ `[start, end)` に含まれる要素のスライス
    /// - Complexity: O(log *n*)
    @inlinable
    public func sequence(from start: Element, to end: Element)
    -> RedBlackTreeKeyOnlyRangeView<Base> {
      // APIはstride関数とsequence関数を参考にした
      .init(
        __tree_: __tree_,
        _start: __tree_.lower_bound(start).sealed,
        _end: __tree_.lower_bound(end).sealed)
    }

    /// 値レンジ `[start, end]` に含まれる要素のスライス
    /// - Complexity: O(log *n*)
    @inlinable
    public func sequence(from start: Element, through end: Element)
    ->  RedBlackTreeKeyOnlyRangeView<Base> {
      // APIはstride関数とsequence関数を参考にした
      .init(
        __tree_: __tree_,
        _start: __tree_.lower_bound(start).sealed,
        _end: __tree_.upper_bound(end).sealed)
    }
  }
#endif
