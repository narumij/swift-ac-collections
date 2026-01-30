//
//  _RedBlackTreeUnsafeView.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/31.
//

/// 探索と削除に関して生木を扱う
///
/// 挿入は用意しない
public struct _RedBlackTreeUnsafeView<Base>:
  UnsafeMutableTreeHost,
  _KeyBride,
  _PayloadValueBride,
  UnsafeIndexBinding,
  ___UnsafeBaseSequenceV2,
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

extension _RedBlackTreeUnsafeView {

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public func begin() -> _NodePtr { __tree_.__begin_node_ }

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public func end() -> _NodePtr { __tree_.__end_node }
}

extension _RedBlackTreeUnsafeView {

  /// - Complexity: O(log `count`)
  @inlinable
  public __consuming func lowerBound(_ member: _Key) -> _NodePtr {
    __tree_.lower_bound(member)
  }

  /// - Complexity: O(log `count`)
  @inlinable
  public __consuming func upperBound(_ member: _Key) -> _NodePtr {
    __tree_.lower_bound(member)
  }
}

extension _RedBlackTreeUnsafeView {

  /// - Complexity: O(log `count`)
  @inlinable
  public __consuming func find(_ member: _Key) -> _NodePtr? {
    __tree_.find(member)
  }
}

extension _RedBlackTreeUnsafeView {
  
  public subscript(p: _NodePtr) -> _PayloadValue {
    p.__value_().pointee
  }
}

extension _RedBlackTreeUnsafeView {

  @inlinable
  public mutating func erase(_ ptr: _NodePtr) -> _NodePtr {
    __tree_.erase(ptr)
  }
}

extension RedBlackTreeSet {

  package mutating func _withUnsafeMutableTree<R>(_ body: (inout _RedBlackTreeUnsafeView<Base>) throws -> R)
    rethrows -> R
  {
    __tree_.ensureUnique()
    var tree = _RedBlackTreeUnsafeView(__tree_: __tree_)
    return try body(&tree)
  }
}

extension RedBlackTreeMultiSet {

  package mutating func _withUnsafeMutableTree<R>(_ body: (inout _RedBlackTreeUnsafeView<Base>) throws -> R)
    rethrows -> R
  {
    __tree_.ensureUnique()
    var tree = _RedBlackTreeUnsafeView(__tree_: __tree_)
    return try body(&tree)
  }
}
