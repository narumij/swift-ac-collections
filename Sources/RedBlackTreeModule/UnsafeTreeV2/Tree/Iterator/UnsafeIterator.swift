//
//  UnsafeIterator.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/17.
//

public enum UnsafeIterator {}

extension UnsafeIterator {

  #if COMPATIBLE_ATCODER_2025 || true
    public typealias _RemoveTrait = _RemoveAware
  #else
    public typealias _RemoveTrait = _RemoveCheck
  #endif

  public
    typealias IndexObverse<Base: ___TreeBase & ___TreeIndex> =
    TiedIndexing<Base, _RemoveTrait<_Obverse>>

  public
    typealias IndexReverse<Base: ___TreeBase & ___TreeIndex> =
    TiedIndexing<Base, _RemoveTrait<_Reverse>>

  public
    typealias ValueObverse<Base: ___TreeBase & ___TreeIndex> = Tied<
      _RawValue<Base, _RemoveTrait<_Obverse>>
    >
  public
    typealias ValueReverse<Base: ___TreeBase & ___TreeIndex> = Tied<
      _RawValue<Base, _RemoveTrait<_Reverse>>
    >

  public
    typealias KeyObverse<Base: ___TreeBase & ___TreeIndex> = Tied<
      _Key<Base, _RemoveTrait<_Obverse>>
    >
  public
    typealias KeyReverse<Base: ___TreeBase & ___TreeIndex> = Tied<
      _Key<Base, _RemoveTrait<_Reverse>>
    >

  public
    typealias MappedValueObverse<Base: ___TreeBase & ___TreeIndex & KeyValueComparer> = Tied<
      _MappedValue<Base, _RemoveTrait<_Obverse>>
    >
  public
    typealias MappedValueReverse<Base: ___TreeBase & ___TreeIndex & KeyValueComparer> = Tied<
      _MappedValue<Base, _RemoveTrait<_Reverse>>
    >

  public
    typealias KeyValueObverse<Base: ___TreeBase & ___TreeIndex & KeyValueComparer> = Tied<
      _KeyValue<Base, _RemoveTrait<_Obverse>>
    >
  public
    typealias KeyValueReverse<Base: ___TreeBase & ___TreeIndex & KeyValueComparer> = Tied<
      _KeyValue<Base, _RemoveTrait<_Reverse>>
    >
}

extension UnsafeIterator {
  public typealias _RemoveAwarePointers = _RemoveAware<_Obverse>
  public typealias _NaivePointers = _Obverse
  public typealias _RemoveAwareReversePointers = _RemoveAware<_Reverse>
}
