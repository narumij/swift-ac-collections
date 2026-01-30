//
//  RedBlackTreeUniqueView.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/31.
//

public struct _RedBlackTreeUniqueView<Base>: UnsafeTreeHost, _KeyBride, _PayloadValueBride, UnsafeIndexBinding, ___UnsafeBaseSequenceV2, ___UnsafeIndexV2
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
  
  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public var startIndex: Index { _startIndex }

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public var endIndex: Index { _endIndex }
}

extension _RedBlackTreeUniqueView {

  /// - Complexity: O(log `count`)
  @inlinable
  public func lowerBound(_ member: _Key) -> Index {
    ___index_lower_bound(member)
  }

  /// - Complexity: O(log `count`)
  @inlinable
  public func upperBound(_ member: _Key) -> Index {
    ___index_upper_bound(member)
  }
}

extension _RedBlackTreeUniqueView {

  /// - Complexity: O(log `count`)
  @inlinable
  public func firstIndex(of member: _Key) -> Index? {
    ___first_index(of: member)
  }
}
