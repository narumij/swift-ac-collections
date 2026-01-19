//
//  UnsafeTreeRangeExpression.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/19.
//


@usableFromInline
protocol UnsafeTreeRangeExpression: RangeExpression {

  func relativeRange<C: UnsafeTreeCollectionProtocol>(
    to collection: C
  ) -> UnsafeTreeRange where Bound == RedBlackTreeBound<C._Key>
}
