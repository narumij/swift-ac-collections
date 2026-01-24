//
//  UnsafeIterator+KeyValue.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/23.
//

extension UnsafeIterator {

  public struct _KeyValue<Base, Source>:
    _UnsafeNodePtrType,
    UnsafeAssosiatedIterator,
    IteratorProtocol,
    Sequence
  where
    Base: ___TreeBase & KeyValueComparer,
    Source: IteratorProtocol & Sequence & UnsafeIteratorProtocol,
    Source.Element == UnsafeMutablePointer<UnsafeNode>
  {

    public
      init(tree: UnsafeTreeV2<Base>, start __first: _NodePtr, end __last: _NodePtr)
    {
      self.init(source: .init(_start: __first, _end: __last))
    }

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
      mutating func next() -> (key: Base._Key, value: Base._MappedValue)?
    {
      return _source.next().map {
        (
          Base.__key($0.__value_().pointee),
          Base.___mapped_value($0.__value_().pointee)
        )
      }
    }
  }
}

#if swift(>=5.5)
  extension UnsafeIterator._KeyValue: @unchecked Sendable
  where Source: Sendable {}
#endif

extension UnsafeIterator._KeyValue: ObverseIterator
where
  Source: ObverseIterator,
  Source.ReversedIterator: UnsafeIteratorProtocol & Sequence
{
  public func reversed() -> UnsafeIterator._KeyValue<Base,Source.ReversedIterator> {
    .init(source: _source.reversed())
  }
  public typealias Reversed = UnsafeIterator._KeyValue<Base,Source.ReversedIterator>
}

extension UnsafeIterator._KeyValue: ReverseIterator
where Source: ReverseIterator {}
