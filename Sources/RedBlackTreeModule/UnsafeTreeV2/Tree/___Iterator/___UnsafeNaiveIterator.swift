//
//  ___UnsafeNaiveIterator.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/15.
//

@usableFromInline
struct ___UnsafeNaiveIterator:
  UnsafeTreeNodeProtocol,
  IteratorProtocol,
  Sequence
{
  @usableFromInline
  internal init(nullptr: _NodePtr, __first: _NodePtr, __last: _NodePtr) {
    self.nullptr = nullptr
    self.__first = __first
    self.__last = __last
  }
  
  @usableFromInline
  mutating func next() -> _NodePtr? {
    guard __first != __last else { return nil }
    let __r = __first
    __first = __tree_next_iter(__first)
    return __r
  }
  
  @usableFromInline
  let nullptr: _NodePtr
  var __first: _NodePtr
  let __last: _NodePtr
}

struct ___UnsafeNaiveRevIterator:
  UnsafeTreeNodeProtocol,
  IteratorProtocol,
  Sequence
{
  @usableFromInline
  internal init(nullptr: _NodePtr, __first: _NodePtr, __last: _NodePtr) {
    self.nullptr = nullptr
    self.__first = __first
    self.__last = __last
  }

  @usableFromInline
  mutating func next() -> _NodePtr? {
    guard __last != __first else { return nil }
    __last = __tree_prev_iter(__last)
    return __last
  }
  
  @usableFromInline
  let nullptr: _NodePtr
  let __first: _NodePtr
  var __last: _NodePtr
}
