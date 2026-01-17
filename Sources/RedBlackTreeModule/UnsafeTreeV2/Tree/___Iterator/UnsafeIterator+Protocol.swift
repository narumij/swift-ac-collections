//
//  UnsafeIterator+Protocol.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/17.
//


public protocol UnsafeIteratorProtocol: UnsafeTreePointer {
  init<Base: ___TreeBase>(tree: UnsafeTreeV2<Base>, start: _NodePtr, end: _NodePtr)
  init<Base: ___TreeBase>(__tree_: UnsafeImmutableTree<Base>, start: _NodePtr, end: _NodePtr)
}

public protocol UnsafeAssosiatedIterator: UnsafeTreePointer {
  associatedtype Base: ___TreeBase
  associatedtype Source: IteratorProtocol & Sequence
  init(tree: UnsafeTreeV2<Base>, start: _NodePtr, end: _NodePtr)
  init(__tree_: UnsafeImmutableTree<Base>, start: _NodePtr, end: _NodePtr)
  var source: Source { get }
}
