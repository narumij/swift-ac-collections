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
protocol InsertNodeAtProtocol_ptr: ~Copyable,
  _UnsafeNodePtrType
    & InsertNodeAtInterface
    & BeginNodeInterface
    & EndNodeInterface
    & RootInterface
    & SizeInterface
    & NullPtrInterface
    & TreeAlgorithmProtocol_ptr
    & TreeAlgorithmBaseProtocol_ptr
{}

extension InsertNodeAtProtocol_ptr where Self: ~Copyable {

  @inlinable
  //  @inline(never)
  internal func
    __insert_node_at(
      _ __parent: _NodePtr, _ __child: _NodeRef,
      _ __new_node: _NodePtr
    )
  {
    let __new_node = __new_node
    __new_node.__left_ = nullptr
    __new_node.__right_ = nullptr
    __new_node.__parent_ = __parent
    // __new_node->__is_black_ is initialized in __tree_balance_after_insert
    __child.pointee = __new_node
    // unsafe operation not allowed
    if __begin_node_.__left_ != nullptr {
      __begin_node_ = __begin_node_.__left_
    }
    // _std__tree_balance_after_insert(__end_node.__left_, __child.pointee)
    _ptr__tree_balance_after_insert(__root, __child.pointee)
    __size_ &+= 1
  }
}

@usableFromInline
protocol InsertUniqueProtocol_ptr: ~Copyable,
  _UnsafeNodePtrType
    & _TreePayloadValue_KeyInterface
    & InsertNodeAtInterface
    & InsertUniqueInterface
    & FindEqualInterface
    & AllocationInterface
    & NullPtrInterface
{}

extension InsertUniqueProtocol_ptr where Self: ~Copyable {

  @inlinable
  //  @inline(never)
  internal func
    __insert_unique(_ x: _PayloadValue) -> (__r: _NodePtr, __inserted: Bool)
  {
    __emplace_unique_key_args(x)
  }

  @inlinable
  //  @inline(never)
  internal func
    __emplace_unique_key_args(_ __k: _PayloadValue)
    -> (__r: _NodePtr, __inserted: Bool)
  {
    let (__parent, __child) = __find_equal(__key(__k))
    let __r = __child
    if __child.pointee == nullptr {
      let __h = __construct_node(__k)
      __insert_node_at(__parent, __child, __h)
      return (__h, true)
    } else {
      // __insert_node_atで挿入した場合、__rが破損する
      // 既存コードの後続で使用しているのが実質Ptrなので、そちらを返すよう一旦修正
      // 今回初めて破損したrefを使用したようで既存コードでの破損ref使用は大丈夫そう
      return (__r.pointee, false)
    }
  }
}

@usableFromInline
protocol InsertMultiProtocol: ~Copyable, AllocationInterface & _TreePayloadValue_KeyInterface
    & FindLeafInterface
    & InsertNodeAtInterface & NullPtrInterface
{}

extension InsertMultiProtocol where Self: ~Copyable {

  @inlinable
  internal func __insert_multi(_ x: _PayloadValue) -> _NodePtr {
    __emplace_multi(x)
  }

  @inlinable
  internal func
    __emplace_multi(_ __k: _PayloadValue) -> _NodePtr
  {
    let __h = __construct_node(__k)
    var __parent = nullptr
    let __child = __find_leaf_high(&__parent, __key(__k))
    __insert_node_at(__parent, __child, __h)
    return __h
  }
}

@usableFromInline
protocol InsertLastProtocol_ptr: ~Copyable,
  _UnsafeNodePtrType
    & InsertLastInterface
    & InsertNodeAtInterface
    & AllocationInterface
    & EndInterface
    & EndNodeInterface
    & RootInterface
    & NullPtrInterface
{}

extension InsertLastProtocol_ptr where Self: ~Copyable {

  @inlinable
  internal func ___max_ref() -> (__parent: _NodePtr, __child: _NodeRef) {
    if __root == nullptr {
      return (__end_node, __end_node.__left_ref)
    }
    let __parent = __tree_max(__root)
    return (__parent, __parent.__right_ref)
  }

  @inlinable
  internal func
    ___emplace_hint_right(_ __parent: _NodePtr, _ __child: _NodeRef, _ __k: _PayloadValue)
    -> (__parent: _NodePtr, __child: _NodeRef)
  {
    let __p = __construct_node(__k)
    __insert_node_at(__parent, __child, __p)
    return (__p, __p.__right_ref)
  }
}

#if false
extension InsertLastProtocol_ptr where Self: ~Copyable {

    // 資料的に残してある
    //
    // こちらのほうがAPIとしては収まりがいいが、かすかに上のモノの方が速い
    // 分岐の有無の差だとおもわれる
    @inlinable
    internal func ___emplace_hint_right(_ __p: _NodePtr, _ __k: _PayloadValue) -> _NodePtr {
      let __child = __p == end ? __end_node.__left_ref : __p.__right_ref
      //                        ^--- これの差
      let __h = __construct_node(__k)
      __insert_node_at(__p, __child, __h)
      return __h
    }

    @inlinable
    internal func ___emplace_hint_left(_ __p: _NodePtr, _ __k: _PayloadValue) -> _NodePtr {
      let __child = __p.__left_ref
      let __h = __construct_node(__k)
      __insert_node_at(__p, __child, __h)
      return __h
    }
  }
#endif

// MARK: -

@usableFromInline
protocol EmplaceHintUniqueProtocol_ptr: ~Copyable,
  _UnsafeNodePtrType
    & _TreePayloadValue_KeyInterface
    & _TreeNode_KeyInterface
    & InsertNodeAtInterface
    & FindHintEqualInterface
    & AllocationInterface
    & DellocationInterface
    & NullPtrInterface
{}

extension EmplaceHintUniqueProtocol_ptr where Self: ~Copyable {

  // キー無しのケースはC++の事情によるもので、Comparable割り切りのSwift版では不要
  // 以下は資料として残して、分割版を使うこととする
  @inlinable
  internal func __emplace_hint_unique(
    _ __p: _NodePtr, _ __k: @autoclosure () -> _Key?, _ __v: @autoclosure () -> _PayloadValue
  )
    -> (__r: _NodePtr, __inserted: Bool)
  {

    if let __key = __k() {
      var __dummy = nullptr
      // 簡略記法もあるが、ここが若干あぶないことに気づけるよう、with記法を採用
      let (__parent, __child) = withUnsafeMutablePointer(to: &__dummy) { __dummy in
        __find_equal(__p, __dummy, __key)
      }
      var __r = __child.pointee
      var __inserted = false
      if __child.pointee == nullptr {
        let __h = __construct_node(__v())
        __insert_node_at(__parent, __child, __h)
        __r = __h
        __inserted = true
      }
      return (__r, __inserted)
    } else {
      let __h = __construct_node(__v())
      var __dummy = nullptr
      let (__parent, __child) = withUnsafeMutablePointer(to: &__dummy) { __dummy in
        __find_equal(__p, __dummy, __get_value(__h))
      }
      var __r = __child.pointee
      var __inserted = false
      if __child.pointee == nullptr {
        __insert_node_at(__parent, __child, __h)
        __r = __h
        __inserted = true
      } else {
        destroy(__h)
      }
      return (__r, __inserted)
    }
  }

  // 実際に使う分割前半バージョン
  @inlinable
  internal func ___emplace_hint_unique_(
    _ __p: _NodePtr, _ __key: @autoclosure () -> _Key, _ __v: @autoclosure () -> _PayloadValue
  )
    -> (__r: _NodePtr, __inserted: Bool)
  {
    var __dummy = nullptr
    // 簡略記法もあるが、ここが若干あぶないことに気づけるよう、with記法を採用
    let (__parent, __child) = withUnsafeMutablePointer(to: &__dummy) { __dummy in
      __find_equal(__p, __dummy, __key())
    }
    var __r = __child.pointee
    var __inserted = false
    if __child.pointee == nullptr {
      let __h = __construct_node(__v())
      __insert_node_at(__parent, __child, __h)
      __r = __h
      __inserted = true
    }
    return (__r, __inserted)
  }

  #if false
    // __get_valueでしかキーが取れないケースに使う分割後半バージョン
    @inlinable
    internal func ___emplace_hint_unique_(
      _ __p: _NodePtr,
      _ __v: @autoclosure () -> _PayloadValue
    ) -> (__r: _NodePtr, __inserted: Bool) {
      let __h = __construct_node(__v())

      var __dummy = nullptr

      // 簡略記法もあるが、ここが若干あぶないことに気づけるよう、with記法を採用
      let (__parent, __child) = withUnsafeMutablePointer(to: &__dummy) { __dummy in
        __find_equal(__p, __dummy, __get_value(__h))
      }

      var __r = __child.pointee
      var __inserted = false

      if __child.pointee == nullptr {
        __insert_node_at(__parent, __child, __h)
        __r = __h
        __inserted = true
      } else {
        destroy(__h)
      }

      return (__r, __inserted)
    }
  #endif
}

@usableFromInline
protocol EmplaceHintMultiProtocol_ptr: ~Copyable,
  _UnsafeNodePtrType
    & _TreePayloadValue_KeyInterface
    & _TreeNode_KeyInterface
    & InsertNodeAtInterface
    & FindHintLeafInterface
    & AllocationInterface
    & NullPtrInterface
{}

extension EmplaceHintMultiProtocol_ptr where Self: ~Copyable {

  @inlinable
  internal func __emplace_hint_multi(_ __p: _NodePtr, _ value: @autoclosure () -> _PayloadValue)
    -> _NodePtr
  {
    let __h = __construct_node(value())
    var parent = nullptr
    let __child = __find_leaf(__p, &parent, __get_value(__h))
    __insert_node_at(parent, __child, __h)
    return __h
  }
}
