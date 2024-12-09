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
// Copyright © [年] The LLVM Project.
// Licensed under the Apache License, Version 2.0 with LLVM Exceptions.
// The original license can be found at https://llvm.org/LICENSE.txt
//
// This Swift implementation includes modifications and adaptations made by narumij.

import Foundation

@usableFromInline
protocol ReadHandleImpl: MemberProtocol & ValueProtocol & EqualProtocol & RootImpl & RefImpl & RootPtrImpl {
  associatedtype Element
  var __header_ptr: UnsafePointer<RedBlackTree.___Header> { get }
  var __node_ptr: UnsafePointer<RedBlackTree.___Node> { get }
  var __value_ptr: UnsafePointer<Element> { get }
}

extension ReadHandleImpl {

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

  @inlinable
  @inline(__always)
  var size: Int {
    __header_ptr.pointee.size
  }
}

extension ReadHandleImpl {

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

extension ReadHandleImpl {
  @inlinable
  @inline(__always)
  func __value_(_ p: _NodePtr) -> Element { __value_ptr[p] }
}
