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
struct _UnsafeHandle<VC> where VC: ValueComparer {

  @inlinable
  @inline(__always)
  init(
    __header_ptr: UnsafePointer<RedBlackTree.___Header>,
    __node_ptr: UnsafePointer<RedBlackTree.___Node>,
    __value_ptr: UnsafePointer<Element>
  ) {
    self.__header_ptr = __header_ptr
    self.__node_ptr = __node_ptr
    self.__value_ptr = __value_ptr
  }
  @usableFromInline
  let __header_ptr: UnsafePointer<RedBlackTree.___Header>
  @usableFromInline
  let __node_ptr: UnsafePointer<RedBlackTree.___Node>
  @usableFromInline
  let __value_ptr: UnsafePointer<Element>
}

extension _UnsafeHandle: _UnsafeHandleCommon {

  @inlinable func __value_(_ p: _NodePtr) -> _Key {
    __value_(__value_ptr[p])
  }
}

extension _UnsafeHandle: ReadHandleImpl {}
extension _UnsafeHandle: NodeFindProtocol & NodeFindEtcProtocol & FindLeafEtcProtocol {}

@usableFromInline
protocol _UnsafeHandleBase {
  associatedtype VC: ValueComparer
  func _read<R>(_ body: (_UnsafeHandle<VC>) throws -> R) rethrows -> R
}

extension _UnsafeHandleBase {

  @inlinable
  func __ref_(_ rhs: _NodeRef) -> _NodePtr {
    _read { $0.__ref_(rhs) }
  }
  
  @inlinable
  func __find_leaf_high(_ __parent: inout _NodePtr, _ __v: VC._Key) -> _NodeRef {
    _read { $0.__find_leaf_high(&__parent, __v) }
  }

  @inlinable
  func __find_equal(_ __parent: inout _NodePtr, _ __v: VC._Key) -> _NodeRef {
    _read { $0.__find_equal(&__parent, __v) }
  }

  @inlinable
  func find(_ __v: VC._Key) -> _NodePtr {
    _read { $0.find(__v) }
  }
  
  @inlinable
  func
  __equal_range_multi(_ __k: VC._Key) -> (_NodePtr, _NodePtr) {
    _read { $0.__equal_range_multi(__k) }
  }
}

extension _UnsafeHandle {

  @inlinable
  @inline(__always)
  func pointer(_ ptr: _NodePtr, offsetBy distance: Int, limitedBy limit: _NodePtr? = .none, type: String) -> _NodePtr {
    return distance > 0
    ? pointer(ptr, nextBy: UInt(distance), limitedBy: limit, type: type)
    : pointer(ptr, prevBy: UInt(abs(distance)), limitedBy: limit, type: type)
  }

  @inlinable
  @inline(__always)
  func pointer(_ ptr: _NodePtr, prevBy distance: UInt, limitedBy limit: _NodePtr? = .none, type: String) -> _NodePtr {
    var ptr = ptr
    var distance = distance
    while distance != 0, ptr != limit {
      // __begin_nodeを越えない
      guard ptr != __begin_node else {
        fatalError("\(type) index is out of Bound.")
      }
      ptr = __tree_prev_iter(ptr)
      distance -= 1
    }
    return ptr
  }

  @inlinable
  @inline(__always)
  func pointer(_ ptr: _NodePtr, nextBy distance: UInt, limitedBy limit: _NodePtr? = .none, type: String) -> _NodePtr {
    var ptr = ptr
    var distance = distance
    while distance != 0, ptr != limit {
      // __end_node()を越えない
      guard ptr != __end_node() else {
        fatalError("\(type) index is out of Bound.")
      }
      ptr = __tree_next_iter(ptr)
      distance -= 1
    }
    return ptr
  }
  
  @inlinable
  @inline(__always)
  func distance(__first: _NodePtr, __last: _NodePtr) -> Int {
    var __first = __first
    var __r = 0
    while __first != __last {
      __first = __tree_next_iter(__first)
      __r += 1
    }
    return __r
  }
}
