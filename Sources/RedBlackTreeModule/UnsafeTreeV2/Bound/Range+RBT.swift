//
//  Range+RBT.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/19.
//

extension Range: RBTRangeExpression {

  public func relativeRange<C>(to collection: C) -> Range<C.Index>
  where C: RBTCollectionProtocol, Bound == RBTBound<C.Key> {

    let lower = lowerBound.relative(to: collection)
    let upper = upperBound.relative(to: collection)

    return lower..<upper
  }
}

extension Range: UnsafeTreeRangeExpression {

  @usableFromInline
  func relativeRange<C>(to collection: C) -> UnsafeTreeRange
  where C: UnsafeTreeCollectionProtocol, Bound == RBTBound<C._Key> {

    let lower = lowerBound.relative(to: collection)
    let upper = upperBound.relative(to: collection)

    return .init(__first: lower, __last: upper)
  }
}
