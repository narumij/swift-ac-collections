//
//  ___UnsafeNaiveIterator.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/15.
//

struct ___UnsafeNaiveIterator:
  UnsafeTreeNodeProtocol,
  IteratorProtocol,
  Sequence
{
  mutating func next() -> _NodePtr? {
    guard __first != __last else { return nil }
    let __r = __first
    __first = __tree_next_iter(__first)
    return __r
  }
  let nullptr: _NodePtr
  var __first: _NodePtr
  let __last: _NodePtr
}

struct ___UnsafeNaiveRevIterator:
  UnsafeTreeNodeProtocol,
  IteratorProtocol,
  Sequence
{
  mutating func next() -> _NodePtr? {
    guard __last != __first else { return nil }
    __last = __tree_prev_iter(__last)
    return __last
  }
  let nullptr: _NodePtr
  let __first: _NodePtr
  var __last: _NodePtr
}
