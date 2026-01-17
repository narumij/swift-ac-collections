//
//  ___UnsafeValueWrapper.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/17.
//

extension UnsafeIterator {
  
  @usableFromInline
  struct Value<Base: ___TreeBase, Source: IteratorProtocol>:
    UnsafeTreePointer,
    UnsafeAssosiatedIterator,
    IteratorProtocol,
    Sequence
  where
  Source.Element == UnsafeMutablePointer<UnsafeNode>,
  Source: UnsafeIteratorProtocol
  {
    @usableFromInline
    init(tree: UnsafeTreeV2<Base>, start __first: _NodePtr, end __last: _NodePtr) {
      self.init(iterator: .init(tree: tree, start: __first, end: __last))
    }
    
    @usableFromInline
    init(__tree_: UnsafeImmutableTree<Base>, start __first: _NodePtr, end __last: _NodePtr) {
      self.init(iterator: .init(__tree_: __tree_, start: __first, end: __last))
    }
    
    var iterator: Source
    
    internal init(iterator: Source) {
      self.iterator = iterator
    }
    
    @usableFromInline
    mutating func next() -> Base._Value? {
      return iterator.next().map {
        $0.__value_().pointee
      }
    }
  }
  
  @usableFromInline
  struct Key<Base: ___TreeBase, Source: IteratorProtocol>:
    UnsafeTreePointer,
    UnsafeAssosiatedIterator,
    IteratorProtocol,
    Sequence
  where
  Source.Element == UnsafeMutablePointer<UnsafeNode>,
  Source: UnsafeIteratorProtocol
  {
    @usableFromInline
    init(tree: UnsafeTreeV2<Base>, start __first: _NodePtr, end __last: _NodePtr) {
      self.init(iterator: .init(tree: tree, start: __first, end: __last))
    }
    
    @usableFromInline
    init(__tree_: UnsafeImmutableTree<Base>, start __first: _NodePtr, end __last: _NodePtr) {
      self.init(iterator: .init(__tree_: __tree_, start: __first, end: __last))
    }
    
    var iterator: Source
    
    internal init(iterator: Source) {
      self.iterator = iterator
    }
    
    @usableFromInline
    mutating func next() -> Base._Key? {
      return iterator.next().map {
        Base.__key($0.__value_().pointee)
      }
    }
  }
  
  @usableFromInline
  struct MappedValue<Base: ___TreeBase & KeyValueComparer, Source: IteratorProtocol>:
    UnsafeTreePointer,
    UnsafeAssosiatedIterator,
    IteratorProtocol,
    Sequence
  where
  Source.Element == UnsafeMutablePointer<UnsafeNode>,
  Source: UnsafeIteratorProtocol
  {
    @usableFromInline
    init(tree: UnsafeTreeV2<Base>, start __first: _NodePtr, end __last: _NodePtr) {
      self.init(iterator: .init(tree: tree, start: __first, end: __last))
    }
    
    @usableFromInline
    init(__tree_: UnsafeImmutableTree<Base>, start __first: _NodePtr, end __last: _NodePtr) {
      self.init(iterator: .init(__tree_: __tree_, start: __first, end: __last))
    }
    
    var iterator: Source
    
    internal init(iterator: Source) {
      self.iterator = iterator
    }
    
    @usableFromInline
    mutating func next() -> Base._MappedValue? {
      return iterator.next().map {
        Base.___mapped_value($0.__value_().pointee)
      }
    }
  }
}

#if swift(>=5.5)
extension UnsafeIterator.Value: @unchecked Sendable
  where Source: Sendable {}
#endif

#if swift(>=5.5)
extension UnsafeIterator.Key: @unchecked Sendable
  where Source: Sendable {}
#endif

#if swift(>=5.5)
extension UnsafeIterator.MappedValue: @unchecked Sendable
  where Source: Sendable {}
#endif
