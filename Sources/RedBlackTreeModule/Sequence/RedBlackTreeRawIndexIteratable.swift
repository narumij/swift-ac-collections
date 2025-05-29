//
//  RedBlackTreeIteratable.swift
//  swift-ac-collections
//
//  Created by narumij on 2025/05/28.
//

public protocol RedBlackTreeRawIndexIteratable {
  associatedtype Tree: IteratableProtocol
}

@usableFromInline
protocol RedBlackTreeCollectionable: RedBlackTreeRawIndexIteratable
where Tree: CollectionableProtocol, Index.Tree == Tree
{
  associatedtype Index: RedBlackTreeIndex
}

@usableFromInline
protocol RedBlackTreeIndex: Strideable & RedBlackTreeMutableRawValue where Stride == Int {
  associatedtype Tree
  init(__tree: Tree, rawValue: _NodePtr)
}

@usableFromInline
protocol RedBlackTreeRawValue {
  var rawValue: _NodePtr { get }
}

@usableFromInline
protocol RedBlackTreeMutableRawValue: RedBlackTreeRawValue {
  var rawValue: _NodePtr { get set }
}
