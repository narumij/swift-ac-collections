//
//  RedBlackTreeIteratable.swift
//  swift-ac-collections
//
//  Created by narumij on 2025/05/28.
//

public protocol RedBlackTreeRawIndexIteratable {
  associatedtype Tree: IteratableProtocol
}

protocol RedBlackTreeCollectionable: RedBlackTreeRawIndexIteratable
where Tree: CollectionableProtocol, Index.Tree == Tree
{
  associatedtype Index: RedBlackTreeIndex
}

protocol RedBlackTreeIndex: Strideable & RedBlackTreeRawValue where Stride == Int {
  associatedtype Tree
  init(__tree: Tree, rawValue: _NodePtr)
}

protocol RedBlackTreeRawValue {
  var rawValue: _NodePtr { get }
}
