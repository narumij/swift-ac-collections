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

  // TODO: なおす
  @inlinable
  mutating func _removeIfPresent(_ key: _Key) -> _PayloadValue? {
    var node = find(key)
    guard node != end else { return nil }
    let tag = node.trackingTag
    if __ensureUnique() {
      node = try! __retrieve_(tag).get()
    }
    return _unchecked_remove(at: node).payload
  }

  // TODO: なおす
  @inlinable
  mutating func _eraseMultiIfPresent(_ key: _Key) -> Int {
    var (first, last) = __equal_range_multi(key)
    guard first != last else { return 0 }
    let firstTag = first.trackingTag
    let lastTag = last.trackingTag
    if __ensureUnique() {
      first = try! __retrieve_(firstTag).get()
      last = try! __retrieve_(lastTag).get()
    }
    var removed = 0
    while first != last {
      first = erase(first)
      removed &+= 1
    }
    return removed
  }
}
