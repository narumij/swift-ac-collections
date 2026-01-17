//
//  ___UnsafeValueWrapper.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/17.
//

@usableFromInline
struct ___UnsafeValueWrapper<Base: ___TreeBase, Source: IteratorProtocol>:
  UnsafeTreePointer,
  IteratorProtocol,
  Sequence
where
  Source.Element == UnsafeMutablePointer<UnsafeNode>,
  Source: UnsafeIterator
{
  @usableFromInline
  init(tree: UnsafeTreeV2<Base>, __first: _NodePtr, __last: _NodePtr) {
    self.init(iterator: .init(tree: tree, start: __first, end: __last))
  }

  @usableFromInline
  init(__tree_: UnsafeImmutableTree<Base>, __first: _NodePtr, __last: _NodePtr) {
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
struct ___UnsafeKeyWrapper<Base: ___TreeBase, Source: IteratorProtocol>:
  UnsafeTreePointer,
  IteratorProtocol,
  Sequence
where
  Source.Element == UnsafeMutablePointer<UnsafeNode>,
  Source: UnsafeIterator
{
  @usableFromInline
  init(tree: UnsafeTreeV2<Base>, __first: _NodePtr, __last: _NodePtr) {
    self.init(iterator: .init(tree: tree, start: __first, end: __last))
  }

  @usableFromInline
  init(__tree_: UnsafeImmutableTree<Base>, __first: _NodePtr, __last: _NodePtr) {
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
struct ___UnsafeMappedValueWrapper<Base: ___TreeBase & KeyValueComparer, Source: IteratorProtocol>:
  UnsafeTreePointer,
  IteratorProtocol,
  Sequence
where
  Source.Element == UnsafeMutablePointer<UnsafeNode>,
  Source: UnsafeIterator
{
  @usableFromInline
  init(tree: UnsafeTreeV2<Base>, __first: _NodePtr, __last: _NodePtr) {
    self.init(iterator: .init(tree: tree, start: __first, end: __last))
  }

  @usableFromInline
  init(__tree_: UnsafeImmutableTree<Base>, __first: _NodePtr, __last: _NodePtr) {
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
