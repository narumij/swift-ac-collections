//
//  ClosedRange+RBT.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/19.
//

extension ClosedRange: RedBlackTreeRangeExpression {

  public func relativeRange<C>(to collection: C) -> Range<C.Index>
  where C: RedBlackTreeCollectionProtocol, Bound == RedBlackTreeBound<C.Key> {

    let lower = lowerBound.relative(to: collection)
    let upper = upperBound.relative(to: collection)
    
    return lower..<collection.index(after: upper)
  }
}

extension ClosedRange: UnsafeTreeRangeExpression {

  @usableFromInline
  func relativeRange<C>(to collection: C) -> UnsafeTreeRange
  where C: UnsafeTreeCollectionProtocol, Bound == RedBlackTreeBound<C._Key> {

    let lower = lowerBound.relative(to: collection)
    let upper = upperBound.relative(to: collection)

    return .init(__first: lower, __last: __tree_next(upper))
  }
}
