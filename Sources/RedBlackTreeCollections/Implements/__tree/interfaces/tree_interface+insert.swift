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
protocol InsertNodeAtInterface: _NodePtrType {
  @inlinable func __insert_node_at(
    _ __parent: _NodePtr,
    _ __child: _NodeRef,
    _ __new_node: _NodePtr
  )
}

@usableFromInline
protocol InsertUniqueInterface: _NodePtrType & _PayloadValueType {
  @inlinable func __insert_unique(_ x: _PayloadValue) -> (__r: _NodePtr, __inserted: Bool)
  @inlinable func __emplace_unique_key_args(_ __k: _PayloadValue) -> (__r: _NodePtr, __inserted: Bool)
}

@usableFromInline
protocol InsertLastInterface: _NodePtrType & _PayloadValueType {
  @inlinable func ___max_ref() -> (__parent: _NodePtr, __child: _NodeRef)
  @inlinable func ___emplace_hint_right(_ __parent: _NodePtr, _ __child: _NodeRef, _ __k: _PayloadValue)
    -> (__parent: _NodePtr, __child: _NodeRef)
  //  func ___emplace_hint_right(_ __p: _NodePtr, _ __k: _PayloadValue) -> _NodePtr
  @inlinable func ___emplace_hint_left(_ __p: _NodePtr, _ __k: _PayloadValue) -> _NodePtr
}
