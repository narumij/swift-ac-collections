//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-ac-collections project.
//
// Copyright (c) 2024-2026 narumij.
// Licensed under the Apache License v2.0.
//
// SPDX-License-Identifier: Apache-2.0
//
// This implementation includes code derived from LLVM libc++'s red-black tree
// implementation, originally distributed under the Apache License v2.0 with
// LLVM Exceptions.
//
// Copyright © 2003-2026 The LLVM Project.
// Licensed under the Apache License v2.0 with LLVM Exceptions.
// The original license can be found at https://llvm.org/LICENSE.txt
//
// This Swift implementation includes modifications and adaptations made by
// narumij.
//
//===----------------------------------------------------------------------===//

#if !COMPATIBLE_ATCODER_2025

  extension RedBlackTreeMultiSet {

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
    /// let tree: RedBlackTreeMultiSet<Int> = [1, 3, 5, 7, 9]
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

  extension RedBlackTreeMultiSet {

    /// Returns whether the corresponding element can be accessed.
    @inlinable
    public func isValid(_ bound: Bound) -> Bool {

      bound.evaluate(__tree_).accessible.error == nil
    }
  }

  extension RedBlackTreeMultiSet {

    @inlinable
    public func distance(from start: Bound, to end: Bound)
      -> Int
    {
      guard let d = __tree_.distance(from: start, to: end)
      else { fatalError(.invalidIndex) }
      return d
    }
  }

  extension RedBlackTreeMultiSet {

    /// Returns the element at the evaluated position.
    ///
    /// If the evaluated position is `endIndex` or the lookup fails, `nil` is returned.
    ///
    @inlinable
    public subscript(bound: Bound) -> Element? {

      let p = bound.evaluate(__tree_)
      guard let p = p.accessible.pointer else { return nil }
      return Base.__payload_(p)
    }
  }

  extension RedBlackTreeMultiSet {

    @inlinable
    public mutating func erase(_ bound: Bound) -> Element? {

      __tree_.ensureUnique()
      let p = bound.evaluate(__tree_)
      guard let p = p.accessible.pointer else { return nil }
      return __tree_._unchecked_remove(at: p).payload
    }
  }

  // MARK: -

  extension RedBlackTreeMultiSet {

    /// Returns whether the corresponding element can be accessed.
    ///
    /// Even if this returns `false`, BoundRange-related APIs will not crash.
    @inlinable
    public func isValid(_ bounds: BoundRangeExpression) -> Bool {
      let range = bounds.evaluate(__tree_).relative(to: __tree_)
      return __tree_.isValid(safeRange: range)
    }
  }

  extension RedBlackTreeMultiSet {

    @inlinable
    public subscript(bounds: BoundRangeExpression) -> View {

      @inline(__always) get {

        let range = __tree_.sanitize(
          safeRange: bounds.evaluate(__tree_).relative(to: __tree_))

        return self[_safeRange: range]
      }

      @inline(__always) _modify {

        let range = __tree_.sanitize(
          safeRange: bounds.evaluate(__tree_).relative(to: __tree_))

        yield &self[_safeRange: range]
      }
    }
  }

  extension RedBlackTreeMultiSet {

    @inlinable
    public mutating func erase(_ bounds: BoundRangeExpression) {

      __tree_.ensureUnique()
      let range = __tree_.sanitize(
        safeRange: bounds.evaluate(__tree_).relative(to: __tree_))
      __tree_.___erase_range(range.lowerBound.pointer!, range.upperBound.pointer!)
    }

    @inlinable
    public mutating func erase(
      _ bounds: BoundRangeExpression, where shouldBeRemoved: (Element) throws -> Bool
    ) rethrows {

      __tree_.ensureUnique()
      let range = __tree_.sanitize(
        safeRange: bounds.evaluate(__tree_).relative(to: __tree_))
      try __tree_.___erase_ragen_if(range.lowerBound, range.upperBound, shouldBeRemoved)
    }
  }
#endif
