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
    public func isValid(_ bound: Bound) -> Bool {
      let sealed = bound.evaluate(__tree_)
      return sealed.isValid && !sealed.___is_end!
    }
  }

  extension RedBlackTreeSet {

    @inlinable
    @inline(__always)
    public func distance(from start: Bound, to end: Bound)
      -> Int
    {
      guard
        let d = __tree_.___distance(
          from: start.evaluate(__tree_),
          to: end.evaluate(__tree_))
      else { fatalError(.invalidIndex) }
      return d
    }
  }

  extension RedBlackTreeSet {

    @inlinable
    internal func bound(before i: Bound) -> Bound {
      .before(i)
    }

    @inlinable
    internal func bound(after i: Bound) -> Bound {
      .after(i)
    }
  }

  // TODO: インデックス取得メソッドを追加するかどうか検討

  extension RedBlackTreeSet {

    // 実は辞書の派生型という位置づけが自然な気もする

    /// Returns the element at the evaluated position.
    ///
    /// If the evaluated position is `endIndex` or the lookup fails, `nil` is returned.
    ///
    @inlinable
    public subscript(bound: Bound) -> Element? {
      let p = bound.evaluate(__tree_)
      guard let p = p.pointer, !p.___is_end else { return nil }
      return __tree_[_unsafe_raw: p]
    }
  }

  extension RedBlackTreeSet {

    @inlinable
    public mutating func erase(_ bound: Bound) -> Element? {
      __tree_.ensureUnique()
      let p = bound.evaluate(__tree_)
      guard let p = p.pointer, !p.___is_end else { return nil }
      return __tree_._unchecked_remove(at: p).payload
    }
  }

  // MARK: -

  extension RedBlackTreeSet {

    /// Returns whether the corresponding element can be accessed.
    ///
    /// Even if this returns `false`, BoundRange-related APIs will not crash.
    @inlinable
    public func isValid(_ bounds: BoundRangeExpression) -> Bool {
      let range = bounds.evaluate(__tree_).relative(to: __tree_)
      return __tree_.isValidSealedRange(range)
        && range.lowerBound.isValid
        && range.upperBound.isValid
    }
  }

  extension RedBlackTreeSet {

    @inlinable
    public subscript(bounds: BoundRangeExpression) -> View {

      @inline(__always) get {

        let range = __tree_.sanitizeSealedRange(
          bounds.evaluate(__tree_).relative(to: __tree_))

        return self[unchecked: range]
      }

      @inline(__always) _modify {

        let range = __tree_.sanitizeSealedRange(
          bounds.evaluate(__tree_).relative(to: __tree_))

        yield &self[unchecked: range]
      }
    }
  }

  extension RedBlackTreeSet {

    @inlinable
    public mutating func erase(_ bounds: BoundRangeExpression) {

      __tree_.ensureUnique()
      let range = __tree_.sanitizeSealedRange(
        bounds.evaluate(__tree_).relative(to: __tree_))
      __tree_.___erase(range.lowerBound.pointer!, range.upperBound.pointer!)
    }

    @inlinable
    public mutating func erase(
      _ bounds: BoundRangeExpression, where shouldBeRemoved: (Element) throws -> Bool
    ) rethrows {

      __tree_.ensureUnique()
      let range = __tree_.sanitizeSealedRange(
        bounds.evaluate(__tree_).relative(to: __tree_))
      try __tree_.___erase_if(range.lowerBound, range.upperBound, shouldBeRemoved)
    }
  }
#endif
