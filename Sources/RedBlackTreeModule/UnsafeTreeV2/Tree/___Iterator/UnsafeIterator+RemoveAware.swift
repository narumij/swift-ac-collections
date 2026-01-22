//
//  ___UnsafeWrappedIterator.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/15.
//

extension UnsafeIterator {

  public struct RemoveAware<Source: IteratorProtocol>:
    _UnsafeNodePtrType,
    UnsafeIteratorProtocol,
    IteratorProtocol,
    Sequence
  where
    Source.Element == UnsafeMutablePointer<UnsafeNode>,
    Source: UnsafeIteratorProtocol
  {
    public init<Base>(tree: UnsafeTreeV2<Base>, start: _NodePtr, end: _NodePtr)
    where Base: ___TreeBase {
      self.init(source: .init(start: start, end: end))
    }

    public init(start: _NodePtr, end: _NodePtr) {
      self.init(source: .init(start: start, end: end))
    }

    var __current: Source.Element?

    @usableFromInline var source: Source
    @usableFromInline
    internal init(source: Source) {
      var it = source
      self.__current = it.next()
      self.source = it
    }

    public mutating func next() -> _NodePtr? {
      guard let __current else { return nil }
      guard !__current.pointee.isGarbaged else {
        fatalError(.invalidIndex)
      }
      self.__current = source.next()
      return __current
    }
  }
}

extension UnsafeIterator.RemoveAware: Equatable where Source: Equatable {}

#if swift(>=5.5)
  extension UnsafeIterator.RemoveAware: @unchecked Sendable
  where Source: Sendable {}
#endif
