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

    public subscript(bounds: RedBlackTreeBoundRangeExpression<Key>) -> SubSequence {
      let (lower, upper) = bounds.relative(to: __tree_)
      guard __tree_.isValidSealedRange(lower: lower, upper: upper) else {
        fatalError(.invalidIndex)
      }
      return .init(tree: __tree_, start: lower, end: upper)
    }

    public subscript(unchecked bounds: RedBlackTreeBoundRangeExpression<Key>) -> SubSequence {
      let (lower, upper) = bounds.relative(to: __tree_)
      return .init(tree: __tree_, start: lower, end: upper)
    }

    public func indices(bounds: RedBlackTreeBoundRangeExpression<Key>)
      -> UnsafeIndexV2Collection<Self>
    {
      let (lower, upper) = bounds.relative(to: __tree_)
      guard __tree_.isValidSealedRange(lower: lower, upper: upper) else {
        fatalError(.invalidIndex)
      }
      return .init(start: lower, end: upper, tie: __tree_.tied)
    }

    public mutating func removeBounds(_ bounds: RedBlackTreeBoundRangeExpression<Key>) {
      __tree_.ensureUnique()
      let (lower, upper) = bounds.relative(to: __tree_)
      guard __tree_.isValidSealedRange(lower: lower, upper: upper) else {
        fatalError(.invalidIndex)
      }
      __tree_.___erase(lower.pointer!, upper.pointer!)
    }

    public mutating func removeBounds(unchecked bounds: RedBlackTreeBoundRangeExpression<Key>) {
      __tree_.ensureUnique()
      let (lower, upper) = bounds.relative(to: __tree_)
      __tree_.___erase(lower.pointer!, upper.pointer!)
    }

    public mutating func removeBounds(
      _ bounds: RedBlackTreeBoundRangeExpression<Key>,
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

    public mutating func removeBounds(
      unchecked bounds: RedBlackTreeBoundRangeExpression<Key>,
      where shouldBeRemoved: (Element) throws -> Bool
    ) rethrows {
      __tree_.ensureUnique()
      let (lower, upper) = bounds.relative(to: __tree_)
      try __tree_.___erase_if(
        lower, upper, shouldBeRemoved: { try shouldBeRemoved($0.tuple) })
    }
  }
#endif
