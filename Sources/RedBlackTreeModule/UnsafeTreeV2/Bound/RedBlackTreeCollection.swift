//
//  RedBlackTreeCollection.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/19.
//

@usableFromInline
protocol RedBlackTreeBoundResolverProtocol: Collection {
  associatedtype Key
  associatedtype Index
  var startIndex: Index { get }
  var endIndex: Index { get }
  func lowerBound(_: Key) -> Index
  func upperBound(_: Key) -> Index
}

extension RedBlackTreeBound {

  @usableFromInline
  func relative<C: RedBlackTreeBoundResolverProtocol>(to collection: C) -> C.Index where _Key == C.Key {
    switch self {
    case .start: collection.startIndex
    case .end: collection.endIndex
    case .lower(let l): collection.lowerBound(l)
    case .upper(let r): collection.upperBound(r)
    }
  }
}

extension RedBlackTreeSet: RedBlackTreeBoundResolverProtocol {}

extension UnsafeTreeV2 {
  
  @usableFromInline
  func relative(from b: RedBlackTreeBound<_Key>) -> _NodePtr
  where _Key: Comparable {
    switch b {
    case .start: __begin_node_
    case .end: __end_node
    case .lower(let l): lower_bound(l)
    case .upper(let r): upper_bound(r)
    }
  }
}
