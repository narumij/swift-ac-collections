//
//  RedBlackTreeCollectionBase.swift
//  swift-ac-collections
//
//  Created by narumij on 2025/05/29.
//

@usableFromInline
protocol RedBlackTreeSubSequenceBase: RedBlackTreeSequenceBase
where Tree: ___CollectionProtocol & ___ForEachProtocol, Index.Tree == Tree
{
  associatedtype Index: RedBlackTreeIndex
}

