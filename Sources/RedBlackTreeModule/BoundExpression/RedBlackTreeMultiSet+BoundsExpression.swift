//
//  RedBlackTreeMultiSet+Bounds.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/23.
//

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiSet {

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

    public func indices(bounds range: RedBlackTreeBoundsExpression<Element>)
      -> UnsafeIndexV2Collection<Self>
    {
      let (lower, upper) = __tree_.rawRange(__tree_.relative(to: range))
      guard lower == upper || __tree_.___ptr_comp(lower, upper) else {
        fatalError(.invalidIndex)
      }
      return .init(start: lower, end: upper, tie: __tree_.tied)
    }

    public mutating func removeBounds(_ range: RedBlackTreeBoundsExpression<Element>) {
      let (lower, upper) = __tree_.rawRange(__tree_.relative(to: range))
      guard __tree_.isValidRawRange(lower: lower, upper: upper) else {
        fatalError(.invalidIndex)
      }
      _ = __tree_.erase(lower, upper)
    }

    public mutating func removeBounds(unchecked range: RedBlackTreeBoundsExpression<Element>) {
      let (lower, upper) = __tree_.rawRange(__tree_.relative(to: range))
      _ = __tree_.erase(lower, upper)
    }

    public mutating func removeBounds(
      _ range: RedBlackTreeBoundsExpression<Element>,
      where shouldBeRemoved: (Element) throws -> Bool
    ) rethrows {
      let (lower, upper) = __tree_.rawRange(__tree_.relative(to: range))
      guard __tree_.isValidRawRange(lower: lower, upper: upper) else {
        fatalError(.invalidIndex)
      }
      try __tree_.___erase_if(lower, upper, shouldBeRemoved: shouldBeRemoved)
    }

    public mutating func removeBounds(
      unchecked range: RedBlackTreeBoundsExpression<Element>,
      where shouldBeRemoved: (Element) throws -> Bool
    ) rethrows {
      let (lower, upper) = __tree_.rawRange(__tree_.relative(to: range))
      try __tree_.___erase_if(lower, upper, shouldBeRemoved: shouldBeRemoved)
    }
  }
#endif
