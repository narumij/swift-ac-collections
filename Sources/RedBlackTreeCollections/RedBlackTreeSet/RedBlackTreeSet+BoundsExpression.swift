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
  extension RedBlackTreeSet {

    /// A shorthand for `RedBlackTreeBoundExpression<Element>`.
    ///
    /// This type is used to describe element positions in the tree,
    /// such as the first element, bounds, or relative offsets.
    ///
    /// - SeeAlso: `RedBlackTreeBoundExpression`
    public typealias Bound = RedBlackTreeBoundExpression<Element>

    /// A shorthand for `RedBlackTreeBoundRangeExpression<Element>`.
    ///
    /// This type represents ranges over the tree using `Bound` expressions
    /// as endpoints.
    ///
    /// ## Example
    ///
    /// ```
    /// let tree: RedBlackTreeSet<Int> = [1, 3, 5, 7, 9]
    ///
    /// // Elements in [3, 9)
    /// let r1 = tree[.lowerBound(3) ..< .lowerBound(9)]
    ///
    /// // Elements in [5, ...]
    /// let r2 = tree[.lowerBound(5)...]
    ///
    /// // Elements less than 7
    /// let r3 = tree[..< .lowerBound(7)]
    ///
    /// // Elements equal to 5
    /// let r4 = tree[equalRange(5)]
    /// ```
    ///
    /// - Note:
    ///   - Endpoints are evaluated in the tree's sort order.
    ///   - Invalid ranges may trap at runtime.
    ///
    /// - SeeAlso:
    ///   - `RedBlackTreeBoundRangeExpression`
    ///   - `RedBlackTreeBoundExpression`
    public typealias BoundRangeExpression = RedBlackTreeBoundRangeExpression<Element>
  }

  extension RedBlackTreeSet {

    /// Returns whether the corresponding element can be accessed.
    @inlinable
    public func isValid(_ bound: RedBlackTreeBoundExpressionV2<Element>) -> Bool {
      let _safe_ptr_ = bound.evaluate(__tree_)
      return _safe_ptr_.___has_payload_content
    }
  }

  extension RedBlackTreeSet {

    /// Returns the distance between two evaluated position.
    ///
    /// - Complexity: O(log *n* + *k*)
    @inlinable
    public func distance(from start: RedBlackTreeBoundExpressionV2<Element>, to end: RedBlackTreeBoundExpressionV2<Element>)
      -> Int
    {
      guard let d = __tree_.distance(from: start, to: end)
      else { fatalError(.invalidIndex) }
      return d
    }
  }

  extension RedBlackTreeSet {

    // 実は辞書の派生型という位置づけが自然な気もする

    /// Returns the element at the evaluated position.
    ///
    /// If the evaluated position is `endIndex` or the lookup fails, `nil` is returned.
    ///
    @inlinable
    @inline(__always)
    public subscript(bound: RedBlackTreeBoundExpressionV2<Element>) -> Element? {
      let p = bound.evaluate(__tree_)
      guard let p = p.pointer, !p.___is_end else { return nil }
      return p.__value_(as: Element.self).pointee
    }
  }

  extension RedBlackTreeSet {

    @inlinable
    public mutating func erase(_ bound: RedBlackTreeBoundExpressionV2<Element>) -> Element? {
      __tree_.ensureUnique()
      let p = bound.evaluate(__tree_)
      guard let p = p.pointer, !p.___is_end else { return nil }
      return __tree_._unchecked_remove(at: p).payload
    }
  }

  extension RedBlackTreeSet {

    /// Returns whether the corresponding element can be accessed.
    ///
    /// Even if this returns `false`, BoundRange-related APIs will not crash.
    @inlinable
    public func isValid(_ bounds: BoundRangeExpression) -> Bool {
      let range = bounds.evaluate(__tree_).relative(to: __tree_)
      return __tree_.isValidSafeRange(range)
    }
  }

  extension RedBlackTreeSet {

    @inlinable
    public subscript(bounds: BoundRangeExpression) -> View {

      @inline(__always) get {

        let range = __tree_.sanitizeSafeRange(
          bounds.evaluate(__tree_).relative(to: __tree_))

        return self[unchecked: range]
      }

      @inline(__always) _modify {

        let range = __tree_.sanitizeSafeRange(
          bounds.evaluate(__tree_).relative(to: __tree_))

        yield &self[unchecked: range]
      }
    }
  }

  extension RedBlackTreeSet {

    @inlinable
    public mutating func erase(_ bounds: BoundRangeExpression) {

      __tree_.ensureUnique()
      let range = __tree_.sanitizeSafeRange(
        bounds.evaluate(__tree_).relative(to: __tree_))
      __tree_.___erase_range(range.lowerBound.pointer!, range.upperBound.pointer!)
    }

    @inlinable
    public mutating func erase(
      _ bounds: BoundRangeExpression, where shouldBeRemoved: (Element) throws -> Bool
    ) rethrows {

      __tree_.ensureUnique()
      let range = __tree_.sanitizeSafeRange(
        bounds.evaluate(__tree_).relative(to: __tree_))
      try __tree_.___erase_ragen_if(
        range.lowerBound, range.upperBound, shouldBeRemoved)
    }
  }
#endif
