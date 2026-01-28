//
//  RedBlackTreeRangeView.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/29.
//

struct RedBlackTreeKeyOnlyRangeView<Base: ___TreeBase & ___TreeIndex>: ___MutableUnsafeBaseV2
{
  public typealias Element = Base._PayloadValue

  @usableFromInline
  internal var __tree_: Tree

  @usableFromInline
  internal let _start, _end: _NodePtr
}

extension RedBlackTreeKeyOnlyRangeView {

  @inlinable
  public mutating func removeSubrange() {
    __tree_.ensureUnique()
    __tree_.___checking_erase(_start, _end)
  }
  
  @inlinable
  public mutating func removeSubrange(where shouldBeRemoved: (Element) throws -> Bool) rethrows {
    __tree_.ensureUnique()
    try __tree_.___checking_erase_if(_start, _end, shouldBeRemoved: shouldBeRemoved)
  }
}
