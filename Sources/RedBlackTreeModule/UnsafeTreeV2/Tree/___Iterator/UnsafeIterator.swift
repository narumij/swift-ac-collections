//
//  UnsafeIterator.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/17.
//

public enum UnsafeIterator {}

extension UnsafeIterator {
  public
    typealias ValueObverse<Base: ___TreeBase & ___TreeIndex> = Movable<
      Value<Base, RemoveAware<Obverse>>
    >
  public
    typealias ValueReverse<Base: ___TreeBase & ___TreeIndex> = Movable<
      Value<Base, RemoveAware<Reverse>>
    >

  public
    typealias KeyObverse<Base: ___TreeBase & ___TreeIndex> = Movable<
      Key<Base, RemoveAware<Obverse>>
    >
  public
    typealias KeyReverse<Base: ___TreeBase & ___TreeIndex> = Movable<
      Key<Base, RemoveAware<Reverse>>
    >

  public
    typealias MappedValueObverse<Base: ___TreeBase & ___TreeIndex & KeyValueComparer> = Movable<
      MappedValue<Base, RemoveAware<Obverse>>
    >
  public
    typealias MappedValueReverse<Base: ___TreeBase & ___TreeIndex & KeyValueComparer> = Movable<
      MappedValue<Base, RemoveAware<Reverse>>
    >
}

extension UnsafeIterator {
  public typealias RemoveAwarePointers = RemoveAware<Obverse>
  public typealias NaivePointers = Obverse
  public typealias RemoveAwareReversePointers = RemoveAware<Reverse>
}

public protocol UnsafeIteratorProtocol: UnsafeTreePointer {
  init<Base: ___TreeBase>(tree: UnsafeTreeV2<Base>, start: _NodePtr, end: _NodePtr)
  init<Base: ___TreeBase>(__tree_: UnsafeImmutableTree<Base>, start: _NodePtr, end: _NodePtr)
}

public protocol UnsafeAssosiatedIterator: UnsafeTreePointer {
  associatedtype Base: ___TreeBase
  associatedtype Source: IteratorProtocol & Sequence
  init(tree: UnsafeTreeV2<Base>, start: _NodePtr, end: _NodePtr)
  init(__tree_: UnsafeImmutableTree<Base>, start: _NodePtr, end: _NodePtr)
  var source: Source { get }
}

extension UnsafeIterator.Movable {

  @inlinable
  @inline(__always)
  public func forEach(_ body: (UnsafeIndexV2<Base>, Element) throws -> Void) rethrows
  where Source.Source.Element == UnsafeMutablePointer<UnsafeNode> {
    try zip(source.source, makeIterator()).forEach {
      try body(___index($0), $1)
    }
  }
}

extension UnsafeIterator.Movable
where
  Source.Source.Element == UnsafeMutablePointer<UnsafeNode>
{

  /// - Complexity: O(1)
  public var indices: UnsafeIterator.Indexing<Source.Base, Source.Source> {
    .init(__tree_: __tree_, source: source.source, pool: poolLifespan)
  }

  @available(*, deprecated, message: "危険になった為")
  @inlinable
  @inline(__always)
  package func ___node_positions() -> Source.Source {
    // 多分lifetime延長しないとクラッシュする
    // と思ったけどしなかった。念のためlifetimeとdeprecated
    defer { _fixLifetime(self) }
    return source.source
  }
}
