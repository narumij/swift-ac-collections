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

@frozen
@usableFromInline
struct ___UnsafeHandle<VC> where VC: ValueComparer {

  @inlinable
  @inline(__always)
  init(
    __header_ptr: UnsafePointer<___RedBlackTree.___Header>,
    __node_ptr: UnsafePointer<___RedBlackTree.___Node>,
    __element_ptr: UnsafePointer<Element>
  ) {
    self.__header_ptr = __header_ptr
    self.__node_ptr = __node_ptr
    self.__element_ptr = __element_ptr
  }
  @usableFromInline
  let __header_ptr: UnsafePointer<___RedBlackTree.___Header>
  @usableFromInline
  let __node_ptr: UnsafePointer<___RedBlackTree.___Node>
  @usableFromInline
  let __element_ptr: UnsafePointer<Element>
}

extension ___UnsafeHandle: ___UnsafeHandleBase { }
extension ___UnsafeHandle: RefImpl & RootImpl & RootPtrImpl {}
extension ___UnsafeHandle: NodeFindProtocol & NodeFindEqualProtocol & FindLeafProtocol {}
extension ___UnsafeHandle: EqualProtocol {}

extension ___UnsafeHandle {

  // 違和感はあるが、__tree由来なので致し方なし
  @inlinable @inline(__always)
  func __value_(_ p: _NodePtr) -> _Key {
    __value_(__element_ptr[p])
  }
}

extension ___UnsafeHandle {
  
  @inlinable @inline(__always)
  func ___element(_ p: _NodePtr) -> Element { __element_ptr[p] }
}

// ポインタに依存するコードは、抽象化して分離することが難しい
// このため、___UnsafeMutableHandleとかぶりが多い

extension ___UnsafeHandle {

  @inlinable
  @inline(__always)
  var __left_: _NodePtr {
    __header_ptr.pointee.__left_
  }

  @inlinable
  @inline(__always)
  var __begin_node: _NodePtr {
    __header_ptr.pointee.__begin_node
  }

//  @inlinable
//  @inline(__always)
//  var size: Int {
//    __header_ptr.pointee.size
//  }
}

extension ___UnsafeHandle {

  @inlinable
  @inline(__always)
  func __parent_(_ p: _NodePtr) -> _NodePtr {
    __node_ptr[p].__parent_
  }
  @inlinable
  @inline(__always)
  func __left_(_ p: _NodePtr) -> _NodePtr {
    p == .end ? __left_ : __node_ptr[p].__left_
  }
  @inlinable
  @inline(__always)
  func __right_(_ p: _NodePtr) -> _NodePtr {
    __node_ptr[p].__right_
  }
  @inlinable
  @inline(__always)
  func __is_black_(_ p: _NodePtr) -> Bool {
    __node_ptr[p].__is_black_
  }
  @inlinable
  @inline(__always)
  func __parent_unsafe(_ p: _NodePtr) -> _NodePtr {
    __parent_(p)
  }
}

// ここまでは基本的な実装
// ここからはセット、マルチセット、辞書の実装

extension ___UnsafeHandle {

  @inlinable
  @inline(__always)
  func distance(__first: _NodePtr, __last: _NodePtr) -> Int {
    var __first = __first
    var __r = 0
    while __first != __last {
      __first = __tree_next(__first)
      __r += 1
    }
    return __r
  }
  
  @inlinable
  @inline(__always)
  func distance(__l: _NodePtr, __r: _NodePtr) -> Int {
    var __p = __begin_node
    var (l,r): (Int?,Int?) = (nil,nil)
    var __a = 0
    while __p != __end_node(), l == nil || r == nil {
      if __p == __l { l = __a }
      if __p == __r { r = __a }
      __p = __tree_next(__p)
      __a += 1
    }
    if __p == __l { l = __a }
    if __p == __r { r = __a }
    return r! - l!
  }

  @inlinable
  @inline(__always)
  public func ___for_each(__p: _NodePtr, __l: _NodePtr, body: (_NodePtr, inout Bool) throws -> Void) rethrows {
    var __p = __p
    var cont = true
    while cont, __p != __l {
      try body(__p, &cont)
      __p = __tree_next(__p)
    }
  }
}
