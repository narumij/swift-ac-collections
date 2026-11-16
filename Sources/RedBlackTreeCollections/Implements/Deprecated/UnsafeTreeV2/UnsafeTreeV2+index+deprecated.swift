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
  extension UnsafeTreeV2 where Base: ___TreeIndex {

    public typealias Index = UnsafeIndexV2<Base>
  }

  extension UnsafeTreeV2 where Base: ___TreeIndex {

    public typealias Indices = UnsafeIndexV2Collection<Base>
  }

  extension UnsafeTreeV2 {

    @inlinable
    internal func ___index(after i: _SealedPtr) -> _SealedPtr {
      i.flatMap { ___tree_next_iter($0.pointer) }.sealed
    }

    @inlinable
    internal func ___index(before i: _SealedPtr) -> _SealedPtr {
      i.flatMap { ___tree_prev_iter($0.pointer) }.sealed
    }

    @inlinable
    internal func ___index(_ i: _SealedPtr, offsetBy distance: Int) -> _SealedPtr {
      i.flatMap { ___tree_adv_iter($0.pointer, distance) }.sealed
    }
  }

  extension UnsafeTreeV2 where Base: _UnsafeNodePtrType & _BaseNode_SignedDistanceInterface {

    @inlinable
    internal func
      ___distance(from start: _SealedPtr, to end: _SealedPtr) -> Int?
    {
      return try? liftA2(
        start.map(\.pointer),
        end.map(\.pointer),
        Base.___signed_distance
      )
      .get()
    }
  }
#endif

#if COMPATIBLE_ATCODER_2025
extension UnsafeTreeV2 {

  public typealias _PayloadValues = UnsafeIterator.Values<Base>
}

extension UnsafeTreeV2 where Base: PairValueTrait {

  public typealias _KeyValues = UnsafeIterator.KeyValues<Base>
}
#endif
