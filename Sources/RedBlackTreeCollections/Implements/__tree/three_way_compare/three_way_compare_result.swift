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

// 結局のところ最も速い
public typealias __int_compare_result = Int

extension Int: ThreeWayCompareResult {}

extension Int {
  @inlinable
  public func __less() -> Bool { self < 0 }
  @inlinable
  public func __greater() -> Bool { self > 0 }
}

// 安定して速い
public
  struct __eager_compare_result: ThreeWayCompareResult
{
  @usableFromInline internal var __res_: Int
  @inlinable
  internal init(_ __res_: Int) {
    self.__res_ = __res_
  }
  @inlinable
  public func __less() -> Bool { __res_ < 0 }
  @inlinable
  public func __greater() -> Bool { __res_ > 0 }
}
