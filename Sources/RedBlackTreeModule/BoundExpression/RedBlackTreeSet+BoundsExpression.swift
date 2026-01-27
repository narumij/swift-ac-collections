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

// TODO: BoundsExpressionのmap型への展開

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeSet {

    // TODO: 新APIを整理し、全てのコレクションに展開する
    
    @inlinable
    public subscript(bound: RedBlackTreeBound<Element>) -> Element? {
      let p = bound.relative(to: __tree_)
      guard !p.___is_null_or_end else { return nil }
      return __tree_[p]
    }
    
    public func index(_ bound: RedBlackTreeBound<Element>) -> Index
    {
      return ___index(bound.relative(to: __tree_))
    }
    
    public mutating func remove(_ bound: RedBlackTreeBound<Element>) -> Element? {
      __tree_.ensureUnique()
      let p = bound.relative(to: __tree_)
      guard !p.___is_null_or_end else { return nil }
      guard let element = ___remove(at: p) else {
        fatalError(.invalidIndex)
      }
      return element
    }

    public subscript(bounds: RedBlackTreeBoundsExpression<Element>) -> SubSequence {
      let (lower, upper) = bounds.relative(to: __tree_)
      guard __tree_.isValidRawRange(lower: lower, upper: upper) else {
        fatalError(.invalidIndex)
      }
      return .init(tree: __tree_, start: lower, end: upper)
    }

    public subscript(unchecked bounds: RedBlackTreeBoundsExpression<Element>) -> SubSequence {
      let (lower, upper) = bounds.relative(to: __tree_)
      return .init(tree: __tree_, start: lower, end: upper)
    }

    public func indices(bounds: RedBlackTreeBoundsExpression<Element>)
      -> UnsafeIndexV2Collection<Self>
    {
      let (lower, upper) = bounds.relative(to: __tree_)
      guard lower == upper || __tree_.___ptr_comp(lower, upper) else {
        fatalError(.invalidIndex)
      }
      return .init(start: lower, end: upper, tie: __tree_.tied)
    }
    
    public mutating func removeBounds(_ bounds: RedBlackTreeBoundsExpression<Element>) {
      __tree_.ensureUnique()
      let (lower, upper) = bounds.relative(to: __tree_)
      guard __tree_.isValidRawRange(lower: lower, upper: upper) else {
        fatalError(.invalidIndex)
      }
      __tree_.___erase(lower, upper)
    }

    public mutating func removeBounds(unchecked bounds: RedBlackTreeBoundsExpression<Element>) {
      __tree_.ensureUnique()
      let (lower, upper) = bounds.relative(to: __tree_)
      __tree_.___erase(lower, upper)
    }

    public mutating func removeBounds(
      _ bounds: RedBlackTreeBoundsExpression<Element>,
      where shouldBeRemoved: (Element) throws -> Bool
    ) rethrows {
      __tree_.ensureUnique()
      let (lower, upper) = bounds.relative(to: __tree_)
      guard __tree_.isValidRawRange(lower: lower, upper: upper) else {
        fatalError(.invalidIndex)
      }
      try __tree_.___erase_if(lower, upper, shouldBeRemoved: shouldBeRemoved)
    }

    public mutating func removeBounds(
      unchecked bounds: RedBlackTreeBoundsExpression<Element>,
      where shouldBeRemoved: (Element) throws -> Bool
    ) rethrows {
      __tree_.ensureUnique()
      let (lower, upper) = bounds.relative(to: __tree_)
      try __tree_.___erase_if(lower, upper, shouldBeRemoved: shouldBeRemoved)
    }
  }
#endif
