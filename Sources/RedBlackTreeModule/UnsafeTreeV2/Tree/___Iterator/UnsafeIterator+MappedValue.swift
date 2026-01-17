//
//  UnsafeIterator+MappedValue.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/17.
//

extension UnsafeIterator {

  public struct MappedValue<Base, Source>:
    UnsafeTreePointer,
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
      self.init(source: .init(tree: tree, start: __first, end: __last))
    }

    public
      init(__tree_: UnsafeImmutableTree<Base>, start __first: _NodePtr, end __last: _NodePtr)
    {
      self.init(source: .init(__tree_: __tree_, start: __first, end: __last))
    }

    public
      var source: Source

    internal init(source: Source) {
      self.source = source
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
