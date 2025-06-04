//
//  NodeElementIterator.swift
//  swift-ac-collections
//
//  Created by narumij on 2025/06/01.
//

@frozen
public
struct NodeElementIterator<Tree: Tree_IterateProtocol>: Sequence, IteratorProtocol {

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
  public mutating func next() -> (_NodePtr, Tree.Element)? {
    guard _current != _end else { return nil }
    defer {
      _current = _next
      _next = _next == _end ? _end : __tree_.__tree_next_iter(_next)
    }
    return (_current, __tree_[_current])
  }
  
  @inlinable
  public __consuming func reversed() -> ReversedNodeElementIterator<Tree> {
    .init(tree: __tree_, start: _start, end: _end)
  }
}

@frozen
public
struct ReversedNodeElementIterator<Tree: Tree_IterateProtocol>: Sequence, IteratorProtocol {

  @usableFromInline
  let __tree_: Tree

  @usableFromInline
  var _start, _begin, _current, _next: _NodePtr

  @inlinable
  @inline(__always)
  internal init(tree: Tree, start: _NodePtr, end: _NodePtr) {
    self.__tree_ = tree
    self._current = end
    self._next = __tree_.__tree_prev_iter(end)
    self._start = start
    self._begin = __tree_.__begin_node
  }
  
  @inlinable
  @inline(__always)
  public mutating func next() -> (_NodePtr, Tree.Element)? {
    guard _current != _start else { return nil }
    _current = _next
    _next = _current != _begin ? __tree_.__tree_prev_iter(_current) : .nullptr
    return (_current, __tree_[_current])
  }
}
