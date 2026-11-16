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

#if true
extension UnsafeTreeV2 {

  @inlinable
  mutating func ___insert_unique_if_not_present(
    _ __k: _PayloadValue
  ) -> (__r: _NodePtr, __inserted: Bool) {
    var (__parent, __child) = __find_equal(__key(__k))
    let __e = __end_node
    if __child.pointee != nullptr { return (__child.pointee, false) }
    ensureUniqueAndCapacity()  // これが問題で全体をupdate内には移せない

    if __e != __end_node {  // 木の不一致判定
      (__parent, __child) = __simple_retrieve(__parent, __child)
    }
    let __h = __construct_node(__k)
    __insert_node_at(__parent, __child, __h)
    return (__h, true)
  }

  @inlinable
  mutating func __emplace_hint_unique_if_not_present(
    _ __k: _PayloadValue,_ __p: _NodePtr
  ) -> (__r: _NodePtr, __inserted: Bool) {
    
    var __dummy = nullptr
    let __e = __end_node

    // 問題が起きる可能性がすこしある
    var (__parent, __child) = __find_equal(__p, &__dummy, __key(__k))

    if __child.pointee != nullptr {
      return (__child.pointee, false)
    }
    
    ensureUniqueAndCapacity()
    
    if __e != __end_node {  // 木の不一致判定
      (__parent, __child) = __simple_retrieve(__parent, __child)
    }
    
    let __h = __construct_node(__k)
    __insert_node_at(__parent, __child, __h)
    
    return (__h, true)
  }
}

#else

// チューニング作業中
extension UnsafeTreeV2 where Base: ScalarValueTrait {

  @inlinable
  mutating func ___insert_unique_if_not_present(
    _ __k: _PayloadValue
  ) -> (__r: _NodePtr, __inserted: Bool) {
    var (__parent, __child) = __find_equal(__k)
    if __child.pointee != nullptr { return (__child.pointee, false) }
    
    let __e = __end_node
    ensureUniqueAndCapacity()  // これが問題で全体をupdate内には移せない
    if __e != __end_node {  // 木の不一致判定
      (__parent, __child) = __simple_retrieve(__parent, __child)
    }
    
    let __h = __construct_node(__k)
    __insert_node_at(__parent, __child, __h)
    return (__h, true)
  }

  @inlinable
  mutating func __emplace_hint_unique_if_not_present(
    _ __k: _PayloadValue,_ __p: _NodePtr
  ) -> (__r: _NodePtr, __inserted: Bool) {
    
    var __dummy = nullptr

    // 問題が起きる可能性がすこしある
    var (__parent, __child) = __find_equal(__p, &__dummy, __k)

    if __child.pointee != nullptr {
      return (__child.pointee, false)
    }
    
    let __e = __end_node
    ensureUniqueAndCapacity()
    if __e != __end_node {  // 木の不一致判定
      (__parent, __child) = __simple_retrieve(__parent, __child)
    }
    
    let __h = __construct_node(__k)
    __insert_node_at(__parent, __child, __h)
    return (__h, true)
  }
}

extension UnsafeTreeV2 where Base: PairValueTrait {

  @inlinable
  mutating func ___insert_unique_if_not_present(
    _ __k: _PayloadValue
  ) -> (__r: _NodePtr, __inserted: Bool) {
    var (__parent, __child) = __find_equal(__key(__k))
    if __child.pointee != nullptr { return (__child.pointee, false) }
    let __e = __end_node
    ensureUniqueAndCapacity()  // これが問題で全体をupdate内には移せない

    if __e != __end_node {  // 木の不一致判定
      (__parent, __child) = __simple_retrieve(__parent, __child)
    }
    let __h = __construct_node(__k)
    __insert_node_at(__parent, __child, __h)
    return (__h, true)
  }

  @inlinable
  mutating func __emplace_hint_unique_if_not_present(
    _ __k: _PayloadValue,_ __p: _NodePtr
  ) -> (__r: _NodePtr, __inserted: Bool) {
    
    var __dummy = nullptr

    // 問題が起きる可能性がすこしある
    var (__parent, __child) = __find_equal(__p, &__dummy, __key(__k))

    if __child.pointee != nullptr {
      return (__child.pointee, false)
    }
    
    let __e = __end_node
    ensureUniqueAndCapacity()
    if __e != __end_node {  // 木の不一致判定
      (__parent, __child) = __simple_retrieve(__parent, __child)
    }
    
    let __h = __construct_node(__k)
    __insert_node_at(__parent, __child, __h)
    return (__h, true)
  }
}
#endif
