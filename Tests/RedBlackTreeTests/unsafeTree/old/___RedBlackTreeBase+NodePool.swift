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

#if true
  // 多分試作コード
  // 消して大丈夫そう(2026/01/03)
  #if DEBUG
    @testable import RedBlackTreeModule

    // 性能面で不利なはずのもの。
    // 性能過敏な部分なので、しばらく保留
    // テストでの利用を想定して切り出した
    @usableFromInline
    protocol ___RedBlackTreeNodePoolProtocol: TreeNodeProtocol {
      associatedtype Element
      var ___destroy_node: _NodePtr { get nonmutating set }
      var ___destroy_count: Int { get nonmutating set }
      func ___initialize(_: Element) -> _NodePtr
      func ___element(_ p: _NodePtr, _: Element)
    }

    extension ___RedBlackTreeNodePoolProtocol {
      /// O(1)
      @inlinable
      @inline(__always)
      internal func ___pushDestroy(_ p: _NodePtr) {
        __left_(p, ___destroy_node)
        __right_(p, p)
        __parent_(p, nullptr)
        __is_black_(p, false)
        ___destroy_node = p
        ___destroy_count += 1
      }
      /// O(1)
      @inlinable
      @inline(__always)
      internal func ___popDetroy() -> _NodePtr {
        let p = __right_(___destroy_node)
        ___destroy_node = __left_unsafe(p)
        ___destroy_count -= 1
        return p
      }
      /// O(1)
      @inlinable
      internal func ___clearDestroy() {
        ___destroy_node = nullptr
        ___destroy_count = 0
      }

      #if AC_COLLECTIONS_INTERNAL_CHECKS
        /// O(*k*)
        var ___destroyNodes: [_NodePtr] {
          if ___destroy_node == nullptr {
            return []
          }
          var nodes: [_NodePtr] = [___destroy_node]
          while let l = nodes.last, __left_(l) != nullptr {
            nodes.append(__left_(l))
          }
          return nodes
        }
      #endif

      @inlinable
      internal func ___recycle(_ k: Element) -> _NodePtr {
        let p = ___popDetroy()
        ___element(p, k)
        return p
      }

      @inlinable
      internal func __construct_node(_ k: Element) -> _NodePtr {
        ___destroy_count > 0 ? ___recycle(k) : ___initialize(k)
      }

      @inlinable
      func destroy(_ p: _NodePtr) {
        ___pushDestroy(p)
      }
    }
  #endif
#endif
