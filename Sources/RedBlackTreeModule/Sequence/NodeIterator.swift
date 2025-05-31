//
//  NodePtrIterator.swift
//  swift-ac-collections
//
//  Created by narumij on 2025/05/30.
//

public
struct NodeIterator<Tree: ___IterateNextProtocol>: Sequence, IteratorProtocol {

  @usableFromInline
  let _tree: Tree

  @usableFromInline
  var _current, _next, _end: _NodePtr
  
  @inlinable
  @inline(__always)
  internal init(tree: Tree, start: _NodePtr, end: _NodePtr) {
    self._tree = tree
    self._current = start
    self._end = end
    self._next = start == .end ? .end : tree.__tree_next_iter(start)
  }
  
  @inlinable
  @inline(__always)
  public mutating func next() -> _NodePtr? {
    guard _current != _end else { return nil }
    defer {
      _current = _next
      _next = _next == _end ? _end : _tree.__tree_next_iter(_next)
    }
    return _current
  }
}

public
struct ReversedNodeIterator<Tree: ___IterateNextProtocol>: Sequence, IteratorProtocol {

  @usableFromInline
  let _tree: Tree

  @usableFromInline
  var _current, _next, _start, _begin: _NodePtr
  
  @inlinable
  @inline(__always)
  internal init(tree: Tree, start: _NodePtr, end: _NodePtr) {
    self._tree = tree
    self._current = end
    self._next = _tree.__tree_prev_iter(end)
    self._start = start
    self._begin = _tree.__begin_node
  }
  
  @inlinable
  @inline(__always)
  public mutating func next() -> _NodePtr? {
    guard _current != _start else { return nil }
    _current = _next
    _next = _current != _begin ? _tree.__tree_prev_iter(_current) : .nullptr
    return _current
  }
}
