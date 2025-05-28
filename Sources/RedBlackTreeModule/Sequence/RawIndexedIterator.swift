//
//  RawIndexedIterator.swift
//  swift-ac-collections
//
//  Created by narumij on 2025/05/28.
//

public
struct RawIndexedIterator<Base: RedBlackTreeRawIndexIteratable>: IteratorProtocol {

  @usableFromInline
  let _tree: Base.Tree

  @usableFromInline
  var _current, _next, _end: _NodePtr
  
  @inlinable
  @inline(__always)
  internal init(tree: Base.Tree, start: _NodePtr, end: _NodePtr) {
    self._tree = tree
    self._current = start
    self._end = end
    self._next = start == .end ? .end : tree.__tree_next(start)
  }
  
  @inlinable
  @inline(__always)
  public mutating func next() -> (rawIndex: RawIndex, element: Base.Tree.Element)? {
    guard _current != _end else { return nil }
    defer {
      _current = _next
      _next = _next == _end ? _end : _tree.__tree_next(_next)
    }
    return (RawIndex(_current), _tree[_current])
  }
}

