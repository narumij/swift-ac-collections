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

  func relative<K>(to boundsExpression: RedBlackTreeBoundsExpression<K>) -> (_NodePtr, _NodePtr)
  where K == _Key {
    switch boundsExpression {
    case .range(let lhs, let rhs):
      return (relative(from: lhs), relative(from: rhs))
    case .closedRange(let lhs, let rhs):
      return (relative(from: lhs), __tree_next(relative(from: rhs)))
    case .partialRangeTo(let rhs):
      return (__begin_node_, relative(from: rhs))
    case .partialRangeThrough(let rhs):
      return (__begin_node_, __tree_next(relative(from: rhs)))
    case .partialRangeFrom(let lhs):
      return (relative(from: lhs), __end_node)
    }
  }
}

// MARK: -

#if !COMPATIBLE_ATCODER_2025
extension RedBlackTreeSet {

  // TODO: 新APIを整理し、全てのコレクションに展開する

  public mutating func removeBounds(_ range: RedBlackTreeBoundsExpression<Element>) {
    let (lhs, rhs) = __tree_.relative(to: range)
    guard lhs == rhs || __tree_.___ptr_comp(lhs, rhs) else {
      fatalError(.invalidIndex)
    }
    _ = __tree_.erase(lhs, rhs)
  }

  public mutating func removeBounds(
    _ range: RedBlackTreeBoundsExpression<Element>,
    where shouldBeRemoved: (Element) throws -> Bool
  ) rethrows {
    let (lhs, rhs) = __tree_.relative(to: range)
    guard lhs == rhs || __tree_.___ptr_comp(lhs, rhs) else {
      fatalError(.invalidIndex)
    }
    try __tree_.___erase_if(lhs, rhs, shouldBeRemoved: shouldBeRemoved)
  }

  public subscript(bounds: RedBlackTreeBoundsExpression<Element>) -> SubSequence {
    let (lhs, rhs) = __tree_.relative(to: bounds)
    guard lhs == rhs || __tree_.___ptr_comp(lhs, rhs) else {
      fatalError(.invalidIndex)
    }
    return .init(tree: __tree_, start: lhs, end: rhs)
  }

  public func indices(bounds range: RedBlackTreeBoundsExpression<Element>)
    -> UnsafeIndexV2Collection<Self>
  {
    let (lhs, rhs) = __tree_.relative(to: range)
    guard lhs == rhs || __tree_.___ptr_comp(lhs, rhs) else {
      fatalError(.invalidIndex)
    }
    return .init(start: lhs, end: rhs, tie: __tree_.tied)
  }
}

func test() {
  var a = RedBlackTreeSet<Int>()
  typealias Index = RedBlackTreeSet<Int>.Index
  let _ = a.indices(bounds: .start ..< .end)
  let _ = a.indices(bounds: .lower(3) ..< .lower(4))
  let _ = a.removeBounds(.lower(10) ..< .lower(100)) { n in
    n % 2 == 1
  }
  let _ = a.removeBounds(.lower(10) ... .upper(100)) { n in
    n % 2 == 0
  }
  let _ = a[.lower(10) ... .end]
  let _ = a[...(.end)]
  let _ = a[.start...]
  let _ = a[start()...]
  let _ = a[lowerBound(100)...]
  let _ = a[lowerBound(100)..<end()]
}
#endif
