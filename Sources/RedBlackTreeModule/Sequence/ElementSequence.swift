//
//  ElementSequence.swift
//  swift-ac-collections
//
//  Created by narumij on 2025/05/28.
//

public
struct ElementSequence<Base: RedBlackTreeRawIndexIteratable>: Sequence {
  
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
  public func makeIterator() -> ElementIterator<Base> {
    .init(tree: _tree, start: _start, end: _end)
  }
  
  @inlinable
  @inline(__always)
  internal func forEach(_ body: (Element) throws -> Void) rethrows {
    var __p = _start
    while __p != _end {
      let __c = __p
      __p = _tree.__tree_next(__p)
      try body(_tree[__c])
    }
  }
}
