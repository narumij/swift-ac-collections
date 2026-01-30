//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-ac-collections project
//
// Copyright (c) 2024 - 2026 narumij.
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// This code is based on work originally distributed under the Apache License 2.0 with LLVM Exceptions:
//
// Copyright © 2003-2026 The LLVM Project.
// Licensed under the Apache License, Version 2.0 with LLVM Exceptions.
// The original license can be found at https://llvm.org/LICENSE.txt
//
// This Swift implementation includes modifications and adaptations made by narumij.
//
//===----------------------------------------------------------------------===//

public enum UnsafeIterator {}

extension UnsafeIterator {

  #if COMPATIBLE_ATCODER_2025 || true
    public typealias _RemoveTrait = _RemoveAware
  #else
  // 強化型CoWの廃止とRemoveAware廃止を同時にやるとfor文での削除ができなくなり、さすがにやりすぎかなと思っている
    public typealias _RemoveTrait = _RemoveCheck
  #endif

  public
    typealias IndexObverse<Base: ___TreeBase & ___TreeIndex> =
    TiedIndexing<Base, _RemoveTrait<_Obverse>>

  public
    typealias IndexReverse<Base: ___TreeBase & ___TreeIndex> =
    TiedIndexing<Base, _RemoveTrait<_Reverse>>

  public
    typealias ValueObverse<Base: ___TreeBase> = Tied<
      _Payload<Base, _RemoveTrait<_Obverse>>
    >
  public
    typealias ValueReverse<Base: ___TreeBase> = Tied<
      _Payload<Base, _RemoveTrait<_Reverse>>
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
