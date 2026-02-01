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

// TODO:範囲不正がfatalになるかどうかのテストを追加すること

// 新形式
#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeSet {

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
    public func isValid(_ bounds: TrackingTagRangeExpression) -> Bool {
      let (l, u) = bounds.relative(to: __tree_)
      return l.isValid && u.isValid
    }

    @inlinable
    public subscript(bounds: UnboundedRange) -> SubSequence {
      ___subscript(.unboundedRange)
    }

    #if false
      @inlinable
      public subscript(bounds: _RangeExpression) -> SubSequence {
        ___subscript(bounds.rawRange)
      }
    #else
      public subscript(bounds: _RangeExpression)
        -> RedBlackTreeKeyOnlyRangeView<Self>
      {
        @inline(__always)
        get {
          let (lower, upper) = bounds.relative(to: __tree_)
          return .init(__tree_: __tree_, _start: lower, _end: upper)
        }
        @inline(__always)
        _modify {
          let (lower, upper) = bounds.relative(to: __tree_)
          var view = RedBlackTreeKeyOnlyRangeView(__tree_: __tree_, _start: lower, _end: upper)
          self = RedBlackTreeSet()
          defer { self = .init(__tree_: view.__tree_) }
          yield &view
        }
      }
    #endif
    
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
    public subscript(unchecked bounds: UnboundedRange) -> SubSequence {
      ___unchecked_subscript(.unboundedRange)
    }

    /// - Warning: This subscript trades safety for performance. Using an invalid index results in undefined behavior.
    /// - Complexity: O(1)
    @inlinable
    public subscript(unchecked bounds: _RangeExpression) -> SubSequence {
      ___unchecked_subscript(bounds.rawRange)
    }

    @inlinable
    public mutating func removeSubrange(_ bounds: UnboundedRange) {
      __tree_.ensureUnique()
      _ = ___remove(.unboundedRange)
    }

    @inlinable
    public mutating func removeSubrange(_ bounds: _RangeExpression) {
      __tree_.ensureUnique()
      _ = ___remove(bounds.rawRange)
    }
    
    @inlinable
    public mutating func removeSubrange(_ bounds: TrackingTagRangeExpression) {
      __tree_.ensureUnique()
      let (lower, upper) = bounds.relative(to: __tree_)
      _ = ___remove(from: lower, to: upper)
    }

    @inlinable
    public mutating func removeSubrange(unchecked bounds: UnboundedRange) {
      __tree_.ensureUnique()
      _ = ___unchecked_remove(.unboundedRange)
    }

    @inlinable
    public mutating func removeSubrange(unchecked bounds: _RangeExpression) {
      __tree_.ensureUnique()
      _ = ___unchecked_remove(bounds.rawRange)
    }

    @inlinable
    public mutating func removeSubrange(
      _ bounds: _RangeExpression,
      where shouldBeRemoved: (Element) throws -> Bool
    ) rethrows {

      __tree_.ensureUnique()
      let (lower, upper) = bounds.relative(to: __tree_)
      guard __tree_.isValidRawRange(lower: lower, upper: upper) else {
        fatalError(.invalidIndex)
      }
      try __tree_.___erase_if(
        lower, upper,
        shouldBeRemoved: shouldBeRemoved)
    }

    @inlinable
    public mutating func removeSubrange(
      unchecked bounds: _RangeExpression,
      where shouldBeRemoved: (Element) throws -> Bool
    ) rethrows {

      __tree_.ensureUnique()
      let (lower, upper) = bounds.relative(to: __tree_)
      try __tree_.___checking_erase_if(
        lower, upper,
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
        _start: __tree_.lower_bound(start),
        _end: __tree_.lower_bound(end))
    }

    /// 値レンジ `[start, end]` に含まれる要素のスライス
    /// - Complexity: O(log *n*)
    @inlinable
    public func sequence(from start: Element, through end: Element)
    ->  RedBlackTreeKeyOnlyRangeView<Base> {
      // APIはstride関数とsequence関数を参考にした
      .init(
        __tree_: __tree_,
        _start: __tree_.lower_bound(start),
        _end: __tree_.upper_bound(end))
    }
  }
#endif
