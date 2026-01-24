//
//  ___UnsafeRemoveCheckWrapper.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/16.
//

extension UnsafeIterator {

  public struct _RemoveCheck<Source: IteratorProtocol>:
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

    @usableFromInline var source: Source
    @usableFromInline
    internal init(source: Source) {
      self.source = source
    }

    public mutating func next() -> _NodePtr? {
      guard let result = source.next() else { return nil }
      guard !result.___is_garbaged else {
        fatalError(.garbagedIndex)
      }
      return result
    }
  }
}

extension UnsafeIterator._RemoveCheck: ObverseIterator
where
  Source: ObverseIterator,
  Source.ReversedIterator: UnsafeIteratorProtocol
{
  public func reversed() -> UnsafeIterator._RemoveAware<Source.ReversedIterator> {
    .init(source: source.reversed())
  }
  public typealias Reversed = UnsafeIterator._RemoveAware<Source.ReversedIterator>
}

extension UnsafeIterator._RemoveCheck: Equatable where Source: Equatable {}

extension UnsafeIterator._RemoveCheck: ReverseIterator
where Source: ReverseIterator {}

#if swift(>=5.5)
  extension UnsafeIterator._RemoveCheck: @unchecked Sendable
  where Source: Sendable {}
#endif
