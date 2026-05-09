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

@usableFromInline
protocol _CompareV2: UnsafeTreeHostV2 & _KeyBride {}

extension _CompareV2 where Base: CompareMultiTrait {

  /// （重複あり）
  @inlinable @inline(__always)
  internal func ___equal_range(_ k: _Key) -> (lower: _NodePtr, upper: _NodePtr) {
    __tree_.__equal_range_multi(k)
  }
}
