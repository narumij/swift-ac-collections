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
where Tree: CollectionableProtocol
{
  associatedtype Index: RedBlackTreeCollectionIndex
  static func index(tree: Tree, rawValue: _NodePtr) -> Index
}

public protocol RedBlackTreeCollectionIndex: Strideable where Stride == Int {
  var rawValue: _NodePtr { get }
}
