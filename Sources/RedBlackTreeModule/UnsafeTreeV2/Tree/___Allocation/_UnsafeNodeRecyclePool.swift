// Copyright 2024-2026 narumij
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
// Copyright © 2003-2025 The LLVM Project.
// Licensed under the Apache License, Version 2.0 with LLVM Exceptions.
// The original license can be found at https://llvm.org/LICENSE.txt
//
// This Swift implementation includes modifications and adaptations made by narumij.

@usableFromInline
protocol _UnsafeNodeRecyclePool: UnsafeTreePointer {
  var recycleHead: _NodePtr { get set }
  var count: Int { get set }
  var freshPoolUsedCount: Int { get set }
  var nullptr: _NodePtr { get }
  var freshBucketAllocator: _UnsafeNodeFreshBucketAllocator { get }
}

extension _UnsafeNodeRecyclePool {

  @inlinable
  mutating func ___pushRecycle(_ p: _NodePtr) {
    assert(p.pointee.___node_id_ > .end)
    assert(recycleHead != p)
    count -= 1
    #if DEBUG
      p.pointee.___recycle_count += 1
    #endif
    freshBucketAllocator.deinitialize(p.advanced(by: 1))
    #if GRAPHVIZ_DEBUG
      p!.pointee.__right_ = nil
      p!.pointee.__parent_ = nil
    #endif
    p.pointee.___needs_deinitialize = false
    p.pointee.__left_ = recycleHead
    recycleHead = p
  }

  @inlinable
  mutating func ___popRecycle() -> _NodePtr {
    let p = recycleHead
    recycleHead = p.pointee.__left_
    count += 1
    p.pointee.___needs_deinitialize = true
    return p
  }

  @usableFromInline
  mutating func ___flushRecyclePool() {
    recycleHead = nullptr
    count = 0
  }

  #if DEBUG
    @usableFromInline
    var recycleCount: Int {
      freshPoolUsedCount - count
    }
  #endif
}

extension _UnsafeNodeRecyclePool {
  #if DEBUG
    @usableFromInline
    internal var ___recycleNodes: [Int] {
      var nodes: [Int] = []
      var last = recycleHead
      while last != nullptr {
        nodes.append(last.pointee.___node_id_)
        last = last.pointee.__left_
      }
      return nodes
    }
  #endif
}
