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

#if !COMPATIBLE_ATCODER_2025
  extension UnsafeIterator {

    public typealias ValueObverse<Base> = _CopyOnWrite<_Payload<Base, _Obverse4>>
    where Base: ___TreeBase
    public typealias ValueReverse<Base> = _CopyOnWrite<_Payload<Base, _Reverse4>>
    where Base: ___TreeBase

    public typealias KeyObverse<Base> = _CopyOnWrite<_Key<Base, _Obverse4>>
    where Base: ___TreeBase & PairValueTrait
    public typealias KeyReverse<Base> = _CopyOnWrite<_Key<Base, _Reverse4>>
    where Base: ___TreeBase & PairValueTrait

    public typealias MappedValueObverse<Base> = _CopyOnWrite<_MappedValue<Base, _Obverse4>>
    where Base: ___TreeBase & PairValueTrait
    public typealias MappedValueReverse<Base> = _CopyOnWrite<_MappedValue<Base, _Reverse4>>
    where Base: ___TreeBase & PairValueTrait

    public typealias KeyValueObverse<Base> = _CopyOnWrite<_KeyValue<Base, _Obverse4>>
    where Base: ___TreeBase & PairValueTrait
    public typealias KeyValueReverse<Base> = _CopyOnWrite<_KeyValue<Base, _Reverse4>>
    where Base: ___TreeBase & PairValueTrait
  }
#endif

extension UnsafeIterator {
  public typealias _NaivePointers = _Obverse1
}
