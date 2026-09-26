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

/// 2025年のシンプル化で代表格となったもの
@usableFromInline
protocol BoundInteface: _NodePtrType & _KeyType {
  @inlinable func lower_bound(_ __v: _Key) -> _NodePtr
  @inlinable func upper_bound(_ __v: _Key) -> _NodePtr
}

/// 2025年の改善で増えたもの
@usableFromInline
protocol BoundBothInterface: _NodePtrType & _KeyType {
  @inlinable func __lower_bound_unique(_ __v: _Key) -> _NodePtr
  @inlinable func __upper_bound_unique(_ __v: _Key) -> _NodePtr
  @inlinable func __lower_bound_multi(_ __v: _Key) -> _NodePtr
  @inlinable func __upper_bound_multi(_ __v: _Key) -> _NodePtr
}

/// 昔からあるBoundインターフェースと同じシグネチャのもの
@usableFromInline
protocol BoundBasicInterface: _NodePtrType & _KeyType {
  @inlinable func __lower_bound_multi(_ __v: _Key, _ __root: _NodePtr, _ __result: _NodePtr) -> _NodePtr
  @inlinable func __upper_bound_multi(_ __v: _Key, _ __root: _NodePtr, _ __result: _NodePtr) -> _NodePtr
}
