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
