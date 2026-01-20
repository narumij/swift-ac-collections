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

// MARK: -

extension RedBlackTreeSet {

  public func indices(bounds range: RedBlackTreeBoundsExpression<Element>)
    -> UnsafeIndexV2Collection<Self>
  {
    let (lhs, rhs) = __tree_.relative(to: range)
    return .init(tree: __tree_, start: lhs, end: rhs)
  }

  public mutating func removeSub(bounds range: RedBlackTreeBoundsExpression<Element>) {
    let (lhs, rhs) = __tree_.relative(to: range)
    _ = __tree_.erase(lhs, rhs)
  }

  public mutating func removeSub(
    bounds range: RedBlackTreeBoundsExpression<Element>,
    where shouldBeRemoved: (Element) throws -> Bool
  ) rethrows {
    let (lhs, rhs) = __tree_.relative(to: range)
    try __tree_.___erase_if(lhs, rhs, shouldBeRemoved: shouldBeRemoved)
  }

  public subscript(bounds: RedBlackTreeBoundsExpression<Element>) -> SubSequence {
    let (lhs, rhs) = __tree_.relative(to: bounds)
    return .init(tree: __tree_, start: lhs, end: rhs)
  }
}

extension UnsafeTreeV2 {

  func relative<K>(to boundsExpression: RedBlackTreeBoundsExpression<K>) -> (_NodePtr, _NodePtr)
  where K == _Key {
    switch boundsExpression {
    case .range(let lhs, let rhs):
      return (relative(from: lhs), relative(from: rhs))
    case .closedRange(let lhs, let rhs):
      return (relative(from: lhs), __tree_next(relative(from: rhs)))
    case .leftUnbound(let rhs):
      return (__begin_node_, relative(from: rhs))
    case .leftUnboundRightClose(let rhs):
      return (__begin_node_, __tree_next(relative(from: rhs)))
    case .rithUnbound(let lhs):
      return (relative(from: lhs), __end_node)
    }
  }
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
