//
//  RedBlackTreeRangeExpression.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/19.
//

public protocol RBTRangeExpression: RangeExpression {
  func relativeBound<C: RBTCollection>(
    to collection: C
  ) -> Range<C.Index> where Bound == RBTBound<C.Key>
}

// MARK: - RedBlackTreeSet

extension RedBlackTreeSet: RBTCollection {

  @inlinable
  public func indices<R: RBTRangeExpression>(bound range: R) -> Range<Index>
  where R.Bound == RBTBound<Key> {
    range.relativeBound(to: self)
  }

  @inlinable
  public func removeSub<R: RBTRangeExpression>(
    bound range: R,
    where shouldBeRemoved: (Element) throws -> Bool
  )
    rethrows -> Bool
  where R.Bound == RBTBound<Key> {
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
