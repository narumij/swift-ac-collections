//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-ac-collections project.
//
// Copyright (c) 2024-2026 narumij.
// Licensed under the Apache License v2.0.
//
// SPDX-License-Identifier: Apache-2.0
//
// This implementation includes code derived from LLVM libc++'s red-black tree
// implementation, originally distributed under the Apache License v2.0 with
// LLVM Exceptions.
//
// Copyright © 2003-2026 The LLVM Project.
// Licensed under the Apache License v2.0 with LLVM Exceptions.
// The original license can be found at https://llvm.org/LICENSE.txt
//
// This Swift implementation includes modifications and adaptations made by
// narumij.
//
//===----------------------------------------------------------------------===//

#if COMPATIBLE_ATCODER_2025
  extension UnsafeIterator {
    public typealias Values = UnsafeIterator.ValueObverse
    public typealias Keys = UnsafeIterator.KeyObverse
    public typealias KeyValues = UnsafeIterator.KeyValueObverse
    public typealias MappedValues = UnsafeIterator.MappedValueObverse
  }

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
      typealias KeyObverse<Base: ___TreeBase & ___TreeIndex & PairValueTrait> = _TieTrait<
        _Key<Base, _RemoveTrait<_Obverse2>>
      >
    public
      typealias KeyReverse<Base: ___TreeBase & ___TreeIndex & PairValueTrait> = _TieTrait<
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
