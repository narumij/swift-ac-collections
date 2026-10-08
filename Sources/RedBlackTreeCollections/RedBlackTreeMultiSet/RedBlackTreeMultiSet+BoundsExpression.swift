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

    /// Removes and returns the element at the position selected by a bound expression.
    ///
    /// When equivalent elements exist, the expression determines which position
    /// is removed.
    ///
    /// - Parameter bound: A bound expression that selects a position in the multiset.
    /// - Returns: The removed element, or `nil` if the expression selects
    ///   `endIndex` or can't be evaluated.
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

    /// Accesses a view of the elements selected by a bound range expression.
    ///
    /// Mutating the returned view modifies this multiset. The view retains every
    /// selected occurrence, including equivalent elements. A range that evaluates
    /// to no ordered positions produces an empty view.
    ///
    /// - Parameter bounds: A bound range expression evaluated in this multiset.
    /// - Returns: A view over the selected occurrences.
    @inlinable
    public subscript(bounds: BoundRangeExpression) -> View {

      @inline(__always) get {
        self[_sanitize: bounds.evaluate(__tree_).relative(to: __tree_)]
      }

      @inline(__always) _modify {
        yield &self[_sanitize: bounds.evaluate(__tree_).relative(to: __tree_)]
      }
    }
  }

  extension RedBlackTreeMultiSet {

    /// Removes the elements in the range selected by a bound range expression.
    ///
    /// - Parameter bounds: A bound range expression that selects the elements
    ///   to remove.
    @inlinable
    public mutating func erase(_ bounds: BoundRangeExpression) {

      // 空の場合は削除対象が存在し得ないため、ensureUnique()による
      // 無駄なコピー(共有される空シングルトンバッファからの退避)を避ける。
      guard __tree_.count > 0 else { return }
      __tree_.ensureUnique()
      _ = __tree_.___erase_sanitize_range(bounds.evaluate(__tree_).relative(to: __tree_))
    }

    /// Removes the elements in the selected range that satisfy a predicate.
    ///
    /// - Parameters:
    ///   - bounds: A bound range expression that selects the elements to examine.
    ///   - shouldBeRemoved: A closure that returns `true` for an element that
    ///     should be removed.
    @inlinable
    public mutating func erase(
      _ bounds: BoundRangeExpression, where shouldBeRemoved: (Element) throws -> Bool
    ) rethrows {

      // 空の場合は削除対象が存在し得ないため、ensureUnique()による
      // 無駄なコピー(共有される空シングルトンバッファからの退避)を避ける。
      guard __tree_.count > 0 else { return }
      __tree_.ensureUnique()
      _ = try __tree_.___erase_sanitize_range_if(
        bounds.evaluate(__tree_).relative(to: __tree_), shouldBeRemoved)
    }
  }
#endif
