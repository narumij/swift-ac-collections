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


  extension RedBlackTreeMultiMap {}

  extension RedBlackTreeMultiMap {

    /// A shorthand for `RedBlackTreeBoundExpression<Element>`.
    ///
    /// This type is used to describe element positions in the tree,
    /// such as the first element, bounds, or relative offsets.
    ///
    /// - SeeAlso: `RedBlackTreeBoundExpression`
    public typealias Bound = RedBlackTreeBoundExpression<Key>
    public typealias BoundRangeExpression = RedBlackTreeBoundRangeExpression<Key>
  }

  extension RedBlackTreeMultiMap {

    @inlinable
    public func distance(from start: Bound, to end: Bound)
      -> Int
    {
      guard let d = __tree_.distance(from: start, to: end)
      else { fatalError(.invalidIndex) }
      return d
    }
  }

  extension RedBlackTreeMultiMap {

    /// Returns the element at the evaluated position.
    ///
    /// If the evaluated position is `endIndex` or the lookup fails, `nil` is returned.
    ///
    @inlinable
    public subscript(bound: Bound) -> Element? {

      let p = bound.evaluate(__tree_)
      guard let p = p.accessible.pointer else { return nil }
      return Base.__element_(p)
    }
  }

  extension RedBlackTreeMultiMap {

    /// Removes and returns the key-value pair at the position selected by a bound expression.
    ///
    /// When equivalent keys exist, the expression determines which position is removed.
    ///
    /// - Parameter bound: A bound expression that selects a position in the multimap.
    /// - Returns: The removed key-value pair, or `nil` if the expression selects
    ///   `endIndex` or can't be evaluated.
    @inlinable
    public mutating func erase(_ bound: Bound) -> Element? {

      __tree_.ensureUnique()
      let p = bound.evaluate(__tree_)
      guard let p = p.accessible.pointer else { return nil }
      return Base.__element_(__tree_._unchecked_remove(at: p).payload)
    }
  }

  extension RedBlackTreeMultiMap {

    /// Accesses a view of the key-value pairs selected by a bound range expression.
    ///
    /// Mutating the returned view modifies this multimap. The view retains every
    /// selected pair, including pairs with equivalent keys. A range that evaluates
    /// to no ordered positions produces an empty view.
    ///
    /// - Parameter bounds: A bound range expression evaluated against the
    ///   multimap's keys.
    /// - Returns: A view over the selected key-value pairs.
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

  extension RedBlackTreeMultiMap {

    /// Removes the key-value pairs in the range selected by a bound range expression.
    ///
    /// - Parameter bounds: A bound range expression that selects the key-value
    ///   pairs to remove.
    @inlinable
    public mutating func erase(_ bounds: BoundRangeExpression) {

      // 空の場合は削除対象が存在し得ないため、ensureUnique()による
      // 無駄なコピー(共有される空シングルトンバッファからの退避)を避ける。
      guard __tree_.count > 0 else { return }
      __tree_.ensureUnique()
      _ = __tree_.___erase_sanitize_range(bounds.evaluate(__tree_).relative(to: __tree_))
    }

    /// Removes the key-value pairs in the selected range that satisfy a predicate.
    ///
    /// - Parameters:
    ///   - bounds: A bound range expression that selects the key-value pairs to examine.
    ///   - shouldBeRemoved: A closure that returns `true` for a key-value pair
    ///     that should be removed.
    @inlinable
    public mutating func erase(
      _ bounds: BoundRangeExpression, where shouldBeRemoved: (Element) throws -> Bool
    ) rethrows {

      // 空の場合は削除対象が存在し得ないため、ensureUnique()による
      // 無駄なコピー(共有される空シングルトンバッファからの退避)を避ける。
      guard __tree_.count > 0 else { return }
      __tree_.ensureUnique()
      _ = try __tree_.___erase_sanitize_range_if(
        bounds.evaluate(__tree_).relative(to: __tree_)
      ) {
        try shouldBeRemoved($0.tuple)
      }
    }
  }
