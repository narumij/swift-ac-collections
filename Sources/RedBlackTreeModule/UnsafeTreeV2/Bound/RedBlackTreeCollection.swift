//
//  RedBlackTreeCollection.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/19.
//

public protocol RedBlackTreeCollectionProtocol: Collection {
  associatedtype Key
  associatedtype Index
  var startIndex: Index { get }
  var endIndex: Index { get }
  func lowerBound(_: Key) -> Index
  func upperBound(_: Key) -> Index
}

extension RedBlackTreeBound {

  func relative<C: RedBlackTreeCollectionProtocol>(to collection: C) -> C.Index where _Key == C.Key {
    switch self {
    case .start: collection.startIndex
    case .end: collection.endIndex
    case .lower(let l): collection.lowerBound(l)
    case .upper(let r): collection.upperBound(r)
    }
  }
}

@usableFromInline
protocol UnsafeTreeCollectionProtocol:
  _UnsafeNodePtrType & _KeyType,
  BeginNodeInterface & EndNodeInterface & BoundInteface,
  Collection
{}

extension RedBlackTreeBound {

  func relative<C: UnsafeTreeCollectionProtocol>(to collection: C) -> C._NodePtr where _Key == C._Key {
    switch self {
    case .start: collection.__begin_node_
    case .end: collection.__end_node
    case .lower(let l): collection.lower_bound(l)
    case .upper(let r): collection.upper_bound(r)
    }
  }
}
