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
protocol MergeProtocol: KeyProtocol & FindEqualProtocol & FindLeafProtocol & InsertNodeAtProtocol & AllocatorProtocol { }

@usableFromInline
protocol HandleProtocol: AllocatorProtocol & KeyProtocol & ValueProtocol & BeginProtocol & EndProtocol & MemberProtocol & EraseProtocol { }

extension HandleProtocol {
  @usableFromInline
  typealias __node_pointer = _NodePtr
  
  @inlinable @inline(__always)
  func __get_key(_ v: _Key) -> _Key { v }
}

extension MergeProtocol {
  
  @usableFromInline
  typealias __parent_pointer = _NodePtr
  
  @inlinable @inline(__always)
  func __get_np(_ p: _NodePtr) -> _NodePtr { p }

  @inlinable @inline(__always)
  func static_cast___node_base_pointer_(_ p: _NodePtr) -> _NodePtr { p }
  
  @inlinable
  @inline(__always)
  public func __node_handle_merge_unique<_Tree>(_ __source: _Tree)
  where _Tree: HandleProtocol, _Tree._Key == _Key, _Tree.Element == Element {
    
    var __i = __source.__begin_node; while __i != __source.end() {
      var __src_ptr: _Tree.__node_pointer = __get_np(__i)
      var __parent: __parent_pointer = .zero
      let __child = __find_equal(&__parent, __source.__get_key(__source.__value_(__src_ptr)))
      __i = __source.__tree_next_iter(__i)
      if (__ptr_(__child) != .nullptr) {
        continue; }
#if false
      // C++では本物のポインタで動作し、挿入後はノードがポインタを介して共有されるため、削除が行われる
      _ = __source.__remove_node_pointer(__src_ptr);
#else
      // ポインタを受け取れないので、代わりにノードを作る
      __src_ptr = __construct_node(__source.___element(__src_ptr))
#endif
      __insert_node_at(__parent, __child, static_cast___node_base_pointer_(__src_ptr))
    }
  }
  
  @inlinable
  @inline(__always)
  public func __node_handle_merge_multi<_Tree>(_ __source: _Tree)
  where _Tree: HandleProtocol, _Tree._Key == _Key, _Tree.Element == Element {

    var __i = __source.__begin_node; while __i != __source.end() {
      var __src_ptr: _Tree.__node_pointer = __get_np(__i)
      var __parent: __parent_pointer = .zero
      let __child = __find_leaf_high(&__parent, __source.__get_key(__source.__value_(__src_ptr)))
      __i = __source.__tree_next_iter(__i)
#if false
      // C++では本物のポインタで動作し、挿入後はノードがポインタを介して共有されるため、削除が行われる
      _ = __source.__remove_node_pointer(__src_ptr);
#else
      // ポインタを受け取れないので、代わりにノードを作る
      __src_ptr = __construct_node(__source.___element(__src_ptr))
#endif
      __insert_node_at(__parent, __child, static_cast___node_base_pointer_(__src_ptr));
    }
  }
}
