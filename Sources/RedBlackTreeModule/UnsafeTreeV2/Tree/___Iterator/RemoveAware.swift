//
//  ___UnsafeWrappedIterator.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/15.
//

extension UnsafeIterator {
  
  @usableFromInline
  package struct RemoveAware<Source: IteratorProtocol>:
    UnsafeTreePointer,
    UnsafeIteratorProtocol,
    IteratorProtocol,
    Sequence
  where
  Source.Element == UnsafeMutablePointer<UnsafeNode>,
  Source: UnsafeIteratorProtocol
  {
    @usableFromInline
    package init<Base>(tree: UnsafeTreeV2<Base>, start: _NodePtr, end: _NodePtr)
    where Base: ___TreeBase {
      self.init(iterator: .init(tree: tree, start: start, end: end))
    }
    
    @usableFromInline
    package init<Base>(__tree_: UnsafeImmutableTree<Base>, start: _NodePtr, end: _NodePtr)
    where Base: ___TreeBase {
      self.init(iterator: .init(__tree_: __tree_, start: start, end: end))
    }
    
    var __current: Source.Element?
    
    @usableFromInline var naive: Source
    @usableFromInline
    internal init(iterator: Source) {
      var it = iterator
      self.__current = it.next()
      self.naive = it
    }
    @usableFromInline
    package mutating func next() -> _NodePtr? {
      guard let __current else { return nil }
      self.__current = naive.next()
      return __current
    }
  }
}

extension UnsafeIterator.RemoveAware: Equatable where Source: Equatable {}

#if swift(>=5.5)
extension UnsafeIterator.RemoveAware: @unchecked Sendable
  where Source: Sendable {}
#endif
