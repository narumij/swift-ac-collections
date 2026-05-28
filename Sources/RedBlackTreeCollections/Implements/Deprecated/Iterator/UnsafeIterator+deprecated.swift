//
//  UnsafeIterator+deprecated.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/05/29.
//

#if COMPATIBLE_ATCODER_2025
  extension UnsafeIterator {
    public typealias _RemoveTrait = _RemoveAware
    public typealias _TieTrait = Tied

    public
      typealias IndexObverse<Base: ___TreeBase & ___TreeIndex> =
      TiedIndexing<Base, _RemoveTrait<_Obverse2>>

    public
      typealias IndexReverse<Base: ___TreeBase & ___TreeIndex> =
      TiedIndexing<Base, _RemoveTrait<_Reverse2>>

    public
      typealias ValueObverse<Base: ___TreeBase> = _TieTrait<
        _Payload<Base, _RemoveTrait<_Obverse2>>
      >
    public
      typealias ValueReverse<Base: ___TreeBase> = _TieTrait<
        _Payload<Base, _RemoveTrait<_Reverse2>>
      >

    public
      typealias KeyObverse<Base: ___TreeBase & ___TreeIndex> = _TieTrait<
        _Key<Base, _RemoveTrait<_Obverse2>>
      >
    public
      typealias KeyReverse<Base: ___TreeBase & ___TreeIndex> = _TieTrait<
        _Key<Base, _RemoveTrait<_Reverse2>>
      >

    public
      typealias MappedValueObverse<Base: ___TreeBase & ___TreeIndex & PairValueTrait> = _TieTrait<
        _MappedValue<Base, _RemoveTrait<_Obverse2>>
      >
    public
      typealias MappedValueReverse<Base: ___TreeBase & ___TreeIndex & PairValueTrait> = _TieTrait<
        _MappedValue<Base, _RemoveTrait<_Reverse2>>
      >

    public
      typealias KeyValueObverse<Base: ___TreeBase & PairValueTrait> = _TieTrait<
        _KeyValue<Base, _RemoveTrait<_Obverse2>>
      >
    public
      typealias KeyValueReverse<Base: ___TreeBase & PairValueTrait> = _TieTrait<
        _KeyValue<Base, _RemoveTrait<_Reverse2>>
      >

    public typealias _RemoveAwarePointers = _RemoveAware<_Obverse2>
    public typealias _RemoveAwareReversePointers = _RemoveAware<_Reverse2>
  }
#endif
