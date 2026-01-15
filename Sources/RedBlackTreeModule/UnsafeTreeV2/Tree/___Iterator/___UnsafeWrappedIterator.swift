//
//  ___UnsafeWrappedIterator.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/15.
//

struct ___UnsafeWrappedIterator:
  UnsafeTreePointer,
  IteratorProtocol,
  Sequence
{
  mutating func next() -> _NodePtr? {
    guard let __current else { return nil }
    self.__current = naive.next()
    return __current
  }
  var __current: _NodePtr?
  var naive: ___UnsafeNaiveIterator
}

struct ___UnsafeWrappedRevIterator:
  UnsafeTreePointer,
  IteratorProtocol,
  Sequence
{
  mutating func next() -> _NodePtr? {
    guard let __current else { return nil }
    self.__current = naive.next()
    return __current
  }
  var __current: _NodePtr?
  var naive: ___UnsafeNaiveRevIterator
}
