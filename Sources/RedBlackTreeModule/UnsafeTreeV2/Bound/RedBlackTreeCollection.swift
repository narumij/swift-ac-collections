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


//@usableFromInline
//protocol UnsafeTreeBoundResolverProtocol:
//  _UnsafeNodePtrType & _KeyType,
//  BeginNodeInterface & EndNodeInterface & BoundInteface
//{
//  func relative<C: UnsafeTreeBoundResolverProtocol>(to collection: C) -> C._NodePtr where _Key == C._Key
//}
//
//extension RedBlackTreeBound {
//
//  @usableFromInline
//  func relative<C: UnsafeTreeBoundResolverProtocol>(to collection: C) -> C._NodePtr where _Key == C._Key {
//    switch self {
//    case .start: collection.__begin_node_
//    case .end: collection.__end_node
//    case .lower(let l): collection.lower_bound(l)
//    case .upper(let r): collection.upper_bound(r)
//    }
//  }
//}

@usableFromInline
class DummyPtr: _UnsafeNodePtrType {
  @usableFromInline
  internal init(p: UnsafeMutablePointer<UnsafeNode>) {
    self.p = p
  }
  @usableFromInline var p: _NodePtr
}

extension UnsafeTreeV2 {
  
  @usableFromInline
  func _relative(from b: RedBlackTreeBound<_Key>) -> _NodePtr
  where _Key: Comparable {
    switch b {
    case .start: __begin_node_
    case .end: __end_node
    case .lower(let l): lower_bound(l)
    case .upper(let r): upper_bound(r)
    }
  }
  
  @usableFromInline
  func relative(from b: RedBlackTreeBound<_Key>) -> DummyPtr
  where _Key: Comparable {
    .init(p: _relative(from: b))
  }
}
