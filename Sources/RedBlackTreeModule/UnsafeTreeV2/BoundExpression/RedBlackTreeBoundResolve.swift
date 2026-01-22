//
//  RedBlackTreeCollection.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/19.
//

#if false
// TODO: 現行互換実装の作業をする
@usableFromInline
protocol RedBlackTreeBoundResolverProtocol: Collection
where Base: ___TreeBase & ___TreeIndex, Index == UnsafeIndexV2<Base> {
  associatedtype _Key
  associatedtype Base
  associatedtype Index
  var startIndex: Index { get }
  var endIndex: Index { get }
  func lowerBound(_: _Key) -> Index
  func upperBound(_: _Key) -> Index
}

extension RedBlackTreeBound {

  @usableFromInline
  func relative<C: RedBlackTreeBoundResolverProtocol>(to collection: C) -> C.Index where _Key == C._Key {
    switch self {
    case .start: collection.startIndex
    case .end: collection.endIndex
    case .lower(let l): collection.lowerBound(l)
    case .upper(let r): collection.upperBound(r)
    }
  }
}

extension RedBlackTreeBoundResolverProtocol {

  func relative<K>(to boundsExpression: RedBlackTreeBoundsExpression<K>) -> (Index, Index)
  where K == _Key {
    switch boundsExpression {
    case .range(let lhs, let rhs):
      return (lhs.relative(to: self), rhs.relative(to: self))
    case .closedRange(let lhs, let rhs):
      return (lhs.relative(to: self), rhs.relative(to: self).next!)
    case .leftUnbound(let rhs):
      return (startIndex, rhs.relative(to: self))
    case .leftUnboundRightClose(let rhs):
      return (startIndex, rhs.relative(to: self).next!)
    case .rithUnbound(let lhs):
      return (lhs.relative(to: self), endIndex)
    }
  }
}

extension RedBlackTreeSet: RedBlackTreeBoundResolverProtocol {}
extension RedBlackTreeMultiSet: RedBlackTreeBoundResolverProtocol {}
extension RedBlackTreeDictionary: RedBlackTreeBoundResolverProtocol {}
extension RedBlackTreeMultiMap: RedBlackTreeBoundResolverProtocol {}
#endif
