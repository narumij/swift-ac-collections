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
      self.init(iterator: .init(tree: tree, start: __first, end: __last))
    }

    public init(__tree_: UnsafeImmutableTree<Base>, start __first: _NodePtr, end __last: _NodePtr) {
      self.init(iterator: .init(__tree_: __tree_, start: __first, end: __last))
    }

    public var source: Source

    internal init(iterator: Source) {
      self.source = iterator
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
