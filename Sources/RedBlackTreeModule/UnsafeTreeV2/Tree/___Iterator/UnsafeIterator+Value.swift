//
//  ___UnsafeValueWrapper.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/17.
//

extension UnsafeIterator {

  public struct _Value<Base: ___TreeBase, Source: IteratorProtocol & Sequence>:
    _UnsafeNodePtrType,
    UnsafeAssosiatedIterator,
    IteratorProtocol,
    Sequence
  where
    Source.Element == UnsafeMutablePointer<UnsafeNode>,
    Source: UnsafeIteratorProtocol
  {
    public init(_ t: Base.Type, _start: _NodePtr, _end: _NodePtr) {
      self.init(source: .init(_start: _start, _end: _end))
    }

    public var _source: Source

    internal init(source: Source) {
      self._source = source
    }
    
    public var _start: UnsafeMutablePointer<UnsafeNode> {
      _source._start
    }

    public var _end: UnsafeMutablePointer<UnsafeNode> {
      _source._end
    }

    public mutating func next() -> Base._Value? {
      return _source.next().map {
        $0.__value_().pointee
      }
    }
  }
}

#if swift(>=5.5)
  extension UnsafeIterator._Value: @unchecked Sendable
  where Source: Sendable {}
#endif

extension UnsafeIterator._Value: ObverseIterator
where
  Source: ObverseIterator,
  Source.ReversedIterator: UnsafeIteratorProtocol & Sequence
{
  public func reversed() -> UnsafeIterator._Value<Base,Source.ReversedIterator> {
    .init(source: _source.reversed())
  }
  public typealias Reversed = UnsafeIterator._Value<Base,Source.ReversedIterator>
}

extension UnsafeIterator._Value: ReverseIterator
where Source: ReverseIterator {}
