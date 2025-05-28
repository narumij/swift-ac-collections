//
//  RedBlackTreeIteratable.swift
//  swift-ac-collections
//
//  Created by narumij on 2025/05/28.
//

public protocol RedBlackTreeRawIndexIteratable {
  associatedtype Tree: IteratableProtocol
}

public protocol RedBlackTreeCollectionable: RedBlackTreeRawIndexIteratable
where Tree: CollectionableProtocol, Index.Tree == Tree
{
  associatedtype Index: RedBlackTreeIndex
}

public protocol RedBlackTreeIndex: Strideable & RedBlackTreeRawValue where Stride == Int {
  associatedtype Tree
  init(__tree: Tree, rawValue: _NodePtr)
}

public protocol RedBlackTreeRawValue {
  var rawValue: _NodePtr { get }
}
