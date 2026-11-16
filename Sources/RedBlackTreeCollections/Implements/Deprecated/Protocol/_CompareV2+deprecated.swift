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
  @usableFromInline
  protocol _CompareV2: UnsafeTreeHostV2 & _KeyBride {}

  // MARK: -

  extension _CompareV2 where Base: UniqueMultiplicity {

    //（重複なし）
    @inlinable
    internal func ___equal_range(_ k: _Key) -> (lower: _NodePtr, upper: _NodePtr) {
      __tree_.__equal_range_unique(k)
    }
  }

  extension _CompareV2 where Base: MultiMultiplicity {

    // （重複あり）
    @inlinable
    internal func ___equal_range(_ k: _Key) -> (lower: _NodePtr, upper: _NodePtr) {
      __tree_.__equal_range_multi(k)
    }
  }

  extension _CompareV2 where Base: UniqueMultiplicity, Self: UnsafeIndexProviderProtocolV2 {

    //（重複なし）
    @inlinable
    internal func ___index_equal_range(_ k: _Key) -> (lower: Index, upper: Index) {
      let (lo, hi) = ___equal_range(k)
      return (___index(lo.sealed), ___index(hi.sealed))
    }
  }

  extension _CompareV2 where Base: MultiMultiplicity, Self: UnsafeIndexProviderProtocolV2 {

    // （重複あり）
    @inlinable
    internal func ___index_equal_range(_ k: _Key) -> (lower: Index, upper: Index) {
      let (lo, hi) = __tree_.__equal_range_multi(k)
      return (___index(lo.sealed), ___index(hi.sealed))
    }
  }
#endif
