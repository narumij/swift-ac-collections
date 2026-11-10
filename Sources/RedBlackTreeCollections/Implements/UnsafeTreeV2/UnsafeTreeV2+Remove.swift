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

// TODO: このソースの位置づけを再確認する

extension UnsafeTreeV2 {

  @inlinable
  @discardableResult
  package mutating func _unchecked_remove(at ptr: _NodePtr)
  -> (__r: _NodePtr, payload: _PayloadValue)
  {
    let ___e = Base.__payload_(ptr)
    let __r = erase(ptr)
    return (__r, ___e)
  }

  @inlinable
  package mutating func _unchecked_remove_v2(at ptr: _NodePtr) -> _PayloadValue {
    let ___e = Base.__payload_(ptr)
    _ = erase(ptr)
    return ___e
  }
}

extension UnsafeTreeV2 {

  @inlinable
  package mutating func ___unchecked_remove_first() -> _PayloadValue? {
    guard __begin_node_ != __end_node else { return nil }
    return _unchecked_remove_v2(at: __begin_node_)
  }

  @inlinable
  package mutating func ___unchecked_remove_last() -> _PayloadValue? {
    guard __begin_node_ != __end_node else { return nil }
    return _unchecked_remove_v2(at: __tree_prev_iter(__end_node))
  }
}

extension UnsafeTreeV2 {
  
  @inlinable
  mutating func ___remove_if_present(_ __k: _Key) -> _PayloadValue? {
    var __i = find(__k)
    if __i == end {
      return nil
    }
    if __ensureUnique() {
      __i = __simple_retrieve(__i)
    }
    let ___e = Base.__payload_(__i)
    _ = erase(__i)
    return ___e
  }
}

extension UnsafeTreeV2 {

  @inlinable
  mutating func ___erase_unique_if_present(_ __k: _Key) -> Bool {
    var __i = find(__k)
    if __i == end {
      return false
    }
    if __ensureUnique() {
      __i = __simple_retrieve(__i)
    }
    _ = erase(__i)
    return true
  }

  @inlinable
  mutating func ___erase_multi_if_present(_ __k: _Key) -> Int {
    var __p = __equal_range_multi(__k)
    guard __p.0 != __p.1 else { return 0 }
    if __ensureUnique() {
      (__p.0,__p.1) = (__simple_retrieve(__p.0),__simple_retrieve(__p.1))
    }
    var __r = 0
    while __p.0 != __p.1 {
      defer { __r &+= 1 }
      __p.0 = erase(__p.0)
    }
    return __r
  }
}
