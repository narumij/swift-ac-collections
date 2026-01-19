//
//  RedBlackTreeRangeExpression.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/19.
//

public protocol RedBlackTreeRangeExpression: RangeExpression {
  func _relativeRange<_Key, B>(relative: (Bound) -> B, after: (B) -> B) -> (B, B)
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
    let (lower, upper) = range._relativeRange(
      relative: { $0.relative(to: self) },
      after: { self.index(after: $0) })
    return lower..<upper
  }

  @inlinable
  public func removeSub<R: RangeExpression>(
    bound range: R,
    where shouldBeRemoved: (Element) throws -> Bool
  ) rethrows
  where
    R.Bound == RedBlackTreeBound<_Key>,
    R: RedBlackTreeRangeExpression
  {
    let (lower, upper) = range._relativeRange(
      relative: { $0.relative(to: __tree_) },
      after: { __tree_next($0) })

    try __tree_.___erase_unique_if(lower, upper, shouldBeRemoved: shouldBeRemoved)
  }
}

func test() {
  let a = RedBlackTreeSet<Int>()
  typealias Index = RedBlackTreeSet<Int>.Index
  let _: Range<Index> = a.indices(bound: .start ..< .end)
  let _: Range<Index> = a.indices(bound: .lower(3) ..< .lower(4))
  let _ = a.removeSub(bound: .lower(10) ... .upper(100)) { n in
    n % 2 == 0
  }
}
