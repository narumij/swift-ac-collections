//
//  ElementSequence.swift
//  swift-ac-collections
//
//  Created by narumij on 2025/05/28.
//

#if false
public
struct ElementIterator<Base: RedBlackTreeRawIndexIteratable>: IteratorProtocol {
  
  public typealias Tree = Base.Tree
  public typealias Element = Base.Tree.Element

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
  public mutating func next() -> Element? {
    guard _current != _end else { return nil }
    defer {
      _current = _next
      _next = _next == _end ? _end : _tree.__tree_next(_next)
    }
    return _tree[_current]
  }
}
#endif

public
struct ElementIterator<Tree: IteratableProtocol>: IteratorProtocol {
  
  public typealias Tree = Tree
  public typealias Element = Tree.Element

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
    self._next = start == .end ? .end : tree.__tree_next(start)
  }
  
  @inlinable
  @inline(__always)
  public mutating func next() -> Element? {
    guard _current != _end else { return nil }
    defer {
      _current = _next
      _next = _next == _end ? _end : _tree.__tree_next(_next)
    }
    return _tree[_current]
  }
}
