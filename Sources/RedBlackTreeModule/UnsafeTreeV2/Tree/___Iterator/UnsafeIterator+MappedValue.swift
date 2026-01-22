//
//  UnsafeIterator+MappedValue.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/17.
//

extension UnsafeIterator {

  public struct MappedValue<Base, Source>:
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
      self.init(source: .init(start: __first, end: __last))
    }

    public init(_ t: Base.Type, start: _NodePtr, end: _NodePtr) {
      self.init(source: .init(start: start, end: end))
    }

    public
      var source: Source

    internal init(source: Source) {
      self.source = source
    }

    public var _start: UnsafeMutablePointer<UnsafeNode> {
      source._start
    }

    public var _end: UnsafeMutablePointer<UnsafeNode> {
      source._end
    }
    
    public
      mutating func next() -> Base._MappedValue?
    {
      return source.next().map {
        Base.___mapped_value($0.__value_().pointee)
      }
    }
  }
}

#if swift(>=5.5)
  extension UnsafeIterator.MappedValue: @unchecked Sendable
  where Source: Sendable {}
#endif

extension UnsafeIterator.MappedValue: ObverseIterator
where
  Source: ObverseIterator,
  Source.ReversedIterator: UnsafeIteratorProtocol & Sequence
{
  public func reversed() -> UnsafeIterator.MappedValue<Base,Source.ReversedIterator> {
    .init(source: source.reversed())
  }
  public typealias Reversed = UnsafeIterator.MappedValue<Base,Source.ReversedIterator>
}

extension UnsafeIterator.MappedValue: ReverseIterator
where Source: ReverseIterator {}
