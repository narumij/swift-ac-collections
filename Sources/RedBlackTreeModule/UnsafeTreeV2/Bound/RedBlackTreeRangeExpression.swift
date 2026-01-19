//
//  RedBlackTreeRangeExpression.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/19.
//

public protocol RedBlackTreeRangeExpression: RangeExpression {

  func withBounds<_Key, B, R>(
    relative: (Bound) -> B,
    after: (B) -> B,
    _ body: (B, B) throws -> R
  ) rethrows
    -> R
  where Bound == RedBlackTreeBound<_Key>
}

// MARK: - RedBlackTreeSet

extension RedBlackTreeSet {

  @inlinable
  public func indices<R: RangeExpression>(bound range: R) -> Range<Index>
  where
    R.Bound == RedBlackTreeBound<_Key>,
    R: RedBlackTreeRangeExpression
  {
    range.withBounds(
      relative: { $0.relative(to: self) },
      after: { self.index(after: $0) }
    ) { lower, upper in
      return lower..<upper
    }
  }

  @inlinable
  public func removeSub<R>(
    bound range: R
  )
  where
    R.Bound == RedBlackTreeBound<_Key>,
    R: RedBlackTreeRangeExpression
  {
    range.withBounds(
      relative: {
        __tree_.relative(from: $0)
      },
      after: { __tree_next($0) }
    ) { lower, upper in
      _ = __tree_.erase(lower, upper)
    }
  }

  @inlinable
  public func removeSub<R>(
    bound range: R,
    where shouldBeRemoved: (Element) throws -> Bool
  ) rethrows
  where
    R.Bound == RedBlackTreeBound<_Key>,
    R: RedBlackTreeRangeExpression
  {
    try range.withBounds(
      relative: {
        __tree_.relative(from: $0)
      },
      after: {
        __tree_next($0)
      }
    ) { lower, upper in

      try __tree_.___erase_if(lower, upper, shouldBeRemoved: shouldBeRemoved)
    }
  }

  @inlinable
  public subscript<R>(bounds: R) -> SubSequence
  where
    R.Bound == RedBlackTreeBound<_Key>,
    R: RedBlackTreeRangeExpression
  {
    bounds.withBounds(
      relative: {
        __tree_.relative(from: $0)
      },
      after: {
        __tree_next($0)
      }
    ) { lower, upper in

      return SubSequence(tree: __tree_, start: lower, end: upper)
    }
  }
}

func test() {
  let a = RedBlackTreeSet<Int>()
  typealias Index = RedBlackTreeSet<Int>.Index
  let _: Range<Index> = a.indices(bound: .start ..< .end)
  let _: Range<Index> = a.indices(bound: .lower(3) ..< .lower(4))

  let _ = a.removeSub(bound: .lower(10) ..< .lower(100)) { n in
    n % 2 == 1
  }

  let _ = a.removeSub(bound: .lower(10) ... .upper(100)) { n in
    n % 2 == 0
  }

  let _ = a[.lower(10) ... .end]
}
