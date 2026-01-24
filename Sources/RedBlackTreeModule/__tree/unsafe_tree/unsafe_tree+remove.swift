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
protocol RemoveProtocol_ptr:
  _UnsafeNodePtrType
    & BeginNodeInterface
    & EndNodeInterface
    & RootInterface
    & SizeInterface
    & RemoveInteface
    & TreeAlgorithmProtocol_ptr
{}

extension RemoveProtocol_ptr {

  @inlinable
  @inline(__always)
  internal func __remove_node_pointer(_ __ptr: _NodePtr) -> _NodePtr {
    var __r = __ptr
    __r = __tree_next_iter(__r)
    if __begin_node_ == __ptr {
      __begin_node_ = __r
    }
    __size_ -= 1
    // _std__tree_remove(__end_node.__left_, __ptr)
    _ptr__tree_remove(__root, __ptr)
    return __r
  }

  @inlinable
  @inline(__always)
  internal func ___remove_node_pointer(_ __ptr: _NodePtr) {
    if __begin_node_ == __ptr {
      // 単に要素を削除したい場合、無駄な手間になるので限定してみた
      __begin_node_ = __tree_next_iter(__ptr)
    }
    __size_ -= 1
    // __root等は、llvmと異なり木の保持の仕方がリッチなうえ型チェックが邪魔なので直接とった方がいい
    _ptr__tree_remove(__root, __ptr)
  }
}
