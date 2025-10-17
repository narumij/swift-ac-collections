// Copyright 2024 narumij
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// This code is based on work originally distributed under the Apache License 2.0 with LLVM Exceptions:
//
// Copyright © 2003-2024 The LLVM Project.
// Licensed under the Apache License, Version 2.0 with LLVM Exceptions.
// The original license can be found at https://llvm.org/LICENSE.txt
//
// This Swift implementation includes modifications and adaptations made by narumij.

import Foundation

@usableFromInline
protocol InsertNodeAtProtocol:
  TreeNodeProtocol & TreeNodeRefProtocol & SizeProtocol & BeginNodeProtocol & EndNodeProtocol
{}

extension InsertNodeAtProtocol {

  @inlinable
  @inline(__always)
  func
    __insert_node_at(
      _ __parent: _NodePtr, _ __child: _NodeRef,
      _ __new_node: _NodePtr
    )
  {
    __left_(__new_node, .nullptr)
    __right_(__new_node, .nullptr)
    __parent_(__new_node, __parent)
    // __new_node->__is_black_ is initialized in __tree_balance_after_insert
    __ptr_(__child, __new_node)
    // unsafe operation not allowed
    if __left_(__begin_node) != .nullptr {
      __begin_node = __left_(__begin_node)
    }
    __tree_balance_after_insert(__left_(__end_node()), __ptr_(__child))
    size += 1
  }
}

@usableFromInline
protocol InsertUniqueProtocol:
  AllocatorProtocol & KeyProtocol & TreeNodeRefProtocol
{
  func __find_equal(_ __v: _Key) -> (__parent: _NodePtr, __child: _NodeRef)

  func
    __insert_node_at(
      _ __parent: _NodePtr, _ __child: _NodeRef,
      _ __new_node: _NodePtr)
}

extension InsertUniqueProtocol {

  @inlinable
  @inline(__always)
  public func __insert_unique(_ x: _Value) -> (__r: _NodePtr, __inserted: Bool) {

    __emplace_unique_key_args(x)
  }

  #if true
    @inlinable
    @inline(__always)
    func
      __emplace_unique_key_args(_ __k: _Value) -> (__r: _NodePtr, __inserted: Bool)
    {
      let (__parent, __child) = __find_equal(__key(__k))
      let __r = __child
      if __ptr_(__child) == .nullptr {
        let __h = __construct_node(__k)
        __insert_node_at(__parent, __child, __h)
        return (__h, true)
      } else {
        // __insert_node_atで挿入した場合、__rが破損する
        // 既存コードの後続で使用しているのが実質Ptrなので、そちらを返すよう一旦修正
        // 今回初めて破損したrefを使用したようで既存コードでの破損ref使用は大丈夫そう
        return (__ptr_(__r), false)
      }
    }
  #else
    @inlinable
    func
      __emplace_unique_key_args(_ __k: _Value) -> (__r: _NodeRef, __inserted: Bool)
    {
      var __parent = _NodePtr.nullptr
      let __child = __find_equal(&__parent, __key(__k))
      let __r = __child
      var __inserted = false
      if __ref_(__child) == .nullptr {
        let __h = __construct_node(__k)
        __insert_node_at(__parent, __child, __h)
        __inserted = true
      }
      return (__r, __inserted)
    }
  #endif
}

@usableFromInline
protocol InsertMultiProtocol:
  AllocatorProtocol & KeyProtocol
{

  func
    __find_leaf_high(_ __parent: inout _NodePtr, _ __v: _Key) -> _NodeRef
  
  func
    __insert_node_at(
      _ __parent: _NodePtr, _ __child: _NodeRef,
      _ __new_node: _NodePtr)
}

extension InsertMultiProtocol {

  @inlinable
  @inline(__always)
  public func __insert_multi(_ x: _Value) -> _NodePtr {
    __emplace_multi(x)
  }

  @inlinable
  @inline(__always)
  func
    __emplace_multi(_ __k: _Value) -> _NodePtr
  {
    let __h = __construct_node(__k)
    var __parent = _NodePtr.nullptr
    let __child = __find_leaf_high(&__parent, __key(__k))
    __insert_node_at(__parent, __child, __h)
    return __h
  }
}

@usableFromInline
protocol InsertLastProtocol:
  InsertNodeAtProtocol & AllocatorProtocol & RootProtocol & EndNodeProtocol
{}

extension InsertLastProtocol {

  @inlinable
  @inline(__always)
  func ___max_ref() -> (__parent: _NodePtr, __child: _NodeRef) {
    if __root() == .nullptr {
      return (__end_node(), __left_ref(__end_node()))
    }
    let __parent = __tree_max(__root())
    return (__parent, __right_ref(__parent))
  }

  @inlinable
  @inline(__always)
  func ___emplace_hint_right(_ __parent: _NodePtr, _ __child: _NodeRef, _ __k: _Value) -> (
    __parent: _NodePtr, __child: _NodeRef
  ) {
    let __p = __construct_node(__k)
    __insert_node_at(__parent, __child, __p)
    return (__p, __right_ref(__p))
  }

  // こちらのほうがAPIとしては収まりがいいが、かすかに上のモノの方が速い
  // 分岐の有無の差だとおもわれる
  @inlinable
  @inline(__always)
  func ___emplace_hint_right(_ __p: _NodePtr, _ __k: _Value) -> _NodePtr {
    let __child = __p == .end ? __left_ref(__p) : __right_ref(__p)
    //                        ^--- これの差
    let __h = __construct_node(__k)
    __insert_node_at(__p, __child, __h)
    return __h
  }

  @inlinable
  @inline(__always)
  func ___emplace_hint_left(_ __p: _NodePtr, _ __k: _Value) -> _NodePtr {
    let __child = __left_ref(__p)
    let __h = __construct_node(__k)
    __insert_node_at(__p, __child, __h)
    return __h
  }
}
