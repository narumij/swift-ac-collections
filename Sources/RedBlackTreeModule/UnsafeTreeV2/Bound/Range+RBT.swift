//
//  Range+RBT.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/19.
//

extension Range: RedBlackTreeRangeExpression {
  
  public func _relativeRange<_Key,B>(relative: (Bound) -> B, after: (B) -> B) -> (B, B)
  where Bound == RedBlackTreeBound<_Key> {
    let lower = relative(lowerBound)
    let upper = relative(upperBound)
    return (lower, upper)
  }
}
