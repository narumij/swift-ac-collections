//
//  ___Base.swift
//  swift-ac-collections
//
//  Created by narumij on 2025/12/24.
//

@usableFromInline
protocol ___Base: ___RedBlackTree___
where
  Base: ___TreeBase & ___TreeIndex,
  Tree == ___Tree<Base>,
  Index == Tree.Index,
  Indices == Tree.Indices,
  _Key == Tree._Key,
  _Value == Tree._Value
{
  associatedtype Index
  associatedtype Indices
  associatedtype _Key
  associatedtype _Value
  var __tree_: Tree { get }
  var _start: _NodePtr { get }
  var _end: _NodePtr { get }
  
  func ___index(_ p: _NodePtr) -> Index
}
