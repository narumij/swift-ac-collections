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

// 性能が出ないため不採用
// 特殊化済みでも性能がでなかった (2026/11/2)

// Do an in-order traversal of the tree until `__break` returns true. Takes the root node of the tree.
/// 中順走査。停止判定がtrueのノードは処理せず、trueを返す。
/// 前提：rootは空でない部分木。走査中に木の接続を変更しない。
/// 値の取り出しはprojectionに任せ、ここではノードの接続だけを扱う。
@inlinable
package func __tree_iterate_from_root<Value>(
  _ __break: (UnsafeMutablePointer<UnsafeNode>) -> Bool,
  _ __root: UnsafeMutablePointer<UnsafeNode>,
  _ __func: (Value) throws -> Void,
  _ __proj: (UnsafeMutablePointer<UnsafeNode>) -> Value
) rethrows -> Bool {
  if __root.__left_ != .nullptr {
    if try __tree_iterate_from_root(__break, __root.__left_, __func, __proj) {
      return true
    }
  }
  if __break(__root) {
    return true
  }
  try __func(__proj(__root))
  if __root.__right_ != .nullptr {
    return try __tree_iterate_from_root(__break, __root.__right_, __func, __proj)
  }
  return false
}

// Do an in-order traversal of the tree from __first to __last.
/// 同じ木の有効な半開範囲[first, last)を中順走査する。
/// first == lastは空範囲。lastにはend nodeを指定できる。
/// 走査中に木の接続を変更しない。
@inlinable
package func __tree_iterate_subrange<Value>(
  _ __first: UnsafeMutablePointer<UnsafeNode>,
  _ __last: UnsafeMutablePointer<UnsafeNode>,
  _ __func: (Value) throws -> Void,
  _ __proj: (UnsafeMutablePointer<UnsafeNode>) -> Value
) rethrows {
  var __first = __first
  while true {
    if __first == __last {
      return
    }
    try __func(__proj(__first))
    if __first.__right_ != .nullptr {
      if try __tree_iterate_from_root(
        { $0 == __last }, __first.__right_, __func, __proj
      ) {
        return
      }
    }
    while !__tree_is_left_child(__first) {
      __first = __first.__parent_
    }
    __first = __first.__parent_
  }
}
