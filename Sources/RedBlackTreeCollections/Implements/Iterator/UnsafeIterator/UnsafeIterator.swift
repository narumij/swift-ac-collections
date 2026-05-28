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

    // CoWを避ける方向ですすめていたが、ケアしきれなさそうなのでCoW導入を検討中
    // TODO: 再度検討し確定すること（夏休み目標）
    public typealias _TieTrait = CopyOnWrite
    public typealias Obverse = _Obverse0
    public typealias Reverse = _Reverse0

    public
      typealias ValueObverse<Base: ___TreeBase> = _TieTrait<
        _Payload<Base, Obverse>
      >
    public
      typealias ValueReverse<Base: ___TreeBase> = _TieTrait<
        _Payload<Base, Reverse>
      >

    public
      typealias KeyObverse<Base: ___TreeBase & ___TreeIndex> = _TieTrait<
        _Key<Base, Obverse>
      >
    public
      typealias KeyReverse<Base: ___TreeBase & ___TreeIndex> = _TieTrait<
        _Key<Base, Reverse>
      >

    public
      typealias MappedValueObverse<Base: ___TreeBase & ___TreeIndex & PairValueTrait> = _TieTrait<
        _MappedValue<Base, Obverse>
      >
    public
      typealias MappedValueReverse<Base: ___TreeBase & ___TreeIndex & PairValueTrait> = _TieTrait<
        _MappedValue<Base, Reverse>
      >

    public
      typealias KeyValueObverse<Base: ___TreeBase & PairValueTrait> = _TieTrait<
        _KeyValue<Base, Obverse>
      >
    public
      typealias KeyValueReverse<Base: ___TreeBase & PairValueTrait> = _TieTrait<
        _KeyValue<Base, Reverse>
      >
  }
#endif

extension UnsafeIterator {
  public typealias _NaivePointers = _Obverse1
}
