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

extension ___RedBlackTree.___Tree {
  
  @usableFromInline
  struct UnsafeHandle {
    @inlinable
    @inline(__always)
    internal init(__header_ptr: UnsafeMutablePointer<___RedBlackTree.___Tree<VC>.Header>, __node_ptr: UnsafeMutablePointer<___RedBlackTree.___Tree<VC>.Node>) {
      self.__header_ptr = __header_ptr
      self.__node_ptr = __node_ptr
    }
    @usableFromInline
    var __header_ptr: UnsafeMutablePointer<Header>
    @usableFromInline
    var __node_ptr: UnsafeMutablePointer<Node>
    public typealias VC = Tree.VC
  }
  
  @inlinable
  @inline(__always)
  static func with<R>(_ manager: Manager,_ body: (UnsafeHandle) throws -> R) rethrows -> R {
    try manager.withUnsafeMutablePointers { header, nodes in
      try body(UnsafeHandle(__header_ptr: header, __node_ptr: nodes))
    }
  }
}

extension ___RedBlackTree.___Tree.UnsafeHandle {
  
  @inlinable
  public subscript(_ pointer: _NodePtr) -> Element {
    @inline(__always)
    get { __node_ptr[pointer].__value_ }
    nonmutating set { __node_ptr[pointer].__value_ = newValue }
  }
  
  @inlinable
  @inline(__always)
  subscript(key pointer: _NodePtr) -> _Key {
      __key(__node_ptr[pointer].__value_)
  }

  @inlinable
  @inline(__always)
  public var __left_: _NodePtr {
    get { __header_ptr.pointee.__left_ }
    nonmutating set { __header_ptr.pointee.__left_ = newValue }
  }
}

extension ___RedBlackTree.___Tree.UnsafeHandle: MemberProtocol & RootImpl & RefSetImpl & RootPtrImpl { }
extension ___RedBlackTree.___Tree.UnsafeHandle: ValueProtocol { }

extension ___RedBlackTree.___Tree.UnsafeHandle {
  
  @usableFromInline
  typealias _Key = VC._Key

  public
    typealias Element = VC.Element

  @inlinable @inline(__always)
  func __key(_ e: VC.Element) -> VC._Key {
    VC.__key(e)
  }
  
  @inlinable @inline(__always)
  func __value_(_ p: _NodePtr) -> _Key {
    __value_(__node_ptr[p].__value_)
  }

  @inlinable @inline(__always)
  func __value_(_ e: VC.Element) -> _Key {
    VC.__key(e)
  }

  @inlinable @inline(__always)
  func value_comp(_ a: _Key, _ b: _Key) -> Bool {
    VC.value_comp(a, b)
  }
}

extension ___RedBlackTree.___Tree.UnsafeHandle {
  
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

extension ___RedBlackTree.___Tree.UnsafeHandle {

  @inlinable
  func __is_black_(_ lhs: _NodePtr, _ rhs: Bool) {
    __node_ptr[lhs].__is_black_ = rhs
  }
  @inlinable
  func __parent_(_ lhs: _NodePtr, _ rhs: _NodePtr) {
    __node_ptr[lhs].__parent_ = rhs
  }
  @inlinable
  func __left_(_ lhs: _NodePtr, _ rhs: _NodePtr) {
    if lhs == .end {
      __left_ = rhs
    } else {
      __node_ptr[lhs].__left_ = rhs
    }
  }
  @inlinable
  func __right_(_ lhs: _NodePtr, _ rhs: _NodePtr) {
    __node_ptr[lhs].__right_ = rhs
  }
}
