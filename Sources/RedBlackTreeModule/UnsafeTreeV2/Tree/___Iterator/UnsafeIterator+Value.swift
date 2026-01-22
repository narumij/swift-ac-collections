//
//  ___UnsafeValueWrapper.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/17.
//

extension UnsafeIterator {

  public struct Value<Base: ___TreeBase, Source: IteratorProtocol & Sequence>:
    _UnsafeNodePtrType,
    UnsafeAssosiatedIterator,
    IteratorProtocol,
    Sequence
  where
    Source.Element == UnsafeMutablePointer<UnsafeNode>,
    Source: UnsafeIteratorProtocol
  {
    public init(tree: UnsafeTreeV2<Base>, start __first: _NodePtr, end __last: _NodePtr) {
      self.init(source: .init(start: __first, end: __last))
    }

    public init(_ t: Base.Type, start: _NodePtr, end: _NodePtr) {
      self.init(source: .init(start: start, end: end))
    }

    public var source: Source

    internal init(source: Source) {
      self.source = source
    }
    
    public var _start: UnsafeMutablePointer<UnsafeNode> {
      source._start
    }

    public var _end: UnsafeMutablePointer<UnsafeNode> {
      source._end
    }

    public mutating func next() -> Base._Value? {
      return source.next().map {
        $0.__value_().pointee
      }
    }
  }
}

#if swift(>=5.5)
  extension UnsafeIterator.Value: @unchecked Sendable
  where Source: Sendable {}
#endif

extension UnsafeIterator.Value: ObverseIterator
where
  Source: ObverseIterator,
  Source.ReversedIterator: UnsafeIteratorProtocol & Sequence
{
  public func reversed() -> UnsafeIterator.Value<Base,Source.ReversedIterator> {
    .init(source: source.reversed())
  }
  public typealias Reversed = UnsafeIterator.Value<Base,Source.ReversedIterator>
}

extension UnsafeIterator.Value: ReverseIterator
where Source: ReverseIterator {}
