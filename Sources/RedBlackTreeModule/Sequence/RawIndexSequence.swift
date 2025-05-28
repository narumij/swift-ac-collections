//
//  RawIndexSequence.swift
//  swift-ac-collections
//
//  Created by narumij on 2025/05/28.
//

public
struct RawIndexIterator<Base: RedBlackTreeRawIndexIteratable>: IteratorProtocol {

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
  public mutating func next() -> RawIndex? {
    guard _current != _end else { return nil }
    defer {
      _current = _next
      _next = _next == _end ? _end : _tree.__tree_next(_next)
    }
    return RawIndex(_current)
  }
}

public
struct RawIndexSequence<Base: RedBlackTreeRawIndexIteratable>: Sequence {
  
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
  public func makeIterator() -> RawIndexIterator<Base> {
    .init(tree: _tree, start: _start, end: _end)
  }
  
  @inlinable
  @inline(__always)
  internal func forEach(_ body: (Element) throws -> Void) rethrows {
    var __p = _start
    while __p != _end {
      let __c = __p
      __p = _tree.__tree_next(__p)
      try body(RawIndex(__c))
    }
  }
}

