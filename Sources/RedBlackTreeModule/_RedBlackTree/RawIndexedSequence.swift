//
//  RawIndexedSequence.swift
//  swift-ac-collections
//
//  Created by narumij on 2025/05/28.
//

public
struct RawIndexedIterator<Base: RedBlackTreeIteratable>: IteratorProtocol {

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
  public mutating func next() -> (RawIndex, Base.Tree.Element)? {
    guard _current != _end else { return nil }
    defer {
      _current = _next
      _next = _next == _end ? _end : _tree.__tree_next(_next)
    }
    return (RawIndex(_current), _tree[_current])
  }
}

public
struct RawIndexedSequence<Base: RedBlackTreeIteratable>: Sequence {
  
  @usableFromInline
  let _tree: Base.Tree

  @usableFromInline
  var _start, _end: _NodePtr

  @inlinable
  @inline(__always)
  internal init(tree: Base.Tree) where Base.Tree: BeginNodeProtocol & EndNodeProtocol {
    self.init(
      tree: tree,
      start: tree.__begin_node,
      end: tree.__end_node())
  }

  @inlinable
  @inline(__always)
  internal init(tree: Base.Tree, start: _NodePtr, end: _NodePtr) {
    _tree = tree
    _start = start
    _end = end
  }

  @inlinable
  public func makeIterator() -> RawIndexedIterator<Base> {
    .init(tree: _tree, start: _start, end: _end)
  }
  
  @inlinable
  @inline(__always)
  internal func forEach(_ body: (RawIndex, Base.Tree.Element) throws -> Void) rethrows {
    var __p = _start
    while __p != _end {
      let __c = __p
      __p = _tree.__tree_next(__p)
      try body(RawIndex(__c), _tree[__c])
    }
  }
}
