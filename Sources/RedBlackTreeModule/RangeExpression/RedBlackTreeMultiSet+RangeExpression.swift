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

  extension RedBlackTreeMultiSet {

    public typealias View = RedBlackTreeKeyOnlyRangeView<Base>
    public typealias IndexRange = UnsafeIndexV3RangeExpression

    @inlinable
    public func isValid(_ bounds: UnboundedRange) -> Bool {
      true
    }

    @inlinable
    public func isValid(_ bounds: IndexRange) -> Bool {
      let (l, u) = bounds.relative(to: __tree_)
      return l.isValid && u.isValid
    }

    @inlinable
    public subscript(bounds: UnboundedRange) -> View {
      .init(__tree_: __tree_, _start: _sealed_start, _end: _sealed_end)
    }

    @inlinable
    public subscript(bounds: IndexRange) -> View {
      let (lower, upper) = bounds.relative(to: __tree_)
      guard __tree_.isValidSealedRange(lower: lower, upper: upper) else {
        fatalError(.invalidIndex)
      }
      return .init(__tree_: __tree_, _start: lower, _end: upper)
    }

    @inlinable
    public mutating func erase(_ bounds: UnboundedRange) {
      __tree_.ensureUnique()
      _ = ___remove(from: _start, to: _end)
    }

    @inlinable
    public mutating func erase(_ bounds: IndexRange) {
      __tree_.ensureUnique()
      let (lower, upper) = unwrapLowerUpperOrFatal(bounds.relative(to: __tree_))
      _ = ___remove(from: lower, to: upper)
    }

    @inlinable
    public mutating func erase(
      _ bounds: IndexRange, where shouldBeRemoved: (Element) throws -> Bool
    ) rethrows {

      __tree_.ensureUnique()
      let (lower, upper) = bounds.relative(to: __tree_)
      guard __tree_.isValidSealedRange(lower: lower, upper: upper) else {
        fatalError(.invalidIndex)
      }
      try __tree_.___erase_if(lower, upper, shouldBeRemoved: shouldBeRemoved)
    }
  }
#endif

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiSet {

    /// 値レンジ `[start, end)` に含まれる要素のスライス
    /// - Complexity: O(log *n*)
    @inlinable
    public func sequence(from start: Element, to end: Element)
      -> RedBlackTreeKeyOnlyRangeView<Base>
    {
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
      -> RedBlackTreeKeyOnlyRangeView<Base>
    {
      // APIはstride関数とsequence関数を参考にした
      .init(
        __tree_: __tree_,
        _start: __tree_.lower_bound(start).sealed,
        _end: __tree_.upper_bound(end).sealed)
    }
  }
#endif
