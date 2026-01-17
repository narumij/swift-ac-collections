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
    self.__current = __first
    self.__last = __last
  }

  @usableFromInline
  package mutating func next() -> _NodePtr? {
    guard __current != __last else { return nil }
    let __r = __current
    __current = __tree_next_iter(__current)
    return __r
  }

  @usableFromInline
  let __first: _NodePtr
  @usableFromInline
  var __current: _NodePtr
  @usableFromInline
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
    self.__current = __last
    self.__last = __last
  }

  @usableFromInline
  package mutating func next() -> _NodePtr? {
    guard __current != __first else { return nil }
    __current = __tree_prev_iter(__current)
    return __current
  }

  @usableFromInline
  let __first: _NodePtr
  @usableFromInline
  var __current: _NodePtr
  @usableFromInline
  let __last: _NodePtr
}
