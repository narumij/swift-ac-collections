//
//  Range+RBT.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/19.
//

extension Range: RedBlackTreeRangeExpression {
  
  public func withBounds<_Key, B, R>(
    relative: (Bound) -> B,
    after: (B) -> B,
    _ body: (B, B) throws -> R
  ) rethrows
  -> R
  where Bound == RedBlackTreeBound<_Key> {
    
    try withExtendedLifetime(self) {
      let l = relative(lowerBound)
      let u = relative(upperBound)
      return try body(l, u)
    }
  }
}
