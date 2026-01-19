//
//  ClosedRange+RBT.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/19.
//

extension ClosedRange: RBTRangeExpression {
  
  public func relativeBound<C>(to collection: C) -> Range<C.Index>
  where C: RBTCollection, Bound == RBTBound<C.Key> {

    let lower = lowerBound.relative(to: collection)
    let upper = upperBound.relative(to: collection)
    return lower..<collection.index(after: upper)
  }
}
