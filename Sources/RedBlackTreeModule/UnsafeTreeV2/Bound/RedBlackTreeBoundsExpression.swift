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
  case leftUnbound(rhs: Bound)
  case leftUnboundRightClose(rhs: Bound)
  case rithUnbound(lhs: Bound)
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
  .leftUnbound(rhs: rhs)
}

public prefix func ... <_Key>(rhs: RedBlackTreeBound<_Key>)
  -> RedBlackTreeBoundsExpression<_Key>
{
  .leftUnboundRightClose(rhs: rhs)
}

public postfix func ... <_Key>(lhs: RedBlackTreeBound<_Key>) -> RedBlackTreeBoundsExpression<_Key> {
  .rithUnbound(lhs: lhs)
}


func test() {
  var a = RedBlackTreeSet<Int>()
  typealias Index = RedBlackTreeSet<Int>.Index
  let _ = a.indices(bounds: .start ..< .end)
  let _ = a.indices(bounds: .lower(3) ..< .lower(4))
  let _ = a.removeSub(bounds: .lower(10) ..< .lower(100)) { n in
    n % 2 == 1
  }
  let _ = a.removeSub(bounds: .lower(10) ... .upper(100)) { n in
    n % 2 == 0
  }
  let _ = a[.lower(10) ... .end]
  let _ = a[...(.end)]
  let _ = a[.start...]
}
