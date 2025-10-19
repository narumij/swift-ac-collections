//
//  RedBlackTreeIterator.swift
//  swift-ac-collections
//
//  Created by narumij on 2025/10/19.
//

import Foundation

@frozen
public struct RedBlackTreeIterator<VC>: Sequence, IteratorProtocol
where
  VC: ValueComparer & CompareTrait & ThreeWayComparator
{
  public typealias Tree = ___Tree<VC>
  public typealias _Value = Tree._Value
  
  @usableFromInline
  let __tree_: Tree
  
  @usableFromInline
  var _start, _end, _current, _next: _NodePtr

  @inlinable
  @inline(__always)
  internal init(tree: Tree, start: _NodePtr, end: _NodePtr) {
    self.__tree_ = tree
    self._current = start
    self._start = start
    self._end = end
    self._next = start == .end ? .end : tree.__tree_next_iter(start)
  }

  @inlinable
  @inline(__always)
  public mutating func next() -> Tree._Value? {
    guard _current != _end else { return nil }
    defer {
      _current = _next
      _next = _next == _end ? _end : __tree_.__tree_next_iter(_next)
    }
    return __tree_[_current]
  }
}

extension RedBlackTreeIterator: Equatable where Tree._Value: Equatable {

  @inlinable
  @inline(__always)
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.elementsEqual(rhs)
  }
}

extension RedBlackTreeIterator: Comparable where Tree._Value: Comparable {

  @inlinable
  @inline(__always)
  public static func < (lhs: Self, rhs: Self) -> Bool {
    lhs.lexicographicallyPrecedes(rhs)
  }
}

extension ___Tree {
  public typealias ElementIterator = RedBlackTreeIterator<VC>
}
