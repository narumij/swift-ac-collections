//
//  RedBlackTreeRangeExpression.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/19.
//

public protocol RedBlackTreeRangeExpression: RangeExpression {
  func relativeRange<C: RedBlackTreeCollectionProtocol>(
    to collection: C
  ) -> Range<C.Index> where Bound == RedBlackTreeBound<C.Key>
}

// MARK: - RedBlackTreeSet

extension RedBlackTreeSet: RedBlackTreeCollectionProtocol {

  @inlinable
  public func indices<R: RedBlackTreeRangeExpression>(bound range: R) -> Range<Index>
  where R.Bound == RedBlackTreeBound<Key> {
    range.relativeRange(to: self)
  }

  @inlinable
  public func removeSub<R: RedBlackTreeRangeExpression>(
    bound range: R,
    where shouldBeRemoved: (Element) throws -> Bool
  )
    rethrows -> Bool
  where R.Bound == RedBlackTreeBound<Key> {
    fatalError()
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
