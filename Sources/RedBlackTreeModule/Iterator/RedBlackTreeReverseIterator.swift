//
//  RedBlackTreeReverseIterator.swift
//  swift-ac-collections
//
//  Created by narumij on 2025/10/19.
//

@frozen
public struct RedBlackTreeReverseIterator<Base>: Sequence, IteratorProtocol
where
  Base: ValueComparer & CompareTrait & ThreeWayComparator
{
  public typealias Tree = ___Tree<Base>
  public typealias _Value = Tree._Value
  
  @usableFromInline
  let __tree_: Tree
  
  @usableFromInline
  var _start, _end, _begin, _current, _next: _NodePtr

  @inlinable
  @inline(__always)
  internal init(tree: Tree, start: _NodePtr, end: _NodePtr) {
    self.__tree_ = tree
    self._current = end
    self._next = end == start ? end : __tree_.__tree_prev_iter(end)
    self._start = start
    self._end = end
    self._begin = __tree_.__begin_node
  }

  @inlinable
  @inline(__always)
  public mutating func next() -> Tree._Value? {
    guard _current != _start else { return nil }
    _current = _next
    _next = _current != _begin ? __tree_.__tree_prev_iter(_current) : .nullptr
    return __tree_[_current]
  }
}

extension RedBlackTreeReverseIterator {

  @inlinable
  @inline(__always)
  public func forEach(_ body: (Tree.Index, Tree._Value) throws -> Void) rethrows {
    try __tree_.___rev_for_each_(__p: _start, __l: _end) {
      try body(__tree_.makeIndex(rawValue: $0), __tree_[$0])
    }
  }

  @inlinable
  @inline(__always)
  public func ___forEach(_ body: (_NodePtr, Tree._Value) throws -> Void) rethrows {
    try __tree_.___rev_for_each_(__p: _start, __l: _end) {
      try body($0, __tree_[$0])
    }
  }
}

extension RedBlackTreeReverseIterator {

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public var indices: RedBlackTreeIndices<Base>.ReverseIterator {
    .init(tree: __tree_, start: _start, end: _end)
  }
}

extension RedBlackTreeReverseIterator {

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public __consuming func keys<Key, Value>() -> ReversedKeyIterator<Base>
  where Element == _KeyValueTuple_<Key, Value> {
    .init(tree: __tree_, start: _start, end: _end)
  }

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public __consuming func values<Key, Value>() -> ReversedValueIterator<Base>
  where Element == _KeyValueTuple_<Key, Value> {
    .init(tree: __tree_, start: _start, end: _end)
  }
}

extension RedBlackTreeReverseIterator {

  @inlinable
  @inline(__always)
  public __consuming func ___node_positions() -> ReversedNodeIterator<Base> {
    .init(tree: __tree_, start: _start, end: _end)
  }
}

extension RedBlackTreeReverseIterator: Equatable where Element: Equatable {

  @inlinable
  @inline(__always)
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.elementsEqual(rhs)
  }
}

extension RedBlackTreeReverseIterator: Comparable where Element: Comparable {

  @inlinable
  @inline(__always)
  public static func < (lhs: Self, rhs: Self) -> Bool {
    lhs.lexicographicallyPrecedes(rhs)
  }
}

extension ___Tree {
  public typealias ReversedElementIterator = RedBlackTreeReverseIterator<VC>
}
