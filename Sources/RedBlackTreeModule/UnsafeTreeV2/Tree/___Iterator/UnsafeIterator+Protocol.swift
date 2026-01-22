//
//  UnsafeIterator+Protocol.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/17.
//

public protocol ObverseIterator: IteratorProtocol
where Element == ReversedIterator.Element {
  associatedtype ReversedIterator: IteratorProtocol
  func reversed() -> ReversedIterator
}

extension ObverseIterator {
  public typealias Reversed = ReversedIterator
}

public protocol ReverseIterator: IteratorProtocol {}

public protocol UnsafeIteratorProtocol: _UnsafeNodePtrType, IteratorProtocol {
  init(start: _NodePtr, end: _NodePtr)
  var _start: _NodePtr { get }
  var _end: _NodePtr { get }
}

public protocol UnsafeAssosiatedIterator: _UnsafeNodePtrType, IteratorProtocol {
  associatedtype Base: ___TreeBase
  associatedtype Source: IteratorProtocol & Sequence
  init(tree: UnsafeTreeV2<Base>, start: _NodePtr, end: _NodePtr)
  init(_ t: Base.Type, start: _NodePtr, end: _NodePtr)
  var source: Source { get }
  var _start: _NodePtr { get }
  var _end: _NodePtr { get }
}
