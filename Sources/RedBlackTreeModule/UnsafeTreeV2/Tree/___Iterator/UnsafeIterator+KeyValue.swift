//
//  UnsafeIterator+KeyValue.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/23.
//

extension UnsafeIterator {

  public struct KeyValue<Base, Source>:
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

    public
      mutating func next() -> (key: Base._Key, value: Base._MappedValue)?
    {
      return source.next().map {
        (
          Base.__get_value($0.__value_().pointee),
          Base.___mapped_value($0.__value_().pointee)
        )
      }
    }
  }
}

#if swift(>=5.5)
  extension UnsafeIterator.KeyValue: @unchecked Sendable
  where Source: Sendable {}
#endif
