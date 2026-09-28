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
protocol InsertNodeAtProtocol_ptr:
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

extension InsertNodeAtProtocol_ptr {

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
    //    _std__tree_balance_after_insert(__end_node.__left_, __child.pointee)
    _ptr__tree_balance_after_insert(__root, __child.pointee)
    __size_ &+= 1
  }
}

@usableFromInline
protocol InsertUniqueProtocol_ptr:
  _UnsafeNodePtrType
    & _TreePayloadValue_KeyInterface
    & InsertNodeAtInterface
    & InsertUniqueInterface
    & FindEqualInterface
    & AllocationInterface
    & NullPtrInterface
{}

extension InsertUniqueProtocol_ptr {

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
protocol InsertMultiProtocol: AllocationInterface & _TreePayloadValue_KeyInterface
    & FindLeafInterface
    & InsertNodeAtInterface & NullPtrInterface
{}

extension InsertMultiProtocol {

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
protocol InsertLastProtocol_ptr:
  _UnsafeNodePtrType
    & InsertLastInterface
    & InsertNodeAtInterface
    & AllocationInterface
    & EndInterface
    & EndNodeInterface
    & RootInterface
    & NullPtrInterface
{}

extension InsertLastProtocol_ptr {

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
  extension InsertLastProtocol_ptr {

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
protocol EmplaceHintUniqueProtocol_ptr:
  _UnsafeNodePtrType
    & _TreePayloadValue_KeyInterface
    & _TreeNode_KeyInterface
    & InsertNodeAtInterface
    & FindHintEqualInterface
    & AllocationInterface
    & DellocationInterface
    & NullPtrInterface
{}

/*
 _LIBCPP_HIDE_FROM_ABI iterator insert(const_iterator __p, const value_type& __v) {
   return __tree_.__emplace_hint_unique(__p, __v).first;
 }
 */

/*
 template <class... _Args>
 _LIBCPP_HIDE_FROM_ABI pair<iterator, bool> __emplace_hint_unique(const_iterator __p, _Args&&... __args) {
   return std::__try_key_extraction<key_type>(
       [this, __p](const key_type& __key, _Args&&... __args2) {
         __node_base_pointer __dummy;
         auto [__parent, __child] = __find_equal(__p, __dummy, __key);
         __node_pointer __r       = std::__static_fancy_pointer_cast<__node_pointer>(__child);
         bool __inserted          = false;
         if (__child == nullptr) {
           __node_holder __h = __construct_node(std::forward<_Args>(__args2)...);
           __insert_node_at(__parent, __child, std::__static_fancy_pointer_cast<__node_base_pointer>(__h.get()));
           __r        = __h.release();
           __inserted = true;
         }
         return pair<iterator, bool>(iterator(__r), __inserted);
       },
       [this, __p](_Args&&... __args2) {
         __node_holder __h = __construct_node(std::forward<_Args>(__args2)...);
         __node_base_pointer __dummy;
         auto [__parent, __child] = __find_equal(__p, __dummy, __h->__get_value());
         __node_pointer __r       = std::__static_fancy_pointer_cast<__node_pointer>(__child);
         if (__child == nullptr) {
           __insert_node_at(__parent, __child, std::__static_fancy_pointer_cast<__node_base_pointer>(__h.get()));
           __r = __h.release();
         }
         return pair<iterator, bool>(iterator(__r), __child == nullptr);
       },
       std::forward<_Args>(__args)...);
 }
 */

extension EmplaceHintUniqueProtocol_ptr {

  /// ヒント位置を利用し、必要な場合に限って値を構築して挿入する。
  ///
  /// extractingKey がキーを返した場合、重複を確認してから
  /// constructingValue を評価する。キーを事前に取得できない場合は、
  /// 値を構築し、その値からキーを取得して重複を確認する。
  @inlinable
  internal func __emplace_hint_unique(
    _ __p: _NodePtr,
    _ __k: @autoclosure () -> _Key?,
    _ __v: @autoclosure () -> _PayloadValue
  ) -> (__r: _NodePtr, __inserted: Bool) {
    if let __key = __k() {
      var __dummy = nullptr
      let (__parent, __child) = __find_equal(__p, &__dummy, __key)
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
      let (parent, __child) = __find_equal(__p, &__dummy, __get_value(__h))
      var __r = __child.pointee
      guard __child.pointee == nullptr else {
        return (__child.pointee, false)
      }
      if __child.pointee == nullptr {
        __insert_node_at(parent, __child, __h)
        __r = __h
      } else {
        destroy(__h)
      }
      return (__r, __child.pointee == nullptr)
    }
  }
}

@usableFromInline
protocol EmplaceHintMultiProtocol_ptr:
  _UnsafeNodePtrType
    & _TreePayloadValue_KeyInterface
    & _TreeNode_KeyInterface
    & InsertNodeAtInterface
    & FindHintLeafInterface
    & AllocationInterface
    & NullPtrInterface
{}

/*
 template <class _Tp, class _Compare, class _Allocator>
 template <class... _Args>
 typename __tree<_Tp, _Compare, _Allocator>::iterator
 __tree<_Tp, _Compare, _Allocator>::__emplace_hint_multi(const_iterator __p, _Args&&... __args) {
   __node_holder __h = __construct_node(std::forward<_Args>(__args)...);
   __end_node_pointer __parent;
   __node_base_pointer& __child = __find_leaf(__p, __parent, __h->__get_value());
   __insert_node_at(__parent, __child, static_cast<__node_base_pointer>(__h.get()));
   return iterator(static_cast<__node_pointer>(__h.release()));
 }
 */

extension EmplaceHintMultiProtocol_ptr {

  /// ヒント位置を利用して、重複を許可したまま値を構築して挿入する。
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
