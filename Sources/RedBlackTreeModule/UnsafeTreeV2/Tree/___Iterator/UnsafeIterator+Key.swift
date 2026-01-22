//
//  UnsafeIterator+Key.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/17.
//

extension UnsafeIterator {

  public struct Key<Base: ___TreeBase, Source: IteratorProtocol & Sequence>:
    _UnsafeNodePtrType,
    UnsafeAssosiatedIterator,
    IteratorProtocol,
    Sequence
  where
    Source.Element == UnsafeMutablePointer<UnsafeNode>,
    Source: UnsafeIteratorProtocol
  {
    public var source: Source

    public init(tree: UnsafeTreeV2<Base>, start __first: _NodePtr, end __last: _NodePtr) {
      self.init(source: .init(start: __first, end: __last))
    }

    public init(_ t: Base.Type, start: _NodePtr, end: _NodePtr) {
      self.init(source: .init(start: start, end: end))
    }

    internal init(source: Source) {
      self.source = source
    }

    public var _start: UnsafeMutablePointer<UnsafeNode> {
      source._start
    }

    public var _end: UnsafeMutablePointer<UnsafeNode> {
      source._end
    }
    
    public mutating func next() -> Base._Key? {
      return source.next().map {
        Base.__key($0.__value_().pointee)
      }
    }
  }
}

#if swift(>=5.5)
  extension UnsafeIterator.Key: @unchecked Sendable
  where Source: Sendable {}
#endif
