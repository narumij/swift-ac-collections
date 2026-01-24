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

    public subscript(bounds: RedBlackTreeBoundsExpression<Element>) -> SubSequence {
      let (lower, upper) = __tree_.rawRange(__tree_.relative(to: bounds))
      guard __tree_.isValidRawRange(lower: lower, upper: upper) else {
        fatalError(.invalidIndex)
      }
      return .init(tree: __tree_, start: lower, end: upper)
    }

    public subscript(unchecked bounds: RedBlackTreeBoundsExpression<Element>) -> SubSequence {
      let (lower, upper) = __tree_.rawRange(__tree_.relative(to: bounds))
      return .init(tree: __tree_, start: lower, end: upper)
    }

    public func indices(bounds: RedBlackTreeBoundsExpression<Element>)
      -> UnsafeIndexV2Collection<Self>
    {
      let (lower, upper) = __tree_.rawRange(__tree_.relative(to: bounds))
      guard lower == upper || __tree_.___ptr_comp(lower, upper) else {
        fatalError(.invalidIndex)
      }
      return .init(start: lower, end: upper, tie: __tree_.tied)
    }

    public mutating func removeBounds(_ bounds: RedBlackTreeBoundsExpression<Element>) {
      let (lower, upper) = __tree_.rawRange(__tree_.relative(to: bounds))
      guard __tree_.isValidRawRange(lower: lower, upper: upper) else {
        fatalError(.invalidIndex)
      }
      _ = __tree_.erase(lower, upper)
    }

    public mutating func removeBounds(unchecked bounds: RedBlackTreeBoundsExpression<Element>) {
      let (lower, upper) = __tree_.rawRange(__tree_.relative(to: bounds))
      _ = __tree_.___fault_torelant_erase(lower, upper)
    }

    public mutating func removeBounds(
      _ bounds: RedBlackTreeBoundsExpression<Element>,
      where shouldBeRemoved: (Element) throws -> Bool
    ) rethrows {
      let (lower, upper) = __tree_.rawRange(__tree_.relative(to: bounds))
      guard __tree_.isValidRawRange(lower: lower, upper: upper) else {
        fatalError(.invalidIndex)
      }
      try __tree_.___erase_if(lower, upper, shouldBeRemoved: shouldBeRemoved)
    }

    public mutating func removeBounds(
      unchecked bounds: RedBlackTreeBoundsExpression<Element>,
      where shouldBeRemoved: (Element) throws -> Bool
    ) rethrows {
      let (lower, upper) = __tree_.rawRange(__tree_.relative(to: bounds))
      try __tree_.___fault_torelant_erase_if(lower, upper, shouldBeRemoved: shouldBeRemoved)
    }
  }
#endif
