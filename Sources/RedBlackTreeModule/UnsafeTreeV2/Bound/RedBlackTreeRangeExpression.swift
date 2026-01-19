//
//  RedBlackTreeRangeExpression.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/19.
//

public protocol RedBlackTreeRangeExpression: _UnsafeNodePtrType, RangeExpression {

  func _relativeRange<_Key, B>(relative: (Bound) -> B, after: (B) -> B) -> (B, B)
  where Bound == RedBlackTreeBound<_Key>

  func __relativeRange<_Key, R>(
    relative: (Bound) -> _NodePtr,
    after: (_NodePtr) -> _NodePtr,
    hoge: (_NodePtr, _NodePtr) -> R
  )
    -> R
  where Bound == RedBlackTreeBound<_Key>
}

// MARK: - RedBlackTreeSet

extension RedBlackTreeSet {

  #if false
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
    public func removeSub<R>(
      bound range: R
    )
    where
      R.Bound == RedBlackTreeBound<_Key>,
      R: RedBlackTreeRangeExpression
    {
      let (lower, upper) = range._relativeRange(
        relative: {
          __tree_.relative(from: $0)
        },
        after: { __tree_next($0) })

      _ = __tree_.erase(lower, upper)
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
      let (lower, upper) = range._relativeRange(
        relative: {
          __tree_.relative(from: $0)
        },
        after: { __tree_next($0) })

      try __tree_.___erase_if(lower, upper, shouldBeRemoved: shouldBeRemoved)
    }
  #endif

  @inlinable
  public subscript<R>(bounds: R) -> SubSequence
  where
    R.Bound == RedBlackTreeBound<_Key>,
    R: RedBlackTreeRangeExpression
  {
    bounds.__relativeRange(
      relative: {
        __tree_._relative(from: $0)
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
  #if false
    let _: Range<Index> = a.indices(bound: .start ..< .end)
    let _: Range<Index> = a.indices(bound: .lower(3) ..< .lower(4))

    let _ = a.removeSub(bound: .lower(10) ..< .lower(100)) { n in
      n % 2 == 1
    }

    let _ = a.removeSub(bound: .lower(10) ... .upper(100)) { n in
      n % 2 == 0
    }
  #endif

  let _ = a[.lower(10) ... .end]
}
