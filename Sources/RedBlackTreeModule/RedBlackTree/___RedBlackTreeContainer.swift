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
protocol ___RedBlackTreeContainer: ___RedBlackTreeContainerBase {
  var ___stock: Heap<_NodePtr> { get set }
}

extension ___RedBlackTreeContainer {

  @inlinable
  mutating func __construct_node(_ k: Element) -> _NodePtr {
    if let stock = ___stock.popMin() {
      ___values[stock] = k
      return stock
    }
    let n = Swift.min(___nodes.count, ___values.count)
    ___nodes.append(.zero)
    ___values.append(k)
    return n
  }

  @inlinable
  mutating func destroy(_ p: _NodePtr) {
    ___nodes[p].invalidate()
    ___stock.insert(p)
  }
}

extension ___RedBlackTreeContainer {

  @usableFromInline
  typealias ___Index = ___RedBlackTree.Index
  
  @inlinable @inline(__always)
  func ___index_begin() -> ___Index {
    ___Index(___begin())
  }

  @inlinable @inline(__always)
  func ___index_end() -> ___Index {
    ___Index(___end())
  }

  @inlinable @inline(__always)
  func ___index_before(_ i: ___Index, type: String) -> ___Index {
    let i = i.pointer
    return _read { tree in
      guard i != tree.__begin_node else {
        fatalError("Attempting to access \(type) elements using an invalid index")
      }
      return ___Index(tree.__tree_prev_iter(i))
    }
  }

  @inlinable @inline(__always)
  func ___index_after(_ i: ___Index, type: String) -> ___Index {
    let i = i.pointer
    return _read { tree in
      guard i != tree.__end_node() else {
        fatalError("Attempting to access \(type) elements using an invalid index")
      }
      return ___Index(tree.__tree_next_iter(i))
    }
  }
}

extension ___RedBlackTreeContainer {

  @inlinable
  func ___index(_ i: ___Index, offsetBy distance: Int, type: String) -> ___Index {
    ___Index(pointer(i.pointer, offsetBy: distance, type: type))
  }

  @inlinable
  func ___index(
    _ i: ___Index, offsetBy distance: Int, limitedBy limit: ___Index, type: String
  ) -> ___Index? {
    ___Index?(pointer(
      i.pointer, offsetBy: distance, limitedBy: limit.pointer, type: type))
  }

  @inlinable
  @inline(__always)
  func pointer(
    _ ptr: _NodePtr, offsetBy distance: Int, limitedBy limit: _NodePtr? = .none, type: String
  ) -> _NodePtr {
    return distance > 0
      ? pointer(ptr, nextBy: UInt(distance), limitedBy: limit, type: type)
      : pointer(ptr, prevBy: UInt(abs(distance)), limitedBy: limit, type: type)
  }

  @inlinable
  @inline(__always)
  func pointer(
    _ ptr: _NodePtr, prevBy distance: UInt, limitedBy limit: _NodePtr? = .none, type: String
  ) -> _NodePtr {
    _read { tree in
      var ptr = ptr
      var distance = distance
      while distance != 0, ptr != limit {
        // __begin_nodeを越えない
        guard ptr != tree.__begin_node else {
          fatalError("\(type) index is out of Bound.")
        }
        ptr = tree.__tree_prev_iter(ptr)
        distance -= 1
      }
      guard distance == 0 else {
        return .nullptr
      }
      assert(ptr != .nullptr)
      return ptr
    }
  }

  @inlinable
  @inline(__always)
  func pointer(
    _ ptr: _NodePtr, nextBy distance: UInt, limitedBy limit: _NodePtr? = .none, type: String
  ) -> _NodePtr {
    _read { tree in
      var ptr = ptr
      var distance = distance
      while distance != 0, ptr != limit {
        // __end_node()を越えない
        guard ptr != tree.__end_node() else {
          fatalError("\(type) index is out of Bound.")
        }
        ptr = tree.__tree_next_iter(ptr)
        distance -= 1
      }
      guard distance == 0 else {
        return .nullptr
      }
      assert(ptr != .nullptr)
      return ptr
    }
  }
}

