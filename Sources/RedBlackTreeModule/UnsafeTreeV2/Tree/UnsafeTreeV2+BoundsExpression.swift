//
//  UnsafeTreeV2+BoundsExpression.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/20.
//

extension UnsafeTreeV2 {

  @usableFromInline
  func relative(from b: RedBlackTreeBound<_Key>) -> _NodePtr {
    switch b {
    case .start: __begin_node_
    case .end: __end_node
    case .lower(let l): lower_bound(l)
    case .upper(let r): upper_bound(r)
    }
  }
}

extension UnsafeTreeV2 {

//  func relative<K>(to boundsExpression: RedBlackTreeBoundsExpression<K>) -> (_NodePtr, _NodePtr)
//  where K == _Key {
//    switch boundsExpression {
//    case .range(let lhs, let rhs):
//      return (relative(from: lhs), relative(from: rhs))
//    case .closedRange(let lhs, let rhs):
//      return (relative(from: lhs), __tree_next(relative(from: rhs)))
//    case .partialRangeTo(let rhs):
//      return (__begin_node_, relative(from: rhs))
//    case .partialRangeThrough(let rhs):
//      return (__begin_node_, __tree_next(relative(from: rhs)))
//    case .partialRangeFrom(let lhs):
//      return (relative(from: lhs), __end_node)
//    }
//  }

  func relative<K>(to boundsExpression: RedBlackTreeBoundsExpression<K>)
    -> UnsafeTreeRangeExpression
  where K == _Key {
    switch boundsExpression {
    case .range(let lhs, let rhs):
      return .range(from: relative(from: lhs), to: relative(from: rhs))
    case .closedRange(let lhs, let rhs):
      return .closedRange(from: relative(from: lhs), through: relative(from: rhs))
    case .partialRangeTo(let rhs):
      return .partialRangeTo(relative(from: rhs))
    case .partialRangeThrough(let rhs):
      return .partialRangeThrough(relative(from: rhs))
    case .partialRangeFrom(let lhs):
      return .partialRangeFrom(relative(from: lhs))
    }
  }
}
