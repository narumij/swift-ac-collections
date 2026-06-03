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

@usableFromInline
protocol FindLeafInterface: _NodePtrType & _KeyType {
  @inlinable func __find_leaf_low(_ __parent: inout _NodePtr, _ __v: _Key) -> _NodeRef
  @inlinable func __find_leaf_high(_ __parent: inout _NodePtr, _ __v: _Key) -> _NodeRef
}

@usableFromInline
protocol FindEqualInterface: _NodePtrType & _KeyType {
  @inlinable func __find_equal(_ __v: _Key) -> (__parent: _NodePtr, __child: _NodeRef)
}

@usableFromInline
protocol FindInteface: _NodePtrType & _KeyType {
  @inlinable func find(_ __v: _Key) -> _NodePtr
}
