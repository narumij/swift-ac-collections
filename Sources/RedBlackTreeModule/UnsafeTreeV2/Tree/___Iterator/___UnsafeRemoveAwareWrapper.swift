//
//  ___UnsafeWrappedIterator.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/15.
//

@usableFromInline
struct ___UnsafeRemoveAwareWrapper<Source: IteratorProtocol>:
  UnsafeTreePointer,
  IteratorProtocol,
  Sequence
where
  Source.Element == UnsafeMutablePointer<UnsafeNode>
{
  var __current: Source.Element?
  var naive: Source
  internal init(iterator: Source) {
    var it = iterator
    self.__current = it.next()
    self.naive = it
  }
  @usableFromInline
  mutating func next() -> _NodePtr? {
    guard let __current else { return nil }
    self.__current = naive.next()
    return __current
  }
}
