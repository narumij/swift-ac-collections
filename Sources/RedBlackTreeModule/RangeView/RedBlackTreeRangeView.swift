//
//  RedBlackTreeRangeView.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/29.
//

struct RedBlackTreeKeyOnlyRangeView<Base>: _UnsafeNodePtrType
where
  Base: ___MutableUnsafeBaseV2 & _ScalarBaseType
{
  public typealias Element = Base.Base._PayloadValue

  @usableFromInline
  internal var _base: Base

  @usableFromInline
  internal let _start, _end: _NodePtr
}

extension RedBlackTreeKeyOnlyRangeView {

  @usableFromInline
  internal var __tree_: Base.Tree {
    _base.__tree_
  }
}

extension RedBlackTreeKeyOnlyRangeView {

  @inlinable
  public mutating func remove(where shouldBeRemoved: (Element) throws -> Bool) rethrows {
    _base.__tree_.ensureUnique()
    try __tree_.___checking_erase_if(_start, _end, shouldBeRemoved: shouldBeRemoved)
  }
}
