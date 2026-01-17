//
//  ___UnsafeNaiveIterator.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/15.
//

@usableFromInline
package struct ___UnsafeNaiveIterator:
  UnsafeTreePointer,
  IteratorProtocol,
  Sequence,
  Equatable
{
  @usableFromInline
  internal init(__first: _NodePtr, __last: _NodePtr) {
    self.__first = __first
    self.__last = __last
  }

  @usableFromInline
  package mutating func next() -> _NodePtr? {
    guard __first != __last else { return nil }
    let __r = __first
    __first = __tree_next_iter(__first)
    return __r
  }

  @usableFromInline
  var __first: _NodePtr
  let __last: _NodePtr
}

@usableFromInline
package struct ___UnsafeNaiveRevIterator:
  UnsafeTreePointer,
  IteratorProtocol,
  Sequence,
  Equatable
{
  @usableFromInline
  internal init(__first: _NodePtr, __last: _NodePtr) {
    self.__first = __first
    self.__last = __last
  }

  @usableFromInline
  package mutating func next() -> _NodePtr? {
    guard __last != __first else { return nil }
    __last = __tree_prev_iter(__last)
    return __last
  }

  @usableFromInline
  let __first: _NodePtr
  @usableFromInline
  var __last: _NodePtr
}
