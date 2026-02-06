//
//  RedBlackTreeUniqueView.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/31.
//

/// C++を模倣したい場合に使う
///
public struct _RedBlackTreeUniqueView<Base>:
  UnsafeMutableTreeHost,
  _KeyBride,
  _PayloadValueBride,
  UnsafeIndexBinding,
  ___UnsafeBaseSequenceV2__,
  ___UnsafeIndexV2
where
  Base: ___TreeBase & ___TreeIndex
{

  @usableFromInline
  internal init(__tree_: UnsafeTreeV2<Base>) {
    self.__tree_ = __tree_
  }

  @usableFromInline
  internal var __tree_: Tree
}

extension _RedBlackTreeUniqueView {

  @usableFromInline
  func ___index(_ p: _SealedPtr) -> Index {
    Index(sealed: p, tie: __tree_.tied)
  }
}

extension _RedBlackTreeUniqueView {

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public __consuming func begin() -> Index { _startIndex }

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public __consuming func end() -> Index { _endIndex }
}

extension _RedBlackTreeUniqueView {

  /// - Complexity: O(log `count`)
  @inlinable
  public __consuming func lowerBound(_ member: _Key) -> Index {
    ___index_lower_bound(member)
  }

  /// - Complexity: O(log `count`)
  @inlinable
  public __consuming func upperBound(_ member: _Key) -> Index {
    ___index_upper_bound(member)
  }
}

extension _RedBlackTreeUniqueView {

  /// - Complexity: O(log `count`)
  @inlinable
  public __consuming func find(_ member: _Key) -> Index? {
    ___index_or_nil(__tree_.find(member).sealed)
  }
}

extension _RedBlackTreeUniqueView {

  @inlinable
  public mutating func erase(_ ptr: Index) -> Index {
    __tree_.ensureUnique()
    return ___erase(ptr)
  }
}
