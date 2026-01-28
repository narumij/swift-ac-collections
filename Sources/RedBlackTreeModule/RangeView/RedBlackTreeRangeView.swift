//
//  RedBlackTreeRangeView.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/29.
//

public struct RedBlackTreeKeyOnlyRangeView<Base: ___TreeBase & ___TreeIndex>:
  ___MutableUnsafeBaseV2, ___UnsafeKeyOnlySequenceV2
where
  Base: ___TreeBase & ___TreeIndex,
  Base._Key == Base._PayloadValue,
  Base._Key: Comparable
{
  public typealias Element = Base._PayloadValue

  @usableFromInline
  internal var __tree_: Tree

  @usableFromInline
  internal var _start, _end: _NodePtr
}

extension RedBlackTreeKeyOnlyRangeView: Sequence {}

extension RedBlackTreeKeyOnlyRangeView {

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public __consuming func makeIterator() -> Tree._PayloadValues {
    _makeIterator()
  }
}

extension RedBlackTreeKeyOnlyRangeView {

  @inlinable
  public mutating func removeSubrange() {
    __tree_.ensureUnique()
    (_start, _end) = (__tree_.___NodePtr(_start.trackingTag), __tree_.___NodePtr(_end.trackingTag))
    __tree_.___checking_erase(_start, _end)
  }

  @inlinable
  public mutating func removeSubrange(where shouldBeRemoved: (Element) throws -> Bool) rethrows {
    __tree_.ensureUnique()
    (_start, _end) = (__tree_.___NodePtr(_start.trackingTag), __tree_.___NodePtr(_end.trackingTag))
    try __tree_.___checking_erase_if(_start, _end, shouldBeRemoved: shouldBeRemoved)
  }
}

#if AC_COLLECTIONS_INTERNAL_CHECKS
  extension RedBlackTreeKeyOnlyRangeView {
    package var _copyCount: UInt {
      __tree_.copyCount
    }
  }
#endif
