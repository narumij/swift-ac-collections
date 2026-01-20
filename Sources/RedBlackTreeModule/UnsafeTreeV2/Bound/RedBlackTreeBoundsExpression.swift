//
//  RedBlackTreeRangeExpression.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/19.
//

// MARK: - RedBlackTreeSet

public enum RedBlackTreeBoundsExpression<_Key> {
  public typealias Bound = RedBlackTreeBound<_Key>
  case range(lhs: Bound, rhs: Bound)
  case closedRange(lhs: Bound, rhs: Bound)
  case partialRangeTo(rhs: Bound)
  case partialRangeThrough(rhs: Bound)
  case partialRangeFrom(lhs: Bound)
}

public func ..< <_Key>(lhs: RedBlackTreeBound<_Key>, rhs: RedBlackTreeBound<_Key>)
  -> RedBlackTreeBoundsExpression<_Key>
{
  .range(lhs: lhs, rhs: rhs)
}

public func ... <_Key>(lhs: RedBlackTreeBound<_Key>, rhs: RedBlackTreeBound<_Key>)
  -> RedBlackTreeBoundsExpression<_Key>
{
  .closedRange(lhs: lhs, rhs: rhs)
}

public prefix func ..< <_Key>(rhs: RedBlackTreeBound<_Key>)
  -> RedBlackTreeBoundsExpression<_Key>
{
  .partialRangeTo(rhs: rhs)
}

public prefix func ... <_Key>(rhs: RedBlackTreeBound<_Key>)
  -> RedBlackTreeBoundsExpression<_Key>
{
  .partialRangeThrough(rhs: rhs)
}

public postfix func ... <_Key>(lhs: RedBlackTreeBound<_Key>) -> RedBlackTreeBoundsExpression<_Key> {
  .partialRangeFrom(lhs: lhs)
}
