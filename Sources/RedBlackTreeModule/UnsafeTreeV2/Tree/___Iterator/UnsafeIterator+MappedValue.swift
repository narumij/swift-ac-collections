//
//  UnsafeIterator+MappedValue.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/17.
//

extension UnsafeIterator {

  public struct _MappedValue<Base, Source>:
    _UnsafeNodePtrType,
    UnsafeAssosiatedIterator,
    IteratorProtocol,
    Sequence
  where
    Base: ___TreeBase & KeyValueComparer,
    Source: IteratorProtocol & Sequence & UnsafeIteratorProtocol,
    Source.Element == UnsafeMutablePointer<UnsafeNode>
  {
    
    public init(_ t: Base.Type, _start: _NodePtr, _end: _NodePtr) {
      self.init(source: .init(_start: _start, _end: _end))
    }

    public
      var _source: Source

    internal init(source: Source) {
      self._source = source
    }

    public var _start: UnsafeMutablePointer<UnsafeNode> {
      _source._start
    }

    public var _end: UnsafeMutablePointer<UnsafeNode> {
      _source._end
    }
    
    public
      mutating func next() -> Base._MappedValue?
    {
      return _source.next().map {
        Base.___mapped_value($0.__value_().pointee)
      }
    }
  }
}

#if swift(>=5.5)
  extension UnsafeIterator._MappedValue: @unchecked Sendable
  where Source: Sendable {}
#endif

extension UnsafeIterator._MappedValue: ObverseIterator
where
  Source: ObverseIterator,
  Source.ReversedIterator: UnsafeIteratorProtocol & Sequence
{
  public func reversed() -> UnsafeIterator._MappedValue<Base,Source.ReversedIterator> {
    .init(source: _source.reversed())
  }
  public typealias Reversed = UnsafeIterator._MappedValue<Base,Source.ReversedIterator>
}

extension UnsafeIterator._MappedValue: ReverseIterator
where Source: ReverseIterator {}
