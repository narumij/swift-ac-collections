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
protocol UnsafeNodeRecyclePool
where _NodePtr == UnsafeMutablePointer<UnsafeNode>? {
  associatedtype _Value
  associatedtype _NodePtr
  var destroyNode: _NodePtr { get set }
  var destroyCount: Int { get set }
}

extension UnsafeNodeRecyclePool {
  
  @inlinable
  @inline(__always)
  mutating func ___pushRecycle(_ p: _NodePtr) {
    assert(p != nil)
    assert(destroyNode != p)
    UnsafePair<_Value>.__value_ptr(p)?.deinitialize(count: 1)
    p?.pointee.___needs_deinitialize = false
    p?.pointee.__left_ = destroyNode
    p?.pointee.__right_ = p
    p?.pointee.__parent_ = nil
    destroyNode = p
    destroyCount += 1
  }
  
  @inlinable
  @inline(__always)
  mutating func ___popRecycle() -> _NodePtr {
    assert(destroyCount > 0)
    let p = destroyNode?.pointee.__right_
    destroyNode = p?.pointee.__left_
    destroyCount -= 1
    return p
  }
  
  @inlinable
  @inline(__always)
  mutating func ___clearRecycle() {
    destroyNode = nil
    destroyCount = 0
  }
}

extension UnsafeNodeRecyclePool {
  @inlinable
  @inline(__always)
  internal var ___destroyNodes: [Int] {
    var nodes: [Int] = []
    var last = destroyNode
    while let l = last {
      nodes.append(l.pointee.___node_id_)
      last = l.pointee.__left_
    }
    return nodes
  }
}

extension UnsafeTree {

  @nonobjc
  @inlinable
  @inline(__always)
  internal var ___destroyNodes: [Int] {
    _header.___destroyNodes
  }
}
