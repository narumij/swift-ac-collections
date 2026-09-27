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

  extension RedBlackTreeDictionary {

    /// A shorthand for `RedBlackTreeBoundExpression<Element>`.
    ///
    /// This type is used to describe element positions in the tree,
    /// such as the first element, bounds, or relative offsets.
    ///
    /// - SeeAlso: `RedBlackTreeBoundExpression`
    public typealias Bound = RedBlackTreeBoundExpression<Key>
    public typealias BoundRangeExpression = RedBlackTreeBoundRangeExpression<Key>
  }

  extension RedBlackTreeDictionary {

    /// Returns whether the corresponding element can be accessed.
    ///
    /// - Deprecated: Use the Bound subscript and inspect its optional result.
    @available(*, deprecated, message: "Use the Bound subscript and inspect its optional result.")
    @inlinable
    public func isValid(_ bound: Bound) -> Bool {

      bound.evaluate(__tree_).accessible.error == nil
    }
  }

  extension RedBlackTreeDictionary {

    @inlinable
    public func distance(from start: Bound, to end: Bound)
      -> Int
    {
      guard let d = __tree_.distance(from: start, to: end)
      else { fatalError(.invalidIndex) }
      return d
    }
  }

  extension RedBlackTreeDictionary {

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

  extension RedBlackTreeDictionary {

    @inlinable
    public mutating func erase(_ bound: Bound) -> Element? {

      __tree_.ensureUnique()
      let p = bound.evaluate(__tree_)
      guard let p = p.accessible.pointer else { return nil }
      return Base.__element_(__tree_._unchecked_remove(at: p).payload)
    }
  }

  // MARK: -

  extension RedBlackTreeDictionary {

    /// Returns whether the corresponding element can be accessed.
    ///
    /// Even if this returns `false`, BoundRange-related APIs will not crash.
    ///
    /// - Deprecated: Use the BoundRangeExpression subscript and inspect the returned view.
    @available(*, deprecated, message: "Use the BoundRangeExpression subscript and inspect the returned view.")
    @inlinable
    public func isValid(_ bounds: BoundRangeExpression) -> Bool {
      let range = bounds.evaluate(__tree_).relative(to: __tree_)
      return __tree_.isValid(range: range)
    }
  }

  extension RedBlackTreeDictionary {

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

  extension RedBlackTreeDictionary {

    @inlinable
    public mutating func erase(_ bounds: BoundRangeExpression) {

      __tree_.ensureUnique()
      _ = __tree_.___erase_sanitize_range(bounds.evaluate(__tree_).relative(to: __tree_))
    }

    @inlinable
    public mutating func erase(
      _ bounds: BoundRangeExpression, where shouldBeRemoved: (Element) throws -> Bool
    ) rethrows {

      __tree_.ensureUnique()
      _ = try __tree_.___erase_sanitize_range_if(
        bounds.evaluate(__tree_).relative(to: __tree_)
      ) {
        try shouldBeRemoved($0.tuple)
      }
    }
  }
#endif
