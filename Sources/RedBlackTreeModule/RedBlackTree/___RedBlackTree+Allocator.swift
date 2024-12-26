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

import Collections

@usableFromInline
typealias ___RedBlackTreeDefaultAllocator = ___RedBlackTreeNonleakingAllocator

@usableFromInline
protocol ___RedBlackTreeAllocatorBase: ___RedBlackTreeBody {
  
}

extension ___RedBlackTreeAllocatorBase {
  @inlinable @inline(__always)
  func ___is_valid(_ p: _NodePtr) -> Bool {
    ___nodes[p].__parent_ != .nullptr
  }

  @inlinable @inline(__always)
  mutating func ___invalidate(_ p: _NodePtr) {
    ___nodes[p].__parent_ = .nullptr
  }
}

// 一度削除したノードやエレメントの箇所を再利用せず、ゴミとして残すもの
@usableFromInline
protocol ___RedBlackTreeLeakingAllocator: ___RedBlackTreeAllocatorBase { }

extension ___RedBlackTreeLeakingAllocator {
  
  @inlinable
  mutating func __construct_node(_ k: Element) -> _NodePtr {
    let n = Swift.min(___nodes.count, ___elements.count)
    ___nodes.append(.zero)
    ___elements.append(k)
    return n
  }

  @inlinable
  mutating func destroy(_ p: _NodePtr) {
    ___invalidate(p)
  }
}

// 一度削除したノードやエレメントの箇所を優先的に再利用するもの
// 末尾の未使用領域の開放も行う
@usableFromInline
protocol ___RedBlackTreeNonleakingAllocator: ___RedBlackTreeAllocatorBase {
  var ___recycle: Heap<_NodePtr> { get set }
}

extension ___RedBlackTreeNonleakingAllocator {
  
  @inlinable
  mutating func ___finalize_destroy() {
    // 未使用末尾を開放する
    var last = ___nodes.count
    while last != 0, !___recycle.isEmpty, ___recycle.max == last - 1 {
      _ = ___recycle.popMax()
      last -= 1
    }
    let amount = max(___nodes.count - last, 0)
    ___nodes.removeLast(amount)
    ___elements.removeLast(amount)
  }

  @inlinable
  mutating func __construct_node(_ k: Element) -> _NodePtr {
    if let stock = ___recycle.popMin() {
      ___elements[stock] = k
      return stock
    }
    let n = Swift.min(___nodes.count, ___elements.count)
    ___nodes.append(.zero)
    ___elements.append(k)
    return n
  }

  @inlinable
  mutating func destroy(_ p: _NodePtr) {
    ___invalidate(p)
    ___recycle.insert(p)
    ___finalize_destroy()
  }
}

