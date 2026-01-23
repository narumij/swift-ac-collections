//
//  ___UnsafeWrappedIterator.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/15.
//

extension UnsafeIterator {

  public struct _RemoveAware<Source: IteratorProtocol>:
    _UnsafeNodePtrType,
    UnsafeIteratorProtocol,
    IteratorProtocol,
    Sequence
  where
    Source.Element == UnsafeMutablePointer<UnsafeNode>,
    Source: UnsafeIteratorProtocol
  {
    public init(_start: _NodePtr, _end: _NodePtr) {
      self.init(source: .init(_start: _start, _end: _end))
    }

    public var _start: UnsafeMutablePointer<UnsafeNode> {
      source._start
    }

    public var _end: UnsafeMutablePointer<UnsafeNode> {
      source._end
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

extension UnsafeIterator._RemoveAware: ObverseIterator
where
  Source: ObverseIterator,
  Source.ReversedIterator: UnsafeIteratorProtocol
{
  public func reversed() -> UnsafeIterator._RemoveAware<Source.ReversedIterator> {
    .init(source: source.reversed())
  }
  public typealias Reversed = UnsafeIterator._RemoveAware<Source.ReversedIterator>
}

extension UnsafeIterator._RemoveAware: Equatable where Source: Equatable {}

extension UnsafeIterator._RemoveAware: ReverseIterator
where Source: ReverseIterator {}

#if swift(>=5.5)
  extension UnsafeIterator._RemoveAware: @unchecked Sendable
  where Source: Sendable {}
#endif
