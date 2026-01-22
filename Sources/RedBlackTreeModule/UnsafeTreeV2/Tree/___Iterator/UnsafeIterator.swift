//
//  UnsafeIterator.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/17.
//

public enum UnsafeIterator {}

extension UnsafeIterator {

  public
    typealias IndexObverse<Base: ___TreeBase & ___TreeIndex> =
    TiedIndexing<Base, RemoveAware<Obverse>>

  public
    typealias IndexReverse<Base: ___TreeBase & ___TreeIndex> =
    TiedIndexing<Base, RemoveAware<Reverse>>

  public
    typealias ValueObverse<Base: ___TreeBase & ___TreeIndex> = Tied<
      Value<Base, RemoveAware<Obverse>>
    >
  public
    typealias ValueReverse<Base: ___TreeBase & ___TreeIndex> = Tied<
      Value<Base, RemoveAware<Reverse>>
    >

  public
    typealias KeyObverse<Base: ___TreeBase & ___TreeIndex> = Tied<
      Key<Base, RemoveAware<Obverse>>
    >
  public
    typealias KeyReverse<Base: ___TreeBase & ___TreeIndex> = Tied<
      Key<Base, RemoveAware<Reverse>>
    >

  public
    typealias MappedValueObverse<Base: ___TreeBase & ___TreeIndex & KeyValueComparer> = Tied<
      MappedValue<Base, RemoveAware<Obverse>>
    >
  public
    typealias MappedValueReverse<Base: ___TreeBase & ___TreeIndex & KeyValueComparer> = Tied<
      MappedValue<Base, RemoveAware<Reverse>>
    >

  public
    typealias KeyValueObverse<Base: ___TreeBase & ___TreeIndex & KeyValueComparer> = Tied<
      KeyValue<Base, RemoveAware<Obverse>>
    >
  public
    typealias KeyValueReverse<Base: ___TreeBase & ___TreeIndex & KeyValueComparer> = Tied<
      KeyValue<Base, RemoveAware<Reverse>>
    >
}

extension UnsafeIterator {
  public typealias RemoveAwarePointers = RemoveAware<Obverse>
  public typealias NaivePointers = Obverse
  public typealias RemoveAwareReversePointers = RemoveAware<Reverse>
}
